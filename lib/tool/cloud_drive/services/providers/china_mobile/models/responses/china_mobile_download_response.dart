import 'china_mobile_base_response.dart';

/// 中国移动云盘下载响应
class ChinaMobileDownloadResponse {
  /// 文件ID
  final String fileId;

  /// 下载URL
  final String url;

  /// 过期时间
  final String expiration;

  /// 文件大小
  final int? size;

  /// CDN URL
  final String? cdnUrl;

  /// CDN开关
  final bool? cdnSwitch;

  /// 元数据审核信息
  final AuditInfo? metadataAuditInfo;

  /// 内容审核信息
  final AuditInfo? contentAuditInfo;

  const ChinaMobileDownloadResponse({
    required this.fileId,
    required this.url,
    required this.expiration,
    this.size,
    this.cdnUrl,
    this.cdnSwitch,
    this.metadataAuditInfo,
    this.contentAuditInfo,
  });

  /// 从API响应解析
  factory ChinaMobileDownloadResponse.fromJson(Map<String, dynamic> json) {
    final base = ChinaMobileBaseResponse.fromJson(json);
    final data = base.data ?? json;

    return ChinaMobileDownloadResponse(
      fileId: data['fileId']?.toString() ?? '',
      url: data['url']?.toString() ?? '',
      expiration: data['expiration']?.toString() ?? '',
      size: data['size'] as int?,
      cdnUrl: data['cdnUrl']?.toString(),
      cdnSwitch: data['cdnSwitch'] as bool?,
      metadataAuditInfo:
          data['metadataAuditInfo'] != null
              ? AuditInfo.fromJson(
                data['metadataAuditInfo'] as Map<String, dynamic>,
              )
              : null,
      contentAuditInfo:
          data['contentAuditInfo'] != null
              ? AuditInfo.fromJson(
                data['contentAuditInfo'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  @override
  String toString() =>
      'ChinaMobileDownloadResponse(fileId: $fileId, url: ${url.length > 50 ? '${url.substring(0, 50)}...' : url})';
}

/// 审核信息
class AuditInfo {
  /// 审核状态
  final int auditStatus;

  /// 审核级别
  final int? auditLevel;

  /// 审核结果
  final int? auditResult;

  const AuditInfo({
    required this.auditStatus,
    this.auditLevel,
    this.auditResult,
  });

  /// 从JSON解析
  factory AuditInfo.fromJson(Map<String, dynamic> json) {
    return AuditInfo(
      auditStatus: json['auditStatus'] as int? ?? 0,
      auditLevel: json['auditLevel'] as int?,
      auditResult: json['auditResult'] as int?,
    );
  }

  @override
  String toString() =>
      'AuditInfo(auditStatus: $auditStatus, auditLevel: $auditLevel, auditResult: $auditResult)';
}
