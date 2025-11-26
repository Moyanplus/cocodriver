import 'dart:async';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

import 'log_category.dart';
import 'log_config.dart';
import 'log_file_manager.dart';
import 'custom_log_printer.dart';
import 'log_style.dart';

/// 统一的日志管理器
/// 提供应用级别的日志记录功能
class LogManager {
  static final LogManager _instance = LogManager._internal();
  factory LogManager() => _instance;
  LogManager._internal();

  final LogConfig _config = LogConfig();
  final LogFileManager _fileManager = LogFileManager();
  bool _isInitialized = false;
  late Logger _logger;

  /// 初始化日志系统
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 初始化日志文件管理器
      await _fileManager.initialize();

      // 配置Logger - 使用自定义格式
      _logger = Logger(
        printer: CustomLogPrinter(),
        output: _config.isConsoleLoggingEnabled ? ConsoleOutput() : null,
        filter: ProductionFilter(),
      );

      _isInitialized = true;

      if (kDebugMode) {
        print('LogManager: 日志系统初始化成功');
      }
    } catch (e) {
      if (kDebugMode) {
        print('LogManager: 日志系统初始化失败: $e');
      }
    }
  }

  /// 记录调试日志
  void debug(
    String message, {
    LogCategory category = LogCategory.debug,
    String? className,
    String? methodName,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.debug, message, category, className, methodName, data);
  }

  /// 记录信息日志
  void info(
    String message, {
    LogCategory category = LogCategory.info,
    String? className,
    String? methodName,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.info, message, category, className, methodName, data);
  }

  /// 记录警告日志
  void warning(
    String message, {
    LogCategory category = LogCategory.warning,
    String? className,
    String? methodName,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.warning, message, category, className, methodName, data);
  }

  /// 记录错误日志
  void error(
    String message, {
    LogCategory category = LogCategory.error,
    String? className,
    String? methodName,
    Map<String, dynamic>? data,
    dynamic exception,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      category,
      className,
      methodName,
      data,
      exception,
      stackTrace,
    );
  }

  /// 记录网络日志
  void network(
    String message, {
    String? className,
    String? methodName,
    Map<String, dynamic>? data,
  }) {
    _log(
      LogLevel.info,
      message,
      LogCategory.network,
      className,
      methodName,
      data,
    );
  }

  /// 记录文件操作日志
  void fileOperation(
    String message, {
    String? className,
    String? methodName,
    Map<String, dynamic>? data,
  }) {
    _log(
      LogLevel.info,
      message,
      LogCategory.fileOperation,
      className,
      methodName,
      data,
    );
  }

  /// 记录用户行为日志
  void userAction(
    String message, {
    String? className,
    String? methodName,
    Map<String, dynamic>? data,
  }) {
    _log(
      LogLevel.info,
      message,
      LogCategory.userAction,
      className,
      methodName,
      data,
    );
  }

  /// 记录云盘服务日志
  void cloudDrive(
    String message, {
    String? className,
    String? methodName,
    Map<String, dynamic>? data,
  }) {
    _log(
      LogLevel.info,
      message,
      LogCategory.cloudDrive,
      className,
      methodName,
      data,
    );
  }

  /// 记录性能日志
  void performance(
    String message, {
    String? className,
    String? methodName,
    Map<String, dynamic>? data,
  }) {
    _log(
      LogLevel.debug,
      message,
      LogCategory.performance,
      className,
      methodName,
      data,
    );
  }

  /// 内部日志记录方法
  void _log(
    LogLevel level,
    String message,
    LogCategory category,
    String? className,
    String? methodName,
    Map<String, dynamic>? data, [
    dynamic exception,
    StackTrace? stackTrace,
  ]) {
    if (!_config.shouldLog(category, level)) return;

    try {
      // 过滤敏感信息
      final filteredMessage = _config.filterSensitiveData(message);

      // 构建完整的日志消息
      final fullMessage = _buildLogMessage(
        level: level,
        message: filteredMessage,
        category: category,
        className: className,
        methodName: methodName,
        data: data,
        exception: exception,
      );

      // 记录到Logger和文件
      switch (level) {
        case LogLevel.debug:
          _logger.d(fullMessage);
          break;
        case LogLevel.info:
          _logger.i(fullMessage);
          break;
        case LogLevel.warning:
          _logger.w(fullMessage);
          break;
        case LogLevel.error:
          _logger.e(fullMessage, error: exception, stackTrace: stackTrace);
          break;
      }

      // 保存到文件
      if (_config.isFileLoggingEnabled) {
        _saveToFile(fullMessage, level, category);
      }
    } catch (e) {
      if (kDebugMode) {
        print('LogManager: 记录日志失败: $e');
      }
    }
  }

  /// 构建完整的日志消息
  String _buildLogMessage({
    required LogLevel level,
    required String message,
    required LogCategory category,
    String? className,
    String? methodName,
    Map<String, dynamic>? data,
    dynamic exception,
  }) {
    final buffer = StringBuffer();
    buffer
      ..write(LogStyle.formatLevel(level))
      ..write(' ')
      ..write(LogStyle.formatCategory(category))
      ..write(' ')
      ..write(message);

    final scope = LogStyle.formatScope(className, methodName);
    if (scope != null) {
      buffer
        ..write(' ')
        ..write(LogStyle.dim(scope));
    }

    if (data != null && data.isNotEmpty) {
      buffer
        ..write('\n')
        ..write(LogStyle.dim('数据: ${data.toString()}'));
    }

    if (exception != null) {
      buffer
        ..write('\n')
        ..write(LogStyle.emphasizeError('异常: $exception'));
    }

    return buffer.toString();
  }

  /// 保存日志到文件
  Future<void> _saveToFile(
    String message,
    LogLevel level,
    LogCategory category,
  ) async {
    try {
      // 格式化时间为：月-日 时:分:秒
      final now = DateTime.now();
      final timestamp =
          '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      // 移除 emoji 和特殊字符，确保纯文本
      final cleanMessage = _cleanMessage(message);

      // 优化后的日志格式：[月-日 时:分:秒] [分类] 消息
      final logEntry = '[$timestamp] [${category.displayName}] $cleanMessage\n';

      // 使用 LogFileManager 写入
      await _fileManager.writeLog(logEntry);
    } catch (e) {
      if (kDebugMode) {
        print('LogManager: 保存日志到文件失败: $e');
      }
    }
  }

  /// 清理消息中的特殊字符
  String _cleanMessage(String message) {
    // 移除 ANSI 控制符
    final ansiPattern = RegExp(r'\x1B\[[0-9;]*[a-zA-Z]');
    var cleaned = message.replaceAll(ansiPattern, '');

    // 移除 emoji 但保留中文字符
    // 只移除 emoji 表情符号，保留所有文本内容
    cleaned = cleaned.replaceAll(
      RegExp(
        r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|'
        r'[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|'
        r'[\u{1F900}-\u{1F9FF}]|[\u{1FA70}-\u{1FAFF}]',
        unicode: true,
      ),
      '',
    );

    return cleaned.trim();
  }

  /// 获取所有日志
  Future<List<String>> getAllLogs() async {
    try {
      // 使用 LogFileManager 获取所有日志
      final content = await _fileManager.getAllLogs();
      if (content.isEmpty) return [];

      return content.split('\n').where((line) => line.isNotEmpty).toList();
    } catch (e) {
      if (kDebugMode) {
        print('LogManager: 获取日志失败: $e');
      }
      return [];
    }
  }

  /// 根据分类获取日志
  Future<List<String>> getLogsByCategory(LogCategory category) async {
    try {
      final allLogs = await getAllLogs();
      return allLogs
          .where((log) => log.contains('[${category.displayName}]'))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('LogManager: 根据分类获取日志失败: $e');
      }
      return [];
    }
  }

  /// 导出日志
  Future<String?> exportLogs() async {
    try {
      // 使用 LogFileManager 导出
      return await _fileManager.exportLogs();
    } catch (e) {
      if (kDebugMode) {
        print('LogManager: 导出日志失败: $e');
      }
      return null;
    }
  }

  /// 清理日志
  Future<void> clearLogs() async {
    try {
      // 使用 LogFileManager 清理
      await _fileManager.clearAllLogs();

      if (kDebugMode) {
        print('LogManager: 日志清理完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('LogManager: 清理日志失败: $e');
      }
    }
  }

  /// 获取日志统计信息
  Future<Map<String, int>> getLogStatistics() async {
    try {
      final allLogs = await getAllLogs();
      final stats = <String, int>{};

      for (final category in LogCategory.values) {
        final count =
            allLogs
                .where((log) => log.contains('[${category.displayName}]'))
                .length;
        stats[category.displayName] = count;
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('LogManager: 获取日志统计失败: $e');
      }
      return {};
    }
  }

  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;
}
