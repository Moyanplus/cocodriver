import 'package:dio/dio.dart';

import '../../../../data/models/cloud_drive_entities.dart';
import '../core/china_mobile_base_service.dart';
import '../core/china_mobile_config.dart';
import '../models/china_mobile_models.dart';
import '../utils/china_mobile_logger.dart';

/// 中国移动云盘统一操作封装。
class ChinaMobileOperations {
  static Future<ChinaMobileApiResult<ChinaMobileFileListResponse>> listFiles({
    required CloudDriveAccount account,
    required ChinaMobileFileListRequest request,
  }) async {
    final startTime = DateTime.now();

    try {
      final dio = ChinaMobileBaseService.createDio(account);
      final url = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('getFileList')}',
      );

      final response = await dio.postUri(url, data: request.toRequestBody());
      _logResponse('POST', url, response);

      final result =
          ChinaMobileResponseParser.parse<ChinaMobileFileListResponse>(
            response: response.data,
            statusCode: response.statusCode,
            dataParser: (data) {
              return ChinaMobileFileListResponse.fromJson(
                response.data as Map<String, dynamic>,
                request.parentFileId,
              );
            },
          );

      if (result.isSuccess) {
        final duration = DateTime.now().difference(startTime);
        ChinaMobileLogger.performance(
          '获取文件列表完成，共 ${result.data!.files.length} 个文件',
          duration: duration,
        );
      }

