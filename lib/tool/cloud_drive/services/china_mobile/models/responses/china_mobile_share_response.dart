
import '../../../providers/china_mobile/models/responses/china_mobile_base_response.dart';

/// 中国移动云盘分享响应
class ChinaMobileShareResponse {
  /// 分享链接
  final String? shareUrl;

  /// 分享ID
  final String? shareId;

  /// 提取码/密码
  final String? password;

  /// 过期时间
  final String? expiration;

  /// 其他数据
  final Map<String, dynamic>? extraData;

  const ChinaMobileShareResponse({
    this.shareUrl,
    this.shareId,
    this.password,
    this.expiration,
    this.extraData,
  });

  /// 从API响应解析
  ///
  /// 根据实际API响应格式解析分享链接信息
  factory ChinaMobileShareResponse.fromJson(Map<String, dynamic> json) {
    final base = ChinaMobileBaseResponse.fromJson(json);
    final data = base.data ?? json;

    // 尝试从不同可能的字段中提取分享链接
    String? shareUrl;
    String? shareId;
    String? password;

    // 常见的分享链接字段名
    if (data.containsKey('shareUrl')) {
      shareUrl = data['shareUrl']?.toString();
    } else if (data.containsKey('share_url')) {
      shareUrl = data['share_url']?.toString();
    } else if (data.containsKey('link')) {
      shareUrl = data['link']?.toString();
    } else if (data.containsKey('url')) {
      shareUrl = data['url']?.toString();
    }

    // 常见的分享ID字段名
    if (data.containsKey('shareId')) {
      shareId = data['shareId']?.toString();
    } else if (data.containsKey('share_id')) {
      shareId = data['share_id']?.toString();
    }

    // 常见的密码字段名
    if (data.containsKey('password')) {
      password = data['password']?.toString();
    } else if (data.containsKey('passcode')) {
      password = data['passcode']?.toString();
    }

    return ChinaMobileShareResponse(
      shareUrl: shareUrl,
      shareId: shareId,
      password: password,
      expiration: data['expiration']?.toString(),
      extraData: data.isNotEmpty ? data : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    if (shareUrl != null) 'shareUrl': shareUrl,
    if (shareId != null) 'shareId': shareId,
    if (password != null) 'password': password,
    if (expiration != null) 'expiration': expiration,
    if (extraData != null) ...extraData!,
  };

  /// 是否有有效的分享链接
  bool get hasValidShareUrl => shareUrl != null && shareUrl!.isNotEmpty;

  @override
  String toString() =>
      'ChinaMobileShareResponse('
      'shareUrl: ${shareUrl != null ? (shareUrl!.length > 50 ? '${shareUrl!.substring(0, 50)}...' : shareUrl) : null}, '
      'shareId: $shareId)';
}
