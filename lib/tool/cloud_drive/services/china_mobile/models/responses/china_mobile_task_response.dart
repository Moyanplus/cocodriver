/// 中国移动云盘任务查询响应
class ChinaMobileTaskResponse {
  /// 任务ID
  final String taskId;

  /// 任务状态（根据实际API定义，可能需要调整）
  final String? status;

  /// 任务状态码（数字）
  final int? statusCode;

  /// 任务类型
  final String? taskType;

  /// 任务标题
  final String? taskTitle;

  /// 创建时间
  final DateTime? createdAt;

  /// 完成时间
  final DateTime? completedAt;

  /// 影响的文件数量
  final int? affectedFileNum;

  /// 错误信息
  final String? errorMessage;

  /// 其他数据
  final Map<String, dynamic>? extraData;

  const ChinaMobileTaskResponse({
    required this.taskId,
    this.status,
    this.statusCode,
    this.taskType,
    this.taskTitle,
    this.createdAt,
    this.completedAt,
    this.affectedFileNum,
    this.errorMessage,
    this.extraData,
  });

  /// 从API响应解析
  factory ChinaMobileTaskResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    // 解析时间戳
    DateTime? parseTime(dynamic timeValue) {
      if (timeValue == null) return null;
      if (timeValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(timeValue);
      } else if (timeValue is String) {
        final timestamp = int.tryParse(timeValue);
        if (timestamp != null) {
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
        return DateTime.tryParse(timeValue);
      }
      return null;
    }

    return ChinaMobileTaskResponse(
      taskId: data['taskId']?.toString() ?? '',
      status: data['status']?.toString(),
      statusCode: data['statusCode'] as int? ?? data['status'] as int?,
      taskType: data['taskType']?.toString() ?? data['task_type']?.toString(),
      taskTitle:
          data['taskTitle']?.toString() ?? data['task_title']?.toString(),
      createdAt: parseTime(data['createdAt'] ?? data['created_at']),
      completedAt: parseTime(data['completedAt'] ?? data['completed_at']),
      affectedFileNum:
          data['affectedFileNum'] as int? ?? data['affected_file_num'] as int?,
      errorMessage:
          data['errorMessage']?.toString() ?? data['error_message']?.toString(),
      extraData: data.isNotEmpty ? data : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    if (status != null) 'status': status,
    if (statusCode != null) 'statusCode': statusCode,
    if (taskType != null) 'taskType': taskType,
    if (taskTitle != null) 'taskTitle': taskTitle,
    if (createdAt != null) 'createdAt': createdAt!.millisecondsSinceEpoch,
    if (completedAt != null) 'completedAt': completedAt!.millisecondsSinceEpoch,
    if (affectedFileNum != null) 'affectedFileNum': affectedFileNum,
    if (errorMessage != null) 'errorMessage': errorMessage,
    if (extraData != null) ...extraData!,
  };

  /// 是否成功
  bool get isSuccess => status == 'success' || statusCode == 2;

  /// 是否失败
  bool get isFailed => status == 'failed' || statusCode == 3;

  /// 是否进行中
  bool get isPending =>
      status == 'pending' ||
      status == 'running' ||
      statusCode == 0 ||
      statusCode == 1;

  @override
  String toString() =>
      'ChinaMobileTaskResponse('
      'taskId: $taskId, '
      'status: $status, '
      'isSuccess: $isSuccess)';
}
