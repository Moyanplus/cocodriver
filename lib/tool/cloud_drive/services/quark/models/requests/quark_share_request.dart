/// 分享链接类型
enum ShareUrlType {
  /// 标准分享链接
  standard(2);

  final int value;
  const ShareUrlType(this.value);
}

/// 分享过期类型
enum ShareExpiredType {
  /// 永久有效
  permanent(1),

  /// 1天
  oneDay(2),

  /// 7天
  sevenDays(3),

  /// 30天
  thirtyDays(4);

  final int value;
  const ShareExpiredType(this.value);
}

/// 夸克云盘创建分享请求
class QuarkShareRequest {
  /// 文件ID列表
  final List<String> fileIds;

  /// 分享标题
  final String? title;

  /// 分享链接类型
  final ShareUrlType urlType;

  /// 过期类型
  final ShareExpiredType expiredType;

  /// 提取码（可选）
  final String? passcode;

  const QuarkShareRequest({
    required this.fileIds,
    this.title,
    this.urlType = ShareUrlType.standard,
    this.expiredType = ShareExpiredType.permanent,
    this.passcode,
  });

  /// 转换为API请求体
  Map<String, dynamic> toRequestBody() {
    final body = <String, dynamic>{
      'fid_list': fileIds,
      'title': title ?? '分享文件',
      'url_type': urlType.value,
      'expired_type': expiredType.value,
    };

    if (passcode != null && passcode!.isNotEmpty) {
      body['passcode'] = passcode;
    }

    return body;
  }

  @override
  String toString() =>
      'QuarkShareRequest('
      'fileIds: ${fileIds.length} files, '
      'title: $title, '
      'expiredType: $expiredType)';
}
