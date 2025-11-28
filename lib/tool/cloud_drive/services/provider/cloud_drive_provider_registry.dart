import '../../data/models/cloud_drive_entities.dart';
import 'cloud_drive_provider_descriptor.dart';

/// 提供方注册表：统一管理可插拔的云盘供应商。
class CloudDriveProviderRegistry {
  CloudDriveProviderRegistry._();

  static final Map<CloudDriveType, CloudDriveProviderDescriptor> _descriptors =
      {};
  static bool _initialized = false;

  /// 注册单个云盘描述
  static void register(CloudDriveProviderDescriptor descriptor) {
    _descriptors[descriptor.type] = descriptor;
  }

  /// 获取所有描述
  static List<CloudDriveProviderDescriptor> get descriptors =>
      _descriptors.values.toList();

  /// 按类型获取描述
  static CloudDriveProviderDescriptor? get(CloudDriveType type) =>
      _descriptors[type];

  /// 初始化默认供应商
  static void initializeDefaults(List<CloudDriveProviderDescriptor> defaults) {
    if (_initialized) return;
    for (final descriptor in defaults) {
      register(descriptor);
    }
    _initialized = true;
  }

  /// 清空（测试场景）
  static void clear() {
    _descriptors.clear();
    _initialized = false;
  }
}
