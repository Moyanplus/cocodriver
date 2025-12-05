import 'dart:convert';
import 'dart:math';

/// 百度登录相关的通用工具。
class BaiduLoginUtils {
  /// 生成与前端 JS 相同格式的 gid（8-4-4-4-12）。
  static String generateGid() {
    const chars = '0123456789ABCDEF';
    final rand = Random();
    final buffer = StringBuffer();
    for (int i = 0; i < 36; i++) {
      if (i == 8 || i == 13 || i == 18 || i == 23) {
        buffer.write('-');
        continue;
      }
      buffer.write(chars[rand.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  /// 合并 set-cookie，保留第一段键值对。
  static String mergeSetCookie(List<String> cookies) {
    final cleaned = <String>[];
    for (final c in cookies) {
      final parts = c.split(';');
      if (parts.isNotEmpty) {
        cleaned.add(parts.first.trim());
      }
    }
    return cleaned.join('; ');
  }

  /// 解析 JSONP（去掉回调包装）。
  static Map<String, dynamic> parseJsonp(String source) {
    try {
      final start = source.indexOf('(');
      final end = source.lastIndexOf(')');
      final jsonStr =
          (start != -1 && end != -1 && end > start + 1)
              ? source.substring(start + 1, end)
              : source;
      final map = jsonDecode(jsonStr);
      if (map is Map<String, dynamic>) return map;
    } catch (_) {}
    return <String, dynamic>{};
  }
}
