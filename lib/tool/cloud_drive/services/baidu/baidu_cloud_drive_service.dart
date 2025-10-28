import '../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import 'baidu_file_list_service.dart';
import 'baidu_file_operations_service.dart';
import 'baidu_download_service.dart';
import 'baidu_account_service.dart';
import 'baidu_param_service.dart';

/// 百度网盘主服务 - 重构后的简化版本
class BaiduCloudDriveService {
  /// 获取文件列表
  static Future<Map<String, List<CloudDriveFile>>> getFileList({
    required CloudDriveAccount account,
    String folderId = '/',
    int page = 1,
    int pageSize = 50,
  }) async {
    return await BaiduFileListService.getFileList(
      account: account,
      folderId: folderId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 验证Cookie
  static Future<bool> validateCookies(CloudDriveAccount account) async {
    return await BaiduAccountService.validateCookies(account);
  }

  /// 获取下载链接
  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required String fileId,
  }) async {
    return await BaiduDownloadService.getDownloadUrl(
      account: account,
      fileId: fileId,
    );
  }

  /// 创建分享链接
  static Future<String?> createShareLink({
    required CloudDriveAccount account,
    required String fileId,
    String? password,
    int expireTime = 0,
  }) async {
    return await BaiduDownloadService.createShareLink(
      account: account,
      fileId: fileId,
      password: password,
      expireTime: expireTime,
    );
  }

  /// 获取文件详情
  static Future<Map<String, dynamic>?> getFileDetail({
    required CloudDriveAccount account,
    required String fileId,
  }) async {
    return await BaiduDownloadService.getFileDetail(
      account: account,
      fileId: fileId,
    );
  }

  /// 删除文件
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required String fileId,
  }) async {
    return await BaiduFileOperationsService.deleteFile(
      account: account,
      fileId: fileId,
    );
  }

  /// 移动文件
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required String fileId,
    required String targetFolderId,
  }) async {
    return await BaiduFileOperationsService.moveFile(
      account: account,
      fileId: fileId,
      targetFolderId: targetFolderId,
    );
  }

  /// 重命名文件
  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required String fileId,
    required String newName,
  }) async {
    return await BaiduFileOperationsService.renameFile(
      account: account,
      fileId: fileId,
      newName: newName,
    );
  }

  /// 复制文件
  static Future<bool> copyFile({
    required CloudDriveAccount account,
    required String fileId,
    required String targetFolderId,
  }) async {
    return await BaiduFileOperationsService.copyFile(
      account: account,
      fileId: fileId,
      targetFolderId: targetFolderId,
    );
  }

  /// 创建文件夹
  static Future<bool> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    return await BaiduFileOperationsService.createFolder(
      account: account,
      folderName: folderName,
      parentFolderId: parentFolderId,
    );
  }

  /// 获取账号详情
  static Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    return await BaiduAccountService.getAccountDetails(account: account);
  }

  /// 获取用户信息
  static Future<Map<String, dynamic>?> getUserInfo({
    required CloudDriveAccount account,
  }) async {
    return await BaiduAccountService.getUserInfo(account: account);
  }

  /// 获取容量信息
  static Future<Map<String, dynamic>?> getQuotaInfo({
    required CloudDriveAccount account,
  }) async {
    return await BaiduAccountService.getQuotaInfo(account: account);
  }

  /// 获取百度参数
  static Future<Map<String, dynamic>> getBaiduParams({
    required CloudDriveAccount account,
  }) async {
    return await BaiduParamService.getBaiduParams(account);
  }

  /// 清除参数缓存
  static void clearParamCache(String accountId) {
    BaiduParamService.clearParamCache(accountId);
  }

  /// 清除所有参数缓存
  static void clearAllParamCache() {
    BaiduParamService.clearAllParamCache();
  }

  /// 测试完整功能
  static Future<void> testCompleteFunctionality({
    required CloudDriveAccount account,
  }) async {
    LogManager().cloudDrive('🔍 开始测试百度网盘完整功能...');

    try {
      // 测试Cookie验证
      LogManager().cloudDrive('🔍 测试Cookie验证...');
      final isValid = await validateCookies(account);
      if (isValid) {
        LogManager().cloudDrive('✅ Cookie验证成功');
      } else {
        LogManager().cloudDrive('❌ Cookie验证失败');
        return;
      }

      // 测试获取文件列表
      LogManager().cloudDrive('🔍 测试获取文件列表...');
      final fileList = await getFileList(account: account);
      LogManager().cloudDrive(
        '✅ 文件列表获取成功: ${fileList['files']?.length ?? 0}个文件, ${fileList['folders']?.length ?? 0}个文件夹',
      );

      // 测试获取账号详情
      LogManager().cloudDrive('🔍 测试获取账号详情...');
      final accountDetails = await getAccountDetails(account: account);
      if (accountDetails != null) {
        LogManager().cloudDrive('✅ 账号详情获取成功');
        LogManager().cloudDrive(
          '📊 详细信息: 用户=${accountDetails.accountInfo?.username ?? '未知用户'}, 存储=${accountDetails.quotaInfo?.usagePercentage.toStringAsFixed(1) ?? '0.0'}%',
        );
      } else {
        LogManager().cloudDrive('❌ 账号详情获取失败');
      }

      LogManager().cloudDrive('✅ 百度网盘完整功能测试完成');
    } catch (e) {
      LogManager().error('❌ 百度网盘功能测试失败: $e');
    }
  }
}
