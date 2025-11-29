// import '../../core/logging/log_manager.dart'; // 未使用
import '../../base/cloud_drive_operation_service.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import '../../base/cloud_drive_service_gateway.dart';
import '../../core/result.dart';
import 'cloud_drive_service_base.dart';

/// 文件操作服务
///
/// 处理文件相关的操作，包括文件列表、文件详情、文件夹操作等。
class FileOperationService extends CloudDriveServiceBase {
  FileOperationService(
    super.type, {
    CloudDriveServiceGateway? gateway,
  }) : _gateway = gateway ?? defaultCloudDriveGateway;

  final CloudDriveServiceGateway _gateway;

  CloudDriveOperationStrategy _strategyOrThrow(CloudDriveAccount account) =>
      _gateway.strategyFor(account) ??
      (throw Exception('策略未找到: ${account.type.displayName}'));

  /// 获取文件列表
  Future<Result<Map<String, List<CloudDriveFile>>>> getFileList({
    required CloudDriveAccount account,
    String? folderId,
    int page = 1,
  }) async {
    logOperation(
      '获取文件列表',
      params: {'folderId': folderId ?? '根目录', 'page': page},
    );

    return await ResultUtils.fromAsync(() async {
      final fileList = await _gateway.listFiles(
        account: account,
        folderId: folderId,
        page: page,
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

      logSuccess(
        '获取文件列表',
        details: '${files.length} 个文件, ${folders.length} 个文件夹',
      );
      return {'files': files, 'folders': folders};
    }, operationName: '获取文件列表');
  }

  /// 获取文件详情
  Future<Result<Map<String, dynamic>?>> getFileDetail({
    required CloudDriveAccount account,
    required String fileId,
  }) async {
    logOperation('获取文件详情', params: {'fileId': fileId});

    return await ResultUtils.fromAsync(() async {
      final accountDetails =
          await _gateway.strategyFor(account)?.getAccountDetails(
                account: account,
              );

      if (accountDetails != null) {
        logSuccess('获取文件详情');
        return {
          'accountInfo': accountDetails.accountInfo,
          'quotaInfo': accountDetails.quotaInfo,
        };
      }

      return null;
    }, operationName: '获取文件详情');
  }

  /// 创建文件夹
  Future<Result<Map<String, dynamic>?>> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    logOperation(
      '创建文件夹',
      params: {
        'folderName': folderName,
        'parentFolderId': parentFolderId ?? '根目录',
      },
    );

    return await ResultUtils.fromAsync(() async {
      final created = await _gateway.createFolder(
        account: account,
        name: folderName,
        parentId: parentFolderId,
      );

      if (created != null) {
        logSuccess('创建文件夹', details: folderName);
        return {'folder': created};
      } else {
        logWarning('创建文件夹', '创建失败');
        return null;
      }
    }, operationName: '创建文件夹');
  }

  /// 移动文件
  Future<Result<bool>> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    logOperation(
      '移动文件',
      params: {
        'fileName': file.name,
        'targetFolderId': targetFolderId ?? '根目录',
      },
    );

    return await ResultUtils.fromAsync(() async {
      final success = await _gateway.moveFile(
        account: account,
        file: file,
        targetFolderId: targetFolderId ?? file.folderId ?? '/',
      );

      if (success) {
        logSuccess('移动文件', details: file.name);
      } else {
        logWarning('移动文件', '移动失败');
      }

      return success;
    }, operationName: '移动文件');
  }

  /// 删除文件
  Future<Result<bool>> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    logOperation('删除文件', params: {'fileName': file.name});

    return await ResultUtils.fromAsync(() async {
      final success = await _gateway.deleteFile(account: account, file: file);

      if (success) {
        logSuccess('删除文件', details: file.name);
      } else {
        logWarning('删除文件', '删除失败');
      }

      return success;
    }, operationName: '删除文件');
  }

  /// 重命名文件
  Future<Result<bool>> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    logOperation('重命名文件', params: {'oldName': file.name, 'newName': newName});

    return await ResultUtils.fromAsync(() async {
      final success = await _gateway.renameFile(
        account: account,
        file: file,
        newName: newName,
      );

      if (success) {
        logSuccess('重命名文件', details: '${file.name} -> $newName');
      } else {
        logWarning('重命名文件', '重命名失败');
      }

      return success;
    }, operationName: '重命名文件');
  }

  /// 复制文件
  Future<Result<bool>> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String destPath,
    String? newName,
  }) async {
    logOperation(
      '复制文件',
      params: {'fileName': file.name, 'destPath': destPath, 'newName': newName},
    );

    return await ResultUtils.fromAsync(() async {
      final success = await _gateway.copyFile(
        account: account,
        file: file,
        targetFolderId: destPath,
        newName: newName,
      );

      if (success) {
        logSuccess('复制文件', details: '${file.name} -> $destPath');
      } else {
        logWarning('复制文件', '复制失败');
      }

      return success;
    }, operationName: '复制文件');
  }

  /// 生成分享链接
  Future<Result<String?>> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    logOperation(
      '生成分享链接',
      params: {
        'fileCount': files.length,
        'password': password ?? '无',
        'expireDays': expireDays ?? 1,
      },
    );

    return await ResultUtils.fromAsync(() async {
      final shareLink = await _gateway.createShareLink(
        account: account,
        files: files,
        password: password,
        expireDays: expireDays,
      );

      if (shareLink != null) {
        logSuccess('生成分享链接', details: '链接长度: ${shareLink.length}');
      } else {
        logWarning('生成分享链接', '生成失败');
      }

      return shareLink;
    }, operationName: '生成分享链接');
  }

  /// 获取支持的操作
  Map<String, bool> getSupportedOperations(CloudDriveAccount account) {
    return _gateway.getSupportedOperations(account);
  }

  /// 获取UI配置
  Map<String, dynamic> getOperationUIConfig(CloudDriveAccount account) {
    final strategy = _gateway.strategyFor(account);
    return strategy?.getOperationUIConfig() ?? {};
  }

  /// 获取账号详情
  Future<Result<CloudDriveAccountDetails?>> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    logOperation('获取账号详情');

    return await ResultUtils.fromAsync(() async {
      final strategy = _gateway.strategyFor(account);
      if (strategy == null) {
        throw Exception('策略未找到: ${account.type.displayName}');
      }
      final accountDetails = await strategy.getAccountDetails(account: account);

      if (accountDetails != null) {
        logSuccess(
          '获取账号详情',
          details: accountDetails.accountInfo?.username ?? '未知用户',
        );
      } else {
        logWarning('获取账号详情', '获取失败');
      }

      return accountDetails;
    }, operationName: '获取账号详情');
  }

  /// 将路径信息转换为目标文件夹ID
  String convertPathToTargetFolderId(
    CloudDriveAccount account,
    List<PathInfo> folderPath,
  ) {
    final strategy = _gateway.strategyFor(account);
    if (strategy == null) {
      return '';
    }
    return strategy.convertPathToTargetFolderId(folderPath);
  }

  /// 更新文件的路径信息为目标目录
  CloudDriveFile updateFilePathForTargetDirectory(
    CloudDriveAccount account,
    CloudDriveFile file,
    String targetPath,
  ) {
    final strategy = _gateway.strategyFor(account);
    if (strategy == null) {
      return file;
    }
    return strategy.updateFilePathForTargetDirectory(file, targetPath);
  }
}
