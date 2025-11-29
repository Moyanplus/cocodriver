import '../../../../../data/models/cloud_drive_entities.dart';

class Pan123MoveRequest {
  Pan123MoveRequest({
    required this.file,
    required this.targetParentId,
  });

  final CloudDriveFile file;
  final String targetParentId;

  Map<String, dynamic> toApiParams() {
    int targetParentInt;
    var clean = targetParentId;
    if (clean == '/' || clean.isEmpty) {
      targetParentInt = 0;
    } else {
      if (clean.startsWith('/')) clean = clean.substring(1);
      targetParentInt = int.tryParse(clean) ?? 0;
    }

    return {
      'fileIdList': [
        {'FileId': int.tryParse(file.id) ?? 0},
      ],
      'parentFileId': targetParentInt,
      'event': 'fileMove',
      'operatePlace': 'bottom',
      'RequestSource': null,
    };
  }
}

class Pan123CopyRequest {
  Pan123CopyRequest({
    required this.file,
    required this.targetParentId,
  });

  final CloudDriveFile file;
  final String targetParentId;

  Map<String, dynamic> toApiParams() => {
    'fileList': [
      {
        'fileId': int.tryParse(file.id) ?? 0,
        'size': file.size ?? 0,
        'etag': '',
        'type': file.isFolder ? 1 : 0,
        'parentFileId': int.tryParse(file.folderId ?? '0') ?? 0,
        'fileName': file.name,
        'driveId': 0,
      },
    ],
    'targetFileId': int.tryParse(targetParentId) ?? 0,
  };
}

class Pan123RenameRequest {
  Pan123RenameRequest({
    required this.file,
    required String newName,
  }) : newName = newName.trim();

  final CloudDriveFile file;
  final String newName;

  Map<String, dynamic> toApiParams() => {
    'driveId': 0,
    'fileId': int.tryParse(file.id) ?? 0,
    'fileName': newName,
    'duplicate': 1,
    'event': 'fileRename',
    'operatePlace': 'bottom',
    'RequestSource': null,
  };
}

class Pan123DeleteRequest {
  Pan123DeleteRequest({
    required this.file,
  });

  final CloudDriveFile file;

  Map<String, dynamic> toApiParams() => {
    'fileIds': file.id,
    'driveId': 0,
    'operatePlace': 'bottom',
    'event': 'fileDelete',
    'RequestSource': null,
  };
}

class Pan123CreateFolderRequest {
  Pan123CreateFolderRequest({
    required this.name,
    this.parentId,
  });

  final String name;
  final String? parentId;

  Map<String, dynamic> toApiParams() => {
    'driveId': 0,
    'parentFileId': int.tryParse(parentId ?? '0') ?? 0,
    'fileName': name,
    'event': 'folderCreate',
    'operatePlace': 'bottom',
    'RequestSource': null,
  };
}

class Pan123DownloadRequest {
  Pan123DownloadRequest({
    required this.file,
  });

  final CloudDriveFile file;

  Map<String, dynamic> toApiParams() {
    final params = <String, dynamic>{
      'fileId': file.id,
      'fileName': file.name,
    };
    if (file.size != null) params['size'] = file.size.toString();
    return params;
  }
}
