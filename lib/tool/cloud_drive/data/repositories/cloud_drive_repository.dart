import '../models/cloud_drive_entities.dart';
import '../../infrastructure/logging/cloud_drive_logger.dart';
import '../../base/cloud_drive_operation_service.dart';

/// 云盘数据仓库接口
///
/// 定义云盘数据的访问接口，包括文件列表、文件详情、搜索等功能。
abstract class CloudDriveRepositoryInterface {
  /// 获取文件列表
  Future<FileListResult> getFileList(FileListRequest request);

  /// 获取文件详情
  Future<FileDetailResult?> getFileDetail(FileDetailRequest request);

  /// 搜索文件
  Future<FileListResult> searchFiles({
    required CloudDriveAccount account,
    required String keyword,
    String? folderId,
    int page,
    int pageSize,
  });

  /// 获取最近文件
  Future<FileListResult> getRecentFiles({
    required CloudDriveAccount account,
    int limit,
  });

  /// 获取文件预览
  Future<Map<String, dynamic>?> getFilePreview({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  });

  /// 获取文件元数据
  Future<Map<String, dynamic>?> getFileMetadata({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  });
}

/// 云盘数据仓库实现
///
/// 实现云盘数据的访问逻辑，通过策略模式调用不同云盘平台的操作。
class CloudDriveRepository implements CloudDriveRepositoryInterface {
  static final CloudDriveRepository _instance =
      CloudDriveRepository._internal();

  factory CloudDriveRepository() => _instance;

  CloudDriveRepository._internal();

  /// 获取单例实例
  static CloudDriveRepository get instance => _instance;

  @override
  Future<FileListResult> getFileList(FileListRequest request) async {
    try {
      CloudDriveLogger.logOperation(
        'Repository: 获取文件列表',
        request.account.type,
        params: {
          '文件夹ID': request.folderId ?? '根目录',
          '页码': request.page,
          '页面大小': request.pageSize,
        },
      );

      // 使用CloudDriveOperationService获取文件列表
      final strategy = CloudDriveOperationService.getStrategy(
        request.account.type,
      );
      if (strategy == null) {
        CloudDriveLogger.logError(
          'Repository: 策略未找到',
          request.account.type,
          Exception('策略未找到: ${request.account.type.displayName}'),
        );
        return const FileListResult(
          files: [],
          folders: [],
          hasMore: false,
          totalCount: 0,
        );
      }
      final files = await strategy.getFileList(
        account: request.account,
        folderId: request.folderId,
      );

      // 分离文件和文件夹
      final fileList = <CloudDriveFile>[];
      final folderList = <CloudDriveFile>[];

      for (final file in files) {
        if (file.isFolder) {
          folderList.add(file);
        } else {
          fileList.add(file);
        }
      }

      final result = FileListResult(
        files: fileList,
        folders: folderList,
        hasMore: false, // TODO: 实现分页逻辑
        totalCount: fileList.length + folderList.length,
      );

      CloudDriveLogger.logSuccess(
        'Repository: 获取文件列表成功',
        request.account.type,
        details: '${result.files.length} 个文件, ${result.folders.length} 个文件夹',
      );

      return result;
    } catch (e) {
      CloudDriveLogger.logError(
        'Repository: 获取文件列表失败',
        request.account.type,
        e,
      );
      rethrow;
    }
  }

