import '../../../data/models/cloud_drive_entities.dart';
import '../core/china_mobile_base_service.dart';
import '../core/china_mobile_config.dart';
import '../models/china_mobile_models.dart';
import '../utils/china_mobile_logger.dart';

/// 中国移动云盘分享服务
///
/// 提供创建分享链接等功能。
class ChinaMobileShareService {
  /// 创建分享链接（使用 DTO）
  ///
  /// [account] 中国移动云盘账号信息
  /// [request] 分享请求对象
  static Future<ChinaMobileApiResult<Map<String, dynamic>>> createShareLink({
    required CloudDriveAccount account,
    required ChinaMobileShareRequest request,
  }) async {
    final startTime = DateTime.now();

    try {
      // 1. 创建编排服务Dio实例
      final dio = ChinaMobileBaseService.createOrchestrationDio(account);

      // 2. 构建请求URI
      final url = Uri.parse(
        '${ChinaMobileConfig.orchestrationUrl}${ChinaMobileConfig.getApiEndpoint('getShareLink')}',
      );

      // 3. 发送请求
      ChinaMobileLogger.network('POST', url: url.toString());
      ChinaMobileLogger.debug('请求体', data: request.toRequestBody());

      final response = await dio.postUri(url, data: request.toRequestBody());

      // 4. 解析响应
      if (ChinaMobileBaseService.isHttpSuccess(response.statusCode) &&
          ChinaMobileBaseService.isApiSuccess(response.data)) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        final duration = DateTime.now().difference(startTime);
        ChinaMobileLogger.performance('创建分享链接完成', duration: duration);
        return ChinaMobileApiResult.success(data);
      } else {
        final errorMsg = ChinaMobileBaseService.getErrorMessage(
          response.data ?? {},
        );
        return ChinaMobileApiResult.failure(errorMsg);
      }
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('创建分享链接失败', error: e, stackTrace: stackTrace);
      return ChinaMobileApiResult.fromException(e as Exception);
    }
  }

  /// 创建分享链接（兼容旧接口）
  ///
  /// [account] 中国移动云盘账号信息
  /// [files] 文件列表
  /// [accountNumber] 账号号码
  /// @deprecated 建议使用 [createShareLink] with DTO
  static Future<String?> getShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    required String accountNumber,
  }) async {
    ChinaMobileLogger.operationStart(
      '获取分享链接',
      params: {'fileCount': files.length, 'accountNumber': accountNumber},
    );

    if (files.isEmpty) {
      ChinaMobileLogger.error('文件列表为空');
      return null;
    }

    final fileIds = files.map((f) => f.id).toList();
    final fileName = files.length == 1 ? files.first.name : '批量文件';

    final request = ChinaMobileShareRequest(
      getOutLinkReq: ShareRequestBody(
        subLinkType: 0,
        encrypt: 1,
        coIDLst: fileIds,
        caIDLst: [],
        pubType: 1,
        dedicatedName: fileName,
        periodUnit: 1,
        viewerLst: [],
        extInfo: ShareExtInfo(isWatermark: 0, shareChannel: '3001'),
        commonAccountInfo: CommonAccountInfo(
          account: accountNumber,
          accountType: 1,
        ),
      ),
    );

    final result = await createShareLink(account: account, request: request);

    if (result.isSuccess && result.data != null) {
      // 根据实际API响应解析分享链接
      final shareUrl = result.data!['shareUrl'] as String?;
      return shareUrl;
    } else {
      ChinaMobileLogger.error('获取分享链接失败: ${result.errorMessage}');
      return null;
    }
  }
}
