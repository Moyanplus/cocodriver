import 'package:dio/dio.dart';

import '../../../core/services/base/debug_service.dart';
import '../../models/cloud_drive_models.dart';
import 'ali_config.dart';

/// 阿里云盘基础服务
/// 提供通用的Dio配置和响应处理功能
abstract class AliBaseService {
  /// 创建配置好的Dio实例
  static Dio createDio(CloudDriveAccount account) {
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
          DebugService.log(
            '📤 阿里云盘请求: ${options.method} ${options.uri}',
            category: DebugCategory.tools,
            subCategory: AliConfig.logSubCategory,
          );
          DebugService.log(
            '📤 请求头: ${options.headers}',
            category: DebugCategory.tools,
            subCategory: AliConfig.logSubCategory,
          );
          if (options.data != null) {
            DebugService.log(
              '📤 请求体: ${options.data}',
              category: DebugCategory.tools,
              subCategory: AliConfig.logSubCategory,
            );
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          DebugService.log(
            '📥 阿里云盘响应: ${response.statusCode} ${response.requestOptions.uri}',
            category: DebugCategory.tools,
            subCategory: AliConfig.logSubCategory,
          );
          handler.next(response);
        },
        onError: (error, handler) {
          DebugService.log(
            '❌ 阿里云盘请求错误: ${error.message}',
            category: DebugCategory.tools,
            subCategory: AliConfig.logSubCategory,
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
