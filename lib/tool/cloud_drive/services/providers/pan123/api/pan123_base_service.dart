import 'dart:math';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../../../../../../core/logging/log_manager.dart';
import '../../../../data/models/cloud_drive_entities.dart';
import '../../../base/cloud_drive_api_logger.dart';
import 'pan123_config.dart';
import 'pan123_error_mapper.dart';

/// 123云盘基础服务
///
/// 提供 Dio 配置和通用方法，包括请求拦截、响应处理等。
class Pan123BaseService {
  static final Random _random = Random();
  static Dio Function(CloudDriveAccount account) _dioFactory =
      _defaultDioFactory;

  /// 覆写用于测试的 Dio factory
  @visibleForTesting
  static set dioFactory(Dio Function(CloudDriveAccount account) factory) =>
      _dioFactory = factory;

  /// 重置为默认 factory
  @visibleForTesting
  static void resetDioFactory() => _dioFactory = _defaultDioFactory;

  /// 创建 Dio 实例
  ///
  /// [account] 当前账号（提供认证 headers 等）
  static Dio createDio(CloudDriveAccount account) {
    return _dioFactory(account);
  }

  static Dio _defaultDioFactory(CloudDriveAccount account) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Pan123Config.baseUrl,
        connectTimeout: Pan123Config.connectTimeout,
        receiveTimeout: Pan123Config.receiveTimeout,
        sendTimeout: Pan123Config.sendTimeout,
        headers: {
          ...Pan123Config.defaultHeaders,
          'User-Agent':
              account.type.webViewConfig.userAgent ??
              Pan123Config.defaultHeaders['User-Agent']!,
          ...account.authHeaders,
        },
      ),
    );

    dio.interceptors.add(
      CloudDriveLoggingInterceptor(
        logger: CloudDriveApiLogger(
          provider: '123云盘',
          verbose: Pan123Config.enableDetailedLog,
        ),
      ),
    );

    return dio;
  }

  /// 获取错误信息
  static String getErrorMessage(int code) {
    LogManager().cloudDrive('123云盘 - 查找错误信息: code=$code');

    return Pan123Config.getErrorMessage(code);
  }

  /// 验证响应状态码是否代表成功
  static bool isSuccessResponse(Map<String, dynamic> response) =>
      response['code'] == 0;

  /// 获取响应中的 data 字段
  static Map<String, dynamic>? getResponseData(
    Map<String, dynamic> response,
  ) {
    if (isSuccessResponse(response)) {
      return response['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// 获取响应中的 message 文案
  static String getResponseMessage(Map<String, dynamic> response) =>
      response['message'] as String? ??
      getErrorMessage(response['code'] as int? ?? -1);

  /// 统一处理 API 响应，成功返回数据，失败抛出 [CloudDriveException]
  static Map<String, dynamic> handleApiResponse(
    Map<String, dynamic> response, {
    String operation = '123云盘API',
  }) {
    final code = response['code'] is int ? response['code'] as int : -1;
    LogManager().cloudDrive('123云盘 - 处理API响应: code=$code');

    if (isSuccessResponse(response)) {
      LogManager().cloudDrive('123云盘 - API请求成功');
      return response;
    } else {
      final message = getResponseMessage(response);
      LogManager().cloudDrive('123云盘 - API请求失败: $message');
      throw Pan123ErrorMapper.map(
        code,
        message,
        operation: operation,
        context: response,
      );
    }
  }

  /// 构建请求参数（用于GET请求的查询参数）
  ///
  /// 根据 123 云盘前端实现生成随机 query，用于规避缓存。
  static Map<String, dynamic> buildRequestParams({
    required String parentId,
    int page = 1,
    int limit = 100,
    String? orderBy,
    String? orderDirection,
    String? searchValue,
  }) {
    // 生成时间戳参数（类似你URL中的901108958=1754698117-5448833-1822996736）
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomValue = '$timestamp-${timestamp.hashCode}-${timestamp * 2}';

    final params = <String, dynamic>{
      // 添加时间戳参数
      timestamp.toString(): randomValue,
      'driveId': '0', // 固定值
      'limit': limit.clamp(1, Pan123Config.maxPageSize),
      'next': '0', // 分页参数
      'orderBy': orderBy ?? 'update_time', // 默认按更新时间排序
      'orderDirection': orderDirection ?? 'desc', // 默认降序
      'parentFileId': Pan123Config.getFolderId(parentId),
      'trashed': 'false', // 不包含回收站文件
      'SearchData': searchValue ?? '', // 搜索关键词
      'Page': page.toString(),
      'OnlyLookAbnormalFile': '0', // 不只查看异常文件
      'event': 'homeListFile', // 事件类型
      'operateType': '1', // 操作类型
      'inDirectSpace': 'false', // 不在直接空间中
    };

    LogManager().cloudDrive('123云盘 - 构建GET请求参数: $params');

    return params;
  }

  /// 构建类似官方 JS 添加的时间戳参数，部分 POST 接口需要
  static Map<String, String> buildNoiseQueryParams() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final value =
        '${_random.nextInt(1 << 31)}-${_random.nextInt(1 << 31)}-${timestamp ^ _random.nextInt(1 << 20)}';
    return {timestamp.toString(): value};
  }
}
