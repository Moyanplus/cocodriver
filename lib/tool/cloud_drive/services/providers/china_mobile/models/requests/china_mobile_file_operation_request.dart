import 'china_mobile_request.dart';

/// 中国移动云盘文件操作请求基类
abstract class ChinaMobileFileOperationRequest implements ChinaMobileRequest {
  /// 转换为请求体
  @override
  Map<String, dynamic> toRequestBody();
}

/// 重命名文件请求
class ChinaMobileRenameFileRequest extends ChinaMobileFileOperationRequest {
  /// 文件ID
  final String fileId;

  /// 新名称
  final String name;

  /// 描述
  final String description;

  ChinaMobileRenameFileRequest({
    required this.fileId,
    required this.name,
    this.description = '',
  });

  @override
  Map<String, dynamic> toRequestBody() => {
    'fileId': fileId,
    'name': name,
    'description': description,
  };

  @override
  String toString() =>
      'ChinaMobileRenameFileRequest(fileId: $fileId, name: $name)';
}

/// 移动文件请求
class ChinaMobileMoveFileRequest extends ChinaMobileFileOperationRequest {
  /// 文件ID列表
  final List<String> fileIds;

  /// 目标父文件夹ID
  final String toParentFileId;

  ChinaMobileMoveFileRequest({
    required this.fileIds,
    required this.toParentFileId,
  });

  @override
  Map<String, dynamic> toRequestBody() => {
    'fileIds': fileIds,
    'toParentFileId': toParentFileId,
  };

  @override
  String toString() =>
      'ChinaMobileMoveFileRequest(fileIds: ${fileIds.length}, toParentFileId: $toParentFileId)';
}

/// 复制文件请求
class ChinaMobileCopyFileRequest extends ChinaMobileFileOperationRequest {
  /// 文件ID列表
  final List<String> fileIds;

  /// 目标父文件夹ID
  final String toParentFileId;

  ChinaMobileCopyFileRequest({
    required this.fileIds,
    required this.toParentFileId,
  });

  @override
  Map<String, dynamic> toRequestBody() => {
    'fileIds': fileIds,
    'toParentFileId': toParentFileId,
  };

  @override
  String toString() =>
      'ChinaMobileCopyFileRequest(fileIds: ${fileIds.length}, toParentFileId: $toParentFileId)';
}

/// 删除文件请求
class ChinaMobileDeleteFileRequest extends ChinaMobileFileOperationRequest {
  /// 文件ID列表
  final List<String> fileIds;

  ChinaMobileDeleteFileRequest({required this.fileIds});

  @override
  Map<String, dynamic> toRequestBody() => {'fileIds': fileIds};

  @override
  String toString() =>
      'ChinaMobileDeleteFileRequest(fileIds: ${fileIds.length})';
}
