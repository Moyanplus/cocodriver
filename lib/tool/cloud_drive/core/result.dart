import '../../../../../core/logging/log_manager.dart';

/// 操作结果封装
///
/// 提供统一的错误处理模式，使用 Result 类型封装成功和失败的情况。
sealed class Result<T> {
  const Result();

  /// 检查是否成功
  bool get isSuccess => this is Success<T>;

  /// 检查是否失败
  bool get isFailure => this is Failure<T>;

  /// 获取数据（仅在成功时）
  T? get data => isSuccess ? (this as Success<T>).data : null;

  /// 获取错误信息（仅在失败时）
  String? get error => isFailure ? (this as Failure<T>).error : null;

  /// 获取错误详情（仅在失败时）
  CloudDriveError? get errorDetail =>
      isFailure ? (this as Failure<T>).errorDetail : null;

  /// 当成功时执行回调
  Result<T> onSuccess(void Function(T data) callback) {
    if (isSuccess) {
      callback((this as Success<T>).data);
    }
    return this;
  }

  /// 当失败时执行回调
  Result<T> onFailure(
    void Function(String error, CloudDriveError? errorDetail) callback,
  ) {
    if (isFailure) {
      final failure = this as Failure<T>;
      callback(failure.error, failure.errorDetail);
    }
    return this;
  }

  /// 映射成功的数据
  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess) {
      try {
        return Success(mapper((this as Success<T>).data));
      } catch (e) {
        return Failure('映射失败: $e');
      }
    }
    return Failure(
      (this as Failure<T>).error,
      (this as Failure<T>).errorDetail,
    );
  }

  /// 映射失败的错误
  Result<T> mapError(String Function(String error) mapper) {
    if (isFailure) {
      final failure = this as Failure<T>;
      return Failure(mapper(failure.error), failure.errorDetail);
    }
    return this;
  }

  /// 获取数据或抛出异常
  T getOrThrow() {
    if (isSuccess) {
      return (this as Success<T>).data;
    }
    final failure = this as Failure<T>;
    throw CloudDriveException(
      failure.error,
      failure.errorDetail?.type ?? CloudDriveErrorType.unknown,
    );
  }

  /// 获取数据或返回默认值
  T getOrElse(T defaultValue) {
    return isSuccess ? (this as Success<T>).data : defaultValue;
  }

  /// 获取数据或执行回调获取默认值
  T getOrElseGet(T Function() defaultValueProvider) {
    return isSuccess ? (this as Success<T>).data : defaultValueProvider();
  }
}

