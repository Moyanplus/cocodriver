/// 中国移动云盘文件操作响应
///
/// 用于移动、删除、复制、重命名等操作的响应
class ChinaMobileFileOperationResponse {
  /// 操作是否成功
  final bool success;

  /// 响应码
  final String? code;

  /// 响应消息
  final String? message;

  /// 数据（如果有）
  final Map<String, dynamic>? data;

  /// 任务ID（如果是异步操作）
  final String? taskId;

  const ChinaMobileFileOperationResponse({
    required this.success,
    this.code,
    this.message,
    this.data,
    this.taskId,
  });

  /// 从API响应解析
  factory ChinaMobileFileOperationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final taskId = data?['taskId'] as String?;

    return ChinaMobileFileOperationResponse(
      success: json['success'] as bool? ?? false,
      code: json['code'] as String?,
      message: json['message'] as String?,
      data: data,
      taskId: taskId,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'success': success,
    if (code != null) 'code': code,
    if (message != null) 'message': message,
    if (data != null) 'data': data,
    if (taskId != null) 'taskId': taskId,
  };

  /// 是否有异步任务
  bool get hasTask => taskId != null;

  @override
  String toString() =>
      'ChinaMobileFileOperationResponse('
      'success: $success, '
      'taskId: $taskId)';
}
