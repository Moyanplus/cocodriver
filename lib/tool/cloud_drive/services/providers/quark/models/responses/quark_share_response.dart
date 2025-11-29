/// 夸克云盘分享响应
class QuarkShareResponse {
  /// 分享ID
  final String shareId;

  /// 事件ID
  final String eventId;

  /// 分享链接
  final String shareUrl;

  /// 提取码
  final String? passcode;

  /// 过期类型
  final int expiredType;

  /// 标题
  final String title;

  /// 状态
  final int status;

  const QuarkShareResponse({
    required this.shareId,
    required this.eventId,
    required this.shareUrl,
    this.passcode,
    required this.expiredType,
    required this.title,
    required this.status,
  });

  /// 从API响应解析
  factory QuarkShareResponse.fromJson(
    Map<String, dynamic> json,
    String shareUrl,
  ) {
    return QuarkShareResponse(
      shareId: json['share_id'] as String,
      eventId: json['event_id'] as String,
      shareUrl: shareUrl,
      passcode: json['passcode'] as String?,
      expiredType: json['expired_type'] as int,
      title: json['title'] as String,
      status: json['status'] as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'share_id': shareId,
    'event_id': eventId,
    'share_url': shareUrl,
    if (passcode != null) 'passcode': passcode,
    'expired_type': expiredType,
    'title': title,
    'status': status,
  };

  @override
  String toString() =>
      'QuarkShareResponse('
      'shareId: $shareId, '
      'shareUrl: $shareUrl, '
      'title: $title)';
}
