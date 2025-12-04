import '../../../../../../core/logging/log_manager.dart';
import '../../../../base/cloud_drive_operation_service.dart';
import '../../../../data/models/cloud_drive_dtos.dart';
import '../../../../data/models/cloud_drive_entities.dart';
import '../../../../utils/cloud_drive_log_utils.dart';
import '../../../../core/result.dart';
import '../repository/ali_repository.dart';
import '../api/ali_api_client.dart';
import '../models/responses/ali_share_record.dart';

/// 阿里云盘操作策略
///
/// 实现 CloudDriveOperationStrategy 接口，提供阿里云盘特定的操作实现。
class AliCloudDriveOperationStrategy implements CloudDriveOperationStrategy {
  AliCloudDriveOperationStrategy();

  final AliRepository _repository = AliRepository();
  final AliApiClient _client = AliApiClient();
  static const Map<String, bool> _supportedOperations = {
    'getFileList': true,
    'getAccountDetails': true,
    'createFolder': true,
    'rename': true,
    'move': true,
    'copy': false,
    'delete': true,
    'download': true,
    'upload': true,
    'share': false,
    'share_records': true,
    'preview': false,
    'recycle': true,
  };

  @override
  Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? path,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      LogManager().cloudDrive('阿里云盘 - 获取文件列表: path=$path, folderId=$folderId');

      final items = await _repository.listFiles(
        account: account,
        folderId: folderId ?? 'root',
        page: page,
        pageSize: pageSize,
      );

      final folders = items.where((f) => f.isFolder).toList();
      final files = items.where((f) => !f.isFolder).toList();
      CloudDriveLogUtils.logFileListSummary(
        provider: '阿里云盘',
        files: files,
        folders: folders,
      );

