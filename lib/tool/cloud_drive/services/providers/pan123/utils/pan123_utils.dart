/// 123云盘通用工具方法，避免把解析逻辑放在配置类中。
class Pan123Utils {
  /// 文件大小单位表
  static const Map<String, int> _sizeUnits = {
    'B': 1,
    'KB': 1024,
    'MB': 1024 * 1024,
    'GB': 1024 * 1024 * 1024,
    'TB': 1024 * 1024 * 1024 * 1024,
  };

  /// 将带单位的文件大小字符串转换为字节数，无法解析时返回 null。
  static int? parseFileSize(String? sizeString) {
    if (sizeString == null || sizeString.isEmpty || sizeString == '0 B') {
      return null;
    }

    final match = RegExp(r'(\\d+(?:\\.\\d+)?)\\s*([KMGT]?B)').firstMatch(sizeString);
    if (match == null) return null;

    final value = double.parse(match.group(1)!);
    final unit = match.group(2)!;
    final multiplier = _sizeUnits[unit] ?? 1;
    return (value * multiplier).toInt();
  }
}
