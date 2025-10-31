import '../../../data/models/cloud_drive_entities.dart';
import '../core/china_mobile_base_service.dart';
import '../core/china_mobile_config.dart';
import '../models/china_mobile_models.dart';
import '../utils/china_mobile_logger.dart';

/// 中国移动云盘搜索服务
///
/// 提供搜索文件等功能。
class ChinaMobileSearchService {
  /// 搜索文件（使用 DTO）
  ///
  /// [account] 中国移动云盘账号信息
  /// [request] 搜索请求对象
  static Future<ChinaMobileApiResult<List<CloudDriveFile>>> searchFiles({
    required CloudDriveAccount account,
    required ChinaMobileSearchRequest request,
  }) async {
    final startTime = DateTime.now();

    try {
      final dio = ChinaMobileBaseService.createDio(account);
      final uri = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('searchFile')}',
      );

      ChinaMobileLogger.operationStart(
        '搜索文件',
        params: {'keyword': request.conditions.keyword},
      );

      ChinaMobileLogger.network('POST', url: uri.toString());
      ChinaMobileLogger.debug('请求体', data: request.toRequestBody());

      final response = await dio.postUri(uri, data: request.toRequestBody());

      if (ChinaMobileBaseService.isHttpSuccess(response.statusCode) &&
          ChinaMobileBaseService.isApiSuccess(response.data)) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        final fileList = _parseSearchResults(data, account.id);

        final duration = DateTime.now().difference(startTime);
        ChinaMobileLogger.performance(
          '搜索文件完成，共 ${fileList.length} 个结果',
          duration: duration,
        );

        return ChinaMobileApiResult.success(fileList);
      } else {
        final errorMsg = ChinaMobileBaseService.getErrorMessage(
          response.data ?? {},
        );
        return ChinaMobileApiResult.failure(errorMsg);
      }
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('搜索文件失败', error: e, stackTrace: stackTrace);
      return ChinaMobileApiResult.fromException(e as Exception);
    }
  }

  /// 解析搜索结果
  static List<CloudDriveFile> _parseSearchResults(
    Map<String, dynamic> data,
    String accountId,
  ) {
    final fileList = <CloudDriveFile>[];
    final items = data['items'] as List<dynamic>? ?? [];

    for (final itemData in items) {
      if (itemData is Map<String, dynamic>) {
        try {
          final file = _parseFileData(itemData);
          if (file != null) {
            fileList.add(file);
          }
        } catch (e) {
          ChinaMobileLogger.warning('解析搜索结果项失败: $e');
        }
      }
    }

    return fileList;
  }

  /// 解析单个文件数据
  static CloudDriveFile? _parseFileData(Map<String, dynamic> fileData) {
    try {
      final fileId = fileData['fileId']?.toString() ?? '';
      final name = fileData['name']?.toString() ?? '';
      final size = fileData['size']?.toString() ?? '0';
      final isFolder = fileData['isFolder'] as bool? ?? false;

      DateTime? updatedAt;
      final updateTime = fileData['updatedAt'];
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
      ChinaMobileLogger.warning('解析文件数据失败: $e');
      return null;
    }
  }

  /// 搜索文件（兼容旧接口）
  ///
  /// [account] 中国移动云盘账号信息
  /// [keyword] 搜索关键字
  /// [owner] 所有者（可选）
  /// [parentFileId] 父文件夹ID（可选）
  /// @deprecated 建议使用 [searchFiles] with DTO
  static Future<List<CloudDriveFile>> searchFile({
    required CloudDriveAccount account,
    required String keyword,
    String? owner,
    String? parentFileId,
  }) async {
    final request = ChinaMobileSearchRequest(
      conditions: SearchConditions(
        type: 0,
        keyword: keyword,
        owner: owner,
        fullFileIdPath: parentFileId,
      ),
      showInfo: ShowInfo(returnTotalCountFlag: true, startNum: 1, stopNum: 100),
    );

    final result = await searchFiles(account: account, request: request);

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      ChinaMobileLogger.error('搜索文件失败: ${result.errorMessage}');
      return [];
    }
  }
}
