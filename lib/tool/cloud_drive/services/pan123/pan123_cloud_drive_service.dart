import '../../models/cloud_drive_models.dart';
import 'pan123_config.dart';
import 'pan123_download_service.dart';
import 'pan123_file_list_service.dart';
import 'pan123_file_operation_service.dart';

/// 123云盘主服务
/// 作为门面模式，提供统一的API接口
class Pan123CloudDriveService {
  /// 获取文件列表
  static Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String parentId = '0',
    int page = 1,
    int limit = 100,
    String? orderBy,
    String? orderDirection,
    String? searchValue,
  }) async => await Pan123FileListService.getFileList(
    account: account,
    parentId: parentId,
    page: page,
    limit: limit,
    orderBy: orderBy,
    orderDirection: orderDirection,
    searchValue: searchValue,
  );

  /// 获取文件下载链接
  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required String fileId,
    required String fileName,
    int? size,
    String? s3keyFlag,
    String? etag,
  }) async => await Pan123DownloadService.getDownloadUrl(
    account: account,
    fileId: fileId,
    fileName: fileName,
    size: size,
    s3keyFlag: s3keyFlag,
    etag: etag,
  );

  /// 重命名文件
  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required String fileId,
    required String newFileName,
  }) async => await Pan123FileOperationService.renameFile(
    account: account,
    fileId: fileId,
    newFileName: newFileName,
  );

  /// 移动文件
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required String fileId,
    required String targetParentFileId,
  }) async => await Pan123FileOperationService.moveFile(
    account: account,
    fileId: fileId,
    targetParentFileId: targetParentFileId,
  );

  /// 复制文件
  static Future<bool> copyFile({
    required CloudDriveAccount account,
    required String fileId,
    required String targetFileId,
    String? fileName,
    int? size,
    String? etag,
    int? type,
    String? parentFileId,
  }) async => await Pan123FileOperationService.copyFile(
    account: account,
    fileId: fileId,
    targetFileId: targetFileId,
    fileName: fileName,
    size: size,
    etag: etag,
    type: type,
    parentFileId: parentFileId,
  );

  /// 删除文件
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required String fileId,
    String? fileName,
    int? type,
    int? size,
    String? s3keyFlag,
    String? etag,
    String? parentFileId,
  }) async => await Pan123FileOperationService.deleteFile(
    account: account,
    fileId: fileId,
    fileName: fileName,
    type: type,
    size: size,
    s3keyFlag: s3keyFlag,
    etag: etag,
    parentFileId: parentFileId,
  );

  /// 验证认证有效性
  static Future<bool> validateAuth(CloudDriveAccount account) async {
    try {
      // 尝试获取根目录文件列表来验证认证
      final files = await getFileList(
        account: account,
        parentId: '0',
        limit: 1,
      );
      return files.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 获取错误信息
  static String getErrorMessage(int code) => Pan123Config.getErrorMessage(code);

  /// 格式化时间戳
  static String formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) => Pan123Config.formatFileSize(bytes);
}
