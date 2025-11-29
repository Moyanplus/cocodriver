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
      logger.cloudDrive('[$provider] 文件夹示例: ${jsonEncode(_fileToMap(folder))}');
    }
    for (final file in files.take(sampleCount)) {
      logger.cloudDrive('[$provider] 文件示例: ${jsonEncode(_fileToMap(file))}');
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
      'category': file.category,
      'downloadCount': file.downloadCount,
      'shareCount': file.shareCount,
      'metadata': file.metadata,
    };
  }
}
