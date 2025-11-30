import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../../core/logging/log_manager.dart';
import '../../../../base/cloud_drive_operation_service.dart';
import '../../../../data/models/cloud_drive_entities.dart';
import '../../../../base/base_cloud_drive_repository.dart';
import '../../../base/cloud_drive_api_logger.dart';
import '../api/lanzou_api_client.dart';
import '../api/lanzou_dio_factory.dart';
import '../lanzou_config.dart';
import '../exceptions/lanzou_exceptions.dart';
import '../models/responses/lanzou_file_list_response.dart';
import '../models/responses/lanzou_operation_response.dart';
import '../models/responses/lanzou_upload_response.dart';
import '../models/requests/lanzou_file_requests.dart';
import '../utils/lanzou_utils.dart';
import '../api/lanzou_vei_provider.dart';
import '../models/lanzou_direct_link_models.dart';
import '../models/lanzou_result.dart';

/// 蓝奏云数据仓库。
///
/// 封装所有需要 cookie + uid 的接口调用，并负责缓存 VEI、拼装请求
/// 以及转换为业务模型，避免在多个 Service 中重复实现。
class LanzouRepository extends BaseCloudDriveRepository {
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
  static final BaseOptions _directLinkOptions = BaseOptions(
    connectTimeout: LanzouConfig.connectTimeout,
    receiveTimeout: LanzouConfig.receiveTimeout,
    sendTimeout: LanzouConfig.sendTimeout,
    headers: LanzouConfig.directLinkHeaders,
  );
  static final Dio _directLinkDio = _createDirectLinkDio();

  static Dio _createDirectLinkDio() {
    final dio = Dio(_directLinkOptions);
    dio.interceptors.add(
      CloudDriveLoggingInterceptor(
        logger: CloudDriveApiLogger(
          provider: '蓝奏云直链',
          verbose: LanzouConfig.verboseLogging,
        ),
      ),
    );
    return dio;
  }

  /// 从 Cookie 中提取 UID，便于在策略/业务层使用。
  static String? extractUidFromCookies(String cookies) =>
      LanzouUtils.extractUid(cookies);

  /// 校验 Cookie 有效性，成功返回 true。
  Future<bool> validateSession() async {
    final resp = await validateCookies();
    return resp.success;
  }

