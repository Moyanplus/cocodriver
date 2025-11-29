import '../../../base/base_cloud_drive_repository.dart';
import '../../../data/models/cloud_drive_entities.dart';
import 'core/china_mobile_config.dart';
import 'models/china_mobile_models.dart';
import 'api/china_mobile_operations.dart';

/// 中国移动云盘仓库，适配统一仓库接口。
class ChinaMobileRepository extends BaseCloudDriveRepository {
  static const Set<String> _videoExtensions = {
    'mp4',
    'mov',
    'mkv',
    'avi',
    'wmv',
    'flv',
    'ts',
    'm4v',
  };

  @override
  Future<List<CloudDriveFile>> listFiles({
    required CloudDriveAccount account,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final req = ChinaMobileFileListRequest(
      parentFileId: folderId ?? ChinaMobileConfig.rootFolderId,
      pageInfo: PageInfo(pageSize: pageSize),
    );
    final result = await ChinaMobileOperations.listFiles(
      account: account,
      request: req,
    );
    final files =
        result.isSuccess && result.data != null ? result.data!.files : <CloudDriveFile>[];
    logListSummary('中国移动', files, folderId: req.parentFileId);
    return files;
  }

  @override
  Future<bool> delete({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) {
    final req = ChinaMobileDeleteFileRequest(fileIds: [file.id]);
    return ChinaMobileOperations.deleteFile(account: account, request: req);
  }

  @override
  Future<bool> rename({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) {
    final req = ChinaMobileRenameFileRequest(fileId: file.id, name: newName);
    return ChinaMobileOperations.renameFile(account: account, request: req);
  }

  @override
  Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required String name,
    String? parentId,
    String? description,
  }) async {
    final req = ChinaMobileCreateFolderRequest(
      parentFileId: parentId ?? ChinaMobileConfig.rootFolderId,
      name: name,
      description: description ?? '',
    );
    final result = await ChinaMobileOperations.createFolder(
      account: account,
      request: req,
    );
    if (result.isSuccess && result.data != null) {
      final data = result.data!;
      final now = DateTime.now();
      return CloudDriveFile(
        id: data.fileId,
        name: data.fileName,
        isFolder: true,
        folderId: data.parentFileId,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'parentFileId': data.parentFileId,
        },
      );
    }
    return null;
  }

  @override
  Future<bool> move({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) {
    final req = ChinaMobileMoveFileRequest(
      fileIds: [file.id],
      toParentFileId: targetFolderId,
    );
    return ChinaMobileOperations.moveFile(account: account, request: req);
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
    // 旧实现中使用 accountNumber 等字段，这里暂取账号名称为 dedicatedName。
    final fileIds = files.map((f) => f.id).toList();
    final fileName = files.length == 1 ? files.first.name : '批量文件';
    final req = ChinaMobileShareRequest(
      getOutLinkReq: ShareRequestBody(
        subLinkType: 0,
        encrypt: 1,
        coIDLst: fileIds,
        caIDLst: [],
        pubType: 1,
        dedicatedName: fileName,
        periodUnit: 1,
        viewerLst: [],
        extInfo: ShareExtInfo(isWatermark: 0, shareChannel: '3001'),
        commonAccountInfo: CommonAccountInfo(
          account: account.name,
          accountType: 1,
        ),
      ),
    );
    final result = await ChinaMobileOperations.createShareLink(
      account: account,
      request: req,
    );
    if (result.isSuccess && result.data != null) {
      return result.data!['shareUrl'] as String?;
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
    final req = ChinaMobileDownloadRequest(fileId: file.id);
    final result = await ChinaMobileOperations.getDownloadUrl(
      account: account,
      request: req,
    );
    return result.isSuccess && result.data != null ? result.data!.url : null;
  }

  @override
  Future<CloudDrivePreviewResult?> getPreviewInfo({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    final category = _resolvePreviewCategory(file);
    if (category == null) {
      return null;
    }
    final req = ChinaMobilePreviewRequest(
      fileId: file.id,
      category: category,
    );
    final result = await ChinaMobileOperations.getPreviewInfo(
      account: account,
      request: req,
    );
    if (result.isSuccess && result.data != null) {
      return result.data!.toPreviewResult(file);
    }
    return null;
  }

  String? _resolvePreviewCategory(CloudDriveFile file) {
    if (file.category == FileCategory.video) return 'video';
    final extension = file.name.split('.').last.toLowerCase();
    if (_videoExtensions.contains(extension)) return 'video';
    return null;
  }
}
