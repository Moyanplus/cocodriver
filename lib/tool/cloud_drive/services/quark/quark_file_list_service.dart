import '../../../core/services/base/debug_service.dart';
import '../../models/cloud_drive_models.dart';
import 'quark_base_service.dart';
import 'quark_config.dart';

/// 夸克云盘文件列表服务
/// 专门负责文件列表的获取和解析
class QuarkFileListService {
  /// 获取文件列表
  static Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? parentFileId,
    int page = 1,
    int pageSize = 50,
  }) async {
    DebugService.log(
      '📁 夸克云盘 - 获取文件列表开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      final dio = QuarkBaseService.createDio(account);
      final queryParams = _buildFileListParams(parentFileId, page, pageSize);
      final uri = _buildFileListUri(queryParams);

      DebugService.log(
        '🔗 请求URL: $uri',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      final response = await dio.getUri(uri);

      if (!QuarkBaseService.isHttpSuccess(response.statusCode)) {
        throw Exception('获取文件列表失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      if (!QuarkBaseService.isApiSuccess(
        QuarkBaseService.getResponseData(responseData, 'code'),
      )) {
        throw Exception(
          '获取文件列表失败: ${QuarkBaseService.getErrorMessage(responseData)}',
        );
      }

      return _parseFileList(responseData, parentFileId);
    } catch (e) {
      DebugService.log(
        '❌ 夸克云盘 - 获取文件列表异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      rethrow;
    }
  }

  /// 构建文件列表请求参数
  static Map<String, String> _buildFileListParams(
    String? parentFileId,
    int page,
    int pageSize,
  ) => {
    'pr': 'ucpro',
    'fr': 'pc',
    'uc_param_str': '',
    'pdir_fid': QuarkConfig.getFolderId(parentFileId),
    '_page': page.toString(),
    '_size': pageSize.toString(),
    '_fetch_total': '1',
    '_fetch_sub_dirs': '0',
    '_sort': QuarkConfig.getSortOption('fileTypeAsc'),
  };

  /// 构建文件列表请求URI
  static Uri _buildFileListUri(Map<String, String> queryParams) {
    final url = Uri.parse(
      '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('getFileList')}',
    );
    return url.replace(queryParameters: queryParams);
  }

  /// 解析文件列表
  static List<CloudDriveFile> _parseFileList(
    Map<String, dynamic> responseData,
    String? parentFileId,
  ) {
    final fileList = <CloudDriveFile>[];
    final data = responseData[QuarkConfig.responseFields['data']];

    if (data != null && data[QuarkConfig.responseFields['list']] != null) {
      final files = data[QuarkConfig.responseFields['list']] as List<dynamic>;

      for (final fileData in files) {
        final file = _parseFileData(
          fileData,
          QuarkConfig.getFolderId(parentFileId),
        );
        if (file != null) {
          fileList.add(file);
        }
      }
    }

    DebugService.log(
      '✅ 夸克云盘 - 文件列表获取成功，共 ${fileList.length} 个文件',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    return fileList;
  }

  /// 解析单个文件数据
  static CloudDriveFile? _parseFileData(
    Map<String, dynamic> fileData,
    String parentId,
  ) {
    try {
      final fid = fileData[QuarkConfig.responseFields['fid']]?.toString() ?? '';
      final name =
          fileData['file_name']?.toString() ??
          fileData['name']?.toString() ??
          '';
      final size = fileData['size']?.toString() ?? '0';

      final fileTypeRaw = fileData['file_type'];
      final categoryRaw = fileData['category'];
      final isFolder =
          (fileTypeRaw == QuarkConfig.fileTypes['folder'] ||
              fileTypeRaw?.toString() == '0') &&
          (categoryRaw == QuarkConfig.fileTypes['folder'] ||
              categoryRaw?.toString() == '0');

      // 解析时间戳
      DateTime? updatedAt;
      final updateTime =
          fileData['l_updated_at'] ??
          fileData['updated_at'] ??
          fileData['utime'];
      if (updateTime != null) {
        if (updateTime is int) {
          updatedAt = DateTime.fromMillisecondsSinceEpoch(updateTime);
        } else if (updateTime is String) {
          updatedAt = DateTime.tryParse(updateTime);
        }
      }

      // 格式化文件大小
      String formattedSize = '0 B';
      if (!isFolder && size.isNotEmpty && size != '0') {
        final sizeInt = int.tryParse(size) ?? 0;
        if (sizeInt > 0) {
          formattedSize = QuarkConfig.formatFileSize(sizeInt);
        }
      }

      // 格式化时间
      String? formattedTime;
      if (updatedAt != null) {
        formattedTime = QuarkConfig.formatDateTime(updatedAt);
      }

      return CloudDriveFile(
        id: fid,
        name: name,
        size: int.tryParse(formattedSize) ?? 0,
        modifiedTime:
            formattedTime != null ? DateTime.tryParse(formattedTime) : null,
        isFolder: isFolder,
        folderId: parentId,
      );
    } catch (e) {
      DebugService.log(
        '❌ 解析文件数据失败: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return null;
    }
  }
}
