import 'package:dio/dio.dart';
import '../../../core/services/base/debug_service.dart';
import '../../models/cloud_drive_models.dart';
import 'baidu_config.dart';

/// 百度云盘基础服务
/// 提供dio配置和通用方法
class BaiduBaseService {
  // 创建dio实例
  static Dio createDio(CloudDriveAccount account) {
    final dio = Dio(
      BaseOptions(
        baseUrl: BaiduConfig.baseUrl,
        connectTimeout: BaiduConfig.connectTimeout,
        receiveTimeout: BaiduConfig.receiveTimeout,
        sendTimeout: BaiduConfig.sendTimeout,
        headers: {
          ...BaiduConfig.defaultHeaders,
          'User-Agent':
              account.type.webViewConfig.userAgent ??
              BaiduConfig.defaultHeaders['User-Agent']!,
          ...account.authHeaders,
        },
        followRedirects: BaiduConfig.followRedirects,
        maxRedirects: BaiduConfig.maxRedirects,
        validateStatus: BaiduConfig.validateStatus,
      ),
    );

    // 添加请求拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          DebugService.log(
            '📡 百度网盘 - 发送请求: ${options.method} ${options.uri}',
            category: DebugCategory.tools,
            subCategory: BaiduConfig.logSubCategory,
          );
          DebugService.log(
            '📋 百度网盘 - 请求头: ${options.headers}',
            category: DebugCategory.tools,
            subCategory: BaiduConfig.logSubCategory,
          );
          if (options.data != null) {
            DebugService.log(
              '📤 百度网盘 - 请求体: ${options.data}',
              category: DebugCategory.tools,
              subCategory: BaiduConfig.logSubCategory,
            );
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          DebugService.log(
            '📡 百度网盘 - 收到响应: ${response.statusCode}',
            category: DebugCategory.tools,
            subCategory: BaiduConfig.logSubCategory,
          );
          DebugService.log(
            '📄 百度网盘 - 响应数据: ${response.data}',
            category: DebugCategory.tools,
            subCategory: BaiduConfig.logSubCategory,
          );
          handler.next(response);
        },
        onError: (error, handler) {
          DebugService.log(
            '❌ 百度网盘 - 请求错误: ${error.message}',
            category: DebugCategory.tools,
            subCategory: BaiduConfig.logSubCategory,
          );
          if (error.response != null) {
            DebugService.log(
              '📄 百度网盘 - 错误响应: ${error.response?.data}',
              category: DebugCategory.tools,
              subCategory: BaiduConfig.logSubCategory,
            );
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// 验证响应状态
  static bool isSuccessResponse(Map<String, dynamic> response) =>
      BaiduConfig.isSuccessResponse(response);

  /// 获取响应数据
  static Map<String, dynamic>? getResponseData(Map<String, dynamic> response) =>
      BaiduConfig.getResponseData(response);

  /// 获取响应消息
  static String getResponseMessage(Map<String, dynamic> response) =>
      BaiduConfig.getResponseMessage(response);

  /// 处理API响应
  static Map<String, dynamic> handleApiResponse(Map<String, dynamic> response) {
    DebugService.log(
      '📊 百度网盘 - 处理API响应: errno=${response['errno']}',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    if (isSuccessResponse(response)) {
      DebugService.log(
        '✅ 百度网盘 - API请求成功',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return response;
    } else {
      final message = getResponseMessage(response);
      DebugService.log(
        '❌ 百度网盘 - API请求失败: $message',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      throw Exception(message);
    }
  }

  /// 构建请求参数
  static Map<String, dynamic> buildRequestParams({
    required String dir,
    int page = 1,
    int num = 100,
    String? order,
    String? desc,
    String? search,
  }) {
    final params = <String, dynamic>{
      'dir': BaiduConfig.getFolderId(dir),
      'page': page,
      'num': num.clamp(1, BaiduConfig.maxPageSize),
    };

    if (order != null) {
      params['order'] = order;
    }
    if (desc != null) {
      params['desc'] = desc;
    }
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    DebugService.log(
      '🔧 百度网盘 - 构建请求参数: $params',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    return params;
  }

  /// 格式化时间戳
  static String formatTimestamp(int timestamp) {
    if (timestamp == 0) {
      DebugService.log(
        '⚠️ 百度网盘 - 时间戳为0，返回未知时间',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return '未知时间';
    }

    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    DebugService.log(
      '⏰ 百度网盘 - 时间戳转换: $timestamp -> $dateTime',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    // 返回具体的日期时间格式
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    final formatted = '$year-$month-$day $hour:$minute';
    DebugService.log(
      '📅 百度网盘 - 格式化时间: $formatted',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    return formatted;
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes == 0) {
      DebugService.log(
        '📏 百度网盘 - 文件大小为0，返回0 B',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return '0 B';
    }

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();

    DebugService.log(
      '📏 百度网盘 - 开始格式化文件大小: $bytes bytes',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
      DebugService.log(
        '📏 百度网盘 - 转换步骤: ${suffixes[i - 1]} -> ${suffixes[i]}, 大小: $size',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
    }

    final result = '${size.toStringAsFixed(1)} ${suffixes[i]}';
    DebugService.log(
      '✅ 百度网盘 - 文件大小格式化完成: $bytes bytes -> $result',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    return result;
  }

  /// 解析文件大小
  static int? parseFileSize(String sizeStr) =>
      BaiduConfig.parseFileSize(sizeStr);

  /// 检查文件类型是否支持
  static bool isFileTypeSupported(String fileName) =>
      BaiduConfig.isFileTypeSupported(fileName);

  /// 获取MIME类型
  static String getMimeType(String fileName) =>
      BaiduConfig.getMimeType(fileName);

  /// 验证文件路径
  static bool isValidPath(String path) => BaiduConfig.isValidPath(path);

  /// 清理文件名
  static String sanitizeFileName(String fileName) =>
      BaiduConfig.sanitizeFileName(fileName);

  /// 获取操作类型描述
  static String getOperationDescription(String operation) =>
      BaiduConfig.getOperationDescription(operation);
}
