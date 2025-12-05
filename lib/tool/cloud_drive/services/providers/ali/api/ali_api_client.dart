import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../../../../../core/logging/log_manager.dart';
import '../../../shared/http_client.dart';
import '../../../../base/cloud_drive_account_service.dart'
    show CloudDriveAccountService;
import '../../../../data/models/cloud_drive_entities.dart';
import '../../../../data/models/cloud_drive_dtos.dart';
import '../../../../core/result.dart';
import '../../../../base/cloud_drive_operation_service.dart';
import '../api/ali_base_service.dart';
import '../models/requests/ali_list_request.dart';
import '../models/requests/ali_operation_requests.dart';
import '../models/responses/ali_file_list_response.dart';
import '../models/responses/ali_operation_response.dart';
import '../models/responses/ali_api_result.dart';
import '../models/responses/ali_share_record.dart';
import '../api/ali_config.dart';

/// 阿里云盘 API 客户端（当前封装现有 Service，后续可逐步替换为显式请求/响应模型）。
class AliApiClient {
  static final Map<String, CloudDriveHttpClient> _httpCache = {};
  static final Map<String, String> _authSnapshot = {};

  CloudDriveHttpClient _http(CloudDriveAccount account) {
    final key = account.id.toString();
    final auth = _authKey(account);
    final cached = _httpCache[key];
    if (cached != null && _authSnapshot[key] == auth) {
      return cached;
    }
    final fresh = AliBaseService.createApiHttpClient(account);
    _httpCache[key] = fresh;
    _authSnapshot[key] = auth;
    return fresh;
  }

  static void clearHttpCache({String? accountId}) {
    if (accountId == null) {
      _httpCache.clear();
      _authSnapshot.clear();
    } else {
      _httpCache.remove(accountId);
      _authSnapshot.remove(accountId);
    }
  }

  Future<CloudDriveAccountInfo?> getUserInfo({
    required CloudDriveAccount account,
  }) async {
    final result = await _post(
      account: account,
      baseUrl: AliConfig.baseUrl,
      path: AliConfig.getApiEndpoint('getUserInfo'),
      data: AliConfig.buildUserInfoParams(),
    );
    if (!result.success || result.data == null) return null;
    final responseData = result.data!;
    if (!AliBaseService.isApiSuccess(responseData)) {
      throw _buildException(
        '获取用户信息',
        result.copyWith(message: _mergeMessage(result, responseData)),
      );
    }

    return CloudDriveAccountInfo(
      username:
          responseData['user_name']?.toString() ??
          responseData['display_name']?.toString() ??
          '未知用户',
      phone: responseData['phone']?.toString(),
      photo: responseData['avatar']?.toString(),
      uk: 0,
      isVip: responseData['vip_identity']?.toString() != 'member',
      isSvip: responseData['vip_identity']?.toString() == 'svip',
      isScanVip: false,
      loginState: responseData['status']?.toString() == 'enabled' ? 1 : 0,
    );
  }

  Future<String?> getDriveId(CloudDriveAccount account) async {
    if (account.driveId != null && account.driveId!.isNotEmpty) {
      return account.driveId;
    }

    final result = await _post(
      account: account,
      baseUrl: AliConfig.baseUrl,
      path: AliConfig.getApiEndpoint('getUserInfo'),
      data: AliConfig.buildUserInfoParams(),
    );
    if (!result.success || result.data == null) return null;
    final responseData = result.data!;
    if (!AliBaseService.isApiSuccess(responseData)) return null;

    final driveId = responseData['resource_drive_id'] as String?;
    if (driveId != null && driveId.isNotEmpty) {
      await CloudDriveAccountService.saveDriveId(account, driveId);
      return driveId;
    }
    return null;
  }

