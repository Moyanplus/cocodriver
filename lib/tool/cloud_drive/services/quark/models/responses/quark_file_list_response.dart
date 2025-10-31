import '../../../../data/models/cloud_drive_entities.dart';
import '../../core/quark_config.dart';
import '../../utils/quark_logger.dart';

/// 夸克云盘文件列表响应
class QuarkFileListResponse {
  /// 文件列表
  final List<CloudDriveFile> files;

  /// 总文件数
  final int total;

  const QuarkFileListResponse({required this.files, required this.total});

  /// 从API响应解析
  factory QuarkFileListResponse.fromJson(
    Map<String, dynamic> json,
    String parentFolderId,
  ) {
    final fileList = <CloudDriveFile>[];
    final data = json['data'];

    if (data != null && data['list'] != null) {
      final files = data['list'] as List<dynamic>;

      for (final fileData in files) {
        final file = _parseFileData(fileData, parentFolderId);
        if (file != null) {
          fileList.add(file);
        }
      }
    }

    final total = data?['total'] as int? ?? fileList.length;

    QuarkLogger.success('解析文件列表完成，共 ${fileList.length} 个文件');
    return QuarkFileListResponse(files: fileList, total: total);
  }

  /// 解析单个文件数据
  static CloudDriveFile? _parseFileData(
    Map<String, dynamic> fileData,
    String parentId,
  ) {
    try {
      // 1. 解析基本信息
      final fid = fileData[QuarkConfig.responseFields['fid']]?.toString() ?? '';
      final name =
          fileData[QuarkConfig.responseFields['fileName']]?.toString() ??
          fileData[QuarkConfig.responseFields['name']]?.toString() ??
          '';
      final size =
          fileData[QuarkConfig.responseFields['size']]?.toString() ?? '0';

      // 2. 判断是否为文件夹
      final fileTypeRaw = fileData[QuarkConfig.responseFields['fileType']];
      final categoryRaw = fileData[QuarkConfig.responseFields['category']];
      final isFolder =
          (fileTypeRaw == QuarkConfig.fileTypes['folder'] ||
              fileTypeRaw?.toString() == '0') &&
          (categoryRaw == QuarkConfig.fileTypes['folder'] ||
              categoryRaw?.toString() == '0');

      // 3. 解析修改时间（支持多种格式）
      DateTime? updatedAt;
      final updateTime =
          fileData[QuarkConfig.responseFields['lUpdatedAt']] ??
          fileData[QuarkConfig.responseFields['updatedAt']] ??
          fileData[QuarkConfig.responseFields['utime']];

      if (updateTime != null) {
        if (updateTime is int) {
          updatedAt = DateTime.fromMillisecondsSinceEpoch(updateTime);
        } else if (updateTime is String) {
          final timestamp = int.tryParse(updateTime);
          if (timestamp != null) {
            updatedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
          } else {
            updatedAt = DateTime.tryParse(updateTime);
          }
        }
      }

      // 4. 解析文件大小（字节数，文件夹无大小）
      int? sizeBytes;
      if (!isFolder && size.isNotEmpty && size != '0') {
        sizeBytes = int.tryParse(size);
      }

      // 5. 解析缩略图URL（仅文件有缩略图）
      String? thumbnailUrl;
      String? bigThumbnailUrl;
      String? previewUrl;

      if (!isFolder) {
        thumbnailUrl =
            fileData[QuarkConfig.responseFields['thumbnail']]?.toString();
        bigThumbnailUrl =
            fileData[QuarkConfig.responseFields['bigThumbnail']]?.toString();
        previewUrl =
            fileData[QuarkConfig.responseFields['previewUrl']]?.toString();
      }

      // 6. 创建CloudDriveFile对象
      return CloudDriveFile(
        id: fid,
        name: name,
        size: sizeBytes,
        modifiedTime: updatedAt,
        isFolder: isFolder,
        folderId: parentId,
        thumbnailUrl: thumbnailUrl,
        bigThumbnailUrl: bigThumbnailUrl,
        previewUrl: previewUrl,
      );
    } catch (e) {
      QuarkLogger.warning('解析文件数据失败，跳过该项: $e');
      QuarkLogger.debug('文件数据', data: fileData);
      return null;
    }
  }

  @override
  String toString() =>
      'QuarkFileListResponse(count: ${files.length}, total: $total)';
}
