/// 离线解析返回的单个文件信息
class Pan123OfflineFile {
  const Pan123OfflineFile({
    required this.id,
    required this.name,
    required this.size,
    required this.category,
    required this.fileType,
  });

  factory Pan123OfflineFile.fromJson(Map<String, dynamic> json) {
    return Pan123OfflineFile(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      category: json['category'] as int? ?? 0,
      fileType: json['file_type'] as int? ?? 0,
    );
  }

  final int id;
  final String name;
  final int size;
  final int category;
  final int fileType;
}

/// 离线解析返回的资源
class Pan123OfflineResource {
  const Pan123OfflineResource({
    required this.id,
    required this.url,
    required this.name,
    required this.size,
    required this.files,
    required this.result,
    this.errCode,
    this.errMsg,
  });

  factory Pan123OfflineResource.fromJson(Map<String, dynamic> json) {
    final files = (json['files'] as List<dynamic>? ?? [])
        .map((e) => Pan123OfflineFile.fromJson(e as Map<String, dynamic>))
        .toList();
    return Pan123OfflineResource(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      url: json['url']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      files: files,
      result: json['result'] as int? ?? -1,
      errCode: json['err_code'] as int?,
      errMsg: json['err_msg']?.toString(),
    );
  }

  final int id;
  final String url;
  final String name;
  final int size;
  final List<Pan123OfflineFile> files;
  final int result;
  final int? errCode;
  final String? errMsg;
}

/// 离线解析响应
class Pan123OfflineResolveResponse {
  const Pan123OfflineResolveResponse({required this.resources});

  factory Pan123OfflineResolveResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data']?['list'] as List<dynamic>? ?? [])
        .map((e) => Pan123OfflineResource.fromJson(e as Map<String, dynamic>))
        .toList();
    return Pan123OfflineResolveResponse(resources: list);
  }

  final List<Pan123OfflineResource> resources;
}

/// 离线提交任务信息
class Pan123OfflineTask {
  const Pan123OfflineTask({
    required this.taskId,
    required this.resourceId,
    required this.url,
    required this.result,
    this.thirdTaskId,
  });

  factory Pan123OfflineTask.fromJson(Map<String, dynamic> json) {
    return Pan123OfflineTask(
      taskId: json['task_id'] is int
          ? json['task_id'] as int
          : int.tryParse('${json['task_id']}') ?? 0,
      resourceId: json['resource_id'] is int
          ? json['resource_id'] as int
          : int.tryParse('${json['resource_id']}') ?? 0,
      url: json['url']?.toString() ?? '',
      result: json['result'] as int? ?? 0,
      thirdTaskId: json['third_task_id']?.toString(),
    );
  }

  final int taskId;
  final int resourceId;
  final String url;
  final int result;
  final String? thirdTaskId;
}

/// 离线提交响应
class Pan123OfflineSubmitResponse {
  const Pan123OfflineSubmitResponse({required this.tasks});

  factory Pan123OfflineSubmitResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data']?['task_list'] as List<dynamic>? ?? [])
        .map((e) => Pan123OfflineTask.fromJson(e as Map<String, dynamic>))
        .toList();
    return Pan123OfflineSubmitResponse(tasks: list);
  }

  final List<Pan123OfflineTask> tasks;
}

/// 离线任务列表项
class Pan123OfflineTaskItem {
  const Pan123OfflineTaskItem({
    required this.taskId,
    required this.name,
    required this.status,
    required this.size,
    required this.progress,
    this.thirdTaskId,
    this.downloaded,
    this.uploadId,
    this.uploadName,
    this.type,
  });

  factory Pan123OfflineTaskItem.fromJson(Map<String, dynamic> json) {
    return Pan123OfflineTaskItem(
      taskId: json['task_id'] is int
          ? json['task_id'] as int
          : int.tryParse('${json['task_id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      status: json['status'] as int? ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      thirdTaskId: json['third_task_id']?.toString(),
      downloaded: (json['downloaded'] as num?)?.toInt(),
      uploadId: json['upload_idr'] as int?,
      uploadName: json['upload_name']?.toString(),
      type: json['type']?.toString(),
    );
  }

  final int taskId;
  final String name;
  final int status;
  final int size;
  final int progress;
  final String? thirdTaskId;
  final int? downloaded;
  final int? uploadId;
  final String? uploadName;
  final String? type;
}

/// 离线任务列表响应
class Pan123OfflineTaskListResponse {
  const Pan123OfflineTaskListResponse({
    required this.tasks,
    required this.total,
    required this.hasRun,
  });

  factory Pan123OfflineTaskListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data']?['list'] as List<dynamic>? ?? [])
        .map((e) => Pan123OfflineTaskItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return Pan123OfflineTaskListResponse(
      tasks: list,
      total: data['total'] as int? ?? 0,
      hasRun: data['has_run'] as bool? ?? false,
    );
  }

  final List<Pan123OfflineTaskItem> tasks;
  final int total;
  final bool hasRun;
}
