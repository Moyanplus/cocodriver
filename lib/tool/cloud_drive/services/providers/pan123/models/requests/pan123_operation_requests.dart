import '../../../../../data/models/cloud_drive_entities.dart';
import '../../api/pan123_config.dart';

/// 123 云盘移动请求模型
class Pan123MoveRequest {
  Pan123MoveRequest({
    required this.file,
    required this.targetParentId,
  });

  final CloudDriveFile file;
  final String targetParentId;

  /// 转换为 API 需要的 JSON 结构
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

/// 123 云盘复制请求模型
class Pan123CopyRequest {
  Pan123CopyRequest({
    required this.file,
    required this.targetParentId,
  });

  final CloudDriveFile file;
  final String targetParentId;

  /// 转换为复制接口的请求体
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

/// 123 云盘重命名请求模型
class Pan123RenameRequest {
  Pan123RenameRequest({
    required this.file,
    required String newName,
  }) : newName = newName.trim();

  final CloudDriveFile file;
  final String newName;

  /// 转换为重命名接口参数
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

/// 123 云盘删除请求模型
class Pan123DeleteRequest {
  Pan123DeleteRequest({
    required this.file,
  });

  final CloudDriveFile file;

  /// 转换为删除接口参数
  Map<String, dynamic> toApiParams() => {
    'fileIds': file.id,
    'driveId': 0,
    'operatePlace': 'bottom',
    'event': 'fileDelete',
    'RequestSource': null,
  };
}

/// 123 云盘创建文件夹请求
class Pan123CreateFolderRequest {
  Pan123CreateFolderRequest({
    required this.name,
    this.parentId,
  });

  final String name;
  final String? parentId;

  /// 转换为创建文件夹请求体
  Map<String, dynamic> toApiParams() {
    final parent = Pan123Config.getFolderId(parentId ?? '0');
    final parentInt = int.tryParse(parent) ?? 0;
    return {
      'driveId': 0,
      'etag': '',
      'fileName': name,
      'parentFileId': parentInt,
      'size': 0,
      'type': 1,
      'duplicate': 1,
      'NotReuse': true,
      'event': 'newCreateFolder',
      'operateType': 1,
      'operatePlace': 'bottom',
      'RequestSource': null,
    };
  }
}

/// 123 云盘下载地址请求模型
class Pan123DownloadRequest {
  Pan123DownloadRequest({
    required this.file,
  });

  final CloudDriveFile file;

  /// 转换为获取下载链接的参数
  Map<String, dynamic> toApiParams() {
    final params = <String, dynamic>{
      'fileId': file.id,
      'fileName': file.name,
    };
    if (file.size != null) params['size'] = file.size.toString();
    return params;
  }
}
