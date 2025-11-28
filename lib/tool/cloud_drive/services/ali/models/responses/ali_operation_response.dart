/// 阿里云盘通用操作响应
class AliOperationResponse {
  const AliOperationResponse({required this.success, this.message});

  final bool success;
  final String? message;
}
