class ChinaMobileUploadInitPartInfo {
  final int partNumber;
  final String? uploadUrl;

  ChinaMobileUploadInitPartInfo({
    required this.partNumber,
    required this.uploadUrl,
  });

  factory ChinaMobileUploadInitPartInfo.fromJson(Map<String, dynamic> json) =>
      ChinaMobileUploadInitPartInfo(
        partNumber: json['partNumber'] as int? ?? 1,
        uploadUrl: json['uploadUrl'] as String?,
      );
}

class ChinaMobileUploadInitResponse {
  final String fileId;
  final String uploadId;
  final String parentFileId;
  final String fileName;
  final List<ChinaMobileUploadInitPartInfo> partInfos;
  final bool exist;
  final Map<String, dynamic> raw;

  ChinaMobileUploadInitResponse({
    required this.fileId,
    required this.uploadId,
    required this.parentFileId,
    required this.fileName,
    required this.partInfos,
    required this.exist,
    required this.raw,
  });

  factory ChinaMobileUploadInitResponse.fromJson(Map<String, dynamic> json) =>
      ChinaMobileUploadInitResponse(
        fileId: json['fileId']?.toString() ?? '',
        uploadId: json['uploadId']?.toString() ?? '',
        parentFileId: json['parentFileId']?.toString() ?? '',
        fileName: json['fileName']?.toString() ?? '',
        partInfos: (json['partInfos'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(ChinaMobileUploadInitPartInfo.fromJson)
            .toList(),
        exist: json['exist'] == true,
        raw: json,
      );
}

class ChinaMobileUploadCompleteResponse {
  final Map<String, dynamic> raw;

  ChinaMobileUploadCompleteResponse(this.raw);
}
