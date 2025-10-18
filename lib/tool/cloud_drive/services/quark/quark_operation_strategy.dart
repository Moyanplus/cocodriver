import '../../../core/services/base/debug_service.dart';
import '../../base/cloud_drive_operation_service.dart';
import '../../models/cloud_drive_models.dart';
import 'quark_cloud_drive_service.dart';
import 'quark_config.dart';
import 'quark_file_list_service.dart';
import 'quark_file_operation_service.dart';

/// 夸克云盘操作策略
class QuarkCloudDriveOperationStrategy implements CloudDriveOperationStrategy {
  @override
  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    DebugService.log(
      '🔗 夸克云盘 - 获取下载链接开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📄 文件信息: ${file.name} (ID: ${file.id})',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      // 解析文件大小
      int? fileSize;
      if (file.size != null && file.size! > 0) {
        // 直接使用int类型的size
        fileSize = file.size;
      }

      final downloadUrl = await QuarkCloudDriveService.getDownloadUrl(
        account: account,
        fileId: file.id,
        fileName: file.name,
        size: fileSize,
      );

      if (downloadUrl != null) {
        final preview =
            downloadUrl.length > 100
                ? '${downloadUrl.substring(0, 100)}...'
                : downloadUrl;
        DebugService.log(
          '✅ 夸克云盘 - 下载链接获取成功: $preview',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 夸克云盘 - 下载链接获取失败: 返回null',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
      }

      return downloadUrl;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 获取下载链接异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
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
    DebugService.log(
      '🚀 夸克云盘 - 获取高速下载链接开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      // 这里需要实现夸克云盘的高速下载链接获取逻辑
      DebugService.log(
        '⚠️ 夸克云盘 - 高速下载链接功能暂未实现',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return null;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 获取高速下载链接异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
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
    DebugService.log(
      '🔗 夸克云盘 - 创建分享链接开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📄 文件数量: ${files.length}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      if (files.isEmpty) {
        throw Exception('文件列表为空');
      }

      // 目前只支持单个文件分享
      final file = files.first;
      final expiredType = QuarkConfig.getShareExpiredType(expireDays);

      final result = await QuarkCloudDriveService.createShareLink(
        account: account,
        fileIds: [file.id],
        title: file.name,
        passcode: password,
        expiredType: expiredType,
      );

      if (result != null) {
        final shareUrl = result['shareUrl']?.toString();
        DebugService.log(
          '✅ 夸克云盘 - 分享链接创建成功: $shareUrl',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return shareUrl;
      } else {
        DebugService.log(
          '❌ 夸克云盘 - 分享链接创建失败: 返回null',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return null;
      }
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 创建分享链接异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return null;
    }
  }

  @override
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    DebugService.log(
      '🗑️ 夸克云盘 - 删除文件开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📄 文件信息: ${file.name} (ID: ${file.id})',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      final success = await QuarkFileOperationService.deleteFile(
        account: account,
        file: file,
      );

      if (success) {
        DebugService.log(
          '✅ 夸克云盘 - 文件删除成功: ${file.name}',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return true;
      } else {
        DebugService.log(
          '❌ 夸克云盘 - 文件删除失败',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return false;
      }
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 删除文件异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
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
    DebugService.log(
      '🚚 夸克云盘 - 移动文件开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📄 文件信息: ${file.name} (ID: ${file.id})',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📁 目标文件夹ID: $targetFolderId',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      final success = await QuarkFileOperationService.moveFile(
        account: account,
        file: file,
        targetFolderId: targetFolderId ?? '',
      );

      if (success) {
        DebugService.log(
          '✅ 夸克云盘 - 文件移动成功: ${file.name}',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return true;
      } else {
        DebugService.log(
          '❌ 夸克云盘 - 文件移动失败',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return false;
      }
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 移动文件异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
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
    DebugService.log(
      '✏️ 夸克云盘 - 重命名文件开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📄 文件信息: ${file.name} (ID: ${file.id})',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '🆕 新名称: $newName',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      final result = await QuarkFileOperationService.renameFile(
        account: account,
        file: file,
        newName: newName,
      );

      if (result) {
        DebugService.log(
          '✅ 夸克云盘 - 重命名文件成功: ${file.name} -> $newName',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 夸克云盘 - 重命名文件失败: ${file.name} -> $newName',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
      }

      return result;
    } catch (e) {
      DebugService.log(
        '❌ 夸克云盘 - 重命名文件异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
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
    DebugService.log(
      '📋 夸克云盘 - 复制文件开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📄 文件信息: ${file.name} (ID: ${file.id})',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📁 目标路径: $destPath',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '🆕 新名称: $newName',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      // 这里需要实现夸克云盘的复制文件逻辑
      DebugService.log(
        '⚠️ 夸克云盘 - 复制文件功能暂未实现',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return false;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 复制文件异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    DebugService.log(
      '📁 夸克云盘 - 创建文件夹开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📁 文件夹名称: $folderName',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📁 父文件夹ID: $parentFolderId',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      final result = await QuarkCloudDriveService.createFolder(
        account: account,
        folderName: folderName,
        parentFolderId: parentFolderId,
      );

      if (result != null && result['success'] == true) {
        DebugService.log(
          '✅ 夸克云盘 - 文件夹创建成功: $folderName',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );

        // 直接返回服务层的结果，它已经包含了folder对象
        return result;
      } else {
        DebugService.log(
          '❌ 夸克云盘 - 文件夹创建失败',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );

        return {'success': false, 'message': result?['message'] ?? '文件夹创建失败'};
      }
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 创建文件夹异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      return {'success': false, 'message': '文件夹创建异常: $e'};
    }
  }

  @override
  Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? path,
    String? folderId,
  }) async {
    try {
      final fileList = await QuarkFileListService.getFileList(
        account: account,
        parentFileId: folderId ?? '0',
      );
      return fileList;
    } catch (e) {
      DebugService.log(
        '❌ 夸克云盘 - 获取文件列表异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return [];
    }
  }

  @override
  Map<String, bool> getSupportedOperations() =>
      QuarkConfig.getSupportedOperationsStatus();

  @override
  Map<String, dynamic> getOperationUIConfig() =>
      QuarkConfig.getOperationUIConfig();

  @override
  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    DebugService.log(
      '📋 夸克云盘 - 开始获取账号详情',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      final accountDetails = await QuarkCloudDriveService.getAccountDetails(
        account: account,
      );

      if (accountDetails != null) {
        DebugService.log(
          '✅ 夸克云盘 - 账号详情获取成功',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return accountDetails;
      } else {
        DebugService.log(
          '❌ 夸克云盘 - 账号详情获取失败: 返回null',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return null;
      }
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 获取账号详情异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return null;
    }
  }

  @override
  String convertPathToTargetFolderId(List<PathInfo> folderPath) {
    if (folderPath.isEmpty) {
      return '';
    }
    // 夸克云盘使用最后一级路径ID
    return folderPath.last.id;
  }

  @override
  CloudDriveFile updateFilePathForTargetDirectory(
    CloudDriveFile file,
    String targetPath,
  ) {
    // 夸克云盘暂时返回原文件，不需要路径更新
    return file;
  }
}
