import 'package:dio/dio.dart';

import '../../../../data/models/cloud_drive_dtos.dart';
import '../../../../data/models/cloud_drive_entities.dart';
import '../api/quark_auth_service.dart';
import '../api/quark_base_service.dart';
import '../api/quark_config.dart';
import '../models/quark_models.dart';
import '../utils/quark_logger.dart';

/// 夸克云盘账号服务
///
/// 负责账号信息、容量信息、会员信息查询等功能。
class QuarkAccountService {
  /// 获取账号个人信息（使用 DTO）
  static Future<QuarkApiResult<QuarkAccountInfoResponse>>
  getAccountInfoWithDTO({required CloudDriveAccount account}) async {
    try {
      // 1. 创建认证的Dio实例（用于pan.quark.cn）
      final authHeaders = await QuarkAuthService.buildAuthHeaders(account);
      final dio = Dio(
        BaseOptions(
          baseUrl: QuarkConfig.panUrl,
          connectTimeout: QuarkConfig.connectTimeout,
          receiveTimeout: QuarkConfig.receiveTimeout,
          headers: authHeaders,
        ),
      );

      // 2. 构建请求
      final request = QuarkAccountInfoRequest();
      final endpoint = QuarkConfig.getPanApiEndpoint('getAccountInfo');

      QuarkLogger.network(
        'GET',
        url: '$endpoint?${request.toQueryParameters()}',
      );

      // 3. 发送请求
      final response = await dio.get(
        endpoint,
        queryParameters: request.toQueryParameters(),
      );

      // 4. 检查响应（pan.quark.cn 使用不同的响应格式）
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] == true && responseData['code'] == 200) {
        final data = responseData['data'] as Map<String, dynamic>;
        final accountInfo = QuarkAccountInfoResponse.fromJson(data);

        QuarkLogger.success('账号个人信息获取成功 - 用户: ${accountInfo.nickname}');

        return QuarkApiResult.success(accountInfo, rawResponse: response.data);
      } else {
        return QuarkApiResult.failure(
          message: responseData['message']?.toString() ?? '获取账号信息失败',
          code: responseData['code']?.toString(),
          statusCode: response.statusCode,
          rawResponse: response.data,
        );
      }
    } catch (e, stackTrace) {
      QuarkLogger.error('获取账号个人信息失败', error: e, stackTrace: stackTrace);
      return QuarkApiResult.fromException(e as Exception);
    }
  }

  /// 获取账号容量信息（使用 DTO）
  static Future<QuarkApiResult<QuarkMemberInfoResponse>> getMemberInfoWithDTO({
    required CloudDriveAccount account,
  }) async {
    try {
      // 1. 创建认证的Dio实例
      final dio = await QuarkBaseService.createDioWithAuth(account);

      // 2. 构建请求
      final request = QuarkMemberInfoRequest();
      final endpoint = QuarkConfig.getApiEndpoint('getMember');

      QuarkLogger.network(
        'GET',
        url: '$endpoint?${request.toQueryParameters()}',
      );

      // 3. 发送请求
      final response = await dio.get(
        endpoint,
        queryParameters: request.toQueryParameters(),
      );

      // 4. 使用统一的响应解析器
      return QuarkResponseParser.parse<QuarkMemberInfoResponse>(
        response: response.data,
        statusCode: response.statusCode,
        dataParser: (data) {
          final memberInfo = QuarkMemberInfoResponse.fromJson(data);
          QuarkLogger.success(
            '账号容量信息获取成功 - '
            '已用: ${memberInfo.useCapacityGB.toStringAsFixed(2)} GB / '
            '${memberInfo.totalCapacityGB.toStringAsFixed(2)} GB',
          );
          return memberInfo;
        },
      );
    } catch (e, stackTrace) {
      QuarkLogger.error('获取账号容量信息失败', error: e, stackTrace: stackTrace);
      return QuarkApiResult.fromException(e as Exception);
    }
  }

  /// 获取账号个人信息（兼容旧接口）
  ///
  /// @deprecated 建议使用 [getAccountInfoWithDTO]
  static Future<CloudDriveAccountInfo?> getAccountInfo({
    required CloudDriveAccount account,
  }) async {
    QuarkLogger.operationStart('获取账号个人信息');

    final result = await getAccountInfoWithDTO(account: account);

    if (result.isSuccess && result.data != null) {
      final response = result.data!;
      final accountInfo = CloudDriveAccountInfo(
        username: response.nickname,
        phone: response.mobile != null ? '已绑定' : null,
        photo: response.avatarUri,
        uk: QuarkConfig.defaultValues['quarkUk'] as int,
      );

      QuarkLogger.success('账号个人信息获取成功 - 用户: ${accountInfo.username}');
      return accountInfo;
    } else {
      QuarkLogger.error('获取账号个人信息失败: ${result.errorMessage}');
      return null;
    }
  }

  /// 获取账号容量信息（兼容旧接口）
  ///
  /// @deprecated 建议使用 [getMemberInfoWithDTO]
  static Future<CloudDriveQuotaInfo?> getMemberInfo({
    required CloudDriveAccount account,
  }) async {
    QuarkLogger.operationStart('获取账号容量信息');

    final result = await getMemberInfoWithDTO(account: account);

    if (result.isSuccess && result.data != null) {
      final response = result.data!;
      final quotaInfo = CloudDriveQuotaInfo(
        total: response.totalCapacity,
        used: response.useCapacity,
        serverTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      return quotaInfo;
    } else {
      QuarkLogger.error('获取账号容量信息失败: ${result.errorMessage}');
      return null;
    }
  }

  /// 获取完整账号详情（并发获取个人信息、容量信息、会员信息）
  static Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    QuarkLogger.operationStart(
      '获取完整账号详情',
      params: {
        'accountName': account.name,
        'accountType': account.type.displayName,
      },
    );

    try {
      // 1. 并发获取用户信息和容量信息
      final results = await Future.wait([
        getAccountInfoWithDTO(account: account),
        getMemberInfoWithDTO(account: account),
      ]);

      final accountInfoResult =
          results[0] as QuarkApiResult<QuarkAccountInfoResponse>;
      final memberInfoResult =
          results[1] as QuarkApiResult<QuarkMemberInfoResponse>;

      // 2. 检查是否成功获取两个信息
      if (!accountInfoResult.isSuccess || !memberInfoResult.isSuccess) {
        QuarkLogger.error(
          '获取账号详情失败 - '
          '用户信息=${accountInfoResult.isSuccess ? '成功' : '失败'}, '
          '容量信息=${memberInfoResult.isSuccess ? '成功' : '失败'}',
        );
        return null;
      }

      final accountInfo = accountInfoResult.data!;
      final memberInfo = memberInfoResult.data!;

      // 3. 构建完整账号详情对象
      final quotaInfo = CloudDriveQuotaInfo(
        total: memberInfo.totalCapacity,
        used: memberInfo.useCapacity,
        serverTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      final details = CloudDriveAccountDetails(
        id: (QuarkConfig.defaultValues['quarkUk'] as int).toString(),
        name: accountInfo.nickname,
        avatarUrl: accountInfo.avatarUri,
        totalSpace: memberInfo.totalCapacity,
        usedSpace: memberInfo.useCapacity,
        freeSpace: memberInfo.freeCapacity,
        isValid: true,
        accountInfo: CloudDriveAccountInfo(
          username: accountInfo.nickname,
          phone: accountInfo.mobile != null ? '已绑定' : null,
          photo: accountInfo.avatarUri,
          uk: QuarkConfig.defaultValues['quarkUk'] as int,
        ),
        quotaInfo: quotaInfo,
      );

      QuarkLogger.success(
        '完整账号详情获取成功 - ${memberInfo.vipTypeDesc} ${memberInfo.memberLevelDesc ?? ''} ${memberInfo.vipStatusDesc ?? ''}',
      );

      return details;
    } catch (e, stackTrace) {
      QuarkLogger.error('获取完整账号详情失败', error: e, stackTrace: stackTrace);
      return null;
    }
  }
}
