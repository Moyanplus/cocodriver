import '../../../data/models/cloud_drive_entities.dart';
import 'quark_base_service.dart';
import 'quark_config.dart';
import '../models/quark_models.dart';
import '../utils/quark_logger.dart';

/// 夸克云盘文件操作服务
///
/// 提供移动、删除、复制、重命名、创建文件夹等操作功能。
class QuarkFileOperationService {
  /// 执行文件操作（统一方法）
  ///
  /// [account] 夸克云盘账号信息
  /// [request] 文件操作请求对象
  static Future<QuarkApiResult<QuarkFileOperationResponse>> executeOperation({
    required CloudDriveAccount account,
    required QuarkFileOperationRequest request,
  }) async {
    try {
      // 1. 创建认证的Dio实例
      final dio = await QuarkBaseService.createDioWithAuth(account);

      // 2. 构建请求URL
      final operationName = _getOperationName(request.operationType);
      final uri = _buildOperationUri(
        operationName,
        request.toQueryParameters(),
      );

      QuarkLogger.network('POST', url: uri.toString());
      QuarkLogger.debug('请求体', data: request.toRequestBody());

      // 3. 发送请求
      final response = await dio.postUri(uri, data: request.toRequestBody());

      // 4. 使用统一的响应解析器
      return QuarkResponseParser.parse<QuarkFileOperationResponse>(
        response: response.data,
        statusCode: response.statusCode,
        dataParser: (data) {
          return QuarkFileOperationResponse.fromJson(data);
        },
      );
    } catch (e, stackTrace) {
      QuarkLogger.error('文件操作失败', error: e, stackTrace: stackTrace);
      return QuarkApiResult.fromException(e as Exception);
    }
  }

  /// 获取操作名称
  static String _getOperationName(FileOperationType type) {
    switch (type) {
      case FileOperationType.move:
        return 'moveFile';
      case FileOperationType.copy:
        return 'copyFile';
      case FileOperationType.delete:
        return 'deleteFile';
      case FileOperationType.rename:
        return 'renameFile';
    }
  }

  /// 处理操作结果（统一方法）
  static Future<bool> _handleOperationResult(
    QuarkApiResult<QuarkFileOperationResponse> result,
    CloudDriveAccount account,
    String operationName,
    String fileName,
  ) async {
    if (result.isFailure) {
      QuarkLogger.error('$operationName失败: ${result.errorMessage}');
      return false;
    }

    final response = result.data!;

    // 同步完成
    if (response.isFinished) {
      QuarkLogger.success('$operationName完成: $fileName');
      return true;
    }

    // 异步任务
    if (response.taskId != null) {
      QuarkLogger.task('$operationName任务创建', taskId: response.taskId!);
      return await _waitForTaskCompletion(account, response.taskId!);
    }

    // 未知情况
    QuarkLogger.warning('$operationName返回未知状态');
    return false;
  }

