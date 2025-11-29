import 'china_mobile_base_response.dart';

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

  factory ChinaMobileCreateFolderResponse.fromJson(Map<String, dynamic> json) {
    final base = ChinaMobileBaseResponse.fromJson(json);
    final data = base.data ?? json;
    return ChinaMobileCreateFolderResponse(
      parentFileId: data['parentFileId']?.toString() ?? '',
      fileId: data['fileId']?.toString() ?? '',
      type: data['type']?.toString() ?? '',
      fileName: data['fileName']?.toString() ?? '',
    );
  }
}
