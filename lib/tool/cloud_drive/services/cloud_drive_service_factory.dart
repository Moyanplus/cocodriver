import '../../../../../core/logging/log_manager.dart';
import '../data/models/cloud_drive_entities.dart';
import '../core/result.dart';
import 'file_operation_service.dart';
import 'download_service.dart';
import 'account_service.dart';
import 'cache_service.dart';

/// 云盘服务工厂 - 统一的服务访问入口
class CloudDriveServiceFactory {
  static final Map<CloudDriveType, CloudDriveServiceFactory> _instances = {};

  final CloudDriveType _type;
  late final FileOperationService _fileOperationService;
  late final DownloadService _downloadService;
  late final AccountService _accountService;
  late final CacheService _cacheService;

  CloudDriveServiceFactory._(this._type) {
    _initializeServices();
  }

  /// 获取服务工厂实例
  static CloudDriveServiceFactory getInstance(CloudDriveType type) {
    if (!_instances.containsKey(type)) {
      _instances[type] = CloudDriveServiceFactory._(type);
      LogManager().cloudDrive('🏭 创建服务工厂: ${type.displayName}');
    }
    return _instances[type]!;
  }

  /// 初始化服务
  void _initializeServices() {
    _fileOperationService = FileOperationService(_type);
    _downloadService = DownloadService(_type);
    _accountService = AccountService(_type);
    _cacheService = CacheService(_type);

    LogManager().cloudDrive('🔧 初始化服务: ${_type.displayName}');
  }

  /// 获取文件操作服务
  FileOperationService get fileOperationService => _fileOperationService;

  /// 获取下载服务
  DownloadService get downloadService => _downloadService;

  /// 获取账号服务
  AccountService get accountService => _accountService;

  /// 获取缓存服务
  CacheService get cacheService => _cacheService;

  /// 重置所有服务
  static void resetAll() {
    LogManager().cloudDrive('🔄 重置所有服务工厂');
    _instances.clear();
  }
}

/// 云盘服务基类
abstract class CloudDriveService {
  final CloudDriveType type;

  CloudDriveService(this.type);

  /// 获取服务名称
  String get serviceName => runtimeType.toString();

  /// 记录操作日志
  void logOperation(String operation, {Map<String, dynamic>? params}) {
    LogManager().cloudDrive('🔧 $serviceName - $operation');
    if (params != null) {
      for (final entry in params.entries) {
        LogManager().cloudDrive('📋 ${entry.key}: ${entry.value}');
      }
    }
  }

  /// 记录成功日志
  void logSuccess(String operation, {String? details}) {
    final message = details != null ? '$operation: $details' : operation;
    LogManager().cloudDrive('✅ $serviceName - $message');
  }

  /// 记录错误日志
  void logError(String operation, dynamic error) {
    LogManager().error('❌ $serviceName - $operation 失败: $error');
  }

  /// 记录警告日志
  void logWarning(String operation, String message) {
    LogManager().warning('⚠️ $serviceName - $operation: $message');
  }
}
