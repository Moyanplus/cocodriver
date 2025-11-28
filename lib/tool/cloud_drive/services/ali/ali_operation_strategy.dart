import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import '../../base/cloud_drive_operation_service.dart';
import 'ali_cloud_drive_service.dart';
import 'ali_config.dart';
import 'ali_repository.dart';

/// 阿里云盘操作策略
///
/// 实现 CloudDriveOperationStrategy 接口，提供阿里云盘特定的操作实现。
class AliCloudDriveOperationStrategy implements CloudDriveOperationStrategy {
  AliCloudDriveOperationStrategy();

  final AliRepository _repository = AliRepository();

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

      final files = await _repository.listFiles(
        account: account,
        folderId: folderId ?? 'root',
        page: page,
        pageSize: pageSize,
      );

      LogManager().cloudDrive('阿里云盘 - 文件列表获取完成: ${files.length} 个文件');

      return files;
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 获取文件列表异常: $e');
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
          'file': {
            'id': createdFolder.id,
            'name': createdFolder.name,
            'isFolder': createdFolder.isFolder,
            'folderId': createdFolder.folderId,
            'modifiedTime': createdFolder.modifiedTime,
          },
        };
      } else {
        LogManager().cloudDrive('阿里云盘 - 文件夹创建操作失败: $folderName');
        return null;
      }
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
      modifiedTime: file.modifiedTime,
      isFolder: file.isFolder,
      folderId: targetPath, // 使用targetPath作为新的folderId
    );
  }

  @override
  Map<String, bool> getSupportedOperations() =>
      AliConfig.getSupportedOperationsStatus();

  @override
  Future<Map<String, dynamic>> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String? folderId,
  }) async {
    LogManager().cloudDrive('阿里云盘 - 上传文件开始');
    LogManager().cloudDrive('文件路径: $filePath');
    LogManager().cloudDrive('文件名: $fileName');
    LogManager().cloudDrive('文件夹ID: ${folderId ?? 'root'}');

    try {
      // TODO: 实现阿里云盘上传功能
      LogManager().cloudDrive('阿里云盘 - 上传功能暂未实现');
      return {'success': false, 'message': '阿里云盘上传功能暂未实现'};
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
