import '../../../../../data/models/cloud_drive_entities.dart';

class BaiduMoveRequest {
  BaiduMoveRequest({
    required this.file,
    required this.targetFolderId,
  });

  final CloudDriveFile file;
  final String targetFolderId;
}

class BaiduCopyRequest {
  BaiduCopyRequest({
    required this.file,
    required this.targetFolderId,
  });

  final CloudDriveFile file;
  final String targetFolderId;
}

class BaiduRenameRequest {
  BaiduRenameRequest({
    required this.file,
    required this.newName,
  });

  final CloudDriveFile file;
  final String newName;
}

class BaiduDeleteRequest {
  BaiduDeleteRequest({required this.file});

  final CloudDriveFile file;
}

class BaiduCreateFolderRequest {
  BaiduCreateFolderRequest({
    required this.name,
    this.parentId,
  });

  final String name;
  final String? parentId;
}

class BaiduDownloadRequest {
  BaiduDownloadRequest({
    required this.file,
  });

  final CloudDriveFile file;
}
