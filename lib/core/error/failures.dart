import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// 应用失败类型
/// 使用Freezed生成不可变的数据类
@freezed
class Failure with _$Failure {
  /// 网络相关失败
  const factory Failure.network({
    required String message,
    int? statusCode,
    String? errorCode,
  }) = NetworkFailure;

  /// 服务器相关失败
  const factory Failure.server({
    required String message,
    int? statusCode,
    String? errorCode,
  }) = ServerFailure;

  /// 缓存相关失败
  const factory Failure.cache({required String message, String? errorCode}) =
      CacheFailure;

  /// 本地存储相关失败
  const factory Failure.storage({required String message, String? errorCode}) =
      StorageFailure;

  /// 验证相关失败
  const factory Failure.validation({
    required String message,
    String? field,
    String? errorCode,
  }) = ValidationFailure;

  /// 权限相关失败
  const factory Failure.permission({
    required String message,
    String? errorCode,
  }) = PermissionFailure;

  /// 未知失败
  const factory Failure.unknown({required String message, String? errorCode}) =
      UnknownFailure;
}

/// 失败扩展方法
extension FailureExtension on Failure {
  /// 获取用户友好的错误消息
  String get userMessage {
    return when(
      network: (message, statusCode, errorCode) {
        switch (statusCode) {
          case 400:
            return '请求参数错误';
          case 401:
            return '未授权，请重新登录';
          case 403:
            return '权限不足';
          case 404:
            return '请求的资源不存在';
          case 408:
            return '请求超时';
          case 500:
            return '服务器内部错误';
          case 502:
            return '网关错误';
          case 503:
            return '服务暂时不可用';
          default:
            return '网络连接失败，请检查网络设置';
        }
      },
      server: (message, statusCode, errorCode) {
        return '服务器错误：$message';
      },
      cache: (message, errorCode) {
        return '缓存错误：$message';
      },
      storage: (message, errorCode) {
        return '存储错误：$message';
      },
      validation: (message, field, errorCode) {
        return field != null ? '$field: $message' : message;
      },
      permission: (message, errorCode) {
        return '权限错误：$message';
      },
      unknown: (message, errorCode) {
        return '未知错误：$message';
      },
    );
  }

  /// 获取错误代码
  String? get errorCode {
    return when(
      network: (message, statusCode, errorCode) => errorCode,
      server: (message, statusCode, errorCode) => errorCode,
      cache: (message, errorCode) => errorCode,
      storage: (message, errorCode) => errorCode,
      validation: (message, field, errorCode) => errorCode,
      permission: (message, errorCode) => errorCode,
      unknown: (message, errorCode) => errorCode,
    );
  }

  /// 检查是否为网络错误
  bool get isNetworkError {
    return when(
      network: (message, statusCode, errorCode) => true,
      server: (message, statusCode, errorCode) => true,
      cache: (message, errorCode) => false,
      storage: (message, errorCode) => false,
      validation: (message, field, errorCode) => false,
      permission: (message, errorCode) => false,
      unknown: (message, errorCode) => false,
    );
  }

  /// 检查是否为可重试的错误
  bool get isRetryable {
    return when(
      network: (message, statusCode, errorCode) {
        // 网络错误和5xx服务器错误可以重试
        return statusCode == null || statusCode >= 500;
      },
      server: (message, statusCode, errorCode) {
        // 5xx服务器错误可以重试
        return statusCode != null && statusCode >= 500;
      },
      cache: (message, errorCode) => false,
      storage: (message, errorCode) => false,
      validation: (message, field, errorCode) => false,
      permission: (message, errorCode) => false,
      unknown: (message, errorCode) => true, // 未知错误可以重试
    );
  }
}
