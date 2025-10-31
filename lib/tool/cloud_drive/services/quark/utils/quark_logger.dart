import '../../../../../core/logging/log_manager.dart';

/// 夸克云盘日志工具类
///
/// 提供统一、简洁的日志输出格式。
class QuarkLogger {
  static const String _tag = 'Quark';

  /// 是否启用详细日志（调试模式）
  static bool enableVerbose = false;

  /// 操作开始
  static void operationStart(String operation, {Map<String, dynamic>? params}) {
    final paramsStr =
        params != null && params.isNotEmpty ? ' ${_formatParams(params)}' : '';
    LogManager().cloudDrive('[$_tag] $operation$paramsStr');
  }

  /// 成功日志
  static void success(String message) {
    LogManager().cloudDrive('[$_tag] ✓ $message');
  }

  /// 错误日志
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    LogManager().cloudDrive('[$_tag] ✗ $message');
    if (error != null) {
      LogManager().error('[$_tag] 错误: $error');
    }
    if (stackTrace != null && enableVerbose) {
      LogManager().error('[$_tag] 堆栈:\n$stackTrace');
    }
  }

  /// 警告日志
  static void warning(String message) {
    LogManager().cloudDrive('[$_tag] ⚠ $message');
  }

  /// 普通信息（仅在详细模式下输出）
  static void info(String message) {
    if (enableVerbose) {
      LogManager().cloudDrive('[$_tag] $message');
    }
  }

  /// 网络请求（简化）
  static void network(String method, {String? url}) {
    if (enableVerbose) {
      final urlShort = url != null ? _shortenUrl(url) : '';
      LogManager().cloudDrive('[$_tag] $method $urlShort');
    }
  }

  /// 调试日志（仅在详细模式下输出）
  static void debug(String message, {dynamic data}) {
    if (enableVerbose) {
      LogManager().cloudDrive('[$_tag] DEBUG: $message');
      if (data != null) {
        LogManager().cloudDrive('  └─ $data');
      }
    }
  }

  /// 性能日志
  static void performance(String message, {Duration? duration}) {
    if (duration != null && duration.inMilliseconds > 100) {
      // 只记录超过100ms的操作
      LogManager().cloudDrive(
        '[$_tag] ⚡ $message (${duration.inMilliseconds}ms)',
      );
    }
  }

  /// 认证日志（简化）
  static void auth(String message) {
    if (enableVerbose) {
      LogManager().cloudDrive('[$_tag] 🔑 $message');
    }
  }

  /// 任务相关（简化）
  static void task(String message, {String? taskId}) {
    if (enableVerbose && taskId != null) {
      LogManager().cloudDrive(
        '[$_tag] 任务 ${taskId.substring(0, 8)}... $message',
      );
    }
  }

  /// 缓存相关（仅在详细模式）
  static void cache(String message, {String? key}) {
    if (enableVerbose) {
      LogManager().cloudDrive('[$_tag] 缓存: $message');
    }
  }

  /// 分享日志
  static void share(String message, {String? url}) {
    LogManager().cloudDrive('[$_tag] 分享: $message');
    if (url != null && enableVerbose) {
      LogManager().cloudDrive('  └─ $url');
    }
  }

  /// 下载日志
  static void download(String message, {String? fileName, int? size}) {
    final info = fileName != null ? ' ($fileName)' : '';
    LogManager().cloudDrive('[$_tag] 下载$info: $message');
  }

  /// QR登录日志
  static void qrLogin(String message, {String? status}) {
    final statusInfo = status != null ? ' [$status]' : '';
    LogManager().cloudDrive('[$_tag] QR登录$statusInfo: $message');
  }

  /// 文件操作（简化）
  static void file(String message, {String? fileName}) {
    info(fileName != null ? '$message: $fileName' : message);
  }

  /// 文件夹操作（简化）
  static void folder(String message, {String? folderName}) {
    info(folderName != null ? '$message: $folderName' : message);
  }

  /// 操作结束（简化）
  static void operationEnd(
    String operation, {
    Duration? duration,
    dynamic result,
  }) {
    if (enableVerbose) {
      final durationInfo =
          duration != null ? ' (${duration.inMilliseconds}ms)' : '';
      LogManager().cloudDrive('[$_tag] 完成: $operation$durationInfo');
    }
  }

  /// 格式化参数（简化）
  static String _formatParams(Map<String, dynamic> params) {
    final entries = params.entries
        .take(3)
        .map((e) {
          var value = e.value;
          if (value is String && value.length > 30) {
            value = '${value.substring(0, 27)}...';
          }
          return '${e.key}=$value';
        })
        .join(', ');

    return params.length > 3 ? '($entries...)' : '($entries)';
  }

  /// 缩短URL（只保留关键部分）
  static String _shortenUrl(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.split('/').last;
    return path.isNotEmpty ? path : uri.host;
  }
}
