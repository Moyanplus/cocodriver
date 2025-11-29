import '../../../../data/models/cloud_drive_entities.dart';
import '../../../../base/base_cloud_drive_repository.dart';
import '../api/pan123_api_client.dart';
import '../models/requests/pan123_list_request.dart';
import '../models/requests/pan123_operation_requests.dart';

/// 123 云盘仓库，适配统一仓库接口。
class Pan123Repository extends BaseCloudDriveRepository {
  Pan123Repository({Pan123ApiClient? apiClient})
    : _api = apiClient ?? Pan123ApiClient();

  final Pan123ApiClient _api;

  @override
  Future<List<CloudDriveFile>> listFiles({
    required CloudDriveAccount account,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  }) {
    final request = Pan123ListRequest(
      parentId: folderId ?? '0',
      page: page,
      pageSize: pageSize,
    );
    return _api.listFiles(account: account, request: request).then((r) {
      logListSummary('123云盘', r.files, folderId: request.parentId);
      return r.files;
    });
  }

  /// 搜索文件列表（仅 Pan123 使用，未纳入通用接口）
  Future<List<CloudDriveFile>> search({
    required CloudDriveAccount account,
    required String keyword,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  }) {
    final request = Pan123ListRequest(
      parentId: folderId ?? '0',
      page: page,
      pageSize: pageSize,
      searchValue: keyword,
    );
    return _api.listFiles(account: account, request: request).then((r) {
      logListSummary('123云盘-搜索', r.files, folderId: request.parentId);
      return r.files;
    });
  }

  @override
  Future<bool> delete({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) {
    final req = Pan123DeleteRequest(file: file);
    return _api.deleteFile(account: account, request: req).then((r) => r.success);
  }

  @override
  Future<bool> rename({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) {
    final req = Pan123RenameRequest(file: file, newName: newName);
    return _api.renameFile(account: account, request: req).then((r) => r.success);
  }

  @override
  Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required String name,
    String? parentId,
    String? description,
  }) async {
    final req = Pan123CreateFolderRequest(name: name, parentId: parentId);
    return _api.createFolder(account: account, request: req);
  }

  @override
  Future<bool> move({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) {
    final req = Pan123MoveRequest(
      file: file,
      targetParentId: targetFolderId,
    );
    return _api.moveFile(account: account, request: req).then((r) => r.success);
  }

  @override
  Future<bool> copy({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) {
    final req = Pan123CopyRequest(
      file: file,
      targetParentId: targetFolderId,
    );
    return _api.copyFile(account: account, request: req).then((r) => r.success);
  }

  @override
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    // TODO: 分享逻辑待实现
    return null;
  }

  @override
  Future<String?> getDirectLink({
    CloudDriveAccount? account,
    CloudDriveFile? file,
    String? shareUrl,
    String? password,
  }) {
    if (account == null || file == null) return Future.value(null);
    final req = Pan123DownloadRequest(file: file);
    return _api.getDownloadUrl(account: account, request: req);
  }
}
