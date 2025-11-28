import '../../../data/models/cloud_drive_entities.dart';
import '../core/china_mobile_base_service.dart';
import '../core/china_mobile_config.dart';
import '../models/china_mobile_models.dart';
import '../models/requests/china_mobile_file_operation_request.dart';
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

      ChinaMobileLogger.network('POST', url: url.toString());
      ChinaMobileLogger.debug('请求体', data: request.toRequestBody());

      final response = await dio.postUri(url, data: request.toRequestBody());

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

      ChinaMobileLogger.network('POST', url: uri.toString());
      ChinaMobileLogger.debug('请求体', data: request.toRequestBody());

      final response = await dio.postUri(uri, data: request.toRequestBody());
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

      ChinaMobileLogger.network('POST', url: uri.toString());
      ChinaMobileLogger.debug('请求体', data: requestBody);

      final response = await dio.postUri(uri, data: requestBody);
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
}
