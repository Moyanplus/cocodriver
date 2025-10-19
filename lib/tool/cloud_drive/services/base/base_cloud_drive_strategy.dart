import '../../../../core/logging/log_manager.dart';
import '../../models/cloud_drive_models.dart';
import '../../base/cloud_drive_operation_service.dart';

/// 基础云盘策略类
/// 提供通用的日志记录、错误处理和操作封装
abstract class BaseCloudDriveStrategy implements CloudDriveOperationStrategy {
  /// 云盘类型
  CloudDriveType get cloudDriveType;

  /// 记录操作开始日志
  void logOperation(String operation, Map<String, dynamic> params) {
    LogManager().cloudDrive(
      '$operation - ${cloudDriveType.displayName}',
      className: 'BaseCloudDriveStrategy',
      methodName: 'logOperation',
      data: {
        'operation': operation,
        'cloudDriveType': cloudDriveType.displayName,
        'params': params,
      },
    );
  }

  /// 记录错误日志
  void logError(String operation, dynamic error) {
    LogManager().error(
      '$operation 失败 - ${cloudDriveType.displayName}: $error',
      className: 'BaseCloudDriveStrategy',
      methodName: 'logError',
      data: {
        'operation': operation,
        'cloudDriveType': cloudDriveType.displayName,
      },
      exception: error,
    );
  }

  /// 记录成功日志
  void logSuccess(String operation, [String? details]) {
    LogManager().cloudDrive(
      '$operation 成功 - ${cloudDriveType.displayName}${details != null ? ': $details' : ''}',
      className: 'BaseCloudDriveStrategy',
      methodName: 'logSuccess',
      data: {
        'operation': operation,
        'cloudDriveType': cloudDriveType.displayName,
        'details': details,
      },
    );
  }

  /// 记录警告日志
  void logWarning(String operation, String details) {
    LogManager().warning(
      '$operation 警告 - ${cloudDriveType.displayName}: $details',
      className: 'BaseCloudDriveStrategy',
      methodName: 'logWarning',
      data: {
        'operation': operation,
        'cloudDriveType': cloudDriveType.displayName,
        'details': details,
      },
    );
  }

  /// 通用操作处理包装器
  Future<T> handleOperation<T>(
    String operation,
    Future<T> Function() action, {
    T? defaultValue,
    bool logParams = true,
    Map<String, dynamic>? params,
  }) async {
    try {
      if (logParams && params != null) {
        logOperation(operation, params);
      } else if (logParams) {
        logOperation(operation, {});
      }

      final result = await action();

      if (result != null) {
        logSuccess(operation);
      } else {
        logWarning(operation, '返回结果为null');
      }

      return result;
    } catch (e) {
      logError(operation, e);
      if (defaultValue != null) {
        return defaultValue;
      }
      rethrow;
    }
  }

  /// 通用布尔操作处理包装器
  Future<bool> handleBooleanOperation(
    String operation,
    Future<bool> Function() action, {
    bool defaultValue = false,
    bool logParams = true,
    Map<String, dynamic>? params,
  }) async {
    try {
      if (logParams && params != null) {
        logOperation(operation, params);
      } else if (logParams) {
        logOperation(operation, {});
      }

      final result = await action();

      if (result) {
        logSuccess(operation);
      } else {
        logWarning(operation, '操作返回false');
      }

      return result;
    } catch (e) {
      logError(operation, e);
      return defaultValue;
    }
  }

  /// 通用字符串操作处理包装器
  Future<String?> handleStringOperation(
    String operation,
    Future<String?> Function() action, {
    bool logParams = true,
    Map<String, dynamic>? params,
  }) async {
    try {
      if (logParams && params != null) {
        logOperation(operation, params);
      } else if (logParams) {
        logOperation(operation, {});
      }

      final result = await action();

      if (result != null && result.isNotEmpty) {
        logSuccess(operation, '结果长度: ${result.length}');
      } else {
        logWarning(operation, '返回结果为空');
      }

      return result;
    } catch (e) {
      logError(operation, e);
      return null;
    }
  }

  /// 通用列表操作处理包装器
  Future<List<T>> handleListOperation<T>(
    String operation,
    Future<List<T>> Function() action, {
    List<T> defaultValue = const [],
    bool logParams = true,
    Map<String, dynamic>? params,
  }) async {
    try {
      if (logParams && params != null) {
        logOperation(operation, params);
      } else if (logParams) {
        logOperation(operation, {});
      }

      final result = await action();

      logSuccess(operation, '返回 ${result.length} 个项目');
      return result;
    } catch (e) {
      logError(operation, e);
      return defaultValue;
    }
  }

  /// 验证账号基础实现
  Future<bool> validateAccount(CloudDriveAccount account) async {
    if (account.type != cloudDriveType) {
      logError('validateAccount', '账号类型不匹配');
      return false;
    }

    if (!account.isLoggedIn) {
      logError('validateAccount', '账号未登录');
      return false;
    }

    return true;
  }

  /// 默认的路径转换实现
  String convertPathToTargetFolderId(List<PathInfo> folderPath) {
    if (folderPath.isEmpty) {
      return cloudDriveType.webViewConfig.rootDir;
    }

    // 默认使用最后一个路径的ID
    return folderPath.last.id;
  }

  /// 默认的文件路径更新实现
  CloudDriveFile updateFilePathForTargetDirectory(
    CloudDriveFile file,
    String targetPath,
  ) {
    // 默认实现：更新文件的folderId为目标路径
    return file.copyWith(folderId: targetPath);
  }

