/// 夸克云盘下载请求
class QuarkDownloadRequest {
  /// 文件ID列表
  final List<String> fileIds;

  const QuarkDownloadRequest({required this.fileIds});

  /// 转换为API查询参数
  Map<String, String> toQueryParameters() => {
    'pr': 'ucpro',
    'fr': 'pc',
    'uc_param_str': '',
  };

  /// 转换为API请求体
  Map<String, dynamic> toRequestBody() => {'fids': fileIds};

  @override
  String toString() => 'QuarkDownloadRequest(fileIds: ${fileIds.length} files)';
}
