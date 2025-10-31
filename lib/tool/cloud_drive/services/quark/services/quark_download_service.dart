import '../../../data/models/cloud_drive_entities.dart';
import '../core/quark_base_service.dart';
import '../core/quark_config.dart';
import '../models/quark_models.dart';
import '../utils/quark_logger.dart';

/// 夸克云盘下载服务 - 获取文件下载链接、支持批量下载
class QuarkDownloadService {
  /// 获取文件下载链接（使用 DTO）
  ///
  /// 使用 [QuarkDownloadRequest] 构建请求
  /// 返回 [QuarkApiResult] 包装的 [QuarkDownloadResponse]
  static Future<QuarkApiResult<QuarkDownloadResponse>> getDownloadUrlWithDTO({
    required CloudDriveAccount account,
    required QuarkDownloadRequest request,
  }) async {
    try {
      // 1. 创建认证的Dio实例
      final dio = await QuarkBaseService.createDioWithAuth(account);

      // 2. 构建请求URL
      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('getDownloadUrl')}',
      );
      final uri = url.replace(queryParameters: request.toQueryParameters());

      QuarkLogger.network('POST', url: uri.toString());
      QuarkLogger.debug('请求体', data: request.toRequestBody());

      // 3. 发送请求
      final response = await dio.postUri(uri, data: request.toRequestBody());

      // 4. 使用统一的响应解析器
      return QuarkResponseParser.parse<QuarkDownloadResponse>(
        response: response.data,
        statusCode: response.statusCode,
        dataParser: (data) {
          if (data is! List || data.isEmpty) {
            throw Exception('响应数据为空');
          }

          final fileData = data.first as Map<String, dynamic>;
          return QuarkDownloadResponse.fromJson(fileData);
        },
      );
    } catch (e, stackTrace) {
      QuarkLogger.error('获取下载链接失败', error: e, stackTrace: stackTrace);
      return QuarkApiResult.fromException(e as Exception);
    }
  }

  /// 批量获取下载链接（使用 DTO）
  ///
  /// 使用 [QuarkDownloadRequest] 构建请求
  /// 返回 [QuarkApiResult] 包装的 [QuarkBatchDownloadResponse]
  static Future<QuarkApiResult<QuarkBatchDownloadResponse>>
  getBatchDownloadUrlsWithDTO({
    required CloudDriveAccount account,
    required QuarkDownloadRequest request,
  }) async {
    QuarkLogger.operationStart(
      '获取批量下载链接',
      params: {'fileCount': request.fileIds.length},
    );

    try {
      // 1. 创建认证的Dio实例
      final dio = await QuarkBaseService.createDioWithAuth(account);

      // 2. 构建请求URL
      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('getDownloadUrl')}',
      );
      final uri = url.replace(queryParameters: request.toQueryParameters());

      QuarkLogger.network('POST', url: uri.toString());

      // 3. 发送请求
      final response = await dio.postUri(uri, data: request.toRequestBody());

      // 4. 使用统一的响应解析器
      return QuarkResponseParser.parse<QuarkBatchDownloadResponse>(
        response: response.data,
        statusCode: response.statusCode,
        dataParser: (data) {
          if (data is! List) {
            throw Exception('响应数据格式错误');
          }

          final batchResponse = QuarkBatchDownloadResponse.fromJsonList(data);
          QuarkLogger.success('批量下载链接获取成功 - 共 ${batchResponse.count} 个文件');

          return batchResponse;
        },
      );
    } catch (e, stackTrace) {
      QuarkLogger.error('获取批量下载链接失败', error: e, stackTrace: stackTrace);
      return QuarkApiResult.fromException(e as Exception);
    }
  }

  /// 获取文件下载链接（兼容旧接口）
  ///
  /// @deprecated 建议使用 [getDownloadUrlWithDTO]
  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required String fileId,
    required String fileName,
    int? size,
  }) async {
    QuarkLogger.operationStart(
      '获取下载链接',
      params: {
        'fileId': fileId,
        'fileName': fileName,
        'size':
            size != null
                ? '${(size / 1024 / 1024).toStringAsFixed(2)} MB'
                : '未知',
      },
    );

    // 使用新的 DTO 方式
    final request = QuarkDownloadRequest(fileIds: [fileId]);
    final result = await getDownloadUrlWithDTO(
      account: account,
      request: request,
    );

    if (result.isSuccess && result.data != null) {
      QuarkLogger.success('下载链接获取成功');
      QuarkLogger.download('下载链接', fileName: fileName);
      return result.data!.downloadUrl;
    } else {
      QuarkLogger.error('获取下载链接失败: ${result.errorMessage}');
      throw Exception(result.errorMessage ?? '获取下载链接失败');
    }
  }

  /// 批量获取下载链接（兼容旧接口）
  ///
  /// @deprecated 建议使用 [getBatchDownloadUrlsWithDTO]
  static Future<Map<String, String>> getBatchDownloadUrls({
    required CloudDriveAccount account,
    required List<String> fileIds,
  }) async {
    // 使用新的 DTO 方式
    final request = QuarkDownloadRequest(fileIds: fileIds);
    final result = await getBatchDownloadUrlsWithDTO(
      account: account,
      request: request,
    );

    if (result.isSuccess && result.data != null) {
      return result.data!.downloadUrls;
    } else {
      QuarkLogger.error('获取批量下载链接失败: ${result.errorMessage}');
      throw Exception(result.errorMessage ?? '获取批量下载链接失败');
    }
  }
}
