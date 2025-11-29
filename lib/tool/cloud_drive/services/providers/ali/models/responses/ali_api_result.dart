/// 通用的阿里云盘 API 返回结果包装。
class AliApiResult<T> {
  const AliApiResult({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  AliApiResult<R> map<R>(R Function(T data) mapper) {
    if (!success || data == null) {
      return AliApiResult<R>(
        success: success,
        message: message,
        statusCode: statusCode,
      );
    }
    return AliApiResult<R>(
      success: true,
      data: mapper(data as T),
      statusCode: statusCode,
    );
  }
}
