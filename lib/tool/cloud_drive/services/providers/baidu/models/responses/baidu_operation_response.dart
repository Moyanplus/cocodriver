/// 百度网盘操作响应
class BaiduOperationResponse {
  const BaiduOperationResponse({required this.success, this.message});

  /// 是否成功
  final bool success;

  /// 返回消息
  final String? message;
}
