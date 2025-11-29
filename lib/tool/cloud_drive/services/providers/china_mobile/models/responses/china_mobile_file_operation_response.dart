import 'china_mobile_base_response.dart';

/// 中国移动云盘文件操作响应（移动、删除、复制、重命名等）
class ChinaMobileFileOperationResponse {
  final bool success;
  final String? code;
  final String? message;
  final Map<String, dynamic>? data;
  final String? taskId;

  const ChinaMobileFileOperationResponse({
    required this.success,
    this.code,
    this.message,
    this.data,
    this.taskId,
  });

  factory ChinaMobileFileOperationResponse.fromJson(Map<String, dynamic> json) {
    final base = ChinaMobileBaseResponse.fromJson(json);
    final data = base.data;
    final taskId = data?['taskId']?.toString();

    return ChinaMobileFileOperationResponse(
      success: base.isSuccess,
      code: base.code,
      message: base.message,
      data: data,
      taskId: taskId,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    if (code != null) 'code': code,
    if (message != null) 'message': message,
    if (data != null) 'data': data,
    if (taskId != null) 'taskId': taskId,
  };

  bool get hasTask => taskId != null;

  @override
  String toString() =>
      'ChinaMobileFileOperationResponse(success: $success, taskId: $taskId)';
}
