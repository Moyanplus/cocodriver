import '../base/cloud_drive_operation_service.dart';
import '../config/cloud_drive_capabilities.dart' show registerCapabilities;
import '../data/models/cloud_drive_entities.dart';
import 'base/qr_login_service.dart';
import 'provider/cloud_drive_provider_descriptor.dart';
import 'provider/cloud_drive_provider_registry.dart';
import 'provider/default_cloud_drive_providers.dart';

/// 策略注册器
///
/// 集中管理所有云盘操作策略的注册和获取，实现策略与调用方的解耦。
class StrategyRegistry {
  /// 按 providerId 管理策略，降低对枚举的依赖。
  static final Map<String, CloudDriveOperationStrategy> _strategies = {};

  /// 注册策略
  static void register({
    required String providerId,
    required CloudDriveOperationStrategy strategy,
  }) {
    _strategies[providerId] = strategy;
  }

  /// 获取策略
  static CloudDriveOperationStrategy? getStrategyById(String providerId) {
    return _strategies[providerId];
  }

  /// 兼容旧签名：通过类型获取策略（内部转换为 providerId）
  static CloudDriveOperationStrategy? getStrategy(CloudDriveType type) {
    final descriptor = CloudDriveProviderRegistry.get(type);
    if (descriptor == null) return null;
    final providerId = descriptor.id ?? type.name;
    return getStrategyById(providerId);
  }

  /// 获取所有已注册的策略类型
  static List<String> getRegisteredIds() {
    return _strategies.keys.toList();
  }

  /// 检查策略是否已注册
  static bool isRegistered(String providerId) {
    return _strategies.containsKey(providerId);
  }

  /// 初始化并注册所有策略
  static void initialize() {
    CloudDriveProviderRegistry.initializeDefaults(defaultCloudDriveProviders);
    _validateDescriptors(CloudDriveProviderRegistry.descriptors);
    for (var descriptor in CloudDriveProviderRegistry.descriptors) {
      final providerId = descriptor.id ?? descriptor.type.name;
      register(providerId: providerId, strategy: descriptor.strategyFactory());
      // 将能力表注册到全局，供业务/规则使用
      registerCapabilities(descriptor.type, descriptor.capabilities);
      // 可选：注册二维码登录服务
      if (descriptor.qrLoginService != null) {
        QRLoginManager.registerService(descriptor.qrLoginService!);
      }
    }
  }

  /// 清空所有策略（用于测试）
  static void clear() {
    _strategies.clear();
  }

  /// 校验描述符，避免重复/缺失导致运行期错误
  static void _validateDescriptors(
    List<CloudDriveProviderDescriptor> descriptors,
  ) {
    if (descriptors.isEmpty) {
      throw StateError('未注册任何云盘描述，初始化失败');
    }

    final errors = <String>[];
    final ids = <String>{};

    for (final descriptor in descriptors) {
      final providerId = descriptor.id ?? descriptor.type.name;
      if (providerId.isEmpty) {
        errors.add('缺少 providerId: ${descriptor.type}');
      }
      if (!ids.add(providerId)) {
        errors.add('重复的 providerId: $providerId');
      }
      if (descriptor.supportedAuthTypes == null ||
          descriptor.supportedAuthTypes!.isEmpty) {
        errors.add('未配置认证方式: $providerId');
      }
      if (descriptor.capabilities == null) {
        errors.add('未配置能力: $providerId');
      }
    }

    if (errors.isNotEmpty) {
      throw StateError('云盘描述校验失败:\n- ${errors.join('\n- ')}');
    }
  }
}
