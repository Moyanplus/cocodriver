import '../../../../../data/models/cloud_drive_entities.dart';

/// 123 云盘文件列表响应
class Pan123FileListResponse {
  const Pan123FileListResponse({
    required this.code,
    this.message,
    this.data,
  });

  final int code;
  final String? message;
  final Pan123ListData? data;

  /// 是否请求成功
  bool get success => code == 0 || code == 200;

  /// 转换后的文件列表
  List<CloudDriveFile> get files => data?.files ?? const [];

  /// 根据原始 map 构造响应对象
  factory Pan123FileListResponse.fromMap(Map<String, dynamic> map) {
    final code = map['code'] as int? ?? -1;
    final dataMap = map['data'] as Map<String, dynamic>?;
    return Pan123FileListResponse(
      code: code,
      message: map['message']?.toString(),
      data: dataMap != null ? Pan123ListData.fromMap(dataMap) : null,
    );
  }
}

/// 123 云盘列表数据实体
class Pan123ListData {
  const Pan123ListData({
    required this.next,
    required this.total,
    required this.items,
  });

  final int next;
  final int total;
  final List<CloudDriveFile> items;

  /// 文件列表
  List<CloudDriveFile> get files => items;

  /// 根据原始数据构造列表对象
  factory Pan123ListData.fromMap(Map<String, dynamic> map) {
    final next = map['Next'] is int
        ? map['Next'] as int
        : int.tryParse(map['Next']?.toString() ?? '0') ?? 0;
    final total = map['Total'] is int
        ? map['Total'] as int
        : int.tryParse(map['Total']?.toString() ?? '0') ?? 0;

    final candidates = <dynamic>[];
    final lists = [
      map['InfoList'],
      map['file_info_bean_list'],
      map['list'],
      map['files'],
    ];
    for (final l in lists) {
      if (l is List) candidates.addAll(l);
    }
    final items = candidates
        .whereType<Map<String, dynamic>>()
        .map(_mapFile)
        .whereType<CloudDriveFile>()
        .toList();

    return Pan123ListData(
      next: next,
      total: total,
      items: items,
    );
  }
}

/// 将原始 JSON 映射为 [CloudDriveFile]
CloudDriveFile? _mapFile(Map<String, dynamic> fileData) {
  final id = fileData['FileId']?.toString();
  final name = fileData['FileName']?.toString();
  if (id == null || name == null) return null;
  final type = fileData['Type'] as int? ?? 0;
  final isFolder = type == 1;
  final size = int.tryParse(fileData['Size']?.toString() ?? '');
  DateTime? updated;
  final updateAt = fileData['UpdateAt']?.toString();
  if (updateAt != null && updateAt.isNotEmpty) {
    updated = DateTime.tryParse(updateAt);
  }
  final parentId = fileData['ParentFileId']?.toString() ?? '0';
  return CloudDriveFile(
    id: id,
    name: name,
    size: size,
    updatedAt: updated,
    isFolder: isFolder,
    folderId: parentId,
  );
}
