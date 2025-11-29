/// 百度网盘通用 API 结果封装。
class BaiduApiResult<T> {
  const BaiduApiResult({
    required this.success,
    this.data,
    this.message,
  });

  final bool success;
  final T? data;
  final String? message;
}
