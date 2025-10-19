import '../../../../core/logging/log_manager.dart';
import '../models/cloud_drive_models.dart';

/// 云盘异常类型
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

/// 云盘异常
class CloudDriveException implements Exception {
  final String message;
  final CloudDriveErrorType type;
  final CloudDriveType? cloudDriveType;
  final dynamic originalError;
  final String? operation;
  final Map<String, dynamic>? context;
  final int? statusCode;
  final String? requestId;

  const CloudDriveException(
    this.message,
    this.type, {
    this.cloudDriveType,
    this.originalError,
    this.operation,
    this.context,
    this.statusCode,
    this.requestId,
  });

  @override
  String toString() {
    final typeName = cloudDriveType?.displayName ?? '未知云盘';
    final operationName = operation ?? '未知操作';
    final statusInfo = statusCode != null ? ' (状态码: $statusCode)' : '';
    final requestInfo = requestId != null ? ' (请求ID: $requestId)' : '';

    return 'CloudDriveException: [$typeName] $operationName - $message (类型: $type)$statusInfo$requestInfo';
  }

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
      case CloudDriveErrorType.authentication:
      case CloudDriveErrorType.permission:
      case CloudDriveErrorType.invalidParameter:
      case CloudDriveErrorType.fileNotFound:
      case CloudDriveErrorType.storageFull:
      case CloudDriveErrorType.operationNotSupported:
      case CloudDriveErrorType.fileExists:
      case CloudDriveErrorType.fileInUse:
      case CloudDriveErrorType.fileCorrupted:
      case CloudDriveErrorType.clientError:
      case CloudDriveErrorType.unknown:
        return false;
    }
  }

  /// 是否需要重新登录
  bool get requiresReLogin => type == CloudDriveErrorType.authentication;
}

/// 云盘错误处理器
class CloudDriveErrorHandler {
  /// 处理错误
  static void handleError(CloudDriveException error) {
    LogManager().cloudDrive(
      '❌ 云盘错误: ${error.message}',
      
    );

    LogManager().cloudDrive(
      '📋 错误详情: 类型=${error.type}, 云盘=${error.cloudDriveType?.displayName ?? '未知'}, 操作=${error.operation ?? '未知'}',
      
    );

    if (error.statusCode != null) {
      LogManager().cloudDrive(
        '📊 状态码: ${error.statusCode}',
        
      );
    }

    if (error.requestId != null) {
      LogManager().cloudDrive(
        '🆔 请求ID: ${error.requestId}',
        
      );
    }

    if (error.context != null) {
      LogManager().cloudDrive(
        '📄 上下文: ${error.context}',
        
      );
    }

    if (error.originalError != null) {
      LogManager().cloudDrive(
        '🔍 原始错误: ${error.originalError}',
        
      );
    }
  }

  /// 从异常创建错误信息
  static String createErrorMessage(
    dynamic error,
    CloudDriveType? cloudDriveType,
    String? operation,
  ) {
    if (error is CloudDriveException) {
      return error.userFriendlyMessage;
    }

    final errorMessage = error.toString();
    final typeName = cloudDriveType?.displayName ?? '未知云盘';
    final operationName = operation ?? '未知操作';

    return '[$typeName] $operationName 失败: $errorMessage';
  }

  /// 判断是否为网络错误
  static bool isNetworkError(dynamic error) {
    if (error is CloudDriveException) {
      return error.type == CloudDriveErrorType.network;
    }

    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket') ||
        errorString.contains('dns') ||
        errorString.contains('host');
  }

  /// 判断是否为认证错误
  static bool isAuthenticationError(dynamic error) {
    if (error is CloudDriveException) {
      return error.type == CloudDriveErrorType.authentication;
    }

    final errorString = error.toString().toLowerCase();
    return errorString.contains('auth') ||
        errorString.contains('login') ||
        errorString.contains('token') ||
        errorString.contains('unauthorized') ||
        errorString.contains('401') ||
        errorString.contains('expired');
  }

