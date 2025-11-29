import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../../core/logging/log_manager.dart';

/// 全局日志配置
class CloudDriveApiLoggerConfig {
  static bool globalVerbose = false;
  static int globalTruncateLength = 800;

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
      buffer.writeln('Headers: ${_formatMap(options.headers)}');
    }

    if (options.data != null) {
      buffer.writeln('Body: ${_formatData(options.data)}');
    }

    _logManager.cloudDrive(buffer.toString(), className: provider, methodName: 'request');
  }

  void logResponse(Response response) {
    final buffer = StringBuffer()
      ..writeln('[$provider] 响应: ${response.requestOptions.method} ${response.realUri} (code: ${response.statusCode})');

    if (response.data != null) {
      buffer.writeln('Body: ${_formatData(response.data)}');
    }

    _logManager.cloudDrive(buffer.toString(), className: provider, methodName: 'response');
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

    _logManager.error(
      buffer.toString(),
      className: provider,
      methodName: 'error',
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
        return _truncate(const JsonEncoder().convert(data));
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
}
