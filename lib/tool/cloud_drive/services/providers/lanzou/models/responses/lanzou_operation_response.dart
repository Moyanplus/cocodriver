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

  /// 原始 info 字段，部分接口会返回字符串提示或 Map 详细数据。
  dynamic get payload => raw['info'];

  /// 蓝奏常用的 text 字段（如创建文件夹返回新 folderId，上传返回文件信息）。
  String? get text => raw['text']?.toString();

  /// 将 payload 转为 Map 便于后续解析（若不是 Map 返回 null）。
  Map<String, dynamic>? get payloadMap =>
      payload is Map<String, dynamic>
          ? Map<String, dynamic>.from(payload as Map<String, dynamic>)
          : null;

  /// 将 payload 转为 List 便于后续解析（若不是 List 返回 null）。
  List<dynamic>? get payloadList =>
      payload is List ? List<dynamic>.from(payload as List) : null;

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
