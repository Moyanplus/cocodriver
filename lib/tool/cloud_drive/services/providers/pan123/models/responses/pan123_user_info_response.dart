import '../../../../../data/models/cloud_drive_dtos.dart';

/// 123 云盘用户信息响应
class Pan123UserInfoResponse {
  final int uid;
  final String nickname;
  final String? avatar;
  final int used;
  final int total;
  final int fileCount;
  final bool isVip;
  final String? vipExpire;
  final bool bindWechat;
  final bool straightLink;

  Pan123UserInfoResponse({
    required this.uid,
    required this.nickname,
    required this.used,
    required this.total,
    required this.fileCount,
    this.avatar,
    this.isVip = false,
    this.vipExpire,
    this.bindWechat = false,
    this.straightLink = false,
  });

  factory Pan123UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return Pan123UserInfoResponse(
      uid: json['UID'] as int? ?? 0,
      nickname: json['Nickname']?.toString() ?? '',
      avatar: json['HeadImage']?.toString(),
      used: json['SpaceUsed'] as int? ?? 0,
      total: json['SpacePermanent'] as int? ?? 0,
      fileCount: json['FileCount'] as int? ?? 0,
      isVip: json['Vip'] as bool? ?? false,
      vipExpire: json['VipExpire']?.toString(),
      bindWechat: json['BindWechat'] as bool? ?? false,
      straightLink: json['StraightLink'] as bool? ?? false,
    );
  }

  CloudDriveAccountInfo toAccountInfo() {
    return CloudDriveAccountInfo(
      username: nickname,
      phone: null,
      photo: avatar,
      uk: uid,
      isVip: isVip,
      isSvip: false,
      isScanVip: false,
      loginState: 1,
    );
  }
}