  @override
  Future<FileDetailResult?> getFileDetail(FileDetailRequest request) async {
    try {
      CloudDriveLogger.logOperation(
        'Repository: 获取文件详情',
        request.account.type,
        params: {'文件ID': request.fileId},
      );

      // 使用CloudDriveOperationService获取文件详情
      final strategy = CloudDriveOperationService.getStrategy(
        request.account.type,
      );
      if (strategy == null) {
        CloudDriveLogger.logError(
          'Repository: 策略未找到',
          request.account.type,
          Exception('策略未找到: ${request.account.type.displayName}'),
        );
        return null;
      }
      final accountDetails = await strategy.getAccountDetails(
        account: request.account,
      );

      if (accountDetails != null) {
        // 创建一个简单的文件详情结果
        final file = CloudDriveFile(
          id: request.fileId,
          name: '文件详情',
          isFolder: false,
          size: null,
          modifiedTime: null,
          folderId: null,
        );

        final result = FileDetailResult(
          file: file,
          metadata: {
            'accountInfo': {
              'username': accountDetails.accountInfo?.username ?? '未知用户',
              'phone': accountDetails.accountInfo?.phone,
              'photo': accountDetails.accountInfo?.photo,
              'uk': accountDetails.accountInfo?.uk ?? 0,
              'isVip': accountDetails.accountInfo?.isVip ?? false,
              'isSvip': accountDetails.accountInfo?.isSvip ?? false,
              'isScanVip': accountDetails.accountInfo?.isScanVip ?? false,
              'loginState': accountDetails.accountInfo?.loginState ?? 0,
            },
            'quotaInfo': {
              'total': accountDetails.quotaInfo?.total ?? 0,
              'used': accountDetails.quotaInfo?.used ?? 0,
              'free': accountDetails.quotaInfo?.free ?? 0,
              'expire': accountDetails.quotaInfo?.expire ?? false,
              'serverTime': accountDetails.quotaInfo?.serverTime ?? 0,
            },
          },
        );

        CloudDriveLogger.logSuccess(
          'Repository: 获取文件详情成功',
          request.account.type,
          details: '账号详情获取成功',
        );

        return result;
      }

      return null;
    } catch (e) {
      CloudDriveLogger.logError(
        'Repository: 获取文件详情失败',
        request.account.type,
        e,
      );
      rethrow;
    }
  }

  @override
  Future<FileListResult> searchFiles({
    required CloudDriveAccount account,
    required String keyword,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      CloudDriveLogger.logOperation(
        'Repository: 搜索文件',
        account.type,
        params: {
          '关键词': keyword,
          '文件夹ID': folderId ?? '全部',
          '页码': page,
          '页面大小': pageSize,
        },
      );

      // TODO: 实现搜索功能
      // 目前返回空结果，因为搜索功能还未实现
      const result = FileListResult(
        files: [],
        folders: [],
        hasMore: false,
        totalCount: 0,
        error: '搜索功能暂未实现',
      );

      CloudDriveLogger.logSuccess(
        'Repository: 搜索文件完成',
        account.type,
        details: '${result.files.length} 个文件, ${result.folders.length} 个文件夹',
      );

      return result;
    } catch (e) {
      CloudDriveLogger.logError('Repository: 搜索文件失败', account.type, e);
      rethrow;
    }
  }

