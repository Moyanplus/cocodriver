import '../../../../../data/models/cloud_drive_entities.dart';

class AliMoveRequest {
  AliMoveRequest({
    required this.file,
    required this.targetFolderId,
  });

  final CloudDriveFile file;
  final String targetFolderId;
}

class AliCopyRequest {
  AliCopyRequest({
    required this.file,
    required this.targetFolderId,
  });

  final CloudDriveFile file;
  final String targetFolderId;
}

class AliRenameRequest {
  AliRenameRequest({
    required this.file,
    required this.newName,
  });

  final CloudDriveFile file;
  final String newName;
}

class AliDeleteRequest {
  AliDeleteRequest({required this.file});

  final CloudDriveFile file;
}

class AliCreateFolderRequest {
  AliCreateFolderRequest({
    required this.name,
    this.parentId,
  });

  final String name;
  final String? parentId;
}

class AliDownloadRequest {
  AliDownloadRequest({
    required this.file,
    required this.driveId,
  });

  final CloudDriveFile file;
  final String driveId;
}
