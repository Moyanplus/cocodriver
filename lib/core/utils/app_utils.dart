import 'package:intl/intl.dart';

/// 应用工具类
/// 统一管理所有工具方法，包括日期、字符串、验证等
class AppUtils {
  // ==================== 日期工具 ====================
  /// 日期格式化器
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

  // ==================== 字符串工具 ====================
  /// 判断字符串是否为空
  static bool isEmpty(String? str) {
    return str == null || str.isEmpty;
  }

  /// 判断字符串是否不为空
  static bool isNotEmpty(String? str) {
    return !isEmpty(str);
  }

  /// 判断字符串是否为空白
  static bool isBlank(String? str) {
    return str == null || str.trim().isEmpty;
  }

  /// 判断字符串是否不为空白
  static bool isNotBlank(String? str) {
    return !isBlank(str);
  }

  /// 安全获取字符串，如果为空则返回默认值
  static String safeString(String? str, {String defaultValue = ''}) {
    return isEmpty(str) ? defaultValue : str!;
  }

  /// 截取字符串
  static String truncate(String str, int maxLength, {String suffix = '...'}) {
    if (str.length <= maxLength) {
      return str;
    }
    return '${str.substring(0, maxLength)}$suffix';
  }

  /// 首字母大写
  static String capitalize(String str) {
    if (isEmpty(str)) return str;
    return '${str[0].toUpperCase()}${str.substring(1)}';
  }

  /// 驼峰命名转下划线命名
  static String camelToSnake(String str) {
    return str.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }

  /// 下划线命名转驼峰命名
  static String snakeToCamel(String str) {
    return str.split('_').map((word) => capitalize(word)).join('');
  }

  /// 移除字符串中的特殊字符
  static String removeSpecialChars(String str) {
    return str.replaceAll(RegExp(r'[^\w\s]'), '');
  }

  // ==================== 验证工具 ====================
  /// 验证邮箱格式
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// 验证手机号格式
  static bool isValidPhone(String phone) {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
  }

  /// 验证身份证号格式
  static bool isValidIdCard(String idCard) {
    return RegExp(r'^\d{17}[\dXx]$').hasMatch(idCard);
  }

  /// 验证URL格式
  static bool isValidUrl(String url) {
    return RegExp(
      r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$',
    ).hasMatch(url);
  }

  // ==================== 数字工具 ====================
  /// 格式化数字，添加千分位分隔符
  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  /// 格式化货币
  static String formatCurrency(double amount, {String symbol = '¥'}) {
    return '$symbol${NumberFormat('#,###.00').format(amount)}';
  }

  /// 格式化百分比
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  // ==================== 文件工具 ====================
  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 获取文件扩展名
  static String getFileExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return '';
    return fileName.substring(lastDot + 1).toLowerCase();
  }

  /// 判断是否为图片文件
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// 判断是否为视频文件
  static bool isVideoFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv'].contains(extension);
  }
}
