import '../../base/base_cloud_drive_repository.dart';
import '../../data/models/cloud_drive_entities.dart';
import 'core/china_mobile_config.dart';
import 'services/china_mobile_file_list_service.dart';
import 'services/china_mobile_file_operation_service.dart';
import 'services/china_mobile_download_service.dart';
import 'services/china_mobile_share_service.dart';

/// 中国移动云盘仓库，适配统一仓库接口。
class ChinaMobileRepository extends BaseCloudDriveRepository {
  @override
  Future<List<CloudDriveFile>> listFiles({
    required CloudDriveAccount account,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  }) async {
    return ChinaMobileFileListService.getFileList(
      account: account,
      parentFileId: folderId ?? ChinaMobileConfig.rootFolderId,
      pageSize: pageSize,
    );
  }

  @override
  Future<bool> delete({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) {
    return ChinaMobileFileOperationService.deleteFile(
      account: account,
      file: file,
    );
  }

  @override
  Future<bool> rename({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) {
    return ChinaMobileFileOperationService.renameFile(
      account: account,
      file: file,
      newName: newName,
    );
  }

  @override
  Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required String name,
    String? parentId,
    String? description,
  }) async {
    // 暂不支持创建文件夹，返回 null
    return null;
  }

  @override
  Future<bool> move({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) {
    return ChinaMobileFileOperationService.moveFile(
      account: account,
      file: file,
      targetFolderId: targetFolderId,
    );
  }

  @override
  Future<bool> copy({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) async {
    // 中国移动云盘暂不支持复制，保持 false
    return false;
  }

  @override
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    // 分享暂未实现
    return null;
  }

  @override
  Future<String?> getDirectLink({
    CloudDriveAccount? account,
    CloudDriveFile? file,
    String? shareUrl,
    String? password,
  }) async {
    if (account == null || file == null) return null;
    return ChinaMobileDownloadService.getDownloadUrl(
      account: account,
      file: file,
    );
  }
}
