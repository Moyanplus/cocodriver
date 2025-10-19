import 'dart:convert';

import 'log_category.dart';
import 'log_config.dart';

/// 日志条目类
class Log {
  final String timestamp;
  final LogLevel logLevel;
  final String className;
  final String methodName;
  final String text;
  final dynamic exception;
  final String? stacktrace;
  final dynamic data;

  Log({
    required this.timestamp,
    required this.logLevel,
    required this.className,
    required this.methodName,
    required this.text,
    this.exception,
    this.stacktrace,
    this.data,
  });
}

/// 日志导出格式枚举
enum LogExportFormat { json, csv, text, html }

/// 日志格式化器
/// 提供各种格式的日志输出功能
class LogFormatter {
  static final LogFormatter _instance = LogFormatter._internal();
  factory LogFormatter() => _instance;
  LogFormatter._internal();

  final LogConfig _config = LogConfig();

  /// 格式化日志为JSON字符串
  String formatToJson(Log log) {
    try {
      final logData = {
        'timestamp': log.timestamp,
        'logLevel': log.logLevel.toString(),
        'className': log.className,
        'methodName': log.methodName,
        'text': log.text,
        'exception': log.exception?.toString(),
        'stacktrace': log.stacktrace,
        'data': log.data,
      };

      return jsonEncode(logData);
    } catch (e) {
      return '{"error": "格式化日志失败: $e"}';
    }
  }

  /// 格式化日志为CSV字符串
  String formatToCsv(Log log) {
    try {
      final fields = [
        _escapeCsvField(log.timestamp),
        _escapeCsvField(log.logLevel.toString()),
        _escapeCsvField(log.className),
        _escapeCsvField(log.methodName),
        _escapeCsvField(log.text),
        _escapeCsvField(log.exception?.toString()),
        _escapeCsvField(log.stacktrace),
        _escapeCsvField(log.data?.toString()),
      ];

      return fields.join(',');
    } catch (e) {
      return '格式化日志失败: $e';
    }
  }

  /// 格式化日志为可读文本
  String formatToText(Log log) {
    try {
      final buffer = StringBuffer();

      // 时间戳
      buffer.writeln('时间: ${log.timestamp}');

      // 日志级别
      buffer.writeln('级别: ${log.logLevel}');

      // 类名和方法名
      buffer.writeln('位置: ${log.className}.${log.methodName}');

      // 日志内容
      buffer.writeln('内容: ${log.text}');

      // 异常信息
      if (log.exception != null) {
        buffer.writeln('异常: ${log.exception}');
      }

      // 堆栈跟踪
      if (log.stacktrace != null) {
        buffer.writeln('堆栈: ${log.stacktrace}');
      }

      // 附加数据
      if (log.data != null) {
        buffer.writeln('数据: ${log.data}');
      }

      buffer.writeln('---');

      return buffer.toString();
    } catch (e) {
      return '格式化日志失败: $e';
    }
  }

  /// 格式化日志为HTML
  String formatToHtml(Log log) {
    try {
      final levelColor = _getLogLevelColor(log.logLevel);

      return '''
        <div class="log-entry" style="margin-bottom: 10px; padding: 10px; border-left: 3px solid $levelColor; background-color: #f5f5f5;">
          <div class="log-header" style="font-weight: bold; color: $levelColor;">
            [${log.logLevel}] ${log.timestamp}
          </div>
          <div class="log-location" style="font-size: 0.9em; color: #666;">
            ${log.className}.${log.methodName}
          </div>
          <div class="log-content" style="margin-top: 5px;">
            ${log.text}
          </div>
          ${log.exception != null ? '<div class="log-exception" style="color: red; margin-top: 5px;">异常: ${log.exception}</div>' : ''}
          ${log.stacktrace != null ? '<div class="log-stacktrace" style="color: #666; font-size: 0.8em; margin-top: 5px;">堆栈: ${log.stacktrace}</div>' : ''}
          ${log.data != null ? '<div class="log-data" style="color: #333; margin-top: 5px;">数据: ${log.data}</div>' : ''}
        </div>
      ''';
    } catch (e) {
      return '<div style="color: red;">格式化日志失败: $e</div>';
    }
  }

  /// 格式化日志列表为指定格式
  String formatLogs(List<Log> logs, LogExportFormat format) {
    try {
      switch (format) {
        case LogExportFormat.json:
          return _formatLogsToJson(logs);
        case LogExportFormat.csv:
          return _formatLogsToCsv(logs);
        case LogExportFormat.text:
          return _formatLogsToText(logs);
        case LogExportFormat.html:
          return _formatLogsToHtml(logs);
      }
    } catch (e) {
      return '格式化日志列表失败: $e';
    }
  }

