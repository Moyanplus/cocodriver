import 'china_mobile_request.dart';

/// 中国移动云盘下载请求
class ChinaMobileDownloadRequest implements ChinaMobileRequest {
  /// 文件ID
  final String fileId;

  const ChinaMobileDownloadRequest({required this.fileId});

  /// 转换为请求体
  @override
  Map<String, dynamic> toRequestBody() => {'fileId': fileId};

  @override
  String toString() => 'ChinaMobileDownloadRequest(fileId: $fileId)';
}
