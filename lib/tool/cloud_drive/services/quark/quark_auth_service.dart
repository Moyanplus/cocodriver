import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../base/cloud_drive_account_service.dart';
import 'quark_base_service.dart';
import 'quark_config.dart';

/// 夸克云盘认证服务
/// 专门负责 __puus token 的刷新和cookie管理
class QuarkAuthService {
  // 缓存最新的 __puus token
  static final Map<String, String> _puusTokenCache = {};
  static final Map<String, DateTime> _tokenExpireTime = {};

  /// 刷新 __puus 认证token
  static Future<String?> refreshPuusToken(CloudDriveAccount account) async {
    LogManager().cloudDrive('🔄 夸克云盘 - 刷新__puus token开始');

    try {
      final dio = QuarkBaseService.createDio(account);
      final queryParams = QuarkConfig.buildFileOperationParams();

      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('flushAuth')}',
      );
      final uri = url.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );

      LogManager().cloudDrive('🔗 刷新认证URL: $uri');

      final response = await dio.getUri(uri);

      if (!QuarkBaseService.isHttpSuccess(response.statusCode)) {
        throw Exception('刷新认证失败，状态码: ${response.statusCode}');
      }

      // 从响应的 set-cookie 头中提取 __puus
      final setCookieHeaders = response.headers['set-cookie'];
      if (setCookieHeaders == null || setCookieHeaders.isEmpty) {
        LogManager().cloudDrive('❌ 夸克云盘 - 刷新响应中未找到set-cookie头');
        return null;
      }

      String? newPuusToken;
      DateTime? expireTime;

      for (final setCookie in setCookieHeaders) {
        LogManager().cloudDrive('🍪 解析set-cookie: $setCookie');

        if (setCookie.contains('__puus=')) {
          // 解析 __puus token
          final puusMatch = RegExp(r'__puus=([^;]+)').firstMatch(setCookie);
          if (puusMatch != null) {
            newPuusToken = puusMatch.group(1);
            LogManager().cloudDrive(
              '✅ 提取到新的__puus token: ${newPuusToken?.substring(0, 50)}...',
            );
          }

          // 解析过期时间
          final expiresMatch = RegExp(r'Expires=([^;]+)').firstMatch(setCookie);
          if (expiresMatch != null) {
            try {
              final expiresStr = expiresMatch.group(1)!;
              expireTime = DateTime.parse(expiresStr.replaceAll(' GMT', ''));
              LogManager().cloudDrive('📅 Token过期时间: $expireTime');
            } catch (e) {
              LogManager().cloudDrive('⚠️ 解析过期时间失败: $e');
            }
          }
          break;
        }
      }

      if (newPuusToken != null) {
        // 缓存新的token
        _puusTokenCache[account.id] = newPuusToken;
        if (expireTime != null) {
          _tokenExpireTime[account.id] = expireTime;
        }

        LogManager().cloudDrive('✅ 夸克云盘 - __puus token刷新成功');
        return newPuusToken;
      } else {
        LogManager().cloudDrive('❌ 夸克云盘 - 响应中未找到__puus token');
        return null;
      }
    } catch (e) {
      LogManager().cloudDrive('❌ 夸克云盘 - 刷新__puus token失败: $e');
      return null;
    }
  }

  /// 获取有效的 __puus token
  /// 如果缓存中的token即将过期或不存在，会自动刷新
  static Future<String?> getValidPuusToken(CloudDriveAccount account) async {
    LogManager().cloudDrive('🔍 夸克云盘 - 开始检查__puus token有效性');
    LogManager().cloudDrive('👤 账号ID: ${account.id}');

    final accountId = account.id;
    final cachedToken = _puusTokenCache[accountId];
    final expireTime = _tokenExpireTime[accountId];

    LogManager().cloudDrive('💾 缓存状态检查:');
    LogManager().cloudDrive('  - 缓存中是否有token: ${cachedToken != null}');
    LogManager().cloudDrive('  - 缓存token长度: ${cachedToken?.length ?? 0}');
    LogManager().cloudDrive(
      '  - 缓存token前50字符: ${cachedToken?.substring(0, cachedToken.length > 50 ? 50 : cachedToken.length) ?? 'null'}',
    );
    LogManager().cloudDrive('  - 过期时间: ${expireTime?.toString() ?? 'null'}');

    // 检查是否需要刷新token
    bool needRefresh = false;

    LogManager().cloudDrive('🔍 开始检查是否需要刷新token:');

    if (cachedToken == null) {
      LogManager().cloudDrive('📝 夸克云盘 - 缓存中无__puus token，需要刷新');
      needRefresh = true;
    } else if (expireTime != null) {
      // 如果距离过期时间不足1小时，则刷新
      final now = DateTime.now();
      final timeUntilExpiry = expireTime.difference(now);

      LogManager().cloudDrive('⏰ 时间检查:');
      LogManager().cloudDrive('  - 当前时间: $now');
      LogManager().cloudDrive('  - 过期时间: $expireTime');
      LogManager().cloudDrive('  - 剩余时间: ${timeUntilExpiry.inMinutes}分钟');
      LogManager().cloudDrive('  - 是否不足1小时: ${timeUntilExpiry.inHours < 1}');

      if (timeUntilExpiry.inHours < 1) {
        LogManager().cloudDrive(
          '⏰ 夸克云盘 - __puus token即将过期(${timeUntilExpiry.inMinutes}分钟)，需要刷新',
        );
        needRefresh = true;
      } else {
        LogManager().cloudDrive(
          '✅ 夸克云盘 - __puus token还有${timeUntilExpiry.inHours}小时${timeUntilExpiry.inMinutes % 60}分钟才过期，无需刷新',
        );
      }
    } else {
      LogManager().cloudDrive('⚠️ 夸克云盘 - 缓存中有token但没有过期时间信息，使用缓存token');
    }

    LogManager().cloudDrive(
      '🎯 最终决策: ${needRefresh ? '需要刷新token' : '使用缓存token'}',
    );

    if (needRefresh) {
      LogManager().cloudDrive('🔄 开始刷新__puus token...');
      return await refreshPuusToken(account);
    } else {
      LogManager().cloudDrive('✅ 夸克云盘 - 使用缓存的__puus token');
      LogManager().cloudDrive(
        '📋 返回的token前50字符: ${cachedToken?.substring(0, cachedToken.length > 50 ? 50 : cachedToken.length) ?? 'null'}',
      );
      return cachedToken;
    }
  }

  /// 构建包含 __puus 的完整Cookie头
  static Future<Map<String, String>> buildAuthHeaders(
    CloudDriveAccount account,
  ) async {
    LogManager().cloudDrive('🔧 夸克云盘 - 开始构建认证头');
    LogManager().cloudDrive('👤 账号ID: ${account.id}');

    final puusToken = await getValidPuusToken(account);

    LogManager().cloudDrive(
      '🎫 获取到的token状态: ${puusToken != null ? '有效' : '无效'}',
    );
    LogManager().cloudDrive('📏 token长度: ${puusToken?.length ?? 0}');

    if (puusToken != null) {
      LogManager().cloudDrive('🍪 开始构建完整Cookie:');

      // 从账号的原始Cookie中提取其他cookie
      final originalCookie = account.cookies ?? '';
      final cookieMap = <String, String>{};

      LogManager().cloudDrive('📋 原始Cookie长度: ${originalCookie.length}');
      LogManager().cloudDrive(
        '📋 原始Cookie前100字符: ${originalCookie.length > 100 ? originalCookie.substring(0, 100) + '...' : originalCookie}',
      );

      // 解析原始cookie
      if (originalCookie.isNotEmpty) {
        for (final cookie in originalCookie.split(';')) {
          final trimmedCookie = cookie.trim();
          if (trimmedCookie.isEmpty) continue;

          final parts = trimmedCookie.split('=');
          if (parts.length >= 2) {
            final name = parts[0].trim();
            final value = parts.sublist(1).join('=').trim();
            cookieMap[name] = value;
          }
        }
      }

      LogManager().cloudDrive('📊 解析出的Cookie数量: ${cookieMap.length}');
      LogManager().cloudDrive('📊 Cookie键列表: ${cookieMap.keys.toList()}');

      // 更新 __puus token
      cookieMap['__puus'] = puusToken;

      LogManager().cloudDrive('🔄 已更新__puus token到Cookie映射中');

      // 构建完整的cookie字符串
      final fullCookie = cookieMap.entries
          .map((e) => '${e.key}=${e.value}')
          .join('; ');

      LogManager().cloudDrive('🍪 夸克云盘 - 构建认证头完成: ${fullCookie.length}字符');
      LogManager().cloudDrive(
        '🍪 完整Cookie前200字符: ${fullCookie.length > 200 ? fullCookie.substring(0, 200) + '...' : fullCookie}',
      );

      // 异步更新账号对象的cookie（不阻塞当前请求）
      _updateAccountCookieAsync(account, fullCookie);

      return {'Cookie': fullCookie, ...QuarkConfig.defaultHeaders};
    } else {
      LogManager().cloudDrive('⚠️ 夸克云盘 - 未能获取有效的__puus token，使用原始认证头');
      LogManager().cloudDrive('📋 原始认证头: ${account.authHeaders}');
      return account.authHeaders;
    }
  }

  /// 异步更新账号对象的cookie字段
  /// 不阻塞当前API调用，在后台更新数据库中的账号信息
  static void _updateAccountCookieAsync(
    CloudDriveAccount account,
    String newCookie,
  ) {
    // 使用异步执行，避免阻塞当前操作
    Future.microtask(() async {
      try {
        // 检查是否需要更新（避免重复更新）
        if (account.cookies == newCookie) {
          LogManager().cloudDrive('📝 夸克云盘 - 账号cookie已是最新，无需更新');
          return;
        }

        LogManager().cloudDrive('📝 夸克云盘 - 开始更新账号cookie');

        // 创建更新后的账号对象
        final updatedAccount = account.copyWith(
          cookies: newCookie, // 更新cookie
          lastLoginAt: DateTime.now(), // 更新最后登录时间
        );

        // 导入并使用账号服务更新数据库
        await CloudDriveAccountService.updateAccount(updatedAccount);

        LogManager().cloudDrive('✅ 夸克云盘 - 账号cookie更新成功');
      } catch (e) {
        LogManager().cloudDrive('❌ 夸克云盘 - 更新账号cookie失败: $e');
      }
    });
  }

  /// 清理账号的token缓存
  static void clearTokenCache(String accountId) {
    _puusTokenCache.remove(accountId);
    _tokenExpireTime.remove(accountId);
    LogManager().cloudDrive('🗑️ 夸克云盘 - 清理账号token缓存: $accountId');
  }

  /// 清理所有token缓存
  static void clearAllTokenCache() {
    _puusTokenCache.clear();
    _tokenExpireTime.clear();
    LogManager().cloudDrive('🗑️ 夸克云盘 - 清理所有token缓存');
  }
}
