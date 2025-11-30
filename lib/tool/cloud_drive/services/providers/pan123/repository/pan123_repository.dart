import '../../../../base/cloud_drive_operation_service.dart';
import '../../../../data/models/cloud_drive_dtos.dart'
    show CloudDriveAccountInfo, CloudDriveQuotaInfo;
import '../../../../data/models/cloud_drive_entities.dart';
import '../../../../base/base_cloud_drive_repository.dart';
import '../../../../core/result.dart';
import '../api/pan123_api_client.dart';
import '../api/pan123_operations.dart';
import '../models/requests/pan123_list_request.dart';
import '../models/requests/pan123_operation_requests.dart';
import '../models/requests/pan123_offline_requests.dart';
import '../models/requests/pan123_share_requests.dart';
import '../models/responses/pan123_offline_responses.dart';
import '../models/responses/pan123_share_list_response.dart';
import '../models/responses/pan123_share_cancel_response.dart';

/// 123 云盘仓库，适配统一仓库接口。
class Pan123Repository extends BaseCloudDriveRepository {
  Pan123Repository({Pan123ApiClient? apiClient})
    : _api = apiClient ?? Pan123ApiClient();

  final Pan123ApiClient _api;

  /// 列出指定文件夹的内容
  ///
  /// [account] 当前账号
  /// [folderId] 目标文件夹
  /// [page] 分页页码
  /// [pageSize] 单页数量
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

  /// 离线解析
  Future<Pan123OfflineResolveResponse> resolveOffline({
    required CloudDriveAccount account,
    required String url,
  }) {
    return _api.resolveOffline(
      account: account,
      request: Pan123OfflineResolveRequest(url: url),
    );
  }

  /// 离线提交任务
  Future<Pan123OfflineSubmitResponse> submitOffline({
    required CloudDriveAccount account,
    required int resourceId,
    required List<int> selectFileIds,
  }) {
    return _api.submitOffline(
      account: account,
      request: Pan123OfflineSubmitRequest(
        resourceId: resourceId,
        selectFileIds: selectFileIds,
      ),
    );
  }

  /// 离线任务列表
  Future<Pan123OfflineTaskListResponse> listOfflineTasks({
    required CloudDriveAccount account,
    int page = 1,
    int pageSize = 15,
    List<int> status = const [0, 1, 2, 3, 4],
  }) {
    return _api.listOfflineTasks(
      account: account,
      request: Pan123OfflineListRequest(
        page: page,
        pageSize: pageSize,
        status: status,
      ),
    );
  }

  /// 搜索文件列表（仅 Pan123 使用，未纳入通用接口）
  @override
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

  /// 回收站列表
  @override
  Future<List<CloudDriveFile>> listRecycle({
    required CloudDriveAccount account,
    int page = 1,
    int pageSize = 100,
  }) {
    final request = Pan123ListRequest(
      parentId: '0',
      page: page,
      pageSize: pageSize,
      trashed: true,
      orderBy: 'trashed_at',
      orderDirection: 'desc',
      event: 'recycleListFile',
      next: '-1',
    );
    return _api.listFiles(account: account, request: request).then((r) {
      logListSummary('123云盘-回收站', r.files, folderId: 'recycle');
      return r.files;
    });
  }

  /// 删除单个文件或文件夹
  @override
  Future<bool> delete({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) {
    final req = Pan123DeleteRequest(file: file);
    return _api.deleteFile(account: account, request: req);
  }

  /// 重命名文件
  @override
  Future<bool> rename({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) {
    final req = Pan123RenameRequest(file: file, newName: newName);
    return _api.renameFile(account: account, request: req);
  }

  /// 创建文件夹
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

  /// 移动文件到指定目录
  @override
  Future<bool> move({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) {
    final req = Pan123MoveRequest(file: file, targetParentId: targetFolderId);
    return _api.moveFile(account: account, request: req);
  }

  /// 复制文件到目标目录
  @override
  Future<bool> copy({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) {
    final req = Pan123CopyRequest(file: file, targetParentId: targetFolderId);
    return _api.copyFile(account: account, request: req);
  }

  /// 创建分享链接（暂未实现，返回 null）
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

  /// 获取文件的直链地址
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

  /// 获取账号详情
  @override
  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    try {
      final info = await _api.getUserInfo(account: account);
      final used = info.used;
      final total = info.total;
      return CloudDriveAccountDetails(
        id: account.id,
        name: info.nickname.isNotEmpty ? info.nickname : account.name,
        avatarUrl: info.avatar,
        usedSpace: used,
        totalSpace: total,
        freeSpace: total - used,
        isValid: true,
        accountInfo: info.toAccountInfo(),
        quotaInfo: CloudDriveQuotaInfo(
          total: total,
          used: used,
          free: total - used,
        expire: false,
        serverTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ),
    );
    } on CloudDriveException catch (e) {
      final isAuthError =
          e.type == CloudDriveErrorType.authentication || e.statusCode == 401;

      if (isAuthError) {
        return CloudDriveAccountDetails(
          id: account.id,
          name: account.name,
          isValid: false,
          accountInfo: CloudDriveAccountInfo(
            username: account.name,
            phone: null,
            photo: account.avatarUrl,
            uk: 0,
            loginState: 0,
          ),
          quotaInfo: null,
        );
      }

      rethrow;
    }
  }

  /// 获取分享列表（免费/付费；付费列表 isPaid=true）
  Future<Pan123ShareListResponse> listShares({
    required CloudDriveAccount account,
    bool isPaid = false,
    int limit = 20,
    String next = '0',
    String orderBy = 'fileId',
    String orderDirection = 'desc',
    String search = '',
  }) {
    final req = Pan123ShareListRequest(
      limit: limit,
      next: next,
      orderBy: orderBy,
      orderDirection: orderDirection,
      search: search,
      isPaid: isPaid,
    );
    return _api.listShares(account: account, request: req);
  }

  /// 上传文件（单分片）
  @override
  Future<CloudDriveFile?> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String? parentId,
    UploadProgressCallback? onProgress,
  }) {
    return Pan123Operations.uploadFile(
      account: account,
      filePath: filePath,
      fileName: fileName,
      parentId: parentId,
      onProgress: onProgress,
    );
  }

  /// 取消分享（免费/付费；isPaidShare 控制接口字段）
  Future<Pan123ShareCancelResponse> cancelShare({
    required CloudDriveAccount account,
    required List<int> shareIds,
    bool isPaidShare = false,
  }) {
    final req = Pan123ShareCancelRequest(
      shareIds: shareIds,
      isPaidShare: isPaidShare,
    );
    return _api.cancelShare(account: account, request: req);
  }
}
