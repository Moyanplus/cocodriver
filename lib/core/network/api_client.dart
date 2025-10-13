import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../error/failures.dart';
import 'api_endpoints.dart';
import 'network_interceptor.dart';

part 'api_client.g.dart';

/// API客户端
/// 使用Retrofit生成网络请求代码
@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  /// 获取用户配置
  @GET(ApiEndpoints.userSettings)
  Future<dynamic> getUserSettings();

  /// 更新用户配置
  @PUT(ApiEndpoints.updateSettings)
  Future<dynamic> updateUserSettings(@Body() Map<String, dynamic> settings);

  /// 获取用户统计信息
  @GET(ApiEndpoints.userStatistics)
  Future<dynamic> getUserStatistics();

  /// 获取系统信息
  @GET(ApiEndpoints.systemInfo)
  Future<dynamic> getSystemInfo();

  /// 获取应用版本信息
  @GET(ApiEndpoints.appVersion)
  Future<dynamic> getAppVersion();

  /// 提交反馈
  @POST(ApiEndpoints.feedback)
  Future<dynamic> submitFeedback(@Body() Map<String, dynamic> feedback);

  /// 报告Bug
  @POST(ApiEndpoints.reportBug)
  Future<dynamic> reportBug(@Body() Map<String, dynamic> bugReport);

  /// 请求新功能
  @POST(ApiEndpoints.featureRequest)
  Future<dynamic> requestFeature(@Body() Map<String, dynamic> featureRequest);

  /// 上传文件
  @POST(ApiEndpoints.uploadFile)
  @MultiPart()
  Future<dynamic> uploadFile(@Part() File file, @Part() String type);

  /// 上传图片
  @POST(ApiEndpoints.uploadImage)
  @MultiPart()
  Future<dynamic> uploadImage(@Part() File image, @Part() String? category);
}

/// API客户端工厂
class ApiClientFactory {
  static ApiClient? _instance;
  static Dio? _dio;

  /// 获取API客户端实例
  static ApiClient getInstance({String? baseUrl}) {
    if (_instance == null) {
      _dio = _createDio(baseUrl);
      _instance = ApiClient(_dio!, baseUrl: baseUrl);
    }
    return _instance!;
  }

  /// 创建Dio实例
  static Dio _createDio(String? baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 添加拦截器
    dio.interceptors.addAll([
      LoggingInterceptor(),
      NetworkInterceptor(),
      RetryInterceptor(),
    ]);

    return dio;
  }

  /// 更新基础URL
  static void updateBaseUrl(String newBaseUrl) {
    _instance = null;
    _dio = null;
    getInstance(baseUrl: newBaseUrl);
  }

  /// 添加认证token
  static void setAuthToken(String token) {
    if (_dio != null) {
      _dio!.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// 移除认证token
  static void removeAuthToken() {
    if (_dio != null) {
      _dio!.options.headers.remove('Authorization');
    }
  }

  /// 重置客户端
  static void reset() {
    _instance = null;
    _dio = null;
  }
}

/// 网络服务基类
abstract class NetworkService {
  final ApiClient _apiClient;

  NetworkService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClientFactory.getInstance();

  /// 处理网络请求
  Future<T> handleRequest<T>(
    Future<T> Function() request, {
    T? fallbackValue,
  }) async {
    try {
      return await request();
    } catch (e) {
      // 这里可以添加额外的错误处理逻辑
      // 比如记录日志、发送错误报告等
      rethrow;
    }
  }

  /// 处理分页请求
  Future<Map<String, dynamic>> handlePaginatedRequest(
    Future<Map<String, dynamic>> Function() request, {
    int page = 1,
    int limit = 20,
  }) async {
    return await handleRequest(request);
  }
}