  /// 判断是否为权限错误
  static bool isPermissionError(dynamic error) {
    if (error is CloudDriveException) {
      return error.type == CloudDriveErrorType.permission;
    }

    final errorString = error.toString().toLowerCase();
    return errorString.contains('permission') ||
        errorString.contains('forbidden') ||
        errorString.contains('403') ||
        errorString.contains('denied');
  }

  /// 判断是否为服务器错误
  static bool isServerError(dynamic error) {
    if (error is CloudDriveException) {
      return error.type == CloudDriveErrorType.serverError;
    }

    final errorString = error.toString().toLowerCase();
    return errorString.contains('server') ||
        errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504');
  }

  /// 判断是否为客户端错误
  static bool isClientError(dynamic error) {
    if (error is CloudDriveException) {
      return error.type == CloudDriveErrorType.clientError;
    }

    final errorString = error.toString().toLowerCase();
    return errorString.contains('client') ||
        errorString.contains('400') ||
        errorString.contains('bad request') ||
        errorString.contains('invalid');
  }

  /// 判断是否需要重试
  static bool shouldRetry(dynamic error) {
    if (error is CloudDriveException) {
      return error.shouldRetry;
    }

    return isNetworkError(error) || isServerError(error);
  }

  /// 判断是否需要重新登录
  static bool requiresReLogin(dynamic error) {
    if (error is CloudDriveException) {
      return error.requiresReLogin;
    }

    return isAuthenticationError(error);
  }

  /// 创建网络错误
  static CloudDriveException createNetworkError(
    String message, {
    CloudDriveType? cloudDriveType,
    String? operation,
    dynamic originalError,
    Map<String, dynamic>? context,
    int? statusCode,
    String? requestId,
  }) => CloudDriveException(
    message,
    CloudDriveErrorType.network,
    cloudDriveType: cloudDriveType,
    originalError: originalError,
    operation: operation,
    context: context,
    statusCode: statusCode,
    requestId: requestId,
  );

  /// 创建认证错误
  static CloudDriveException createAuthenticationError(
    String message, {
    CloudDriveType? cloudDriveType,
    String? operation,
    dynamic originalError,
    Map<String, dynamic>? context,
    int? statusCode,
    String? requestId,
  }) => CloudDriveException(
    message,
    CloudDriveErrorType.authentication,
    cloudDriveType: cloudDriveType,
    originalError: originalError,
    operation: operation,
    context: context,
    statusCode: statusCode,
    requestId: requestId,
  );

  /// 创建权限错误
  static CloudDriveException createPermissionError(
    String message, {
    CloudDriveType? cloudDriveType,
    String? operation,
    dynamic originalError,
    Map<String, dynamic>? context,
    int? statusCode,
    String? requestId,
  }) => CloudDriveException(
    message,
    CloudDriveErrorType.permission,
    cloudDriveType: cloudDriveType,
    originalError: originalError,
    operation: operation,
    context: context,
    statusCode: statusCode,
    requestId: requestId,
  );

  /// 创建参数错误
  static CloudDriveException createParameterError(
    String message, {
    CloudDriveType? cloudDriveType,
    String? operation,
    dynamic originalError,
    Map<String, dynamic>? context,
    int? statusCode,
    String? requestId,
  }) => CloudDriveException(
    message,
    CloudDriveErrorType.invalidParameter,
    cloudDriveType: cloudDriveType,
    originalError: originalError,
    operation: operation,
    context: context,
    statusCode: statusCode,
    requestId: requestId,
  );

  /// 创建文件不存在错误
  static CloudDriveException createFileNotFoundError(
    String message, {
    CloudDriveType? cloudDriveType,
    String? operation,
    dynamic originalError,
    Map<String, dynamic>? context,
    int? statusCode,
    String? requestId,
  }) => CloudDriveException(
    message,
    CloudDriveErrorType.fileNotFound,
    cloudDriveType: cloudDriveType,
    originalError: originalError,
    operation: operation,
    context: context,
    statusCode: statusCode,
    requestId: requestId,
  );

