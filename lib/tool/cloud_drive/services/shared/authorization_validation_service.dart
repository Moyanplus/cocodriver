import '../../data/models/cloud_drive_entities.dart';
import '../../base/cloud_drive_service_gateway.dart';
import '../registry/cloud_drive_provider_registry.dart';

/// Authorization Token 验证结果类
///
/// 表示 Authorization Token 验证的结果，包括验证状态、错误信息、用户名等。
class AuthorizationValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? successMessage;
  final String? username;
  final String? formattedToken;

  const AuthorizationValidationResult({
    required this.isValid,
    this.errorMessage,
    this.successMessage,
    this.username,
    this.formattedToken,
  });

  factory AuthorizationValidationResult.success({
    String? username,
    String? formattedToken,
  }) {
    return AuthorizationValidationResult(
      isValid: true,
      successMessage:
          username != null ? 'Token 验证成功！用户: $username' : 'Token 验证成功！',
      username: username,
      formattedToken: formattedToken,
    );
  }

  factory AuthorizationValidationResult.error(String message) {
    return AuthorizationValidationResult(isValid: false, errorMessage: message);
  }
}

/// Authorization Token 验证服务
///
/// 负责 Authorization Token 的验证和格式化。
class AuthorizationValidationService {
  /// 清理 Token 字符串
  ///
  /// 移除 "Bearer " 和 "Basic " 前缀和多余空白字符
  static String cleanToken(String token) {
    var cleaned = token.trim();

    // 移除 Bearer 前缀（如果有）
    if (cleaned.toLowerCase().startsWith('bearer ')) {
      cleaned = cleaned.substring(7).trim();
    }

    // 移除 Basic 前缀（如果有）
    if (cleaned.toLowerCase().startsWith('basic ')) {
      cleaned = cleaned.substring(6).trim();
    }

    return cleaned;
  }

  /// 格式化 Token
  ///
  /// 如果需要，添加 "Bearer " 前缀
  static String formatToken(String token, {bool addBearer = false}) {
    final cleaned = cleanToken(token);
    return addBearer ? 'Bearer $cleaned' : cleaned;
  }

  /// 验证 Token 格式
  ///
  /// [token] Token 字符串
  /// [type] 云盘类型
  /// 注意：这里只做基本格式验证，详细的验证由各云盘策略实现
  static bool isValidFormat(String token, CloudDriveType type) {
    final cleaned = cleanToken(token);

    if (cleaned.isEmpty) {
      return false;
    }

    // 基本格式验证：非空即可
    // 详细的格式验证由 getAccountDetails 接口实现
    return true;
  }

  /// 验证 Authorization Token
  ///
  /// [token] Authorization Token 字符串
  /// [type] 云盘类型
  /// [accountName] 账号名称（可选）
  static Future<AuthorizationValidationResult> validateToken({
    required String token,
    required CloudDriveType type,
    String? accountName,
  }) async {
    try {
      // 1. 检查 Token 是否为空
      final cleanedToken = cleanToken(token);
      if (cleanedToken.isEmpty) {
        return AuthorizationValidationResult.error('请先输入 Authorization Token');
      }

      // 2. 检查云盘是否支持 Authorization Token
      if (!supportsAuthorizationToken(type)) {
        return AuthorizationValidationResult.error(
          '该云盘不支持 Authorization Token 认证方式，请使用 Cookie 认证方式',
        );
      }

      // 3. 创建临时账号用于验证
      final tempAccount = CloudDriveAccount(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        name: accountName?.trim().isNotEmpty == true ? accountName! : '临时账号',
        type: type,
        authorizationToken: cleanedToken,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // 4. 调用统一的获取账号详情接口进行实际验证
      // 这里会调用对应云盘策略的 getAccountDetails 方法
      final accountDetails =
          await defaultCloudDriveGateway.strategyFor(tempAccount)
              ?.getAccountDetails(account: tempAccount);

      if (accountDetails != null && accountDetails.accountInfo != null) {
        // 验证成功
        final username = accountDetails.accountInfo!.username;
        return AuthorizationValidationResult.success(
          username: username,
          formattedToken: cleanedToken,
        );
      } else {
        // 验证失败
        return AuthorizationValidationResult.error(
          'Token 验证失败，请检查 Token 是否正确或已过期',
        );
      }
    } catch (e) {
      return AuthorizationValidationResult.error('Token 验证异常: $e');
    }
  }

  /// 获取格式错误提示
  ///
  /// [type] 云盘类型
  /// 注意：该方法已被 validateToken 方法中的统一检查替代
  @Deprecated('Use validateToken method which handles all checks')
  static String getFormatError(CloudDriveType type) {
    return 'Token 格式不正确';
  }

  /// 获取 Token 获取步骤说明
  ///
  /// [type] 云盘类型
  /// 返回步骤说明字符串
  /// 注意：这只是通用说明，云盘特定的说明应该在各云盘的配置或文档中
  static String getTokenInstructions(CloudDriveType type) {
    final descriptor = CloudDriveProviderRegistry.get(type);
    if (descriptor == null) {
      throw StateError('未注册云盘描述: $type');
    }
    if (!supportsAuthorizationToken(type)) {
      return '该云盘不支持 Authorization Token 认证方式\n'
          '请使用 Cookie 认证方式添加账号';
    }

    final url = type.webViewConfig.initialUrl ?? 'https://yun.139.com/';

    // 通用步骤说明
    return '1. 在浏览器中打开 $url\n'
        '2. 登录您的账号\n'
        '3. 按F12打开开发者工具\n'
        '4. 在Network标签页中找到任意请求\n'
        '5. 查看请求头中的 Authorization 字段\n'
        '6. 复制完整的 Authorization 值';
  }

  /// 检查云盘是否支持 Authorization Token 认证
  ///
  /// [type] 云盘类型
  static bool supportsAuthorizationToken(CloudDriveType type) {
    final descriptor = CloudDriveProviderRegistry.get(type);
    if (descriptor == null) {
      throw StateError('未注册云盘描述: $type');
    }
    final supported = descriptor.supportedAuthTypes ?? type.supportedAuthTypes;
    return supported.contains(AuthType.authorization);
  }
}
