import '../../../core/logging/log_manager.dart';
import '../data/models/cloud_drive_entities.dart';

/// 各云盘 Repository 的统一接口定义。
///
/// 新增云盘时建议继承本类，保证能力覆盖与签名一致，减少遗漏。
abstract class BaseCloudDriveRepository {
  /// 获取文件/文件夹列表。
  Future<List<CloudDriveFile>> listFiles({
    required CloudDriveAccount account,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  });

  /// 删除文件或文件夹。
  Future<bool> delete({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  });

  /// 重命名文件或文件夹。
  Future<bool> rename({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  });

  /// 创建文件夹，返回新建的文件夹信息或 null。
  Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required String name,
    String? parentId,
    String? description,
  });

  /// 移动/复制：部分云盘 copy 与 move 可能使用同一接口。
  Future<bool> move({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  });

  Future<bool> copy({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  });

  /// 分享链接创建，返回分享 URL。
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  });

  /// 获取直链或下载链接。
  Future<String?> getDirectLink({
    CloudDriveAccount? account,
    CloudDriveFile? file,
    String? shareUrl,
    String? password,
  });

  /// 获取预览信息，默认返回 null，由具体云盘按需实现。
  Future<CloudDrivePreviewResult?> getPreviewInfo({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    LogManager().cloudDrive(
      '${account.type.displayName} 尚未实现预览接口',
      className: runtimeType.toString(),
      methodName: 'getPreviewInfo',
      data: {'fileId': file.id, 'fileName': file.name},
    );
    return null;
  }

  /// 统一的列表结果日志，避免各云盘重复实现。
  void logListSummary(
    String provider,
    List<CloudDriveFile> files, {
    String? folderId,
    int sampleCount = 2,
  }) {
    if (files.isEmpty) {
      LogManager()
          .cloudDrive('$provider 列表为空${folderId != null ? ' folder=$folderId' : ''}');
      return;
    }

    String fmt(dynamic v) => v?.toString() ?? 'null';

    // 只展示一个文件夹和一个文件（如果存在）
    final samplesList = <CloudDriveFile>{};
    final folderSample =
        files.firstWhere((f) => f.isFolder, orElse: () => files.first);
    samplesList.add(folderSample);
    final fileSample =
        files.firstWhere((f) => !f.isFolder, orElse: () => folderSample);
    samplesList.add(fileSample);

    final samples = samplesList.map((f) {
      final kind = f.isFolder ? 'folder' : 'file';
      return [
        'id=${fmt(f.id)}',
        'name=${fmt(f.name)}',
        'type=$kind',
        'size=${fmt(f.size)}',
        'createdAt=${fmt(f.createdAt)}',
        'updatedAt=${fmt(f.updatedAt)}',
        'parent=${fmt(f.folderId)}',
        'path=${fmt(f.path)}',
        'downloadUrl=${fmt(f.downloadUrl)}',
        'thumbnailUrl=${fmt(f.thumbnailUrl)}',
        'bigThumbnailUrl=${fmt(f.bigThumbnailUrl)}',
        'previewUrl=${fmt(f.previewUrl)}',
        'description=${fmt(f.description)}',
        'category=${fmt(f.category?.name)}',
        'downloadCount=${f.downloadCount}',
        'shareCount=${f.shareCount}',
      ].join(', ');
    }).join('\n  - ');

    LogManager().cloudDrive(
      '$provider 列表: total=${files.length}'
      '${folderId != null ? ', folder=$folderId' : ''}'
      ', sample:\n  - $samples',
    );
  }
}