  /// 获取当前账号指定文件夹下的文件/文件夹列表。
  /// [account] 蓝奏云账号
  /// [folderId] 目标文件夹ID，默认根目录 -1
  /// [page]/[pageSize] 蓝奏云暂不分页，此处占位
  @override
  Future<List<CloudDriveFile>> listFiles({
    required CloudDriveAccount account,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final targetFolderId = folderId ?? '-1';
    final files = await fetchFiles(targetFolderId, page: page);
    final folders =
        page == 1
            ? await fetchFolders(targetFolderId)
            : const <CloudDriveFile>[];
    final all = [...folders, ...files];
    logListSummary('蓝奏云', all, folderId: targetFolderId);
    return all;
  }

  /// 请求文件列表，返回蓝奏云文件实体。
  /// [folderId] 目标文件夹ID
  Future<List<CloudDriveFile>> fetchFiles(
    String folderId, {
    int page = 1,
  }) async {
    final request = LanzouFolderRequest(
      folderId: folderId,
      taskKey: 'getFiles',
      page: page,
    );
    final response = await _postWithVei(request);

    final parsed = LanzouFilesResponse.fromMap(response.raw);
    if (!parsed.success) {
      throw LanzouApiException(parsed.info ?? '获取文件列表失败');
    }
    return parsed.items.map((file) => _mapFile(file)).toList();
  }

  /// 请求文件夹列表。
  /// [folderId] 目标文件夹ID
  Future<List<CloudDriveFile>> fetchFolders(
    String folderId, {
    int? page,
  }) async {
    final request = LanzouFolderRequest(
      folderId: folderId,
      taskKey: 'getFolders',
      page: page,
    );
    final response = await _postWithVei(request, allowFolderMeta: true);

    final parsed = LanzouFoldersResponse.fromMap(response.raw);
    if (!parsed.success) {
      throw LanzouApiException(parsed.info ?? '获取文件夹失败');
    }
    return parsed.items.map((folder) => _mapFolder(folder)).toList();
  }

  /// 获取文件详情（容量、账户信息等）。
  /// [fileId] 文件ID
  Future<LanzouFileDetailResponse> fetchFileDetail(String fileId) async {
    final detailRequest = LanzouFileDetailRequest(fileId: fileId);
    final response = await _postOperationExpectSuccess(detailRequest.build());
    return LanzouFileDetailResponse.fromOperation(response);
  }

  /// 校验当前 Cookie 是否有效。
  Future<LanzouOperationResponse> validateCookies() async {
    final request = const LanzouValidateCookiesRequest();
    final response = await _postOperationExpectSuccess(
      request.build(LanzouConfig.getVeiParameter()),
    );
    return response;
  }

  /// 删除文件/文件夹。
  /// [account] 当前账号
  /// [file] 要删除的文件或文件夹
  @override
  Future<bool> delete({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    final response = await deleteFile(fileId: file.id);
    return response.success;
  }

  /// 重命名文件/文件夹。
  /// [account] 当前账号
  /// [file] 目标文件或文件夹
  /// [newName] 新名称
  @override
  Future<bool> rename({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    final response = await renameFile(fileId: file.id, newName: newName);
    return response.success;
  }

  /// 将文件移动至目标文件夹。
  /// [account] 当前账号
  /// [file] 需要移动的文件
  /// [targetFolderId] 目标文件夹ID
  @override
  Future<bool> move({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) async {
    final response = await moveFile(
      fileId: file.id,
      targetFolderId: targetFolderId,
    );
    return response.success;
  }

  /// 蓝奏云暂未支持复制，此处默认返回 false。
  /// [account] 当前账号
  /// [file] 要复制的文件
  /// [targetFolderId] 目标文件夹ID
  @override
  Future<bool> copy({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) async {
    // 蓝奏云暂未提供复制能力
    return false;
  }

  /// 创建文件夹并返回 CloudDriveFile，失败返回 null。
  /// [account] 当前账号
  /// [name] 文件夹名称
  /// [parentId] 父级文件夹ID
  /// [description] 可选描述
  @override
  Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required String name,
    String? parentId,
    String? description,
  }) async {
    final response = await createFolderRaw(
      folderName: name,
      parentFolderId: parentId ?? '-1',
      description: description,
    );
    if (response.success && response.text != null) {
      return CloudDriveFile(
        id: response.text!,
        name: name,
        isFolder: true,
        folderId: parentId ?? '/',
      );
    }
    return null;
  }

  /// 创建分享链接（蓝奏云 API 暂不支持，返回 null 占位）。
  /// [account] 当前账号
  /// [files] 需要分享的文件列表
  /// [password] 分享密码
  /// [expireDays] 过期天数
  @override
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    LogManager().cloudDrive('蓝奏云 - 暂不支持 API 分享，返回 null');
    return null;
  }

  /// 获取直链：从文件 metadata 的 shareUrl 或入参 shareUrl 解析直链。
  /// [shareUrl] 分享链接
  /// [password] 分享密码
  @override
  Future<String?> getDirectLink({
    CloudDriveAccount? account,
    CloudDriveFile? file,
    String? shareUrl,
    String? password,
  }) async {
    final targetUrl = shareUrl ?? file?.metadata?['shareUrl']?.toString();
    if (targetUrl == null || targetUrl.isEmpty) {
      return null;
    }
    final result = await parseDirectLink(
      shareUrl: targetUrl,
      password: password,
    );
    return result.isSuccess ? result.data?.directLink : null;
  }

  /// 移动文件到指定文件夹。
  Future<LanzouOperationResponse> moveFile({
    required String fileId,
    String? targetFolderId,
  }) async {
    return _postOperationExpectSuccess(
      LanzouMoveFileRequest(
        fileId: fileId,
        targetFolderId: targetFolderId,
      ).build(),
    );
  }

  /// 删除文件
  Future<LanzouOperationResponse> deleteFile({required String fileId}) async {
    return _postOperationExpectSuccess(
      LanzouDeleteFileRequest(fileId: fileId).build(),
    );
  }

  /// 重命名文件
  Future<LanzouOperationResponse> renameFile({
    required String fileId,
    required String newName,
  }) async {
    return _postOperationExpectSuccess(
      LanzouRenameFileRequest(fileId: fileId, newName: newName).build(),
    );
  }

  /// 上传文件，返回通用 CloudDriveFile。
  /// [filePath] 本地路径
  /// [fileName] 上传后的文件名
  /// [parentId] 目标文件夹，默认 -1（根）
  @override
  Future<CloudDriveFile?> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String? parentId,
    UploadProgressCallback? onProgress,
  }) async {
    final folderId = parentId ?? '-1';
    final file = File(filePath);
    if (!await file.exists()) {
      throw LanzouApiException('文件不存在: $filePath');
    }

    final uid = LanzouUtils.extractUid(account.cookies ?? '');
    if (uid == null || uid.isEmpty) {
      throw LanzouApiException('无法从Cookie中提取UID，请重新登录');
    }

    final headers = _buildUploadHeaders(account);
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
      'upload_file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await LanzouDioFactory.createDio(account).post(
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
      final model = LanzouUploadResponse.fromMap(data);
      if (model.success) {
        final info = model.file;
        return CloudDriveFile(
          id: info?.id ?? '',
          name: info?.name ?? fileName,
          isFolder: false,
          folderId: folderId,
          size: await file.length(),
          metadata: info?.toMap(),
        );
      }
      throw LanzouApiException(model.message ?? '上传失败');
    }
    throw LanzouApiException('响应格式错误');
  }

  /// 解析蓝奏云直链，供 CLI/Façade 页面使用。
  /// [shareUrl] 分享链接
  /// [password] 分享密码（可选）
  static Future<LanzouResult<LanzouDirectLinkResult>> parseDirectLink({
    required String shareUrl,
    String? password,
  }) async {
    try {
      final request = LanzouDirectLinkRequest(
        shareUrl: shareUrl,
        password: password,
      );
      final context = await _buildShareContext(request);
      final apiResponse = await _resolveDirectLinkResponse(
        context: context,
        password: password,
      );
      final downloadUrl = await _getDownloadUrl(apiResponse);
      if (downloadUrl == null) {
        return LanzouResult.failure(const LanzouFailure(message: '获取下载链接失败'));
      }
      return LanzouResult.success(
        LanzouDirectLinkResult(
          name: context.fileInfo.name,
          size: context.fileInfo.size,
          time: context.fileInfo.time,
          directLink: downloadUrl,
          originalUrl: request.shareUrl,
        ),
      );
    } catch (e) {
      LogManager().error('解析蓝奏云直链失败', exception: e);
      if (e is LanzouApiException) {
        return LanzouResult.failure(LanzouFailure(message: e.message));
      }
      return LanzouResult.failure(LanzouFailure(message: e.toString()));
    }
  }

  static Future<LanzouDirectLinkContext> _buildShareContext(
    LanzouDirectLinkRequest request,
  ) async {
    final formattedUrl = _formatShareUrl(request.shareUrl);
    final content = await _getPageContent(formattedUrl);
    if (content == null) {
      throw const LanzouApiException('无法获取页面内容');
    }
    if (_isFileDeleted(content)) {
      throw const LanzouApiException('文件取消分享了');
    }
    final fileInfo = _extractFileInfo(content);
    if (fileInfo == null) {
      throw const LanzouApiException('文件解析失败');
    }
    return LanzouDirectLinkContext(
      originalUrl: request.shareUrl,
      formattedUrl: formattedUrl,
      rawContent: content,
      fileInfo: fileInfo,
      needsPassword: content.contains('function down_p(){'),
    );
  }

  static String _formatShareUrl(String url) {
    if (url.startsWith('http')) return url;
    return '${LanzouConfig.baseUrl}/$url';
  }

  static Future<String?> _getPageContent(String url) async {
    final response = await _directLinkDio.get(
      url,
      options: Options(
        headers: LanzouConfig.directLinkHeaders,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    if (response.statusCode == 200) {
      return response.data as String;
    }
    return null;
  }

  static bool _isFileDeleted(String content) =>
      content.contains('文件取消分享了') || content.contains('文件不存在');

  static LanzouDirectLinkFileInfo? _extractFileInfo(String content) {
    final nameMatch = RegExp(
      r'class="md"><span>(.*?)</span>',
    ).firstMatch(content);
    final sizeMatch = RegExp(
      r'class="n_filesize">(.*?)</span>',
    ).firstMatch(content);
    final timeMatch = RegExp(r'发布于 ：(.+?)</span>').firstMatch(content);
    if (nameMatch == null) return null;
    return LanzouDirectLinkFileInfo(
      name: nameMatch.group(1) ?? '未知文件',
      size: sizeMatch!.group(1) ?? '未知大小',
      time: timeMatch!.group(1) ?? '未知时间',
    );
  }

  static Future<String> _resolveDirectLinkResponse({
    required LanzouDirectLinkContext context,
    String? password,
  }) async {
    if (context.needsPassword) {
      if (password == null || password.isEmpty) {
        throw const LanzouApiException('请输入分享密码');
      }
      return await _handlePasswordProtected(
        context.rawContent,
        context.formattedUrl,
        password,
      );
    }
    return await _handlePublicFile(context.rawContent, context.formattedUrl);
  }

  static Future<String> _handlePasswordProtected(
    String content,
    String url,
    String password,
  ) async {
    final reSign = RegExp(r'data : \{(.*?)\}').firstMatch(content);
    if (reSign == null) {
      throw const LanzouApiException('解析密码接口失败');
    }
    final signInfo = reSign.group(1)?.replaceAll("'", '"');
    if (signInfo == null) {
      throw const LanzouApiException('解析密码接口失败');
    }
    final signJson = jsonDecode('{$signInfo}') as Map<String, dynamic>;
    signJson['p'] = password;

    final ajaxPath = RegExp(r"var ajaxm = '(.*?)';").firstMatch(content);
    if (ajaxPath == null) {
      throw const LanzouApiException('解析 ajaxm 失败');
    }
    final apiUrl = '${LanzouConfig.lanzouxUrl}/${ajaxPath.group(1)}';
    final response = await _directLinkDio.post(
      apiUrl,
      data: FormData.fromMap(signJson),
      options: Options(
        headers: {
          ...LanzouConfig.directLinkHeaders,
          'Referer': url,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    );
    return jsonEncode(response.data);
  }

  static Future<String> _handlePublicFile(String content, String url) async {
    final ajaxPath = RegExp(r"var ajaxm = '(.*?)';").firstMatch(content);
    if (ajaxPath == null) {
      throw const LanzouApiException('解析 ajaxm 失败');
    }
    final apiUrl = '${LanzouConfig.lanzouxUrl}/${ajaxPath.group(1)}';
    final sign = RegExp(r"data : \{(.*?)\}").firstMatch(content);
    if (sign == null) {
      throw const LanzouApiException('解析 data 失败');
    }
    final postData = jsonDecode('{${sign.group(1)!.replaceAll("'", '"')}}');
    final response = await _directLinkDio.post(
      apiUrl,
      data: FormData.fromMap(postData as Map<String, dynamic>),
      options: Options(
        headers: {
          ...LanzouConfig.directLinkHeaders,
          'Referer': url,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    );
    return jsonEncode(response.data);
  }

  static Future<String?> _getDownloadUrl(String apiResponse) async {
    final response = jsonDecode(apiResponse);
    if (response['url'] == '0') {
      throw LanzouApiException(response['inf']?.toString() ?? '未知错误');
    }
    if ((response['zt'] ?? 0) != 1) {
      return null;
    }
    final downloadLink = '${response['dom']}/file/${response['url']}';
    final finalLink = await _getRedirectUrl(downloadLink);
    if (finalLink.isEmpty || !finalLink.startsWith('http')) {
      return downloadLink;
    }
    return finalLink.replaceAll(RegExp(r'pid=.*?&'), '');
  }

  static Future<String> _getRedirectUrl(String url) async {
    final response = await _directLinkDio.head(
      url,
      options: Options(
        headers: LanzouConfig.directLinkHeaders,
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return response.headers.value('location') ?? '';
  }

  /// 构造包含 VEI 的请求体并发送。
  Future<LanzouOperationResponse> _postWithVei(
    LanzouFolderRequest request, {
    bool allowFolderMeta = false,
  }) async {
    final vei = await _getVei();
    final data = request.build(vei);
    return _postExpectSuccess(data);
  }

  Future<LanzouOperationResponse> _postOperationExpectSuccess(
    Map<String, dynamic> data,
  ) async =>
      _postExpectSuccess(data);

  Future<LanzouOperationResponse> _postExpectSuccess(
    Map<String, dynamic> data,
  ) async {
    final response = await _client.post(data);
    final parsed = LanzouOperationResponse.fromMap(response);
    if (parsed.success) {
      return parsed;
    }
    throw LanzouApiException(parsed.message ?? '蓝奏云请求失败');
  }

  /// 获取或返回缓存的 VEI 参数。
  Future<String> _getVei() async {
    if (_cachedVei != null && _cachedVei!.isNotEmpty) {
      return _cachedVei!;
    }

    final vei = await LanzouVeiProvider.initializeVeiParameter(
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

  Map<String, String> _buildUploadHeaders(CloudDriveAccount account) =>
      LanzouConfig.buildUploadHeaders(account);

  Future<LanzouOperationResponse> createFolderRaw({
    required String folderName,
    required String parentFolderId,
    String? description,
  }) async {
    return _postOperationExpectSuccess(
      LanzouCreateFolderRequest(
        parentFolderId: parentFolderId,
        folderName: folderName,
        description: description,
      ).build(),
    );
  }

  static DateTime? _tryParseTime(dynamic time) {
    if (time == null) return null;
    return DateTime.tryParse(time.toString());
  }

  CloudDriveFile _mapFile(LanzouRawFile raw) => CloudDriveFile(
    id: raw.id,
    name: raw.name,
    size: LanzouUtils.parseFileSize(raw.size),
    updatedAt: _tryParseTime(raw.time),
    isFolder: false,
    metadata: _buildFileMetadata(raw),
    downloadCount: raw.downloads ?? -1,
  );

  CloudDriveFile _mapFolder(LanzouRawFolder raw) => CloudDriveFile(
    id: raw.id,
    name: raw.name,
    updatedAt: _tryParseTime(raw.time),
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
