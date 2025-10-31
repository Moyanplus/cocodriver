import '../../../data/models/cloud_drive_entities.dart';
import '../core/china_mobile_base_service.dart';
import '../core/china_mobile_config.dart';
import '../models/china_mobile_models.dart';
import '../utils/china_mobile_logger.dart';

/// 中国移动云盘下载服务
///
/// 提供获取下载链接等功能。
class ChinaMobileDownloadService {
  /// 获取下载链接（使用 DTO）
  ///
  /// [account] 中国移动云盘账号信息
  /// [request] 下载请求对象
  static Future<ChinaMobileApiResult<ChinaMobileDownloadResponse>>
  getDownloadUrlWithDTO({
    required CloudDriveAccount account,
    required ChinaMobileDownloadRequest request,
  }) async {
    final startTime = DateTime.now();

    try {
      // 1. 创建Dio实例
      final dio = ChinaMobileBaseService.createDio(account);

      // 2. 构建请求URI
      final url = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('getDownloadUrl')}',
      );

      // 3. 发送请求
      ChinaMobileLogger.network('POST', url: url.toString());
      ChinaMobileLogger.debug('请求体', data: request.toRequestBody());

      final response = await dio.postUri(url, data: request.toRequestBody());

      // 4. 使用统一的响应解析器
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

      // 5. 记录性能指标
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

  /// 获取下载链接（兼容旧接口）
  ///
  /// [account] 中国移动云盘账号信息
  /// [file] 文件对象
  /// @deprecated 建议使用 [getDownloadUrlWithDTO]
  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    ChinaMobileLogger.operationStart(
      '获取下载链接',
      params: {'fileName': file.name, 'fileId': file.id},
    );

    final request = ChinaMobileDownloadRequest(fileId: file.id);

    final result = await getDownloadUrlWithDTO(
      account: account,
      request: request,
    );

    if (result.isSuccess && result.data != null) {
      return result.data!.url;
    } else {
      ChinaMobileLogger.error('获取下载链接失败: ${result.errorMessage}');
      return null;
    }
  }
}
