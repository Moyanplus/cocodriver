import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/cloud_drive_entities.dart';

/// 云盘用户偏好设置服务
///
/// 负责管理云盘相关的用户偏好设置，包括：
/// - 默认云盘类型选择
/// - 登录方式偏好
/// - 其他用户设置
class CloudDrivePreferencesService {
  static const String _keyDefaultCloudDriveType = 'cloud_drive_default_type';
  static const String _keyDefaultAuthType = 'cloud_drive_default_auth_type';

  /// 获取默认云盘类型
  ///
  /// 如果用户之前选择过，返回用户的选择
  /// 否则返回百度网盘作为默认值
  Future<CloudDriveType> getDefaultCloudDriveType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final typeString = prefs.getString(_keyDefaultCloudDriveType);

      if (typeString != null) {
        // 尝试从字符串转换为枚举
        final type = CloudDriveType.values.firstWhere(
          (type) => type.name == typeString,
          orElse: () => CloudDriveType.baidu, // 默认值
        );
        return type;
      }

      // 如果没有保存的选择，返回默认值
      return CloudDriveType.baidu;
    } catch (e) {
      // 发生错误时返回默认值
      return CloudDriveType.baidu;
    }
  }

  /// 保存默认云盘类型
  ///
  /// 当用户选择云盘类型时调用此方法保存选择
  Future<void> setDefaultCloudDriveType(CloudDriveType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyDefaultCloudDriveType, type.name);
    } catch (e) {
      // 保存失败时静默处理，不影响用户体验
      // print('保存云盘类型偏好失败: $e');
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

        // 检查该认证方式是否被当前云盘类型支持
        if (cloudDriveType.supportedAuthTypes.contains(authType)) {
          return authType;
        }
      }

      // 如果没有保存的选择或不支持，返回云盘类型的默认认证方式
      return cloudDriveType.authType;
    } catch (e) {
      // 发生错误时返回云盘类型的默认认证方式
      return cloudDriveType.authType;
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

      return {
        'defaultCloudDriveType': defaultType.displayName,
        'defaultAuthType': defaultAuthType.name,
        'supportedAuthTypes':
            defaultType.supportedAuthTypes.map((e) => e.name).toList(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
