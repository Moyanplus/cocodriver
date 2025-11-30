import '../../../../core/result.dart';
import '../../../../data/models/cloud_drive_entities.dart';
import '../models/requests/pan123_list_request.dart';
import '../models/requests/pan123_offline_requests.dart';
import '../models/requests/pan123_operation_requests.dart';
import '../models/responses/pan123_file_list_response.dart';
import '../models/responses/pan123_offline_responses.dart';
import '../models/responses/pan123_user_info_response.dart';
import 'pan123_base_service.dart';
import 'pan123_operations.dart';
import 'pan123_config.dart';

/// 123 云盘 API 客户端（当前复用现有 Service，统一出入参）。
class Pan123ApiClient {
  /// 获取文件列表
  ///
  /// [account] 当前账号
  /// [request] 列表请求参数
  Future<Pan123FileListResponse> listFiles({
    required CloudDriveAccount account,
    required Pan123ListRequest request,
  }) async {
    return _safeCall(() async {
      final dio = Pan123BaseService.createDio(account);
      final url = Uri.parse(
        Pan123Config.getApiUrl(Pan123Config.endpoints['fileList']!),
      );
      final params = Pan123BaseService.buildRequestParams(
        parentId: request.parentId,
        page: request.page,
        limit: request.pageSize,
        searchValue: request.searchValue,
        trashed: request.trashed,
        orderBy: request.orderBy,
        orderDirection: request.orderDirection,
        event: request.event,
        next: request.next,
      );
      final uri = url.replace(
        queryParameters: params.map((k, v) => MapEntry(k, v.toString())),
      );
      final response = await dio.get(uri.toString());
      final data = response.data as Map<String, dynamic>? ?? {};
      return Pan123FileListResponse.fromMap(data);
    }, operation: '123云盘-获取文件列表');
  }

  /// 离线解析
  Future<Pan123OfflineResolveResponse> resolveOffline({
    required CloudDriveAccount account,
    required Pan123OfflineResolveRequest request,
  }) {
    return _safeCall(
      () => Pan123Operations.resolveOffline(account: account, request: request),
      operation: '123云盘-离线解析',
    );
  }

  /// 提交离线任务
  Future<Pan123OfflineSubmitResponse> submitOffline({
    required CloudDriveAccount account,
    required Pan123OfflineSubmitRequest request,
  }) {
    return _safeCall(
      () => Pan123Operations.submitOffline(account: account, request: request),
      operation: '123云盘-离线提交',
    );
  }

  /// 查询离线任务列表
  Future<Pan123OfflineTaskListResponse> listOfflineTasks({
    required CloudDriveAccount account,
    required Pan123OfflineListRequest request,
  }) {
    return _safeCall(
      () => Pan123Operations.listOfflineTasks(
        account: account,
        request: request,
      ),
      operation: '123云盘-离线任务列表',
    );
  }

  /// 获取用户信息
  Future<Pan123UserInfoResponse> getUserInfo({
    required CloudDriveAccount account,
  }) {
    return _safeCall(
      () => Pan123Operations.getUserInfo(
        account: account,
        dio: Pan123BaseService.createDio(account),
      ),
      operation: '123云盘-获取用户信息',
    );
  }

  /// 删除单个文件或文件夹
  ///
  /// [account] 当前账号
  /// [request] 删除请求
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required Pan123DeleteRequest request,
  }) async {
    return _safeCall(
      () => Pan123Operations.delete(account: account, request: request),
      operation: '123云盘-删除文件',
    );
  }

  /// 重命名文件
  ///
  /// [account] 当前账号
  /// [request] 重命名请求
  Future<bool> renameFile({
    required CloudDriveAccount account,
    required Pan123RenameRequest request,
  }) async {
    return _safeCall(
      () => Pan123Operations.rename(account: account, request: request),
      operation: '123云盘-重命名文件',
    );
  }

  /// 创建文件夹
  ///
  /// [account] 当前账号
  /// [request] 创建文件夹请求
  Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required Pan123CreateFolderRequest request,
  }) async {
    return _safeCall(
      () => Pan123Operations.createFolder(account: account, request: request),
      operation: '123云盘-创建文件夹',
    );
  }

  /// 移动文件
  ///
  /// [account] 当前账号
  /// [request] 移动请求
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required Pan123MoveRequest request,
  }) async {
    return _safeCall(
      () => Pan123Operations.move(account: account, request: request),
      operation: '123云盘-移动文件',
    );
  }

  /// 复制文件
  ///
  /// [account] 当前账号
  /// [request] 复制请求
  Future<bool> copyFile({
    required CloudDriveAccount account,
    required Pan123CopyRequest request,
  }) async {
    return _safeCall(
      () => Pan123Operations.copy(account: account, request: request),
      operation: '123云盘-复制文件',
    );
  }

  /// 获取下载链接
  ///
  /// [account] 当前账号
  /// [request] 下载信息请求
  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required Pan123DownloadRequest request,
  }) async {
    return _safeCall(
      () => Pan123Operations.getDownloadUrl(account: account, request: request),
      operation: '123云盘-获取下载链接',
    );
  }

  /// 包装执行函数，统一捕获异常
  Future<T> _safeCall<T>(Future<T> Function() fn, {String? operation}) async {
    try {
      return await fn();
    } on CloudDriveException {
      rethrow;
    } catch (e, stackTrace) {
      throw CloudDriveException(
        e.toString(),
        CloudDriveErrorType.unknown,
        operation: operation,
        context: {'stackTrace': stackTrace.toString()},
      );
    }
  }
}