  /// 格式化日志列表为JSON
  String _formatLogsToJson(List<Log> logs) {
    final logList =
        logs
            .map(
              (log) => {
                'timestamp': log.timestamp,
                'logLevel': log.logLevel.toString(),
                'className': log.className,
                'methodName': log.methodName,
                'text': log.text,
                'exception': log.exception?.toString(),
                'stacktrace': log.stacktrace,
                'data': log.data,
              },
            )
            .toList();

    return jsonEncode({
      'logs': logList,
      'count': logs.length,
      'exportTime': DateTime.now().toIso8601String(),
    });
  }

  /// 格式化日志列表为CSV
  String _formatLogsToCsv(List<Log> logs) {
    final buffer = StringBuffer();

    // CSV头部
    buffer.writeln('时间戳,日志级别,类名,方法名,内容,异常,堆栈跟踪,数据');

    // CSV数据行
    for (final log in logs) {
      buffer.writeln(formatToCsv(log));
    }

    return buffer.toString();
  }

  /// 格式化日志列表为文本
  String _formatLogsToText(List<Log> logs) {
    final buffer = StringBuffer();

    buffer.writeln('=== 日志导出 ===');
    buffer.writeln('导出时间: ${DateTime.now()}');
    buffer.writeln('日志数量: ${logs.length}');
    buffer.writeln('');

    for (final log in logs) {
      buffer.writeln(formatToText(log));
    }

    return buffer.toString();
  }

  /// 格式化日志列表为HTML
  String _formatLogsToHtml(List<Log> logs) {
    final buffer = StringBuffer();

    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html><head><title>日志导出</title></head><body>');
    buffer.writeln('<h1>日志导出</h1>');
    buffer.writeln('<p>导出时间: ${DateTime.now()}</p>');
    buffer.writeln('<p>日志数量: ${logs.length}</p>');
    buffer.writeln('<hr>');

    for (final log in logs) {
      buffer.writeln(formatToHtml(log));
    }

    buffer.writeln('</body></html>');
    return buffer.toString();
  }

  /// 转义CSV字段
  String _escapeCsvField(String? field) {
    if (field == null) return '';

    // 如果包含逗号、引号或换行符，需要用引号包围并转义内部引号
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }

    return field;
  }

  /// 获取日志级别对应的颜色
  String _getLogLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '#666666';
      case LogLevel.info:
        return '#2196F3';
      case LogLevel.warning:
        return '#FF9800';
      case LogLevel.error:
        return '#F44336';
    }
  }

  /// 格式化网络请求日志
  String formatNetworkRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🌐 网络请求');
    buffer.writeln('方法: $method');
    buffer.writeln('URL: $url');

    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('请求头: ${_formatMap(headers)}');
    }

    if (queryParameters != null && queryParameters.isNotEmpty) {
      buffer.writeln('查询参数: ${_formatMap(queryParameters)}');
    }

    if (data != null) {
      buffer.writeln('请求数据: $data');
    }

    return buffer.toString();
  }

  /// 格式化网络响应日志
  String formatNetworkResponse({
    required int statusCode,
    required String url,
    Map<String, dynamic>? headers,
    dynamic data,
    Duration? duration,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('📡 网络响应');
    buffer.writeln('状态码: $statusCode');
    buffer.writeln('URL: $url');

    if (duration != null) {
      buffer.writeln('耗时: ${duration.inMilliseconds}ms');
    }

    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('响应头: ${_formatMap(headers)}');
    }

    if (data != null) {
      buffer.writeln('响应数据: $data');
    }

    return buffer.toString();
  }

  /// 格式化文件操作日志
  String formatFileOperation({
    required String operation,
    required String filePath,
    int? fileSize,
    Duration? duration,
    bool? success,
    String? error,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('📁 文件操作');
    buffer.writeln('操作: $operation');
    buffer.writeln('文件路径: $filePath');

    if (fileSize != null) {
      buffer.writeln('文件大小: ${_formatFileSize(fileSize)}');
    }

    if (duration != null) {
      buffer.writeln('耗时: ${duration.inMilliseconds}ms');
    }

    if (success != null) {
      buffer.writeln('结果: ${success ? '成功' : '失败'}');
    }

    if (error != null) {
      buffer.writeln('错误: $error');
    }

    return buffer.toString();
  }

  /// 格式化性能日志
  String formatPerformance({
    required String operation,
    required Duration duration,
    Map<String, dynamic>? metrics,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('⚡ 性能监控');
    buffer.writeln('操作: $operation');
    buffer.writeln('耗时: ${duration.inMilliseconds}ms');

    if (metrics != null && metrics.isNotEmpty) {
      buffer.writeln('指标: ${_formatMap(metrics)}');
    }

    return buffer.toString();
  }

  /// 格式化Map为可读字符串
  String _formatMap(Map<String, dynamic> map) {
    try {
      return jsonEncode(map);
    } catch (e) {
      return map.toString();
    }
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
