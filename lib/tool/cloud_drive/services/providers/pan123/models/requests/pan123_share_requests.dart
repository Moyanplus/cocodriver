import '../../api/pan123_base_service.dart';

/// 123 云盘分享列表请求（包含免费与付费两种列表）
class Pan123ShareListRequest {
  Pan123ShareListRequest({
    this.limit = 20,
    this.next = '0',
    this.orderBy = 'fileId',
    this.orderDirection = 'desc',
    this.search = '',
    this.isPaid = false,
  });

  final int limit;
  final String next;
  final String orderBy;
  final String orderDirection;
  final String search;
  final bool isPaid;

  /// 构造查询参数，包含官方前端生成的随机参数
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'driveId': '0',
      'limit': limit,
      'next': next,
      'orderBy': orderBy,
      'orderDirection': orderDirection,
      'SearchData': search,
      'event': 'shareListFile',
      'operateType': '1',
    };

    return {
      ...Pan123BaseService.buildNoiseQueryParams(),
      ...params,
    };
  }
}

/// 123 云盘取消分享请求
class Pan123ShareCancelRequest {
  Pan123ShareCancelRequest({
    required this.shareIds,
    this.isPaidShare = false,
  });

  final List<int> shareIds;
  final bool isPaidShare;

  Map<String, dynamic> toBody() => {
    'driveId': 0,
    'shareInfoList': [
      for (final id in shareIds) {'shareId': id},
    ],
    'isPayShare': isPaidShare ? 1 : 0,
    'event': 'shareCancel',
    'operatePlace': 2,
  };
}
