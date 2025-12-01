import 'package:coco_cloud_drive/tool/cloud_drive/services/providers/lanzou/exceptions/lanzou_exceptions.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/services/providers/lanzou/lanzou_config.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/services/providers/lanzou/repository/lanzou_repository.dart';

import '../../../../../../core/logging/log_manager.dart';
import '../../../base/cloud_drive_operation_service.dart';
import '../../../data/models/cloud_drive_dtos.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../utils/cloud_drive_log_utils.dart';
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
  Future<CloudDrivePreviewResult?> getPreviewInfo({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    LogManager().cloudDrive('蓝奏云 - 暂未实现预览接口');
    return null;
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
      if (files.isEmpty) {
        LogManager().cloudDrive('蓝奏云 - 分享失败，文件为空');
        return null;
      }
      final repository = LanzouRepository.fromAccount(account);
      final shareLink = await repository.createShareLink(
        account: account,
        files: files,
        password: password,
        expireDays: expireDays,
      );
      if (shareLink != null) {
        LogManager().cloudDrive('蓝奏云 - 分享链接创建成功');
      } else {
        LogManager().cloudDrive('蓝奏云 - 分享链接创建失败: 暂不支持');
      }
      return shareLink;
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
      final repository = LanzouRepository.fromAccount(account);
      final result = await repository.move(
        account: account,
        file: file,
        targetFolderId: targetFolderId ?? LanzouConfig.defaultFolderId,
      );

      if (result) {
        LogManager().cloudDrive('蓝奏云 - 文件移动成功');
        return true;
      } else {
        LogManager().cloudDrive('蓝奏云 - 文件移动失败');
        return false;
      }
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
      final repository = LanzouRepository.fromAccount(account);
      final result = await repository.delete(account: account, file: file);
      if (result) {
        LogManager().cloudDrive('蓝奏云 - 文件删除成功');
        return true;
      }
      LogManager().cloudDrive('蓝奏云 - 文件删除失败');
      throw LanzouApiException('蓝奏云删除失败');
    } catch (e, stackTrace) {
      LogManager().cloudDrive('蓝奏云 - 删除文件异常: $e');
      LogManager().cloudDrive('蓝奏云 - 错误堆栈: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    LogManager().cloudDrive('蓝奏云 - 重命名文件开始');
    LogManager().cloudDrive('蓝奏云 - 原文件名: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive('蓝奏云 - 新文件名: $newName');

    try {
      final repository = LanzouRepository.fromAccount(account);
      final result = await repository.rename(
        account: account,
        file: file,
        newName: newName,
      );
      if (result) {
        LogManager().cloudDrive('蓝奏云 - 文件重命名成功');
        return true;
      }
      LogManager().cloudDrive('蓝奏云 - 文件重命名失败');
      throw LanzouApiException('蓝奏云重命名失败');
    } catch (e, stackTrace) {
      LogManager().cloudDrive('蓝奏云 - 重命名文件异常: $e');
      LogManager().cloudDrive('蓝奏云 - 错误堆栈: $stackTrace');
      rethrow;
    }
  }

  @override
  Map<String, bool> getSupportedOperations() => {
    'download': false, // 蓝奏云暂不支持API下载
    'share': true, // 支持分享
    'copy': false, // 支持复制
    'move': true, // 支持移动
    'delete': true, // 支持删除
    'rename': true, // 暂不支持重命名
    'createFolder': true, // 暂不支持创建文件夹
    'preview': false,
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
      final repository = LanzouRepository.fromAccount(account);
      final folder = await repository.createFolder(
        account: account,
        name: folderName,
        parentId: parentFolderId ?? LanzouConfig.defaultFolderId,
      );
      if (folder != null) {
        LogManager().cloudDrive('蓝奏云 - 创建文件夹成功');
        return {
          'success': true,
          'folderId': folder.id,
          'folder': folder,
          'message': '创建成功',
        };
      }
      LogManager().cloudDrive('蓝奏云 - 创建文件夹失败');
      return {'success': false, 'message': '创建失败，请稍后重试'};
    } catch (e, stackTrace) {
      LogManager().error('蓝奏云 - 创建文件夹异常', exception: e, stackTrace: stackTrace);
      return {'success': false, 'message': e.toString()};
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

      final uid = LanzouRepository.extractUidFromCookies(
        account.primaryAuthType == AuthType.cookie
            ? (account.primaryAuthValue ?? '')
            : '',
      );

      if (uid == null || uid.isEmpty) {
        LogManager().cloudDrive('蓝奏云 - 无法从 Cookie 中提取 UID');
        return null;
      }

      final repository = LanzouRepository.fromAccount(account);
      final isValid = await repository.validateSession();
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

      final repository = LanzouRepository.fromAccount(account);
      final items = await repository.listFiles(
        account: account,
        folderId: folderId,
        page: page,
        pageSize: pageSize,
      );

      final folders = items.where((e) => e.isFolder).toList();
      final files = items.where((e) => !e.isFolder).toList();

      CloudDriveLogUtils.logFileListSummary(
        provider: '蓝奏云',
        files: files,
        folders: folders,
      );

      return items;
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
    UploadProgressCallback? onProgress,
  }) async {
    LogManager().cloudDrive('蓝奏云 - 上传文件开始');
    LogManager().cloudDrive('文件路径: $filePath');
    LogManager().cloudDrive('文件名: $fileName');
    LogManager().cloudDrive('文件夹ID: ${folderId ?? '-1'}');

    try {
      final repository = LanzouRepository.fromAccount(account);
      final uploaded = await repository.uploadFile(
        account: account,
        filePath: filePath,
        fileName: fileName,
        parentId: folderId ?? '-1',
      );

      if (uploaded != null) {
        LogManager().cloudDrive('蓝奏云 - 文件上传成功: ${uploaded.name}');
        return {'success': true, 'file': uploaded};
      }
      LogManager().cloudDrive('蓝奏云 - 文件上传失败: 未返回文件');
      return {'success': false, 'message': '上传失败'};
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
