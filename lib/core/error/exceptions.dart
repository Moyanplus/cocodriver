/// 应用异常基类
abstract class AppException implements Exception {
  final String message;
  final String? errorCode;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.errorCode,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message';
}

/// 网络异常
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required super.message,
    this.statusCode,
    super.errorCode,
    super.originalError,
  });

  @override
  String toString() => 'NetworkException: $message (Status: $statusCode)';
}

/// 服务器异常
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    this.statusCode,
    super.errorCode,
    super.originalError,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// 缓存异常
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.errorCode,
    super.originalError,
  });

  @override
  String toString() => 'CacheException: $message';
}

/// 存储异常
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.errorCode,
    super.originalError,
  });

  @override
  String toString() => 'StorageException: $message';
}

/// 验证异常
class ValidationException extends AppException {
  final String? field;

  const ValidationException({
    required super.message,
    this.field,
    super.errorCode,
    super.originalError,
  });

  @override
  String toString() => 'ValidationException: $message (Field: $field)';
}

/// 权限异常
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.errorCode,
    super.originalError,
  });

  @override
  String toString() => 'PermissionException: $message';
}

/// 未知异常
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.errorCode,
    super.originalError,
  });

  @override
  String toString() => 'UnknownException: $message';
}
