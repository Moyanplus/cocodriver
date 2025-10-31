import '../../../../../core/logging/log_manager.dart';
import '../data/models/cloud_drive_entities.dart';
// import '../data/models/cloud_drive_dtos.dart'; // 未使用
import '../base/cloud_drive_operation_service.dart';
import '../core/result.dart';
import 'cloud_drive_service_factory.dart';

/// 下载服务 - 专门处理下载相关操作
class DownloadService extends CloudDriveService {
  DownloadService(CloudDriveType type) : super(type);

  /// 获取下载链接
  Future<Result<String?>> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    logOperation(
      '获取下载链接',
      params: {
        'fileName': file.name,
        'fileId': file.id,
        'isFolder': file.isFolder,
      },
    );

    return await ResultUtils.fromAsync(() async {
      final strategy = CloudDriveOperationService.getStrategy(type);
      final downloadUrl = await strategy.getDownloadUrl(
        account: account,
        file: file,
      );

      if (downloadUrl != null) {
        logSuccess('获取下载链接', details: '链接长度: ${downloadUrl.length}');
      } else {
        logWarning('获取下载链接', '返回null');
      }

      return downloadUrl;
    }, operationName: '获取下载链接');
  }

  /// 高速下载 - 使用第三方解析服务获取直接下载链接
  Future<Result<List<String>?>> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    logOperation(
      '高速下载',
      params: {
        'fileName': file.name,
        'fileId': file.id,
        'shareUrl': shareUrl,
        'password': password,
      },
    );

    return await ResultUtils.fromAsync(() async {
      final strategy = CloudDriveOperationService.getStrategy(type);
      final downloadUrls = await strategy.getHighSpeedDownloadUrls(
        account: account,
        file: file,
        shareUrl: shareUrl,
        password: password,
      );

      if (downloadUrls != null) {
        logSuccess('高速下载', details: '获取到 ${downloadUrls.length} 个下载链接');
      } else {
        logWarning('高速下载', '获取失败');
      }

      return downloadUrls;
    }, operationName: '高速下载');
  }

  /// 批量下载文件
  Future<Result<void>> batchDownloadFiles({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    required List<CloudDriveFile> folders,
  }) async {
    logOperation(
      '批量下载',
      params: {'fileCount': files.length, 'folderCount': folders.length},
    );

    return await ResultUtils.fromAsync(() async {
      // 目前只支持文件下载，文件夹下载需要递归处理
      if (folders.isNotEmpty) {
        LogManager().warning(
          '文件夹批量下载暂未实现，跳过 ${folders.length} 个文件夹',
          className: 'DownloadService',
          methodName: 'batchDownloadFiles',
          data: {'folderCount': folders.length},
        );
      }

      if (files.isEmpty) {
        LogManager().warning(
          '没有文件需要下载',
          className: 'DownloadService',
          methodName: 'batchDownloadFiles',
        );
        return;
      }

      await _performBatchDownload(account, files);
      logSuccess('批量下载', details: '${files.length} 个文件');
    }, operationName: '批量下载');
  }

  /// 执行批量下载
  Future<void> _performBatchDownload(
    CloudDriveAccount account,
    List<CloudDriveFile> files,
  ) async {
    // 这里应该集成下载管理器
    // 暂时只记录日志
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      LogManager().cloudDrive('下载文件 ${i + 1}/${files.length}: ${file.name}');

      // 获取下载链接
      final result = await getDownloadUrl(account: account, file: file);
      if (result.isSuccess && result.data != null) {
        LogManager().cloudDrive('文件下载链接获取成功: ${file.name}');
        // TODO: 创建下载任务
      } else {
        LogManager().error('无法获取下载链接: ${file.name}');
      }
    }
  }

  /// 检查下载是否支持
  bool isDownloadSupported() {
    final supportedOps =
        CloudDriveOperationService.getStrategy(type).getSupportedOperations();
    return supportedOps['download'] ?? false;
  }

  /// 获取下载配置
  Map<String, dynamic> getDownloadConfig() {
    return {
      'supported': isDownloadSupported(),
      'maxConcurrent': 3,
      'retryCount': 3,
      'timeout': 30000, // 30秒
    };
  }
}
