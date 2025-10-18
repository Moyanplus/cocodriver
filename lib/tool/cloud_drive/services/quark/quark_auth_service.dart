import '../../../core/services/base/debug_service.dart';
import '../../models/cloud_drive_models.dart';
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
    DebugService.log(
      '🔄 夸克云盘 - 刷新__puus token开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      final dio = QuarkBaseService.createDio(account);
      final queryParams = QuarkConfig.buildFileOperationParams();

      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('flushAuth')}',
      );
      final uri = url.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );

      DebugService.log(
        '🔗 刷新认证URL: $uri',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      final response = await dio.getUri(uri);

      if (!QuarkBaseService.isHttpSuccess(response.statusCode)) {
        throw Exception('刷新认证失败，状态码: ${response.statusCode}');
      }

      // 从响应的 set-cookie 头中提取 __puus
      final setCookieHeaders = response.headers['set-cookie'];
      if (setCookieHeaders == null || setCookieHeaders.isEmpty) {
        DebugService.log(
          '❌ 夸克云盘 - 刷新响应中未找到set-cookie头',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return null;
      }

      String? newPuusToken;
      DateTime? expireTime;

      for (final setCookie in setCookieHeaders) {
        DebugService.log(
          '🍪 解析set-cookie: $setCookie',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );

        if (setCookie.contains('__puus=')) {
          // 解析 __puus token
          final puusMatch = RegExp(r'__puus=([^;]+)').firstMatch(setCookie);
          if (puusMatch != null) {
            newPuusToken = puusMatch.group(1);
            DebugService.log(
              '✅ 提取到新的__puus token: ${newPuusToken?.substring(0, 50)}...',
              category: DebugCategory.tools,
              subCategory: QuarkConfig.logSubCategory,
            );
          }

          // 解析过期时间
          final expiresMatch = RegExp(r'Expires=([^;]+)').firstMatch(setCookie);
          if (expiresMatch != null) {
            try {
              final expiresStr = expiresMatch.group(1)!;
              expireTime = DateTime.parse(expiresStr.replaceAll(' GMT', ''));
              DebugService.log(
                '📅 Token过期时间: $expireTime',
                category: DebugCategory.tools,
                subCategory: QuarkConfig.logSubCategory,
              );
            } catch (e) {
              DebugService.log(
                '⚠️ 解析过期时间失败: $e',
                category: DebugCategory.tools,
                subCategory: QuarkConfig.logSubCategory,
              );
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

        DebugService.log(
          '✅ 夸克云盘 - __puus token刷新成功',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return newPuusToken;
      } else {
        DebugService.log(
          '❌ 夸克云盘 - 响应中未找到__puus token',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return null;
      }
    } catch (e) {
      DebugService.log(
        '❌ 夸克云盘 - 刷新__puus token失败: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return null;
    }
  }

  /// 获取有效的 __puus token
  /// 如果缓存中的token即将过期或不存在，会自动刷新
  static Future<String?> getValidPuusToken(CloudDriveAccount account) async {
    final accountId = account.id;
    final cachedToken = _puusTokenCache[accountId];
    final expireTime = _tokenExpireTime[accountId];

    // 检查是否需要刷新token
    bool needRefresh = false;

    if (cachedToken == null) {
      DebugService.log(
        '📝 夸克云盘 - 缓存中无__puus token，需要刷新',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      needRefresh = true;
    } else if (expireTime != null) {
      // 如果距离过期时间不足1小时，则刷新
      final now = DateTime.now();
      final timeUntilExpiry = expireTime.difference(now);
      if (timeUntilExpiry.inHours < 1) {
        DebugService.log(
          '⏰ 夸克云盘 - __puus token即将过期(${timeUntilExpiry.inMinutes}分钟)，需要刷新',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        needRefresh = true;
      }
    }

    if (needRefresh) {
      return await refreshPuusToken(account);
    } else {
      DebugService.log(
        '✅ 夸克云盘 - 使用缓存的__puus token',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return cachedToken;
    }
  }

  /// 构建包含 __puus 的完整Cookie头
  static Future<Map<String, String>> buildAuthHeaders(
    CloudDriveAccount account,
  ) async {
    final puusToken = await getValidPuusToken(account);

    if (puusToken != null) {
      // 从账号的原始Cookie中提取其他cookie
      final originalCookie = account.cookies ?? '';
      final cookieMap = <String, String>{};

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

      // 更新 __puus token
      cookieMap['__puus'] = puusToken;

      // 构建完整的cookie字符串
      final fullCookie = cookieMap.entries
          .map((e) => '${e.key}=${e.value}')
          .join('; ');

      DebugService.log(
        '🍪 夸克云盘 - 构建认证头完成: ${fullCookie.length}字符',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      // 异步更新账号对象的cookie（不阻塞当前请求）
      _updateAccountCookieAsync(account, fullCookie);

      return {'Cookie': fullCookie, ...QuarkConfig.defaultHeaders};
    } else {
      DebugService.log(
        '⚠️ 夸克云盘 - 未能获取有效的__puus token，使用原始认证头',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
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
          DebugService.log(
            '📝 夸克云盘 - 账号cookie已是最新，无需更新',
            category: DebugCategory.tools,
            subCategory: QuarkConfig.logSubCategory,
          );
          return;
        }

        DebugService.log(
          '📝 夸克云盘 - 开始更新账号cookie',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );

        // 创建更新后的账号对象
        final updatedAccount = account.copyWith(
          cookies: newCookie, // 更新cookie
          lastLoginAt: DateTime.now(), // 更新最后登录时间
        );

        // 导入并使用账号服务更新数据库
        await CloudDriveAccountService.updateAccount(updatedAccount);

        DebugService.log(
          '✅ 夸克云盘 - 账号cookie更新成功',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
      } catch (e) {
        DebugService.log(
          '❌ 夸克云盘 - 更新账号cookie失败: $e',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
      }
    });
  }

  /// 清理账号的token缓存
  static void clearTokenCache(String accountId) {
    _puusTokenCache.remove(accountId);
    _tokenExpireTime.remove(accountId);
    DebugService.log(
      '🗑️ 夸克云盘 - 清理账号token缓存: $accountId',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
  }

  /// 清理所有token缓存
  static void clearAllTokenCache() {
    _puusTokenCache.clear();
    _tokenExpireTime.clear();
    DebugService.log(
      '🗑️ 夸克云盘 - 清理所有token缓存',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
  }
}
