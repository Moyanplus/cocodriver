import '../../../../../data/models/cloud_drive_entities.dart';

/// 百度网盘列表响应
class BaiduFileListResponse {
  const BaiduFileListResponse({
    required this.files,
    required this.folders,
  });

  /// 文件列表
  final List<CloudDriveFile> files;

  /// 文件夹列表
  final List<CloudDriveFile> folders;
}
