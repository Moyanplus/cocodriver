import '../../../core/services/base/debug_service.dart';
import '../../models/cloud_drive_models.dart';
import '../../base/cloud_drive_operation_service.dart';
import 'ali_cloud_drive_service.dart';
import 'ali_config.dart';
import 'ali_file_list_service.dart';
import 'ali_file_operation_service.dart';

/// 阿里云盘操作策略
/// 实现CloudDriveOperationStrategy，提供阿里云盘特定的操作
class AliCloudDriveOperationStrategy implements CloudDriveOperationStrategy {
  @override
  Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? path,
    String? folderId,
  }) async {
    try {
      DebugService.log(
        '📁 阿里云盘 - 获取文件列表: path=$path, folderId=$folderId',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );

      // 首先获取drive_id
      final driveId = await AliCloudDriveService.getDriveId(account: account);
      if (driveId == null) {
        DebugService.log(
          '❌ 阿里云盘 - 无法获取drive_id，文件列表获取失败',
          category: DebugCategory.tools,
          subCategory: AliConfig.logSubCategory,
        );
        return [];
      }

      // 使用专门的文件列表服务获取文件
      final files = await AliFileListService.getFileList(
        account: account,
        driveId: driveId,
        parentFileId: folderId ?? 'root',
      );

      DebugService.log(
        '✅ 阿里云盘 - 文件列表获取完成: ${files.length} 个文件',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );

      return files;
    } catch (e) {
      DebugService.log(
        '❌ 阿里云盘 - 获取文件列表异常: $e',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );
      return [];
    }
  }

  @override
  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    try {
      final result = await AliCloudDriveService.getAccountDetails(
        account: account,
      );
      return result;
    } catch (e) {
      DebugService.log(
        '❌ 阿里云盘 - 获取账号详情异常: $e',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    try {
      DebugService.log(
        '📁 阿里云盘 - 创建文件夹: name=$folderName, parentFolderId=$parentFolderId',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );

      // 使用专门的文件操作服务创建文件夹
      final createdFolder = await AliFileOperationService.createFolder(
        account: account,
        folderName: folderName,
        parentFolderId: parentFolderId,
      );

      if (createdFolder != null) {
        DebugService.log(
          '✅ 阿里云盘 - 文件夹创建操作完成: ${createdFolder.name} (ID: ${createdFolder.id})',
          category: DebugCategory.tools,
          subCategory: AliConfig.logSubCategory,
        );

        // 返回创建成功的文件夹信息
        return {
          'success': true,
          'file': {
            'id': createdFolder.id,
            'name': createdFolder.name,
            'isFolder': createdFolder.isFolder,
            'folderId': createdFolder.folderId,
            'modifiedTime': createdFolder.modifiedTime,
          },
        };
      } else {
        DebugService.log(
          '❌ 阿里云盘 - 文件夹创建操作失败: $folderName',
          category: DebugCategory.tools,
          subCategory: AliConfig.logSubCategory,
        );
        return null;
      }
    } catch (e) {
      DebugService.log(
        '❌ 阿里云盘 - 创建文件夹异常: $e',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );
      return null;
    }
  }

  @override
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      DebugService.log(
        '🗑️ 阿里云盘 - 删除文件: ${file.name}',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );

      // TODO: 实现阿里云盘删除文件
      // 这里需要实现具体的API调用逻辑

      return false;
    } catch (e) {
      DebugService.log(
        '❌ 阿里云盘 - 删除文件异常: $e',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );
      return false;
    }
  }

  @override
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    try {
      DebugService.log(
        '📋 阿里云盘 - 移动文件: ${file.name} -> $targetFolderId',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );

      if (targetFolderId == null) {
        DebugService.log(
          '❌ 阿里云盘 - 目标文件夹ID为空，移动失败',
          category: DebugCategory.tools,
          subCategory: AliConfig.logSubCategory,
        );
        return false;
      }

      // 使用专门的文件操作服务进行移动
      final success = await AliFileOperationService.moveFile(
        account: account,
        file: file,
        targetFolderId: targetFolderId,
      );

      if (success) {
        DebugService.log(
          '✅ 阿里云盘 - 文件移动操作完成: ${file.name} -> $targetFolderId',
          category: DebugCategory.tools,
          subCategory: AliConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 阿里云盘 - 文件移动操作失败: ${file.name} -> $targetFolderId',
          category: DebugCategory.tools,
          subCategory: AliConfig.logSubCategory,
        );
      }

      return success;
    } catch (e) {
      DebugService.log(
        '❌ 阿里云盘 - 移动文件异常: $e',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );
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
      DebugService.log(
        '📄 阿里云盘 - 复制文件: ${file.name} -> $destPath',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );

      // 阿里云盘暂不支持复制操作
      DebugService.log(
        '⚠️ 阿里云盘暂不支持复制操作',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );

      return false;
    } catch (e) {
      DebugService.log(
        '❌ 阿里云盘 - 复制文件异常: $e',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );
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
      DebugService.log(
        '✏️ 阿里云盘 - 重命名文件: ${file.name} -> $newName',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );

      // 使用专门的文件操作服务进行重命名
      final success = await AliFileOperationService.renameFile(
        account: account,
        file: file,
        newName: newName,
      );

      if (success) {
        DebugService.log(
          '✅ 阿里云盘 - 文件重命名操作完成: ${file.name} -> $newName',
          category: DebugCategory.tools,
          subCategory: AliConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 阿里云盘 - 文件重命名操作失败: ${file.name} -> $newName',
          category: DebugCategory.tools,
          subCategory: AliConfig.logSubCategory,
        );
      }

      return success;
    } catch (e) {
      DebugService.log(
        '❌ 阿里云盘 - 重命名文件异常: $e',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );
      return false;
    }
  }

  @override
  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      DebugService.log(
        '🔗 阿里云盘 - 获取下载链接: ${file.name}',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );

      // 使用专门的文件操作服务获取下载链接
      final downloadUrl = await AliFileOperationService.getDownloadUrl(
        account: account,
        file: file,
      );

      if (downloadUrl != null) {
        DebugService.log(
          '✅ 阿里云盘 - 下载链接获取操作完成: ${file.name}',
          category: DebugCategory.tools,
          subCategory: AliConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 阿里云盘 - 下载链接获取操作失败: ${file.name}',
          category: DebugCategory.tools,
          subCategory: AliConfig.logSubCategory,
        );
      }

      return downloadUrl;
    } catch (e) {
      DebugService.log(
        '❌ 阿里云盘 - 获取下载链接异常: $e',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );
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
      DebugService.log(
        '🚀 阿里云盘 - 获取高速下载链接: ${file.name}',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );

      // TODO: 实现阿里云盘高速下载
      return null;
    } catch (e) {
      DebugService.log(
        '❌ 阿里云盘 - 获取高速下载链接异常: $e',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );
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
      DebugService.log(
        '🔗 阿里云盘 - 创建分享链接: ${files.length}个文件',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );

      // TODO: 实现阿里云盘分享链接创建
      return null;
    } catch (e) {
      DebugService.log(
        '❌ 阿里云盘 - 创建分享链接异常: $e',
        category: DebugCategory.tools,
        subCategory: AliConfig.logSubCategory,
      );
      return null;
    }
  }

  @override
  String convertPathToTargetFolderId(List<PathInfo> folderPath) {
    // 阿里云盘使用文件夹ID而不是路径
    if (folderPath.isEmpty) {
      return 'root'; // 根目录
    }

    // 返回最后一个路径项的ID
    return folderPath.last.id;
  }

  @override
  CloudDriveFile updateFilePathForTargetDirectory(
    CloudDriveFile file,
    String targetPath,
  ) {
    // 阿里云盘使用ID系统，更新文件的路径信息
    return CloudDriveFile(
      id: file.id,
      name: file.name,
      size: file.size,
      modifiedTime: file.modifiedTime,
      isFolder: file.isFolder,
      folderId: targetPath, // 使用targetPath作为新的folderId
    );
  }

  @override
  Map<String, bool> getSupportedOperations() =>
      AliConfig.getSupportedOperationsStatus();

  @override
  Map<String, dynamic> getOperationUIConfig() => {
    'supportsCreateFolder': true,
    'supportsMove': true,
    'supportsDelete': true,
    'supportsRename': true,
    'supportsDownload': true,
    'supportsCopy': false, // 阿里云盘暂不支持复制
    'supportsShare': true,
    'maxFileNameLength': 255,
    'allowedCharacters': r'^[^\\/:*?"<>|]*$',
    'folderIcon': 'folder',
    'fileIcon': 'description',
  };
}
