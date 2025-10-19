import '../../../../core/logging/log_manager.dart';
import '../../download/services/download_config_service.dart';
import '../../download/services/download_service.dart';
import '../models/cloud_drive_models.dart';
import '../services/lanzou/lanzou_cloud_drive_service.dart';
import '../services/lanzou/lanzou_direct_link_service.dart';
import 'cloud_drive_operation_service.dart';

/// 云盘文件管理服务
/// 统一管理不同云盘的文件操作，基于策略模式实现
class CloudDriveFileService {
  /// 获取文件列表（根据云盘类型）
  static Future<Map<String, List<CloudDriveFile>>> getFileList({
    required CloudDriveAccount account,
    String? folderId,
    int page = 1,
  }) async {
    try {
      _logOperation('获取文件列表', account);

      // 验证账号登录状态
      if (!await _validateAccount(account)) {
        return {'files': [], 'folders': []};
      }

      // 使用策略模式获取文件列表
      final strategy = CloudDriveOperationService.getStrategy(account.type);
      final fileList = await strategy.getFileList(
        account: account,
        folderId: _normalizeRootFolder(folderId, account),
      );

      // 分离文件和文件夹
      final files = <CloudDriveFile>[];
      final folders = <CloudDriveFile>[];

      for (final file in fileList) {
        if (file.isFolder) {
          folders.add(file);
        } else {
          files.add(file);
        }
      }

      _logSuccess(
        '文件列表获取',
        account,
        '${files.length} 个文件, ${folders.length} 个文件夹',
      );
      return {'files': files, 'folders': folders};
    } catch (e) {
      _logError('获取文件列表', account, e);
      return {'files': [], 'folders': []};
    }
  }

  /// 获取文件详情（根据云盘类型）
  static Future<Map<String, dynamic>?> getFileDetail({
    required CloudDriveAccount account,
    required String fileId,
  }) async {
    try {
      _logOperation('获取文件详情', account);

      // 验证账号登录状态
      if (!await _validateAccount(account)) {
        return null;
      }

      // 使用策略模式获取账号详情
      final strategy = CloudDriveOperationService.getStrategy(account.type);
      final accountDetails = await strategy.getAccountDetails(account: account);

      if (accountDetails != null) {
        _logSuccess('文件详情获取', account, fileId);
        return {
          'accountInfo': accountDetails.accountInfo,
          'quotaInfo': accountDetails.quotaInfo,
        };
      }

      return null;
    } catch (e) {
      _logError('获取文件详情', account, e);
      return null;
    }
  }

  /// 获取文件下载链接
  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      _logOperation('获取下载链接', account);

      // 验证账号登录状态
      if (!await _validateAccount(account)) {
        return null;
      }

      // 使用策略模式获取下载链接
      final downloadUrl = await CloudDriveOperationService.getDownloadUrl(
        account: account,
        file: file,
      );

      if (downloadUrl != null) {
        _logSuccess('下载链接获取', account, '链接长度: ${downloadUrl.length}');
      } else {
        _logWarning('下载链接获取', account, '返回null');
      }

