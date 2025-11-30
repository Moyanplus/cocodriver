/// 上传初始化响应
class Pan123UploadInitResponse {
  Pan123UploadInitResponse({
    required this.bucket,
    required this.key,
    required this.fileId,
    required this.uploadId,
    required this.storageNode,
    required this.sliceSize,
    required this.endPoint,
    required this.reuse,
    required this.info,
  });

  factory Pan123UploadInitResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return Pan123UploadInitResponse(
      bucket: data['Bucket']?.toString() ?? '',
      key: data['Key']?.toString() ?? '',
      fileId: data['FileId']?.toString() ?? '',
      uploadId: data['UploadId']?.toString() ?? '',
      storageNode: data['StorageNode']?.toString() ?? '',
      sliceSize: data['SliceSize']?.toString() ?? '',
      endPoint: data['EndPoint']?.toString() ?? '',
      reuse: data['Reuse'] as bool? ?? false,
      info: (data['Info'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }

  final String bucket;
  final String key;
  final String fileId;
  final String uploadId;
  final String storageNode;
  final String sliceSize;
  final String endPoint;
  final bool reuse;
  final Map<String, dynamic> info;
}

/// 预签名 URL 响应
class Pan123UploadAuthResponse {
  Pan123UploadAuthResponse({required this.urls, this.firstUrl});

  factory Pan123UploadAuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final presigned = data['presignedUrls'] as Map<String, dynamic>? ?? {};
    // 取第一条即可（当前只支持单分片）
    final first = presigned.values.cast<String?>().firstWhere(
      (e) => e != null && e.isNotEmpty,
      orElse: () => null,
    );
    return Pan123UploadAuthResponse(urls: presigned, firstUrl: first);
  }

  final Map<String, dynamic> urls;
  final String? firstUrl;
}

/// 上传完成响应（包含文件信息）
class Pan123UploadCompleteResponse {
  Pan123UploadCompleteResponse({required this.fileInfo});

  factory Pan123UploadCompleteResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final info = data['file_info'] as Map<String, dynamic>? ?? {};
    return Pan123UploadCompleteResponse(fileInfo: info);
  }

  final Map<String, dynamic> fileInfo;
}
