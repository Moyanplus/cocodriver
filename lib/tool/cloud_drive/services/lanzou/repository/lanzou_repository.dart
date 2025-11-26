import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../core/logging/log_manager.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../api/lanzou_api_client.dart';
import '../api/lanzou_base_service.dart';
import '../lanzou_config.dart';
import '../exceptions/lanzou_exceptions.dart';
import '../models/lanzou_response_models.dart';
import '../models/lanzou_request_models.dart';
import '../utils/lanzou_utils.dart';
import '../api/lanzou_vei_service.dart';

/// 蓝奏云数据仓库。
///
/// 封装所有需要 cookie + uid 的接口调用，并负责缓存 VEI、拼装请求
/// 以及转换为业务模型，避免在多个 Service 中重复实现。
class LanzouRepository {
  LanzouRepository({required this.cookies, required this.uid, this.account})
    : _client = LanzouApiClient.fromCookies(cookies: cookies, uid: uid);

  /// 根据账号信息构建仓库，自动解析 Cookie 获取 UID。
  factory LanzouRepository.fromAccount(CloudDriveAccount account) {
    final cookies = account.cookies ?? '';
    final uid = LanzouUtils.extractUid(cookies);
    if (uid == null || uid.isEmpty) {
      throw LanzouApiException('无法从Cookie中提取UID');
    }
    return LanzouRepository(cookies: cookies, uid: uid, account: account);
  }

  final String cookies;
  final String uid;
  final LanzouApiClient _client;
  final CloudDriveAccount? account;
  String? _cachedVei;

  Future<List<CloudDriveFile>> fetchFiles(String folderId) async {
    final request = LanzouFolderRequest(
      folderId: folderId,
      taskKey: 'getFiles',
    );
    final response = await _postWithVei(request);

    final parsed = LanzouFilesResponse.fromMap(response);
    if (!parsed.success) {
      throw LanzouApiException(parsed.info ?? '获取文件列表失败');
    }
    return parsed.items.map((file) => _mapFile(file)).toList();
  }

  Future<List<CloudDriveFile>> fetchFolders(String folderId) async {
    final request = LanzouFolderRequest(
      folderId: folderId,
      taskKey: 'getFolders',
    );
    final response = await _postWithVei(
      request,
      allowFolderMeta: true,
    );

    final parsed = LanzouFoldersResponse.fromMap(response);
    if (!parsed.success) {
      throw LanzouApiException(parsed.info ?? '获取文件夹失败');
    }
    return parsed.items.map((folder) => _mapFolder(folder)).toList();
  }

  /// 获取文件详情（容量、账户信息等）。
  Future<Map<String, dynamic>?> fetchFileDetail(String fileId) async {
    final detailRequest = LanzouFileDetailRequest(fileId: fileId);
    final response = await _postExpectSuccess(detailRequest.build());

    return response['info'] as Map<String, dynamic>?;
  }

  Future<bool> validateCookies() async {
    final request = const LanzouValidateCookiesRequest();
    final response = await _client.post(
      request.build(LanzouConfig.getVeiParameter()),
    );

    final isValid = response['zt'] == 1;
    if (!isValid) {
      LogManager().cloudDrive('Cookie 验证失败: ${response['info']}');
    }
    return isValid;
  }

  /// 移动文件到指定文件夹。
  Future<bool> moveFile({
    required String fileId,
    String? targetFolderId,
  }) async {
    await _postExpectSuccess(
      LanzouMoveFileRequest(
        fileId: fileId,
        targetFolderId: targetFolderId,
      ).build(),
    );
    return true;
  }

