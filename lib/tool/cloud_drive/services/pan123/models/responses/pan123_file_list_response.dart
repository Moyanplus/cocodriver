import '../../../../data/models/cloud_drive_entities.dart';

class Pan123FileListResponse {
  const Pan123FileListResponse({
    required this.code,
    this.message,
    this.data,
  });

  final int code;
  final String? message;
  final Pan123ListData? data;

  bool get success => code == 0 || code == 200;
  List<CloudDriveFile> get files => data?.files ?? const [];

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

class Pan123ListData {
  const Pan123ListData({
    required this.next,
    required this.total,
    required this.items,
  });

  final int next;
  final int total;
  final List<CloudDriveFile> items;

  List<CloudDriveFile> get files => items;

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

CloudDriveFile? _mapFile(Map<String, dynamic> fileData) {
  final id = fileData['FileId']?.toString();
  final name = fileData['FileName']?.toString();
  if (id == null || name == null) return null;
  final type = fileData['Type'] as int? ?? 0;
  final isFolder = type == 1;
  final size = int.tryParse(fileData['Size']?.toString() ?? '');
  DateTime? modified;
  final updateAt = fileData['UpdateAt']?.toString();
  if (updateAt != null && updateAt.isNotEmpty) {
    modified = DateTime.tryParse(updateAt);
  }
  final parentId = fileData['ParentFileId']?.toString() ?? '0';
  return CloudDriveFile(
    id: id,
    name: name,
    size: size,
    modifiedTime: modified,
    isFolder: isFolder,
    folderId: parentId,
  );
}
