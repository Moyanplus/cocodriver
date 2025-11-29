/// 百度网盘通用 API 结果封装。
class BaiduApiResult<T> {
  const BaiduApiResult({
    required this.success,
    this.data,
    this.message,
  });

  /// 是否成功
  final bool success;

  /// 泛型数据
  final T? data;

  /// 返回消息
  final String? message;
}
