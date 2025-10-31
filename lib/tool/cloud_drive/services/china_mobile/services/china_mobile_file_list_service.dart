import '../../../data/models/cloud_drive_entities.dart';
import '../core/china_mobile_base_service.dart';
import '../core/china_mobile_config.dart';
import '../models/china_mobile_models.dart';
import '../utils/china_mobile_logger.dart';

/// 中国移动云盘文件列表服务
///
/// 提供文件列表获取、解析文件元数据等功能。
class ChinaMobileFileListService {
  /// 获取文件列表（使用 DTO）
  ///
  /// [account] 中国移动云盘账号信息
  /// [request] 文件列表请求对象
  static Future<ChinaMobileApiResult<ChinaMobileFileListResponse>>
  getFileListWithDTO({
    required CloudDriveAccount account,
    required ChinaMobileFileListRequest request,
  }) async {
    final startTime = DateTime.now();

    try {
      // 1. 创建Dio实例
      final dio = ChinaMobileBaseService.createDio(account);

      // 2. 构建请求URI
      final url = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('getFileList')}',
      );

      // 3. 发送请求
      ChinaMobileLogger.network('POST', url: url.toString());
      ChinaMobileLogger.debug('请求体', data: request.toRequestBody());

      final response = await dio.postUri(url, data: request.toRequestBody());

      // 4. 使用统一的响应解析器
      final result =
          ChinaMobileResponseParser.parse<ChinaMobileFileListResponse>(
            response: response.data,
            statusCode: response.statusCode,
            dataParser: (data) {
              // 传递完整的响应数据和父文件夹ID
              return ChinaMobileFileListResponse.fromJson(
                response.data as Map<String, dynamic>,
                request.parentFileId,
              );
            },
          );

      // 5. 记录性能指标
      if (result.isSuccess) {
        final duration = DateTime.now().difference(startTime);
        ChinaMobileLogger.performance(
          '获取文件列表完成，共 ${result.data!.files.length} 个文件',
          duration: duration,
        );
      }

      return result;
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('获取文件列表失败', error: e, stackTrace: stackTrace);
      return ChinaMobileApiResult.fromException(e as Exception);
    }
  }

  /// 获取指定文件夹下的文件列表（兼容旧接口）
  ///
  /// @deprecated 建议使用 [getFileListWithDTO]
  static Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? parentFileId,
    int pageSize = 100,
    String? pageCursor,
  }) async {
    ChinaMobileLogger.operationStart(
      '获取文件列表',
      params: {
        'parentFileId': parentFileId ?? 'root',
        'pageSize': pageSize,
        'pageCursor': pageCursor,
      },
    );

    // 使用新的 DTO 方式
    final request = ChinaMobileFileListRequest(
      parentFileId: ChinaMobileConfig.getFolderId(parentFileId),
      pageInfo: PageInfo(pageSize: pageSize, pageCursor: pageCursor),
    );

    final result = await getFileListWithDTO(account: account, request: request);

    if (result.isSuccess && result.data != null) {
      return result.data!.files;
    } else {
      ChinaMobileLogger.error('获取文件列表失败: ${result.errorMessage}');
      throw Exception(result.errorMessage ?? '获取文件列表失败');
    }
  }
}
