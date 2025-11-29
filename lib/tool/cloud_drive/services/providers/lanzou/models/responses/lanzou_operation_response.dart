/// 通用操作响应（删除/重命名/创建文件夹等）。
class LanzouOperationResponse {
  const LanzouOperationResponse({
    required this.success,
    this.message,
    required this.raw,
  });

  final bool success;
  final String? message;
  final Map<String, dynamic> raw;

  dynamic get payload => raw['info'];

  factory LanzouOperationResponse.fromMap(Map<String, dynamic> map) =>
      LanzouOperationResponse(
        success: (map['zt'] ?? 0) == 1,
        message: map['info'] is String ? map['info'] as String? : null,
        raw: Map<String, dynamic>.from(map),
      );
}

/// 文件详情响应
class LanzouFileDetailResponse {
  const LanzouFileDetailResponse({
    required this.success,
    this.message,
    this.detail,
  });

  final bool success;
  final String? message;
  final Map<String, dynamic>? detail;

  factory LanzouFileDetailResponse.fromOperation(
    LanzouOperationResponse response,
  ) =>
      LanzouFileDetailResponse(
        success: response.success,
        message: response.message,
        detail:
            response.payload is Map<String, dynamic>
                ? Map<String, dynamic>.from(
                  response.payload as Map<String, dynamic>,
                )
                : null,
      );
}
