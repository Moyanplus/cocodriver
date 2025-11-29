/// 文件操作类型
enum FileOperationType {
  /// 移动
  move(1),

  /// 删除
  delete(2),

  /// 复制
  copy(3),

  /// 重命名
  rename(4);

  final int value;
  const FileOperationType(this.value);
}

/// 夸克云盘文件操作请求基类
abstract class QuarkFileOperationRequest {
  /// 操作类型
  FileOperationType get operationType;

  /// 转换为API查询参数
  Map<String, String> toQueryParameters() => {
    'pr': 'ucpro',
    'fr': 'pc',
    'uc_param_str': '',
  };

  /// 转换为API请求体
  Map<String, dynamic> toRequestBody();
}

/// 移动文件请求
class QuarkMoveFileRequest extends QuarkFileOperationRequest {
  /// 目标文件夹ID
  final String targetFolderId;

  /// 文件ID列表
  final List<String> fileIds;

  QuarkMoveFileRequest({required this.targetFolderId, required this.fileIds});

  @override
  FileOperationType get operationType => FileOperationType.move;

  @override
  Map<String, dynamic> toRequestBody() => {
    'action_type': operationType.value,
    'to_pdir_fid': targetFolderId,
    'filelist': fileIds,
    'exclude_fids': <String>[],
  };

  @override
  String toString() =>
      'QuarkMoveFileRequest('
      'targetFolderId: $targetFolderId, '
      'fileIds: ${fileIds.length} files)';
}

/// 复制文件请求
class QuarkCopyFileRequest extends QuarkFileOperationRequest {
  /// 目标文件夹ID
  final String targetFolderId;

  /// 文件ID列表
  final List<String> fileIds;

  QuarkCopyFileRequest({required this.targetFolderId, required this.fileIds});

  @override
  FileOperationType get operationType => FileOperationType.copy;

  @override
  Map<String, dynamic> toRequestBody() => {
    'action_type': operationType.value,
    'to_pdir_fid': targetFolderId,
    'filelist': fileIds,
    'exclude_fids': <String>[],
  };

  @override
  String toString() =>
      'QuarkCopyFileRequest('
      'targetFolderId: $targetFolderId, '
      'fileIds: ${fileIds.length} files)';
}

/// 删除文件请求
class QuarkDeleteFileRequest extends QuarkFileOperationRequest {
  /// 文件ID列表
  final List<String> fileIds;

  QuarkDeleteFileRequest({required this.fileIds});

  @override
  FileOperationType get operationType => FileOperationType.delete;

  @override
  Map<String, dynamic> toRequestBody() => {
    'action_type': operationType.value,
    'filelist': fileIds,
    'exclude_fids': <String>[],
  };

  @override
  String toString() =>
      'QuarkDeleteFileRequest(fileIds: ${fileIds.length} files)';
}

/// 重命名文件请求
class QuarkRenameFileRequest extends QuarkFileOperationRequest {
  /// 文件ID
  final String fileId;

  /// 新文件名
  final String newName;

  QuarkRenameFileRequest({required this.fileId, required this.newName});

  @override
  FileOperationType get operationType => FileOperationType.rename;

  @override
  Map<String, dynamic> toRequestBody() => {'fid': fileId, 'file_name': newName};

  @override
  String toString() =>
      'QuarkRenameFileRequest('
      'fileId: $fileId, '
      'newName: $newName)';
}

/// 创建文件夹请求
class QuarkCreateFolderRequest {
  /// 父文件夹ID
  final String parentFolderId;

  /// 文件夹名称
  final String folderName;

  /// 目录路径（通常为空）
  final String dirPath;

  /// 是否初始化锁定
  final bool dirInitLock;

  const QuarkCreateFolderRequest({
    required this.parentFolderId,
    required this.folderName,
    this.dirPath = '',
    this.dirInitLock = false,
  });

  /// 转换为API查询参数
  Map<String, String> toQueryParameters() => {
    'pr': 'ucpro',
    'fr': 'pc',
    'uc_param_str': '',
  };

  /// 转换为API请求体
  Map<String, dynamic> toRequestBody() => {
    'pdir_fid': parentFolderId,
    'file_name': folderName,
    'dir_path': dirPath,
    'dir_init_lock': dirInitLock,
  };

  @override
  String toString() =>
      'QuarkCreateFolderRequest('
      'parentFolderId: $parentFolderId, '
      'folderName: $folderName)';
}
