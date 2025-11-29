import 'package:dio/dio.dart';

import '../../../../data/models/cloud_drive_entities.dart';
import '../../../base/cloud_drive_api_logger.dart';
import 'china_mobile_config.dart';

/// 中国移动云盘基础服务
///
/// 提供 Dio 实例创建、请求拦截、响应验证等功能。
abstract class ChinaMobileBaseService {
  /// 创建 Dio 实例
  static Dio createDio(CloudDriveAccount account) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ChinaMobileConfig.baseUrl,
        connectTimeout: ChinaMobileConfig.connectTimeout,
        receiveTimeout: ChinaMobileConfig.receiveTimeout,
        sendTimeout: ChinaMobileConfig.sendTimeout,
        headers: {...ChinaMobileConfig.defaultHeaders, ...account.authHeaders},
        followRedirects: ChinaMobileConfig.followRedirects,
        maxRedirects: ChinaMobileConfig.maxRedirects,
        validateStatus: ChinaMobileConfig.validateStatus,
      ),
    );

    _addInterceptors(dio);
    return dio;
  }

  /// 创建用于编排服务的dio实例
  static Dio createOrchestrationDio(CloudDriveAccount account) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ChinaMobileConfig.orchestrationUrl,
        connectTimeout: ChinaMobileConfig.connectTimeout,
        receiveTimeout: ChinaMobileConfig.receiveTimeout,
        sendTimeout: ChinaMobileConfig.sendTimeout,
        headers: {...ChinaMobileConfig.defaultHeaders, ...account.authHeaders},
        followRedirects: ChinaMobileConfig.followRedirects,
        maxRedirects: ChinaMobileConfig.maxRedirects,
        validateStatus: ChinaMobileConfig.validateStatus,
      ),
    );

    _addInterceptors(dio);
    return dio;
  }

  /// 添加请求拦截器
  static void _addInterceptors(Dio dio) {
    final logger = CloudDriveApiLogger(
      provider: '中国移动云盘',
      verbose: ChinaMobileConfig.verboseLogging,
      truncateLength: 800,
    );
    dio.interceptors.add(CloudDriveLoggingInterceptor(logger: logger));
  }

  /// 验证HTTP响应状态
  static bool isHttpSuccess(int? statusCode) {
    return statusCode == ChinaMobileConfig.responseStatus['httpSuccess'];
  }

  /// 验证API响应状态
  static bool isApiSuccess(dynamic response) {
    if (response is Map<String, dynamic>) {
      final success = response[ChinaMobileConfig.responseFields['success']];
      return success == ChinaMobileConfig.responseStatus['apiSuccess'];
    }
    return false;
  }

  /// 提取响应数据
  static dynamic getResponseData(Map<String, dynamic> response, String field) {
    return response[ChinaMobileConfig.responseFields[field]];
  }

  /// 提取错误信息
  static String getErrorMessage(Map<String, dynamic> response) {
    return response[ChinaMobileConfig.responseFields['message']] ?? '未知错误';
  }
}
