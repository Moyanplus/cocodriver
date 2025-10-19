import 'cloud_drive_dependency_injection.dart';
import '../../../../core/logging/log_manager.dart';

/// 云盘模块初始化器
class CloudDriveInitializer {
  static bool _isInitialized = false;

  /// 初始化云盘模块
  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      // 初始化依赖注入容器
      CloudDriveDIContainer.instance.initialize();

      // 标记为已初始化
      _isInitialized = true;

      LogManager().cloudDrive(
        '云盘模块初始化成功',
        className: 'CloudDriveInitializer',
        methodName: 'initialize',
      );
    } catch (e) {
      LogManager().error(
        '云盘模块初始化失败: $e',
        className: 'CloudDriveInitializer',
        methodName: 'initialize',
        exception: e,
      );
      rethrow;
    }
  }

  /// 检查是否已初始化
  static bool get isInitialized => _isInitialized;

  /// 重置初始化状态
  static void reset() {
    if (_isInitialized) {
      CloudDriveDIContainer.instance.reset();
      _isInitialized = false;
      LogManager().cloudDrive(
        '云盘模块已重置',
        className: 'CloudDriveInitializer',
        methodName: 'reset',
      );
    }
  }
}
