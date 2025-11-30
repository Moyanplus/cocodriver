/// 123 云盘文件列表请求
class Pan123ListRequest {
  const Pan123ListRequest({
    required this.parentId,
    this.page = 1,
    this.pageSize = 100,
    this.searchValue,
    this.trashed = false,
    this.orderBy = 'update_time',
    this.orderDirection = 'desc',
    this.event = 'homeListFile',
    this.next = '0',
  });

  /// 父级目录 ID
  final String parentId;

  /// 页码
  final int page;

  /// 单页数量
  final int pageSize;

  /// 搜索关键词
  final String? searchValue;

  /// 是否查询回收站
  final bool trashed;

  /// 排序字段
  final String orderBy;

  /// 排序方向
  final String orderDirection;

  /// 事件类型（区分回收站/首页）
  final String event;

  /// 下一页游标
  final String next;
}