  /// 上传文件，返回蓝奏云原始响应。
  Future<Map<String, dynamic>> uploadFile({
    required String filePath,
    required String fileName,
    String folderId = '-1',
  }) async {
    final targetAccount = _accountOrThrow();
    final file = File(filePath);
    if (!await file.exists()) {
      throw LanzouApiException('文件不存在: $filePath');
    }

    final uid = LanzouUtils.extractUid(targetAccount.cookies ?? '');
    if (uid == null || uid.isEmpty) {
      throw LanzouApiException('无法从Cookie中提取UID，请重新登录');
    }

    final headers = _buildUploadHeaders(targetAccount.cookies ?? '', uid);
    final formData = FormData.fromMap({
      'task': LanzouConfig.getTaskId('uploadFile'),
      'vie': '2',
      've': '2',
      'id': 'WU_FILE_1',
      'name': fileName,
      'type': LanzouConfig.getMimeType(fileName.split('.').last.toLowerCase()),
      'lastModifiedDate': DateTime.now().toIso8601String(),
      'size': (await file.length()).toString(),
      'folder_id_bb_n': folderId,
      'upload_file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    final response = await LanzouBaseService.createDio(targetAccount).post(
      LanzouConfig.uploadUrl,
      data: formData,
      options: Options(
        headers: headers,
        followRedirects: true,
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode != 200) {
      throw LanzouApiException('上传请求失败: ${response.statusCode}');
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['zt'] == 1) {
        return {
          'success': true,
          'message': data['info'],
          'file': data['text']?[0],
        };
      }
      throw LanzouApiException(data['info']?.toString() ?? '上传失败');
    }
    throw LanzouApiException('响应格式错误');
  }

  /// 构造包含 VEI 的请求体并发送。
  Future<Map<String, dynamic>> _postWithVei(
    LanzouFolderRequest request, {
    bool allowFolderMeta = false,
  }) async {
    final vei = await _getVei();
    final data = request.build(vei);
    if (allowFolderMeta) {
      return _postAllowFolderMeta(data);
    }
    return _postExpectSuccess(data);
  }

  /// 发送请求并保证 `zt == 1`，否则抛出异常。
  Future<Map<String, dynamic>> _postExpectSuccess(
    Map<String, dynamic> data,
  ) async {
    final response = await _client.post(data);
    final parsed = LanzouOperationResponse.fromMap(response);
    if (parsed.success) {
      return response;
    }
    throw LanzouApiException(parsed.info ?? '蓝奏云请求失败');
  }

  Future<Map<String, dynamic>> _postAllowFolderMeta(
    Map<String, dynamic> data,
  ) async {
    final response = await _client.post(data);
    final parsed = LanzouOperationResponse.fromMap(response);
    if (parsed.success || _containsFolderMeta(response)) {
      return response;
    }
    throw LanzouApiException(parsed.info ?? '蓝奏云请求失败');
  }

  bool _containsFolderMeta(Map<String, dynamic> response) {
    final info = response['info'];
    if (info is List && info.isNotEmpty) {
      final first = info.first;
      if (first is Map<String, dynamic>) {
        return first.containsKey('folderid') || first.containsKey('now');
      }
    }
    return false;
  }

  /// 获取或返回缓存的 VEI 参数。
  Future<String> _getVei() async {
    if (_cachedVei != null && _cachedVei!.isNotEmpty) {
      return _cachedVei!;
    }

    final vei = await LanzouVeiService.initializeVeiParameter(
      uid,
      cookies: cookies,
    );
    _cachedVei = vei ?? LanzouConfig.getVeiParameter();
    return _cachedVei!;
  }

  /// 获取绑定账号，未绑定时抛异常。
  CloudDriveAccount _accountOrThrow() {
    final acc = account;
    if (acc == null) {
      throw LanzouApiException('当前仓库未绑定账号，无法执行该操作');
    }
    return acc;
  }

  Map<String, String> _buildUploadHeaders(String cookies, String uid) {
    return {
      ...LanzouConfig.defaultHeaders,
      'Cookie': cookies,
      'Referer': '${LanzouConfig.baseUrl}/',
      'Origin': LanzouConfig.baseUrl,
      'X-Requested-With': 'XMLHttpRequest',
      'Content-Type': 'multipart/form-data',
    };
  }

  static DateTime? _tryParseTime(dynamic time) {
    if (time == null) return null;
    return DateTime.tryParse(time.toString());
  }

  CloudDriveFile _mapFile(LanzouRawFile raw) => CloudDriveFile(
    id: raw.id,
    name: raw.name,
    size: LanzouUtils.parseFileSize(raw.size),
    modifiedTime: _tryParseTime(raw.time),
    isFolder: false,
    metadata: _buildFileMetadata(raw),
    downloadCount: raw.downloads ?? -1,
  );

  CloudDriveFile _mapFolder(LanzouRawFolder raw) => CloudDriveFile(
    id: raw.id,
    name: raw.name,
    modifiedTime: _tryParseTime(raw.time),
    isFolder: true,
  );

  Map<String, dynamic>? _buildFileMetadata(LanzouRawFile raw) {
    final data = <String, dynamic>{};
    void put(String key, dynamic value) {
      if (value != null) data[key] = value;
    }

    put('displayName', raw.displayName);
    put('icon', raw.icon);
    put('downloads', raw.downloads);
    put('isLock', raw.isLock);
    put('fileLock', raw.fileLock);
    put('isBakDownload', raw.isBakDownload);
    put('isCopyright', raw.isCopyright);
    put('isDescription', raw.isDescription);
    put('isIcon', raw.isIcon);
    put('onOff', raw.onOff);
    put('bakDownload', raw.bakDownload);

    return data.isEmpty ? null : data;
  }
}
