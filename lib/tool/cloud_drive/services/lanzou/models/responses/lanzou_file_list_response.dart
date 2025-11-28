/// 文件/文件夹列表响应
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
        downloads: _asInt(map['downs']),
        isLock: _asBool(map['is_lock']),
        fileLock: _asBool(map['f_l']),
        isBakDownload: _asBool(map['is_bakdown']),
        isCopyright: _asBool(map['is_copyright']),
        isDescription: _asBool(map['is_des']),
        isIcon: _asBool(map['is_icon']),
        onOff: map['onof']?.toString(),
        bakDownload: map['bakdown']?.toString(),
      );
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

  factory LanzouRawFolder.fromMap(Map<String, dynamic> map) => LanzouRawFolder(
        id: map['folderid']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        time: map['t']?.toString(),
      );
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  return int.tryParse(value.toString());
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final str = value.toString();
  return str == '1' || str.toLowerCase() == 'true';
}
