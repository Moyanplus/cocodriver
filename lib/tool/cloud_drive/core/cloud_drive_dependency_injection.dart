import '../../../../../core/logging/log_manager.dart';
import '../infrastructure/cache/cloud_drive_cache_service.dart';
import '../base/cloud_drive_file_service.dart';
import '../infrastructure/error/cloud_drive_error_handler.dart';
import '../infrastructure/logging/cloud_drive_logger.dart';
import '../data/repositories/cloud_drive_repository.dart';

/// 云盘服务定位器
///
/// 提供依赖注入容器功能，管理各种云盘服务的注册和获取。
class CloudDriveServiceLocator {
  static final Map<Type, dynamic> _services = {};
  static bool _isInitialized = false;

  /// 注册服务
  static void register<T>(T service) {
    _services[T] = service;
    LogManager().cloudDrive('注册服务: ${T.toString()}');
  }

  /// 获取服务
  static T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw StateError('服务未注册: ${T.toString()}');
    }
    return service as T;
  }

  /// 检查服务是否已注册
  static bool isRegistered<T>() => _services.containsKey(T);

  /// 初始化所有核心服务
  static void initialize() {
    if (_isInitialized) {
      LogManager().cloudDrive('服务定位器已初始化，跳过重复初始化');
      return;
    }

    LogManager().cloudDrive('开始初始化云盘服务定位器');

    // 注册核心服务
    register<CloudDriveLogger>(CloudDriveLogger());
    register<CloudDriveErrorHandler>(CloudDriveErrorHandler());
    register<CloudDriveCacheService>(CloudDriveCacheService());
    register<CloudDriveRepository>(CloudDriveRepository());
    register<CloudDriveFileService>(CloudDriveFileService());

    _isInitialized = true;
    LogManager().cloudDrive('云盘服务定位器初始化完成');
  }

  /// 重置所有服务
  static void reset() {
    LogManager().cloudDrive('重置云盘服务定位器');
    _services.clear();
    _isInitialized = false;

    // 清理缓存
    CloudDriveCacheService.clearCache();
    LogManager().cloudDrive('云盘服务定位器重置完成');
  }

  /// 获取所有已注册的服务
  static Map<Type, dynamic> get allServices => Map.unmodifiable(_services);

  /// 检查是否已初始化
  static bool get isInitialized => _isInitialized;
}

/// 云盘服务提供者
///
/// 提供简化的服务访问接口，方便获取各种云盘服务。
class CloudDriveServices {
  /// 获取文件服务
  static CloudDriveFileService get fileService =>
      CloudDriveServiceLocator.get<CloudDriveFileService>();

  /// 获取缓存服务
  static CloudDriveCacheService get cacheService =>
      CloudDriveServiceLocator.get<CloudDriveCacheService>();

  /// 获取数据仓库
  static CloudDriveRepository get repository =>
      CloudDriveServiceLocator.get<CloudDriveRepository>();

  /// 获取日志服务
  static CloudDriveLogger get logger =>
      CloudDriveServiceLocator.get<CloudDriveLogger>();

  /// 获取错误处理器
  static CloudDriveErrorHandler get errorHandler =>
      CloudDriveServiceLocator.get<CloudDriveErrorHandler>();
}
