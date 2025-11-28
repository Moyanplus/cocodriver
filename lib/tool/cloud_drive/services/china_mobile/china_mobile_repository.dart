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
      fileId: file.id,
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
      fileId: file.id,
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
    final created = await ChinaMobileFileOperationService.createFolder(
      account: account,
      folderName: name,
      parentFolderId: parentId ?? ChinaMobileConfig.rootFolderId,
    );
    if (created == null) return null;
    return CloudDriveFile(
      id: created.folderId ?? '',
      name: name,
      isFolder: true,
      folderId: created.parentFolderId ?? ChinaMobileConfig.rootFolderId,
    );
  }

  @override
  Future<bool> move({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) {
    return ChinaMobileFileOperationService.moveFile(
      account: account,
      fileId: file.id,
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
    if (files.isEmpty) return null;
    final result = await ChinaMobileShareService.createShareLink(
      account: account,
      fileId: files.first.id,
      password: password,
      expireDays: expireDays,
    );
    return result;
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
      fileId: file.id,
    );
  }
}
