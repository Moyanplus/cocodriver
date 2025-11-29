import '../../../../../data/models/cloud_drive_entities.dart';
import '../../core/china_mobile_config.dart';
import '../../utils/china_mobile_logger.dart';
import 'china_mobile_base_response.dart';
import 'parsing_utils.dart';

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
    final base = ChinaMobileBaseResponse.fromJson(json);
    final data = base.data;

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
      final fileId = _parseId(fileData);
      final name = _parseName(fileData);
      final isFolder = _parseIsFolder(fileData);
      final updatedAt = ChinaMobileParsingUtils.parseDate(
        fileData[ChinaMobileConfig.responseFields['updatedAt']] ??
            fileData['updatedAt'],
      );
      final createdAt = ChinaMobileParsingUtils.parseDate(
        fileData['createdAt'] ?? fileData['created_at'],
      );
      final sizeBytes = _parseSizeBytes(fileData, isFolder);
      final thumbnails = _parseThumbnails(fileData, isFolder);

      // 2. 创建CloudDriveFile对象
      return CloudDriveFile(
        id: fileId,
        name: name,
        size: sizeBytes,
        updatedAt: updatedAt,
        createdAt: createdAt,
        isFolder: isFolder,
        folderId: parentId,
        thumbnailUrl: thumbnails.$1,
        bigThumbnailUrl: thumbnails.$2,
      );
    } catch (e) {
      ChinaMobileLogger.warning('解析文件数据失败，跳过该项: $e');
      ChinaMobileLogger.debug('文件数据', data: fileData);
      return null;
    }
  }

  static String _parseId(Map<String, dynamic> fileData) =>
      fileData[ChinaMobileConfig.responseFields['fileId']]?.toString() ?? '';

  static String _parseName(Map<String, dynamic> fileData) =>
      fileData[ChinaMobileConfig.responseFields['fileName']]?.toString() ??
      fileData[ChinaMobileConfig.responseFields['name']]?.toString() ??
      '';

  static bool _parseIsFolder(Map<String, dynamic> fileData) =>
      fileData['isFolder'] as bool? ??
      fileData['type']?.toString() == 'folder';

  static int? _parseSizeBytes(
    Map<String, dynamic> fileData,
    bool isFolder,
  ) {
    if (isFolder) return null;
    final size =
        fileData[ChinaMobileConfig.responseFields['size']]?.toString() ?? '0';
    if (size.isEmpty || size == '0') return null;
    return int.tryParse(size);
  }

  // 返回 (small, large)
  static (String?, String?) _parseThumbnails(
    Map<String, dynamic> fileData,
    bool isFolder,
  ) {
    if (isFolder) return (null, null);
    return ChinaMobileParsingUtils.parseThumbnails(fileData);
  }

  @override
  String toString() =>
      'ChinaMobileFileListResponse(count: ${files.length}, hasMore: $hasMore)';
}
