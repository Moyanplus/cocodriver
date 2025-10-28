import 'dart:async';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'log_category.dart';
import 'log_config.dart';

/// 统一的日志管理器
/// 提供应用级别的日志记录功能
class LogManager {
  static final LogManager _instance = LogManager._internal();
  factory LogManager() => _instance;
  LogManager._internal();

  final LogConfig _config = LogConfig();
  bool _isInitialized = false;
  late Logger _logger;
  late File _logFile;

  /// 初始化日志系统
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 创建日志文件
      final directory = await getApplicationDocumentsDirectory();
      final logDirectory = Directory('${directory.path}/logs');
      if (!await logDirectory.exists()) {
        await logDirectory.create(recursive: true);
      }

      _logFile = File('${logDirectory.path}/app_logs.txt');

      // 配置Logger
      // iOS 上禁用颜色，避免 ANSI 控制符显示混乱
      final useColors = !Platform.isIOS;

      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: useColors,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
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
        filteredMessage,
        category,
        data,
        exception,
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
  String _buildLogMessage(
    String message,
    LogCategory category,
    Map<String, dynamic>? data,
    dynamic exception,
  ) {
    final buffer = StringBuffer();
    buffer.write('[${category.displayName}] $message');

    if (data != null && data.isNotEmpty) {
      buffer.write('\n数据: ${data.toString()}');
    }

    if (exception != null) {
      buffer.write('\n异常: $exception');
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
      final timestamp = DateTime.now().toIso8601String();
      final logEntry =
          '[$timestamp] [${level.name}] [${category.displayName}] $message\n';
      await _logFile.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      if (kDebugMode) {
        print('LogManager: 保存日志到文件失败: $e');
      }
    }
  }

  /// 获取所有日志
  Future<List<String>> getAllLogs() async {
    try {
      if (await _logFile.exists()) {
        final content = await _logFile.readAsString();
        return content.split('\n').where((line) => line.isNotEmpty).toList();
      }
      return [];
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
      final directory = await getApplicationDocumentsDirectory();
      final exportFile = File(
        '${directory.path}/logs_export_${DateTime.now().millisecondsSinceEpoch}.txt',
      );

      if (await _logFile.exists()) {
        await _logFile.copy(exportFile.path);
        return exportFile.path;
      }
      return null;
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
      if (await _logFile.exists()) {
        await _logFile.delete();
        await _logFile.create();
      }
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
