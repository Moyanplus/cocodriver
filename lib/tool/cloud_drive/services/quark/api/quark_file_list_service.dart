import '../../../data/models/cloud_drive_entities.dart';
import 'quark_base_service.dart';
import 'quark_config.dart';
import '../models/quark_models.dart';
import '../utils/quark_logger.dart';

/// 夸克云盘文件列表服务
///
/// 提供文件列表获取、解析文件元数据等功能。
class QuarkFileListService {
  /// 获取文件列表（使用 DTO）
  ///
  /// [account] 夸克云盘账号信息
  /// [request] 文件列表请求对象
  static Future<QuarkApiResult<QuarkFileListResponse>> getFileListWithDTO({
    required CloudDriveAccount account,
    required QuarkFileListRequest request,
  }) async {
    final startTime = DateTime.now();

    try {
      // 1. 创建认证的Dio实例
      final dio = await QuarkBaseService.createDioWithAuth(account);

      // 2. 构建请求URI
      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('getFileList')}',
      );
      final uri = url.replace(queryParameters: request.toQueryParameters());

      // 3. 发送请求
      QuarkLogger.network('GET', url: uri.toString());
      final response = await dio.getUri(uri);

      // 4. 使用统一的响应解析器
      final result = QuarkResponseParser.parse<QuarkFileListResponse>(
        response: response.data,
        statusCode: response.statusCode,
        dataParser: (data) {
          // 传递完整的响应数据和父文件夹ID
          return QuarkFileListResponse.fromJson(
            response.data as Map<String, dynamic>,
            request.parentFolderId,
          );
        },
      );

      // 5. 记录性能指标
      if (result.isSuccess) {
        final duration = DateTime.now().difference(startTime);
        QuarkLogger.performance(
          '获取文件列表完成，共 ${result.data!.files.length} 个文件',
          duration: duration,
        );
      }

      return result;
    } catch (e, stackTrace) {
      QuarkLogger.error('获取文件列表失败', error: e, stackTrace: stackTrace);
      return QuarkApiResult.fromException(e as Exception);
    }
  }

  /// 获取指定文件夹下的文件列表（兼容旧接口）
  ///
  /// @deprecated 建议使用 [getFileListWithDTO]
  static Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? parentFileId,
    int page = 1,
    int pageSize = 50,
  }) async {
    QuarkLogger.operationStart(
      '获取文件列表',
      params: {
        'parentFileId': parentFileId ?? 'root',
        'page': page,
        'pageSize': pageSize,
      },
    );

    // 使用新的 DTO 方式
    final request = QuarkFileListRequest(
      parentFolderId: QuarkConfig.getFolderId(parentFileId),
      page: page,
      pageSize: pageSize,
    );

    final result = await getFileListWithDTO(account: account, request: request);

    if (result.isSuccess && result.data != null) {
      return result.data!.files;
    } else {
      QuarkLogger.error('获取文件列表失败: ${result.errorMessage}');
      throw Exception(result.errorMessage ?? '获取文件列表失败');
    }
  }
}
