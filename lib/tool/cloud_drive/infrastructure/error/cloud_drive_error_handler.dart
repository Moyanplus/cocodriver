import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../core/result.dart';

/// 云盘错误处理器 - 使用 Result 模式
class CloudDriveErrorHandler {
  /// 处理错误
  static void handleError(CloudDriveException error) {
    LogManager().cloudDrive('云盘错误: ${error.message}');

    LogManager().cloudDrive(
      '错误详情: 类型=${error.type}, 操作=${error.operation ?? '未知'}',
    );

    if (error.statusCode != null) {
      LogManager().cloudDrive('状态码: ${error.statusCode}');
    }

    if (error.requestId != null) {
      LogManager().cloudDrive('请求ID: ${error.requestId}');
    }

    if (error.context != null) {
      LogManager().cloudDrive('上下文: ${error.context}');
    }
  }

  /// 处理 Result 错误
  static void handleResultError<T>(Result<T> result, String operation) {
    if (result.isFailure) {
      final error = result.errorDetail;
      LogManager().error('$operation 失败: ${result.error}');

      if (error != null) {
        LogManager().cloudDrive('错误类型: ${error.type}');
        LogManager().cloudDrive('操作: ${error.operation ?? operation}');

        if (error.statusCode != null) {
          LogManager().cloudDrive('状态码: ${error.statusCode}');
        }

        if (error.context != null) {
          LogManager().cloudDrive('上下文: ${error.context}');
        }
      }
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

  /// 从 Result 创建错误信息
  static String createResultErrorMessage<T>(Result<T> result) {
    if (result.isSuccess) {
      return '';
    }

    final error = result.errorDetail;
    if (error != null) {
      return error.userFriendlyMessage;
    }

    return result.error ?? '操作失败';
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
      operation: operation,
      context: context,
      statusCode: statusCode,
      requestId: requestId,
    );
  }
}
