import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../../core/logging/log_manager.dart';

/// 全局日志配置
class CloudDriveApiLoggerConfig {
  static bool globalVerbose = false;
  static int globalTruncateLength = 2000;

  /// 统一设置全局日志开关和截断长度
  static void update({bool? verbose, int? truncateLength}) {
    if (verbose != null) {
      globalVerbose = verbose;
    }
    if (truncateLength != null) {
      globalTruncateLength = truncateLength;
    }
  }
}

/// 通用 API 日志记录器，提供请求/响应/错误的统一输出。
class CloudDriveApiLogger {
  CloudDriveApiLogger({
    required this.provider,
    bool? verbose,
    int? truncateLength,
    LogManager? logManager,
  })  : verbose = verbose ?? CloudDriveApiLoggerConfig.globalVerbose,
        truncateLength =
            truncateLength ?? CloudDriveApiLoggerConfig.globalTruncateLength,
        _logManager = logManager ?? LogManager();

  final String provider;
  final bool verbose;
  final int truncateLength;
  final LogManager _logManager;

  void logRequest(RequestOptions options) {
    final buffer = StringBuffer()
      ..writeln('[$provider] 请求: ${options.method} ${options.uri}');

    if (verbose && options.headers.isNotEmpty) {
      buffer.writeln('Headers:\n${_formatData(options.headers)}');
    }

    if (options.data != null) {
      buffer.writeln('Body: ${_formatData(options.data)}');
    }

    _logLarge(
      buffer.toString(),
      methodName: 'request',
    );
  }

  void logResponse(Response response) {
    final buffer = StringBuffer()
      ..writeln('[$provider] 响应: ${response.requestOptions.method} ${response.realUri} (code: ${response.statusCode})');

    if (response.data != null) {
      buffer.writeln('Body: ${_formatData(response.data)}');
    }

    _logLarge(
      buffer.toString(),
      methodName: 'response',
    );
  }

  void logError(DioException error) {
    final req = error.requestOptions;
    final buffer = StringBuffer()
      ..writeln(
        '[$provider] 请求异常: ${req.method} ${req.uri} (${error.response?.statusCode ?? 'no-status'})',
      )
      ..writeln('Message: ${error.message}');

    if (error.response?.data != null) {
      buffer.writeln('Body: ${_formatData(error.response!.data)}');
    }

    _logLarge(
      buffer.toString(),
      methodName: 'error',
      isError: true,
      exception: error,
    );
  }

  String _formatMap(Map headers) {
    final entries = headers.entries
        .map((e) => '${e.key}: ${_truncate(e.value.toString())}')
        .join(', ');
    return '{ $entries }';
  }

  String _formatData(dynamic data) {
    if (data is FormData) {
      final fields = {
        for (final field in data.fields) field.key: field.value,
      };
      final files = data.files.map((f) => f.value.filename).toList();
      return 'FormData(fields: ${jsonEncode(fields)}, files: $files)';
    }

    if (data is Map || data is List) {
      try {
        final pretty = const JsonEncoder.withIndent('  ').convert(data);
        return _truncate(pretty);
      } catch (_) {
        return _truncate(data.toString());
      }
    }

    return _truncate(data.toString());
  }

  String _truncate(String value) {
    if (value.length <= truncateLength) return value;
    return '${value.substring(0, truncateLength)}...';
  }

  void _logLarge(
    String message, {
    String? methodName,
    bool isError = false,
    dynamic exception,
  }) {
    const chunkSize = 900; // 避免 logcat 单行截断
    final totalChunks = (message.length / chunkSize).ceil();

    for (int i = 0; i < totalChunks; i++) {
      final start = i * chunkSize;
      final end = (i + 1) * chunkSize > message.length
          ? message.length
          : (i + 1) * chunkSize;
      final chunk = message.substring(start, end);
      final suffix = totalChunks > 1 ? ' [${i + 1}/$totalChunks]' : '';
      final text = '$chunk$suffix';

      if (isError) {
        _logManager.error(
          text,
          className: provider,
          methodName: methodName,
          exception: i == 0 ? exception : null,
        );
      } else {
        _logManager.cloudDrive(
          text,
          className: provider,
          methodName: methodName,
        );
      }
    }
  }
}

/// 通用日志拦截器，封装 Dio 的 onRequest/onResponse/onError。
class CloudDriveLoggingInterceptor extends Interceptor {
  CloudDriveLoggingInterceptor({required this.logger});

  final CloudDriveApiLogger logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.logRequest(options);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.logResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.logError(err);
    handler.next(err);
  }

  /// 便捷方法：为指定 Dio 添加日志拦截器。
  static void attach(
    Dio dio, {
    required String provider,
    bool? verbose,
    int? truncateLength,
    LogManager? logManager,
  }) {
    dio.interceptors.add(
      CloudDriveLoggingInterceptor(
        logger: CloudDriveApiLogger(
          provider: provider,
          verbose: verbose,
          truncateLength: truncateLength,
          logManager: logManager,
        ),
      ),
    );
  }
}
