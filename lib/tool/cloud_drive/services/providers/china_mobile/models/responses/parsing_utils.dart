
/// 通用解析工具，避免各响应重复代码。
class ChinaMobileParsingUtils {
  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      final ts = int.tryParse(value);
      if (ts != null) return DateTime.fromMillisecondsSinceEpoch(ts);
      // 强制按 ISO 解析并返回 UTC，再转本地，保证 folder/file 一致
      final parsed = DateTime.tryParse(value);
      return parsed?.toLocal();
    }
    return null;
  }

  /// 解析缩略图，返回 (small, large)
  static (String?, String?) parseThumbnails(Map<String, dynamic> fileData) {
    final thumbRaw = fileData['thumbnailUrls'] ?? fileData['thumbnailurls'];
    if (thumbRaw == null) return (null, null);

    // 统一成列表
    final thumbList = thumbRaw is List
        ? thumbRaw
        : thumbRaw is Map<String, dynamic>
            ? thumbRaw.entries
                .map((e) => {'style': e.key, 'url': e.value})
                .toList()
            : thumbRaw is String
                ? <Map<String, dynamic>>[
                    {'style': 'small', 'url': thumbRaw}
                  ]
                : <dynamic>[];

    String? small;
    String? large;
    for (final item in thumbList.whereType<Map<String, dynamic>>()) {
      final style = item['style']?.toString().toLowerCase();
      final url = item['url']?.toString();
      if (style == 'small' && small == null) small = url;
      if (style == 'large' && large == null) large = url;
      if (style == null && url != null) {
        small ??= url;
      }
    }
    return (small, large);
  }
}
