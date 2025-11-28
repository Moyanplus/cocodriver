import '../../../base/base_cloud_drive_repository.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../api/ali_api_client.dart';
import '../models/requests/ali_list_request.dart';
import '../models/requests/ali_operation_requests.dart';

/// 阿里云盘仓库，适配统一仓库接口。
class AliRepository extends BaseCloudDriveRepository {
  AliRepository({AliApiClient? client}) : _client = client ?? AliApiClient();

  final AliApiClient _client;

  @override
  Future<List<CloudDriveFile>> listFiles({
    required CloudDriveAccount account,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final driveId = await _client.getDriveId(account);
    if (driveId == null) return [];
    final request = AliListRequest(
      parentFileId: folderId ?? 'root',
      page: page,
      pageSize: pageSize,
    );
    final response = await _client.listFiles(
      account: account,
      driveId: driveId,
      request: request,
    );
    return response.files;
  }

  @override
  Future<bool> delete({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) {
    final req = AliDeleteRequest(file: file);
    return _client
        .deleteFile(account: account, request: req)
        .then((r) => r.success);
  }

  @override
  Future<bool> rename({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) {
    final req = AliRenameRequest(file: file, newName: newName);
    return _client
        .renameFile(account: account, request: req)
        .then((r) => r.success);
  }

  @override
  Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required String name,
    String? parentId,
    String? description,
  }) {
    final req = AliCreateFolderRequest(name: name, parentId: parentId);
    return _client.createFolder(account: account, request: req);
  }

  @override
  Future<bool> move({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) {
    final req = AliMoveRequest(file: file, targetFolderId: targetFolderId);
    return _client
        .moveFile(account: account, request: req)
        .then((r) => r.success);
  }

  @override
  Future<bool> copy({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) {
    final req = AliCopyRequest(file: file, targetFolderId: targetFolderId);
    return _client
        .copyFile(account: account, request: req)
        .then((r) => r.success);
  }

  @override
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    // TODO: 阿里云盘分享逻辑待实现
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
    final driveId = await _client.getDriveId(account);
    if (driveId == null) return null;
    final req = AliDownloadRequest(file: file, driveId: driveId);
    return _client.getDownloadUrl(account: account, request: req);
  }
}
