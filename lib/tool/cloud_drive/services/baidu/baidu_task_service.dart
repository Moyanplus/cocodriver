import '../../../core/services/base/debug_service.dart';
import '../../models/cloud_drive_models.dart';
import 'baidu_base_service.dart';
import 'baidu_config.dart';

/// 百度网盘任务管理服务
/// 专门负责异步任务的轮询和状态查询
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
    DebugService.log(
      '🔄 百度网盘 - 开始轮询$taskType任务状态: $taskId',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    for (int i = 0; i < _maxRetries; i++) {
      try {
        final status = await _queryTaskStatus(account, taskId);
        DebugService.log(
          '📊 百度网盘 - 第${i + 1}次查询结果: $status',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );

        if (status == 'success') {
          DebugService.log(
            '✅ 百度网盘 - $taskType任务完成',
            category: DebugCategory.tools,
            subCategory: BaiduConfig.logSubCategory,
          );
          return true;
        } else if (status == 'failed') {
          DebugService.log(
            '❌ 百度网盘 - $taskType任务失败',
            category: DebugCategory.tools,
            subCategory: BaiduConfig.logSubCategory,
          );
          return false;
        } else if (status == 'running') {
          DebugService.log(
            '⏳ 百度网盘 - $taskType任务进行中，等待${_retryInterval.inMilliseconds}毫秒后重试...',
            category: DebugCategory.tools,
            subCategory: BaiduConfig.logSubCategory,
          );
          await Future.delayed(_retryInterval);
        } else {
          DebugService.log(
            '❓ 百度网盘 - 未知任务状态: $status',
            category: DebugCategory.tools,
            subCategory: BaiduConfig.logSubCategory,
          );
          return false;
        }
      } catch (e) {
        DebugService.log(
          '❌ 百度网盘 - 查询$taskType任务状态异常: $e',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return false;
      }
    }

    DebugService.log(
      '⏰ 百度网盘 - $taskType任务超时，超过${_maxRetries * _retryInterval.inMilliseconds / 1000}秒',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
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

    DebugService.log(
      '🔍 百度网盘 - 查询任务状态: $url',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📋 百度网盘 - 查询参数: $queryParams',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      final dio = BaiduBaseService.createDio(account);
      final response = await dio.get(url, queryParameters: queryParams);

      DebugService.log(
        '📡 百度网盘 - 任务状态查询响应: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (response.statusCode != 200) {
        throw Exception('任务状态查询失败: ${response.statusCode}');
      }

      final data = response.data;
      DebugService.log(
        '📄 百度网盘 - 任务状态响应数据: $data',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (data['errno'] != 0) {
        final errorMsg = BaiduConfig.getErrorMessage(data['errno']);
        throw Exception('任务状态查询失败: $errorMsg');
      }

      final result = data['result'] as Map<String, dynamic>?;
      if (result == null) {
        throw Exception('任务状态响应格式错误');
      }

      final status = result['status']?.toString() ?? '';
      DebugService.log(
        '📊 百度网盘 - 任务状态: $status',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      return status;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 百度网盘 - 查询任务状态失败: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📄 百度网盘 - 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      rethrow;
    }
  }

  /// 批量轮询任务状态
  static Future<Map<String, bool>> pollMultipleTaskStatus({
    required CloudDriveAccount account,
    required List<String> taskIds,
    required String taskType,
  }) async {
    DebugService.log(
      '🔄 百度网盘 - 开始批量轮询$taskType任务状态: $taskIds',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    final results = <String, bool>{};

    for (final taskId in taskIds) {
      final success = await pollTaskStatus(
        account: account,
        taskId: taskId,
        taskType: taskType,
      );
      results[taskId] = success;
    }

    DebugService.log(
      '📊 百度网盘 - 批量任务轮询结果: $results',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    return results;
  }

  /// 取消任务
  static Future<bool> cancelTask({
    required CloudDriveAccount account,
    required String taskId,
  }) async {
    DebugService.log(
      '❌ 百度网盘 - 取消任务: $taskId',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

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

      DebugService.log(
        '📡 百度网盘 - 取消任务响应: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (response.statusCode != 200) {
        throw Exception('取消任务失败: ${response.statusCode}');
      }

      final data = response.data;
      DebugService.log(
        '📄 百度网盘 - 取消任务响应数据: $data',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (data['errno'] != 0) {
        final errorMsg = BaiduConfig.getErrorMessage(data['errno']);
        throw Exception('取消任务失败: $errorMsg');
      }

      DebugService.log(
        '✅ 百度网盘 - 任务取消成功: $taskId',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      return true;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 百度网盘 - 取消任务失败: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📄 百度网盘 - 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return false;
    }
  }
}
