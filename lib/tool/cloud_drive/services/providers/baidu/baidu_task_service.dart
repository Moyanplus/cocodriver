import '../../../../../../core/logging/log_manager.dart';
import '../../../data/models/cloud_drive_entities.dart';
import 'baidu_base_service.dart';
import 'baidu_config.dart';

/// 百度网盘任务管理服务
///
/// 负责异步任务的轮询和状态查询。
class BaiduTaskService {
  static const int _maxRetries = 20; // 最多轮询20次（10秒）
  static const Duration _retryInterval = Duration(
    milliseconds: 500,
  ); // 每0.5秒查询一次

  /// 轮询任务状态
  static Future<bool> pollTaskStatus({
    required CloudDriveAccount account,
    required String taskId,
    required String taskType, // 'delete', 'move', 'copy', 'rename'
  }) async {
    LogManager().cloudDrive('百度网盘 - 开始轮询$taskType任务状态: $taskId');

    for (int i = 0; i < _maxRetries; i++) {
      try {
        final status = await _queryTaskStatus(account, taskId);
        LogManager().cloudDrive('百度网盘 - 第${i + 1}次查询结果: $status');

        if (status == 'success') {
          LogManager().cloudDrive('百度网盘 - $taskType任务完成');
          return true;
        } else if (status == 'failed') {
          LogManager().cloudDrive('百度网盘 - $taskType任务失败');
          return false;
        } else if (status == 'running') {
          LogManager().cloudDrive(
            '⏳ 百度网盘 - $taskType任务进行中，等待${_retryInterval.inMilliseconds}毫秒后重试...',
          );
          await Future.delayed(_retryInterval);
        } else {
          LogManager().cloudDrive('❓ 百度网盘 - 未知任务状态: $status');
          return false;
        }
      } catch (e) {
        LogManager().cloudDrive('百度网盘 - 查询$taskType任务状态异常: $e');
        return false;
      }
    }

    LogManager().cloudDrive(
      '百度网盘 - $taskType任务超时，超过${_maxRetries * _retryInterval.inMilliseconds / 1000}秒',
    );
    return false;
  }

  /// 查询任务状态
  static Future<String> _queryTaskStatus(
    CloudDriveAccount account,
    String taskId,
  ) async {
    // 使用配置中的API端点
    final url = BaiduConfig.getApiUrl(BaiduConfig.endpoints['taskQuery']!);
    final queryParams = {
      'taskid': taskId,
      'clienttype': '0',
      'app_id': '250528',
      'web': '1',
      'dp-logid': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    LogManager().cloudDrive('百度网盘 - 查询任务状态: $url');
    LogManager().cloudDrive('百度网盘 - 查询参数: $queryParams');

    try {
      final dio = BaiduBaseService.createDio(account);
      final response = await dio.get(url, queryParameters: queryParams);

      LogManager().cloudDrive('百度网盘 - 任务状态查询响应: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('任务状态查询失败: ${response.statusCode}');
      }

      final data = response.data;
      LogManager().cloudDrive('百度网盘 - 任务状态响应数据: $data');

      if (data['errno'] != 0) {
        final errorMsg = BaiduConfig.getErrorMessage(data['errno']);
        throw Exception('任务状态查询失败: $errorMsg');
      }

      final result = data['result'] as Map<String, dynamic>?;
      if (result == null) {
        throw Exception('任务状态响应格式错误');
      }

      final status = result['status']?.toString() ?? '';
      LogManager().cloudDrive('百度网盘 - 任务状态: $status');

      return status;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('百度网盘 - 查询任务状态失败: $e');
      LogManager().cloudDrive('百度网盘 - 错误堆栈: $stackTrace');
      rethrow;
    }
  }

  /// 批量轮询任务状态
  static Future<Map<String, bool>> pollMultipleTaskStatus({
    required CloudDriveAccount account,
    required List<String> taskIds,
    required String taskType,
  }) async {
    LogManager().cloudDrive('百度网盘 - 开始批量轮询$taskType任务状态: $taskIds');

    final results = <String, bool>{};

    for (final taskId in taskIds) {
      final success = await pollTaskStatus(
        account: account,
        taskId: taskId,
        taskType: taskType,
      );
      results[taskId] = success;
    }

    LogManager().cloudDrive('百度网盘 - 批量任务轮询结果: $results');

    return results;
  }

  /// 取消任务
  static Future<bool> cancelTask({
    required CloudDriveAccount account,
    required String taskId,
  }) async {
    LogManager().cloudDrive('百度网盘 - 取消任务: $taskId');

    try {
      // 使用配置中的API端点
      final url = BaiduConfig.getApiUrl(BaiduConfig.endpoints['taskCancel']!);
      final queryParams = {
        'taskid': taskId,
        'clienttype': '0',
        'app_id': '250528',
        'web': '1',
      };

      final dio = BaiduBaseService.createDio(account);
      final response = await dio.get(url, queryParameters: queryParams);

      LogManager().cloudDrive('百度网盘 - 取消任务响应: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('取消任务失败: ${response.statusCode}');
      }

      final data = response.data;
      LogManager().cloudDrive('百度网盘 - 取消任务响应数据: $data');

      if (data['errno'] != 0) {
        final errorMsg = BaiduConfig.getErrorMessage(data['errno']);
        throw Exception('取消任务失败: $errorMsg');
      }

      LogManager().cloudDrive('百度网盘 - 任务取消成功: $taskId');

      return true;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('百度网盘 - 取消任务失败: $e');
      LogManager().cloudDrive('百度网盘 - 错误堆栈: $stackTrace');
      return false;
    }
  }
}
