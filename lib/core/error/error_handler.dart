import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'exceptions.dart';
import 'failures.dart';
import '../logging/log_manager.dart';
import '../logging/log_category.dart';

/// 错误处理器
/// 负责将各种异常转换为统一的Failure对象
class ErrorHandler {
  static const ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  const ErrorHandler._internal();

  /// 处理异常并转换为Failure
  Failure handleException(dynamic exception) {
    // 记录错误日志
    LogManager().error(
      '处理异常: ${exception.toString()}',
      category: LogCategory.error,
      className: 'ErrorHandler',
      methodName: 'handleException',
      exception: exception,
    );

    if (kDebugMode) {
      print('ErrorHandler: Handling exception: $exception');
    }

    if (exception is DioException) {
      return _handleDioException(exception);
    }

    if (exception is AppException) {
      return _handleAppException(exception);
    }

    if (exception is SocketException) {
      return const Failure.network(
        message: '网络连接失败，请检查网络设置',
        errorCode: 'NO_INTERNET',
      );
    }

    if (exception is HttpException) {
      return Failure.network(
        message: 'HTTP错误: ${exception.message}',
        errorCode: 'HTTP_ERROR',
      );
    }

    if (exception is FormatException) {
      return const Failure.validation(
        message: '数据格式错误',
        errorCode: 'FORMAT_ERROR',
      );
    }

    // 处理其他类型的异常
    return Failure.unknown(
      message: exception?.toString() ?? '未知错误',
      errorCode: 'UNKNOWN_ERROR',
    );
  }

  /// 处理Dio异常
  Failure _handleDioException(DioException exception) {
    // 记录网络错误日志
    LogManager().error(
      'Dio异常: ${exception.type} - ${exception.message}',
      category: LogCategory.network,
      className: 'ErrorHandler',
      methodName: '_handleDioException',
      data: {
        'type': exception.type.toString(),
        'message': exception.message,
        'statusCode': exception.response?.statusCode,
        'url': exception.requestOptions.uri.toString(),
      },
      exception: exception,
    );

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const Failure.network(
          message: '请求超时，请检查网络连接',
          errorCode: 'TIMEOUT',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(exception);

      case DioExceptionType.cancel:
        return const Failure.network(message: '请求已取消', errorCode: 'CANCELLED');

      case DioExceptionType.connectionError:
        return const Failure.network(
          message: '网络连接错误',
          errorCode: 'CONNECTION_ERROR',
        );

      case DioExceptionType.badCertificate:
        return const Failure.network(
          message: '证书验证失败',
          errorCode: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.unknown:
        return Failure.unknown(
          message: exception.message ?? '未知网络错误',
          errorCode: 'UNKNOWN_NETWORK_ERROR',
        );
    }
  }

  /// 处理错误响应
  Failure _handleBadResponse(DioException exception) {
    final response = exception.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    // 尝试从响应中提取错误信息
    String message = '请求失败';
    String? errorCode;

    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
      errorCode = data['code'] ?? data['errorCode'];
    }

    // 根据状态码确定失败类型
    if (statusCode != null) {
      if (statusCode >= 400 && statusCode < 500) {
        return Failure.network(
          message: message,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      } else if (statusCode >= 500) {
        return Failure.server(
          message: message,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      }
    }

    return Failure.network(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
    );
  }

  /// 处理应用异常
  Failure _handleAppException(AppException exception) {
    if (exception is NetworkException) {
      return Failure.network(
        message: exception.message,
        statusCode: exception.statusCode,
        errorCode: exception.errorCode,
      );
    }

    if (exception is ServerException) {
      return Failure.server(
        message: exception.message,
        statusCode: exception.statusCode,
        errorCode: exception.errorCode,
      );
    }

    if (exception is CacheException) {
      return Failure.cache(
        message: exception.message,
        errorCode: exception.errorCode,
      );
    }

    if (exception is StorageException) {
      return Failure.storage(
        message: exception.message,
        errorCode: exception.errorCode,
      );
    }

    if (exception is ValidationException) {
      return Failure.validation(
        message: exception.message,
        field: exception.field,
        errorCode: exception.errorCode,
      );
    }

    if (exception is PermissionException) {
      return Failure.permission(
        message: exception.message,
        errorCode: exception.errorCode,
      );
    }

    if (exception is UnknownException) {
      return Failure.unknown(
        message: exception.message,
        errorCode: exception.errorCode,
      );
    }

    return Failure.unknown(
      message: exception.message,
      errorCode: exception.errorCode,
    );
  }

  /// 创建网络异常
  static NetworkException createNetworkException({
    required String message,
    int? statusCode,
    String? errorCode,
    dynamic originalError,
  }) {
    return NetworkException(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      originalError: originalError,
    );
  }

  /// 创建服务器异常
  static ServerException createServerException({
    required String message,
    int? statusCode,
    String? errorCode,
    dynamic originalError,
  }) {
    return ServerException(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      originalError: originalError,
    );
  }

  /// 创建缓存异常
  static CacheException createCacheException({
    required String message,
    String? errorCode,
    dynamic originalError,
  }) {
    return CacheException(
      message: message,
      errorCode: errorCode,
      originalError: originalError,
    );
  }

  /// 创建存储异常
  static StorageException createStorageException({
    required String message,
    String? errorCode,
    dynamic originalError,
  }) {
    return StorageException(
      message: message,
      errorCode: errorCode,
      originalError: originalError,
    );
  }

  /// 创建验证异常
  static ValidationException createValidationException({
    required String message,
    String? field,
    String? errorCode,
    dynamic originalError,
  }) {
    return ValidationException(
      message: message,
      field: field,
      errorCode: errorCode,
      originalError: originalError,
    );
  }

  /// 创建权限异常
  static PermissionException createPermissionException({
    required String message,
    String? errorCode,
    dynamic originalError,
  }) {
    return PermissionException(
      message: message,
      errorCode: errorCode,
      originalError: originalError,
    );
  }

  /// 创建未知异常
  static UnknownException createUnknownException({
    required String message,
    String? errorCode,
    dynamic originalError,
  }) {
    return UnknownException(
      message: message,
      errorCode: errorCode,
      originalError: originalError,
    );
  }
}
