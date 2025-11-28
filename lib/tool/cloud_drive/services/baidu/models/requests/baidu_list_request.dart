/// 百度网盘文件列表请求
class BaiduListRequest {
  const BaiduListRequest({
    required this.folderId,
    this.page = 1,
    this.pageSize = 50,
  });

  final String folderId;
  final int page;
  final int pageSize;
}
