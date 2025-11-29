import 'china_mobile_request.dart';

/// 中国移动云盘任务查询请求
class ChinaMobileTaskRequest implements ChinaMobileRequest {
  /// 任务ID
  final String taskId;

  const ChinaMobileTaskRequest({required this.taskId});

  /// 转换为请求体
  @override
  Map<String, dynamic> toRequestBody() => {'taskId': taskId};

  @override
  String toString() => 'ChinaMobileTaskRequest(taskId: $taskId)';
}
