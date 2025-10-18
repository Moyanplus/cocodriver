import '../../../core/services/base/debug_service.dart';
import '../../models/cloud_drive_models.dart';
import 'ali_base_service.dart';
import 'ali_config.dart';

/// 阿里云盘文件列表服务
/// 专门处理文件列表获取和解析
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
      DebugService.log(
        '📁 阿里云盘 - 获取文件列表: driveId=$driveId, parentFileId=$parentFileId, limit=$limit',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
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

      DebugService.log(
        '🌐 阿里云盘 - 请求URL: $uri',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );

      DebugService.log(
        '📤 阿里云盘 - 请求体: $requestBody',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );

      final response = await dio.postUri(uri, data: requestBody);

      if (!AliBaseService.isHttpSuccess(response.statusCode)) {
        DebugService.log(
          '❌ 阿里云盘 - 获取文件列表HTTP错误: ${response.statusCode}',
          category: DebugCategory.tools,
          subCategory: AliConfig.logSubCategory,
        );
        return [];
      }

      final responseData = AliBaseService.getResponseData(response.data);
      if (responseData == null) {
        DebugService.log(
          '❌ 阿里云盘 - 文件列表响应数据为空',
          category: DebugCategory.tools,
          subCategory: AliConfig.logSubCategory,
        );
        return [];
      }

      final items = responseData['items'] as List<dynamic>? ?? [];
      final nextMarker = responseData['next_marker'] as String?;

      DebugService.log(
        '📋 阿里云盘 - 解析到 ${items.length} 个文件项, next_marker: $nextMarker',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
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

      DebugService.log(
        '✅ 阿里云盘 - 文件列表获取成功: ${files.length} 个文件',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );

      return files;
    } catch (e) {
      DebugService.log(
        '❌ 阿里云盘 - 获取文件列表异常: $e',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );
      return [];
    }
  }

  /// 解析文件数据
  static CloudDriveFile? _parseFileData(Map<String, dynamic> data) {
    try {
      final fileId = data['file_id'] as String?;
      final name = data['name'] as String?;

      if (fileId == null || name == null) {
        DebugService.log(
          '⚠️ 阿里云盘 - 文件数据缺少必要字段: file_id=$fileId, name=$name',
          category: DebugCategory.tools,
          subCategory: AliConfig.logSubCategory,
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
          DebugService.log(
            '⚠️ 阿里云盘 - 时间解析失败: $updatedAt, $e',
            category: DebugCategory.tools,
            subCategory: AliConfig.logSubCategory,
          );
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
      DebugService.log(
        '❌ 阿里云盘 - 解析文件数据异常: $e',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );
      return null;
    }
  }
}
