import 'china_mobile_request.dart';

/// 中国移动云盘文件列表请求
class ChinaMobileFileListRequest implements ChinaMobileRequest {
  /// 父文件夹ID
  final String parentFileId;

  /// 页面信息
  final PageInfo pageInfo;

  /// 排序字段
  final String orderBy;

  /// 排序方向
  final String orderDirection;

  /// 图片缩略图样式列表
  final List<String> imageThumbnailStyleList;

  const ChinaMobileFileListRequest({
    required this.parentFileId,
    required this.pageInfo,
    this.orderBy = 'updated_at',
    this.orderDirection = 'DESC',
    this.imageThumbnailStyleList = const ['Small', 'Large'],
  });

  /// 转换为请求体
  @override
  Map<String, dynamic> toRequestBody() => {
    'pageInfo': pageInfo.toJson(),
    'orderBy': orderBy,
    'orderDirection': orderDirection,
    'parentFileId': parentFileId,
    'imageThumbnailStyleList': imageThumbnailStyleList,
  };

  @override
  String toString() =>
      'ChinaMobileFileListRequest('
      'parentFileId: $parentFileId, '
      'pageInfo: $pageInfo)';
}

/// 分页信息
class PageInfo {
  /// 页面大小
  final int pageSize;

  /// 页面游标（下一页的标识）
  final String? pageCursor;

  const PageInfo({this.pageSize = 100, this.pageCursor});

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'pageSize': pageSize,
    'pageCursor': pageCursor,
  };

  @override
  String toString() => 'PageInfo(pageSize: $pageSize, pageCursor: $pageCursor)';
}
