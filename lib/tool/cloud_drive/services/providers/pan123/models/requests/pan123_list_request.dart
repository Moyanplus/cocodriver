/// 123 云盘文件列表请求
class Pan123ListRequest {
  const Pan123ListRequest({
    required this.parentId,
    this.page = 1,
    this.pageSize = 100,
    this.searchValue,
  });

  /// 父级目录 ID
  final String parentId;

  /// 页码
  final int page;

  /// 单页数量
  final int pageSize;

  /// 搜索关键词
  final String? searchValue;
}
