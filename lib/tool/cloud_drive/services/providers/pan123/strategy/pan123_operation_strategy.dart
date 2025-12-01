import '../../../../../../core/logging/log_manager.dart';
import '../../../../core/result.dart';
import '../../../../base/cloud_drive_operation_service.dart';
import '../../../../data/models/cloud_drive_entities.dart';
import '../../../../data/models/cloud_drive_dtos.dart';
import '../../../../utils/cloud_drive_log_utils.dart';
import '../models/responses/pan123_offline_responses.dart';
import '../utils/pan123_utils.dart';
import '../repository/pan123_repository.dart';

/// 123云盘操作策略
///
/// 实现 CloudDriveOperationStrategy 接口，提供123云盘特定的操作实现。
class Pan123CloudDriveOperationStrategy implements CloudDriveOperationStrategy {
  Pan123CloudDriveOperationStrategy();

  final Pan123Repository _repository = Pan123Repository();

  @override
  /// 获取下载链接（不带加速）
  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    LogManager().cloudDrive('123云盘 - 获取下载链接开始');
    LogManager().cloudDrive('123云盘 - 文件信息: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive(
      '123云盘 - 账号信息: ${account.name} (${account.type.displayName})',
    );

    try {
      // 使用配置中的文件大小解析方法
      final fileSize = Pan123Utils.parseFileSize(file.size?.toString());

      LogManager().cloudDrive('📏 123云盘 - 解析的文件大小: $fileSize bytes');

      // 从文件信息中提取S3KeyFlag和Etag
      String? s3keyFlag;
      String? etag;

      // TODO: 如果需要从其他地方获取s3keyFlag和etag，请在这里实现
      // 目前CloudDriveFile模型中没有downloadUrl字段，所以设置为null
      s3keyFlag = null;
      etag = null;

      LogManager().cloudDrive(
        '123云盘 - 提取的参数: s3keyFlag=$s3keyFlag, etag=$etag',
      );

      final downloadUrl = await _repository.getDirectLink(
        account: account,
        file: file,
      );

      if (downloadUrl != null) {
        final preview =
            downloadUrl.length > 100
                ? '${downloadUrl.substring(0, 100)}...'
                : downloadUrl;
        LogManager().cloudDrive('123云盘 - 下载链接获取成功: $preview');
      } else {
        LogManager().cloudDrive('123云盘 - 下载链接获取失败');
      }

      return downloadUrl;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('123云盘 - 获取下载链接异常: $e');
      LogManager().cloudDrive('123云盘 - 错误堆栈: $stackTrace');
      return null;
    }
  }

  @override
  /// 获取预览信息（当前未实现）
  Future<CloudDrivePreviewResult?> getPreviewInfo({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    LogManager().cloudDrive('123云盘 - 暂未实现预览接口');
    return null;
  }

  @override
  /// 请求高速下载链接（预留扩展）
  Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    try {
      LogManager().cloudDrive('123云盘 - 高速下载: ${file.name}');

      // TODO: 实现123云盘高速下载
      // 这里需要调用第三方解析服务

      return null;
    } catch (e) {
      LogManager().error('123云盘高速下载失败');
      return null;
    }
  }

  @override
  /// 创建分享链接（待实现，当前返回 null）
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    try {
      LogManager().cloudDrive('123云盘 - 生成分享链接');

      // TODO: 实现123云盘分享链接生成
      // 这里需要调用123云盘的API来生成分享链接

      return null;
    } catch (e) {
      LogManager().error('123云盘生成分享链接失败');
      return null;
    }
  }

  @override
  /// 移动文件
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    try {
      LogManager().cloudDrive('123云盘 - 移动文件开始');
      LogManager().cloudDrive('123云盘 - 文件信息: ${file.name} (ID: ${file.id})');
      LogManager().cloudDrive('123云盘 - 目标文件夹ID: ${targetFolderId ?? '根目录'}');
      LogManager().cloudDrive(
        '123云盘 - 账号信息: ${account.name} (${account.type.displayName})',
      );

      final success = await _repository.move(
        account: account,
        file: file,
        targetFolderId: targetFolderId ?? '0',
      );

      if (success) {
        LogManager().cloudDrive(
          '123云盘 - 文件移动成功: ${file.name} -> ${targetFolderId ?? '根目录'}',
        );
      } else {
        LogManager().cloudDrive(
          '123云盘 - 文件移动失败: ${file.name} -> ${targetFolderId ?? '根目录'}',
        );
      }

      return success;
    } on CloudDriveException {
      rethrow;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('123云盘 - 移动文件异常: $e');
      LogManager().cloudDrive('123云盘 - 错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  /// 删除文件
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      LogManager().cloudDrive('123云盘 - 删除文件开始');
      LogManager().cloudDrive('123云盘 - 文件信息: ${file.name} (ID: ${file.id})');
      LogManager().cloudDrive(
        '123云盘 - 账号信息: ${account.name} (${account.type.displayName})',
      );

      // 解析文件大小
      if (file.size != null && file.size! > 0) {
        // 直接使用int类型的size
      }

      // 从文件信息中提取S3KeyFlag和Etag
      String? s3keyFlag;
      String? etag;

      // TODO: 如果需要从其他地方获取s3keyFlag和etag，请在这里实现
      // 目前CloudDriveFile模型中没有downloadUrl字段，所以设置为null
      s3keyFlag = null;
      etag = null;

      final success = await _repository.delete(account: account, file: file);

      if (success) {
        LogManager().cloudDrive('123云盘 - 文件删除成功: ${file.name}');
      } else {
        LogManager().cloudDrive('123云盘 - 文件删除失败: ${file.name}');
      }

      return success;
    } on CloudDriveException {
      rethrow;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('123云盘 - 删除文件异常: $e');
      LogManager().cloudDrive('123云盘 - 错误堆栈: $stackTrace');
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
      LogManager().cloudDrive('123云盘 - 重命名文件开始');
      LogManager().cloudDrive('123云盘 - 文件信息: ${file.name} (ID: ${file.id})');
      LogManager().cloudDrive('123云盘 - 新文件名: $newName');
      LogManager().cloudDrive(
        '123云盘 - 账号信息: ${account.name} (${account.type.displayName})',
      );

      final success = await _repository.rename(
        account: account,
        file: file,
        newName: newName,
      );

      if (success) {
        LogManager().cloudDrive('123云盘 - 文件重命名成功: ${file.name} -> $newName');
      } else {
        LogManager().cloudDrive('123云盘 - 文件重命名失败: ${file.name} -> $newName');
      }

      return success;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('123云盘 - 重命名文件异常: $e');
      LogManager().cloudDrive('123云盘 - 错误堆栈: $stackTrace');
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
      LogManager().cloudDrive('123云盘 - 复制文件开始');
      LogManager().cloudDrive('123云盘 - 文件信息: ${file.name} (ID: ${file.id})');
      LogManager().cloudDrive('123云盘 - 目标路径: $destPath');
      LogManager().cloudDrive('123云盘 - 新文件名: ${newName ?? '使用原文件名'}');
      LogManager().cloudDrive(
        '123云盘 - 账号信息: ${account.name} (${account.type.displayName})',
      );

      final success = await _repository.copy(
        account: account,
        file: file,
        targetFolderId: destPath,
      );

      if (success) {
        LogManager().cloudDrive('123云盘 - 文件复制成功: ${file.name} -> $destPath');
      } else {
        LogManager().cloudDrive('123云盘 - 文件复制失败: ${file.name} -> $destPath');
      }

      return success;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('123云盘 - 复制文件异常: $e');
      LogManager().cloudDrive('123云盘 - 错误堆栈: $stackTrace');
      return false;
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
    LogManager().cloudDrive('123云盘 - 上传文件开始');
    LogManager().cloudDrive('文件路径: $filePath');
    LogManager().cloudDrive('文件名: $fileName');
    LogManager().cloudDrive('文件夹ID: ${folderId ?? '0'}');

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
        LogManager().cloudDrive('123云盘 - 上传文件成功: ${uploaded.name}');
      } else {
        LogManager().cloudDrive('123云盘 - 上传文件失败');
      }
      return {'success': success, 'file': uploaded};
    } catch (e, stackTrace) {
      LogManager().cloudDrive('123云盘 - 上传文件异常: $e');
      LogManager().cloudDrive('123云盘 - 错误堆栈: $stackTrace');
      return {'success': false, 'message': e.toString()};
    }
  }

  @override
  Map<String, bool> getSupportedOperations() => {
    'upload': true,
    'download': true, // 已实现下载功能
    'share': false, // 暂未实现分享功能
    'move': true, // 已实现移动功能
    'delete': true, // 已实现删除功能
    'rename': true, // 已实现重命名功能
    'copy': true, // 已实现复制功能
    'createFolder': true, // 通过仓库实现
    'preview': false,
    'offlineDownload': true,
    'recycle': true,
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
    LogManager().cloudDrive('123云盘 - 创建文件夹开始');
    LogManager().cloudDrive('123云盘 - 文件夹名称: $folderName');
    LogManager().cloudDrive('123云盘 - 父文件夹ID: $parentFolderId');

    try {
      final created = await _repository.createFolder(
        account: account,
        name: folderName,
        parentId: parentFolderId,
      );
      if (created != null) {
        LogManager().cloudDrive('123云盘 - 创建文件夹成功');
        return {'success': true, 'folder': created};
      }
      LogManager().cloudDrive('123云盘 - 创建文件夹失败');
      return {'success': false};
    } catch (e, stackTrace) {
      LogManager().cloudDrive('123云盘 - 创建文件夹异常: $e');
      LogManager().cloudDrive('123云盘 - 错误堆栈: $stackTrace');
      if (e is CloudDriveException) {
        rethrow;
      }
      throw CloudDriveException(
        e.toString(),
        CloudDriveErrorType.unknown,
        operation: '123云盘-创建文件夹',
        context: {'stackTrace': stackTrace.toString()},
      );
    }
  }

  /// 离线解析
  Future<Pan123OfflineResolveResponse> resolveOffline({
    required CloudDriveAccount account,
    required String url,
  }) {
    return _repository.resolveOffline(account: account, url: url);
  }

  /// 提交离线任务
  Future<Pan123OfflineSubmitResponse> submitOffline({
    required CloudDriveAccount account,
    required int resourceId,
    required List<int> selectFileIds,
  }) {
    return _repository.submitOffline(
      account: account,
      resourceId: resourceId,
      selectFileIds: selectFileIds,
    );
  }

  /// 查询离线任务列表
  Future<Pan123OfflineTaskListResponse> listOfflineTasks({
    required CloudDriveAccount account,
    int page = 1,
    int pageSize = 15,
    List<int> status = const [0, 1, 2, 3, 4],
  }) {
    return _repository.listOfflineTasks(
      account: account,
      page: page,
      pageSize: pageSize,
      status: status,
    );
  }

  @override
  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) {
    return _repository.getAccountDetails(account: account);
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
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      LogManager().cloudDrive('123云盘 - 获取文件列表开始');
      LogManager().cloudDrive('123云盘 - 文件夹ID: ${folderId ?? '根目录'}');
      LogManager().cloudDrive(
        '123云盘 - 账号信息: ${account.name} (${account.type.displayName})',
      );

      final items = await _repository.listFiles(
        account: account,
        folderId: folderId,
        page: page,
        pageSize: pageSize,
      );

      final folders = items.where((f) => f.isFolder).toList();
      final files = items.where((f) => !f.isFolder).toList();
      CloudDriveLogUtils.logFileListSummary(
        provider: '123云盘',
        files: files,
        folders: folders,
      );
      return items;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('123云盘 - 获取文件列表异常: $e');
      LogManager().cloudDrive('错误堆栈: $stackTrace');
      return [];
    }
  }

  @override
  Future<List<CloudDriveFile>> searchFiles({
    required CloudDriveAccount account,
    required String keyword,
    String? folderId,
    int page = 1,
    int pageSize = 50,
    String? fileType,
  }) async {
    try {
      LogManager().cloudDrive('123云盘 - 搜索文件开始');
      LogManager().cloudDrive('123云盘 - 搜索关键词: $keyword');
      LogManager().cloudDrive(
        '123云盘 - 账号信息: ${account.name} (${account.type.displayName})',
      );

      final files = await _repository.search(
        account: account,
        keyword: keyword,
        folderId: folderId,
        page: page,
        pageSize: pageSize,
      );

      // 如果指定了文件类型，进行筛选
      List<CloudDriveFile> filteredFiles = files;
      if (fileType != null) {
        if (fileType == 'file') {
          filteredFiles = files.where((f) => !f.isFolder).toList();
        } else if (fileType == 'folder') {
          filteredFiles = files.where((f) => f.isFolder).toList();
        }
      }

      LogManager().cloudDrive('123云盘 - 搜索完成: 找到 ${filteredFiles.length} 个文件');
      return filteredFiles;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('123云盘 - 搜索文件异常: $e');
      LogManager().cloudDrive('错误堆栈: $stackTrace');
      return [];
    }
  }

  @override
  Future<CloudDriveAccount?> refreshAuth({
    required CloudDriveAccount account,
  }) async {
    // 暂无官方刷新接口，直接返回当前账号。
    LogManager().cloudDrive('123云盘 - 暂不支持刷新鉴权，返回原账号');
    return account;
  }
}
