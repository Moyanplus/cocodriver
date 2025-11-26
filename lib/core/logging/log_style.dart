import 'log_category.dart';
import 'log_config.dart';

/// Provides ANSI color helpers so console logs can highlight level/category
/// information without affecting persisted log files (they are stripped later).
class LogStyle {
  static const _reset = '\x1B[0m';
  static const _bold = '\x1B[1m';
  static const _dim = '\x1B[90m';

  static const Map<LogLevel, String> _levelColors = {
    LogLevel.debug: '\x1B[36m', // Cyan
    LogLevel.info: '\x1B[32m', // Green
    LogLevel.warning: '\x1B[33m', // Yellow
    LogLevel.error: '\x1B[31m', // Red
  };

  static const Map<LogCategory, String> _categoryColors = {
    LogCategory.network: '\x1B[36m',
    LogCategory.fileOperation: '\x1B[35m',
    LogCategory.userAction: '\x1B[34m',
    LogCategory.error: '\x1B[31m',
    LogCategory.performance: '\x1B[33m',
    LogCategory.cloudDrive: '\x1B[94m',
    LogCategory.database: '\x1B[38;5;135m',
    LogCategory.cache: '\x1B[38;5;172m',
    LogCategory.auth: '\x1B[95m',
    LogCategory.system: '\x1B[37m',
    LogCategory.debug: '\x1B[36m',
    LogCategory.info: '\x1B[32m',
    LogCategory.warning: '\x1B[33m',
  };

  static const Map<LogCategory, String> _categoryIcons = {
    LogCategory.network: 'NET',
    LogCategory.fileOperation: 'FILE',
    LogCategory.userAction: 'USER',
    LogCategory.error: 'ERR',
    LogCategory.performance: 'PERF',
    LogCategory.cloudDrive: 'CLOUD',
    LogCategory.database: 'DB',
    LogCategory.cache: 'CACHE',
    LogCategory.auth: 'AUTH',
    LogCategory.system: 'SYS',
    LogCategory.debug: 'DBG',
    LogCategory.info: 'INFO',
    LogCategory.warning: 'WARN',
  };

  static String formatLevel(LogLevel level) {
    final color = _levelColors[level] ?? _dim;
    final padded = level.name.padRight(7);
    return '$color[$padded]$_reset';
  }

  static String formatCategory(LogCategory category) {
    final color = _categoryColors[category] ?? _dim;
    final icon = _categoryIcons[category];
    final label =
        icon == null ? category.displayName : '$icon ${category.displayName}';
    return '$color[$label]$_reset';
  }

  static String? formatScope(String? className, String? methodName) {
    String? resolved;
    if (className != null && methodName != null) {
      resolved = '$className.$methodName';
    } else if (className != null) {
      resolved = className;
    } else if (methodName != null) {
      resolved = methodName;
    }
    if (resolved == null || resolved.isEmpty) return null;
    return '${_bold}($resolved)$_reset';
  }

  static String dim(String text) => '$_dim$text$_reset';

  static String emphasizeError(String text) =>
      '${_levelColors[LogLevel.error]}$text$_reset';

  static String emphasizeWarning(String text) =>
      '${_levelColors[LogLevel.warning]}$text$_reset';

  static String formatTimestamp(DateTime time) {
    final formatted =
        '${time.month.toString().padLeft(2, '0')}-'
        '${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
    return dim('[$formatted]');
  }
}