  Future<CloudDriveQuotaInfo?> getQuotaInfo({
    required CloudDriveAccount account,
  }) async {
    final result = await _post(
      account: account,
      path: AliConfig.getApiEndpoint('getQuotaInfo'),
      data: AliConfig.buildQuotaInfoParams(),
    );
    if (!result.success || result.data == null) return null;
    final responseData = AliBaseService.getResponseData(result.data!);
    if (responseData == null) return null;

    final driveDetails =
        responseData['drive_capacity_details'] as Map<String, dynamic>? ?? {};
    final limitInfo =
        responseData['user_capacity_limit_details'] as Map<String, dynamic>? ??
        {};

    final totalSize = driveDetails['drive_total_size'] as int? ?? 0;
    final usedSize = driveDetails['drive_used_size'] as int? ?? 0;

    return CloudDriveQuotaInfo(
      total: totalSize,
      used: usedSize,
      free: totalSize - usedSize,
      expire: limitInfo['limit_consume'] as bool? ?? false,
      serverTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    final futures = await Future.wait([
      getUserInfo(account: account),
      getQuotaInfo(account: account),
    ]);
    final accountInfo = futures[0] as CloudDriveAccountInfo?;
    final quotaInfo = futures[1] as CloudDriveQuotaInfo?;
    if (accountInfo == null) return null;
    return CloudDriveAccountDetails(
      id: accountInfo.username,
      name: accountInfo.username,
      accountInfo: accountInfo,
      quotaInfo: quotaInfo,
    );
  }

  Future<AliFileListResponse> listFiles({
    required CloudDriveAccount account,
    required String driveId,
    required AliListRequest request,
  }) async {
    // 阿里接口需要 root 而不是 "/"，driveId 必须有效。
    final parentId =
        (request.parentFileId.isEmpty || request.parentFileId == '/')
            ? 'root'
            : request.parentFileId;
    final result = await _post<Map<String, dynamic>>(
      account: account,
      path: AliConfig.getApiEndpoint('getFileList'),
      query: AliConfig.buildFileListQueryParams(),
      data: AliConfig.buildFileListParams(
        driveId: driveId,
        parentFileId: parentId,
        limit: request.pageSize,
        marker: null,
      ),
    );
    if (!result.success || result.data == null) {
      return const AliFileListResponse(files: []);
    }
    final items = result.data!['items'] as List<dynamic>? ?? [];
    final files =
        items
            .map(
              (e) =>
                  e is Map<String, dynamic>
                      ? AliBaseService.parseFileItem(e)
                      : null,
            )
            .whereType<CloudDriveFile>()
            .toList();
    return AliFileListResponse(files: files);
  }

  Future<List<CloudDriveFile>> listRecycle({
    required CloudDriveAccount account,
    required String driveId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final result = await _post<Map<String, dynamic>>(
      account: account,
      path: AliConfig.getApiEndpoint('recycleList'),
      data: {
        'drive_id': driveId,
        'limit': pageSize,
        'order_by': 'name',
        'order_direction': 'DESC',
      },
    );

    if (!result.success || result.data == null) return const [];
    final items = result.data!['items'] as List<dynamic>? ?? [];
    final files = <CloudDriveFile>[];
    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;
      final parsed = AliBaseService.parseFileItem(item);
      if (parsed == null) continue;
      final meta = Map<String, dynamic>.from(parsed.metadata ?? {});
      meta.addAll({'trashedAt': item['trashed_at'], 'status': item['status']});
      files.add(
        parsed.copyWith(
          folderId: item['parent_file_id']?.toString() ?? 'recyclebin',
          metadata: meta,
        ),
      );
    }
    return files;
  }

  Future<List<AliShareRecord>> listShareRecords({
    required CloudDriveAccount account,
    int limit = 20,
    String orderBy = 'browse_count',
    String orderDirection = 'DESC',
  }) async {
    final data = <String, dynamic>{
      'include_canceled': false,
      'category': 'file,album',
      'limit': limit,
      'order_by': orderBy,
      'order_direction': orderDirection,
    };
    final userId = _extractUserId(account);
    if (userId != null && userId.isNotEmpty) {
      data['creator'] = userId;
    }

    final result = await _post<Map<String, dynamic>>(
      account: account,
      path: AliConfig.getApiEndpoint('shareList'),
      data: data,
    );

    if (!result.success || result.data == null) {
      throw _buildException('获取分享列表', result);
    }
    final items = result.data!['items'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(AliShareRecord.fromJson)
        .toList();
  }

  /// 从 Authorization token 中提取 userId（token payload 的 userId 字段）。
  String? _extractUserId(CloudDriveAccount account) {
    return AliBaseService.parseUserIdFromToken(account.authValue);
  }

  Future<AliOperationResponse> deleteFile({
    required CloudDriveAccount account,
    required AliDeleteRequest request,
  }) async {
    final driveId = await getDriveId(account);
    if (driveId == null) {
      return const AliOperationResponse(
        success: false,
        message: 'missing driveId',
      );
    }
    final result = await _post(
      account: account,
      path: AliConfig.getApiEndpoint('deleteFile'),
      data: AliConfig.buildDeleteFileParams(
        driveId: driveId,
        fileId: request.file.id,
      ),
    );
    if (!result.success) {
      throw _buildException('删除文件', result);
    }
    return AliOperationResponse(
      success: result.success,
      message: result.message,
    );
  }

  Future<AliOperationResponse> renameFile({
    required CloudDriveAccount account,
    required AliRenameRequest request,
  }) async {
    final driveId = await getDriveId(account);
    if (driveId == null) {
      return const AliOperationResponse(
        success: false,
        message: 'missing driveId',
      );
    }
    final result = await _post(
      account: account,
      path: AliConfig.getApiEndpoint('renameFile'),
      data: AliConfig.buildRenameFileParams(
        driveId: driveId,
        fileId: request.file.id,
        newName: request.newName,
      ),
    );
    if (!result.success) {
      throw _buildException('重命名', result);
    }
    return AliOperationResponse(
      success: result.success,
      message: result.message,
    );
  }

  Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required AliCreateFolderRequest request,
  }) {
    return _createFolderInternal(account, request);
  }