      return downloadUrl;
    } catch (e) {
      _logError('获取下载链接', account, e);
      return null;
    }
  }

  /// 批量下载文件
  static Future<void> batchDownloadFiles({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    required List<CloudDriveFile> folders,
  }) async {
    try {
      _logOperation(
        '批量下载',
        account,
        '${files.length} 个文件, ${folders.length} 个文件夹',
      );

      // 目前只支持文件下载，文件夹下载需要递归处理
      if (folders.isNotEmpty) {
        LogManager().warning(
          '文件夹批量下载暂未实现，跳过 ${folders.length} 个文件夹',
          className: 'CloudDriveFileService',
          methodName: 'downloadFiles',
          data: {'folderCount': folders.length},
        );
      }

      if (files.isEmpty) {
        LogManager().warning(
          '没有文件需要下载',
          className: 'CloudDriveFileService',
          methodName: 'downloadFiles',
        );
        return;
      }

      await _performBatchDownload(account, files);
    } catch (e) {
      _logError('批量下载', account, e);
      rethrow;
    }
  }

  /// 创建文件夹
  static Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    try {
      _logOperation('创建文件夹', account, folderName);

      // 验证账号登录状态
      if (!await _validateAccount(account)) {
        return null;
      }

      // 使用策略模式创建文件夹
      final result = await CloudDriveOperationService.createFolder(
        account: account,
        folderName: folderName,
        parentFolderId: parentFolderId,
      );

      if (result != null) {
        _logSuccess('文件夹创建', account, folderName);
      } else {
        _logWarning('文件夹创建', account, '创建失败');
      }

      return result;
    } catch (e) {
      _logError('创建文件夹', account, e);
      return null;
    }
  }

  /// 移动文件
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    try {
      _logOperation('移动文件', account, '${file.name} -> $targetFolderId');

      // 验证账号登录状态
      if (!await _validateAccount(account)) {
        return false;
      }

      // 使用策略模式移动文件
      final success = await CloudDriveOperationService.moveFile(
        account: account,
        file: file,
        targetFolderId: targetFolderId,
      );

      if (success) {
        _logSuccess('文件移动', account, file.name);
      } else {
        _logWarning('文件移动', account, '移动失败');
      }

      return success;
    } catch (e) {
      _logError('移动文件', account, e);
      return false;
    }
  }

  /// 删除文件
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      _logOperation('删除文件', account, file.name);

      // 验证账号登录状态
      if (!await _validateAccount(account)) {
        return false;
      }

      // 使用策略模式删除文件
      final success = await CloudDriveOperationService.deleteFile(
        account: account,
        file: file,
      );

      if (success) {
        _logSuccess('文件删除', account, file.name);
      } else {
        _logWarning('文件删除', account, '删除失败');
      }

      return success;
    } catch (e) {
      _logError('删除文件', account, e);
      return false;
    }
  }

  /// 重命名文件
  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    try {
      _logOperation('重命名文件', account, '${file.name} -> $newName');

      // 验证账号登录状态
      if (!await _validateAccount(account)) {
        return false;
      }

      // 使用策略模式重命名文件
      final success = await CloudDriveOperationService.renameFile(
        account: account,
        file: file,
        newName: newName,
      );

      if (success) {
        _logSuccess('文件重命名', account, '${file.name} -> $newName');
      } else {
        _logWarning('文件重命名', account, '重命名失败');
      }

      return success;
    } catch (e) {
      _logError('重命名文件', account, e);
      return false;
    }
  }

  /// 复制文件
  static Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String destPath,
    String? newName,
  }) async {
    try {
      _logOperation('复制文件', account, '${file.name} -> $destPath');

      // 验证账号登录状态
      if (!await _validateAccount(account)) {
        return false;
      }

      // 使用策略模式复制文件
      final success = await CloudDriveOperationService.copyFile(
        account: account,
        file: file,
        destPath: destPath,
        newName: newName,
      );

      if (success) {
        _logSuccess('文件复制', account, '${file.name} -> $destPath');
      } else {
        _logWarning('文件复制', account, '复制失败');
      }

      return success;
    } catch (e) {
      _logError('复制文件', account, e);
      return false;
    }
  }

  /// 上传文件
  static Future<Map<String, dynamic>> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String? folderId,
  }) async {
    try {
      _logOperation('上传文件', account, fileName);

      // 验证账号登录状态
      if (!await _validateAccount(account)) {
        return {'success': false, 'message': '账号未登录'};
      }

      // 根据云盘类型选择合适的上传服务
      switch (account.type) {
        case CloudDriveType.lanzou:
          final result = await LanzouCloudDriveService.uploadFile(
            account: account,
            filePath: filePath,
            fileName: fileName,
            folderId: folderId ?? '-1',
          );
          _logSuccess('文件上传', account, fileName);
          return result;

        case CloudDriveType.baidu:
        case CloudDriveType.pan123:
        case CloudDriveType.ali:
        case CloudDriveType.quark:
          // 其他云盘的上传功能待实现
          _logWarning('文件上传', account, '${account.type.displayName}上传功能暂未实现');
          return {
            'success': false,
            'message': '${account.type.displayName}上传功能暂未实现',
          };
      }
    } catch (e) {
      _logError('上传文件', account, e);
      return {'success': false, 'message': e.toString()};
    }
  }

  /// 解析蓝奏云直链
  static Future<Map<String, dynamic>?> parseLanzouDirectLink({
    required String shareUrl,
    String? password,
  }) async {
    try {
      LogManager().cloudDrive('🔗 开始解析蓝奏云直链: $shareUrl');

      final result = await LanzouDirectLinkService.parseDirectLink(
        shareUrl: shareUrl,
        password: password,
      );

      if (result != null) {
        LogManager().cloudDrive('✅ 蓝奏云直链解析成功');
      } else {
        LogManager().cloudDrive('❌ 蓝奏云直链解析失败');
      }

      return result;
    } catch (e) {
      LogManager().error('❌ 解析蓝奏云直链异常');
      return null;
    }
  }

  /// 检查操作是否支持
  static bool isOperationSupported({
    required CloudDriveAccount account,
    required String operation,
  }) => CloudDriveOperationService.isOperationSupported(account, operation);

  /// 获取UI配置
  static Map<String, dynamic> getUIConfig(CloudDriveAccount account) =>
      CloudDriveOperationService.getUIConfig(account);

  /// 获取文件统计信息
  static Map<String, int> getFileStats(
    Map<String, List<CloudDriveFile>> fileList,
  ) {
    final files = fileList['files'] ?? [];
    final folders = fileList['folders'] ?? [];

    return {
      'total': files.length + folders.length,
      'files': files.length,
      'folders': folders.length,
    };
  }

  // ========== 私有辅助方法 ==========

  /// 验证账号登录状态
  static Future<bool> _validateAccount(CloudDriveAccount account) async {
    _logDebug('验证账号登录状态', account);

    if (!account.isLoggedIn) {
      _logWarning('账号验证', account, '账号未登录');
      return false;
    }

    // 根据认证方式验证
    switch (account.type.authType) {
      case AuthType.cookie:
        if (account.cookies == null || account.cookies!.isEmpty) {
          _logWarning('账号验证', account, 'Cookie为空');
          return false;
        }
        break;
      case AuthType.authorization:
        if (account.authorizationToken == null ||
            account.authorizationToken!.isEmpty) {
          _logWarning('账号验证', account, 'Authorization Token为空');
          return false;
        }
        break;
      case AuthType.qrCode:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    _logDebug('账号验证完成', account, '状态有效');
    return true;
  }

  /// 标准化根目录文件夹ID
  static String _normalizeRootFolder(
    String? folderId,
    CloudDriveAccount account,
  ) => folderId ?? account.type.webViewConfig.rootDir;

  /// 执行批量下载
  static Future<void> _performBatchDownload(
    CloudDriveAccount account,
    List<CloudDriveFile> files,
  ) async {
    // 加载下载配置
    final configService = DownloadConfigService();
    final downloadConfig = await configService.loadConfig();
    final downloadService = DownloadService();

    int successCount = 0;
    int failCount = 0;

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      try {
        LogManager().cloudDrive(
          '📥 下载文件 ${i + 1}/${files.length}: ${file.name}',
        );

        // 获取下载链接
        final downloadUrl = await getDownloadUrl(account: account, file: file);

        if (downloadUrl == null) {
          LogManager().error('❌ 无法获取下载链接: ${file.name}');
          failCount++;
          continue;
        }

        // 构建认证头 - 根据云盘类型添加相应的认证信息
        Map<String, String> authHeaders = {};
        if (account.type == CloudDriveType.ali) {
          // 阿里云盘使用Authorization Bearer Token认证
          if (account.authorizationToken != null &&
              account.authorizationToken!.isNotEmpty) {
            authHeaders['Authorization'] =
                'Bearer ${account.authorizationToken}';
            LogManager().cloudDrive(
              '🔑 阿里云盘 - 批量下载任务使用Authorization认证: ${account.authorizationToken!.length}字符',
            );
          } else {
            LogManager().cloudDrive('⚠️ 阿里云盘 - 账号缺少Authorization Token');
          }
        } else if (account.type == CloudDriveType.quark) {
          // 夸克云盘使用Cookie认证
          authHeaders['Cookie'] = account.cookies ?? '';
        } else {
          // 其他云盘使用Cookie认证
          authHeaders['Cookie'] = account.cookies ?? '';
        }

        // 合并认证头和配置中的自定义请求头
        final finalHeaders = <String, String>{
          'User-Agent': 'netdisk;PC',
          ...authHeaders,
          ...downloadConfig.customHeaders,
        };

        // 创建下载任务
        await downloadService.createDownloadTask(
          url: downloadUrl,
          fileName: file.name,
          downloadDir: downloadConfig.downloadDirectory,
          showNotification: downloadConfig.showNotification,
          openFileFromNotification: downloadConfig.openFileFromNotification,
          isExternalStorage: false,
          customHeaders: finalHeaders,
        );

        successCount++;
        LogManager().cloudDrive('✅ 文件下载任务创建成功: ${file.name}');
      } catch (e) {
        LogManager().error('❌ 下载文件失败: ${file.name}');
        failCount++;
      }
    }

    LogManager().cloudDrive('📥 批量下载完成: $successCount 成功, $failCount 失败');
  }

  // ========== 日志辅助方法 ==========

  /// 记录操作开始日志
  static void _logOperation(
    String operation,
    CloudDriveAccount account, [
    String? details,
  ]) {
    final message = details != null ? '$operation: $details' : operation;
    LogManager().cloudDrive(
      message,
      className: 'CloudDriveFileService',
      methodName: '_logOperation',
      data: {
        'operation': operation,
        'accountId': account.id,
        'accountType': account.type,
        'details': details,
      },
    );
  }

  /// 记录成功日志
  static void _logSuccess(
    String operation,
    CloudDriveAccount account,
    String details,
  ) {
    LogManager().cloudDrive(
      '$operation成功: $details',
      className: 'CloudDriveFileService',
      methodName: '_logSuccess',
      data: {
        'operation': operation,
        'accountId': account.id,
        'accountType': account.type,
        'details': details,
      },
    );
  }

  /// 记录警告日志
  static void _logWarning(
    String operation,
    CloudDriveAccount account,
    String details,
  ) {
    LogManager().warning(
      '$operation警告: $details',
      className: 'CloudDriveFileService',
      methodName: '_logWarning',
      data: {
        'operation': operation,
        'accountId': account.id,
        'accountType': account.type,
        'details': details,
      },
    );
  }

  /// 记录错误日志
  static void _logError(
    String operation,
    CloudDriveAccount account,
    dynamic error,
  ) {
    LogManager().error(
      '$operation失败',
      className: 'CloudDriveFileService',
      methodName: '_logError',
      data: {
        'operation': operation,
        'accountId': account.id,
        'accountType': account.type,
      },
      exception: error,
    );
  }

  /// 记录调试日志
  static void _logDebug(
    String operation,
    CloudDriveAccount account, [
    String? details,
  ]) {
    final message = details != null ? '$operation: $details' : operation;
    LogManager().cloudDrive('🔍 $message');
  }

  /// 获取日志子分类
  static String _getLogSubCategory(CloudDriveType type) {
    switch (type) {
      case CloudDriveType.lanzou:
        return 'cloudDrive.lanzou';
      case CloudDriveType.baidu:
        return 'cloudDrive.baidu';
      case CloudDriveType.pan123:
        return 'cloudDrive.pan123';
      case CloudDriveType.ali:
        return 'cloudDrive.ali';
      case CloudDriveType.quark:
        return 'cloudDrive.quark';
    }
  }
}
