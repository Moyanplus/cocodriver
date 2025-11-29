import '../../../../../data/models/cloud_drive_entities.dart';
import 'china_mobile_base_response.dart';
import 'parsing_utils.dart';

/// 中国移动云盘搜索响应
class ChinaMobileSearchResponse {
  /// 搜索结果文件列表
  final List<CloudDriveFile> files;

  /// 总文件数
  final int? totalCount;

  /// 起始编号
  final int? startNum;

  /// 结束编号
  final int? stopNum;

  /// 是否有更多结果
  final bool hasMore;

  /// 其他数据
  final Map<String, dynamic>? extraData;

  const ChinaMobileSearchResponse({
    required this.files,
    this.totalCount,
    this.startNum,
    this.stopNum,
    this.hasMore = false,
    this.extraData,
  });

  /// 从API响应解析
  ///
  /// [json] API响应数据
  /// [accountId] 账号ID，用于文件对象创建
  factory ChinaMobileSearchResponse.fromJson(
    Map<String, dynamic> json,
    String accountId,
  ) {
    final fileList = <CloudDriveFile>[];
    final base = ChinaMobileBaseResponse.fromJson(json);
    final data = base.data ?? json;

    // 解析文件列表
    final items =
        data['items'] as List<dynamic>? ??
        data['list'] as List<dynamic>? ??
        data['files'] as List<dynamic>? ??
        [];

    for (final itemData in items) {
      if (itemData is Map<String, dynamic>) {
        try {
          final file = _parseFileData(itemData);
          if (file != null) {
            fileList.add(file);
          }
        } catch (e) {
          // 跳过解析失败的项目
        }
      }
    }

    // 解析分页信息
    final totalCount =
        data['totalCount'] as int? ?? data['total_count'] as int?;
    final startNum = data['startNum'] as int? ?? data['start_num'] as int?;
    final stopNum = data['stopNum'] as int? ?? data['stop_num'] as int?;
    final hasMore =
        data['hasMore'] as bool? ??
        (stopNum != null && totalCount != null && stopNum < totalCount);

    return ChinaMobileSearchResponse(
      files: fileList,
      totalCount: totalCount,
      startNum: startNum,
      stopNum: stopNum,
      hasMore: hasMore,
      extraData: data.isNotEmpty ? data : null,
    );
  }

  /// 解析单个文件数据
  static CloudDriveFile? _parseFileData(Map<String, dynamic> fileData) {
    try {
      final fileId = fileData['fileId']?.toString() ?? '';
      final name =
          fileData['name']?.toString() ??
          fileData['fileName']?.toString() ??
          '';
      final size = fileData['size']?.toString() ?? '0';
      final isFolder =
          fileData['isFolder'] as bool? ??
          fileData['type']?.toString() == 'folder';

      final updatedAt =
          ChinaMobileParsingUtils.parseDate(fileData['updatedAt'] ?? fileData['updated_at']);

      int? sizeBytes;
      if (!isFolder && size.isNotEmpty && size != '0') {
        sizeBytes = int.tryParse(size);
      }

      return CloudDriveFile(
        id: fileId,
        name: name,
        size: sizeBytes,
        modifiedTime: updatedAt,
        isFolder: isFolder,
        folderId: fileData['parentFileId']?.toString() ?? '/',
      );
    } catch (e) {
      return null;
    }
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'files':
        files
            .map(
              (f) => {
                'id': f.id,
                'name': f.name,
                'size': f.size,
                'isFolder': f.isFolder,
              },
            )
            .toList(),
    if (totalCount != null) 'totalCount': totalCount,
    if (startNum != null) 'startNum': startNum,
    if (stopNum != null) 'stopNum': stopNum,
    'hasMore': hasMore,
    if (extraData != null) ...extraData!,
  };

  @override
  String toString() =>
      'ChinaMobileSearchResponse('
      'count: ${files.length}, '
      'totalCount: $totalCount, '
      'hasMore: $hasMore)';
}