      return result;
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('获取文件列表失败', error: e, stackTrace: stackTrace);
      return ChinaMobileApiResult.fromException(e as Exception);
    }
  }

  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required ChinaMobileRenameFileRequest request,
  }) async {
    try {
      final dio = ChinaMobileBaseService.createDio(account);
      final uri = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('updateFile')}',
      );

      final response = await dio.postUri(uri, data: request.toRequestBody());
      _logResponse('POST', uri, response);
      if (ChinaMobileBaseService.isHttpSuccess(response.statusCode) &&
          ChinaMobileBaseService.isApiSuccess(response.data)) {
        ChinaMobileLogger.success('重命名文件完成');
        return true;
      } else {
        final errorMsg = ChinaMobileBaseService.getErrorMessage(
          response.data ?? {},
        );
        ChinaMobileLogger.error('重命名文件失败: $errorMsg');
        return false;
      }
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('重命名文件失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required ChinaMobileMoveFileRequest request,
  }) async {
    return _simpleBatchOperation(
      account: account,
      endpointKey: 'batchMove',
      requestBody: request.toRequestBody(),
      opName: '移动文件',
    );
  }

  static Future<bool> copyFile({
    required CloudDriveAccount account,
    required ChinaMobileCopyFileRequest request,
  }) async {
    return _simpleBatchOperation(
      account: account,
      endpointKey: 'batchCopy',
      requestBody: request.toRequestBody(),
      opName: '复制文件',
    );
  }

  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required ChinaMobileDeleteFileRequest request,
  }) async {
    return _simpleBatchOperation(
      account: account,
      endpointKey: 'batchTrash',
      requestBody: request.toRequestBody(),
      opName: '删除文件',
    );
  }

  static Future<bool> _simpleBatchOperation({
    required CloudDriveAccount account,
    required String endpointKey,
    required Map<String, dynamic> requestBody,
    required String opName,
  }) async {
    ChinaMobileLogger.operationStart(opName, params: requestBody);
    try {
      final dio = ChinaMobileBaseService.createDio(account);
      final uri = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint(endpointKey)}',
      );

      final response = await dio.postUri(uri, data: requestBody);
      _logResponse('POST', uri, response);
      if (ChinaMobileBaseService.isHttpSuccess(response.statusCode) &&
          ChinaMobileBaseService.isApiSuccess(response.data)) {
        ChinaMobileLogger.success('$opName 完成');
        return true;
      } else {
        final errorMsg = ChinaMobileBaseService.getErrorMessage(
          response.data ?? {},
        );
        ChinaMobileLogger.error('$opName 失败: $errorMsg');
        return false;
      }
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('$opName 失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  static Future<ChinaMobileApiResult<ChinaMobileDownloadResponse>>
  getDownloadUrl({
    required CloudDriveAccount account,
    required ChinaMobileDownloadRequest request,
  }) async {
    final startTime = DateTime.now();

    try {
      final dio = ChinaMobileBaseService.createDio(account);
      final url = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('getDownloadUrl')}',
      );

      final response = await dio.postUri(url, data: request.toRequestBody());
      _logResponse('POST', url, response);

      final result =
          ChinaMobileResponseParser.parse<ChinaMobileDownloadResponse>(
            response: response.data,
            statusCode: response.statusCode,
            dataParser: (data) {
              return ChinaMobileDownloadResponse.fromJson(
                response.data as Map<String, dynamic>,
              );
            },
          );

      if (result.isSuccess) {
        final duration = DateTime.now().difference(startTime);
        ChinaMobileLogger.performance('获取下载链接完成', duration: duration);
      }

      return result;
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('获取下载链接失败', error: e, stackTrace: stackTrace);
      return ChinaMobileApiResult.fromException(e as Exception);
    }
  }

  static Future<ChinaMobileApiResult<ChinaMobilePreviewResponse>>
  getPreviewInfo({
    required CloudDriveAccount account,
    required ChinaMobilePreviewRequest request,
  }) async {
    final startTime = DateTime.now();
    try {
      final dio = ChinaMobileBaseService.createDio(account);
      final uri = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('getPreviewInfo')}',
      );

      final response = await dio.postUri(uri, data: request.toRequestBody());
      _logResponse('POST', uri, response);

      final result =
          ChinaMobileResponseParser.parse<ChinaMobilePreviewResponse>(
            response: response.data,
            statusCode: response.statusCode,
            dataParser: (data) => ChinaMobilePreviewResponse.fromJson(data),
          );

      if (result.isSuccess) {
        ChinaMobileLogger.performance(
          '获取预览信息完成',
          duration: DateTime.now().difference(startTime),
        );
      }

      return result;
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('获取预览信息失败', error: e, stackTrace: stackTrace);
      return ChinaMobileApiResult.fromException(e as Exception);
    }
  }

  static Future<ChinaMobileApiResult<Map<String, dynamic>>> createShareLink({
    required CloudDriveAccount account,
    required ChinaMobileShareRequest request,
  }) async {
    final startTime = DateTime.now();

    try {
      final dio = ChinaMobileBaseService.createOrchestrationDio(account);
      final url = Uri.parse(
        '${ChinaMobileConfig.orchestrationUrl}${ChinaMobileConfig.getApiEndpoint('getShareLink')}',
      );

      final response = await dio.postUri(url, data: request.toRequestBody());
      _logResponse('POST', url, response);

      if (ChinaMobileBaseService.isHttpSuccess(response.statusCode) &&
          ChinaMobileBaseService.isApiSuccess(response.data)) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        final duration = DateTime.now().difference(startTime);
        ChinaMobileLogger.performance('创建分享链接完成', duration: duration);
        return ChinaMobileApiResult.success(data);
      } else {
        final errorMsg = ChinaMobileBaseService.getErrorMessage(
          response.data ?? {},
        );
        return ChinaMobileApiResult.failure(errorMsg);
      }
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('创建分享链接失败', error: e, stackTrace: stackTrace);
      return ChinaMobileApiResult.fromException(e as Exception);
    }
  }

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

      final response = await dio.postUri(uri, data: request.toRequestBody());
      _logResponse('POST', uri, response);

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

  static Future<ChinaMobileApiResult<ChinaMobileCreateFolderResponse>>
  createFolder({
    required CloudDriveAccount account,
    required ChinaMobileCreateFolderRequest request,
  }) async {
    ChinaMobileLogger.operationStart('创建文件夹', params: request.toRequestBody());
    try {
      final dio = ChinaMobileBaseService.createDio(account);
      final uri = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('createFolder')}',
      );

      final response = await dio.postUri(uri, data: request.toRequestBody());
      _logResponse('POST', uri, response);
      return ChinaMobileResponseParser.parse<ChinaMobileCreateFolderResponse>(
        response: response.data,
        statusCode: response.statusCode,
        dataParser: (data) => ChinaMobileCreateFolderResponse.fromJson(
          (response.data?['data'] as Map<String, dynamic>? ?? {}),
        ),
      );
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('创建文件夹失败', error: e, stackTrace: stackTrace);
      return ChinaMobileApiResult.fromException(e as Exception);
    }
  }

  static Future<ChinaMobileApiResult<ChinaMobileUploadInitResponse>> initUpload({
    required CloudDriveAccount account,
    required ChinaMobileUploadInitRequest request,
  }) async {
    try {
      final dio = ChinaMobileBaseService.createDio(account);
      final uri = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('createFile')}',
      );
      final response = await dio.postUri(uri, data: request.toRequestBody());
      _logResponse('POST', uri, response);
      return ChinaMobileResponseParser.parse<ChinaMobileUploadInitResponse>(
        response: response.data,
        statusCode: response.statusCode,
        dataParser: (data) => ChinaMobileUploadInitResponse.fromJson(
          (response.data?['data'] as Map<String, dynamic>? ?? {}),
        ),
      );
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('初始化上传失败', error: e, stackTrace: stackTrace);
      return ChinaMobileApiResult.fromException(e as Exception);
    }
  }

  static Future<ChinaMobileApiResult<Map<String, dynamic>>> completeUpload({
    required CloudDriveAccount account,
    required ChinaMobileUploadCompleteRequest request,
  }) async {
    try {
      final dio = ChinaMobileBaseService.createDio(account);
      final uri = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('completeUpload')}',
      );
      final response = await dio.postUri(uri, data: request.toRequestBody());
      _logResponse('POST', uri, response);
      return ChinaMobileResponseParser.parse<Map<String, dynamic>>(
        response: response.data,
        statusCode: response.statusCode,
        dataParser: (data) =>
            (response.data?['data'] as Map<String, dynamic>? ?? {}),
      );
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('完成上传失败', error: e, stackTrace: stackTrace);
      return ChinaMobileApiResult.fromException(e as Exception);
    }
  }

  static void _logResponse(String method, Uri uri, Response response) {
    if (!ChinaMobileConfig.verboseLogging) return;
    ChinaMobileLogger.networkResponse(
      method: method,
      url: uri.toString(),
      statusCode: response.statusCode,
      data: response.data,
    );
  }
}
