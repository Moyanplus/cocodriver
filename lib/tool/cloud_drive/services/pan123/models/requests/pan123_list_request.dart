/// 123 云盘文件列表请求
class Pan123ListRequest {
  const Pan123ListRequest({
    required this.parentId,
    this.page = 1,
    this.pageSize = 100,
    this.searchValue,
  });

  final String parentId;
  final int page;
  final int pageSize;
  final String? searchValue;
}
