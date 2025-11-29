import '../../../../../data/models/cloud_drive_entities.dart';
import 'parsing_utils.dart';

/// 预览信息响应
class ChinaMobilePreviewResponse {
  final String fileId;
  final Map<String, dynamic>? meta;
  final Map<String, dynamic>? previewInfo;
  final List<dynamic>? cdnMediaInfos;
  final bool? cdnSwitch;
  final DateTime? cdnExpiredAt;
  final String? message;
  final Map<String, dynamic> raw;

  const ChinaMobilePreviewResponse({
    required this.fileId,
    required this.meta,
    required this.previewInfo,
    required this.cdnMediaInfos,
    required this.cdnSwitch,
    required this.cdnExpiredAt,
    required this.message,
    required this.raw,
  });

  factory ChinaMobilePreviewResponse.fromJson(Map<String, dynamic> json) {
    final previewInfo =
        json['previewInfo'] is Map<String, dynamic>
            ? json['previewInfo'] as Map<String, dynamic>
            : null;
    return ChinaMobilePreviewResponse(
      fileId: json['fileId']?.toString() ?? '',
      meta: json['meta'] as Map<String, dynamic>?,
      previewInfo: previewInfo,
      cdnMediaInfos: json['cdnMediaInfos'] as List<dynamic>?,
      cdnSwitch: json['cdnSwitch'] as bool?,
      cdnExpiredAt: ChinaMobileParsingUtils.parseDate(json['cdnExpiredAt']),
      message: json['message']?.toString(),
      raw: json,
    );
  }

  String? get url => previewInfo?['url']?.toString();
  String? get status => previewInfo?['status']?.toString();

  CloudDrivePreviewResult toPreviewResult(CloudDriveFile file) {
    return CloudDrivePreviewResult(
      file: file,
      previewUrl: url,
      status: status,
      expiresAt: cdnExpiredAt,
      meta: meta,
      extra: {
        'previewInfo': previewInfo,
        'cdnMediaInfos': cdnMediaInfos,
        'cdnSwitch': cdnSwitch,
        'message': message,
        'raw': raw,
      },
    );
  }
}
