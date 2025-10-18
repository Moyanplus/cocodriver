import 'package:dio/dio.dart';
import '../../../core/services/base/debug_service.dart';
import '../../models/cloud_drive_models.dart';
import 'pan123_config.dart';

/// 123云盘基础服务
/// 提供dio配置和通用方法
class Pan123BaseService {
  // 创建dio实例
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

    // 添加请求拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          DebugService.log(
            '📡 123云盘 - 发送请求: ${options.method} ${options.uri}',
            category: DebugCategory.tools,
            subCategory: Pan123Config.logSubCategory,
          );
          DebugService.log(
            '📋 123云盘 - 请求头: ${options.headers}',
            category: DebugCategory.tools,
            subCategory: Pan123Config.logSubCategory,
          );
          if (options.data != null) {
            DebugService.log(
              '📤 123云盘 - 请求体: ${options.data}',
              category: DebugCategory.tools,
              subCategory: Pan123Config.logSubCategory,
            );
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          DebugService.log(
            '📡 123云盘 - 收到响应: ${response.statusCode}',
            category: DebugCategory.tools,
            subCategory: Pan123Config.logSubCategory,
          );
          DebugService.log(
            '📄 123云盘 - 响应数据: ${response.data}',
            category: DebugCategory.tools,
            subCategory: Pan123Config.logSubCategory,
          );
          handler.next(response);
        },
        onError: (error, handler) {
          DebugService.log(
            '❌ 123云盘 - 请求错误: ${error.message}',
            category: DebugCategory.tools,
            subCategory: Pan123Config.logSubCategory,
          );
          if (error.response != null) {
            DebugService.log(
              '📄 123云盘 - 错误响应: ${error.response?.data}',
              category: DebugCategory.tools,
              subCategory: Pan123Config.logSubCategory,
            );
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// 获取错误信息
  static String getErrorMessage(int code) {
    DebugService.log(
      '🔍 123云盘 - 查找错误信息: code=$code',
      category: DebugCategory.tools,
      subCategory: Pan123Config.logSubCategory,
    );

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
    DebugService.log(
      '📊 123云盘 - 处理API响应: code=${response['code']}',
      category: DebugCategory.tools,
      subCategory: Pan123Config.logSubCategory,
    );

    if (isSuccessResponse(response)) {
      DebugService.log(
        '✅ 123云盘 - API请求成功',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );
      return response;
    } else {
      final message = getResponseMessage(response);
      DebugService.log(
        '❌ 123云盘 - API请求失败: $message',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );
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

    DebugService.log(
      '🔧 123云盘 - 构建GET请求参数: $params',
      category: DebugCategory.tools,
      subCategory: Pan123Config.logSubCategory,
    );

    return params;
  }
}
