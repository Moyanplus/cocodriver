import 'china_mobile_request.dart';

/// 中国移动云盘分享请求
class ChinaMobileShareRequest implements ChinaMobileRequest {
  /// 分享请求体
  final ShareRequestBody getOutLinkReq;

  const ChinaMobileShareRequest({required this.getOutLinkReq});

  /// 转换为请求体
  @override
  Map<String, dynamic> toRequestBody() => {
    'getOutLinkReq': getOutLinkReq.toJson(),
  };

  @override
  String toString() =>
      'ChinaMobileShareRequest(coIDLst: ${getOutLinkReq.coIDLst.length} files)';
}

/// 分享请求体
class ShareRequestBody {
  /// 子链接类型
  final int subLinkType;

  /// 是否加密
  final int encrypt;

  /// 内容对象ID列表
  final List<String> coIDLst;

  /// 内容附件ID列表
  final List<String> caIDLst;

  /// 发布类型
  final int pubType;

  /// 专用名称
  final String dedicatedName;

  /// 周期单位
  final int periodUnit;

  /// 查看者列表
  final List<String> viewerLst;

  /// 扩展信息
  final ShareExtInfo extInfo;

  /// 通用账号信息
  final CommonAccountInfo commonAccountInfo;

  const ShareRequestBody({
    required this.subLinkType,
    required this.encrypt,
    required this.coIDLst,
    required this.caIDLst,
    required this.pubType,
    required this.dedicatedName,
    required this.periodUnit,
    required this.viewerLst,
    required this.extInfo,
    required this.commonAccountInfo,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'subLinkType': subLinkType,
    'encrypt': encrypt,
    'coIDLst': coIDLst,
    'caIDLst': caIDLst,
    'pubType': pubType,
    'dedicatedName': dedicatedName,
    'periodUnit': periodUnit,
    'viewerLst': viewerLst,
    'extInfo': extInfo.toJson(),
    'commonAccountInfo': commonAccountInfo.toJson(),
  };
}

/// 分享扩展信息
class ShareExtInfo {
  /// 是否水印
  final int isWatermark;

  /// 分享渠道
  final String shareChannel;

  const ShareExtInfo({required this.isWatermark, required this.shareChannel});

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'isWatermark': isWatermark,
    'shareChannel': shareChannel,
  };
}

/// 通用账号信息
class CommonAccountInfo {
  /// 账号
  final String account;

  /// 账号类型
  final int accountType;

  const CommonAccountInfo({required this.account, required this.accountType});

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'account': account,
    'accountType': accountType,
  };
}
