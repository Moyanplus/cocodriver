import '../../../../core/logging/log_manager.dart';
import '../../models/cloud_drive_models.dart';
import 'quark_base_service.dart';
import 'quark_config.dart';

/// 夸克云盘文件操作服务
/// 专门负责文件的移动、删除、复制、重命名等操作
class QuarkFileOperationService {
  /// 移动文件
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) async {
    LogManager().cloudDrive(
      '🔄 夸克云盘 - 移动文件开始: ${file.name}',
      
    );

    try {
      final dio = await QuarkBaseService.createDioWithAuth(account);
      final queryParams = QuarkConfig.buildFileOperationParams();
      final requestBody = QuarkConfig.buildMoveFileBody(
        targetFolderId: targetFolderId,
        fileIds: [file.id],
      );

      final uri = _buildOperationUri('moveFile', queryParams);
      LogManager().cloudDrive(
        '🔗 请求URL: $uri',
        
      );
      LogManager().cloudDrive(
        '📤 请求体: $requestBody',
        
      );

      final response = await dio.postUri(uri, data: requestBody);

      if (!QuarkBaseService.isHttpSuccess(response.statusCode)) {
        throw Exception('移动文件失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      if (!QuarkBaseService.isApiSuccess(
        responseData[QuarkConfig.responseFields['code']],
      )) {
        final message = QuarkBaseService.getErrorMessage(responseData);
        throw Exception('移动文件失败: $message');
      }

      final data = QuarkBaseService.getResponseData(responseData, 'data');
      final taskId = data['task_id'] as String?;
      final isFinished = data['finish'] as bool? ?? false;

      if (isFinished) {
        LogManager().cloudDrive(
          '✅ 夸克云盘 - 移动文件完成: ${file.name}',
          
        );
        return true;
      }

      if (taskId != null) {
        LogManager().cloudDrive(
          '⏳ 夸克云盘 - 移动文件任务创建: $taskId',
          
        );
        return await _waitForTaskCompletion(account, taskId);
      }

      return false;
    } catch (e) {
      LogManager().cloudDrive(
        '❌ 夸克云盘 - 移动文件失败: $e',
        
      );
      rethrow;
    }
  }

  /// 删除文件
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    LogManager().cloudDrive(
      '🗑️ 夸克云盘 - 删除文件开始: ${file.name}',
      
    );

    try {
      final dio = await QuarkBaseService.createDioWithAuth(account);
      final queryParams = QuarkConfig.buildFileOperationParams();
      final requestBody = QuarkConfig.buildDeleteFileBody(fileIds: [file.id]);

      final uri = _buildOperationUri('deleteFile', queryParams);
      LogManager().cloudDrive(
        '🔗 请求URL: $uri',
        
      );
      LogManager().cloudDrive(
        '📤 请求体: $requestBody',
        
      );

      final response = await dio.postUri(uri, data: requestBody);

      if (!QuarkBaseService.isHttpSuccess(response.statusCode)) {
        throw Exception('删除文件失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      if (!QuarkBaseService.isApiSuccess(
        responseData[QuarkConfig.responseFields['code']],
      )) {
        final message = QuarkBaseService.getErrorMessage(responseData);
        throw Exception('删除文件失败: $message');
      }

      final data = QuarkBaseService.getResponseData(responseData, 'data');
      final taskId = data['task_id'] as String?;
      final isFinished = data['finish'] as bool? ?? false;

      if (isFinished) {
        LogManager().cloudDrive(
          '✅ 夸克云盘 - 删除文件完成: ${file.name}',
          
        );
        return true;
      }

      if (taskId != null) {
        LogManager().cloudDrive(
          '⏳ 夸克云盘 - 删除文件任务创建: $taskId',
          
        );
        return await _waitForTaskCompletion(account, taskId);
      }

      return false;
    } catch (e) {
      LogManager().cloudDrive(
        '❌ 夸克云盘 - 删除文件失败: $e',
        
      );
      rethrow;
    }
  }

  /// 重命名文件
  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    LogManager().cloudDrive(
      '✏️ 夸克云盘 - 重命名文件开始: ${file.name} -> $newName',
      
    );

    try {
      final dio = await QuarkBaseService.createDioWithAuth(account);
      final queryParams = QuarkConfig.buildFileOperationParams();
      final requestBody = QuarkConfig.buildRenameFileBody(
        fileId: file.id,
        newName: newName,
      );

      final uri = _buildOperationUri('renameFile', queryParams);
      LogManager().cloudDrive(
        '🔗 请求URL: $uri',
        
      );
      LogManager().cloudDrive(
        '📤 请求体: $requestBody',
        
      );

      final response = await dio.postUri(uri, data: requestBody);

      if (!QuarkBaseService.isHttpSuccess(response.statusCode)) {
        throw Exception('重命名文件失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      LogManager().cloudDrive(
        '📥 夸克云盘 - 重命名响应: $responseData',
        
      );

      if (!QuarkBaseService.isApiSuccess(
        responseData[QuarkConfig.responseFields['code']],
      )) {
        final message = QuarkBaseService.getErrorMessage(responseData);
        throw Exception('重命名文件失败: $message');
      }

      LogManager().cloudDrive(
        '✅ 夸克云盘 - 重命名文件完成: ${file.name} -> $newName',
        
      );
      return true;
    } catch (e) {
      LogManager().cloudDrive(
        '❌ 夸克云盘 - 重命名文件失败: $e',
        
      );
      rethrow;
    }
  }

  /// 查询任务状态
  static Future<Map<String, dynamic>?> getTaskStatus({
    required CloudDriveAccount account,
    required String taskId,
    int retryIndex = 0,
  }) async {
    LogManager().cloudDrive(
      '📋 夸克云盘 - 查询任务状态: $taskId',
      
    );

    try {
      final dio = await QuarkBaseService.createDioWithAuth(account);
      final queryParams = QuarkConfig.buildTaskQueryParams(
        taskId: taskId,
        retryIndex: retryIndex,
      );

      final uri = _buildOperationUri('getTask', queryParams);
      LogManager().cloudDrive(
        '🔗 请求URL: $uri',
        
      );

      final response = await dio.getUri(uri);

      if (!QuarkBaseService.isHttpSuccess(response.statusCode)) {
        throw Exception('查询任务状态失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      if (!QuarkBaseService.isApiSuccess(
        QuarkBaseService.getResponseData(responseData, 'code'),
      )) {
        throw Exception(
          '查询任务状态失败: ${QuarkBaseService.getErrorMessage(responseData)}',
        );
      }

      final data = QuarkBaseService.getResponseData(responseData, 'data');
      LogManager().cloudDrive(
        '📋 任务状态查询成功: $data',
        
      );

      return data;
    } catch (e, stackTrace) {
      LogManager().cloudDrive(
        '❌ 夸克云盘 - 查询任务状态异常: $e',
        
      );
      LogManager().cloudDrive(
        '📄 错误堆栈: $stackTrace',
        
      );
      return null;
    }
  }

  /// 等待任务完成
  static Future<bool> _waitForTaskCompletion(
    CloudDriveAccount account,
    String taskId,
  ) async {
    LogManager().cloudDrive(
      '⏳ 等待任务完成: $taskId',
      
    );

    const maxRetries = 30; // 最多重试30次
    const retryDelay = Duration(seconds: 1); // 每次重试间隔1秒

    for (int retryIndex = 0; retryIndex < maxRetries; retryIndex++) {
      await Future.delayed(retryDelay);

      final taskData = await getTaskStatus(
        account: account,
        taskId: taskId,
        retryIndex: retryIndex,
      );

      if (taskData != null) {
        final status =
            taskData[QuarkConfig.responseFields['taskStatus']] as int?;

        if (status == QuarkConfig.taskStatus['success']) {
          LogManager().cloudDrive(
            '✅ 任务执行成功: $taskId',
            
          );
          return true;
        } else if (status == QuarkConfig.taskStatus['failed']) {
          LogManager().cloudDrive(
            '❌ 任务执行失败: $taskId',
            
          );
          return false;
        }

        LogManager().cloudDrive(
          '⏳ 任务仍在进行中: $taskId (状态: $status)',
          
        );
      }
    }

    LogManager().cloudDrive(
      '⚠️ 任务轮询超时: $taskId',
      
    );
    return false;
  }

  /// 构建操作URI
  static Uri _buildOperationUri(
    String operation,
    Map<String, dynamic> queryParams,
  ) {
    final url = Uri.parse(
      '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint(operation)}',
    );
    return url.replace(
      queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
    );
  }
}
