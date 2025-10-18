import 'package:dio/dio.dart';

import '../../../core/services/base/debug_service.dart';
import '../../models/cloud_drive_models.dart';
import 'quark_auth_service.dart';
import 'quark_config.dart';

/// 夸克云盘基础服务类
/// 提供通用的dio实例创建和请求拦截器
abstract class QuarkBaseService {
  /// 创建dio实例（使用原始认证头）
  static Dio createDio(CloudDriveAccount account) {
    final dio = Dio(
      BaseOptions(
        baseUrl: QuarkConfig.baseUrl,
        connectTimeout: QuarkConfig.connectTimeout,
        receiveTimeout: QuarkConfig.receiveTimeout,
        headers: {...QuarkConfig.defaultHeaders, ...account.authHeaders},
      ),
    );

    _addInterceptors(dio);
    return dio;
  }

  /// 创建带有刷新认证的dio实例
  static Future<Dio> createDioWithAuth(CloudDriveAccount account) async {
    final authHeaders = await QuarkAuthService.buildAuthHeaders(account);

    final dio = Dio(
      BaseOptions(
        baseUrl: QuarkConfig.baseUrl,
        connectTimeout: QuarkConfig.connectTimeout,
        receiveTimeout: QuarkConfig.receiveTimeout,
        headers: authHeaders,
      ),
    );

    _addInterceptors(dio);
    return dio;
  }

  /// 添加请求拦截器
  static void _addInterceptors(Dio dio) {
    // 添加请求拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          DebugService.log(
            '📡 发送请求: ${options.method} ${options.uri}',
            category: DebugCategory.tools,
            subCategory: QuarkConfig.logSubCategory,
          );
          DebugService.log(
            '📋 请求头: ${options.headers}',
            category: DebugCategory.tools,
            subCategory: QuarkConfig.logSubCategory,
          );
          if (options.data != null) {
            DebugService.log(
              '📤 请求体: ${options.data}',
              category: DebugCategory.tools,
              subCategory: QuarkConfig.logSubCategory,
            );
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          DebugService.log(
            '📡 收到响应: ${response.statusCode}',
            category: DebugCategory.tools,
            subCategory: QuarkConfig.logSubCategory,
          );
          DebugService.log(
            '📄 响应内容长度: ${response.data?.toString().length ?? 0}',
            category: DebugCategory.tools,
            subCategory: QuarkConfig.logSubCategory,
          );
          handler.next(response);
        },
        onError: (error, handler) {
          DebugService.log(
            '❌ 请求错误: ${error.message}',
            category: DebugCategory.tools,
            subCategory: QuarkConfig.logSubCategory,
          );
          if (error.response != null) {
            DebugService.log(
              '📄 错误响应: ${error.response?.statusCode} - ${error.response?.data}',
              category: DebugCategory.tools,
              subCategory: QuarkConfig.logSubCategory,
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  /// 创建用于pan.quark.cn的dio实例
  static Dio createPanDio(CloudDriveAccount account) {
    final dio = Dio(
      BaseOptions(
        baseUrl: QuarkConfig.panUrl,
        connectTimeout: QuarkConfig.connectTimeout,
        receiveTimeout: QuarkConfig.receiveTimeout,
        headers: {...QuarkConfig.defaultHeaders, ...account.authHeaders},
      ),
    );

    // 添加请求拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          DebugService.log(
            '📡 发送请求: ${options.method} ${options.uri}',
            category: DebugCategory.tools,
            subCategory: QuarkConfig.logSubCategory,
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          DebugService.log(
            '📡 收到响应: ${response.statusCode}',
            category: DebugCategory.tools,
            subCategory: QuarkConfig.logSubCategory,
          );
          handler.next(response);
        },
        onError: (error, handler) {
          DebugService.log(
            '❌ 请求错误: ${error.message}',
            category: DebugCategory.tools,
            subCategory: QuarkConfig.logSubCategory,
          );
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// 验证HTTP响应状态
  static bool isHttpSuccess(int? statusCode) {
    return statusCode == QuarkConfig.responseStatus['httpSuccess'];
  }

  /// 验证API响应状态
  static bool isApiSuccess(dynamic apiCode) {
    return apiCode == QuarkConfig.responseStatus['apiSuccess'];
  }

  /// 提取响应数据
  static dynamic getResponseData(Map<String, dynamic> response, String field) {
    return response[QuarkConfig.responseFields[field]];
  }

  /// 提取错误信息
  static String getErrorMessage(Map<String, dynamic> response) {
    return response[QuarkConfig.responseFields['message']] ?? '未知错误';
  }
}
