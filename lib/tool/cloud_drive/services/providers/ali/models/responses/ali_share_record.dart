import '../../../../../data/models/cloud_drive_entities.dart';

/// 阿里云盘分享记录
class AliShareRecord {
  final String shareId;
  final String? shareName;
  final String? shareUrl;
  final String? sharePwd;
  final String? description;
  final String? category;
  final bool expired;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? browseCount;
  final int? saveCount;
  final int? downloadCount;
  final CloudDriveFile? firstFile;

  const AliShareRecord({
    required this.shareId,
    this.shareName,
    this.shareUrl,
    this.sharePwd,
    this.description,
    this.category,
    this.expired = false,
    this.createdAt,
    this.updatedAt,
    this.browseCount,
    this.saveCount,
    this.downloadCount,
    this.firstFile,
  });

  factory AliShareRecord.fromJson(Map<String, dynamic> json) {
    FileCategory? parseCategory(dynamic value) {
      final raw = value?.toString().toLowerCase();
      switch (raw) {
        case 'image':
          return FileCategory.image;
        case 'video':
          return FileCategory.video;
        case 'audio':
          return FileCategory.audio;
        case 'document':
          return FileCategory.document;
        case 'archive':
          return FileCategory.archive;
        default:
          return null;
      }
    }

    CloudDriveFile? firstFile;
    final first = json['first_file'] as Map<String, dynamic>?;
    if (first != null) {
      firstFile = CloudDriveFile(
        id: first['file_id']?.toString() ?? '',
        name:
            first['name']?.toString() ?? (json['share_name']?.toString() ?? ''),
        isFolder:
            first['type']?.toString() == 'folder' ||
            first['content_type']?.toString() == 'folder',
        folderId: first['parent_file_id']?.toString(),
        size: first['size'] as int?,
        createdAt:
            DateTime.tryParse(
              (first['created_at']?.toString() ?? '').replaceFirst('Z', ''),
            )?.toLocal(),
        updatedAt:
            DateTime.tryParse(
              (first['updated_at']?.toString() ?? '').replaceFirst('Z', ''),
            )?.toLocal(),
        thumbnailUrl: first['thumbnail']?.toString(),
        category: parseCategory(first['category']),
        metadata: first,
      );
    }

    DateTime? parseDate(String? value) {
      if (value == null || value.isEmpty) return null;
      final normalized = value.replaceFirst('T', ' ').replaceFirst('Z', '');
      return DateTime.tryParse(normalized)?.toLocal();
    }

    return AliShareRecord(
      shareId: json['share_id']?.toString() ?? '',
      shareName: json['share_name']?.toString(),
      shareUrl: json['share_url']?.toString(),
      sharePwd: json['share_pwd']?.toString() ?? '',
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      expired: json['expired'] as bool? ?? false,
      createdAt: parseDate(json['created_at']?.toString()),
      updatedAt: parseDate(json['updated_at']?.toString()),
      browseCount: json['browse_count'] as int?,
      saveCount: json['save_count'] as int?,
      downloadCount: json['download_count'] as int?,
      firstFile: firstFile,
    );
  }
}
