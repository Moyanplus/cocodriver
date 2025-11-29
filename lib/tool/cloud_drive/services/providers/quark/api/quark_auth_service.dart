import '../../../../data/models/cloud_drive_entities.dart';
import 'quark_base_service.dart';
import 'quark_config.dart';
import '../utils/quark_logger.dart';

/// 夸克云盘认证服务
///
/// 负责 Token 刷新、认证头管理、缓存优化等功能。
class QuarkAuthService {
  // 缓存最新的 __puus token
  static final Map<String, String> _puusTokenCache = {};
  static final Map<String, DateTime> _tokenExpireTime = {};

  // 认证头缓存：避免短时间内重复构建认证头
  static final Map<String, Map<String, String>> _authHeadersCache = {};
  static final Map<String, DateTime> _authHeadersCacheTime = {};
  static final _authHeadersCacheDuration = Duration(
    seconds: QuarkConfig.performanceConfig['authHeadersCacheDuration'] as int,
  );

  /// 刷新 __puus 认证token（从响应头提取并缓存）
  static Future<String?> refreshPuusToken(CloudDriveAccount account) async {
    QuarkLogger.auth('刷新 __puus token');

    try {
      // 1. 创建Dio实例并构建请求
      final dio = QuarkBaseService.createDio(account);
      final queryParams = QuarkConfig.buildFileOperationParams();

      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('flushAuth')}',
      );
      final uri = url.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );

      // 2. 发送请求
      QuarkLogger.network('GET', url: uri.toString());
      final response = await dio.getUri(uri);

      // 3. 检查HTTP状态码
      if (!QuarkBaseService.isHttpSuccess(response.statusCode)) {
        throw Exception('HTTP请求失败，状态码: ${response.statusCode}');
      }

      // 4. 从响应头中提取 set-cookie
      final setCookieHeaders = response.headers['set-cookie'];
      if (setCookieHeaders == null || setCookieHeaders.isEmpty) {
        QuarkLogger.warning('响应中未找到 set-cookie 头');
        return null;
      }

      // 5. 解析 __puus token 和过期时间
      String? newPuusToken;
      DateTime? expireTime;

      for (final setCookie in setCookieHeaders) {
        QuarkLogger.debug('解析 set-cookie', data: setCookie);

        final puusKey = QuarkConfig.cookieConfig['puusKey']!;
        if (setCookie.contains('$puusKey=')) {
          // 提取token值
          final puusMatch = RegExp('$puusKey=([^;]+)').firstMatch(setCookie);
          if (puusMatch != null) {
            newPuusToken = puusMatch.group(1);
            final previewLength =
                QuarkConfig.performanceConfig['cookiePreviewLength'] as int;
            QuarkLogger.auth(
              '提取到新token: ${newPuusToken?.substring(0, previewLength)}...',
            );
          }

          // 提取过期时间
          final expiresPrefix = QuarkConfig.cookieConfig['expiresPrefix']!;
          final expiresMatch = RegExp(
            '$expiresPrefix([^;]+)',
          ).firstMatch(setCookie);
          if (expiresMatch != null) {
            try {
              final expiresStr = expiresMatch.group(1)!;
              final gmtSuffix = QuarkConfig.cookieConfig['gmtSuffix']!;
              expireTime = DateTime.parse(expiresStr.replaceAll(gmtSuffix, ''));
              QuarkLogger.auth('Token过期时间: $expireTime');
            } catch (e) {
              QuarkLogger.warning('解析过期时间失败: $e');
            }
          }
          break;
        }
      }

      // 6. 缓存token
      if (newPuusToken != null) {
        _puusTokenCache[account.id] = newPuusToken;
        if (expireTime != null) {
          _tokenExpireTime[account.id] = expireTime;
        }

        QuarkLogger.success('__puus token 刷新成功');
        return newPuusToken;
      } else {
        QuarkLogger.warning('响应中未找到 __puus token');
        return null;
      }
    } catch (e, stackTrace) {
      QuarkLogger.error('刷新 __puus token 失败', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// 获取有效的 __puus token
  ///
  /// 智能获取有效的认证token，支持自动刷新和缓存。
  ///
  /// **参数**:
  /// - [account] 云盘账号
  ///
  /// **返回值**:
  /// - 有效的 __puus token
  ///
  /// **智能逻辑**:
  /// 1. 检查缓存中是否有token
  /// 2. 检查token是否即将过期（1小时内）
  /// 3. 需要时自动刷新
  /// 4. 返回有效token
  ///
  /// **自动刷新条件**:
  /// - 缓存中没有token
  /// - Token即将在1小时内过期
  static Future<String?> getValidPuusToken(CloudDriveAccount account) async {
    final accountId = account.id;
    final cachedToken = _puusTokenCache[accountId];
    final expireTime = _tokenExpireTime[accountId];

    // 检查是否需要刷新
    bool needRefresh = false;

    if (cachedToken == null) {
      QuarkLogger.cache('Token缓存未找到，需要刷新', key: accountId);
      needRefresh = true;
    } else if (expireTime != null) {
      final timeUntilExpiry = expireTime.difference(DateTime.now());
      final refreshThreshold =
          QuarkConfig.performanceConfig['tokenRefreshThreshold'] as int;
      if (timeUntilExpiry.inHours < refreshThreshold) {
        QuarkLogger.cache(
          'Token即将过期 (${timeUntilExpiry.inMinutes}分钟)，需要刷新',
          key: accountId,
        );
        needRefresh = true;
      } else {
        QuarkLogger.cache('使用缓存的token', key: accountId);
      }
    }

    if (needRefresh) {
      return await refreshPuusToken(account);
    } else {
      return cachedToken;
    }
  }

  /// 构建包含 __puus 的完整Cookie头
  static Future<Map<String, String>> buildAuthHeaders(
    CloudDriveAccount account,
  ) async {
    final accountId = account.id;

    // 【优化】检查缓存的认证头是否还有效
    final cachedHeaders = _authHeadersCache[accountId];
    final cacheTime = _authHeadersCacheTime[accountId];
    if (cachedHeaders != null && cacheTime != null) {
      final now = DateTime.now();
      if (now.difference(cacheTime) < _authHeadersCacheDuration) {
        // 【简化】使用缓存时不打印日志，减少噪音
        return cachedHeaders;
      }
    }

    // 【简化】构建认证头时只打印关键信息
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
      cookieMap[QuarkConfig.cookieConfig['puusKey']!] = puusToken;

      // 构建完整的cookie字符串
      final fullCookie = cookieMap.entries
          .map((e) => '${e.key}=${e.value}')
          .join('; ');

      // 【暂时注销】异步更新账号对象的cookie（不阻塞当前请求）
      // _updateAccountCookieAsync(account, fullCookie);r

      final headers = {'Cookie': fullCookie, ...QuarkConfig.defaultHeaders};

      // 【优化】缓存认证头
      _authHeadersCache[accountId] = headers;
      _authHeadersCacheTime[accountId] = DateTime.now();

      QuarkLogger.auth('构建认证头成功');
      return headers;
    } else {
      QuarkLogger.warning('未能获取有效的 __puus token，使用原始认证头');
      return account.authHeaders;
    }
  }

  /// 清理指定账号的token缓存
  ///
  /// 移除账号的所有缓存数据，包括token、认证头和更新记录。
  ///
  /// **参数**:
  /// - [accountId] 账号ID
  ///
  /// **使用场景**:
  /// - 账号登出时
  /// - 认证失败时
  /// - 强制刷新token时
  static void clearTokenCache(String accountId) {
    _puusTokenCache.remove(accountId);
    _tokenExpireTime.remove(accountId);
    _authHeadersCache.remove(accountId);
    _authHeadersCacheTime.remove(accountId);

    QuarkLogger.cache('清理账号token缓存', key: accountId);
  }

  /// 清理所有账号的token缓存
  ///
  /// 移除所有账号的缓存数据。
  ///
  /// **使用场景**:
  /// - 应用重启时
  /// - 全局注销时
  /// - 清理临时数据时
  static void clearAllTokenCache() {
    final count = _puusTokenCache.length;

    _puusTokenCache.clear();
    _tokenExpireTime.clear();
    _authHeadersCache.clear();
    _authHeadersCacheTime.clear();

    QuarkLogger.cache('清理所有token缓存，共 $count 个账号');
  }
}