      return items;
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 获取文件列表异常: $e');
      return [];
    }
  }

  /// 回收站列表
  Future<List<CloudDriveFile>> listRecycle({
    required CloudDriveAccount account,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      return _repository.listRecycle(
        account: account,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 获取回收站异常: $e');
      return const [];
    }
  }

  /// 分享记录列表
  Future<List<AliShareRecord>> listShareRecords({
    required CloudDriveAccount account,
    int limit = 20,
  }) async {
    try {
      return _repository.listShareRecords(account: account, limit: limit);
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 获取分享列表异常: $e');
      return const [];
    }
  }

  @override
  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    try {
      return await _client.getAccountDetails(account: account);
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 获取账号详情异常: $e');
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
      LogManager().cloudDrive(
        '阿里云盘 - 创建文件夹: name=$folderName, parentFolderId=$parentFolderId',
      );

      final createdFolder = await _repository.createFolder(
        account: account,
        name: folderName,
        parentId: parentFolderId,
      );

      if (createdFolder != null) {
        LogManager().cloudDrive(
          '阿里云盘 - 文件夹创建操作完成: ${createdFolder.name} (ID: ${createdFolder.id})',
        );

        // 返回创建成功的文件夹信息
        return {
          'success': true,
          'folder': createdFolder,
        };
      } else {
        LogManager().cloudDrive('阿里云盘 - 文件夹创建操作失败: $folderName');
        return null;
      }
    } on CloudDriveException {
      rethrow;
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 创建文件夹异常: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      LogManager().cloudDrive('阿里云盘 - 删除文件: ${file.name}');

      return await _repository.delete(account: account, file: file);
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 删除文件异常: $e');
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
      LogManager().cloudDrive('阿里云盘 - 移动文件: ${file.name} -> $targetFolderId');

      if (targetFolderId == null) {
        LogManager().cloudDrive('阿里云盘 - 目标文件夹ID为空，移动失败');
        return false;
      }

      final success = await _repository.move(
        account: account,
        file: file,
        targetFolderId: targetFolderId,
      );

      if (success) {
        LogManager().cloudDrive(
          '阿里云盘 - 文件移动操作完成: ${file.name} -> $targetFolderId',
        );
      } else {
        LogManager().cloudDrive(
          '阿里云盘 - 文件移动操作失败: ${file.name} -> $targetFolderId',
        );
      }

      return success;
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 移动文件异常: $e');
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
      LogManager().cloudDrive('阿里云盘 - 复制文件: ${file.name} -> $destPath');

      // 阿里云盘暂不支持复制操作
      LogManager().cloudDrive('阿里云盘暂不支持复制操作');

      return false;
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 复制文件异常: $e');
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
      LogManager().cloudDrive('阿里云盘 - 重命名文件: ${file.name} -> $newName');

      final success = await _repository.rename(
        account: account,
        file: file,
        newName: newName,
      );

      if (success) {
        LogManager().cloudDrive('阿里云盘 - 文件重命名操作完成: ${file.name} -> $newName');
      } else {
        LogManager().cloudDrive('阿里云盘 - 文件重命名操作失败: ${file.name} -> $newName');
      }

      return success;
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 重命名文件异常: $e');
      return false;
    }
  }

  @override
  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      LogManager().cloudDrive('阿里云盘 - 获取下载链接: ${file.name}');

      final downloadUrl = await _repository.getDirectLink(
        account: account,
        file: file,
      );

      if (downloadUrl != null) {
        LogManager().cloudDrive('阿里云盘 - 下载链接获取操作完成: ${file.name}');
      } else {
        LogManager().cloudDrive('阿里云盘 - 下载链接获取操作失败: ${file.name}');
      }

      return downloadUrl;
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 获取下载链接异常: $e');
      return null;
    }
  }

  @override
  Future<CloudDrivePreviewResult?> getPreviewInfo({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    LogManager().cloudDrive('阿里云盘 - 暂未实现预览接口');
    return null;
  }

  @override
  Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    try {
      LogManager().cloudDrive('阿里云盘 - 获取高速下载链接: ${file.name}');

      // TODO: 实现阿里云盘高速下载
      return null;
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 获取高速下载链接异常: $e');
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
      LogManager().cloudDrive('阿里云盘 - 创建分享链接: ${files.length}个文件');

      // TODO: 实现阿里云盘分享链接创建
      return null;
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 创建分享链接异常: $e');
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
      isFolder: file.isFolder,
      folderId: targetPath, // 使用targetPath作为新的folderId
      createdAt: file.createdAt,
      updatedAt: file.updatedAt,
      description: file.description,
      path: targetPath,
      downloadUrl: file.downloadUrl,
      thumbnailUrl: file.thumbnailUrl,
      bigThumbnailUrl: file.bigThumbnailUrl,
      previewUrl: file.previewUrl,
      metadata: file.metadata,
      category: file.category,
      downloadCount: file.downloadCount,
      shareCount: file.shareCount,
    );
  }

  @override
  Map<String, bool> getSupportedOperations() => _supportedOperations;

  @override
  Future<Map<String, dynamic>> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String? folderId,
    UploadProgressCallback? onProgress,
  }) async {
    LogManager().cloudDrive('阿里云盘 - 上传文件开始');
    LogManager().cloudDrive('文件路径: $filePath');
    LogManager().cloudDrive('文件名: $fileName');
    LogManager().cloudDrive('文件夹ID: ${folderId ?? 'root'}');

    try {
      final uploaded = await _repository.uploadFile(
        account: account,
        filePath: filePath,
        fileName: fileName,
        parentId: folderId,
        onProgress: onProgress,
      );
      final success = uploaded != null;
      if (success) {
        LogManager().cloudDrive('阿里云盘 - 上传文件成功: ${uploaded.name}');
      } else {
        LogManager().cloudDrive('阿里云盘 - 上传文件失败');
      }
      return {'success': success, 'file': uploaded};
    } catch (e, stackTrace) {
      LogManager().cloudDrive('阿里云盘 - 上传文件异常: $e');
      LogManager().cloudDrive('阿里云盘 - 错误堆栈: $stackTrace');
      return {'success': false, 'message': e.toString()};
    }
  }

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

  /// 搜索文件
  ///
  /// [account] 阿里云盘账号信息
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
    LogManager().cloudDrive('阿里云盘 - 搜索文件功能暂未实现');
    return [];
  }

  /// 刷新鉴权信息
  ///
  /// [account] 阿里云盘账号信息
  /// 返回刷新后的账号信息，如果刷新失败返回null
  @override
  Future<CloudDriveAccount?> refreshAuth({
    required CloudDriveAccount account,
  }) async {
    LogManager().cloudDrive('阿里云盘 - 刷新鉴权信息功能暂未实现');
    return null;
  }
}
