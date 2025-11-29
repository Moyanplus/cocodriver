/// 夸克云盘文件操作响应
class QuarkFileOperationResponse {
  /// 任务ID（异步操作时）
  final String? taskId;

  /// 是否立即完成
  final bool isFinished;

  /// 影响的文件数量
  final int? affectedFileNum;

  const QuarkFileOperationResponse({
    this.taskId,
    required this.isFinished,
    this.affectedFileNum,
  });

  /// 从API响应解析
  factory QuarkFileOperationResponse.fromJson(Map<String, dynamic> json) {
    return QuarkFileOperationResponse(
      taskId: json['task_id'] as String?,
      isFinished: json['finish'] as bool? ?? false,
      affectedFileNum: json['affected_file_num'] as int?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    if (taskId != null) 'task_id': taskId,
    'finish': isFinished,
    if (affectedFileNum != null) 'affected_file_num': affectedFileNum,
  };

  @override
  String toString() =>
      'QuarkFileOperationResponse('
      'taskId: $taskId, '
      'isFinished: $isFinished, '
      'affectedFileNum: $affectedFileNum)';
}

/// 夸克云盘创建文件夹响应
class QuarkCreateFolderResponse {
  /// 文件夹ID
  final String? folderId;

  /// 是否立即完成
  final bool isFinished;

  const QuarkCreateFolderResponse({this.folderId, required this.isFinished});

  /// 从API响应解析
  factory QuarkCreateFolderResponse.fromJson(Map<String, dynamic> json) {
    return QuarkCreateFolderResponse(
      folderId: json['fid'] as String?,
      isFinished: json['finish'] as bool? ?? false,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    if (folderId != null) 'fid': folderId,
    'finish': isFinished,
  };

  @override
  String toString() =>
      'QuarkCreateFolderResponse('
      'folderId: $folderId, '
      'isFinished: $isFinished)';
}

/// 夸克云盘任务状态响应
class QuarkTaskStatusResponse {
  /// 任务ID
  final String taskId;

  /// 任务状态（0=等待，1=运行，2=成功，3=失败）
  final int status;

  /// 任务类型
  final int? taskType;

  /// 任务标题
  final String? taskTitle;

  /// 创建时间
  final int? createdAt;

  /// 影响的文件数量
  final int? affectedFileNum;

  const QuarkTaskStatusResponse({
    required this.taskId,
    required this.status,
    this.taskType,
    this.taskTitle,
    this.createdAt,
    this.affectedFileNum,
  });

  /// 从API响应解析
  factory QuarkTaskStatusResponse.fromJson(Map<String, dynamic> json) {
    return QuarkTaskStatusResponse(
      taskId: json['task_id'] as String,
      status: json['status'] as int,
      taskType: json['task_type'] as int?,
      taskTitle: json['task_title'] as String?,
      createdAt: json['created_at'] as int?,
      affectedFileNum: json['affected_file_num'] as int?,
    );
  }

  /// 是否成功
  bool get isSuccess => status == 2;

  /// 是否失败
  bool get isFailed => status == 3;

  /// 是否进行中
  bool get isPending => status == 0 || status == 1;

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'task_id': taskId,
    'status': status,
    if (taskType != null) 'task_type': taskType,
    if (taskTitle != null) 'task_title': taskTitle,
    if (createdAt != null) 'created_at': createdAt,
    if (affectedFileNum != null) 'affected_file_num': affectedFileNum,
  };

  @override
  String toString() =>
      'QuarkTaskStatusResponse('
      'taskId: $taskId, '
      'status: $status, '
      'isSuccess: $isSuccess)';
}
