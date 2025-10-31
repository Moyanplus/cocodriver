import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import '../../base/cloud_drive_operation_service.dart';
import 'lanzou_cloud_drive_service.dart';
// import 'lanzou_config.dart'; // 未使用

/// 蓝奏云操作策略
///
/// 实现 CloudDriveOperationStrategy 接口，提供蓝奏云特定的操作实现。
class LanzouCloudDriveOperationStrategy implements CloudDriveOperationStrategy {
  @override
  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    LogManager().cloudDrive('蓝奏云 - 获取下载链接开始');
    LogManager().cloudDrive('蓝奏云 - 文件信息: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive(
      '蓝奏云 - 账号信息: ${account.name} (${account.type.displayName})',
    );

    try {
      // 蓝奏云暂不支持API下载，返回null
      LogManager().cloudDrive('蓝奏云 - 暂不支持API下载，需要用户手动操作');
      return null;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('蓝奏云 - 获取下载链接异常: $e');
      LogManager().cloudDrive('蓝奏云 - 错误堆栈: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    LogManager().cloudDrive('蓝奏云 - 高速下载功能暂不支持');
    LogManager().cloudDrive('蓝奏云 - 文件: ${file.name}');
    LogManager().cloudDrive('蓝奏云 - 分享链接: $shareUrl');
    return null;
  }

  @override
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    LogManager().cloudDrive('蓝奏云 - 创建分享链接开始');
    LogManager().cloudDrive('蓝奏云 - 文件数量: ${files.length}');
    LogManager().cloudDrive('蓝奏云 - 密码: ${password ?? '无'}');
    LogManager().cloudDrive('蓝奏云 - 过期天数: ${expireDays ?? '永久'}');

    try {
      // TODO: 实现蓝奏云分享链接生成
      LogManager().cloudDrive('蓝奏云 - 分享链接生成功能暂未实现');
      return null;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('蓝奏云 - 创建分享链接异常: $e');
      LogManager().cloudDrive('蓝奏云 - 错误堆栈: $stackTrace');
      return null;
    }
  }

