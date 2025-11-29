import '../../../../../core/logging/log_manager.dart';
import '../data/models/cloud_drive_dtos.dart';
import '../data/models/cloud_drive_entities.dart';
import '../services/registry/cloud_drive_provider_registry.dart';
import '../services/registry/strategy_registry.dart';

typedef UploadProgressCallback = void Function(double progress);

/// 云盘操作策略接口（各云盘实现）。
abstract class CloudDriveOperationStrategy {
  // 查询
  Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? path,
    String? folderId,
    int page,
    int pageSize,
  });

  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  });

  Future<List<CloudDriveFile>> searchFiles({
    required CloudDriveAccount account,
    required String keyword,
    String? folderId,
    int page,
    int pageSize,
    String? fileType,
  });

  // 文件操作
  Future<Map<String, dynamic>> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String? folderId,
    UploadProgressCallback? onProgress,
  });

  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  });

  Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  });

  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  });

  Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String destPath,
    String? newName,
  });

  Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  });

  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  });

  // 分享/下载增强
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  });

  Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  });

  // 配置
  Map<String, bool> getSupportedOperations();
  Map<String, dynamic> getOperationUIConfig();

  // 路径处理
  String convertPathToTargetFolderId(List<PathInfo> folderPath);
  CloudDriveFile updateFilePathForTargetDirectory(
    CloudDriveFile file,
    String targetPath,
  );

  // 账号管理
  Future<CloudDriveAccount?> refreshAuth({required CloudDriveAccount account});
}

/// 策略工厂/注册访问入口（仅保留策略查找，业务调用已移至网关）。
class CloudDriveOperationService {
  /// 根据云盘类型获取策略实例。
  static CloudDriveOperationStrategy? getStrategy(CloudDriveType type) {
    final descriptor = CloudDriveProviderRegistry.get(type);
    final providerId = descriptor?.id ?? type.name;
    final strategy = StrategyRegistry.getStrategyById(providerId);
    if (strategy == null) {
      LogManager().warning(
        '策略未找到',
        className: 'CloudDriveOperationService',
        data: {'type': type.name, 'providerId': providerId},
      );
    }
    return strategy;
  }

  /// 兼容旧调用：判断某操作是否受支持。
  static bool isOperationSupported(
    CloudDriveAccount account,
    String operation,
  ) {
    final strategy = getStrategy(account.type);
    if (strategy == null) return false;
    final ops = strategy.getSupportedOperations();
    return ops[operation] ?? false;
  }

  /// 兼容旧调用：获取操作 UI 配置。
  static Map<String, dynamic> getUIConfig(CloudDriveAccount account) {
    final strategy = getStrategy(account.type);
    return strategy?.getOperationUIConfig() ?? {};
  }
}
