import '../base/cloud_drive_operation_service.dart';
import '../config/cloud_drive_capabilities.dart' show registerCapabilities;
import '../data/models/cloud_drive_entities.dart';
import 'provider/cloud_drive_provider_registry.dart';
import 'provider/default_cloud_drive_providers.dart';

/// 策略注册器
///
/// 集中管理所有云盘操作策略的注册和获取，实现策略与调用方的解耦。
class StrategyRegistry {
  static final Map<CloudDriveType, CloudDriveOperationStrategy> _strategies =
      {};

  /// 注册策略
  static void register(
    CloudDriveType type,
    CloudDriveOperationStrategy strategy,
  ) {
    _strategies[type] = strategy;
  }

  /// 获取策略
  static CloudDriveOperationStrategy? getStrategy(CloudDriveType type) {
    return _strategies[type];
  }

  /// 获取所有已注册的策略类型
  static List<CloudDriveType> getRegisteredTypes() {
    return _strategies.keys.toList();
  }

  /// 检查策略是否已注册
  static bool isRegistered(CloudDriveType type) {
    return _strategies.containsKey(type);
  }

  /// 初始化并注册所有策略
  static void initialize() {
    CloudDriveProviderRegistry.initializeDefaults(defaultCloudDriveProviders);
    CloudDriveProviderRegistry.descriptors.forEach((descriptor) {
      register(descriptor.type, descriptor.strategyFactory());
      // 将能力表注册到全局，供业务/规则使用
      registerCapabilities(descriptor.type, descriptor.capabilities);
    });
  }

  /// 清空所有策略（用于测试）
  static void clear() {
    _strategies.clear();
  }
}
