/// 百度网盘文件列表请求
class BaiduListRequest {
  const BaiduListRequest({
    required this.folderId,
    this.page = 1,
    this.pageSize = 50,
  });

  /// 目标文件夹 ID
  final String folderId;

  /// 页码
  final int page;

  /// 单页数量
  final int pageSize;
}