  @override
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    LogManager().cloudDrive('蓝奏云 - 开始移动文件');
    LogManager().cloudDrive('蓝奏云 - 文件: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive('蓝奏云 - 目标文件夹ID: ${targetFolderId ?? '-1'}');
    LogManager().cloudDrive('蓝奏云 - 账号: ${account.name}');

    try {
      // 调用蓝奏云服务的移动文件方法
      final success = await LanzouCloudDriveService.moveFile(
        account: account,
        file: file,
        targetFolderId: targetFolderId,
      );

      if (success) {
        LogManager().cloudDrive('蓝奏云 - 文件移动成功');
      } else {
        LogManager().cloudDrive('蓝奏云 - 文件移动失败');
      }

      return success;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('蓝奏云 - 移动文件异常: $e');
      LogManager().cloudDrive('蓝奏云 - 错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    LogManager().cloudDrive('蓝奏云 - 删除文件开始');
    LogManager().cloudDrive('蓝奏云 - 文件: ${file.name} (ID: ${file.id})');

    try {
      // TODO: 实现蓝奏云文件删除
      LogManager().cloudDrive('蓝奏云 - 文件删除功能暂未实现');
      return false;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('蓝奏云 - 删除文件异常: $e');
      LogManager().cloudDrive('蓝奏云 - 错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    LogManager().cloudDrive('蓝奏云 - 重命名文件开始');
    LogManager().cloudDrive('�� 蓝奏云 - 原文件名: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive('蓝奏云 - 新文件名: $newName');

    try {
      // TODO: 实现蓝奏云文件重命名
      LogManager().cloudDrive('蓝奏云 - 文件重命名功能暂未实现');
      return false;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('蓝奏云 - 重命名文件异常: $e');
      LogManager().cloudDrive('蓝奏云 - 错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  Map<String, bool> getSupportedOperations() => {
    'download': false, // 蓝奏云暂不支持API下载
    'share': true, // 支持分享
    'copy': true, // 支持复制
    'move': true, // 支持移动
    'delete': false, // 暂不支持删除
    'rename': false, // 暂不支持重命名
    'createFolder': false, // 暂不支持创建文件夹
  };

  @override
  Map<String, dynamic> getOperationUIConfig() => {
    'share_password_hint': '蓝奏云暂不支持API分享',
    'share_expire_options': [],
  };

  @override
  Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String destPath,
    String? newName,
  }) async {
    // TODO: 实现蓝奏云文件复制
    return false;
  }

  @override
  Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    LogManager().cloudDrive('蓝奏云 - 创建文件夹开始');
    LogManager().cloudDrive('文件夹名称: $folderName');
    LogManager().cloudDrive('父文件夹ID: $parentFolderId');

    try {
      // TODO: 实现蓝奏云创建文件夹功能
      LogManager().cloudDrive('蓝奏云 - 创建文件夹功能暂未实现');
      return null;
    } catch (e) {
      LogManager().error('蓝奏云 - 创建文件夹异常');
      return null;
    }
  }

  @override
  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    try {
      LogManager().cloudDrive('蓝奏云 - 获取账号详情开始');
      LogManager().cloudDrive(
        '蓝奏云 - 账号信息: ${account.name} (${account.type.displayName})',
      );

      // 从 Cookie 中提取 UID
      final uid = LanzouCloudDriveService.extractUidFromCookies(
        account.cookies ?? '',
      );

      if (uid == null || uid.isEmpty) {
        LogManager().cloudDrive('蓝奏云 - 无法从 Cookie 中提取 UID');
        return null;
      }

      // 验证 Cookie 有效性
      final isValid = await LanzouCloudDriveService.validateCookies(
        account.cookies ?? '',
        uid,
      );

      if (!isValid) {
        LogManager().cloudDrive('蓝奏云 - Cookie 验证失败');
        return null;
      }

      // 蓝奏云没有详细的用户信息 API，使用 UID 作为用户名
      final accountInfo = CloudDriveAccountInfo(
        username: 'lanzou_$uid',
        uk: int.tryParse(uid) ?? 0,
        isVip: false,
        isSvip: false,
        loginState: 1,
      );

      final accountDetails = CloudDriveAccountDetails(
        id: account.id,
        name: account.name,
        accountInfo: accountInfo,
        quotaInfo: null, // 蓝奏云没有容量信息 API
      );

      LogManager().cloudDrive('蓝奏云 - 账号详情获取成功');
      return accountDetails;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('蓝奏云 - 获取账号详情异常: $e');
      LogManager().cloudDrive('错误堆栈: $stackTrace');
      return null;
    }
  }

  @override
  String convertPathToTargetFolderId(List<PathInfo> folderPath) {
    if (folderPath.isEmpty) {
      return '';
    }
    // 蓝奏云盘使用最后一级路径ID
    return folderPath.last.id;
  }

  @override
  CloudDriveFile updateFilePathForTargetDirectory(
    CloudDriveFile file,
    String targetPath,
  ) {
    // 蓝奏云盘暂时返回原文件，不需要路径更新
    return file;
  }

  @override
  Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? path,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      LogManager().cloudDrive('蓝奏云 - 获取文件列表开始');
      LogManager().cloudDrive('文件夹ID: ${folderId ?? '-1'}');
      LogManager().cloudDrive('账号: ${account.name}');

      // 从Cookie中提取UID
      final uid = LanzouCloudDriveService.extractUidFromCookies(
        account.cookies ?? '',
      );

      if (uid == null || uid.isEmpty) {
        LogManager().cloudDrive('蓝奏云 - 无法从Cookie中提取UID');
        return [];
      }

      LogManager().cloudDrive('蓝奏云 - UID提取成功: $uid');

      // 获取文件和文件夹
      final files = await LanzouCloudDriveService.getFiles(
        cookies: account.cookies ?? '',
        uid: uid,
        folderId: folderId ?? '-1',
      );

      final folders = await LanzouCloudDriveService.getFolders(
        cookies: account.cookies ?? '',
        uid: uid,
        folderId: folderId ?? '-1',
      );

      // 合并文件和文件夹列表
      final allItems = [...folders, ...files];

      LogManager().cloudDrive(
        '蓝奏云 - 文件列表获取成功: ${files.length}个文件, ${folders.length}个文件夹',
      );

      return allItems;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('蓝奏云 - 获取文件列表异常: $e');
      LogManager().cloudDrive('蓝奏云 - 错误堆栈: $stackTrace');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String? folderId,
  }) async {
    LogManager().cloudDrive('蓝奏云 - 上传文件开始');
    LogManager().cloudDrive('文件路径: $filePath');
    LogManager().cloudDrive('文件名: $fileName');
    LogManager().cloudDrive('文件夹ID: ${folderId ?? '-1'}');

    try {
      final result = await LanzouCloudDriveService.uploadFile(
        account: account,
        filePath: filePath,
        fileName: fileName,
        folderId: folderId ?? '-1',
      );

      if (result['success'] == true) {
        LogManager().cloudDrive('蓝奏云 - 文件上传成功');
      } else {
        LogManager().cloudDrive('蓝奏云 - 文件上传失败: ${result['message']}');
      }

      return result;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('蓝奏云 - 上传文件异常: $e');
      LogManager().cloudDrive('蓝奏云 - 错误堆栈: $stackTrace');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// 搜索文件
  ///
  /// [account] 蓝奏云账号信息
  /// [keyword] 搜索关键词
  /// [folderId] 可选，在指定文件夹内搜索
  /// [page] 页码，默认第1页
  /// [pageSize] 每页数量，默认50
  /// [fileType] 可选，文件类型筛选
  /// 返回符合条件的文件列表
  @override
  Future<List<CloudDriveFile>> searchFiles({
    required CloudDriveAccount account,
    required String keyword,
    String? folderId,
    int page = 1,
    int pageSize = 50,
    String? fileType,
  }) async {
    LogManager().cloudDrive('蓝奏云 - 搜索文件功能暂未实现');
    return [];
  }

  /// 刷新鉴权信息
  ///
  /// [account] 蓝奏云账号信息
  /// 返回刷新后的账号信息，如果刷新失败返回null
  @override
  Future<CloudDriveAccount?> refreshAuth({
    required CloudDriveAccount account,
  }) async {
    LogManager().cloudDrive('蓝奏云 - 刷新鉴权信息功能暂未实现');
    return null;
  }
}
