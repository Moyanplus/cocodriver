import 'package:dio/dio.dart';

import '../../../../data/models/cloud_drive_entities.dart';
import '../../../base/cloud_drive_api_logger.dart';
import '../../../shared/http_client.dart';
import 'quark_auth_service.dart';
import 'quark_config.dart';
import '../utils/quark_logger.dart';

/// 夸克云盘基础服务
///
/// 提供 Dio 实例创建、请求拦截、响应验证等功能。
abstract class QuarkBaseService {
  static final Map<String, CloudDriveHttpClient> _httpCache = {};
  static final Map<String, String> _authSnapshot = {};

  /// 创建 Dio 实例（使用原始认证头）
  static Dio createDio(CloudDriveAccount account) {
    final dio = Dio(
      BaseOptions(
        baseUrl: QuarkConfig.baseUrl,
        connectTimeout: QuarkConfig.connectTimeout,
        receiveTimeout: QuarkConfig.receiveTimeout,
        headers: {...QuarkConfig.defaultHeaders, ...account.authHeaders},
      ),
    );

    _addInterceptors(dio, providerLabel: '夸克云盘');
    return dio;
  }

  /// 创建带默认 query 的 HttpClient。
  static CloudDriveHttpClient createHttpClient(CloudDriveAccount account) {
    final key = account.id.toString();
    final authKey = _authKey(account);
    final cached = _httpCache[key];
    if (cached != null && _authSnapshot[key] == authKey) {
      return cached;
    }
    final dio = createDio(account);
    final client = CloudDriveHttpClient(
      provider: '夸克网盘',
      dio: dio,
      defaultQueryBuilder:
          (extra) => QuarkConfig.buildDefaultQuery(extra: extra),
    );
    _httpCache[key] = client;
    _authSnapshot[key] = authKey;
    return client;
  }

  /// 创建带授权的 HttpClient。
  static Future<CloudDriveHttpClient> createHttpClientWithAuth(
    CloudDriveAccount account,
  ) async {
    final key = account.id.toString();
    final authKey = _authKey(account);
    final cached = _httpCache[key];
    if (cached != null && _authSnapshot[key] == authKey) {
      return cached;
    }

    final dio = await createDioWithAuth(account);
    final client = CloudDriveHttpClient(
      provider: '夸克网盘',
      dio: dio,
      defaultQueryBuilder:
          (extra) => QuarkConfig.buildDefaultQuery(extra: extra),
    );
    _httpCache[key] = client;
    _authSnapshot[key] = authKey;
    return client;
  }

  /// 创建带有刷新认证的dio实例
  static Future<Dio> createDioWithAuth(CloudDriveAccount account) async {
    // 【简化】移除冗余日志，只在出错时打印
    try {
      final authHeaders = await QuarkAuthService.buildAuthHeaders(account);

      final dio = Dio(
        BaseOptions(
          baseUrl: QuarkConfig.baseUrl,
          connectTimeout: QuarkConfig.connectTimeout,
          receiveTimeout: QuarkConfig.receiveTimeout,
          headers: authHeaders,
        ),
      );

      _addInterceptors(dio, providerLabel: '夸克云盘(授权)');
      return dio;
    } catch (e) {
      QuarkLogger.debug('创建Dio实例失败: $e');
      rethrow;
    }
  }

  /// 添加请求拦截器
  static void _addInterceptors(Dio dio, {String providerLabel = '夸克云盘'}) {
    dio.interceptors.add(
      CloudDriveLoggingInterceptor(
        logger: CloudDriveApiLogger(
          provider: providerLabel,
          verbose: QuarkConfig.verboseLogging,
        ),
      ),
    );
  }

  /// 创建用于pan.quark.cn的dio实例
  static Dio createPanDio(CloudDriveAccount account) {
    final dio = Dio(
      BaseOptions(
        baseUrl: QuarkConfig.panUrl,
        connectTimeout: QuarkConfig.connectTimeout,
        receiveTimeout: QuarkConfig.receiveTimeout,
        headers: {...QuarkConfig.defaultHeaders, ...account.authHeaders},
      ),
    );

    _addInterceptors(dio, providerLabel: '夸克云盘Pan');

    return dio;
  }

  /// 验证HTTP响应状态
  static bool isHttpSuccess(int? statusCode) {
    return statusCode == QuarkConfig.responseStatus['httpSuccess'];
  }

  /// 验证API响应状态
  static bool isApiSuccess(dynamic apiCode) {
    return apiCode == QuarkConfig.responseStatus['apiSuccess'];
  }

  /// 提取响应数据
  static dynamic getResponseData(Map<String, dynamic> response, String field) {
    return response[QuarkConfig.responseFields[field]];
  }

  /// 提取错误信息
  static String getErrorMessage(Map<String, dynamic> response) {
    return response[QuarkConfig.responseFields['message']] ?? '未知错误';
  }

  static void clearHttpCache({String? accountId}) {
    if (accountId == null) {
      _httpCache.clear();
      _authSnapshot.clear();
    } else {
      _httpCache.remove(accountId);
      _authSnapshot.remove(accountId);
    }
  }

  static String _authKey(CloudDriveAccount account) =>
      '${account.id}::${account.authValue ?? ''}::${account.primaryAuthValue ?? ''}';
}