  Future<AliOperationResponse> moveFile({
    required CloudDriveAccount account,
    required AliMoveRequest request,
  }) async {
    final driveId = await getDriveId(account);
    if (driveId == null) {
      return const AliOperationResponse(
        success: false,
        message: 'missing driveId',
      );
    }
    final result = await _post(
      account: account,
      path: AliConfig.getApiEndpoint('moveFile'),
      data: AliConfig.buildMoveFileParams(
        driveId: driveId,
        fileId: request.file.id,
        fileName: request.file.name,
        fileType: request.file.isFolder ? 'folder' : 'file',
        toParentFileId: request.targetFolderId,
      ),
    );
    if (!result.success) {
      throw _buildException('移动文件', result);
    }
    return AliOperationResponse(
      success: result.success,
      message: result.message,
    );
  }

  Future<AliOperationResponse> copyFile({
    required CloudDriveAccount account,
    required AliCopyRequest request,
  }) async {
    // 阿里云盘暂不支持复制，返回失败占位
    return const AliOperationResponse(
      success: false,
      message: 'copy not supported',
    );
  }

  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required AliDownloadRequest request,
  }) {
    return _getDownloadUrlInternal(account, request);
  }

  Future<CloudDriveFile?> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String? parentId,
    UploadProgressCallback? onProgress,
  }) async {
    final driveId = await getDriveId(account);
    if (driveId == null) return null;

    final file = File(filePath);
    if (!await file.exists()) {
      throw CloudDriveException(
        'file not found: $filePath',
        CloudDriveErrorType.clientError,
        operation: '上传文件',
      );
    }
    final fileSize = await file.length();
    final normalizedParent =
        (parentId == null || parentId.isEmpty || parentId == '/')
            ? 'root'
            : parentId;

    final initResult = await _initUpload(
      account: account,
      driveId: driveId,
      parentId: normalizedParent,
      fileName: fileName,
      file: file,
      fileSize: fileSize,
    );

    final uploadUrl = initResult.uploadUrl;
    if (uploadUrl == null || uploadUrl.isEmpty) {
      throw CloudDriveException(
        'missing upload url',
        CloudDriveErrorType.serverError,
        operation: '上传文件',
      );
    }

    await _uploadContent(
      http: _http(account),
      uploadUrl: uploadUrl,
      file: file,
      fileSize: fileSize,
      fileName: fileName,
      contentType: initResult.contentType,
      onProgress: onProgress,
    );

    final completeData = await _completeUpload(
      account: account,
      driveId: driveId,
      uploadId: initResult.uploadId,
      fileId: initResult.fileId,
    );

    final parsed = AliBaseService.parseFileItem(completeData);
    if (parsed != null) return parsed;

    return CloudDriveFile(
      id: completeData['file_id']?.toString() ?? initResult.fileId,
      name: completeData['name']?.toString() ?? fileName,
      isFolder: false,
      size: fileSize,
      folderId: normalizedParent,
      createdAt: DateTime.tryParse(completeData['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(completeData['updated_at']?.toString() ?? ''),
      metadata: completeData,
    );
  }

  Future<CloudDriveFile?> _createFolderInternal(
    CloudDriveAccount account,
    AliCreateFolderRequest request,
  ) async {
    final driveId = await getDriveId(account);
    if (driveId == null) return null;
    final normalizedParentId =
        (request.parentId == null ||
                request.parentId!.isEmpty ||
                request.parentId == '/')
            ? 'root'
            : request.parentId;
    final body = AliConfig.buildCreateFolderParams(
      name: request.name,
      parentFileId: normalizedParentId,
      driveId: driveId,
    );
    final result = await _post(
      account: account,
      path: AliConfig.getApiEndpoint('createFolder'),
      data: body,
    );
    if (!result.success || result.data == null) {
      final respData = result.data ?? {};
      final msg = result.message ?? AliBaseService.getErrorMessage(respData);
      LogManager().cloudDrive(
        '阿里云盘 - 创建文件夹失败: ${result.statusCode} body=$respData',
      );
      throw CloudDriveException(
        msg,
        CloudDriveErrorType.serverError,
        operation: '创建文件夹',
        statusCode: result.statusCode,
        requestId: respData['requestId']?.toString(),
      );
    }
    final data = result.data!;
    // API 已返回完整的文件信息，优先复用通用解析逻辑以带回时间、分类等元数据。
    final parsed = AliBaseService.parseFileItem(data);
    if (parsed != null) {
      return parsed;
    }

    final fileId = data['file_id']?.toString();
    if (fileId == null) return null;
    return CloudDriveFile(
      id: fileId,
      name: data['file_name']?.toString() ?? request.name,
      isFolder: true,
      folderId: data['parent_file_id']?.toString() ?? request.parentId,
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(data['updated_at']?.toString() ?? ''),
    );
  }

  Future<String?> _getDownloadUrlInternal(
    CloudDriveAccount account,
    AliDownloadRequest request,
  ) async {
    // 优先使用请求中提供的 driveId，如果缺失则补取一次，避免未定义报错。
    var driveId = request.driveId;
    if (driveId.isEmpty) {
      driveId = await getDriveId(account) ?? '';
    }
    if (driveId.isEmpty) return null;

    final result = await _post<Map<String, dynamic>>(
      account: account,
      path: AliConfig.getApiEndpoint('downloadFile'),
      data: AliConfig.buildDownloadFileParams(
        driveId: driveId,
        fileId: request.file.id,
      ),
    );
    if (!result.success || result.data == null) return null;
    return result.data!['url']?.toString();
  }

  Future<_AliUploadInitResult> _initUpload({
    required CloudDriveAccount account,
    required String driveId,
    required String parentId,
    required String fileName,
    required File file,
    required int fileSize,
  }) async {
    final contentHash = await _computeSha1Hex(file);
    final proofCode = await _computeProofCode(
      accessToken: account.primaryAuthValue,
      file: file,
      fileSize: fileSize,
    );

    final body = {
      'drive_id': driveId,
      'parent_file_id': parentId,
      'name': fileName,
      'type': 'file',
      'check_name_mode': 'auto_rename',
      'size': fileSize,
      'part_info_list': [
        {'part_number': 1},
      ],
      'content_hash': contentHash,
      'content_hash_name': 'sha1',
      if (proofCode != null) ...{
        'proof_code': proofCode,
        'proof_version': 'v1',
      },
    };

    final result = await _post(
      account: account,
      path: AliConfig.getApiEndpoint('createFolder'),
      data: body,
    );
    if (!result.success || result.data == null) {
      throw CloudDriveException(
        'init upload failed: http ${result.statusCode}',
        CloudDriveErrorType.serverError,
        operation: '上传文件',
        statusCode: result.statusCode,
      );
    }

    final data = result.data!;
    final fileId = data['file_id']?.toString();
    final uploadId = data['upload_id']?.toString();
    Map<String, dynamic> _firstPart() {
      return (data['part_info_list'] as List?)
              ?.cast<Map<String, dynamic>>()
              .firstWhere(
                (e) => e['part_number'] == 1,
                orElse: () => const {},
              ) ??
          const {};
    }

    final part = _firstPart();
    final uploadUrl = part['upload_url']?.toString();
    final contentType = part['content_type']?.toString();
    if (fileId == null || uploadId == null) {
      throw CloudDriveException(
        'init upload missing ids',
        CloudDriveErrorType.serverError,
        operation: '上传文件',
      );
    }
    return _AliUploadInitResult(
      fileId: fileId,
      uploadId: uploadId,
      uploadUrl: uploadUrl,
      contentType: contentType,
    );
  }

  Future<void> _uploadContent({
    required CloudDriveHttpClient http,
    required String uploadUrl,
    required File file,
    required int fileSize,
    required String fileName,
    String? contentType,
    UploadProgressCallback? onProgress,
  }) async {
    final headers = <String, Object>{HttpHeaders.contentLengthHeader: fileSize};
    // 阿里返回的预签名未声明 content-type，显式传会导致签名不匹配，除非接口返回了值。
    if (contentType != null && contentType.isNotEmpty) {
      headers[HttpHeaders.contentTypeHeader] = contentType;
    }

    try {
      await http.putResponse(
        Uri.parse(uploadUrl),
        data: file.openRead(),
        headers: headers,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );
    } on DioException catch (e) {
      throw CloudDriveException(
        http.formatDioError(e),
        CloudDriveErrorType.network,
        operation: '上传文件',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw CloudDriveException(
        '上传失败: $e',
        CloudDriveErrorType.network,
        operation: '上传文件',
      );
    }
  }

  Future<Map<String, dynamic>> _completeUpload({
    required CloudDriveAccount account,
    required String driveId,
    required String uploadId,
    required String fileId,
  }) async {
    final result = await _post(
      account: account,
      path: '/v2/file/complete',
      data: {
        'drive_id': driveId,
        'upload_id': uploadId,
        'file_id': fileId,
      },
    );
    if (!result.success || result.data == null) {
      throw CloudDriveException(
        'complete upload failed: http ${result.statusCode}',
        CloudDriveErrorType.serverError,
        operation: '上传文件',
        statusCode: result.statusCode,
      );
    }
    return result.data!;
  }

  Future<String> _computeSha1Hex(File file) async {
    final digest = await sha1.bind(file.openRead()).first;
    return hex.encode(digest.bytes).toUpperCase();
  }

  Future<String?> _computeProofCode({
    required String? accessToken,
    required File file,
    required int fileSize,
  }) async {
    if (accessToken == null ||
        accessToken.isEmpty ||
        fileSize <= 0 ||
        fileSize < 8) {
      return null;
    }
    try {
      final tokenDigest = sha1.convert(utf8.encode(accessToken)).bytes;
      final offset =
          ((tokenDigest[0] << 24) |
                  (tokenDigest[1] << 16) |
                  (tokenDigest[2] << 8) |
                  tokenDigest[3]) %
              fileSize;
      final raf = await file.open();
      await raf.setPosition(offset);
      final slice = await raf.read(8);
      await raf.close();
      if (slice.isEmpty) return null;
      return base64Encode(slice);
    } catch (_) {
      return null;
    }
  }

  CloudDriveException _buildException(
    String operation,
    AliApiResult<Map<String, dynamic>> result,
  ) {
    final resp = result.data ?? {};
    final msg = result.message ?? AliBaseService.getErrorMessage(resp);
    return CloudDriveException(
      msg,
      CloudDriveErrorType.serverError,
      operation: operation,
      statusCode: result.statusCode,
      requestId:
          result.requestId ??
          resp['requestId']?.toString() ??
          resp['request_id']?.toString(),
      context: resp,
    );
  }

  Future<AliApiResult<Map<String, dynamic>>> _post<T>({
    required CloudDriveAccount account,
    required String path,
    Map<String, String>? query,
    Map<String, dynamic>? data,
    String baseUrl = AliConfig.apiUrl,
  }) async {
    try {
      final http = _http(account);
      final uri = http.buildUri(
        '$baseUrl$path',
        query ?? const {},
      );
      final response = await http.postResponse(uri, data: data);
      final status = response.statusCode;
      final respData = response.data as Map<String, dynamic>? ?? {};
      final success = AliBaseService.isHttpSuccess(status);
      return AliApiResult<Map<String, dynamic>>(
        success: success,
        data: respData,
        statusCode: status,
        message: success
            ? null
            : _mergeMessage(
                AliApiResult<Map<String, dynamic>>(
                  success: false,
                  statusCode: status,
                  data: respData,
                ),
                respData,
              ),
        requestId: response.headers['x-request-id']?.firstOrNull ??
            response.headers['x-ca-request-id']?.firstOrNull,
      );
    } on DioException catch (e) {
      final http = _http(account);
      return AliApiResult<Map<String, dynamic>>(
        success: false,
        statusCode: e.response?.statusCode,
        message: _mergeMessage(
          AliApiResult<Map<String, dynamic>>(
            success: false,
            statusCode: e.response?.statusCode,
            data: e.response?.data as Map<String, dynamic>?,
            message: http.formatDioError(e),
          ),
          e.response?.data as Map<String, dynamic>?,
        ),
        requestId: e.response?.headers['x-request-id']?.firstOrNull ??
            e.response?.headers['x-ca-request-id']?.firstOrNull,
      );
    } catch (e) {
      return AliApiResult<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  String _mergeMessage(
    AliApiResult<Map<String, dynamic>> result,
    Map<String, dynamic>? resp,
  ) {
    final code = resp?['code']?.toString();
    final msg = resp?['message']?.toString() ??
        resp?['msg']?.toString() ??
        result.message;
    if ((code == null || code.isEmpty) && msg != null) return msg;
    if (msg == null && code != null) return 'code: $code';
    if (code != null && msg != null) return 'code: $code, message: $msg';
    return result.message ?? 'unknown error';
  }

  static String _authKey(CloudDriveAccount account) =>
      '${account.id}::${account.authValue ?? ''}::${account.primaryAuthValue ?? ''}';
}

class _AliUploadInitResult {
  _AliUploadInitResult({
    required this.fileId,
    required this.uploadId,
    this.uploadUrl,
    this.contentType,
  });

  final String fileId;
  final String uploadId;
  final String? uploadUrl;
  final String? contentType;
}
