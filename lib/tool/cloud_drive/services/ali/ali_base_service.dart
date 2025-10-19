import 'package:dio/dio.dart';

import '../../../../core/logging/log_manager.dart';
import '../../../../core/logging/log_category.dart';
import '../../models/cloud_drive_models.dart';
import 'ali_config.dart';

/// 阿里云盘基础服务
/// 提供通用的Dio配置和响应处理功能
abstract class AliBaseService {
  /// 创建配置好的Dio实例
  static Dio createDio(CloudDriveAccount account) {
    // 记录云盘服务初始化日志
    LogManager().cloudDrive(
      '创建阿里云盘Dio实例',
      className: 'AliBaseService',
      methodName: 'createDio',
      data: {
        'accountId': account.id,
        'accountName': account.name,
        'baseUrl': AliConfig.baseUrl,
      },
    );

    final dio = Dio(
      BaseOptions(
        baseUrl: AliConfig.baseUrl,
        connectTimeout: AliConfig.connectTimeout,
        receiveTimeout: AliConfig.receiveTimeout,
        headers: _buildHeaders(account),
      ),
    );

    _addInterceptors(dio);
    return dio;
  }

  /// 创建用于API调用的Dio实例（使用api.aliyundrive.com）
  static Dio createApiDio(CloudDriveAccount account) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AliConfig.apiUrl,
        connectTimeout: AliConfig.connectTimeout,
        receiveTimeout: AliConfig.receiveTimeout,
        headers: _buildHeaders(account),
      ),
    );

    _addInterceptors(dio);
    return dio;
  }

  /// 构建请求头
  static Map<String, String> _buildHeaders(CloudDriveAccount account) {
    final headers = Map<String, String>.from(AliConfig.defaultHeaders);

    // 添加Authorization头
    if (account.authorizationToken != null &&
        account.authorizationToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${account.authorizationToken}';
    }

    return headers;
  }

  /// 添加拦截器
  static void _addInterceptors(Dio dio) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          LogManager().network(
            '阿里云盘请求: ${options.method} ${options.uri}',
            className: 'AliBaseService',
            methodName: 'onRequest',
            data: {
              'method': options.method,
              'uri': options.uri.toString(),
              'headers': options.headers,
              'data': options.data?.toString(),
            },
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          LogManager().network(
            '阿里云盘响应: ${response.statusCode} ${response.requestOptions.uri}',
            className: 'AliBaseService',
            methodName: 'onResponse',
            data: {
              'statusCode': response.statusCode,
              'uri': response.requestOptions.uri.toString(),
              'data': response.data?.toString(),
            },
          );
          handler.next(response);
        },
        onError: (error, handler) {
          LogManager().error(
            '阿里云盘请求错误: ${error.message}',
            category: LogCategory.network,
            className: 'AliBaseService',
            methodName: 'onError',
            data: {
              'errorType': error.type.toString(),
              'message': error.message,
              'uri': error.requestOptions.uri.toString(),
            },
            exception: error,
          );
          handler.next(error);
        },
      ),
    );
  }

  /// 检查HTTP响应是否成功
  static bool isHttpSuccess(int? statusCode) =>
      statusCode != null && statusCode >= 200 && statusCode < 300;

  /// 检查API响应是否成功
  static bool isApiSuccess(Map<String, dynamic> response) =>
      AliConfig.isResponseSuccess(response);

  /// 获取响应数据
  static dynamic getResponseData(Map<String, dynamic> response) => response;

  /// 获取错误信息
  static String getErrorMessage(Map<String, dynamic> response) =>
      AliConfig.getErrorMessage(response);
}
