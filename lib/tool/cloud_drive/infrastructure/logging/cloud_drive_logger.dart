import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';

/// 云盘日志服务
///
/// 提供云盘相关的日志记录功能，包括日志配置、日志级别管理等。

/// 云盘日志级别
enum CloudDriveLogLevel {
  /// 调试信息
  debug,

  /// 一般信息
  info,

  /// 警告信息
  warning,

  /// 错误信息
  error,
}

/// 云盘日志配置类
class CloudDriveLogConfig {
  final bool enableLogging;
  final CloudDriveLogLevel minLevel;
  final bool enablePerformanceLogging;
  final bool enableRequestLogging;
  final bool enableResponseLogging;
  final bool enableErrorLogging;
  final bool enableCacheLogging;
  final int maxLogEntries;

  const CloudDriveLogConfig({
    this.enableLogging = true,
    this.minLevel = CloudDriveLogLevel.info,
    this.enablePerformanceLogging = false,
    this.enableRequestLogging = true,
    this.enableResponseLogging = true,
    this.enableErrorLogging = true,
    this.enableCacheLogging = false,
    this.maxLogEntries = 500,
  });

  /// 默认配置
  static const CloudDriveLogConfig defaultConfig = CloudDriveLogConfig();

  /// 调试配置
  static const CloudDriveLogConfig debugConfig = CloudDriveLogConfig(
    enableLogging: true,
    minLevel: CloudDriveLogLevel.debug,
    enablePerformanceLogging: true,
    enableRequestLogging: true,
    enableResponseLogging: true,
    enableErrorLogging: true,
    enableCacheLogging: true,
    maxLogEntries: 1000,
  );

  /// 生产配置
  static const CloudDriveLogConfig productionConfig = CloudDriveLogConfig(
    enableLogging: true,
    minLevel: CloudDriveLogLevel.warning,
    enablePerformanceLogging: false,
    enableRequestLogging: false,
    enableResponseLogging: false,
    enableErrorLogging: true,
    enableCacheLogging: false,
    maxLogEntries: 100,
  );
}

/// 云盘日志条目类
class CloudDriveLogEntry {
  final DateTime timestamp;
  final CloudDriveLogLevel level;
  final String message;
  final CloudDriveType? cloudDriveType;
  final String? operation;
  final Map<String, dynamic>? data;
  final String? error;
  final Duration? duration;

  const CloudDriveLogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.cloudDriveType,
    this.operation,
    this.data,
    this.error,
    this.duration,
  });

  @override
  String toString() {
    final timeStr = timestamp.toIso8601String();
    final levelStr = level.name.toUpperCase();
    final typeStr = cloudDriveType?.displayName ?? '未知';
    final operationStr = operation ?? '未知';
    final durationStr =
        duration != null ? ' (${duration!.inMilliseconds}ms)' : '';

    return '[$timeStr] $levelStr [$typeStr] $operationStr: $message$durationStr';
  }
}

/// 云盘日志记录器
class CloudDriveLogger {
  static CloudDriveLogConfig _config = CloudDriveLogConfig.defaultConfig;
  static final List<CloudDriveLogEntry> _logEntries = [];

  /// 设置日志配置
  static void setConfig(CloudDriveLogConfig config) {
    _config = config;
    LogManager().cloudDrive('设置日志配置: ${config.minLevel.name}');
  }

  /// 获取日志配置
  static CloudDriveLogConfig get config => _config;

  /// 获取日志条目
  static List<CloudDriveLogEntry> get logEntries =>
      List.unmodifiable(_logEntries);

  /// 清空日志
  static void clearLogs() {
    _logEntries.clear();
    LogManager().cloudDrive('🧹 清空日志');
  }

  /// 导出日志
  static String exportLogs() =>
      _logEntries.map((entry) => entry.toString()).join('\n');

  /// 记录操作日志 - 简化版本
  static void logOperation(
    String operation,
    CloudDriveType cloudDriveType, {
    Map<String, dynamic>? params,
    CloudDriveLogLevel level = CloudDriveLogLevel.info,
  }) {
    if (!_shouldLog(level)) return;

    final emoji = _getEmojiForLevel(level);
    final message = '$emoji $operation - ${cloudDriveType.displayName}';

    LogManager().cloudDrive(message);

    if (params != null && level == CloudDriveLogLevel.debug) {
      for (final entry in params.entries) {
        LogManager().cloudDrive('${entry.key}: ${entry.value}');
      }
    }

    _addLogEntry(
      CloudDriveLogEntry(
        timestamp: DateTime.now(),
        level: level,
        message: operation,
        cloudDriveType: cloudDriveType,
        operation: operation,
        data: params,
      ),
    );
  }

