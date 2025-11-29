import '../../api/lanzou_request_builder.dart';

/// 获取文件/文件夹列表请求
class LanzouFolderRequest {
  const LanzouFolderRequest({required this.folderId, required this.taskKey});

  final String folderId;
  final String taskKey;

  Map<String, dynamic> build(String vei) =>
      LanzouRequestBuilder().task(taskKey).folder(folderId).vei(vei).build();
}

/// 文件详情请求
class LanzouFileDetailRequest {
  const LanzouFileDetailRequest({required this.fileId});

  final String fileId;

  Map<String, dynamic> build() =>
      LanzouRequestBuilder().task('getFileDetail').file(fileId).build();
}

/// Cookie 校验请求
class LanzouValidateCookiesRequest {
  const LanzouValidateCookiesRequest();

  Map<String, dynamic> build(String vei) =>
      LanzouRequestBuilder()
          .task('validateCookies')
          .folder('-1')
          .vei(vei)
          .build();
}

/// 移动文件请求
class LanzouMoveFileRequest {
  const LanzouMoveFileRequest({required this.fileId, this.targetFolderId});

  final String fileId;
  final String? targetFolderId;

  Map<String, dynamic> build() =>
      LanzouRequestBuilder()
          .task('moveFile')
          .folder(targetFolderId)
          .file(fileId)
          .build();
}

/// 删除文件请求
class LanzouDeleteFileRequest {
  const LanzouDeleteFileRequest({required this.fileId});

  final String fileId;

  Map<String, dynamic> build() =>
      LanzouRequestBuilder().task('deleteFile').file(fileId).build();
}

/// 重命名文件请求
class LanzouRenameFileRequest {
  const LanzouRenameFileRequest({required this.fileId, required this.newName});

  final String fileId;
  final String newName;

  Map<String, dynamic> build() =>
      LanzouRequestBuilder()
          .task('renameFile')
          .file(fileId)
          .add('file_name', newName)
          .add('type', '2')
          .build();
}

/// 创建文件夹请求
class LanzouCreateFolderRequest {
  const LanzouCreateFolderRequest({
    required this.parentFolderId,
    required this.folderName,
    this.description,
  });

  final String parentFolderId;
  final String folderName;
  final String? description;

  Map<String, dynamic> build() =>
      LanzouRequestBuilder()
          .task('createFolder')
          .folder(parentFolderId)
          .add('folder_name', folderName)
          .add('folder_description', description ?? '')
          .build();
}
