class BaiduShareRecord {
  final int shareId;
  final String? name;
  final String? shortLink;
  final String? shortUrl;
  final String? password;
  final String? typicalPath;
  final List<String> fsIds;
  final DateTime? createdAt;
  final int? expiredSeconds;
  final int status;

  BaiduShareRecord({
    required this.shareId,
    this.name,
    this.shortLink,
    this.shortUrl,
    this.password,
    this.typicalPath,
    this.fsIds = const [],
    this.createdAt,
    this.expiredSeconds,
    this.status = 0,
  });

  factory BaiduShareRecord.fromJson(Map<String, dynamic> json) {
    return BaiduShareRecord(
      shareId: (json['shareId'] ?? json['shareid'] ?? 0) as int,
      name: json['name']?.toString(),
      shortLink: json['shortlink']?.toString(),
      shortUrl: json['shorturl']?.toString(),
      password: json['passwd']?.toString(),
      typicalPath: json['typicalPath']?.toString(),
      fsIds: (json['fsIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      createdAt: json['ctime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['ctime'] as int) * 1000,
            )
          : null,
      expiredSeconds: json['expiredTime'] as int?,
      status: json['status'] as int? ?? 0,
    );
  }
}
