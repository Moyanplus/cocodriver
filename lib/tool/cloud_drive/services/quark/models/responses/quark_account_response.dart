/// 夸克云盘账号信息响应
class QuarkAccountInfoResponse {
  /// 用户名/昵称
  final String nickname;

  /// 手机号（可能为空）
  final String? mobile;

  /// 头像URI
  final String? avatarUri;

  const QuarkAccountInfoResponse({
    required this.nickname,
    this.mobile,
    this.avatarUri,
  });

  /// 从API响应解析
  factory QuarkAccountInfoResponse.fromJson(Map<String, dynamic> json) {
    return QuarkAccountInfoResponse(
      nickname: json['nickname'] as String? ?? '',
      mobile: json['mobilekps'] as String?,
      avatarUri: json['avatar_uri'] as String?,
    );
  }

  @override
  String toString() =>
      'QuarkAccountInfoResponse(nickname: $nickname, mobile: $mobile)';
}

/// 夸克云盘会员信息响应
class QuarkMemberInfoResponse {
  /// 总容量（字节）
  final int totalCapacity;

  /// 已用容量（字节）
  final int useCapacity;

  /// 是否为VIP
  final bool isVip;

  /// VIP结束时间（秒级时间戳）
  final int? vipEndTime;

  /// 会员等级
  final int? memberLevel;

  const QuarkMemberInfoResponse({
    required this.totalCapacity,
    required this.useCapacity,
    this.isVip = false,
    this.vipEndTime,
    this.memberLevel,
  });

  /// 从API响应解析
  factory QuarkMemberInfoResponse.fromJson(Map<String, dynamic> json) {
    return QuarkMemberInfoResponse(
      totalCapacity: json['capacity_total'] as int? ?? 0,
      useCapacity: json['capacity_use'] as int? ?? 0,
      isVip: json['is_vip'] as bool? ?? false,
      vipEndTime: json['vip_end_time'] as int?,
      memberLevel: json['member_level'] as int?,
    );
  }

  /// 剩余容量（字节）
  int get freeCapacity => totalCapacity - useCapacity;

  /// 总容量（GB）
  double get totalCapacityGB => totalCapacity / 1024 / 1024 / 1024;

  /// 已用容量（GB）
  double get useCapacityGB => useCapacity / 1024 / 1024 / 1024;

  /// 剩余容量（GB）
  double get freeCapacityGB => freeCapacity / 1024 / 1024 / 1024;

  /// VIP类型描述
  String get vipTypeDesc => isVip ? '会员用户' : '普通用户';

  /// VIP状态描述
  String? get vipStatusDesc {
    if (!isVip || vipEndTime == null) return null;
    final endTime = DateTime.fromMillisecondsSinceEpoch(vipEndTime! * 1000);
    return '有效期至 ${endTime.year}/${endTime.month}/${endTime.day}';
  }

  /// 会员等级描述
  String? get memberLevelDesc {
    if (memberLevel == null) return null;
    return 'Lv$memberLevel';
  }

  @override
  String toString() =>
      'QuarkMemberInfoResponse('
      'capacity: ${useCapacityGB.toStringAsFixed(2)} GB / ${totalCapacityGB.toStringAsFixed(2)} GB, '
      'vip: $vipTypeDesc)';
}
