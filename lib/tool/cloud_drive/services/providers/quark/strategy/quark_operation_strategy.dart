import '../../../../base/cloud_drive_operation_service.dart';
import '../../../../data/models/cloud_drive_entities.dart';
import '../../../../data/models/cloud_drive_dtos.dart';
import '../api/quark_config.dart';
import '../services/quark_account_service.dart';
import '../utils/quark_logger.dart';
import '../quark_repository.dart';

/// 夸克云盘操作策略
///
/// 实现 CloudDriveOperationStrategy 接口，提供夸克云盘特定的操作实现。
class QuarkCloudDriveOperationStrategy implements CloudDriveOperationStrategy {
  QuarkCloudDriveOperationStrategy();

  final QuarkRepository _repository = QuarkRepository();

  @override
  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    QuarkLogger.info('夸克云盘 - 获取下载链接开始');
    QuarkLogger.info('文件信息: ${file.name} (ID: ${file.id})');
    QuarkLogger.info('账号信息: ${account.name} (${account.type.displayName})');

    try {
      // 解析文件大小
      int? fileSize;
      if (file.size != null && file.size! > 0) {
        // 直接使用int类型的size
        fileSize = file.size;
      }

      final downloadUrl = await _repository.getDirectLink(
        account: account,
        file: file,
      );

      if (downloadUrl != null) {
        final preview =
            downloadUrl.length > 100
                ? '${downloadUrl.substring(0, 100)}...'
                : downloadUrl;
        QuarkLogger.info('夸克云盘 - 下载链接获取成功: $preview');
        return downloadUrl;
      }

      QuarkLogger.info('夸克云盘 - 下载链接获取失败: 返回null');
      return null;
    } catch (e, stackTrace) {
      QuarkLogger.info('夸克云盘 - 获取下载链接异常: $e');
      QuarkLogger.info('错误堆栈: $stackTrace');
      return null;
    }
  }

  @override
  Future<CloudDrivePreviewResult?> getPreviewInfo({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    QuarkLogger.info('夸克云盘 - 暂未实现预览接口');
    return null;
  }

  @override
  Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    QuarkLogger.info('夸克云盘 - 获取高速下载链接开始');

    try {
      // 这里需要实现夸克云盘的高速下载链接获取逻辑
      QuarkLogger.info('夸克云盘 - 高速下载链接功能暂未实现');
      return null;
    } catch (e, stackTrace) {
      QuarkLogger.info('夸克云盘 - 获取高速下载链接异常: $e');
      QuarkLogger.info('错误堆栈: $stackTrace');
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
    QuarkLogger.info('夸克云盘 - 创建分享链接开始');
    QuarkLogger.info('文件数量: ${files.length}');

    try {
      final shareUrl = await _repository.createShareLink(
        account: account,
        files: files,
        password: password,
        expireDays: expireDays,
      );

      if (shareUrl != null) {
        QuarkLogger.info('夸克云盘 - 分享链接创建成功: $shareUrl');
        return shareUrl;
      }

      QuarkLogger.info('夸克云盘 - 分享链接创建失败');
      return null;
    } catch (e, stackTrace) {
      QuarkLogger.info('夸克云盘 - 创建分享链接异常: $e');
      QuarkLogger.info('错误堆栈: $stackTrace');
      return null;
    }
  }

  @override
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    QuarkLogger.info('夸克云盘 - 删除文件开始');
    QuarkLogger.info('文件信息: ${file.name} (ID: ${file.id})');

    try {
      final success = await _repository.delete(account: account, file: file);

      if (success) {
        QuarkLogger.info('夸克云盘 - 文件删除成功: ${file.name}');
        return true;
      } else {
        QuarkLogger.info('夸克云盘 - 文件删除失败');
        return false;
      }
    } catch (e, stackTrace) {
      QuarkLogger.info('夸克云盘 - 删除文件异常: $e');
      QuarkLogger.info('错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    QuarkLogger.info('夸克云盘 - 移动文件开始');
    QuarkLogger.info('文件信息: ${file.name} (ID: ${file.id})');
    QuarkLogger.info('目标文件夹ID: $targetFolderId');

    try {
      final success = await _repository.move(
        account: account,
        file: file,
        targetFolderId: targetFolderId ?? '',
      );

      if (success) {
        QuarkLogger.info('夸克云盘 - 文件移动成功: ${file.name}');
        return true;
      } else {
        QuarkLogger.info('夸克云盘 - 文件移动失败');
        return false;
      }
    } catch (e, stackTrace) {
      QuarkLogger.info('夸克云盘 - 移动文件异常: $e');
      QuarkLogger.info('错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    QuarkLogger.info('夸克云盘 - 重命名文件开始');
    QuarkLogger.info('文件信息: ${file.name} (ID: ${file.id})');
    QuarkLogger.info('新名称: $newName');

    try {
      final result = await _repository.rename(
        account: account,
        file: file,
        newName: newName,
      );

      if (result) {
        QuarkLogger.info('夸克云盘 - 重命名文件成功: ${file.name} -> $newName');
      } else {
        QuarkLogger.info('夸克云盘 - 重命名文件失败: ${file.name} -> $newName');
      }

      return result;
    } catch (e) {
      QuarkLogger.info('夸克云盘 - 重命名文件异常: $e');
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
    QuarkLogger.info('夸克云盘 - 复制文件开始');
    QuarkLogger.info('文件信息: ${file.name} (ID: ${file.id})');
    QuarkLogger.info('目标路径: $destPath');
    QuarkLogger.info('新名称: $newName');

    try {
      final success = await _repository.copy(
        account: account,
        file: file,
        targetFolderId: destPath,
      );

      if (success) {
        QuarkLogger.info('夸克云盘 - 复制文件成功: ${file.name}');
        // 注意：夸克云盘不支持在复制时直接重命名，如果需要新名称，需要复制后再重命名
        if (newName != null && newName != file.name) {
          QuarkLogger.info('夸克云盘复制时不支持重命名，忽略新名称: $newName');
        }
      } else {
        QuarkLogger.info('夸克云盘 - 复制文件失败');
      }

      return success;
    } catch (e, stackTrace) {
      QuarkLogger.info('夸克云盘 - 复制文件异常: $e');
      QuarkLogger.info('错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    QuarkLogger.info('夸克云盘 - 创建文件夹开始');
    QuarkLogger.info('文件夹名称: $folderName');
    QuarkLogger.info('父文件夹ID: $parentFolderId');

    try {
      final folder = await _repository.createFolder(
        account: account,
        name: folderName,
        parentId: parentFolderId,
      );

      if (folder != null) {
        QuarkLogger.info('夸克云盘 - 文件夹创建成功: $folderName');
        return {'success': true, 'folder': folder};
      }

      QuarkLogger.info('夸克云盘 - 文件夹创建失败');
      return {'success': false, 'message': '文件夹创建失败'};
    } catch (e, stackTrace) {
      QuarkLogger.info('夸克云盘 - 创建文件夹异常: $e');
      QuarkLogger.info('错误堆栈: $stackTrace');

      return {'success': false, 'message': '文件夹创建异常: $e'};
    }
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
      final fileList = await _repository.listFiles(
        account: account,
        folderId: folderId,
        page: page,
        pageSize: pageSize,
      );
      return fileList;
    } catch (e) {
      QuarkLogger.info('夸克云盘 - 获取文件列表异常: $e');
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
    QuarkLogger.info('夸克云盘 - 上传文件开始');
    QuarkLogger.info('文件路径: $filePath');
    QuarkLogger.info('文件名: $fileName');
    QuarkLogger.info('文件夹ID: ${folderId ?? '0'}');

    try {
      // TODO: 实现夸克云盘上传功能
      QuarkLogger.info('夸克云盘 - 上传功能暂未实现');
      return {'success': false, 'message': '夸克云盘上传功能暂未实现'};
    } catch (e, stackTrace) {
      QuarkLogger.error('夸克云盘 - 上传文件异常: $e');
      QuarkLogger.error('夸克云盘 - 错误堆栈: $stackTrace');
      return {'success': false, 'message': e.toString()};
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
    QuarkLogger.info('夸克云盘 - 开始获取账号详情');

    try {
      final accountDetails = await QuarkAccountService.getAccountDetails(
        account: account,
      );

      if (accountDetails != null) {
        QuarkLogger.info('夸克云盘 - 账号详情获取成功');
        return accountDetails;
      } else {
        QuarkLogger.info('夸克云盘 - 账号详情获取失败: 返回null');
        return null;
      }
    } catch (e, stackTrace) {
      QuarkLogger.info('夸克云盘 - 获取账号详情异常: $e');
      QuarkLogger.info('错误堆栈: $stackTrace');
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

  /// 搜索文件
  ///
  /// [account] 夸克云盘账号信息
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
    QuarkLogger.info('夸克云盘 - 搜索文件功能暂未实现');
    return [];
  }

  /// 刷新鉴权信息
  ///
  /// [account] 夸克云盘账号信息
  /// 返回刷新后的账号信息，如果刷新失败返回null
  @override
  Future<CloudDriveAccount?> refreshAuth({
    required CloudDriveAccount account,
  }) async {
    QuarkLogger.info('夸克云盘 - 刷新鉴权信息功能暂未实现');
    return null;
  }
}
