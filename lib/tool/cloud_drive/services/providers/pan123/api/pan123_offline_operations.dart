import '../../../../../../core/logging/log_manager.dart';
import '../../../../core/result.dart';
import '../../../../data/models/cloud_drive_entities.dart';
import '../models/requests/pan123_offline_requests.dart';
import '../models/responses/pan123_offline_responses.dart';
import 'pan123_base_service.dart';
import 'pan123_config.dart';

/// 123云盘 离线下载相关操作
class Pan123OfflineOperations {
  static bool get _verbose => Pan123Config.enableDetailedLog;
  static void _log(String msg) => LogManager().cloudDrive(msg);

  /// 解析离线资源
  static Future<Pan123OfflineResolveResponse> resolve({
    required CloudDriveAccount account,
    required Pan123OfflineResolveRequest request,
  }) async {
    return _execute<Pan123OfflineResolveResponse>(
      account: account,
      operation: '123云盘-离线解析',
      action: () async {
        final base = Uri.parse(
          Pan123Config.getApiUrl(Pan123Config.endpoints['offlineResolve']!),
        );
        final query = Pan123BaseService.buildNoiseQueryParams();
        final url = base.replace(queryParameters: query);
        final dio = Pan123BaseService.createDio(account);

        if (_verbose) _log('离线解析请求体: ${request.toJson()}');
        final response = await dio.post(url.toString(), data: request.toJson());
        final processed = Pan123BaseService.handleApiResponse(
          response.data as Map<String, dynamic>,
          operation: '离线解析',
        );
        if (_verbose) _log('离线解析响应: ${response.data}');
        return Pan123OfflineResolveResponse.fromJson(processed);
      },
    );
  }

  /// 提交离线任务
  static Future<Pan123OfflineSubmitResponse> submit({
    required CloudDriveAccount account,
    required Pan123OfflineSubmitRequest request,
  }) async {
    return _execute<Pan123OfflineSubmitResponse>(
      account: account,
      operation: '123云盘-离线提交',
      action: () async {
        final base = Uri.parse(
          Pan123Config.getApiUrl(Pan123Config.endpoints['offlineSubmit']!),
        );
        final query = Pan123BaseService.buildNoiseQueryParams();
        final url = base.replace(queryParameters: query);
        final dio = Pan123BaseService.createDio(account);

        if (_verbose) _log('离线提交请求体: ${request.toJson()}');
        final response = await dio.post(url.toString(), data: request.toJson());
        final processed = Pan123BaseService.handleApiResponse(
          response.data as Map<String, dynamic>,
          operation: '离线提交',
        );
        if (_verbose) _log('离线提交响应: ${response.data}');
        return Pan123OfflineSubmitResponse.fromJson(processed);
      },
    );
  }

  /// 查询离线任务列表
  static Future<Pan123OfflineTaskListResponse> listTasks({
    required CloudDriveAccount account,
    required Pan123OfflineListRequest request,
  }) async {
    return _execute<Pan123OfflineTaskListResponse>(
      account: account,
      operation: '123云盘-离线任务列表',
      action: () async {
        final base = Uri.parse(
          Pan123Config.getApiUrl(Pan123Config.endpoints['offlineList']!),
        );
        final query = Pan123BaseService.buildNoiseQueryParams();
        final url = base.replace(queryParameters: query);
        final dio = Pan123BaseService.createDio(account);

        if (_verbose) _log('离线列表请求体: ${request.toJson()}');
        final response = await dio.post(url.toString(), data: request.toJson());
        final processed = Pan123BaseService.handleApiResponse(
          response.data as Map<String, dynamic>,
          operation: '离线任务列表',
        );
        if (_verbose) _log('离线列表响应: ${response.data}');
        return Pan123OfflineTaskListResponse.fromJson(processed);
      },
    );
  }

  static Future<T> _execute<T>({
    required CloudDriveAccount account,
    required String operation,
    required Future<T> Function() action,
  }) async {
    try {
      return await action();
    } on CloudDriveException {
      rethrow;
    } catch (e, stack) {
      throw CloudDriveException(
        e.toString(),
        CloudDriveErrorType.unknown,
        operation: operation,
        context: {'stackTrace': stack.toString()},
      );
    }
  }
}
