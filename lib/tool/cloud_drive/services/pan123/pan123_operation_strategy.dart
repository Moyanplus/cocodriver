import '../../../../core/logging/log_manager.dart';
import '../../base/cloud_drive_operation_service.dart';
import '../../models/cloud_drive_models.dart';
import 'pan123_cloud_drive_service.dart';
import 'pan123_config.dart';

/// 123云盘操作策略
class Pan123CloudDriveOperationStrategy implements CloudDriveOperationStrategy {
  @override
  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    LogManager().cloudDrive('🔗 123云盘 - 获取下载链接开始');
    LogManager().cloudDrive('📄 123云盘 - 文件信息: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive(
      '👤 123云盘 - 账号信息: ${account.name} (${account.type.displayName})',
    );

    try {
      // 使用配置中的文件大小解析方法
      final fileSize = Pan123Config.parseFileSize(file.size?.toString());

      LogManager().cloudDrive('📏 123云盘 - 解析的文件大小: $fileSize bytes');

      // 从文件信息中提取S3KeyFlag和Etag
      String? s3keyFlag;
      String? etag;

      // TODO: 如果需要从其他地方获取s3keyFlag和etag，请在这里实现
      // 目前CloudDriveFile模型中没有downloadUrl字段，所以设置为null
      s3keyFlag = null;
      etag = null;

      LogManager().cloudDrive(
        '🔍 123云盘 - 提取的参数: s3keyFlag=$s3keyFlag, etag=$etag',
      );

      final downloadUrl = await Pan123CloudDriveService.getDownloadUrl(
        account: account,
        fileId: file.id,
        fileName: file.name,
        size: fileSize,
        s3keyFlag: s3keyFlag,
        etag: etag,
      );

      if (downloadUrl != null) {
        final preview =
            downloadUrl.length > 100
                ? '${downloadUrl.substring(0, 100)}...'
                : downloadUrl;
        LogManager().cloudDrive('✅ 123云盘 - 下载链接获取成功: $preview');
      } else {
        LogManager().cloudDrive('❌ 123云盘 - 下载链接获取失败');
      }

      return downloadUrl;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 123云盘 - 获取下载链接异常: $e');
      LogManager().cloudDrive('📄 123云盘 - 错误堆栈: $stackTrace');
      return null;
    }
  }

  @override
  Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    try {
      LogManager().cloudDrive('🚀 123云盘 - 高速下载: ${file.name}');

      // TODO: 实现123云盘高速下载
      // 这里需要调用第三方解析服务

      return null;
    } catch (e) {
      LogManager().error('❌ 123云盘高速下载失败');
      return null;
    }
  }

  @override
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    try {
      LogManager().cloudDrive('🔗 123云盘 - 生成分享链接');

      // TODO: 实现123云盘分享链接生成
      // 这里需要调用123云盘的API来生成分享链接

      return null;
    } catch (e) {
      LogManager().error('❌ 123云盘生成分享链接失败');
      return null;
    }
  }

  @override
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    try {
      LogManager().cloudDrive('🚚 123云盘 - 移动文件开始');
      LogManager().cloudDrive('📄 123云盘 - 文件信息: ${file.name} (ID: ${file.id})');
      LogManager().cloudDrive('📁 123云盘 - 目标文件夹ID: ${targetFolderId ?? '根目录'}');
      LogManager().cloudDrive(
        '👤 123云盘 - 账号信息: ${account.name} (${account.type.displayName})',
      );

      final success = await Pan123CloudDriveService.moveFile(
        account: account,
        fileId: file.id,
        targetParentFileId: targetFolderId ?? '0',
      );

      if (success) {
        LogManager().cloudDrive(
          '✅ 123云盘 - 文件移动成功: ${file.name} -> ${targetFolderId ?? '根目录'}',
        );
      } else {
        LogManager().cloudDrive(
          '❌ 123云盘 - 文件移动失败: ${file.name} -> ${targetFolderId ?? '根目录'}',
        );
      }

      return success;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 123云盘 - 移动文件异常: $e');
      LogManager().cloudDrive('📄 123云盘 - 错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      LogManager().cloudDrive('🗑️ 123云盘 - 删除文件开始');
      LogManager().cloudDrive('📄 123云盘 - 文件信息: ${file.name} (ID: ${file.id})');
      LogManager().cloudDrive(
        '👤 123云盘 - 账号信息: ${account.name} (${account.type.displayName})',
      );

      // 解析文件大小
      int? fileSize;
      if (file.size != null && file.size! > 0) {
        // 直接使用int类型的size
        fileSize = file.size;
      }

      // 从文件信息中提取S3KeyFlag和Etag
      String? s3keyFlag;
      String? etag;

      // TODO: 如果需要从其他地方获取s3keyFlag和etag，请在这里实现
      // 目前CloudDriveFile模型中没有downloadUrl字段，所以设置为null
      s3keyFlag = null;
      etag = null;

      final success = await Pan123CloudDriveService.deleteFile(
        account: account,
        fileId: file.id,
        fileName: file.name,
        type: file.isFolder ? 1 : 0,
        size: fileSize,
        s3keyFlag: s3keyFlag,
        etag: etag,
        parentFileId: file.folderId,
      );

      if (success) {
        LogManager().cloudDrive('✅ 123云盘 - 文件删除成功: ${file.name}');
      } else {
        LogManager().cloudDrive('❌ 123云盘 - 文件删除失败: ${file.name}');
      }

      return success;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 123云盘 - 删除文件异常: $e');
      LogManager().cloudDrive('📄 123云盘 - 错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    try {
      LogManager().cloudDrive('✏️ 123云盘 - 重命名文件开始');
      LogManager().cloudDrive('📄 123云盘 - 文件信息: ${file.name} (ID: ${file.id})');
      LogManager().cloudDrive('🔄 123云盘 - 新文件名: $newName');
      LogManager().cloudDrive(
        '👤 123云盘 - 账号信息: ${account.name} (${account.type.displayName})',
      );

      final success = await Pan123CloudDriveService.renameFile(
        account: account,
        fileId: file.id,
        newFileName: newName,
      );

      if (success) {
        LogManager().cloudDrive('✅ 123云盘 - 文件重命名成功: ${file.name} -> $newName');
      } else {
        LogManager().cloudDrive('❌ 123云盘 - 文件重命名失败: ${file.name} -> $newName');
      }

      return success;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 123云盘 - 重命名文件异常: $e');
      LogManager().cloudDrive('📄 123云盘 - 错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String destPath,
    String? newName,
  }) async {
    try {
      LogManager().cloudDrive('📋 123云盘 - 复制文件开始');
      LogManager().cloudDrive('📄 123云盘 - 文件信息: ${file.name} (ID: ${file.id})');
      LogManager().cloudDrive('📁 123云盘 - 目标路径: $destPath');
      LogManager().cloudDrive('🔄 123云盘 - 新文件名: ${newName ?? '使用原文件名'}');
      LogManager().cloudDrive(
        '👤 123云盘 - 账号信息: ${account.name} (${account.type.displayName})',
      );

      // 解析目标文件夹ID
      String targetFileId;
      if (destPath == '/' || destPath.isEmpty) {
        targetFileId = '0'; // 根目录
      } else {
        // 移除可能的路径前缀
        String cleanTargetId = destPath;
        if (cleanTargetId.startsWith('/')) {
          cleanTargetId = cleanTargetId.substring(1);
        }
        targetFileId = cleanTargetId;
      }

      LogManager().cloudDrive(
        '📁 123云盘 - 解析后的目标文件夹ID: $targetFileId (原始: $destPath)',
      );

      // 解析文件大小
      int? fileSize;
      if (file.size != null && file.size! > 0) {
        // 直接使用int类型的size
        fileSize = file.size;
      }

      // 从文件信息中提取Etag
      String? etag;

      // TODO: 如果需要从其他地方获取etag，请在这里实现
      // 目前CloudDriveFile模型中没有downloadUrl字段，所以设置为null
      etag = null;

      final success = await Pan123CloudDriveService.copyFile(
        account: account,
        fileId: file.id,
        targetFileId: targetFileId,
        fileName: newName ?? file.name,
        size: fileSize,
        etag: etag,
        type: file.isFolder ? 1 : 0,
        parentFileId: file.folderId,
      );

      if (success) {
        LogManager().cloudDrive(
          '✅ 123云盘 - 文件复制成功: ${file.name} -> $targetFileId',
        );
      } else {
        LogManager().cloudDrive(
          '❌ 123云盘 - 文件复制失败: ${file.name} -> $targetFileId',
        );
      }

      return success;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 123云盘 - 复制文件异常: $e');
      LogManager().cloudDrive('📄 123云盘 - 错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  Map<String, bool> getSupportedOperations() => {
    'download': true, // 已实现下载功能
    'share': false, // 暂未实现分享功能
    'move': true, // 已实现移动功能
    'delete': true, // 已实现删除功能
    'rename': true, // 已实现重命名功能
    'copy': true, // 已实现复制功能
    'createFolder': false, // 暂未实现创建文件夹功能
  };

  @override
  Map<String, dynamic> getOperationUIConfig() => {
    'showDownloadButton': true,
    'showShareButton': false,
    'showMoveButton': true, // 已实现移动功能
    'showDeleteButton': true, // 已实现删除功能
    'showRenameButton': true, // 已实现重命名功能
    'showCopyButton': true, // 已实现复制功能
  };

  @override
  Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    LogManager().cloudDrive('📁 123云盘 - 创建文件夹开始');
    LogManager().cloudDrive('📁 123云盘 - 文件夹名称: $folderName');
    LogManager().cloudDrive('📁 123云盘 - 父文件夹ID: $parentFolderId');

    try {
      // TODO: 实现123云盘创建文件夹功能
      LogManager().cloudDrive('⚠️ 123云盘 - 创建文件夹功能暂未实现');
      return null;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 123云盘 - 创建文件夹异常: $e');
      LogManager().cloudDrive('📄 123云盘 - 错误堆栈: $stackTrace');
      return null;
    }
  }

  @override
  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) {
    // TODO: 实现123云盘账号详情获取
    return Future.value(null);
  }

  @override
  String convertPathToTargetFolderId(List<PathInfo> folderPath) {
    if (folderPath.isEmpty) {
      return '0';
    }
    // 123云盘使用最后一级ID，通常是数字ID
    return folderPath.last.id;
  }

  @override
  CloudDriveFile updateFilePathForTargetDirectory(
    CloudDriveFile file,
    String targetPath,
  ) {
    // 123云盘暂时返回原文件，不需要路径更新
    return file;
  }

  @override
  Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? path,
    String? folderId,
  }) {
    // TODO: implement getFileList
    throw UnimplementedError();
  }
}