  /// 创建存储空间不足错误
  static CloudDriveException createStorageFullError(
    String message, {
    CloudDriveType? cloudDriveType,
    String? operation,
    dynamic originalError,
    Map<String, dynamic>? context,
    int? statusCode,
    String? requestId,
  }) => CloudDriveException(
    message,
    CloudDriveErrorType.storageFull,
    cloudDriveType: cloudDriveType,
    originalError: originalError,
    operation: operation,
    context: context,
    statusCode: statusCode,
    requestId: requestId,
  );

  /// 创建操作不支持错误
  static CloudDriveException createOperationNotSupportedError(
    String message, {
    CloudDriveType? cloudDriveType,
    String? operation,
    dynamic originalError,
    Map<String, dynamic>? context,
    int? statusCode,
    String? requestId,
  }) => CloudDriveException(
    message,
    CloudDriveErrorType.operationNotSupported,
    cloudDriveType: cloudDriveType,
    originalError: originalError,
    operation: operation,
    context: context,
    statusCode: statusCode,
    requestId: requestId,
  );

  /// 创建服务器错误
  static CloudDriveException createServerError(
    String message, {
    CloudDriveType? cloudDriveType,
    String? operation,
    dynamic originalError,
    Map<String, dynamic>? context,
    int? statusCode,
    String? requestId,
  }) => CloudDriveException(
    message,
    CloudDriveErrorType.serverError,
    cloudDriveType: cloudDriveType,
    originalError: originalError,
    operation: operation,
    context: context,
    statusCode: statusCode,
    requestId: requestId,
  );

  /// 创建客户端错误
  static CloudDriveException createClientError(
    String message, {
    CloudDriveType? cloudDriveType,
    String? operation,
    dynamic originalError,
    Map<String, dynamic>? context,
    int? statusCode,
    String? requestId,
  }) => CloudDriveException(
    message,
    CloudDriveErrorType.clientError,
    cloudDriveType: cloudDriveType,
    originalError: originalError,
    operation: operation,
    context: context,
    statusCode: statusCode,
    requestId: requestId,
  );

  /// 创建未知错误
  static CloudDriveException createUnknownError(
    String message, {
    CloudDriveType? cloudDriveType,
    String? operation,
    dynamic originalError,
    Map<String, dynamic>? context,
    int? statusCode,
    String? requestId,
  }) => CloudDriveException(
    message,
    CloudDriveErrorType.unknown,
    cloudDriveType: cloudDriveType,
    originalError: originalError,
    operation: operation,
    context: context,
    statusCode: statusCode,
    requestId: requestId,
  );

  /// 根据HTTP状态码创建错误
  static CloudDriveException createFromStatusCode(
    int statusCode,
    String message, {
    CloudDriveType? cloudDriveType,
    String? operation,
    dynamic originalError,
    Map<String, dynamic>? context,
    String? requestId,
  }) {
    CloudDriveErrorType errorType;

    if (statusCode >= 500) {
      errorType = CloudDriveErrorType.serverError;
    } else if (statusCode == 401) {
      errorType = CloudDriveErrorType.authentication;
    } else if (statusCode == 403) {
      errorType = CloudDriveErrorType.permission;
    } else if (statusCode == 404) {
      errorType = CloudDriveErrorType.fileNotFound;
    } else if (statusCode == 409) {
      errorType = CloudDriveErrorType.fileExists;
    } else if (statusCode == 413) {
      errorType = CloudDriveErrorType.storageFull;
    } else if (statusCode == 429) {
      errorType = CloudDriveErrorType.rateLimit;
    } else if (statusCode >= 400) {
      errorType = CloudDriveErrorType.clientError;
    } else {
      errorType = CloudDriveErrorType.unknown;
    }

    return CloudDriveException(
      message,
      errorType,
      cloudDriveType: cloudDriveType,
      originalError: originalError,
      operation: operation,
      context: context,
      statusCode: statusCode,
      requestId: requestId,
    );
  }
}
