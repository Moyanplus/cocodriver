/// 中国移动云盘下载请求
class ChinaMobileDownloadRequest {
  /// 文件ID
  final String fileId;

  const ChinaMobileDownloadRequest({required this.fileId});

  /// 转换为请求体
  Map<String, dynamic> toRequestBody() => {'fileId': fileId};

  @override
  String toString() => 'ChinaMobileDownloadRequest(fileId: $fileId)';
}
