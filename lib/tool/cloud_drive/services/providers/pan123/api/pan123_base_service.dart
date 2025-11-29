import 'package:dio/dio.dart';

import '../../../../../../core/logging/log_manager.dart';
import '../../../base/cloud_drive_api_logger.dart';
import '../../../../data/models/cloud_drive_entities.dart';
import 'pan123_config.dart';

/// 123云盘基础服务
///
/// 提供 Dio 配置和通用方法，包括请求拦截、响应处理等。
class Pan123BaseService {
  /// 创建 Dio 实例
  static Dio createDio(CloudDriveAccount account) {
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

  /// 验证响应状态
  static bool isSuccessResponse(Map<String, dynamic> response) =>
      Pan123Config.isSuccessResponse(response);

  /// 获取响应数据
  static Map<String, dynamic>? getResponseData(Map<String, dynamic> response) =>
      Pan123Config.getResponseData(response);

  /// 获取响应消息
  static String getResponseMessage(Map<String, dynamic> response) =>
      Pan123Config.getResponseMessage(response);

  /// 处理API响应
  static Map<String, dynamic> handleApiResponse(Map<String, dynamic> response) {
    LogManager().cloudDrive('123云盘 - 处理API响应: code=${response['code']}');

    if (isSuccessResponse(response)) {
      LogManager().cloudDrive('123云盘 - API请求成功');
      return response;
    } else {
      final message = getResponseMessage(response);
      LogManager().cloudDrive('123云盘 - API请求失败: $message');
      throw Exception(message);
    }
  }

  /// 构建请求参数（用于GET请求的查询参数）
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
}
