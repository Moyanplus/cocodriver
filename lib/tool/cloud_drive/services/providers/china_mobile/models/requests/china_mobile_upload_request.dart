import 'china_mobile_request.dart';

class ChinaMobileUploadPartInfo {
  final int partNumber;
  final int partSize;
  final Map<String, dynamic>? parallelHashCtx;

  ChinaMobileUploadPartInfo({
    required this.partNumber,
    required this.partSize,
    this.parallelHashCtx,
  });

  Map<String, dynamic> toJson() => {
    'parallelHashCtx': parallelHashCtx ?? {'partOffset': 0},
    'partNumber': partNumber,
    'partSize': partSize,
  };
}

class ChinaMobileUploadInitRequest implements ChinaMobileRequest {
  final String parentFileId;
  final String name;
  final String type;
  final int size;
  final String fileRenameMode;
  final String contentHash;
  final String contentHashAlgorithm;
  final String contentType;
  final bool parallelUpload;
  final List<ChinaMobileUploadPartInfo> partInfos;

  ChinaMobileUploadInitRequest({
    required this.parentFileId,
    required this.name,
    required this.type,
    required this.size,
    required this.fileRenameMode,
    required this.contentHash,
    required this.contentHashAlgorithm,
    required this.contentType,
    this.parallelUpload = false,
    required this.partInfos,
  });

  @override
  Map<String, dynamic> toRequestBody() => {
    'parentFileId': parentFileId,
    'name': name,
    'type': type,
    'size': size,
    'fileRenameMode': fileRenameMode,
    'contentHash': contentHash,
    'contentHashAlgorithm': contentHashAlgorithm,
    'contentType': contentType,
    'parallelUpload': parallelUpload,
    'partInfos': partInfos.map((e) => e.toJson()).toList(),
  };
}

class ChinaMobileUploadCompleteRequest implements ChinaMobileRequest {
  final String fileId;
  final String uploadId;
  final String contentHash;
  final String contentHashAlgorithm;

  ChinaMobileUploadCompleteRequest({
    required this.fileId,
    required this.uploadId,
    required this.contentHash,
    required this.contentHashAlgorithm,
  });

  @override
  Map<String, dynamic> toRequestBody() => {
    'fileId': fileId,
    'uploadId': uploadId,
    'contentHash': contentHash,
    'contentHashAlgorithm': contentHashAlgorithm,
  };
}
