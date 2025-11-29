import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../registry/cloud_drive_provider_registry.dart';

/// 云盘用户偏好设置服务
///
/// 管理云盘相关的用户偏好设置，包括默认云盘类型、登录方式等。
class CloudDrivePreferencesService {
  static const String _keyDefaultCloudDriveType = 'cloud_drive_default_type';
  static const String _keyDefaultAuthType = 'cloud_drive_default_auth_type';

  /// 获取默认云盘类型
  Future<CloudDriveType> getDefaultCloudDriveType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final typeString = prefs.getString(_keyDefaultCloudDriveType);

      if (typeString != null) {
        final descriptor = CloudDriveProviderRegistry.getById(typeString);
        if (descriptor != null) {
          return descriptor.type;
        }
      }

      // 如果没有保存的选择或未注册，返回注册表中的第一个
      return _getFirstRegisteredType();
    } catch (e) {
      throw StateError('无法获取默认云盘类型: $e');
    }
  }

  /// 保存默认云盘类型
  ///
  /// 当用户选择云盘类型时调用此方法保存选择
  Future<void> setDefaultCloudDriveType(CloudDriveType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final descriptor = CloudDriveProviderRegistry.get(type);
      if (descriptor == null) {
        throw StateError('未注册云盘描述: $type');
      }
      await prefs.setString(
        _keyDefaultCloudDriveType,
        descriptor.id ?? type.name,
      );
    } catch (e) {
      throw StateError('保存云盘类型偏好失败: $e');
    }
  }

  /// 获取默认认证方式
  ///
  /// 根据云盘类型返回推荐的认证方式
  Future<AuthType> getDefaultAuthType(CloudDriveType cloudDriveType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authTypeString = prefs.getString(_keyDefaultAuthType);

      if (authTypeString != null) {
        // 尝试从字符串转换为枚举
        final authType = AuthType.values.firstWhere(
          (type) => type.name == authTypeString,
          orElse: () => cloudDriveType.authType, // 使用云盘类型的默认认证方式
        );

        final supported =
            CloudDriveProviderRegistry.get(cloudDriveType)?.supportedAuthTypes ??
                cloudDriveType.supportedAuthTypes;

        if (supported.contains(authType)) {
          return authType;
        }
      }

      // 如果没有保存的选择或不支持，返回云盘类型的默认认证方式
      final supported =
          CloudDriveProviderRegistry.get(cloudDriveType)?.supportedAuthTypes ??
              cloudDriveType.supportedAuthTypes;
      if (supported.isEmpty) {
        throw StateError('未配置认证方式: $cloudDriveType');
      }
      return supported.first;
    } catch (e) {
      throw StateError('获取默认认证方式失败: $e');
    }
  }

  /// 保存默认认证方式
  ///
  /// 当用户选择认证方式时调用此方法保存选择
  Future<void> setDefaultAuthType(AuthType authType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyDefaultAuthType, authType.name);
    } catch (e) {
      // 保存失败时静默处理，不影响用户体验
      // print('保存认证方式偏好失败: $e');
    }
  }

  /// 清除所有偏好设置
  ///
  /// 重置为默认值
  Future<void> clearPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyDefaultCloudDriveType);
      await prefs.remove(_keyDefaultAuthType);
    } catch (e) {
      print('清除偏好设置失败: $e');
    }
  }

  /// 获取偏好设置摘要
  ///
  /// 用于调试和显示当前设置
  Future<Map<String, dynamic>> getPreferencesSummary() async {
    try {
      final defaultType = await getDefaultCloudDriveType();
      final defaultAuthType = await getDefaultAuthType(defaultType);
      final descriptor = CloudDriveProviderRegistry.get(defaultType);
      final supported =
          descriptor?.supportedAuthTypes ?? defaultType.supportedAuthTypes;

      return {
        'defaultCloudDriveType':
            descriptor?.displayName ?? defaultType.displayName,
        'defaultAuthType': defaultAuthType.name,
        'supportedAuthTypes': supported.map((e) => e.name).toList(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  CloudDriveType _getFirstRegisteredType() {
    final descriptors = CloudDriveProviderRegistry.descriptors;
    if (descriptors.isNotEmpty) {
      return descriptors.first.type;
    }
    throw StateError('未注册任何云盘提供方');
  }
}
