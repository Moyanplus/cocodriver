/// 中国移动云盘通用响应基类
class ChinaMobileBaseResponse {
  /// 请求是否成功（按 code 判定）
  final bool isSuccess;

  /// 原始状态码
  final String? code;

  /// 提示信息
  final String? message;

  /// data 字段（如果存在且为 Map）
  final Map<String, dynamic>? data;

  const ChinaMobileBaseResponse({
    required this.isSuccess,
    this.code,
    this.message,
    this.data,
  });

  factory ChinaMobileBaseResponse.fromJson(Map<String, dynamic> json) {
    final code = json['code']?.toString();
    final success = json['success'] as bool? ?? code == '0000';
    final data = json['data'] as Map<String, dynamic>?;
    return ChinaMobileBaseResponse(
      isSuccess: success,
      code: code,
      message: json['message']?.toString(),
      data: data,
    );
  }
}
