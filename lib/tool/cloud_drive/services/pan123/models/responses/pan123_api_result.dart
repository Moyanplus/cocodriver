/// 123 云盘通用 API 结果包装。
class Pan123ApiResult<T> {
  const Pan123ApiResult({
    required this.success,
    this.data,
    this.message,
  });

  final bool success;
  final T? data;
  final String? message;
}
