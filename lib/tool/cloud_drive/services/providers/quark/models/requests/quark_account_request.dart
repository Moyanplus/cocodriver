/// 夸克云盘获取账号信息请求
class QuarkAccountInfoRequest {
  /// 转换为API查询参数
  Map<String, String> toQueryParameters() => {'fr': 'pc', 'platform': 'pc'};

  @override
  String toString() => 'QuarkAccountInfoRequest()';
}

/// 夸克云盘获取会员信息请求
class QuarkMemberInfoRequest {
  /// 转换为API查询参数
  Map<String, String> toQueryParameters() => {
    'pr': 'ucpro',
    'fr': 'pc',
    'uc_param_str': '',
    'fetch_subscribe': 'true',
    '_ch': 'home',
    'fetch_identity': 'true',
  };

  @override
  String toString() => 'QuarkMemberInfoRequest()';
}

/// 夸克云盘任务状态查询请求
class QuarkTaskStatusRequest {
  /// 任务ID
  final String taskId;

  /// 重试索引
  final int retryIndex;

  const QuarkTaskStatusRequest({required this.taskId, this.retryIndex = 0});

  /// 转换为API查询参数
  Map<String, String> toQueryParameters() => {
    'pr': 'ucpro',
    'fr': 'pc',
    'uc_param_str': '',
    'task_id': taskId,
    'retry_index': retryIndex.toString(),
  };

  @override
  String toString() =>
      'QuarkTaskStatusRequest('
      'taskId: $taskId, '
      'retryIndex: $retryIndex)';
}
