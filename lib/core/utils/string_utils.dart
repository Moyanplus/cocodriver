/// 字符串工具类
class StringUtils {
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

  /// 验证邮箱格式
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// 验证手机号格式
  static bool isValidPhone(String phone) {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
  }
}
