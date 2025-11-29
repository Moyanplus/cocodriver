/// 阿里云盘文件列表请求
class AliListRequest {
  AliListRequest({
    required this.parentFileId,
    this.page = 1,
    this.pageSize = 50,
  });

  final String parentFileId;
  final int page;
  final int pageSize;
}
