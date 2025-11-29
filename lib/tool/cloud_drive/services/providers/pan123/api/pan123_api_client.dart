import '../../../../data/models/cloud_drive_entities.dart';
import '../models/requests/pan123_list_request.dart';
import '../models/requests/pan123_operation_requests.dart';
import '../models/responses/pan123_file_list_response.dart';
import '../models/responses/pan123_operation_response.dart';
import '../models/responses/pan123_api_result.dart';
import 'pan123_config.dart';
import 'pan123_base_service.dart';
import 'pan123_operations.dart';

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
      return Pan123FileListResponse.fromMap(data);
    });
    return result.data ??
        const Pan123FileListResponse(code: -1, message: 'empty', data: null);
  }

  Future<Pan123OperationResponse> deleteFile({
    required CloudDriveAccount account,
    required Pan123DeleteRequest request,
  }) async {
    final result = await _safeCall<bool>(
      () => Pan123Operations.delete(account: account, request: request),
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
      () => Pan123Operations.rename(account: account, request: request),
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
      () => Pan123Operations.createFolder(account: account, request: request),
    );
    return result.data;
  }

  Future<Pan123OperationResponse> moveFile({
    required CloudDriveAccount account,
    required Pan123MoveRequest request,
  }) async {
    final result = await _safeCall<bool>(
      () => Pan123Operations.move(account: account, request: request),
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
      () => Pan123Operations.copy(account: account, request: request),
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
      () => Pan123Operations.getDownloadUrl(account: account, request: request),
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
}
