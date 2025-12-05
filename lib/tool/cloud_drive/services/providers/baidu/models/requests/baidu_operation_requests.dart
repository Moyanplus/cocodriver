import '../../../../../data/models/cloud_drive_entities.dart';

/// 百度网盘移动请求
class BaiduMoveRequest {
  BaiduMoveRequest({
    required this.file,
    required this.targetFolderId,
    required this.sourcePath,
  });

  final CloudDriveFile file;
  final String targetFolderId;
  final String sourcePath;
}

/// 百度网盘复制请求
class BaiduCopyRequest {
  BaiduCopyRequest({
    required this.file,
    required this.targetFolderId,
    required this.sourcePath,
  });

  final CloudDriveFile file;
  final String targetFolderId;
  final String sourcePath;
}

/// 百度网盘重命名请求
class BaiduRenameRequest {
  BaiduRenameRequest({
    required this.file,
    required this.newName,
    required this.sourcePath,
  });

  final CloudDriveFile file;
  final String newName;
  final String sourcePath;
}

/// 百度网盘删除请求
class BaiduDeleteRequest {
  BaiduDeleteRequest({required this.file, required this.sourcePath});

  final CloudDriveFile file;
  final String sourcePath;
}

/// 百度网盘创建文件夹请求
class BaiduCreateFolderRequest {
  BaiduCreateFolderRequest({required this.name, this.parentId});

  final String name;
  final String? parentId;
}

/// 百度网盘下载链接请求
class BaiduDownloadRequest {
  BaiduDownloadRequest({required this.file});

  final CloudDriveFile file;
}
