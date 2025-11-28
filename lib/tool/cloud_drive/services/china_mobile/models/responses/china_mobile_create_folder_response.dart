class ChinaMobileCreateFolderResponse {
  final String parentFileId;
  final String fileId;
  final String type;
  final String fileName;

  ChinaMobileCreateFolderResponse({
    required this.parentFileId,
    required this.fileId,
    required this.type,
    required this.fileName,
  });

  factory ChinaMobileCreateFolderResponse.fromJson(Map<String, dynamic> json) =>
      ChinaMobileCreateFolderResponse(
        parentFileId: json['parentFileId'] as String? ?? '',
        fileId: json['fileId'] as String? ?? '',
        type: json['type'] as String? ?? '',
        fileName: json['fileName'] as String? ?? '',
      );
}
