import '../../../../../core/logging/log_manager.dart';

/// 夸克API响应结果封装
///
/// 统一的API响应包装类，提供类型安全和错误处理
/// 使用泛型支持不同的返回类型
class QuarkApiResult<T> {
  /// 操作是否成功
  final bool isSuccess;

  /// 返回的数据（成功时）
  final T? data;

  /// 错误信息（失败时）
  final String? errorMessage;

  /// 错误代码（失败时）
  final String? errorCode;

  /// HTTP状态码
  final int? statusCode;

  /// 原始响应数据（用于调试）
  final dynamic rawResponse;

  const QuarkApiResult._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    this.errorCode,
    this.statusCode,
    this.rawResponse,
  });

  /// 创建成功结果
  factory QuarkApiResult.success(T data, {dynamic rawResponse}) {
    return QuarkApiResult._(
      isSuccess: true,
      data: data,
      rawResponse: rawResponse,
    );
  }

  /// 创建失败结果
  factory QuarkApiResult.failure({
    required String message,
    String? code,
    int? statusCode,
    dynamic rawResponse,
  }) {
    LogManager().cloudDrive('❌ API调用失败: $message (code: $code)');
    return QuarkApiResult._(
      isSuccess: false,
      errorMessage: message,
      errorCode: code,
      statusCode: statusCode,
      rawResponse: rawResponse,
    );
  }

  /// 从异常创建失败结果
  factory QuarkApiResult.fromException(Exception exception) {
    final message = exception.toString();
    LogManager().error('异常: $message');
    return QuarkApiResult.failure(message: message, code: 'EXCEPTION');
  }

  /// 是否失败
  bool get isFailure => !isSuccess;

  /// 获取数据或抛出异常
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw QuarkApiException(
      message: errorMessage ?? '未知错误',
      code: errorCode,
      statusCode: statusCode,
    );
  }

  /// 获取数据或返回默认值
  T getDataOrDefault(T defaultValue) {
    return data ?? defaultValue;
  }

  /// 映射数据
  QuarkApiResult<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        return QuarkApiResult.success(mapper(data as T));
      } catch (e) {
        return QuarkApiResult.failure(
          message: '数据转换失败: $e',
          code: 'MAPPING_ERROR',
        );
      }
    }
    return QuarkApiResult.failure(
      message: errorMessage ?? '操作失败',
      code: errorCode,
      statusCode: statusCode,
    );
  }

  /// 执行成功或失败的回调
  void fold({
    required void Function(T data) onSuccess,
    required void Function(String message) onFailure,
  }) {
    if (isSuccess && data != null) {
      onSuccess(data as T);
    } else {
      onFailure(errorMessage ?? '未知错误');
    }
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'QuarkApiResult.success(data: $data)';
    } else {
      return 'QuarkApiResult.failure(message: $errorMessage, code: $errorCode)';
    }
  }
}

/// 夸克API异常
class QuarkApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic originalError;

  QuarkApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('QuarkApiException: $message');
    if (code != null) buffer.write(' (code: $code)');
    if (statusCode != null) buffer.write(' (status: $statusCode)');
    return buffer.toString();
  }

  /// 是否为网络错误
  bool get isNetworkError =>
      code == 'NETWORK_ERROR' || statusCode == null || statusCode! >= 500;

  /// 是否为认证错误
  bool get isAuthError =>
      code == 'AUTH_ERROR' || statusCode == 401 || statusCode == 403;

  /// 是否为客户端错误
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// 用户友好的错误消息
  String get userFriendlyMessage {
    if (isNetworkError) {
      return '网络连接失败，请检查网络';
    } else if (isAuthError) {
      return '认证失败，请重新登录';
    } else if (isClientError) {
      return message; // 客户端错误通常是业务错误，直接显示
    } else {
      return '操作失败，请稍后重试';
    }
  }
}

/// 夸克API响应解析器
class QuarkResponseParser {
  /// 解析标准API响应
  ///
  /// 夸克API的标准响应格式：
  /// ```json
  /// {
  ///   "code": 0,
  ///   "message": "success",
  ///   "data": {...}
  /// }
  /// ```
  static QuarkApiResult<T> parse<T>({
    required dynamic response,
    required T Function(dynamic data) dataParser,
    int? statusCode,
  }) {
    try {
      // 检查HTTP状态码
      if (statusCode != null && statusCode != 200) {
        return QuarkApiResult.failure(
          message: 'HTTP错误',
          statusCode: statusCode,
          rawResponse: response,
        );
      }

      // 检查响应是否为Map
      if (response is! Map<String, dynamic>) {
        return QuarkApiResult.failure(
          message: '响应格式错误',
          code: 'INVALID_RESPONSE',
          rawResponse: response,
        );
      }

      final responseMap = response;

      // 检查code字段
      final code = responseMap['code'];
      if (code != 0) {
        return QuarkApiResult.failure(
          message: responseMap['message']?.toString() ?? '请求失败',
          code: code?.toString(),
          rawResponse: response,
        );
      }

      // 解析data字段
      final data = responseMap['data'];
      if (data == null) {
        return QuarkApiResult.failure(
          message: '响应数据为空',
          code: 'EMPTY_DATA',
          rawResponse: response,
        );
      }

      // 使用提供的解析器解析数据
      final parsedData = dataParser(data);
      return QuarkApiResult.success(parsedData, rawResponse: response);
    } catch (e, stackTrace) {
      LogManager().error('解析响应失败: $e\n$stackTrace');
      return QuarkApiResult.failure(message: '数据解析失败: $e', code: 'PARSE_ERROR');
    }
  }

  /// 解析列表响应
  static QuarkApiResult<List<T>> parseList<T>({
    required dynamic response,
    required T Function(dynamic item) itemParser,
    required String listKey,
    int? statusCode,
  }) {
    return parse<List<T>>(
      response: response,
      statusCode: statusCode,
      dataParser: (data) {
        if (data is! Map<String, dynamic>) {
          throw QuarkApiException(message: 'data不是Map类型');
        }

        final list = data[listKey];
        if (list == null) {
          return <T>[];
        }

        if (list is! List) {
          throw QuarkApiException(message: '$listKey不是List类型');
        }

        return list
            .map((item) {
              try {
                return itemParser(item);
              } catch (e) {
                LogManager().error('解析列表项失败: $e');
                return null;
              }
            })
            .whereType<T>()
            .toList();
      },
    );
  }
}
