import '../../../../data/models/cloud_drive_entities.dart';
import '../../core/china_mobile_config.dart';
import '../../utils/china_mobile_logger.dart';

/// 中国移动云盘文件列表响应
class ChinaMobileFileListResponse {
  /// 文件列表
  final List<CloudDriveFile> files;

  /// 是否有更多
  final bool hasMore;

  /// 下一页游标
  final String? nextPageCursor;

  /// 总文件数
  final int? totalCount;

  const ChinaMobileFileListResponse({
    required this.files,
    this.hasMore = false,
    this.nextPageCursor,
    this.totalCount,
  });

  /// 从API响应解析
  factory ChinaMobileFileListResponse.fromJson(
    Map<String, dynamic> json,
    String parentFolderId,
  ) {
    final fileList = <CloudDriveFile>[];
    final data = json['data'] as Map<String, dynamic>?;

    if (data != null) {
      final files = (data['items'] as List<dynamic>?) ??
          (data['list'] as List<dynamic>?) ??
          const [];

      for (final fileData in files) {
        final file = _parseFileData(
          fileData as Map<String, dynamic>,
          parentFolderId,
        );
        if (file != null) {
          fileList.add(file);
        }
      }
    }

    // 解析分页信息
    final pageInfo = data?['pageInfo'] as Map<String, dynamic>?;
    final nextPageCursor =
        data?['nextPageCursor']?.toString() ??
        pageInfo?['pageCursor']?.toString();
    final hasMore = nextPageCursor != null && nextPageCursor.isNotEmpty;

    ChinaMobileLogger.success('解析文件列表完成，共 ${fileList.length} 个文件');
    return ChinaMobileFileListResponse(
      files: fileList,
      hasMore: hasMore,
      nextPageCursor: nextPageCursor,
    );
  }

  /// 解析单个文件数据
  static CloudDriveFile? _parseFileData(
    Map<String, dynamic> fileData,
    String parentId,
  ) {
    try {
      // 1. 解析基本信息
      final fileId =
          fileData[ChinaMobileConfig.responseFields['fileId']]?.toString() ??
          '';
      final name =
          fileData[ChinaMobileConfig.responseFields['fileName']]?.toString() ??
          fileData[ChinaMobileConfig.responseFields['name']]?.toString() ??
          '';
      final size =
          fileData[ChinaMobileConfig.responseFields['size']]?.toString() ?? '0';

      // 2. 判断是否为文件夹（根据API响应判断，可能需要根据实际情况调整）
      final isFolder =
          fileData['isFolder'] as bool? ??
          fileData['type']?.toString() == 'folder';

      // 3. 解析修改时间
      DateTime? updatedAt;
      final updateTime =
          fileData[ChinaMobileConfig.responseFields['updatedAt']];
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

      if (!isFolder) {
        final thumbnails = fileData['thumbnails'] as Map<String, dynamic>?;
        if (thumbnails != null) {
          thumbnailUrl = thumbnails['Small'] as String?;
          bigThumbnailUrl = thumbnails['Large'] as String?;
        }
      }

      // 6. 创建CloudDriveFile对象
      return CloudDriveFile(
        id: fileId,
        name: name,
        size: sizeBytes,
        modifiedTime: updatedAt,
        isFolder: isFolder,
        folderId: parentId,
        thumbnailUrl: thumbnailUrl,
        bigThumbnailUrl: bigThumbnailUrl,
      );
    } catch (e) {
      ChinaMobileLogger.warning('解析文件数据失败，跳过该项: $e');
      ChinaMobileLogger.debug('文件数据', data: fileData);
      return null;
    }
  }

  @override
  String toString() =>
      'ChinaMobileFileListResponse(count: ${files.length}, hasMore: $hasMore)';
}
