/// 夸克云盘文件列表请求
class QuarkFileListRequest {
  /// 父文件夹ID
  final String parentFolderId;

  /// 页码（从1开始）
  final int page;

  /// 每页数量
  final int pageSize;

  /// 排序方式
  final String sort;

  /// 是否获取总数
  final bool fetchTotal;

  /// 是否获取子目录信息
  final bool fetchSubDirs;

  const QuarkFileListRequest({
    required this.parentFolderId,
    this.page = 1,
    this.pageSize = 50,
    this.sort = 'file_type:asc,updated_at:desc',
    this.fetchTotal = true,
    this.fetchSubDirs = false,
  });

  /// 转换为API查询参数
  Map<String, String> toQueryParameters() => {
    'pr': 'ucpro',
    'fr': 'pc',
    'uc_param_str': '',
    'pdir_fid': parentFolderId,
    '_page': page.toString(),
    '_size': pageSize.toString(),
    '_fetch_total': fetchTotal ? '1' : '0',
    '_fetch_sub_dirs': fetchSubDirs ? '1' : '0',
    '_sort': sort,
  };

  @override
  String toString() =>
      'QuarkFileListRequest('
      'parentFolderId: $parentFolderId, '
      'page: $page, '
      'pageSize: $pageSize)';
}
