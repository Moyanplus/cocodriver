import '../../../../data/models/cloud_drive_entities.dart';

class BaiduFileListResponse {
  const BaiduFileListResponse({
    required this.files,
    required this.folders,
  });

  final List<CloudDriveFile> files;
  final List<CloudDriveFile> folders;
}
