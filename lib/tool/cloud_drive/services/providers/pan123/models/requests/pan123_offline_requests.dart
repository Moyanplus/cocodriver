/// 离线下载解析请求
class Pan123OfflineResolveRequest {
  const Pan123OfflineResolveRequest({required this.url});

  final String url;

  Map<String, dynamic> toJson() => {'urls': url};
}

/// 离线下载提交请求
class Pan123OfflineSubmitRequest {
  const Pan123OfflineSubmitRequest({
    required this.resourceId,
    required this.selectFileIds,
  });

  final int resourceId;
  final List<int> selectFileIds;

  Map<String, dynamic> toJson() => {
        'resource_list': [
          {
            'resource_id': resourceId,
            'select_file_id': selectFileIds,
          }
        ]
      };
}

/// 离线下载任务列表请求
class Pan123OfflineListRequest {
  const Pan123OfflineListRequest({
    this.page = 1,
    this.pageSize = 15,
    this.status = const [0, 1, 2, 3, 4],
  });

  final int page;
  final int pageSize;
  final List<int> status;

  Map<String, dynamic> toJson() => {
        'current_page': page,
        'page_size': pageSize,
        'status_arr': status,
      };
}
