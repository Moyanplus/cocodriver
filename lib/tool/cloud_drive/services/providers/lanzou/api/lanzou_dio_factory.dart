import 'package:coco_cloud_drive/tool/cloud_drive/data/models/cloud_drive_entities.dart';
import 'package:dio/dio.dart';
import '../../../base/cloud_drive_api_logger.dart';
import '../lanzou_config.dart';

/// 蓝奏云盘基础服务
///
/// 提供 Dio 配置和通用方法，包括请求拦截、响应处理等。
class LanzouDioFactory {
  /// 创建 Dio 实例
  static Dio createDio(CloudDriveAccount account) {
    final dio = Dio(
      BaseOptions(
        baseUrl: LanzouConfig.baseUrl,
        connectTimeout: LanzouConfig.connectTimeout,
        receiveTimeout: LanzouConfig.receiveTimeout,
        sendTimeout: LanzouConfig.sendTimeout,
        headers: {
          ...LanzouConfig.defaultHeaders,
          'User-Agent':
              account.type.webViewConfig.userAgent ??
              LanzouConfig.defaultHeaders['User-Agent']!,
          ...account.authHeaders,
        },
        followRedirects: LanzouConfig.followRedirects,
        maxRedirects: LanzouConfig.maxRedirects,
        validateStatus: LanzouConfig.validateStatus,
      ),
    );

    dio.interceptors.add(
      CloudDriveLoggingInterceptor(
        logger: CloudDriveApiLogger(
          provider: '蓝奏云盘',
          verbose: LanzouConfig.verboseLogging,
        ),
      ),
    );

    return dio;
  }

  /// 验证响应状态
  static bool isSuccessResponse(Map<String, dynamic> response) =>
      LanzouConfig.isSuccessResponse(response);

  /// 获取响应数据
  static Map<String, dynamic>? getResponseData(Map<String, dynamic> response) =>
      LanzouConfig.getResponseData(response);

  /// 获取响应消息
  static String getResponseMessage(Map<String, dynamic> response) =>
      LanzouConfig.getResponseMessage(response);

  /// 创建请求头
  static Map<String, String> createHeaders(
    CloudDriveAccount account, {
    Map<String, String>? extra,
  }) {
    final headers = {
      ...LanzouConfig.defaultHeaders,
      'User-Agent':
          account.type.webViewConfig.userAgent ??
          LanzouConfig.defaultHeaders['User-Agent']!,
      ...account.authHeaders,
    };

    if (extra != null) {
      headers.addAll(extra);
    }

    return headers;
  }
}
