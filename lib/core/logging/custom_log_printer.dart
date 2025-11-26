import 'package:logger/logger.dart';

import 'log_style.dart';

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
    final timestamp = LogStyle.formatTimestamp(DateTime.now());
    final message = event.message;

    // 控制台输出：带颜色的时间戳 + 已格式化的消息（消息内部已包含等级/分类）
    return ['$timestamp $message'];
  }
}
