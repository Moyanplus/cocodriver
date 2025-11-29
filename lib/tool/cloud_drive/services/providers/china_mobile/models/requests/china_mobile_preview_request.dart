import 'china_mobile_request.dart';

/// 视频/媒体预览请求
class ChinaMobilePreviewRequest implements ChinaMobileRequest {
  const ChinaMobilePreviewRequest({
    required this.fileId,
    required this.category,
  });

  /// 文件 ID
  final String fileId;

  /// 分类（如 video）
  final String category;

  @override
  Map<String, dynamic> toRequestBody() => {
    'fileId': fileId,
    'category': category,
  };
}
