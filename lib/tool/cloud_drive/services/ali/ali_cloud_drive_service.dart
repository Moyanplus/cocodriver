import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import '../../base/cloud_drive_account_service.dart';
import 'ali_base_service.dart';
import 'ali_config.dart';

/// 阿里云盘服务
/// 处理账号信息、容量信息等核心功能
class AliCloudDriveService {
  /// 获取用户信息
  static Future<CloudDriveAccountInfo?> getUserInfo({
    required CloudDriveAccount account,
  }) async {
    try {
      LogManager().cloudDrive('🔍 开始获取阿里云盘用户信息');

      final dio = AliBaseService.createDio(account);
      final requestBody = AliConfig.buildUserInfoParams();

      final response = await dio.post(
        AliConfig.getApiEndpoint('getUserInfo'),
        data: requestBody,
      );

      if (!AliBaseService.isHttpSuccess(response.statusCode)) {
        LogManager().cloudDrive('❌ HTTP请求失败: ${response.statusCode}');
        return null;
      }

      final responseData = response.data as Map<String, dynamic>;

      if (!AliBaseService.isApiSuccess(responseData)) {
        final errorMsg = AliBaseService.getErrorMessage(responseData);
        LogManager().cloudDrive('❌ API调用失败: $errorMsg');
        return null;
      }

      // 解析用户信息
      final userInfo = CloudDriveAccountInfo(
        username:
            responseData['user_name']?.toString() ??
            responseData['display_name']?.toString() ??
            '未知用户',
        phone: responseData['phone']?.toString(),
        photo: responseData['avatar']?.toString(),
        uk: 0, // 阿里云盘没有uk字段，使用0
        isVip: responseData['vip_identity']?.toString() != 'member',
        isSvip: responseData['vip_identity']?.toString() == 'svip',
        isScanVip: false, // 阿里云盘没有此字段
        loginState: responseData['status']?.toString() == 'enabled' ? 1 : 0,
      );

      LogManager().cloudDrive('✅ 阿里云盘用户信息获取成功: ${userInfo.username}');

      return userInfo;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 获取阿里云盘用户信息异常: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
      return null;
    }
  }

  /// 获取Drive信息（包含drive_id）
  static Future<String?> getDriveId({
    required CloudDriveAccount account,
  }) async {
    try {
      // 优先使用账号中存储的driveId
      if (account.driveId != null && account.driveId!.isNotEmpty) {
        LogManager().cloudDrive(
          '✅ 阿里云盘 - 使用账号中存储的Drive ID: ${account.driveId}',
        );
        return account.driveId;
      }

      LogManager().cloudDrive('🔍 阿里云盘 - 账号中未存储Drive ID，开始获取');

      final dio = AliBaseService.createDio(account);
      final requestBody = AliConfig.buildUserInfoParams();

      final response = await dio.post(
        AliConfig.getApiEndpoint('getUserInfo'),
        data: requestBody,
      );

      if (!AliBaseService.isHttpSuccess(response.statusCode)) {
        LogManager().cloudDrive(
          '❌ 阿里云盘 - 获取Drive信息HTTP错误: ${response.statusCode}',
        );
        return null;
      }

      final responseData = response.data as Map<String, dynamic>;

      if (!AliBaseService.isApiSuccess(responseData)) {
        final errorMsg = AliBaseService.getErrorMessage(responseData);
        LogManager().cloudDrive('❌ 阿里云盘 - 获取Drive信息API调用失败: $errorMsg');
        return null;
      }

      // 从用户信息API响应中获取resource_drive_id
      final driveId = responseData['resource_drive_id'] as String?;

      if (driveId != null) {
        LogManager().cloudDrive('✅ 阿里云盘 - Drive ID获取成功: $driveId');
        // 将获取到的driveId保存到账号中
        await CloudDriveAccountService.saveDriveId(account, driveId);
        return driveId;
      } else {
        LogManager().cloudDrive('⚠️ 阿里云盘 - 响应中未找到resource_drive_id字段');
        return null;
      }
    } catch (e) {
      LogManager().cloudDrive('❌ 阿里云盘 - 获取Drive信息异常: $e');
      return null;
    }
  }

  /// 获取容量信息
  static Future<CloudDriveQuotaInfo?> getQuotaInfo({
    required CloudDriveAccount account,
  }) async {
    try {
      LogManager().cloudDrive('📊 阿里云盘 - 获取容量信息');

      final dio = AliBaseService.createApiDio(account);
      final response = await dio.post(
        AliConfig.getApiEndpoint('getQuotaInfo'),
        data: AliConfig.buildQuotaInfoParams(),
      );

      if (!AliBaseService.isHttpSuccess(response.statusCode)) {
        LogManager().cloudDrive(
          '❌ 阿里云盘 - 获取容量信息HTTP错误: ${response.statusCode}',
        );
        return null;
      }

      final responseData = AliBaseService.getResponseData(response.data);
      if (responseData == null) {
        LogManager().cloudDrive('❌ 阿里云盘 - 容量信息响应数据为空');
        return null;
      }

      // 解析新的API响应格式
      final driveDetails =
          responseData['drive_capacity_details'] as Map<String, dynamic>? ?? {};
      final limitInfo =
          responseData['user_capacity_limit_details']
              as Map<String, dynamic>? ??
          {};

      final totalSize = driveDetails['drive_total_size'] as int? ?? 0;
      final usedSize = driveDetails['drive_used_size'] as int? ?? 0;

      final quotaInfo = CloudDriveQuotaInfo(
        total: totalSize,
        used: usedSize,
        free: totalSize - usedSize,
        expire: limitInfo['limit_consume'] as bool? ?? false,
        serverTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      LogManager().cloudDrive(
        '✅ 阿里云盘 - 容量信息获取成功: 总容量=${AliConfig.formatFileSize(totalSize)}, 已用=${AliConfig.formatFileSize(usedSize)}, 可用=${AliConfig.formatFileSize(totalSize - usedSize)}',
      );

      return quotaInfo;
    } catch (e) {
      LogManager().cloudDrive('❌ 阿里云盘 - 获取容量信息异常: $e');
      return null;
    }
  }

  /// 获取账号详情（用户信息 + 容量信息）
  static Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    try {
      LogManager().cloudDrive('🔍 开始获取阿里云盘账号详情');

      // 并行获取用户信息和容量信息
      final futures = await Future.wait([
        getUserInfo(account: account),
        getQuotaInfo(account: account),
      ]);

      final accountInfo = futures[0] as CloudDriveAccountInfo?;
      final quotaInfo = futures[1] as CloudDriveQuotaInfo?;

      if (accountInfo == null) {
        LogManager().cloudDrive('❌ 用户信息获取失败');
        return null;
      }

      final accountDetails = CloudDriveAccountDetails(
        accountInfo: accountInfo,
        quotaInfo:
            quotaInfo ??
            CloudDriveQuotaInfo(
              total: 0,
              used: 0,
              free: 0,
              expire: false,
              serverTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            ),
      );

      LogManager().cloudDrive('✅ 阿里云盘账号详情获取成功');

      return accountDetails;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 获取阿里云盘账号详情异常: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
      return null;
    }
  }
}