  /// 记录错误日志 - 简化版本
  static void logError(
    String operation,
    CloudDriveType cloudDriveType,
    dynamic error, {
    Map<String, dynamic>? context,
  }) {
    if (!_config.enableErrorLogging) return;

    LogManager().error('$operation 失败 - ${cloudDriveType.displayName}: $error');

    if (context != null) {
      for (final entry in context.entries) {
        LogManager().cloudDrive('${entry.key}: ${entry.value}');
      }
    }

    _addLogEntry(
      CloudDriveLogEntry(
        timestamp: DateTime.now(),
        level: CloudDriveLogLevel.error,
        message: '$operation 失败: $error',
        cloudDriveType: cloudDriveType,
        operation: operation,
        data: context,
        error: error.toString(),
      ),
    );
  }

  /// 记录成功日志 - 简化版本
  static void logSuccess(
    String operation,
    CloudDriveType cloudDriveType, {
    String? details,
    Map<String, dynamic>? result,
  }) {
    if (!_shouldLog(CloudDriveLogLevel.info)) return;

    final message =
        '$operation 成功 - ${cloudDriveType.displayName}${details != null ? ': $details' : ''}';
    LogManager().cloudDrive(message);

    if (result != null && _config.minLevel == CloudDriveLogLevel.debug) {
      for (final entry in result.entries) {
        LogManager().cloudDrive('${entry.key}: ${entry.value}');
      }
    }

    _addLogEntry(
      CloudDriveLogEntry(
        timestamp: DateTime.now(),
        level: CloudDriveLogLevel.info,
        message: '$operation 成功${details != null ? ': $details' : ''}',
        cloudDriveType: cloudDriveType,
        operation: operation,
        data: result,
      ),
    );
  }

  /// 记录文件操作日志
  static void logFileOperation(
    String operation,
    CloudDriveType cloudDriveType,
    CloudDriveFile file, {
    Map<String, dynamic>? additionalInfo,
  }) {
    final params = <String, dynamic>{
      '文件ID': file.id,
      '文件名': file.name,
      '文件类型': file.isFolder ? '文件夹' : '文件',
      '文件大小': file.size,
    };

    if (additionalInfo != null) {
      params.addAll(additionalInfo);
    }

    logOperation(operation, cloudDriveType, params: params);
  }

  /// 记录账号操作日志
  static void logAccountOperation(
    String operation,
    CloudDriveType cloudDriveType,
    CloudDriveAccount account, {
    Map<String, dynamic>? additionalInfo,
  }) {
    final params = <String, dynamic>{
      '账号ID': account.id,
      '账号名称': account.name,
      '认证方式': account.type.authType.name,
    };

    if (additionalInfo != null) {
      params.addAll(additionalInfo);
    }

    logOperation(operation, cloudDriveType, params: params);
  }

