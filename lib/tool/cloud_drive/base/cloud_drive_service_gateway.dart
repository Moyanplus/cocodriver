import '../../../../../core/logging/log_manager.dart';
import '../data/models/cloud_drive_entities.dart';
import 'cloud_drive_operation_service.dart';

/// 云盘操作网关（实例化入口），便于依赖注入与测试。
class CloudDriveServiceGateway {
  CloudDriveServiceGateway({LogManager? logger})
    : _logger = logger ?? LogManager();

  final LogManager _logger;

  CloudDriveOperationStrategy? _strategyOrWarn(CloudDriveAccount account) {
    final strategy = CloudDriveOperationService.getStrategy(account.type);
    if (strategy == null) {
      _logger.warning(
        '策略未找到',
        className: 'CloudDriveServiceGateway',
        data: {'accountType': account.type.name, 'accountName': account.name},
      );
    }
    return strategy;
  }

  /// 暴露策略获取（需要直接访问策略方法时使用）
  CloudDriveOperationStrategy? strategyFor(CloudDriveAccount account) =>
      _strategyOrWarn(account);

  Future<List<CloudDriveFile>> listFiles({
    required CloudDriveAccount account,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final strategy = _strategyOrWarn(account);
    if (strategy == null) return [];
    return strategy.getFileList(
      account: account,
      folderId: folderId,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) async {
    final strategy = _strategyOrWarn(account);
    if (strategy == null) return false;
    return strategy.moveFile(
      account: account,
      file: file,
      targetFolderId: targetFolderId,
    );
  }

  Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
    String? newName,
  }) async {
    final strategy = _strategyOrWarn(account);
    if (strategy == null) return false;
    return strategy.copyFile(
      account: account,
      file: file,
      destPath: targetFolderId,
      newName: newName,
    );
  }

  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    final strategy = _strategyOrWarn(account);
    if (strategy == null) return null;
    return strategy.createShareLink(
      account: account,
      files: files,
      password: password,
      expireDays: expireDays,
    );
  }

  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    final strategy = _strategyOrWarn(account);
    if (strategy == null) return null;
    return strategy.getDownloadUrl(account: account, file: file);
  }

  Future<CloudDrivePreviewResult?> getPreviewInfo({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    final strategy = _strategyOrWarn(account);
    if (strategy == null) return null;
    return strategy.getPreviewInfo(account: account, file: file);
  }

  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    final strategy = _strategyOrWarn(account);
    if (strategy == null) return false;
    return strategy.deleteFile(account: account, file: file);
  }

  Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    final strategy = _strategyOrWarn(account);
    if (strategy == null) return false;
    return strategy.renameFile(account: account, file: file, newName: newName);
  }

  Map<String, bool> getSupportedOperations(CloudDriveAccount account) {
    final strategy = _strategyOrWarn(account);
    return strategy?.getSupportedOperations() ?? const {};
  }

  Future<Map<String, dynamic>> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String? folderId,
    UploadProgressCallback? onProgress,
  }) async {
    final strategy = _strategyOrWarn(account);
    if (strategy == null) {
      return {'success': false, 'message': '策略未注册'};
    }
    return strategy.uploadFile(
      account: account,
      filePath: filePath,
      fileName: fileName,
      folderId: folderId,
      onProgress: onProgress,
    );
  }

  Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required String name,
    String? parentId,
  }) async {
    final strategy = _strategyOrWarn(account);
    if (strategy == null) return null;
    final result = await strategy.createFolder(
      account: account,
      folderName: name,
      parentFolderId: parentId,
    );
    // 部分策略返回 Map，统一转回 CloudDriveFile 由调用方处理，这里仅透传。
    return result?['folder'] as CloudDriveFile?;
  }
}

/// 过渡期默认单例，便于逐步从静态方法迁移。
final CloudDriveServiceGateway defaultCloudDriveGateway =
    CloudDriveServiceGateway();
