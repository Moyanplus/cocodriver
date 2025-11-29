/// 文件上传响应
class LanzouUploadResponse {
  const LanzouUploadResponse({
    required this.success,
    this.message,
    this.file,
  });

  final bool success;
  final String? message;
  final LanzouUploadedFileInfo? file;

  Map<String, dynamic> toMap() => {
        'success': success,
        'message': message,
        if (file != null) 'file': file!.toMap(),
      };

  factory LanzouUploadResponse.fromMap(Map<String, dynamic> map) {
    final text = map['text'];
    LanzouUploadedFileInfo? file;
    if (text is List && text.isNotEmpty && text.first is Map<String, dynamic>) {
      file = LanzouUploadedFileInfo.fromMap(
        Map<String, dynamic>.from(text.first as Map),
      );
    }
    return LanzouUploadResponse(
      success: (map['zt'] ?? 0) == 1,
      message: map['info']?.toString(),
      file: file,
    );
  }
}

class LanzouUploadedFileInfo {
  const LanzouUploadedFileInfo({
    required this.raw,
  });

  final Map<String, dynamic> raw;

  String? get id => raw['id']?.toString();
  String? get name => raw['name']?.toString();

  Map<String, dynamic> toMap() => Map<String, dynamic>.from(raw);

  factory LanzouUploadedFileInfo.fromMap(Map<String, dynamic> map) =>
      LanzouUploadedFileInfo(raw: map);
}
