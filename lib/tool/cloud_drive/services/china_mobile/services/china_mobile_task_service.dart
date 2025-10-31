import '../../../data/models/cloud_drive_entities.dart';
import '../core/china_mobile_base_service.dart';
import '../core/china_mobile_config.dart';
import '../models/china_mobile_models.dart';
import '../utils/china_mobile_logger.dart';

/// 中国移动云盘任务服务
///
/// 提供查询任务状态等功能。
class ChinaMobileTaskService {
  /// 查询任务状态（使用 DTO）
  ///
  /// [account] 中国移动云盘账号信息
  /// [request] 任务查询请求对象
  static Future<ChinaMobileApiResult<Map<String, dynamic>>> getTaskStatus({
    required CloudDriveAccount account,
    required ChinaMobileTaskRequest request,
  }) async {
    try {
      final dio = ChinaMobileBaseService.createDio(account);
      final uri = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('getTask')}',
      );

      ChinaMobileLogger.task('查询任务状态', taskId: request.taskId);
      ChinaMobileLogger.network('POST', url: uri.toString());
      ChinaMobileLogger.debug('请求体', data: request.toRequestBody());

      final response = await dio.postUri(uri, data: request.toRequestBody());

      if (ChinaMobileBaseService.isHttpSuccess(response.statusCode) &&
          ChinaMobileBaseService.isApiSuccess(response.data)) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        ChinaMobileLogger.success('查询任务状态完成', data: data);
        return ChinaMobileApiResult.success(data);
      } else {
        final errorMsg = ChinaMobileBaseService.getErrorMessage(
          response.data ?? {},
        );
        return ChinaMobileApiResult.failure(errorMsg);
      }
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('查询任务状态失败', error: e, stackTrace: stackTrace);
      return ChinaMobileApiResult.fromException(e as Exception);
    }
  }

  /// 查询任务状态（兼容旧接口）
  ///
  /// [account] 中国移动云盘账号信息
  /// [taskId] 任务ID
  /// @deprecated 建议使用 [getTaskStatus] with DTO
  static Future<Map<String, dynamic>?> getTask({
    required CloudDriveAccount account,
    required String taskId,
  }) async {
    final request = ChinaMobileTaskRequest(taskId: taskId);

    final result = await getTaskStatus(account: account, request: request);

    if (result.isSuccess && result.data != null) {
      return result.data;
    } else {
      ChinaMobileLogger.error('查询任务失败: ${result.errorMessage}');
      return null;
    }
  }
}
