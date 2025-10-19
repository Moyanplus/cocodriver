import 'package:dio/dio.dart';

import '../../../../core/logging/log_manager.dart';
import '../../models/cloud_drive_models.dart';
import 'quark_auth_service.dart';
import 'quark_config.dart';

/// 夸克云盘基础服务类
/// 提供通用的dio实例创建和请求拦截器
abstract class QuarkBaseService {
  /// 创建dio实例（使用原始认证头）
  static Dio createDio(CloudDriveAccount account) {
    final dio = Dio(
      BaseOptions(
        baseUrl: QuarkConfig.baseUrl,
        connectTimeout: QuarkConfig.connectTimeout,
        receiveTimeout: QuarkConfig.receiveTimeout,
        headers: {...QuarkConfig.defaultHeaders, ...account.authHeaders},
      ),
    );

    _addInterceptors(dio);
    return dio;
  }

  /// 创建带有刷新认证的dio实例
  static Future<Dio> createDioWithAuth(CloudDriveAccount account) async {
    LogManager().cloudDrive('🔧 QuarkBaseService - 开始创建带认证的Dio实例');
    LogManager().cloudDrive('👤 账号ID: ${account.id}');

    try {
      LogManager().cloudDrive('🔄 调用 QuarkAuthService.buildAuthHeaders...');
      final authHeaders = await QuarkAuthService.buildAuthHeaders(account);
      LogManager().cloudDrive('✅ 获取认证头成功，键数量: ${authHeaders.length}');

      final dio = Dio(
        BaseOptions(
          baseUrl: QuarkConfig.baseUrl,
          connectTimeout: QuarkConfig.connectTimeout,
          receiveTimeout: QuarkConfig.receiveTimeout,
          headers: authHeaders,
        ),
      );

      _addInterceptors(dio);
      LogManager().cloudDrive('✅ Dio实例创建完成');
      return dio;
    } catch (e) {
      LogManager().cloudDrive('❌ 创建Dio实例失败: $e');
      rethrow;
    }
  }

  /// 添加请求拦截器
  static void _addInterceptors(Dio dio) {
    // 添加请求拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          LogManager().network(
            '夸克云盘请求: ${options.method} ${options.uri}',
            className: 'QuarkBaseService',
            methodName: 'onRequest',
            data: {
              'method': options.method,
              'uri': options.uri.toString(),
              'headers': options.headers,
              'data': options.data?.toString(),
            },
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          LogManager().cloudDrive('📡 收到响应: ${response.statusCode}');
          LogManager().cloudDrive(
            '📄 响应内容长度: ${response.data?.toString().length ?? 0}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          LogManager().cloudDrive('❌ 请求错误: ${error.message}');
          if (error.response != null) {
            LogManager().cloudDrive(
              '📄 错误响应: ${error.response?.statusCode} - ${error.response?.data}',
            );
          }
          handler.next(error);
        },
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

    // 添加请求拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          LogManager().cloudDrive('📡 发送请求: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          LogManager().network(
            '夸克云盘响应: ${response.statusCode}',
            className: 'QuarkBaseService',
            methodName: 'onResponse',
            data: {
              'statusCode': response.statusCode,
              'uri': response.requestOptions.uri.toString(),
              'data': response.data?.toString(),
            },
          );
          handler.next(response);
        },
        onError: (error, handler) {
          LogManager().cloudDrive('❌ 请求错误: ${error.message}');
          handler.next(error);
        },
      ),
    );

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
}
