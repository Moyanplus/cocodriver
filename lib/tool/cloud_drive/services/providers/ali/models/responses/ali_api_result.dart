/// 通用的阿里云盘 API 返回结果包装。
class AliApiResult<T> {
  const AliApiResult({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.requestId,
  });

  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
   final String? requestId;

  AliApiResult<R> map<R>(R Function(T data) mapper) {
    if (!success || data == null) {
      return AliApiResult<R>(
        success: success,
        message: message,
        statusCode: statusCode,
        requestId: requestId,
      );
    }
    return AliApiResult<R>(
      success: true,
      data: mapper(data as T),
      statusCode: statusCode,
      requestId: requestId,
    );
  }

  AliApiResult<T> copyWith({
    bool? success,
    T? data,
    String? message,
    int? statusCode,
    String? requestId,
  }) {
    return AliApiResult<T>(
      success: success ?? this.success,
      data: data ?? this.data,
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      requestId: requestId ?? this.requestId,
    );
  }
}
