import '../../../data/models/cloud_drive_entities.dart';
import '../ali_base_service.dart';
import '../ali_cloud_drive_service.dart';
import '../models/requests/ali_list_request.dart';
import '../models/requests/ali_operation_requests.dart';
import '../models/responses/ali_file_list_response.dart';
import '../models/responses/ali_operation_response.dart';
import '../models/responses/ali_api_result.dart';
import '../ali_config.dart';

/// 阿里云盘 API 客户端（当前封装现有 Service，后续可逐步替换为显式请求/响应模型）。
class AliApiClient {
  Future<String?> getDriveId(CloudDriveAccount account) =>
      AliCloudDriveService.getDriveId(account: account);

  Future<AliFileListResponse> listFiles({
    required CloudDriveAccount account,
    required String driveId,
    required AliListRequest request,
  }) async {
    final result = await _post<Map<String, dynamic>>(
      account: account,
      path: AliConfig.getApiEndpoint('getFileList'),
      query: AliConfig.buildFileListQueryParams(),
      data: AliConfig.buildFileListParams(
        driveId: driveId,
        parentFileId: request.parentFileId,
        limit: request.pageSize,
        marker: null,
      ),
    );
    if (!result.success || result.data == null) {
      return const AliFileListResponse(files: []);
    }
    final items = result.data!['items'] as List<dynamic>? ?? [];
    final files = items
        .map((e) => e is Map<String, dynamic>
            ? AliBaseService.parseFileItem(e)
            : null)
        .whereType<CloudDriveFile>()
        .toList();
    return AliFileListResponse(files: files);
  }

  Future<AliOperationResponse> deleteFile({
    required CloudDriveAccount account,
    required AliDeleteRequest request,
  }) async {
    final driveId = await AliCloudDriveService.getDriveId(account: account);
    if (driveId == null) {
      return const AliOperationResponse(success: false, message: 'missing driveId');
    }
    final result = await _post(
      account: account,
      path: AliConfig.getApiEndpoint('deleteFile'),
      data: AliConfig.buildDeleteFileParams(
        driveId: driveId,
        fileId: request.file.id,
      ),
    );
    return AliOperationResponse(
      success: result.success,
      message: result.message,
    );
  }

  Future<AliOperationResponse> renameFile({
    required CloudDriveAccount account,
    required AliRenameRequest request,
  }) async {
    final driveId = await AliCloudDriveService.getDriveId(account: account);
    if (driveId == null) {
      return const AliOperationResponse(success: false, message: 'missing driveId');
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
    final driveId = await AliCloudDriveService.getDriveId(account: account);
    if (driveId == null) {
      return const AliOperationResponse(success: false, message: 'missing driveId');
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
    return const AliOperationResponse(success: false, message: 'copy not supported');
  }

  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required AliDownloadRequest request,
  }) {
    return _getDownloadUrlInternal(account, request);
  }

  Future<CloudDriveFile?> _createFolderInternal(
    CloudDriveAccount account,
    AliCreateFolderRequest request,
  ) async {
    final driveId = await AliCloudDriveService.getDriveId(account: account);
    if (driveId == null) return null;
    final dio = AliBaseService.createApiDio(account);
    final body = AliConfig.buildCreateFolderParams(
      name: request.name,
      parentFileId: request.parentId,
      driveId: driveId,
    );
    final response = await dio.post(
      AliConfig.getApiEndpoint('createFolder'),
      data: body,
    );
    if (!AliBaseService.isHttpSuccess(response.statusCode)) {
      return null;
    }
    final data = response.data as Map<String, dynamic>? ?? {};
    final fileId = data['file_id']?.toString();
    final fileName = data['file_name']?.toString() ?? request.name;
    final parentId = data['parent_file_id']?.toString() ?? request.parentId;
    if (fileId == null) return null;
    return CloudDriveFile(
      id: fileId,
      name: fileName,
      isFolder: true,
      folderId: parentId,
    );
  }

  Future<String?> _getDownloadUrlInternal(
    CloudDriveAccount account,
    AliDownloadRequest request,
  ) async {
    // 优先使用请求中提供的 driveId，如果缺失则补取一次，避免未定义报错。
    var driveId = request.driveId;
    if (driveId.isEmpty) {
      driveId = await AliCloudDriveService.getDriveId(account: account) ?? '';
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

  Future<AliApiResult<Map<String, dynamic>>> _post<T>({
    required CloudDriveAccount account,
    required String path,
    Map<String, String>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      final dio = AliBaseService.createApiDio(account);
      final uri = query == null
          ? Uri.parse('${dio.options.baseUrl}$path')
          : Uri.parse('${dio.options.baseUrl}$path')
              .replace(queryParameters: query);
      final response = await dio.postUri(uri, data: data);
      final status = response.statusCode;
      final respData = response.data as Map<String, dynamic>? ?? {};
      final success = AliBaseService.isHttpSuccess(status);
      return AliApiResult<Map<String, dynamic>>(
        success: success,
        data: respData,
        statusCode: status,
        message: success ? null : 'http $status',
      );
    } catch (e) {
      return AliApiResult<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