  @override
  Future<FileListResult> getRecentFiles({
    required CloudDriveAccount account,
    int limit = 20,
  }) async {
    try {
      CloudDriveLogger.logOperation(
        'Repository: 获取最近文件',
        account.type,
        params: {'限制数量': limit},
      );

      // TODO: 实现最近文件获取功能
      // 目前返回空结果，因为最近文件功能还未实现
      const result = FileListResult(
        files: [],
        folders: [],
        hasMore: false,
        totalCount: 0,
        error: '最近文件功能暂未实现',
      );

      CloudDriveLogger.logSuccess(
        'Repository: 获取最近文件完成',
        account.type,
        details: '${result.files.length} 个文件, ${result.folders.length} 个文件夹',
      );

      return result;
    } catch (e) {
      CloudDriveLogger.logError('Repository: 获取最近文件失败', account.type, e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getFilePreview({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      CloudDriveLogger.logFileOperation(
        'Repository: 获取文件预览',
        account.type,
        file,
      );

      // TODO: 实现文件预览功能
      // 目前返回null，因为文件预览功能还未实现
      CloudDriveLogger.logSuccess(
        'Repository: 文件预览功能暂未实现',
        account.type,
        details: '文件: ${file.name}',
      );

      return null;
    } catch (e) {
      CloudDriveLogger.logError('Repository: 获取文件预览失败', account.type, e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getFileMetadata({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      CloudDriveLogger.logFileOperation(
        'Repository: 获取文件元数据',
        account.type,
        file,
      );

      // TODO: 实现文件元数据获取功能
      // 目前返回null，因为文件元数据功能还未实现
      CloudDriveLogger.logSuccess(
        'Repository: 文件元数据功能暂未实现',
        account.type,
        details: '文件: ${file.name}',
      );

      return null;
    } catch (e) {
      CloudDriveLogger.logError('Repository: 获取文件元数据失败', account.type, e);
      rethrow;
    }
  }
}

/// ---------- 请求/结果模型（从旧基类内联迁移，便于去除遗留依赖） ----------

class FileListRequest {
  final CloudDriveAccount account;
  final String? folderId;
  final int page;
  final int pageSize;

  const FileListRequest({
    required this.account,
    this.folderId,
    this.page = 1,
    this.pageSize = 50,
  });
}

class FileListResult {
  final List<CloudDriveFile> files;
  final List<CloudDriveFile> folders;
  final bool hasMore;
  final int totalCount;
  final String? error;

  const FileListResult({
    required this.files,
    required this.folders,
    this.hasMore = false,
    this.totalCount = 0,
    this.error,
  });

  bool get isSuccess => error == null;
}

class FileDetailRequest {
  final CloudDriveAccount account;
  final String fileId;

  const FileDetailRequest({required this.account, required this.fileId});
}

class FileDetailResult {
  final CloudDriveFile file;
  final Map<String, dynamic> metadata;
  final String? error;

  const FileDetailResult({
    required this.file,
    required this.metadata,
    this.error,
  });

  bool get isSuccess => error == null;
}

class UploadRequest {
  final CloudDriveAccount account;
  final String filePath;
  final String fileName;
  final String folderId;
  final Function(double)? onProgress;

  const UploadRequest({
    required this.account,
    required this.filePath,
    required this.fileName,
    required this.folderId,
    this.onProgress,
  });
}

class UploadResult {
  final bool success;
  final String? fileId;
  final String? error;
  final Map<String, dynamic>? metadata;

  const UploadResult({
    required this.success,
    this.fileId,
    this.error,
    this.metadata,
  });
}

class DownloadRequest {
  final CloudDriveAccount account;
  final CloudDriveFile file;
  final String? fileName;
  final int? size;

  const DownloadRequest({
    required this.account,
    required this.file,
    this.fileName,
    this.size,
  });
}

class DownloadResult {
  final String? downloadUrl;
  final String? error;
  final Map<String, dynamic>? metadata;

  const DownloadResult({this.downloadUrl, this.error, this.metadata});

  bool get isSuccess => downloadUrl != null && error == null;
}

class ShareRequest {
  final CloudDriveAccount account;
  final List<CloudDriveFile> files;
  final String? password;
  final int? expireDays;

  const ShareRequest({
    required this.account,
    required this.files,
    this.password,
    this.expireDays,
  });
}

class ShareResult {
  final String? shareUrl;
  final String? password;
  final String? error;
  final Map<String, dynamic>? metadata;

  const ShareResult({this.shareUrl, this.password, this.error, this.metadata});

  bool get isSuccess => shareUrl != null && error == null;
}

class MoveRequest {
  final CloudDriveAccount account;
  final CloudDriveFile file;
  final String? targetFolderId;

  const MoveRequest({
    required this.account,
    required this.file,
    this.targetFolderId,
  });
}

class DeleteRequest {
  final CloudDriveAccount account;
  final CloudDriveFile file;

  const DeleteRequest({required this.account, required this.file});
}

class RenameRequest {
  final CloudDriveAccount account;
  final CloudDriveFile file;
  final String newName;

  const RenameRequest({
    required this.account,
    required this.file,
    required this.newName,
  });
}

class CopyRequest {
  final CloudDriveAccount account;
  final CloudDriveFile file;
  final String destPath;
  final String? newName;

  const CopyRequest({
    required this.account,
    required this.file,
    required this.destPath,
    this.newName,
  });
}

class OperationResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? metadata;

  const OperationResult({required this.success, this.error, this.metadata});
}
