/// 夸克云盘下载响应
class QuarkDownloadResponse {
  /// 文件ID
  final String fileId;

  /// 下载链接
  final String downloadUrl;

  const QuarkDownloadResponse({
    required this.fileId,
    required this.downloadUrl,
  });

  /// 从API响应解析
  factory QuarkDownloadResponse.fromJson(Map<String, dynamic> json) {
    return QuarkDownloadResponse(
      fileId: json['fid'] as String,
      downloadUrl: json['download_url'] as String,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {'fid': fileId, 'download_url': downloadUrl};

  @override
  String toString() =>
      'QuarkDownloadResponse('
      'fileId: $fileId, '
      'downloadUrl: ${downloadUrl.length > 50 ? '${downloadUrl.substring(0, 50)}...' : downloadUrl})';
}

/// 夸克云盘批量下载响应
class QuarkBatchDownloadResponse {
  /// 文件ID到下载链接的映射
  final Map<String, String> downloadUrls;

  const QuarkBatchDownloadResponse({required this.downloadUrls});

  /// 从API响应列表解析
  factory QuarkBatchDownloadResponse.fromJsonList(List<dynamic> jsonList) {
    final urls = <String, String>{};

    for (final item in jsonList) {
      if (item is Map<String, dynamic>) {
        final fid = item['fid'] as String?;
        final downloadUrl = item['download_url'] as String?;

        if (fid != null && downloadUrl != null && downloadUrl.isNotEmpty) {
          urls[fid] = downloadUrl;
        }
      }
    }

    return QuarkBatchDownloadResponse(downloadUrls: urls);
  }

  /// 获取指定文件的下载链接
  String? getDownloadUrl(String fileId) => downloadUrls[fileId];

  /// 是否包含指定文件的下载链接
  bool hasDownloadUrl(String fileId) => downloadUrls.containsKey(fileId);

  /// 下载链接数量
  int get count => downloadUrls.length;

  @override
  String toString() => 'QuarkBatchDownloadResponse(count: $count)';
}
