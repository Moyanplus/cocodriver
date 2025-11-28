class ChinaMobileCreateFolderRequest {
  final String parentFileId;
  final String name;
  final String description;
  /// API 固定为 folder
  final String type;
  /// 重名处理模式，force_rename 会自动追加后缀
  final String fileRenameMode;

  ChinaMobileCreateFolderRequest({
    required this.parentFileId,
    required this.name,
    this.description = '',
    this.type = 'folder',
    this.fileRenameMode = 'force_rename',
  });

  Map<String, dynamic> toRequestBody() => {
    'parentFileId': parentFileId,
    'name': name,
    'description': description,
    'type': type,
    'fileRenameMode': fileRenameMode,
  };
}
