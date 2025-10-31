import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../data/models/cloud_drive_entities.dart';
import '../core/quark_base_service.dart';
import '../core/quark_config.dart';
import '../models/quark_models.dart';
import '../utils/quark_logger.dart';

/// 夸克云盘分享服务
///
/// 提供创建分享链接、查询分享信息等功能。
class QuarkShareService {
  /// 创建分享链接
  ///
  /// [account] 夸克云盘账号信息
  /// [request] 分享请求对象
  static Future<QuarkApiResult<QuarkShareResponse>> createShareLink({
    required CloudDriveAccount account,
    required QuarkShareRequest request,
  }) async {
    QuarkLogger.operationStart(
      '创建分享链接',
      params: {
        'fileCount': request.fileIds.length,
        'title': request.title ?? '分享文件',
        'hasPasscode': request.passcode != null,
        'expiredType': request.expiredType.name,
      },
    );

    try {
      // 1. 创建认证的Dio实例
      final dio = await QuarkBaseService.createDioWithAuth(account);

      // 2. 构建请求URL
      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('createShare')}',
      );

      // 3. 使用 DTO 的 toRequestBody() 方法
      final requestBody = request.toRequestBody();
      QuarkLogger.debug('请求体', data: requestBody);

      // 4. 发送请求（使用 plain 类型，但明确设置 Content-Type 为 application/json）
      final response = await dio.postUri(
        url,
        data: requestBody,
        options: Options(
          responseType: ResponseType.plain,
          contentType: 'application/json',
        ),
      );

      // 5. 手动解析 JSON 响应
      Map<String, dynamic> responseData;
      try {
        final responseText = response.data as String;
        QuarkLogger.debug('响应文本长度: ${responseText.length}');
        responseData = json.decode(responseText) as Map<String, dynamic>;
      } catch (e) {
        QuarkLogger.error('JSON解析失败', error: e);
        final responseText = response.data as String;
        final preview =
            responseText.length > 100
                ? responseText.substring(0, 100)
                : responseText;
        QuarkLogger.debug('响应内容预览: $preview');
        return QuarkApiResult.failure(
          message: '响应解析失败: $e',
          code: 'PARSE_ERROR',
        );
      }

      // 6. 使用统一的响应解析器
      return QuarkResponseParser.parse<QuarkShareResponse>(
        response: responseData,
        statusCode: response.statusCode,
        dataParser: (data) {
          final taskResp = data['task_resp'];
          final taskData = taskResp['data'];
          final shareId = taskData['share_id'];
          final shareUrl = QuarkConfig.buildShareUrl(shareId);

          QuarkLogger.success('创建分享链接成功');
          QuarkLogger.share('分享链接已创建', url: shareUrl);

          // 使用 DTO 的 fromJson 工厂方法
          return QuarkShareResponse.fromJson(taskData, shareUrl);
        },
      );
    } catch (e, stackTrace) {
      QuarkLogger.error('创建分享链接失败', error: e, stackTrace: stackTrace);
      return QuarkApiResult.fromException(e as Exception);
    }
  }

  /// 创建分享链接（兼容旧接口）
  ///
  /// @deprecated 建议使用 [createShareLink] 并传入 [QuarkShareRequest]
  @Deprecated('使用 createShareLink(account, request) 代替')
  static Future<Map<String, dynamic>?> createShareLinkLegacy({
    required CloudDriveAccount account,
    required List<String> fileIds,
    String? title,
    String? passcode,
    int expiredType = 1,
  }) async {
    // 转换为新的请求方式
    final request = QuarkShareRequest(
      fileIds: fileIds,
      title: title,
      passcode: passcode,
      expiredType: _convertExpiredType(expiredType),
    );

    final result = await createShareLink(account: account, request: request);

    // 转换回旧的返回格式
    if (result.isSuccess && result.data != null) {
      final response = result.data!;
      return {
        'success': true,
        'share_id': response.shareId,
        'event_id': response.eventId,
        'share_url': response.shareUrl,
        'passcode': response.passcode,
        'expired_type': response.expiredType,
        'title': response.title,
        'status': response.status,
      };
    } else {
      throw Exception(result.errorMessage ?? '创建分享失败');
    }
  }

  /// 转换过期类型
  static ShareExpiredType _convertExpiredType(int type) {
    switch (type) {
      case 2:
        return ShareExpiredType.oneDay;
      case 3:
        return ShareExpiredType.sevenDays;
      case 4:
        return ShareExpiredType.thirtyDays;
      default:
        return ShareExpiredType.permanent;
    }
  }

  /// 根据分享ID查询分享信息
  static Future<Map<String, dynamic>?> getShareInfo({
    required CloudDriveAccount account,
    required String shareId,
  }) async {
    QuarkLogger.operationStart('获取分享信息', params: {'shareId': shareId});

    try {
      // 1. 创建认证的Dio实例
      final dio = await QuarkBaseService.createDioWithAuth(account);

      // 2. 构建请求URL和参数
      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('getShareInfo')}',
      );
      final queryParams = {
        'pr': 'ucpro',
        'fr': 'pc',
        'uc_param_str': '',
        'share_id': shareId,
      };

      // 3. 发送请求
      final uri = url.replace(queryParameters: queryParams);
      QuarkLogger.network('GET', url: uri.toString());

      final response = await dio.getUri(uri);

      // 4. 检查HTTP状态码
      if (response.statusCode != 200) {
        throw Exception('HTTP请求失败，状态码: ${response.statusCode}');
      }

      // 5. 检查API响应码
      final responseData = response.data;
      if (responseData['code'] != 0) {
        final message = responseData['message'];
        throw Exception('API返回错误: $message');
      }

      // 6. 返回分享数据
      final shareData = responseData['data'];
      QuarkLogger.success('获取分享信息成功');

      return shareData;
    } catch (e, stackTrace) {
      QuarkLogger.error('获取分享信息失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
