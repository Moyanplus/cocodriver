import 'china_mobile_base_response.dart';
import 'parsing_utils.dart';

/// 中国移动云盘任务查询响应
class ChinaMobileTaskResponse {
  final String taskId;
  final String? status;
  final int? statusCode;
  final String? taskType;
  final String? taskTitle;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final int? affectedFileNum;
  final String? errorMessage;
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

  factory ChinaMobileTaskResponse.fromJson(Map<String, dynamic> json) {
    final base = ChinaMobileBaseResponse.fromJson(json);
    final data = base.data ?? json;

    return ChinaMobileTaskResponse(
      taskId: data['taskId']?.toString() ?? '',
      status: data['status']?.toString(),
      statusCode: data['statusCode'] as int? ?? data['status'] as int?,
      taskType: data['taskType']?.toString() ?? data['task_type']?.toString(),
      taskTitle:
          data['taskTitle']?.toString() ?? data['task_title']?.toString(),
      createdAt:
          ChinaMobileParsingUtils.parseDate(data['createdAt'] ?? data['created_at']),
      completedAt:
          ChinaMobileParsingUtils.parseDate(data['completedAt'] ?? data['completed_at']),
      affectedFileNum:
          data['affectedFileNum'] as int? ?? data['affected_file_num'] as int?,
      errorMessage:
          data['errorMessage']?.toString() ?? data['error_message']?.toString(),
      extraData: data.isNotEmpty ? data : null,
    );
  }

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

  bool get isSuccess => status == 'success' || statusCode == 2;
  bool get isFailed => status == 'failed' || statusCode == 3;
  bool get isPending =>
      status == 'pending' ||
      status == 'running' ||
      statusCode == 0 ||
      statusCode == 1;

  @override
  String toString() =>
      'ChinaMobileTaskResponse(taskId: $taskId, status: $status, isSuccess: $isSuccess)';
}