  /// 获取支持的操作 - 子类可以重写
  Map<String, bool> getSupportedOperations() {
    return {
      'download': true,
      'share': true,
      'move': true,
      'delete': true,
      'rename': true,
      'copy': true,
      'createFolder': true,
    };
  }

  /// 获取UI配置 - 子类可以重写
  Map<String, dynamic> getOperationUIConfig() {
    return {
      'showBatchActions': true,
      'showContextMenu': true,
      'showFloatingActionButton': true,
      'maxFileSize': 100 * 1024 * 1024, // 100MB
      'supportedFileTypes': '*',
    };
  }

  /// 获取账号详情 - 子类必须实现
  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    return await handleOperation(
      'getAccountDetails',
      () => _getAccountDetailsImpl(account),
    );
  }

  /// 获取文件列表 - 子类必须实现
  Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? path,
    String? folderId,
  }) async {
    return await handleListOperation(
      'getFileList',
      () => _getFileListImpl(account, path, folderId),
      params: {'path': path, 'folderId': folderId, 'accountId': account.id},
    );
  }

  /// 获取下载链接 - 子类必须实现
  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    return await handleStringOperation(
      'getDownloadUrl',
      () => _getDownloadUrlImpl(account, file),
      params: {
        'fileId': file.id,
        'fileName': file.name,
        'accountId': account.id,
      },
    );
  }

  /// 高速下载 - 子类可以重写
  Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    return await handleOperation(
      'getHighSpeedDownloadUrls',
      () => _getHighSpeedDownloadUrlsImpl(account, file, shareUrl, password),
      params: {
        'fileId': file.id,
        'fileName': file.name,
        'shareUrl': shareUrl,
        'accountId': account.id,
      },
    );
  }

  /// 创建分享链接 - 子类必须实现
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    return await handleStringOperation(
      'createShareLink',
      () => _createShareLinkImpl(account, files, password, expireDays),
      params: {
        'fileCount': files.length,
        'password': password != null ? '已设置' : '未设置',
        'expireDays': expireDays,
        'accountId': account.id,
      },
    );
  }

  /// 移动文件 - 子类必须实现
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    return await handleBooleanOperation(
      'moveFile',
      () => _moveFileImpl(account, file, targetFolderId),
      params: {
        'fileId': file.id,
        'fileName': file.name,
        'targetFolderId': targetFolderId,
        'accountId': account.id,
      },
    );
  }

  /// 删除文件 - 子类必须实现
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    return await handleBooleanOperation(
      'deleteFile',
      () => _deleteFileImpl(account, file),
      params: {
        'fileId': file.id,
        'fileName': file.name,
        'accountId': account.id,
      },
    );
  }

  /// 重命名文件 - 子类必须实现
  Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    return await handleBooleanOperation(
      'renameFile',
      () => _renameFileImpl(account, file, newName),
      params: {
        'fileId': file.id,
        'oldName': file.name,
        'newName': newName,
        'accountId': account.id,
      },
    );
  }

  /// 复制文件 - 子类必须实现
  Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String destPath,
    String? newName,
  }) async {
    return await handleBooleanOperation(
      'copyFile',
      () => _copyFileImpl(account, file, destPath, newName),
      params: {
        'fileId': file.id,
        'fileName': file.name,
        'destPath': destPath,
        'newName': newName,
        'accountId': account.id,
      },
    );
  }

  /// 创建文件夹 - 子类必须实现
  Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    return await handleOperation(
      'createFolder',
      () => _createFolderImpl(account, folderName, parentFolderId),
      params: {
        'folderName': folderName,
        'parentFolderId': parentFolderId,
        'accountId': account.id,
      },
    );
  }

  // ========== 抽象方法，子类必须实现 ==========

  /// 获取账号详情实现
  Future<CloudDriveAccountDetails?> _getAccountDetailsImpl(
    CloudDriveAccount account,
  );

  /// 获取文件列表实现
  Future<List<CloudDriveFile>> _getFileListImpl(
    CloudDriveAccount account,
    String? path,
    String? folderId,
  );

  /// 获取下载链接实现
  Future<String?> _getDownloadUrlImpl(
    CloudDriveAccount account,
    CloudDriveFile file,
  );

  /// 高速下载实现
  Future<List<String>?> _getHighSpeedDownloadUrlsImpl(
    CloudDriveAccount account,
    CloudDriveFile file,
    String shareUrl,
    String password,
  );

  /// 创建分享链接实现
  Future<String?> _createShareLinkImpl(
    CloudDriveAccount account,
    List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  );

  /// 移动文件实现
  Future<bool> _moveFileImpl(
    CloudDriveAccount account,
    CloudDriveFile file,
    String? targetFolderId,
  );

  /// 删除文件实现
  Future<bool> _deleteFileImpl(CloudDriveAccount account, CloudDriveFile file);

  /// 重命名文件实现
  Future<bool> _renameFileImpl(
    CloudDriveAccount account,
    CloudDriveFile file,
    String newName,
  );

  /// 复制文件实现
  Future<bool> _copyFileImpl(
    CloudDriveAccount account,
    CloudDriveFile file,
    String destPath,
    String? newName,
  );

  /// 创建文件夹实现
  Future<Map<String, dynamic>?> _createFolderImpl(
    CloudDriveAccount account,
    String folderName,
    String? parentFolderId,
  );
}