  /// 记录API请求日志
  static void logApiRequest(
    String operation,
    CloudDriveType cloudDriveType,
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
  }) {
    if (!_config.enableRequestLogging) return;

    final requestInfo = <String, dynamic>{'请求URL': url};

    if (headers != null) {
      requestInfo['请求头'] = headers;
    }

    if (params != null) {
      requestInfo['请求参数'] = params;
    }

    logOperation('API请求: $operation', cloudDriveType, params: requestInfo);
  }

  /// 记录API响应日志
  static void logApiResponse(
    String operation,
    CloudDriveType cloudDriveType,
    int statusCode, {
    Map<String, dynamic>? responseData,
    String? errorMessage,
    Duration? duration,
  }) {
    if (!_config.enableResponseLogging) return;

    final responseInfo = <String, dynamic>{'状态码': statusCode};

    if (responseData != null) {
      responseInfo['响应数据'] = responseData;
    }

    if (errorMessage != null) {
      responseInfo['错误信息'] = errorMessage;
    }

    if (duration != null) {
      responseInfo['响应时间'] = '${duration.inMilliseconds}ms';
    }

    if (errorMessage != null) {
      logError(
        'API响应: $operation',
        cloudDriveType,
        errorMessage,
        context: responseInfo,
      );
    } else {
      logSuccess('API响应: $operation', cloudDriveType, result: responseInfo);
    }
  }

  /// 记录性能日志
  static void logPerformance(
    String operation,
    CloudDriveType cloudDriveType,
    Duration duration, {
    Map<String, dynamic>? additionalInfo,
  }) {
    if (!_config.enablePerformanceLogging) return;

    final params = <String, dynamic>{'耗时': '${duration.inMilliseconds}ms'};

    if (additionalInfo != null) {
      params.addAll(additionalInfo);
    }

    logOperation(
      '性能: $operation',
      cloudDriveType,
      params: params,
      level: CloudDriveLogLevel.debug,
    );

    _addLogEntry(
      CloudDriveLogEntry(
        timestamp: DateTime.now(),
        level: CloudDriveLogLevel.debug,
        message: '性能: $operation',
        cloudDriveType: cloudDriveType,
        operation: operation,
        data: params,
        duration: duration,
      ),
    );
  }

  /// 记录缓存操作日志
  static void logCacheOperation(
    String operation,
    CloudDriveType cloudDriveType, {
    String? cacheKey,
    bool? hit,
    Map<String, dynamic>? additionalInfo,
  }) {
    if (!_config.enableCacheLogging) return;

    final params = <String, dynamic>{
      '缓存键': cacheKey ?? '未知',
      '缓存命中': hit ?? false,
    };

    if (additionalInfo != null) {
      params.addAll(additionalInfo);
    }

    logOperation(
      '缓存: $operation',
      cloudDriveType,
      params: params,
      level: CloudDriveLogLevel.debug,
    );
  }

  /// 记录批量操作日志
  static void logBatchOperation(
    String operation,
    CloudDriveType cloudDriveType,
    int totalCount, {
    int? successCount,
    int? failCount,
    List<String>? errors,
  }) {
    final params = <String, dynamic>{
      '总数': totalCount,
      '成功数': successCount ?? 0,
      '失败数': failCount ?? 0,
    };

    if (errors != null && errors.isNotEmpty) {
      params['错误列表'] = errors;
    }

    logOperation('批量操作: $operation', cloudDriveType, params: params);
  }

  /// 记录调试信息
  static void logDebug(
    String message,
    CloudDriveType cloudDriveType, {
    Map<String, dynamic>? data,
  }) {
    logOperation(
      message,
      cloudDriveType,
      params: data,
      level: CloudDriveLogLevel.debug,
    );
  }

  /// 记录警告信息
  static void logWarning(
    String message,
    CloudDriveType cloudDriveType, {
    Map<String, dynamic>? data,
  }) {
    logOperation(
      message,
      cloudDriveType,
      params: data,
      level: CloudDriveLogLevel.warning,
    );
  }

  /// 检查是否应该记录日志
  static bool _shouldLog(CloudDriveLogLevel level) {
    if (!_config.enableLogging) return false;

    switch (_config.minLevel) {
      case CloudDriveLogLevel.debug:
        return true;
      case CloudDriveLogLevel.info:
        return level != CloudDriveLogLevel.debug;
      case CloudDriveLogLevel.warning:
        return level == CloudDriveLogLevel.warning ||
            level == CloudDriveLogLevel.error;
      case CloudDriveLogLevel.error:
        return level == CloudDriveLogLevel.error;
    }
  }

  /// 添加日志条目
  static void _addLogEntry(CloudDriveLogEntry entry) {
    _logEntries.add(entry);

    // 限制日志条目数量
    if (_logEntries.length > _config.maxLogEntries) {
      _logEntries.removeAt(0);
    }
  }

  /// 获取性能统计
  static Map<String, dynamic> getPerformanceStats() {
    final performanceEntries =
        _logEntries.where((entry) => entry.duration != null).toList();

    if (performanceEntries.isEmpty) {
      return {
        'totalOperations': 0,
        'averageDuration': 0,
        'minDuration': 0,
        'maxDuration': 0,
      };
    }

    final durations =
        performanceEntries.map((e) => e.duration!.inMilliseconds).toList();
    final totalDuration = durations.reduce((a, b) => a + b);

    return {
      'totalOperations': performanceEntries.length,
      'averageDuration': totalDuration / performanceEntries.length,
      'minDuration': durations.reduce((a, b) => a < b ? a : b),
      'maxDuration': durations.reduce((a, b) => a > b ? a : b),
    };
  }

  /// 获取错误统计
  static Map<String, dynamic> getErrorStats() {
    final errorEntries =
        _logEntries
            .where((entry) => entry.level == CloudDriveLogLevel.error)
            .toList();

    final errorCounts = <String, int>{};
    for (final entry in errorEntries) {
      final operation = entry.operation ?? '未知';
      errorCounts[operation] = (errorCounts[operation] ?? 0) + 1;
    }

    return {'totalErrors': errorEntries.length, 'errorCounts': errorCounts};
  }

  /// 获取日志级别的表情符号
  static String _getEmojiForLevel(CloudDriveLogLevel level) {
    switch (level) {
      case CloudDriveLogLevel.debug:
        return 'TRACE';
      case CloudDriveLogLevel.info:
        return 'INFO';
      case CloudDriveLogLevel.warning:
        return 'WARN';
      case CloudDriveLogLevel.error:
        return 'ERROR';
    }
  }
}
