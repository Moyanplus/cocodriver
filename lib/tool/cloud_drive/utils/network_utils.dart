import 'dart:convert';

import 'package:dio/dio.dart';

import '../data/models/cloud_drive_entities.dart';
import '../infrastructure/error/recovery_strategies.dart';
import '../infrastructure/performance/performance_metrics.dart';

/// 网络相关工具（Dio 创建、请求包装、性能记录）。
class NetworkUtils {
  NetworkUtils._();

  static final PerformanceMetrics _metrics = PerformanceMetrics();

  static Dio createDio({
    required CloudDriveAccount account,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, String>? defaultHeaders,
    List<Interceptor>? extraInterceptors,
  }) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        sendTimeout: sendTimeout ?? const Duration(seconds: 30),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json, text/plain, */*',
          'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Cache-Control': 'no-cache',
          ...account.authHeaders,
          ...?defaultHeaders,
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );

    if (extraInterceptors != null && extraInterceptors.isNotEmpty) {
      dio.interceptors.addAll(extraInterceptors);
    }
    return dio;
  }

  /// 统一的API请求方法，带错误恢复和性能记录。
  static Future<Response<T>> apiRequest<T>({
    required Dio dio,
    required String method,
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Duration? timeout,
    String? operationId,
  }) async {
    final startTime = DateTime.now();
    final opId =
        operationId ?? '${method.toUpperCase()}_${Uri.parse(url).path}';

    try {
      final opts = Options(
        headers: headers,
        sendTimeout: timeout,
        receiveTimeout: timeout,
      );
      final response = await RecoveryStrategies.apiCall(
        operationId: opId,
        operation: () async {
          switch (method.toUpperCase()) {
            case 'GET':
              return await dio.get<T>(
                url,
                queryParameters: queryParameters,
                options: opts,
              );
            case 'POST':
              return await dio.post<T>(
                url,
                data: data,
                queryParameters: queryParameters,
                options: opts,
              );
            case 'PUT':
              return await dio.put<T>(
                url,
                data: data,
                queryParameters: queryParameters,
                options: opts,
              );
            case 'DELETE':
              return await dio.delete<T>(
                url,
                data: data,
                queryParameters: queryParameters,
                options: opts,
              );
            default:
              throw ArgumentError('Unsupported HTTP method: $method');
          }
        },
        context: {
          'url': url,
          'method': method,
          'has_data': data != null,
          'has_query': queryParameters != null,
        },
      );

      _metrics.recordApiCall(
        endpoint: url,
        method: method,
        duration: DateTime.now().difference(startTime),
        statusCode: response.statusCode,
        responseSize: response.data?.toString().length,
      );

      return response;
    } catch (error) {
      _metrics.recordApiCall(
        endpoint: url,
        method: method,
        duration: DateTime.now().difference(startTime),
        error: error.toString(),
      );
      rethrow;
    }
  }

  /// 统一解析响应为 Map 的小助手
  static Map<String, dynamic> decodeResponseData(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    throw Exception('Invalid response format');
  }
}
