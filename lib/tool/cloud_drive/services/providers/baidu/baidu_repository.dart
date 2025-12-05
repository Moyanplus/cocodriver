import '../../../base/base_cloud_drive_repository.dart';
import '../../../data/models/cloud_drive_entities.dart';
import 'api/baidu_api_client.dart';
import 'models/requests/baidu_list_request.dart';
import 'models/requests/baidu_operation_requests.dart';
import 'models/responses/baidu_share_record.dart';
import '../../shared/path_utils.dart';

/// 百度网盘仓库，适配统一的云盘仓库接口。
class BaiduRepository extends BaseCloudDriveRepository {
  BaiduRepository({BaiduApiClient? api}) : _api = api ?? BaiduApiClient();

  final BaiduApiClient _api;

  @override
  Future<List<CloudDriveFile>> listFiles({
    required CloudDriveAccount account,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final req = BaiduListRequest(
      folderId: folderId ?? '/',
      page: page,
      pageSize: pageSize,
    );
    final res = await _api.listFiles(account: account, request: req);
    final files = [...res.folders, ...res.files];
    logListSummary('百度网盘', files, folderId: req.folderId);
    return files;
  }

  @override
  Future<bool> delete({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) {
    final srcPath = CloudDrivePathUtils.resolvePath(file);
    final req = BaiduDeleteRequest(file: file, sourcePath: srcPath);
    return _api
        .deleteFile(account: account, request: req)
        .then((r) => r.success);
  }

  @override
  Future<bool> rename({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) {
    final srcPath = CloudDrivePathUtils.resolvePath(file);
    final req = BaiduRenameRequest(
      file: file,
      newName: newName,
      sourcePath: srcPath,
    );
    return _api
        .renameFile(account: account, request: req)
        .then((r) => r.success);
  }

  @override
  Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required String name,
    String? parentId,
    String? description,
  }) async {
    final req = BaiduCreateFolderRequest(name: name, parentId: parentId);
    return _api.createFolder(account: account, request: req);
  }

  @override
  Future<bool> move({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) {
    final srcPath = CloudDrivePathUtils.resolvePath(file);
    final destPath =
        targetFolderId.isNotEmpty && targetFolderId.startsWith('/')
            ? targetFolderId
            : '/';
    final req = BaiduMoveRequest(
      file: file,
      targetFolderId: destPath,
      sourcePath: srcPath,
    );
    return _api.moveFile(account: account, request: req).then((r) => r.success);
  }

  @override
  Future<bool> copy({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) {
    final srcPath = CloudDrivePathUtils.resolvePath(file);
    final destPath =
        targetFolderId.isNotEmpty && targetFolderId.startsWith('/')
            ? targetFolderId
            : '/';
    final req = BaiduCopyRequest(
      file: file,
      targetFolderId: destPath,
      sourcePath: srcPath,
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
    if (files.isEmpty) return null;
    return _api.createShareLink(
      account: account,
      files: files,
      password: password,
      expireDays: expireDays,
    );
  }

  @override
  Future<String?> getDirectLink({
    CloudDriveAccount? account,
    CloudDriveFile? file,
    String? shareUrl,
    String? password,
  }) async {
    if (account == null || file == null) return null;
    final req = BaiduDownloadRequest(file: file);
    return _api.getDownloadUrl(account: account, request: req);
  }

  /// 获取分享记录
  Future<List<BaiduShareRecord>> listShareRecords({
    required CloudDriveAccount account,
    int page = 1,
    int pageSize = 50,
  }) {
    return _api.listShareRecords(
      account: account,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<List<CloudDriveFile>> listRecycle({
    required CloudDriveAccount account,
    int page = 1,
    int pageSize = 100,
  }) {
    return _api.listRecycle(account: account, page: page, pageSize: pageSize);
  }
}
