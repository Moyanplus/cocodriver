import 'package:dio/dio.dart';

import '../../../../data/models/cloud_drive_entities.dart';
import 'quark_auth_service.dart';
import 'quark_config.dart';
import '../utils/quark_logger.dart';

/// 夸克云盘基础服务
///
/// 提供 Dio 实例创建、请求拦截、响应验证等功能。
abstract class QuarkBaseService {
  /// 创建 Dio 实例（使用原始认证头）
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
    // 【简化】移除冗余日志，只在出错时打印
    try {
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
    } catch (e) {
      QuarkLogger.debug('创建Dio实例失败: $e');
      rethrow;
    }
  }

  /// 添加请求拦截器
  static void _addInterceptors(Dio dio) {
    // 添加请求拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          QuarkLogger.network(options.method, url: options.uri.toString());
          if (options.data != null) {
            QuarkLogger.debug('请求体: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          QuarkLogger.debug('响应: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          QuarkLogger.debug(
            '请求错误: ${error.message} (${error.response?.statusCode ?? 'no status'})',
          );
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
          QuarkLogger.debug('请求: ${options.method} ${options.uri}');
          if (options.data != null) {
            QuarkLogger.debug('请求体: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          QuarkLogger.debug('响应: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          QuarkLogger.debug(
            '请求错误: ${error.message} (${error.response?.statusCode ?? 'no status'})',
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
