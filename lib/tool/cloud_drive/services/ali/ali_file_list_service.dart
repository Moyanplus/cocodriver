import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import 'ali_base_service.dart';
import 'ali_config.dart';

/// 阿里云盘文件列表服务
///
/// 专门处理文件列表获取和解析。
class AliFileListService {
  /// 获取文件列表
  static Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    required String driveId,
    String? parentFileId,
    int limit = 20,
    String? marker,
  }) async {
    try {
      LogManager().cloudDrive(
        '阿里云盘 - 获取文件列表: driveId=$driveId, parentFileId=$parentFileId, limit=$limit',
      );

      final dio = AliBaseService.createApiDio(account);

      // 构建完整的URL，包含查询参数
      final endpoint = AliConfig.getApiEndpoint('getFileList');
      final queryParams = AliConfig.buildFileListQueryParams();
      final uri = Uri.parse(
        dio.options.baseUrl + endpoint,
      ).replace(queryParameters: queryParams);

      final requestBody = AliConfig.buildFileListParams(
        driveId: driveId,
        parentFileId: parentFileId,
        limit: limit,
        marker: marker,
      );

      LogManager().cloudDrive('阿里云盘 - 请求URL: $uri');

      LogManager().cloudDrive('阿里云盘 - 请求体: $requestBody');

      final response = await dio.postUri(uri, data: requestBody);

      if (!AliBaseService.isHttpSuccess(response.statusCode)) {
        LogManager().cloudDrive('阿里云盘 - 获取文件列表HTTP错误: ${response.statusCode}');
        return [];
      }

      final responseData = AliBaseService.getResponseData(response.data);
      if (responseData == null) {
        LogManager().cloudDrive('阿里云盘 - 文件列表响应数据为空');
        return [];
      }

      final items = responseData['items'] as List<dynamic>? ?? [];
      final nextMarker = responseData['next_marker'] as String?;

      LogManager().cloudDrive(
        '阿里云盘 - 解析到 ${items.length} 个文件项, next_marker: $nextMarker',
      );

      final files = <CloudDriveFile>[];
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final file = _parseFileData(item);
          if (file != null) {
            files.add(file);
          }
        }
      }

      LogManager().cloudDrive('阿里云盘 - 文件列表获取成功: ${files.length} 个文件');

      return files;
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 获取文件列表异常: $e');
      return [];
    }
  }

  /// 解析文件数据
  static CloudDriveFile? _parseFileData(Map<String, dynamic> data) {
    try {
      final fileId = data['file_id'] as String?;
      final name = data['name'] as String?;

      if (fileId == null || name == null) {
        LogManager().cloudDrive(
          '阿里云盘 - 文件数据缺少必要字段: file_id=$fileId, name=$name',
        );
        return null;
      }

      final type = data['type'] as String? ?? 'file';
      final isFolder = type == 'folder';
      final size = data['size'] as int?;
      final updatedAt = data['updated_at'] as String?;
      final parentFileId = data['parent_file_id'] as String?;

      // 解析时间
      String? formattedTime;
      if (updatedAt != null) {
        try {
          final dateTime = DateTime.parse(updatedAt);
          formattedTime = AliConfig.formatTimestamp(
            dateTime.millisecondsSinceEpoch,
          );
        } catch (e) {
          LogManager().cloudDrive('阿里云盘 - 时间解析失败: $updatedAt, $e');
        }
      }

      final file = CloudDriveFile(
        id: fileId,
        name: name,
        size: size,
        modifiedTime:
            formattedTime != null ? DateTime.tryParse(formattedTime) : null,
        isFolder: isFolder,
        folderId: parentFileId,
      );

      return file;
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 解析文件数据异常: $e');
      return null;
    }
  }
}
