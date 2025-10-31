import 'package:logger/logger.dart';

/// 自定义日志打印器
/// 格式：[月-日 时:分:秒] [级别] 消息
class CustomLogPrinter extends LogPrinter {
  static final levelEmojis = {
    Level.trace: 'TRACE',
    Level.debug: 'DEBUG',
    Level.info: 'INFO',
    Level.warning: 'WARN',
    Level.error: 'ERROR',
    Level.fatal: 'FATAL',
  };

  static final levelLabels = {
    Level.trace: 'T',
    Level.debug: 'D',
    Level.info: 'I',
    Level.warning: 'W',
    Level.error: 'E',
    Level.fatal: 'F',
  };

  @override
  List<String> log(LogEvent event) {
    final now = DateTime.now();
    final timestamp =
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';

    final level = levelLabels[event.level] ?? 'I';
    final message = event.message;

    // 格式：[月-日 时:分:秒] [级别] 消息
    return ['[$timestamp] [$level] $message'];
  }
}
