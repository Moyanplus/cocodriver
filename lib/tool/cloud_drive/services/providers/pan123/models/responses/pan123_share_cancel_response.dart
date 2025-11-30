/// 123 云盘取消分享响应
class Pan123ShareCancelResponse {
  const Pan123ShareCancelResponse({
    required this.code,
    this.message,
    this.shareIds = const <int>[],
  });

  final int code;
  final String? message;
  final List<int> shareIds;

  bool get success => code == 0;

  factory Pan123ShareCancelResponse.fromMap(Map<String, dynamic> map) {
    final data = map['data'] as Map<String, dynamic>? ?? {};
    final infoList = (data['InfoList'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => e['ShareId'])
        .whereType<int>()
        .toList();
    return Pan123ShareCancelResponse(
      code: map['code'] as int? ?? -1,
      message: map['message']?.toString(),
      shareIds: infoList,
    );
  }
}
