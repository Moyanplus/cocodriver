import '../base/cloud_drive_cache_service.dart';
import '../base/cloud_drive_file_service.dart';
import '../core/cloud_drive_error_handler.dart';
import '../core/cloud_drive_logger.dart';
import '../repositories/cloud_drive_repository.dart';

/// 云盘依赖注入容器
class CloudDriveDIContainer {
  static final CloudDriveDIContainer _instance =
      CloudDriveDIContainer._internal();

  factory CloudDriveDIContainer() => _instance;

  CloudDriveDIContainer._internal();

  /// 获取单例实例
  static CloudDriveDIContainer get instance => _instance;

  // 服务实例
  late final CloudDriveFileService _fileService;
  late final CloudDriveCacheService _cacheService;
  late final CloudDriveRepository _repository;
  late final CloudDriveLogger _logger;
  late final CloudDriveErrorHandler _errorHandler;

  /// 初始化依赖注入容器
  void initialize() {
    _logger = CloudDriveLogger();
    _errorHandler = CloudDriveErrorHandler();
    _cacheService = CloudDriveCacheService();
    _fileService = CloudDriveFileService();
    _repository = CloudDriveRepository();
  }

  /// 获取文件服务
  CloudDriveFileService get fileService => _fileService;

  /// 获取缓存服务
  CloudDriveCacheService get cacheService => _cacheService;

  /// 获取数据仓库
  CloudDriveRepository get repository => _repository;

  /// 获取日志服务
  CloudDriveLogger get logger => _logger;

  /// 获取错误处理器
  CloudDriveErrorHandler get errorHandler => _errorHandler;

  /// 重置所有依赖
  void reset() {
    // 重置所有服务状态
    CloudDriveCacheService.clearCache();
  }
}

/// 依赖注入提供者
class CloudDriveDIProvider {
  static CloudDriveDIContainer get container => CloudDriveDIContainer.instance;

  /// 获取文件服务
  static CloudDriveFileService get fileService => container.fileService;

  /// 获取缓存服务
  static CloudDriveCacheService get cacheService => container.cacheService;

  /// 获取数据仓库
  static CloudDriveRepository get repository => container.repository;

  /// 获取日志服务
  static CloudDriveLogger get logger => container.logger;

  /// 获取错误处理器
  static CloudDriveErrorHandler get errorHandler => container.errorHandler;
}
