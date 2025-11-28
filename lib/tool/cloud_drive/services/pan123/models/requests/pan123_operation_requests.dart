import '../../../../data/models/cloud_drive_entities.dart';

class Pan123MoveRequest {
  Pan123MoveRequest({
    required this.file,
    required this.targetParentId,
  });

  final CloudDriveFile file;
  final String targetParentId;
}

class Pan123CopyRequest {
  Pan123CopyRequest({
    required this.file,
    required this.targetParentId,
  });

  final CloudDriveFile file;
  final String targetParentId;
}

class Pan123RenameRequest {
  Pan123RenameRequest({
    required this.file,
    required String newName,
  }) : newName = newName.trim();

  final CloudDriveFile file;
  final String newName;
}

class Pan123DeleteRequest {
  Pan123DeleteRequest({
    required this.file,
  });

  final CloudDriveFile file;
}

class Pan123CreateFolderRequest {
  Pan123CreateFolderRequest({
    required this.name,
    this.parentId,
  });

  final String name;
  final String? parentId;
}

class Pan123DownloadRequest {
  Pan123DownloadRequest({
    required this.file,
  });

  final CloudDriveFile file;
}
