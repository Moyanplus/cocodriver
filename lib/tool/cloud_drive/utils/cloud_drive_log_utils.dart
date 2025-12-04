import 'dart:convert';

import '../../../core/logging/log_manager.dart';
import '../data/models/cloud_drive_entities.dart';

/// 统一的云盘日志工具，输出文件/文件夹列表示例。
class CloudDriveLogUtils {
  CloudDriveLogUtils._();

  /// 打印文件列表概览与示例。
  static void logFileListSummary({
    required String provider,
    required List<CloudDriveFile> files,
    required List<CloudDriveFile> folders,
    int sampleCount = 5,
  }) {
    final logger = LogManager();
    logger.cloudDrive(
      '[$provider] 文件列表获取成功: ${files.length} 个文件, ${folders.length} 个文件夹',
    );
    for (final folder in folders.take(sampleCount)) {
      logger.cloudDrive(
        '[$provider] 文件夹示例: ${_safeEncode(_fileToMap(folder))}',
      );
    }
    for (final file in files.take(sampleCount)) {
      logger.cloudDrive(
        '[$provider] 文件示例: ${_safeEncode(_fileToMap(file))}',
      );
    }
  }

  static Map<String, dynamic> _fileToMap(CloudDriveFile file) {
    return {
      'id': file.id,
      'name': file.name,
      'isFolder': file.isFolder,
      'folderId': file.folderId,
      'size': file.size,
      'createdAt': file.createdAt?.toIso8601String(),
      'updatedAt': file.updatedAt?.toIso8601String(),
      'path': file.path,
      'downloadUrl': file.downloadUrl,
      'thumbnailUrl': file.thumbnailUrl,
      // 把枚举转成可 JSON 序列化的字符串，避免 jsonEncode 报错
      'category': file.category?.name,
      'downloadCount': file.downloadCount,
      'shareCount': file.shareCount,
      'metadata': _sanitizeForJson(file.metadata),
    };
  }

  /// 将任意对象转换为可 JSON 序列化的结构，递归处理 Map/List/Enum。
  static dynamic _sanitizeForJson(dynamic value) {
    if (value == null) return null;
    if (value is Enum) return value.name;
    if (value is DateTime) return value.toIso8601String();
    if (value is num || value is bool || value is String) return value;
    if (value is Map) {
      return value.map(
        (key, v) => MapEntry(key.toString(), _sanitizeForJson(v)),
      );
    }
    if (value is Iterable) {
      return value.map(_sanitizeForJson).toList();
    }
    return value.toString();
  }

  /// 尝试 jsonEncode，失败时用 toString 兜底，避免打断业务流程。
  static String _safeEncode(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      return data.toString();
    }
  }
}