/// 成功结果类
class Success<T> extends Result<T> {
  @override
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success($data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// 失败结果类
class Failure<T> extends Result<T> {
  @override
  final String error;
  @override
  final CloudDriveError? errorDetail;

  const Failure(this.error, [this.errorDetail]);

  @override
  String toString() => 'Failure($error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          error == other.error &&
          errorDetail == other.errorDetail;

  @override
  int get hashCode => error.hashCode ^ errorDetail.hashCode;
}

/// 云盘错误类型枚举
enum CloudDriveErrorType {
  /// 网络错误
  network,

  /// 认证错误
  authentication,

  /// 权限错误
  permission,

  /// 参数错误
  invalidParameter,

  /// 文件不存在
  fileNotFound,

  /// 存储空间不足
  storageFull,

  /// 操作不支持
  operationNotSupported,

  /// 文件已存在
  fileExists,

  /// 文件被占用
  fileInUse,

  /// 文件损坏
  fileCorrupted,

  /// 请求频率限制
  rateLimit,

  /// 服务器错误
  serverError,

  /// 客户端错误
  clientError,

  /// 未知错误
  unknown,
}

/// 云盘错误详情类
class CloudDriveError {
  final CloudDriveErrorType type;
  final String message;
  final String? operation;
  final Map<String, dynamic>? context;
  final int? statusCode;
  final String? requestId;

  const CloudDriveError({
    required this.type,
    required this.message,
    this.operation,
    this.context,
    this.statusCode,
    this.requestId,
  });

  /// 获取用户友好的错误消息
  String get userFriendlyMessage {
    switch (type) {
      case CloudDriveErrorType.network:
        return '网络连接失败，请检查网络设置';
      case CloudDriveErrorType.authentication:
        return '登录已过期，请重新登录';
      case CloudDriveErrorType.permission:
        return '没有权限执行此操作';
      case CloudDriveErrorType.invalidParameter:
        return '参数错误，请检查输入';
      case CloudDriveErrorType.fileNotFound:
        return '文件不存在或已被删除';
      case CloudDriveErrorType.storageFull:
        return '存储空间不足';
      case CloudDriveErrorType.operationNotSupported:
        return '此操作暂不支持';
      case CloudDriveErrorType.fileExists:
        return '文件已存在';
      case CloudDriveErrorType.fileInUse:
        return '文件正在被使用，请稍后重试';
      case CloudDriveErrorType.fileCorrupted:
        return '文件已损坏';
      case CloudDriveErrorType.rateLimit:
        return '请求过于频繁，请稍后重试';
      case CloudDriveErrorType.serverError:
        return '服务器错误，请稍后重试';
      case CloudDriveErrorType.clientError:
        return '客户端错误，请检查操作';
      case CloudDriveErrorType.unknown:
        return '未知错误，请稍后重试';
    }
  }

  /// 是否需要重试
  bool get shouldRetry {
    switch (type) {
      case CloudDriveErrorType.network:
      case CloudDriveErrorType.serverError:
      case CloudDriveErrorType.rateLimit:
        return true;
      default:
        return false;
    }
  }

  /// 是否需要重新登录
  bool get requiresReLogin => type == CloudDriveErrorType.authentication;

  @override
  String toString() {
    final operationName = operation ?? '未知操作';
    final statusInfo = statusCode != null ? ' (状态码: $statusCode)' : '';
    final requestInfo = requestId != null ? ' (请求ID: $requestId)' : '';

    return 'CloudDriveError: $operationName - $message (类型: $type)$statusInfo$requestInfo';
  }
}

/// 云盘异常类
class CloudDriveException implements Exception {
  final String message;
  final CloudDriveErrorType type;
  final String? operation;
  final Map<String, dynamic>? context;
  final int? statusCode;
  final String? requestId;

  const CloudDriveException(
    this.message,
    this.type, {
    this.operation,
    this.context,
    this.statusCode,
    this.requestId,
  });

  /// 从错误详情创建异常
  factory CloudDriveException.fromError(CloudDriveError error) =>
      CloudDriveException(
        error.message,
        error.type,
        operation: error.operation,
        context: error.context,
        statusCode: error.statusCode,
        requestId: error.requestId,
      );

  /// 获取用户友好的错误消息
  String get userFriendlyMessage {
    switch (type) {
      case CloudDriveErrorType.network:
        return '网络连接失败，请检查网络设置';
      case CloudDriveErrorType.authentication:
        return '登录已过期，请重新登录';
      case CloudDriveErrorType.permission:
        return '没有权限执行此操作';
      case CloudDriveErrorType.invalidParameter:
        return '参数错误，请检查输入';
      case CloudDriveErrorType.fileNotFound:
        return '文件不存在或已被删除';
      case CloudDriveErrorType.storageFull:
        return '存储空间不足';
      case CloudDriveErrorType.operationNotSupported:
        return '此操作暂不支持';
      case CloudDriveErrorType.fileExists:
        return '文件已存在';
      case CloudDriveErrorType.fileInUse:
        return '文件正在被使用，请稍后重试';
      case CloudDriveErrorType.fileCorrupted:
        return '文件已损坏';
      case CloudDriveErrorType.rateLimit:
        return '请求过于频繁，请稍后重试';
      case CloudDriveErrorType.serverError:
        return '服务器错误，请稍后重试';
      case CloudDriveErrorType.clientError:
        return '客户端错误，请检查操作';
      case CloudDriveErrorType.unknown:
        return '未知错误，请稍后重试';
    }
  }

  /// 是否需要重试
  bool get shouldRetry {
    switch (type) {
      case CloudDriveErrorType.network:
      case CloudDriveErrorType.serverError:
      case CloudDriveErrorType.rateLimit:
        return true;
      default:
        return false;
    }
  }

  /// 是否需要重新登录
  bool get requiresReLogin => type == CloudDriveErrorType.authentication;

  @override
  String toString() {
    final operationName = operation ?? '未知操作';
    final statusInfo = statusCode != null ? ' (状态码: $statusCode)' : '';
    final requestInfo = requestId != null ? ' (请求ID: $requestId)' : '';

    return 'CloudDriveException: $operationName - $message (类型: $type)$statusInfo$requestInfo';
  }
}

/// Result 工具类
///
/// 提供将异步和同步操作包装为 Result 类型的工具方法。
class ResultUtils {
  /// 将异步操作包装为 Result
  static Future<Result<T>> fromAsync<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      final data = await operation();
      return Success(data);
    } catch (e) {
      final error = _createErrorFromException(e, operationName);
      return Failure(error.message, error);
    }
  }

  /// 将同步操作包装为 Result
  static Result<T> fromSync<T>(
    T Function() operation, {
    String? operationName,
  }) {
    try {
      final data = operation();
      return Success(data);
    } catch (e) {
      final error = _createErrorFromException(e, operationName);
      return Failure(error.message, error);
    }
  }

  /// 从异常创建错误
  static CloudDriveError _createErrorFromException(
    dynamic exception,
    String? operationName,
  ) {
    if (exception is CloudDriveException) {
      return CloudDriveError(
        type: exception.type,
        message: exception.message,
        operation: operationName ?? exception.operation,
        context: exception.context,
        statusCode: exception.statusCode,
        requestId: exception.requestId,
      );
    }

    final errorString = exception.toString().toLowerCase();
    CloudDriveErrorType errorType;

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      errorType = CloudDriveErrorType.network;
    } else if (errorString.contains('auth') ||
        errorString.contains('login') ||
        errorString.contains('unauthorized')) {
      errorType = CloudDriveErrorType.authentication;
    } else if (errorString.contains('permission') ||
        errorString.contains('forbidden')) {
      errorType = CloudDriveErrorType.permission;
    } else if (errorString.contains('not found') ||
        errorString.contains('404')) {
      errorType = CloudDriveErrorType.fileNotFound;
    } else if (errorString.contains('server') || errorString.contains('500')) {
      errorType = CloudDriveErrorType.serverError;
    } else {
      errorType = CloudDriveErrorType.unknown;
    }

    return CloudDriveError(
      type: errorType,
      message: exception.toString(),
      operation: operationName,
    );
  }

  /// 记录 Result 操作日志
  static void logResult<T>(
    Result<T> result,
    String operation, {
    Map<String, dynamic>? context,
  }) {
    if (result.isSuccess) {
      LogManager().cloudDrive('$operation 成功');
    } else {
      LogManager().error('$operation 失败: ${result.error}');
      if (context != null) {
        LogManager().cloudDrive('上下文: $context');
      }
    }
  }
}
