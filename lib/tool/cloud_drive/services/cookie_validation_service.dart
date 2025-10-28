import '../data/models/cloud_drive_entities.dart';
import '../data/models/cloud_drive_configs.dart';
import '../base/cloud_drive_operation_service.dart';

/// Cookie 验证结果
class CookieValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? successMessage;
  final String? username;
  final String? formattedCookie;

  const CookieValidationResult({
    required this.isValid,
    this.errorMessage,
    this.successMessage,
    this.username,
    this.formattedCookie,
  });

  factory CookieValidationResult.success({
    required String username,
    required String formattedCookie,
  }) {
    return CookieValidationResult(
      isValid: true,
      successMessage: 'Cookie 验证成功！用户: $username',
      username: username,
      formattedCookie: formattedCookie,
    );
  }

  factory CookieValidationResult.error(String message) {
    return CookieValidationResult(isValid: false, errorMessage: message);
  }
}

/// Cookie 验证服务
///
/// 负责 Cookie 的验证、提取和格式化
class CookieValidationService {
  /// 获取指定云盘类型的 Cookie 配置
  static CookieProcessingConfig getConfig(CloudDriveType type) {
    switch (type) {
      case CloudDriveType.lanzou:
        return CookieProcessingConfig.lanzouConfig;
      case CloudDriveType.baidu:
        return CookieProcessingConfig.defaultConfig;
      case CloudDriveType.quark:
        return CookieProcessingConfig.quarkConfig;
      case CloudDriveType.pan123:
        return CookieProcessingConfig.pan123Config;
      default:
        return CookieProcessingConfig(requiredCookies: []);
    }
  }

  /// 从 Cookie 字符串中提取必需字段
  ///
  /// [cookies] Cookie 字符串
  /// [type] 云盘类型
  /// 返回提取后的 Cookie 键值对
  static Map<String, String> extractRequiredCookies(
    String cookies,
    CloudDriveType type,
  ) {
    final cookieMap = <String, String>{};

    // 解析 Cookie 字符串
    for (final cookie in cookies.split(';')) {
      final trimmedCookie = cookie.trim();
      if (trimmedCookie.isEmpty) continue;

      final parts = trimmedCookie.split('=');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        final value = parts.sublist(1).join('=').trim();
        cookieMap[name] = value;
      }
    }

    // 获取必需字段列表
    final config = getConfig(type);

    // 提取必需字段
    final result = <String, String>{};
    for (final requiredField in config.requiredCookies) {
      if (cookieMap.containsKey(requiredField)) {
        result[requiredField] = cookieMap[requiredField]!;
      }
    }

    return result;
  }

  /// 格式化 Cookie 为字符串
  ///
  /// [cookieMap] Cookie 键值对
  /// 返回格式化后的 Cookie 字符串
  static String formatCookie(Map<String, String> cookieMap) {
    return cookieMap.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  /// 获取必需的 Cookie 字段说明
  ///
  /// [type] 云盘类型
  /// 返回字段说明字符串
  static String getRequiredFieldsDescription(CloudDriveType type) {
    final config = getConfig(type);

    if (config.requiredCookies.isEmpty) {
      return '';
    }

    return '\n必需字段：${config.requiredCookies.join(", ")}';
  }

  /// 验证 Cookie
  ///
  /// [cookies] Cookie 字符串
  /// [type] 云盘类型
  /// [accountName] 账号名称（可选）
  /// 返回验证结果
  static Future<CookieValidationResult> validateCookie({
    required String cookies,
    required CloudDriveType type,
    String? accountName,
  }) async {
    try {
      // 1. 检查 Cookie 是否为空
      if (cookies.trim().isEmpty) {
        return CookieValidationResult.error('请先输入 Cookie');
      }

      // 2. 提取必需的 Cookie 字段
      final extractedCookies = extractRequiredCookies(cookies.trim(), type);

      if (extractedCookies.isEmpty) {
        return CookieValidationResult.error('未找到必需的 Cookie 字段');
      }

      // 3. 格式化 Cookie
      final formattedCookies = formatCookie(extractedCookies);

      // 4. 创建临时账号用于验证
      final tempAccount = CloudDriveAccount(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        name: accountName?.trim().isNotEmpty == true ? accountName! : '临时账号',
        type: type,
        cookies: formattedCookies,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // 5. 调用统一的获取账号详情接口
      final accountDetails = await CloudDriveOperationService.getAccountDetails(
        account: tempAccount,
      );

      if (accountDetails != null && accountDetails.accountInfo != null) {
        // 验证成功
        final username = accountDetails.accountInfo!.username;
        return CookieValidationResult.success(
          username: username,
          formattedCookie: formattedCookies,
        );
      } else {
        // 验证失败 - 显示详细的错误信息
        final config = getConfig(type);
        final missingFields = <String>[];

        for (final field in config.requiredCookies) {
          if (!extractedCookies.containsKey(field)) {
            missingFields.add(field);
          }
        }

        String errorMessage = 'Cookie 验证失败';
        if (missingFields.isNotEmpty) {
          errorMessage += '\n缺少必需字段: ${missingFields.join(", ")}';
        } else {
          errorMessage += '\n请检查 Cookie 是否正确或已过期';
        }

        return CookieValidationResult.error(errorMessage);
      }
    } catch (e) {
      return CookieValidationResult.error('Cookie 验证异常: $e');
    }
  }

  /// 获取 Cookie 获取步骤说明
  ///
  /// [type] 云盘类型
  /// 返回步骤说明字符串
  static String getCookieInstructions(CloudDriveType type) {
    final url = type.webViewConfig.initialUrl ?? 'https://www.123pan.com/';
    final requiredFields = getRequiredFieldsDescription(type);

    return '1. 在浏览器中打开 $url\n'
        '2. 登录您的账号\n'
        '3. 按F12打开开发者工具\n'
        '4. 在Network标签页中找到任意请求\n'
        '5. 复制请求头中的Cookie值'
        '$requiredFields';
  }
}
