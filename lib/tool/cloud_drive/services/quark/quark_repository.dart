import '../../base/base_cloud_drive_repository.dart';
import '../../data/models/cloud_drive_entities.dart';
import 'models/quark_models.dart';
import 'models/requests/quark_file_list_request.dart';
import 'models/requests/quark_file_operation_request.dart';
import 'models/requests/quark_share_request.dart';
import 'services/quark_file_list_service.dart';
import 'services/quark_file_operation_service.dart';
import 'services/quark_download_service.dart';
import 'services/quark_share_service.dart';

/// 夸克云盘仓库，适配统一的云盘仓库接口。
class QuarkRepository extends BaseCloudDriveRepository {
  @override
  Future<List<CloudDriveFile>> listFiles({
    required CloudDriveAccount account,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final request = QuarkFileListRequest(
      parentFolderId: folderId ?? '0',
      page: page,
      pageSize: pageSize,
    );
    final result = await QuarkFileListService.getFileListWithDTO(
      account: account,
      request: request,
    );
    if (result.isSuccess && result.data != null) {
      return result.data!.files;
    }
    return [];
  }

  @override
  Future<bool> delete({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    final req = QuarkDeleteFileRequest(fileIds: [file.id]);
    final result = await QuarkFileOperationService.executeOperation(
      account: account,
      request: req,
    );
    return result.isSuccess;
  }

  @override
  Future<bool> rename({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    final req = QuarkRenameFileRequest(fileId: file.id, newName: newName);
    final result = await QuarkFileOperationService.executeOperation(
      account: account,
      request: req,
    );
    return result.isSuccess;
  }

  @override
  Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required String name,
    String? parentId,
    String? description,
  }) async {
    final created = await QuarkFileOperationService.createFolder(
      account: account,
      folderName: name,
      parentFolderId: parentId,
    );
    if (created == null) return null;
    final folder = created['folder'] as CloudDriveFile?;
    return folder ??
        CloudDriveFile(
          id: created['folderId']?.toString() ?? '',
          name: name,
          isFolder: true,
          folderId: parentId ?? '0',
        );
  }

  @override
  Future<bool> move({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) async {
    final req = QuarkMoveFileRequest(
      targetFolderId: targetFolderId,
      fileIds: [file.id],
    );
    final result = await QuarkFileOperationService.executeOperation(
      account: account,
      request: req,
    );
    return result.isSuccess;
  }

  @override
  Future<bool> copy({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) async {
    final req = QuarkCopyFileRequest(
      targetFolderId: targetFolderId,
      fileIds: [file.id],
    );
    final result = await QuarkFileOperationService.executeOperation(
      account: account,
      request: req,
    );
    return result.isSuccess;
  }

  @override
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    if (files.isEmpty) return null;
    final request = QuarkShareRequest(
      fileIds: files.map((f) => f.id).toList(),
      passcode: password,
      expiredType: expireDays == 1
          ? ShareExpiredType.oneDay
          : expireDays == 7
              ? ShareExpiredType.sevenDays
              : ShareExpiredType.permanent,
    );
    final result = await QuarkShareService.createShareLink(
      account: account,
      request: request,
    );
    if (result.isSuccess && result.data != null) {
      return result.data!.shareUrl;
    }
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
    final size = file.size;
    final result = await QuarkDownloadService.getDownloadUrl(
      account: account,
      fileId: file.id,
      fileName: file.name,
      size: size,
    );
    return result;
  }
}