  /// 移动文件到目标文件夹
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) async {
    QuarkLogger.operationStart(
      '移动文件',
      params: {
        'fileName': file.name,
        'fileId': file.id,
        'targetFolderId': targetFolderId,
      },
    );

    // 使用 DTO 构建请求
    final request = QuarkMoveFileRequest(
      targetFolderId: targetFolderId,
      fileIds: [file.id],
    );

    final result = await executeOperation(account: account, request: request);

    return await _handleOperationResult(result, account, '移动文件', file.name);
  }

  /// 复制文件到目标文件夹
  static Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) async {
    QuarkLogger.operationStart(
      '复制文件',
      params: {
        'fileName': file.name,
        'fileId': file.id,
        'targetFolderId': targetFolderId,
      },
    );

    // 使用 DTO 构建请求
    final request = QuarkCopyFileRequest(
      targetFolderId: targetFolderId,
      fileIds: [file.id],
    );

    final result = await executeOperation(account: account, request: request);

    return await _handleOperationResult(result, account, '复制文件', file.name);
  }

  /// 删除文件
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    QuarkLogger.operationStart(
      '删除文件',
      params: {
        'fileName': file.name,
        'fileId': file.id,
        'isFolder': file.isFolder,
      },
    );

    // 使用 DTO 构建请求
    final request = QuarkDeleteFileRequest(fileIds: [file.id]);

    final result = await executeOperation(account: account, request: request);

    return await _handleOperationResult(result, account, '删除文件', file.name);
  }

  /// 重命名文件或文件夹
  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    QuarkLogger.operationStart(
      '重命名文件',
      params: {'fileName': file.name, 'newName': newName, 'fileId': file.id},
    );

    // 使用 DTO 构建请求
    final request = QuarkRenameFileRequest(fileId: file.id, newName: newName);

    final result = await executeOperation(account: account, request: request);

    if (result.isSuccess) {
      QuarkLogger.success('重命名文件完成: ${file.name} -> $newName');
      return true;
    } else {
      QuarkLogger.error('重命名文件失败: ${result.errorMessage}');
      return false;
    }
  }

  /// 查询任务状态
  static Future<QuarkApiResult<QuarkTaskStatusResponse>> getTaskStatus({
    required CloudDriveAccount account,
    required String taskId,
    int retryIndex = 0,
  }) async {
    QuarkLogger.task('查询任务状态', taskId: taskId);

    try {
      // 1. 创建认证的Dio实例
      final dio = await QuarkBaseService.createDioWithAuth(account);

      // 2. 使用 DTO 构建请求
      final request = QuarkTaskStatusRequest(
        taskId: taskId,
        retryIndex: retryIndex,
      );

      // 3. 发送请求
      final uri = _buildOperationUri('getTask', request.toQueryParameters());
      QuarkLogger.network('GET', url: uri.toString());

      final response = await dio.getUri(uri);

      // 4. 使用统一的响应解析器
      return QuarkResponseParser.parse<QuarkTaskStatusResponse>(
        response: response.data,
        statusCode: response.statusCode,
        dataParser: (data) {
          QuarkLogger.debug('任务状态', data: data);
          return QuarkTaskStatusResponse.fromJson(data);
        },
      );
    } catch (e, stackTrace) {
      QuarkLogger.error('查询任务状态失败', error: e, stackTrace: stackTrace);
      return QuarkApiResult.fromException(e as Exception);
    }
  }

  /// 等待任务完成（私有方法）
  static Future<bool> _waitForTaskCompletion(
    CloudDriveAccount account,
    String taskId,
  ) async {
    QuarkLogger.task('开始等待任务完成', taskId: taskId);

    // 配置轮询参数
    final maxRetries = QuarkConfig.performanceConfig['taskMaxRetries'] as int;
    final retryDelay = Duration(
      seconds: QuarkConfig.performanceConfig['taskRetryDelay'] as int,
    );

    // 开始轮询
    for (int retryIndex = 0; retryIndex < maxRetries; retryIndex++) {
      // 等待一段时间后再查询
      await Future.delayed(retryDelay);

      // 查询任务状态
      final result = await getTaskStatus(
        account: account,
        taskId: taskId,
        retryIndex: retryIndex,
      );

      // 解析任务状态
      if (result.isSuccess && result.data != null) {
        final taskStatus = result.data!;

        // 任务成功
        if (taskStatus.isSuccess) {
          QuarkLogger.success('任务执行成功: $taskId');
          return true;
        }

        // 任务失败
        if (taskStatus.isFailed) {
          QuarkLogger.error('任务执行失败: $taskId');
          return false;
        }

        // 任务仍在进行中
        QuarkLogger.task(
          '任务进行中 (${retryIndex + 1}/$maxRetries)',
          taskId: taskId,
        );
      } else {
        // 查询失败，继续重试
        QuarkLogger.warning('查询任务状态失败，继续重试');
      }
    }

    // 超时
    QuarkLogger.error('任务轮询超时: $taskId');
    return false;
  }

  /// 构建操作URI（私有方法）
  ///
  /// 根据操作类型和查询参数构建完整的API请求URI。
  ///
  /// **参数**:
  /// - [operation] 操作类型，如 'moveFile'、'deleteFile' 等
  /// - [queryParams] 查询参数
  ///
  /// **返回值**:
  /// 完整的URI对象
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

  /// 在指定位置创建新文件夹
  static Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    QuarkLogger.operationStart(
      '创建文件夹',
      params: {
        'folderName': folderName,
        'parentFolderId': parentFolderId ?? '根目录',
      },
    );

    try {
      // 1. 创建认证的Dio实例
      final dio = await QuarkBaseService.createDioWithAuth(account);

      // 2. 构建请求URL
      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('createFolder')}',
      );

      // 添加必要的查询参数
      final queryParams = QuarkConfig.buildCreateFolderParams();
      final uri = url.replace(queryParameters: queryParams);

      // 3. 构建请求体
      final requestBody = {
        QuarkConfig.responseFields['pdirFid']: QuarkConfig.getFolderId(
          parentFolderId,
        ),
        QuarkConfig.responseFields['fileName']: folderName,
        QuarkConfig.responseFields['dirPath']: '',
        QuarkConfig.responseFields['dirInitLock']: false,
      };

      QuarkLogger.debug('请求体', data: requestBody);

      // 4. 发送请求
      final response = await dio.postUri(uri, data: requestBody);

      // 5. 检查HTTP状态码
      if (response.statusCode != 200) {
        QuarkLogger.error('HTTP请求失败 - 状态码: ${response.statusCode}');
        throw Exception('HTTP请求失败，状态码: ${response.statusCode}');
      }

      // 6. 检查API响应码
      final responseData = response.data;
      if (responseData['code'] != 0) {
        final message = responseData['message'];
        throw Exception('API返回错误: $message');
      }

      // 7. 解析创建结果
      final data = responseData[QuarkConfig.responseFields['data']];
      final finish = data[QuarkConfig.responseFields['finish']] as bool?;
      final fid = data[QuarkConfig.responseFields['fid']] as String?;

      QuarkLogger.success('文件夹创建成功 - 文件夹ID: $fid');

      // 8. 构建返回结果
      if (fid != null) {
        // 创建CloudDriveFile对象
        final folder = CloudDriveFile(
          id: fid,
          name: folderName,
          size: QuarkConfig.defaultValues['folderSize'] as int,
          modifiedTime: DateTime.now(),
          isFolder: true,
          folderId: QuarkConfig.getFolderId(parentFolderId),
        );

        final result = {
          'success': true,
          'folderId': fid,
          'folderName': folderName,
          'parentFolderId': QuarkConfig.getFolderId(parentFolderId),
          'finish': finish ?? false,
          'folder': folder,
        };

        return result;
      } else {
        QuarkLogger.error('文件夹创建成功但未返回文件夹ID');

        final result = {
          'success': true,
          'folderId': null,
          'folderName': folderName,
          'parentFolderId': QuarkConfig.getFolderId(parentFolderId),
          'finish': finish ?? false,
        };

        return result;
      }
    } catch (e, stackTrace) {
      QuarkLogger.error('创建文件夹失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
