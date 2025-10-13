import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/error_handler.dart';
import '../error/exceptions.dart';

/// 网络拦截器
/// 处理请求和响应的通用逻辑
class NetworkInterceptor extends Interceptor {
  final ErrorHandler _errorHandler = ErrorHandler();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('🚀 Request: ${options.method} ${options.uri}');
      print('📤 Headers: ${options.headers}');
      if (options.data != null) {
        print('📦 Data: ${options.data}');
      }
    }

    // 添加通用请求头
    _addCommonHeaders(options);

    // 添加认证token
    _addAuthToken(options);

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print(
        '✅ Response: ${response.statusCode} ${response.requestOptions.uri}',
      );
      print('📥 Data: ${response.data}');
    }

    // 检查响应状态
    if (response.statusCode != null && response.statusCode! >= 400) {
      final failure = _errorHandler.handleException(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );

      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: failure,
        ),
      );
      return;
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('❌ Error: ${err.type} ${err.requestOptions.uri}');
      print('💥 Message: ${err.message}');
      if (err.response != null) {
        print('📥 Response: ${err.response?.data}');
      }
    }

    // 处理网络错误
    final failure = _errorHandler.handleException(err);

    // 创建新的DioException，包含Failure信息
    final newError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: failure,
      message: failure.message,
    );

    super.onError(newError, handler);
  }

  /// 添加通用请求头
  void _addCommonHeaders(RequestOptions options) {
    options.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Flutter-UI-Template/1.0.0',
    });
  }

  /// 添加认证token
  void _addAuthToken(RequestOptions options) {
    // 这里可以从本地存储或状态管理中获取token
    // 示例实现
    const token = 'your-auth-token'; // 实际应该从存储中获取

    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
  }
}

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] == null) {
      err.requestOptions.extra['retryCount'] = 0;
    }

    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      if (kDebugMode) {
        print(
          '🔄 Retrying request (${retryCount + 1}/$maxRetries): ${err.requestOptions.uri}',
        );
      }

      // 等待重试延迟
      await Future.delayed(retryDelay * (retryCount + 1));

      try {
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        if (e is DioException) {
          super.onError(e, handler);
          return;
        }
      }
    }

    super.onError(err, handler);
  }

  /// 判断是否应该重试
  bool _shouldRetry(DioException err) {
    // 网络错误和5xx服务器错误可以重试
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // 5xx服务器错误可以重试
    if (err.type == DioExceptionType.badResponse) {
      final statusCode = err.response?.statusCode;
      return statusCode != null && statusCode >= 500;
    }

    return false;
  }
}

/// 日志拦截器
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('''
🚀 REQUEST
Method: ${options.method}
URL: ${options.uri}
Headers: ${options.headers}
Data: ${options.data}
Query Parameters: ${options.queryParameters}
      ''');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('''
✅ RESPONSE
Status Code: ${response.statusCode}
URL: ${response.requestOptions.uri}
Headers: ${response.headers}
Data: ${response.data}
      ''');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('''
❌ ERROR
Type: ${err.type}
Message: ${err.message}
URL: ${err.requestOptions.uri}
Status Code: ${err.response?.statusCode}
Response Data: ${err.response?.data}
      ''');
    }
    super.onError(err, handler);
  }
}
