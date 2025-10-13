import 'package:intl/intl.dart';

/// 日期工具类
class DateUtils {
  // 日期格式化器
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _fullFormat = DateFormat('yyyy年MM月dd日 HH:mm');

  /// 格式化日期
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// 格式化时间
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// 格式化日期时间
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// 格式化完整日期时间
  static String formatFullDateTime(DateTime date) {
    return _fullFormat.format(date);
  }

  /// 获取相对时间描述
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 判断是否为今天
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 判断是否为昨天
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}
