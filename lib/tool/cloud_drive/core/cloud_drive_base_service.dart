import '../../../core/services/base/debug_service.dart';
import '../models/cloud_drive_models.dart';

/// 云盘基础服务接口
abstract class CloudDriveServiceInterface {
  /// 获取文件列表
  Future<FileListResult> getFileList(FileListRequest request);

  /// 获取文件详情
  Future<FileDetailResult?> getFileDetail(FileDetailRequest request);

  /// 上传文件
  Future<UploadResult> uploadFile(UploadRequest request);

  /// 获取下载链接
  Future<DownloadResult?> getDownloadUrl(DownloadRequest request);

  /// 创建分享链接
  Future<ShareResult?> createShareLink(ShareRequest request);

  /// 移动文件
  Future<OperationResult> moveFile(MoveRequest request);

  /// 删除文件
  Future<OperationResult> deleteFile(DeleteRequest request);

  /// 重命名文件
  Future<OperationResult> renameFile(RenameRequest request);

  /// 复制文件
  Future<OperationResult> copyFile(CopyRequest request);

  /// 验证账号
  Future<bool> validateAccount(CloudDriveAccount account);

  /// 获取支持的操作
  Map<String, bool> getSupportedOperations();
}

/// 文件列表请求
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

/// 文件列表结果
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

/// 文件详情请求
class FileDetailRequest {
  final CloudDriveAccount account;
  final String fileId;

  const FileDetailRequest({required this.account, required this.fileId});
}

/// 文件详情结果
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

/// 上传请求
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

/// 上传结果
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

/// 下载请求
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

/// 下载结果
class DownloadResult {
  final String? downloadUrl;
  final String? error;
  final Map<String, dynamic>? metadata;

  const DownloadResult({this.downloadUrl, this.error, this.metadata});

  bool get isSuccess => downloadUrl != null && error == null;
}

/// 分享请求
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

/// 分享结果
class ShareResult {
  final String? shareUrl;
  final String? password;
  final String? error;
  final Map<String, dynamic>? metadata;

  const ShareResult({this.shareUrl, this.password, this.error, this.metadata});

  bool get isSuccess => shareUrl != null && error == null;
}

/// 移动请求
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

/// 删除请求
class DeleteRequest {
  final CloudDriveAccount account;
  final CloudDriveFile file;

  const DeleteRequest({required this.account, required this.file});
}

/// 重命名请求
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

/// 复制请求
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

/// 操作结果
class OperationResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? metadata;

  const OperationResult({required this.success, this.error, this.metadata});
}

/// 云盘基础服务
abstract class CloudDriveBaseService implements CloudDriveServiceInterface {
  final CloudDriveType cloudDriveType;

  const CloudDriveBaseService(this.cloudDriveType);

  /// 获取云盘类型
  CloudDriveType get type => cloudDriveType;

  /// 记录操作日志
  void logOperation(String operation, Map<String, dynamic> params) {
    DebugService.log(
      '🔧 $operation - ${cloudDriveType.displayName}',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.${cloudDriveType.name}',
    );

    for (final entry in params.entries) {
      DebugService.log(
        '📋 ${entry.key}: ${entry.value}',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.${cloudDriveType.name}',
      );
    }
  }

  /// 记录错误日志
  void logError(String operation, dynamic error) {
    DebugService.log(
      '❌ $operation 失败 - ${cloudDriveType.displayName}: $error',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.${cloudDriveType.name}',
    );
  }

  /// 记录成功日志
  void logSuccess(String operation, [String? details]) {
    DebugService.log(
      '✅ $operation 成功 - ${cloudDriveType.displayName}${details != null ? ': $details' : ''}',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.${cloudDriveType.name}',
    );
  }

  /// 验证账号基础实现
  @override
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
}
