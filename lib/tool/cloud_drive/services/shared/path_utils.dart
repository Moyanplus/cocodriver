import '../../data/models/cloud_drive_entities.dart';

/// 文件/路径工具，避免各云盘重复计算。
class CloudDrivePathUtils {
  /// 解析文件的完整路径；如果已有 path 直接返回，否则用 folderId+name 兜底。
  static String resolvePath(CloudDriveFile file) {
    if (file.path != null && file.path!.isNotEmpty) return file.path!;
    final folder = file.folderId;
    if (folder != null && folder.isNotEmpty) {
      return '${folder.endsWith('/') ? folder : '$folder/'}${file.name}';
    }
    return '/${file.name}';
  }

  /// 连接目录与文件名，自动补齐斜杠。
  static String join(String parent, String name) =>
      '${parent.endsWith('/') ? parent : '$parent/'}$name';
}
