import 'package:flutter/foundation.dart';
import 'log_category.dart';

/// 日志配置类
/// 管理日志系统的各种配置选项
class LogConfig {
  static final LogConfig _instance = LogConfig._internal();
  factory LogConfig() => _instance;
  LogConfig._internal();

  /// 是否启用日志记录
  bool get isLoggingEnabled => kDebugMode || _forceEnableLogging;

  /// 强制启用日志记录（用于生产环境调试）
  bool _forceEnableLogging = false;

  /// 是否启用文件日志
  bool get isFileLoggingEnabled => true;

  /// 是否启用控制台日志
  bool get isConsoleLoggingEnabled => kDebugMode;

  /// 是否启用数据库日志
  bool get isDatabaseLoggingEnabled => true;

  /// 日志保留天数
  int get logRetentionDays => kDebugMode ? 30 : 7;

  /// 最大日志文件大小（MB）
  int get maxLogFileSizeMB => 10;

  /// 最大日志记录数
  int get maxLogRecords => kDebugMode ? 10000 : 5000;

  /// 日志级别配置
  Map<LogCategory, LogLevel> get categoryLogLevels => {
    LogCategory.network: kDebugMode ? LogLevel.debug : LogLevel.warning,
    LogCategory.fileOperation: kDebugMode ? LogLevel.debug : LogLevel.info,
    LogCategory.userAction: kDebugMode ? LogLevel.debug : LogLevel.info,
    LogCategory.error: LogLevel.error,
    LogCategory.performance: kDebugMode ? LogLevel.debug : LogLevel.warning,
    LogCategory.cloudDrive: kDebugMode ? LogLevel.debug : LogLevel.info,
    LogCategory.database: kDebugMode ? LogLevel.debug : LogLevel.warning,
    LogCategory.cache: kDebugMode ? LogLevel.debug : LogLevel.warning,
    LogCategory.auth: kDebugMode ? LogLevel.debug : LogLevel.warning,
    LogCategory.system: kDebugMode ? LogLevel.debug : LogLevel.info,
    LogCategory.debug: LogLevel.debug,
    LogCategory.info: LogLevel.info,
    LogCategory.warning: LogLevel.warning,
  };

  /// 是否启用敏感信息过滤
  bool get isSensitiveDataFilteringEnabled => !kDebugMode;

  /// 敏感信息关键词列表
  List<String> get sensitiveKeywords => [
    'password',
    'token',
    'key',
    'secret',
    'auth',
    'credential',
    'cookie',
    'session',
  ];

  /// 是否启用性能监控日志
  bool get isPerformanceLoggingEnabled => kDebugMode;

  /// 是否启用网络请求日志
  bool get isNetworkLoggingEnabled => kDebugMode;

  /// 是否启用用户行为日志
  bool get isUserActionLoggingEnabled => true;

  /// 日志导出格式
  LogExportFormat get exportFormat => LogExportFormat.json;

  /// 是否启用日志压缩
  bool get isLogCompressionEnabled => true;

  /// 设置强制启用日志记录
  void setForceEnableLogging(bool enable) {
    _forceEnableLogging = enable;
  }

  /// 获取指定分类的日志级别
  LogLevel getLogLevelForCategory(LogCategory category) {
    return categoryLogLevels[category] ?? LogLevel.info;
  }

  /// 检查是否应该记录指定级别的日志
  bool shouldLog(LogCategory category, LogLevel level) {
    if (!isLoggingEnabled) return false;

    final categoryLevel = getLogLevelForCategory(category);
    return level.level >= categoryLevel.level;
  }

  /// 过滤敏感信息
  String filterSensitiveData(String message) {
    if (!isSensitiveDataFilteringEnabled) return message;

    String filteredMessage = message;
    for (final keyword in sensitiveKeywords) {
      final regex = RegExp('$keyword[^\\s]*', caseSensitive: false);
      filteredMessage = filteredMessage.replaceAll(regex, '***');
    }
    return filteredMessage;
  }
}

/// 日志级别枚举
enum LogLevel {
  debug(0, 'DEBUG'),
  info(1, 'INFO'),
  warning(2, 'WARNING'),
  error(3, 'ERROR');

  const LogLevel(this.level, this.name);

  final int level;
  final String name;

  @override
  String toString() => name;
}

/// 日志导出格式枚举
enum LogExportFormat {
  json('JSON'),
  csv('CSV'),
  text('TXT'),
  html('HTML');

  const LogExportFormat(this.name);

  final String name;

  @override
  String toString() => name;
}
