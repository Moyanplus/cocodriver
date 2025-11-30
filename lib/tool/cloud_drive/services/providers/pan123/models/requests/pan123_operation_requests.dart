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
    'driveId': 0,
    'fileTrashInfoList': [_buildTrashInfo()],
    'operation': true,
    'event': 'intoRecycle',
    'operatePlace': 'bottom',
    'RequestSource': null,
    'safeBox': false,
  };

  Map<String, dynamic> _buildTrashInfo() {
    final meta = Map<String, dynamic>.from(file.metadata ?? {});
    int asInt(dynamic v, {int fallback = 0}) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }

    String? asString(dynamic v) => v?.toString();

    return {
      'FileId': asInt(meta['FileId'] ?? file.id, fallback: 0),
      'FileName': file.name,
      'Type': asInt(meta['Type'], fallback: file.isFolder ? 1 : 0),
      'Size': asInt(meta['Size'], fallback: file.size ?? 0),
      'ContentType': asString(meta['ContentType']) ?? '0',
      'S3KeyFlag': asString(meta['S3KeyFlag']) ?? '',
      'CreateAt':
          asString(meta['CreateAt']) ?? file.createdAt?.toIso8601String(),
      'UpdateAt':
          asString(meta['UpdateAt']) ?? file.updatedAt?.toIso8601String(),
      'Hidden': meta['Hidden'] ?? false,
      'Etag': asString(meta['Etag'] ?? meta['etag']) ?? '',
      'Status': asInt(meta['Status'], fallback: 0),
      'ParentFileId': asInt(
        meta['ParentFileId'] ?? file.folderId,
        fallback: int.tryParse(file.folderId ?? '0') ?? 0,
      ),
      'Category': asInt(meta['Category'], fallback: 0),
      'PunishFlag': asInt(meta['PunishFlag'], fallback: 0),
      'ParentName': asString(meta['ParentName']) ?? '',
      'DownloadUrl': asString(meta['DownloadUrl'] ?? file.downloadUrl) ?? '',
      'AbnormalAlert': asInt(meta['AbnormalAlert'], fallback: 0),
      'Trashed': meta['Trashed'] ?? false,
      'TrashedExpire': asString(meta['TrashedExpire']),
      'TrashedAt': asString(meta['TrashedAt']),
      'StorageNode': asString(meta['StorageNode']) ?? '',
      'DirectLink': asInt(meta['DirectLink'], fallback: 0),
      'AbsPath': asString(meta['AbsPath']) ?? '',
      'PinYin': asString(meta['PinYin']) ?? '',
      'BusinessType': asInt(meta['BusinessType'], fallback: 0),
      'Thumbnail': asString(meta['Thumbnail'] ?? file.thumbnailUrl) ?? '',
      'Operable': meta['Operable'] ?? true,
      'StarredStatus': asInt(meta['StarredStatus'], fallback: 0),
      'HighLight': asString(meta['HighLight']) ?? '',
      'NewParentName': asString(meta['NewParentName']) ?? '',
      'LiveSize': asInt(meta['LiveSize'], fallback: 0),
      'BaseSize': asInt(meta['BaseSize'], fallback: file.size ?? 0),
      'UserId': asInt(meta['UserId'], fallback: 0),
      'EnableAppeal': asInt(meta['EnableAppeal'], fallback: 0),
      'ToolTip': asString(meta['ToolTip']) ?? '',
      'RefuseReason': asInt(meta['RefuseReason'], fallback: 0),
      'DirectTranscodeStatus':
          asInt(meta['DirectTranscodeStatus'], fallback: 0),
      'PreviewType': asInt(meta['PreviewType'], fallback: 0),
      'IsLock': meta['IsLock'] ?? false,
      // 123 删除接口需要 keys/checked 与前端一致，官方前端固定 keys=9/checked=true
      'keys': 9,
      'checked': true,
    };
  }
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
