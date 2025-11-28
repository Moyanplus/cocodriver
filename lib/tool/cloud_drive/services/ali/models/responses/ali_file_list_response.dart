import '../../../../data/models/cloud_drive_entities.dart';

/// 阿里云盘文件列表响应（简单封装，当前直接复用 CloudDriveFile 列表）。
class AliFileListResponse {
  const AliFileListResponse({required this.files});

  final List<CloudDriveFile> files;
}
