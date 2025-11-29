import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/cloud_drive_entities.dart';
import '../infrastructure/performance/performance_metrics.dart';
import '../infrastructure/error/recovery_strategies.dart';

/// 通用工具类
///
/// 提供通用的工具方法，包括 Dio 创建、错误处理、性能监控等。
class CommonUtils {
  static final PerformanceMetrics _metrics = PerformanceMetrics();

  /// 统一的 Dio 创建方法
  ///
  /// [account] 云盘账号信息
  /// [connectTimeout] 连接超时时间（可选）
  /// [receiveTimeout] 接收超时时间（可选）
  /// [sendTimeout] 发送超时时间（可选）
  /// [defaultHeaders] 默认请求头（可选）
  static Dio createDio({
    required CloudDriveAccount account,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, String>? defaultHeaders,
  }) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        sendTimeout: sendTimeout ?? const Duration(seconds: 30),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json, text/plain, */*',
          'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Cache-Control': 'no-cache',
          ...?defaultHeaders,
        },
      ),
    );

    // 添加请求拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logRequest(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          handler.next(response);
        },
        onError: (error, handler) {
          _logError(error);
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// 统一的API请求方法
  ///
  /// 执行HTTP API请求的统一方法，包含错误处理和性能监控
  ///
  /// [dio] Dio实例
  /// [method] HTTP方法
  /// [url] 请求URL
  /// [data] 请求数据（可选）
  /// [queryParameters] 查询参数（可选）
  /// [headers] 请求头（可选）
  /// [timeout] 超时时间（可选）
  /// [operationId] 操作ID（可选）
  /// 返回响应结果
  static Future<Response<T>> apiRequest<T>({
    required Dio dio,
    required String method,
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Duration? timeout,
    String? operationId,
  }) async {
    final startTime = DateTime.now();
    final opId =
        operationId ?? '${method.toUpperCase()}_${Uri.parse(url).path}';

    try {
      final response = await RecoveryStrategies.apiCall(
        operationId: opId,
        operation: () async {
          switch (method.toUpperCase()) {
            case 'GET':
              return await dio.get<T>(
                url,
                queryParameters: queryParameters,
                options: Options(headers: headers),
              );
            case 'POST':
              return await dio.post<T>(
                url,
                data: data,
                queryParameters: queryParameters,
                options: Options(headers: headers),
              );
            case 'PUT':
              return await dio.put<T>(
                url,
                data: data,
                queryParameters: queryParameters,
                options: Options(headers: headers),
              );
            case 'DELETE':
              return await dio.delete<T>(
                url,
                data: data,
                queryParameters: queryParameters,
                options: Options(headers: headers),
              );
            default:
              throw ArgumentError('Unsupported HTTP method: $method');
          }
        },
        context: {
          'url': url,
          'method': method,
          'has_data': data != null,
          'has_query': queryParameters != null,
        },
      );

      // 记录性能指标
      final duration = DateTime.now().difference(startTime);
      _metrics.recordApiCall(
        endpoint: url,
        method: method,
        duration: duration,
        statusCode: response.statusCode,
        responseSize: response.data?.toString().length,
      );

      return response;
    } catch (error) {
      final duration = DateTime.now().difference(startTime);
      _metrics.recordApiCall(
        endpoint: url,
        method: method,
        duration: duration,
        error: error.toString(),
      );
      rethrow;
    }
  }

  /// 统一的文件操作包装器
  static Future<T> fileOperation<T>({
    required String operation,
    required Future<T> Function() operationFunction,
    String? fileName,
    int? fileSize,
    Map<String, dynamic>? context,
  }) async {
    final startTime = DateTime.now();
    final operationId = 'file_${operation}_${fileName ?? 'unknown'}';

    try {
      final result = await RecoveryStrategies.fileOperation(
        operationId: operationId,
        operation: operationFunction,
        context: {
          'operation': operation,
          'file_name': fileName,
          'file_size': fileSize,
          ...?context,
        },
      );

      // 记录性能指标
      final duration = DateTime.now().difference(startTime);
      _metrics.recordFileOperation(
        operation: operation,
        fileName: fileName ?? 'unknown',
        duration: duration,
        fileSize: fileSize,
      );

      return result;
    } catch (error) {
      final duration = DateTime.now().difference(startTime);
      _metrics.recordFileOperation(
        operation: operation,
        fileName: fileName ?? 'unknown',
        duration: duration,
        fileSize: fileSize,
        error: error.toString(),
      );
      rethrow;
    }
  }

  /// 统一的日志记录方法
  ///
  /// 记录信息级别的日志
  ///
  /// [message] 日志消息
  /// [context] 上下文信息（可选）
  static void logInfo(String message, {Map<String, dynamic>? context}) {
    if (kDebugMode) {
      print(message);
      if (context != null && context.isNotEmpty) {
        print('   Context: $context');
      }
    }
  }

  /// 记录成功日志
  ///
  /// 记录成功操作的日志
  ///
  /// [message] 日志消息
  /// [context] 上下文信息（可选）
  static void logSuccess(String message, {Map<String, dynamic>? context}) {
    if (kDebugMode) {
      print(message);
      if (context != null && context.isNotEmpty) {
        print('   Context: $context');
      }
    }
  }

  /// 记录错误日志
  ///
  /// 记录错误操作的日志
  ///
  /// [message] 日志消息
  /// [error] 错误信息（可选）
  /// [context] 上下文信息（可选）
  static void logError(
    String message, {
    dynamic error,
    Map<String, dynamic>? context,
  }) {
    if (kDebugMode) {
      print(message);
      if (error != null) {
        print('   Error: $error');
      }
      if (context != null && context.isNotEmpty) {
        print('   Context: $context');
      }
    }
  }

  /// 记录警告日志
  ///
  /// 记录警告信息的日志
  ///
  /// [message] 日志消息
  /// [context] 上下文信息（可选）
  static void logWarning(String message, {Map<String, dynamic>? context}) {
    if (kDebugMode) {
      print(message);
      if (context != null && context.isNotEmpty) {
        print('   Context: $context');
      }
    }
  }

  /// 统一的错误处理方法
  ///
  /// 处理各种类型错误的统一方法
  ///
  /// [error] 错误对象
  /// [operation] 操作名称（可选）
  /// 返回格式化的错误消息
  static String handleError(dynamic error, {String? operation}) {
    if (error is DioException) {
      return _handleDioError(error, operation);
    } else if (error is FileSystemException) {
      return _handleFileSystemError(error, operation);
    } else if (error is TimeoutException) {
      return _handleTimeoutError(error, operation);
    } else if (error is SocketException) {
      return _handleSocketError(error, operation);
    } else {
      return _handleGenericError(error, operation);
    }
  }

  /// 统一的响应解析方法
  ///
  /// 解析HTTP响应的统一方法
  ///
  /// [response] HTTP响应
  /// [parser] 数据解析函数
  /// [errorMessage] 自定义错误消息（可选）
  /// 返回解析后的数据
  static T parseResponse<T>({
    required Response response,
    required T Function(Map<String, dynamic>) parser,
    String? errorMessage,
  }) {
    try {
      if (response.statusCode != 200) {
        throw Exception(
          errorMessage ??
              'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return parser(data);
      } else if (data is String) {
        final jsonData = jsonDecode(data) as Map<String, dynamic>;
        return parser(jsonData);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (error) {
      logError('Failed to parse response', error: error);
      rethrow;
    }
  }

  /// 统一的文件大小格式化
  ///
  /// 将字节数格式化为可读的文件大小字符串
  ///
  /// [bytes] 字节数
  /// 返回格式化的文件大小字符串
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }

  /// 统一的时间格式化
  ///
  /// 将DateTime格式化为标准时间字符串
  ///
  /// [time] 时间对象
  /// 返回格式化的时间字符串
  static String formatTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  /// 统一的相对时间格式化
  ///
  /// 将DateTime格式化为相对时间描述
  ///
  /// [time] 时间对象
  /// 返回相对时间字符串
  static String formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 统一的文件名验证
  ///
  /// 验证文件名是否合法
  ///
  /// [fileName] 文件名
  /// 返回是否合法
  static bool isValidFileName(String fileName) {
    if (fileName.isEmpty || fileName.length > 255) return false;

    // 检查非法字符
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if (invalidChars.hasMatch(fileName)) return false;

    // 检查保留名称
    final reservedNames = [
      'CON',
      'PRN',
      'AUX',
      'NUL',
      'COM1',
      'COM2',
      'COM3',
      'COM4',
      'COM5',
      'COM6',
      'COM7',
      'COM8',
      'COM9',
      'LPT1',
      'LPT2',
      'LPT3',
      'LPT4',
      'LPT5',
      'LPT6',
      'LPT7',
      'LPT8',
      'LPT9',
    ];

    final nameWithoutExt = fileName.split('.').first.toUpperCase();
    if (reservedNames.contains(nameWithoutExt)) return false;

    return true;
  }

  /// 统一的文件类型检测
  ///
  /// 根据文件扩展名检测文件类型
  ///
  /// [fileName] 文件名
  /// 返回文件类型字符串
  static String getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'];
    const videoExtensions = ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm'];
    const audioExtensions = ['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a'];
    const documentExtensions = [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
    ];
    const archiveExtensions = ['zip', 'rar', '7z', 'tar', 'gz'];

    if (imageExtensions.contains(extension)) return 'image';
    if (videoExtensions.contains(extension)) return 'video';
    if (audioExtensions.contains(extension)) return 'audio';
    if (documentExtensions.contains(extension)) return 'document';
    if (archiveExtensions.contains(extension)) return 'archive';

    return 'unknown';
  }

  /// 统一的网络状态检查
  ///
  /// 检查网络连接状态
  ///
  /// 返回网络是否可用
  static Future<bool> checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 统一的延迟执行
  ///
  /// 延迟指定时间后继续执行
  ///
  /// [duration] 延迟时间
  static Future<void> delay(Duration duration) async {
    await Future.delayed(duration);
  }

  /// 统一的防抖执行
  ///
  /// 防抖执行回调函数，在指定时间内只执行最后一次调用
  ///
  /// [delay] 防抖延迟时间
  /// [callback] 回调函数
  static Timer? _debounceTimer;
  static void debounce(Duration delay, VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// 统一的节流执行
  ///
  /// 节流执行回调函数，在指定时间间隔内只执行一次
  ///
  /// [interval] 节流时间间隔
  /// [callback] 回调函数
  /// 返回是否执行了回调
  static DateTime? _lastThrottleTime;
  static bool throttle(Duration interval, VoidCallback callback) {
    final now = DateTime.now();
    if (_lastThrottleTime == null ||
        now.difference(_lastThrottleTime!) >= interval) {
      _lastThrottleTime = now;
      callback();
      return true;
    }
    return false;
  }

  // 私有方法
  /// 记录请求日志
  ///
  /// 记录HTTP请求的详细信息
  ///
  /// [options] 请求选项
  static void _logRequest(RequestOptions options) {
    logInfo(
      '${options.method} ${options.uri}',
      context: {
        'headers': options.headers,
        'data': options.data?.toString(),
        'query': options.queryParameters,
      },
    );
  }

  /// 记录响应日志
  ///
  /// 记录HTTP响应的详细信息
  ///
  /// [response] HTTP响应
  static void _logResponse(Response response) {
    logSuccess(
      '${response.requestOptions.method} ${response.requestOptions.uri} - ${response.statusCode}',
      context: {
        'status_message': response.statusMessage,
        'data_size': response.data?.toString().length,
      },
    );
  }

  /// 记录错误日志
  ///
  /// 记录Dio错误的详细信息
  ///
  /// [error] Dio错误
  static void _logError(DioException error) {
    logError(
      'FATAL ${error.requestOptions.method} ${error.requestOptions.uri}',
      error: error,
      context: {
        'type': error.type.toString(),
        'message': error.message,
        'response': error.response?.data?.toString(),
      },
    );
  }

  /// 处理Dio错误
  ///
  /// 根据Dio错误类型返回对应的错误消息
  ///
  /// [error] Dio错误
  /// [operation] 操作名称（可选）
  /// 返回错误消息
  static String _handleDioError(DioException error, String? operation) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络连接';
      case DioExceptionType.sendTimeout:
        return '发送超时，请重试';
      case DioExceptionType.receiveTimeout:
        return '接收超时，请重试';
      case DioExceptionType.badResponse:
        return '服务器错误: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接错误，请检查网络';
      case DioExceptionType.badCertificate:
        return '证书验证失败';
      case DioExceptionType.unknown:
        return '未知错误: ${error.message}';
    }
  }

  /// 处理文件系统错误
  ///
  /// 处理文件系统相关的错误
  ///
  /// [error] 文件系统错误
  /// [operation] 操作名称（可选）
  /// 返回错误消息
  static String _handleFileSystemError(
    FileSystemException error,
    String? operation,
  ) {
    return '文件系统错误: ${error.message}';
  }

  /// 处理超时错误
  ///
  /// 处理超时相关的错误
  ///
  /// [error] 超时错误
  /// [operation] 操作名称（可选）
  /// 返回错误消息
  static String _handleTimeoutError(TimeoutException error, String? operation) {
    return '操作超时，请重试';
  }

  /// 处理Socket错误
  ///
  /// 处理网络Socket相关的错误
  ///
  /// [error] Socket错误
  /// [operation] 操作名称（可选）
  /// 返回错误消息
  static String _handleSocketError(SocketException error, String? operation) {
    return '网络连接失败: ${error.message}';
  }

  /// 处理通用错误
  ///
  /// 处理其他类型的错误
  ///
  /// [error] 错误对象
  /// [operation] 操作名称（可选）
  /// 返回错误消息
  static String _handleGenericError(dynamic error, String? operation) {
    return '操作失败: ${error.toString()}';
  }
}
