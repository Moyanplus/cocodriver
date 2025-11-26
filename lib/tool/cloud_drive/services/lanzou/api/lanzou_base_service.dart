import 'package:coco_cloud_drive/tool/cloud_drive/data/models/cloud_drive_entities.dart';
import 'package:dio/dio.dart';
import '../../../../../core/logging/log_manager.dart';
import '../lanzou_config.dart';

/// 蓝奏云盘基础服务
///
/// 提供 Dio 配置和通用方法，包括请求拦截、响应处理等。
class LanzouBaseService {
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

    // 添加请求拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          LogManager().cloudDrive(
            '蓝奏云盘 - 发送请求: ${options.method} ${options.uri}',
          );
          LogManager().cloudDrive('蓝奏云盘 - 请求头: ${options.headers}');
          if (options.data != null) {
            LogManager().cloudDrive('蓝奏云盘 - 请求体: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          LogManager().cloudDrive('蓝奏云盘 - 收到响应: ${response.statusCode}');
          LogManager().cloudDrive('蓝奏云盘 - 响应数据: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          LogManager().cloudDrive('蓝奏云盘 - 请求错误: ${error.message}');
          if (error.response != null) {
            LogManager().cloudDrive('蓝奏云盘 - 错误响应: ${error.response?.data}');
          }
          handler.next(error);
        },
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

  /// 处理API响应
  static Map<String, dynamic> handleApiResponse(Map<String, dynamic> response) {
    if (isSuccessResponse(response)) {
      return response;
    } else {
      final message = getResponseMessage(response);
      throw Exception('蓝奏云盘API错误: $message');
    }
  }

  /// 创建请求头
  static Map<String, String> createHeaders(CloudDriveAccount account) {
    return {
      ...LanzouConfig.defaultHeaders,
      'User-Agent':
          account.type.webViewConfig.userAgent ??
          LanzouConfig.defaultHeaders['User-Agent']!,
      ...account.authHeaders,
    };
  }
}
