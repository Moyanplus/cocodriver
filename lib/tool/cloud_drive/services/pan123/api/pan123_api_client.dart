import '../../../data/models/cloud_drive_entities.dart';
import '../models/requests/pan123_list_request.dart';
import '../models/requests/pan123_operation_requests.dart';
import '../models/responses/pan123_file_list_response.dart';
import '../models/responses/pan123_operation_response.dart';
import '../models/responses/pan123_api_result.dart';
import '../pan123_config.dart';
import '../pan123_base_service.dart';
import '../pan123_file_operation_service.dart';
import '../pan123_download_service.dart';

/// 123 云盘 API 客户端（当前复用现有 Service，统一出入参）。
class Pan123ApiClient {
  Future<Pan123FileListResponse> listFiles({
    required CloudDriveAccount account,
    required Pan123ListRequest request,
  }) async {
    final dio = Pan123BaseService.createDio(account);
    final url = Uri.parse(
      Pan123Config.getApiUrl(Pan123Config.endpoints['fileList']!),
    );
    final params = Pan123BaseService.buildRequestParams(
      parentId: request.parentId,
      page: request.page,
      limit: request.pageSize,
      searchValue: request.searchValue,
    );
    final uri = url.replace(
      queryParameters: params.map((k, v) => MapEntry(k, v.toString())),
    );
    final result = await _safeCall(() async {
      final response = await dio.get(uri.toString());
      final data = response.data as Map<String, dynamic>? ?? {};
      final files = _parseFileList(data);
      return files;
    });
    return Pan123FileListResponse(files: result.data ?? const []);
  }

  Future<Pan123OperationResponse> deleteFile({
    required CloudDriveAccount account,
    required Pan123DeleteRequest request,
  }) async {
    final result = await _safeCall<bool>(
      () => Pan123FileOperationService.deleteFile(
        account: account,
        fileId: request.file.id,
        fileName: request.file.name,
        type: request.file.isFolder ? 1 : 0,
        size: request.file.size,
        parentFileId: request.file.folderId,
      ),
    );
    return Pan123OperationResponse(
      success: result.data ?? false,
      message: result.message,
    );
  }

  Future<Pan123OperationResponse> renameFile({
    required CloudDriveAccount account,
    required Pan123RenameRequest request,
  }) async {
    final result = await _safeCall<bool>(
      () => Pan123FileOperationService.renameFile(
        account: account,
        fileId: request.file.id,
        newFileName: request.newName,
      ),
    );
    return Pan123OperationResponse(
      success: result.data ?? false,
      message: result.message,
    );
  }

  Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required Pan123CreateFolderRequest request,
  }) async {
    final result = await _safeCall<CloudDriveFile?>(
      () => Pan123FileOperationService.createFolder(
        account: account,
        folderName: request.name,
        parentFileId: request.parentId ?? '0',
      ),
    );
    return result.data;
  }

  Future<Pan123OperationResponse> moveFile({
    required CloudDriveAccount account,
    required Pan123MoveRequest request,
  }) async {
    final result = await _safeCall<bool>(
      () => Pan123FileOperationService.moveFile(
        account: account,
        fileId: request.file.id,
        targetParentFileId: request.targetParentId,
      ),
    );
    return Pan123OperationResponse(
      success: result.data ?? false,
      message: result.message,
    );
  }

  Future<Pan123OperationResponse> copyFile({
    required CloudDriveAccount account,
    required Pan123CopyRequest request,
  }) async {
    final result = await _safeCall<bool>(
      () => Pan123FileOperationService.copyFile(
        account: account,
        fileId: request.file.id,
        targetFileId: request.targetParentId,
        fileName: request.file.name,
        size: request.file.size,
        parentFileId: request.file.folderId,
      ),
    );
    return Pan123OperationResponse(
      success: result.data ?? false,
      message: result.message,
    );
  }

  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required Pan123DownloadRequest request,
  }) async {
    final result = await _safeCall<String?>(
      () => Pan123DownloadService.getDownloadUrl(
        account: account,
        fileId: request.file.id,
        fileName: request.file.name,
        size: request.file.size,
      ),
    );
    return result.data;
  }

  Future<Pan123ApiResult<T>> _safeCall<T>(Future<T> Function() fn) async {
    try {
      final data = await fn();
      return Pan123ApiResult<T>(success: true, data: data);
    } catch (e) {
      return Pan123ApiResult<T>(success: false, message: e.toString());
    }
  }

  List<CloudDriveFile> _parseFileList(Map<String, dynamic> responseData) {
    // API code check
    final code = responseData['code'] as int?;
    if (code != 200) {
      return const [];
    }
    final dynamic processed = Pan123BaseService.getResponseData(responseData) ??
        responseData['data'] as Map<String, dynamic>?;
    final candidates = <dynamic>[];
    if (processed is List) {
      candidates.addAll(processed);
    } else if (processed is Map<String, dynamic>) {
      final lists = [
        processed['InfoList'],
        processed['file_info_bean_list'],
        processed['list'],
        processed['files'],
      ];
      for (final l in lists) {
        if (l is List) candidates.addAll(l);
      }
    }
    final list = candidates.whereType<Map<String, dynamic>>().toList();

    final files = <CloudDriveFile>[];
    for (final item in list) {
      final file = _parseFileItem(item);
      if (file != null) files.add(file);
    }
    return files;
  }

  CloudDriveFile? _parseFileItem(Map<String, dynamic> fileData) {
    final id = fileData['FileId']?.toString();
    final name = fileData['FileName']?.toString();
    if (id == null || name == null) return null;
    final type = fileData['Type'] as int? ?? 0;
    final isFolder = type == 1;
    final size = int.tryParse(fileData['Size']?.toString() ?? '');
    DateTime? modified;
    final updateAt = fileData['UpdateAt']?.toString();
    if (updateAt != null && updateAt.isNotEmpty) {
      modified = DateTime.tryParse(updateAt);
    }
    final parentId = fileData['ParentFileId']?.toString() ?? '0';
    return CloudDriveFile(
      id: id,
      name: name,
      size: size,
      modifiedTime: modified,
      isFolder: isFolder,
      folderId: parentId,
    );
  }
}
