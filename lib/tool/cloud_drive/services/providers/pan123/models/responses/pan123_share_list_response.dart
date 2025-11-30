/// 123 云盘分享列表响应（免费/付费通用）
class Pan123ShareListResponse {
  const Pan123ShareListResponse({
    required this.code,
    this.message,
    this.data,
  });

  final int code;
  final String? message;
  final Pan123ShareListData? data;

  bool get success => code == 0;
  List<Pan123ShareItem> get items => data?.items ?? const [];

  factory Pan123ShareListResponse.fromMap(Map<String, dynamic> map) {
    final code = map['code'] as int? ?? -1;
    final dataMap = map['data'] as Map<String, dynamic>?;
    return Pan123ShareListResponse(
      code: code,
      message: map['message']?.toString(),
      data: dataMap != null ? Pan123ShareListData.fromMap(dataMap) : null,
    );
  }
}

class Pan123ShareListData {
  const Pan123ShareListData({
    required this.next,
    required this.len,
    required this.isFirst,
    required this.total,
    required this.items,
  });

  final String next;
  final int len;
  final bool isFirst;
  final int total;
  final List<Pan123ShareItem> items;

  factory Pan123ShareListData.fromMap(Map<String, dynamic> map) {
    final infoList = (map['InfoList'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Pan123ShareItem.fromMap)
        .toList();

    return Pan123ShareListData(
      next: map['Next']?.toString() ?? '0',
      len: _toInt(map['Len']),
      isFirst: map['IsFirst'] == true,
      total: _toInt(map['Total']),
      items: infoList,
    );
  }
}

class Pan123ShareItem {
  const Pan123ShareItem({
    required this.shareId,
    required this.shareKey,
    required this.driveId,
    required this.fileIdList,
    required this.shareName,
    required this.expiration,
    required this.expired,
    required this.sharePwd,
    required this.status,
    required this.createAt,
    required this.updateAt,
    this.downloadCount,
    this.previewCount,
    this.saveCount,
    this.bytesCharge,
    this.bytesTotal,
    this.isPayShare,
    this.isReward,
    this.auditStatus,
    this.amount,
    this.shareUrl,
    this.shareLinkList,
    this.trafficSwitch,
    this.trafficLimitSwitch,
    this.trafficLimit,
    this.noLoginStdAmount,
    this.fillPwdSwitch,
    this.payAmount,
    this.shareMessage,
    this.createStatus,
    this.createMsg,
    this.isViolation,
  });

  final int shareId;
  final String shareKey;
  final int driveId;
  final String fileIdList;
  final String shareName;
  final String? expiration;
  final bool expired;
  final String sharePwd;
  final int status;
  final String? createAt;
  final String? updateAt;
  final int? downloadCount;
  final int? previewCount;
  final int? saveCount;
  final int? bytesCharge;
  final int? bytesTotal;
  final int? isPayShare;
  final int? isReward;
  final int? auditStatus;
  final int? amount;
  final String? shareUrl;
  final Map<String, dynamic>? shareLinkList;
  final int? trafficSwitch;
  final int? trafficLimitSwitch;
  final int? trafficLimit;
  final int? noLoginStdAmount;
  final int? fillPwdSwitch;
  final int? payAmount;
  final String? shareMessage;
  final int? createStatus;
  final String? createMsg;
  final int? isViolation;

  factory Pan123ShareItem.fromMap(Map<String, dynamic> map) {
    return Pan123ShareItem(
      shareId: _toInt(map['ShareId']),
      shareKey: map['ShareKey']?.toString() ?? '',
      driveId: _toInt(map['DriveId']),
      fileIdList: map['FileIdList']?.toString() ?? '',
      shareName: map['ShareName']?.toString() ?? '',
      expiration: map['Expiration']?.toString(),
      expired: map['Expired'] == true,
      sharePwd: map['SharePwd']?.toString() ?? '',
      status: _toInt(map['Status']),
      createAt: map['CreateAt']?.toString(),
      updateAt: map['UpdateAt']?.toString(),
      downloadCount: _toNullableInt(map['DownloadCount']),
      previewCount: _toNullableInt(map['PreviewCount']),
      saveCount: _toNullableInt(map['SaveCount']),
      bytesCharge: _toNullableInt(map['bytesCharge']),
      bytesTotal: _toNullableInt(map['bytesTotal']),
      isPayShare: _toNullableInt(map['isPayShare']),
      isReward: _toNullableInt(map['isReward']),
      auditStatus: _toNullableInt(map['auditStatus']),
      amount: _toNullableInt(map['amount']),
      shareUrl: map['ShareUrl']?.toString(),
      shareLinkList: map['shareLinkList'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['shareLinkList'] as Map)
          : null,
      trafficSwitch: _toNullableInt(map['trafficSwitch']),
      trafficLimitSwitch: _toNullableInt(map['trafficLimitSwitch']),
      trafficLimit: _toNullableInt(map['trafficLimit']),
      noLoginStdAmount: _toNullableInt(map['noLoginStdAmount']),
      fillPwdSwitch: _toNullableInt(map['fillPwdSwitch']),
      payAmount: _toNullableInt(map['payAmount']),
      shareMessage: map['shareMessage']?.toString(),
      createStatus: _toNullableInt(map['createStatus']),
      createMsg: map['createMsg']?.toString(),
      isViolation: _toNullableInt(map['isViolation']),
    );
  }
}

int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
int? _toNullableInt(dynamic v) =>
    v == null ? null : int.tryParse(v.toString());
