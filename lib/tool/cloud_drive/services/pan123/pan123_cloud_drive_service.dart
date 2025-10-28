/// 123云盘主服务类
///
/// 作为门面模式，提供123云盘功能的统一API接口
/// 整合文件列表、文件操作、下载等各个子服务
///
/// 主要功能：
/// - 文件列表获取
/// - 文件操作管理
/// - 下载服务集成
/// - 统一API接口
/// - 服务协调管理
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年

import '../../data/models/cloud_drive_entities.dart';
// import '../../data/models/cloud_drive_dtos.dart'; // 未使用
import 'pan123_config.dart';
import 'pan123_download_service.dart';
import 'pan123_file_list_service.dart';
import 'pan123_file_operation_service.dart';

/// 123云盘主服务类
///
/// 作为门面模式，提供123云盘功能的统一API接口
/// 整合文件列表、文件操作、下载等各个子服务
class Pan123CloudDriveService {
  ///
  /// 获取指定文件夹下的文件和文件夹列表
  ///
  /// [account] 123云盘账号信息
  /// [parentId] 父文件夹ID（默认根目录）
  /// [page] 页码（默认1）
  /// [limit] 每页数量（默认100）
  /// [orderBy] 排序字段（可选）
  /// [orderDirection] 排序方向（可选）
  /// [searchValue] 搜索关键词（可选）
  /// 返回文件列表
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
  ///
  /// 获取指定文件的下载链接
  ///
  /// [account] 123云盘账号信息
  /// [fileId] 文件ID
  /// [fileName] 文件名
  /// [size] 文件大小（可选）
  /// [s3keyFlag] S3密钥标志（可选）
  /// [etag] ETag（可选）
  /// 返回下载链接，如果获取失败则返回null
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
  ///
  /// 重命名指定的文件或文件夹
  ///
  /// [account] 123云盘账号信息
  /// [fileId] 文件ID
  /// [newFileName] 新文件名
  /// 返回操作是否成功
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
  ///
  /// 将文件移动到指定的目标文件夹
  ///
  /// [account] 123云盘账号信息
  /// [fileId] 文件ID
  /// [targetParentFileId] 目标父文件夹ID
  /// 返回操作是否成功
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
  ///
  /// 复制文件到指定的目标位置
  ///
  /// [account] 123云盘账号信息
  /// [fileId] 源文件ID
  /// [targetFileId] 目标文件ID
  /// [fileName] 文件名（可选）
  /// [size] 文件大小（可选）
  /// [etag] ETag（可选）
  /// [type] 文件类型（可选）
  /// [parentFileId] 父文件ID（可选）
  /// 返回操作是否成功
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
  ///
  /// 删除指定的文件或文件夹
  ///
  /// [account] 123云盘账号信息
  /// [fileId] 文件ID
  /// [fileName] 文件名（可选）
  /// [type] 文件类型（可选）
  /// [size] 文件大小（可选）
  /// [s3keyFlag] S3密钥标志（可选）
  /// [etag] ETag（可选）
  /// [parentFileId] 父文件ID（可选）
  /// 返回操作是否成功
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
  ///
  /// 验证账号认证是否有效
  ///
  /// [account] 123云盘账号信息
  /// 返回认证是否有效
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
  ///
  /// 根据错误码获取对应的错误信息
  ///
  /// [code] 错误码
  /// 返回错误信息字符串
  static String getErrorMessage(int code) => Pan123Config.getErrorMessage(code);

  /// 格式化时间戳
  ///
  /// 将时间戳格式化为可读的时间字符串
  ///
  /// [timestamp] 时间戳（秒）
  /// 返回格式化的时间字符串
  static String formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// 格式化文件大小
  ///
  /// 将字节数格式化为可读的文件大小字符串
  ///
  /// [bytes] 字节数
  /// 返回格式化的文件大小字符串
  static String formatFileSize(int bytes) => Pan123Config.formatFileSize(bytes);
}
