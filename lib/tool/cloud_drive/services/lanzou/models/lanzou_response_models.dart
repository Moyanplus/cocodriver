/// 蓝奏云 API 基础响应模型集合。
///
/// 这些模型用于 Repository 层解析接口返回的数据，避免在业务逻辑中
/// 直接操作 Map 结构。

class LanzouFilesResponse {
  const LanzouFilesResponse({
    required this.success,
    this.info,
    required this.items,
  });

  final bool success;
  final String? info;
  final List<LanzouRawFile> items;

  factory LanzouFilesResponse.fromMap(Map<String, dynamic> map) {
    final items = <LanzouRawFile>[];
    final rawList = map['text'] as List<dynamic>? ?? [];
    for (final raw in rawList) {
      if (raw is Map<String, dynamic>) {
        items.add(LanzouRawFile.fromMap(raw));
      }
    }
    return LanzouFilesResponse(
      success: (map['zt'] ?? 0) == 1,
      info: map['info']?.toString(),
      items: items,
    );
  }
}

class LanzouFoldersResponse {
  const LanzouFoldersResponse({
    required this.success,
    this.info,
    required this.items,
  });

  final bool success;
  final String? info;
  final List<LanzouRawFolder> items;

  factory LanzouFoldersResponse.fromMap(Map<String, dynamic> map) {
    final rawList = map['text'] as List<dynamic>? ?? [];
    final items = <LanzouRawFolder>[];
    for (final raw in rawList) {
      if (raw is Map<String, dynamic>) {
        items.add(LanzouRawFolder.fromMap(raw));
      }
    }
    final infoField = map['info'];
    final bool infoIsFolderMeta =
        infoField is List &&
        infoField.isNotEmpty &&
        infoField.first is Map &&
        ((infoField.first as Map).containsKey('folderid') ||
            (infoField.first as Map).containsKey('now'));
    return LanzouFoldersResponse(
      success: (map['zt'] ?? 0) == 1 || infoIsFolderMeta,
      info: infoIsFolderMeta ? null : infoField?.toString(),
      items: items,
    );
  }
}

class LanzouOperationResponse {
  const LanzouOperationResponse({
    required this.success,
    this.info,
  });

  final bool success;
  final String? info;

  factory LanzouOperationResponse.fromMap(Map<String, dynamic> map) =>
      LanzouOperationResponse(
        success: (map['zt'] ?? 0) == 1,
        info: map['info']?.toString(),
      );
}

class LanzouRawFile {
  const LanzouRawFile({
    required this.id,
    required this.name,
    this.displayName,
    this.size,
    this.time,
    this.icon,
    this.downloads,
    this.isLock,
    this.fileLock,
    this.isBakDownload,
    this.isCopyright,
    this.isDescription,
    this.isIcon,
    this.onOff,
    this.bakDownload,
  });

  final String id;
  final String name;
  final String? displayName;
  final String? size;
  final String? time;
  final String? icon;
  final int? downloads;
  final bool? isLock;
  final bool? fileLock;
  final bool? isBakDownload;
  final bool? isCopyright;
  final bool? isDescription;
  final bool? isIcon;
  final String? onOff;
  final String? bakDownload;

  factory LanzouRawFile.fromMap(Map<String, dynamic> map) => LanzouRawFile(
    id: map['id']?.toString() ?? '',
    name: map['name']?.toString() ?? '',
    displayName: map['name_all']?.toString(),
    size: map['size']?.toString(),
    time: map['time']?.toString(),
    icon: map['icon']?.toString(),
    downloads: _tryParseInt(map['downs']),
    isLock: _parseFlag(map['is_lock']),
    fileLock: _parseFlag(map['filelock']),
    isBakDownload: _parseFlag(map['is_bakdownload']),
    isCopyright: _parseFlag(map['is_copyright']),
    isDescription: _parseFlag(map['is_des']),
    isIcon: _parseFlag(map['is_ico']),
    onOff: map['onof']?.toString(),
    bakDownload: map['bakdownload']?.toString(),
  );

  static int? _tryParseInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static bool? _parseFlag(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim().toLowerCase();
    if (str == '1' || str == 'true') return true;
    if (str == '0' || str == 'false') return false;
    return null;
  }
}

class LanzouRawFolder {
  const LanzouRawFolder({
    required this.id,
    required this.name,
    this.time,
  });

  final String id;
  final String name;
  final String? time;

  factory LanzouRawFolder.fromMap(Map<String, dynamic> map) {
    final rawId = map['fol_id'] ?? map['id'];
    final rawName = map['name'] ?? map['name_all'];
    return LanzouRawFolder(
      id: rawId?.toString() ?? '',
      name: rawName?.toString() ?? '',
      time: map['time']?.toString(),
    );
  }
}
