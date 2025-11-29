import 'package:coco_cloud_drive/tool/cloud_drive/data/models/cloud_drive_entities.dart';
import 'package:dio/dio.dart';

import '../../../../../../core/logging/log_manager.dart';
import 'lanzou_dio_factory.dart';
import '../lanzou_config.dart';
import '../exceptions/lanzou_exceptions.dart';
import '../utils/lanzou_utils.dart';

/// 封装蓝奏云 API 请求的客户端。
///
/// 负责在蓝奏官方 `api.php` 接口上执行 POST 请求，自动附带 UID、Cookie、
/// 默认请求头等信息，同时提供简单的重试机制，保证在弱网络条件下仍可工作。
class LanzouApiClient {
  LanzouApiClient({
    required this.account,
    required this.uid,
    this.maxRetries = 1,
    this.retryDelay = const Duration(milliseconds: 200),
  }) : _dio = LanzouDioFactory.createDio(account);

  /// 从 Cookie 创建临时账号对象
  factory LanzouApiClient.fromCookies({
    required String cookies,
    required String uid,
  }) {
    final tempAccount = LanzouUtils.createTempAccount(cookies, uid: uid);
    return LanzouApiClient(account: tempAccount, uid: uid);
  }

  final CloudDriveAccount account;
  final String uid;
  final int maxRetries;
  final Duration retryDelay;
  final Dio _dio;

  Map<String, String> get _headers => {
    ...LanzouConfig.defaultHeaders,
    'Cookie': account.cookies ?? '',
    'Referer': '${LanzouConfig.baseUrl}/',
    'Origin': LanzouConfig.baseUrl,
  };

  /// 执行 POST 请求并返回蓝奏云原始响应 Map。
  ///
  /// 当接口返回非 Map 或网络失败时会抛出 [LanzouApiException]，调用
  /// 方可在更高层统一捕获并提示用户。
  Future<Map<String, dynamic>> post(Map<String, dynamic> data) async {
    LogManager().cloudDrive('蓝奏云 - API 请求数据: $data');
    DioException? lastError;

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await _dio.post(
          '${LanzouConfig.apiUrl}?uid=$uid',
          data: FormData.fromMap(data),
          options: Options(
            headers: _headers,
            followRedirects: LanzouConfig.followRedirects,
            maxRedirects: LanzouConfig.maxRedirects,
          ),
        );

        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }

        throw LanzouApiException('响应数据格式错误: ${response.data.runtimeType}');
      } on DioException catch (e) {
        lastError = e;
        LogManager().cloudDrive('蓝奏云 - API 请求失败: ${e.message}');
        if (attempt < maxRetries - 1) {
          await Future.delayed(retryDelay);
          continue;
        }
        throw LanzouApiException(e.message ?? '网络请求失败');
      }
    }

    throw LanzouApiException(lastError?.message ?? '网络请求失败');
  }
}
