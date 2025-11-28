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
}
