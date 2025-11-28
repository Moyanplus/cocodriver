import 'package:coco_cloud_drive/tool/cloud_drive/data/models/cloud_drive_entities.dart';

import '../../../../../core/logging/log_manager.dart';
import '../repository/lanzou_repository.dart';
import '../models/lanzou_result.dart';
import '../models/lanzou_direct_link_models.dart';
import '../models/responses/lanzou_upload_response.dart';
import '../utils/lanzou_utils.dart';

/// 蓝奏云盘 API 服务 Facade。
///
/// 对外暴露文件列表、直链解析、上传、移动等能力，内部全部委托给
/// Repository/Utils，使上层无需关心底层实现细节。
class LanzouCloudDriveFacade {
  /// 统一错误处理
  static void _handleError(
    String operation,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    LogManager().cloudDrive('蓝奏云盘 - $operation 失败: $error');
    if (stackTrace != null) {
      LogManager().cloudDrive('错误堆栈: $stackTrace');
    }
  }

  /// 统一日志记录
  static void _logInfo(String message) {
    LogManager().cloudDrive(message);
  }

  /// 统一成功日志记录
  static void _logSuccess(String message) {
    LogManager().cloudDrive('蓝奏云盘 - $message');
  }

  /// 统一错误日志记录
  static void _logError(String message, dynamic error) {
    LogManager().cloudDrive('蓝奏云盘 - $message: $error');
  }

  /// UID 提取工具
  static String? extractUidFromCookies(String cookies) =>
      LanzouUtils.extractUid(cookies);

  /// 获取文件列表
  /// 获取文件与文件夹列表。
  static Future<LanzouResult<List<CloudDriveFile>>> getFiles({
    required String cookies,
    required String uid,
    String folderId = '-1',
  }) async {
    try {
      _logInfo('获取文件列表: 文件夹ID=$folderId');

      final repository = LanzouRepository(cookies: cookies, uid: uid);
      final files = await repository.fetchFiles(folderId);
      _logSuccess('成功获取 ${files.length} 个文件');
      return LanzouResult.success(files);
    } catch (e) {
      _handleError('获取文件列表', e, null);
      return LanzouResult.failure(LanzouFailure(message: e.toString()));
    }
  }

  /// 获取文件夹列表
  /// 获取子文件夹列表。
  static Future<LanzouResult<List<CloudDriveFile>>> getFolders({
    required String cookies,
    required String uid,
    String folderId = '-1',
  }) async {
    try {
      _logInfo('获取文件夹列表: 文件夹ID=$folderId');

      final repository = LanzouRepository(cookies: cookies, uid: uid);
      final folders = await repository.fetchFolders(folderId);
      _logSuccess('成功获取 ${folders.length} 个文件夹');
      return LanzouResult.success(folders);
    } catch (e) {
      _handleError('获取文件夹列表', e, null);
      return LanzouResult.failure(LanzouFailure(message: e.toString()));
    }
  }

  /// 验证 Cookie 有效性
  /// 验证 Cookie 是否仍有效。
  static Future<LanzouResult<bool>> validateCookies(
    String cookies,
    String uid,
  ) async {
    try {
      _logInfo('验证 Cookie 有效性');

      final repository = LanzouRepository(cookies: cookies, uid: uid);
      final response = await repository.validateCookies();
      _logInfo('Cookie 验证结果: ${response.success ? '有效' : '无效'}');
      return LanzouResult.success(response.success);
    } catch (e) {
      _logError('Cookie 验证异常', e);
      return LanzouResult.failure(LanzouFailure(message: e.toString()));
    }
  }

  /// 获取文件详情
  static Future<Map<String, dynamic>?> getFileDetail({
    required String cookies,
    required String uid,
    required String fileId,
  }) async {
    try {
      _logInfo('获取文件详情: file_id=$fileId');

      final repository = LanzouRepository(cookies: cookies, uid: uid);
      final response = await repository.fetchFileDetail(fileId);

      if (response.detail != null) {
        _logSuccess('成功获取文件详情');
        _logInfo('文件详情: ${response.detail}');
      } else {
        _logError('获取文件详情失败', response.message ?? '未返回信息');
      }
      return response.detail;
    } catch (e) {
      _logError('获取文件详情异常', e);
      return null;
    }
  }

  /// 解析蓝奏云直链
  /// 解析分享链接并返回直链信息。
  static Future<LanzouResult<LanzouDirectLinkResult>> parseDirectLink({
    required String shareUrl,
    String? password,
  }) async {
    try {
      final result = await LanzouRepository.parseDirectLink(
        shareUrl: shareUrl,
        password: password,
      );
      if (!result.isSuccess) {
        _logError('解析直链失败', result.error?.message ?? '未知错误');
      }
      return result;
    } catch (e) {
      _logError('解析直链失败', e);
      return LanzouResult.failure(LanzouFailure(message: e.toString()));
    }
  }

  /// 上传文件到蓝奏云
  /// 上传文件到指定文件夹。
  static Future<LanzouResult<LanzouUploadResponse>> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String folderId = '-1',
  }) async {
    try {
      _logInfo('开始上传文件: $fileName');
      final repository = LanzouRepository.fromAccount(account);
      final result = await repository.uploadFile(
        filePath: filePath,
        fileName: fileName,
        folderId: folderId,
      );
      _logSuccess('文件上传成功');
      return LanzouResult.success(result as LanzouUploadResponse);
    } catch (e) {
      _logError('文件上传异常', e);
      return LanzouResult.failure(LanzouFailure(message: e.toString()));
    }
  }

  /// 移动文件
  /// [account] 蓝奏云账号信息
  /// [file] 要移动的文件
  /// [targetFolderId] 目标文件夹ID（可选，默认为根目录-1）
  /// 返回移动是否成功
  /// 移动单个文件。
  static Future<LanzouResult<bool>> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    try {
      _logInfo('开始移动文件');
      _logInfo('文件: ${file.name} (ID: ${file.id})');
      _logInfo('目标文件夹ID: ${targetFolderId ?? '-1'}');

      final repository = LanzouRepository.fromAccount(account);
      await repository.moveFile(
        fileId: file.id,
        targetFolderId: targetFolderId,
      );
      _logSuccess('文件移动成功');
      return LanzouResult.success(true);
    } catch (e) {
      _logError('移动文件异常', e);
      return LanzouResult.failure(LanzouFailure(message: e.toString()));
    }
  }

  /// 重命名文件
  static Future<LanzouResult<bool>> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    try {
      _logInfo('开始重命名文件: ${file.name} -> $newName');
      final repository = LanzouRepository.fromAccount(account);
      await repository.renameFile(fileId: file.id, newName: newName);
      _logSuccess('文件重命名成功');
      return LanzouResult.success(true);
    } catch (e) {
      _logError('重命名文件异常', e);
      return LanzouResult.failure(LanzouFailure(message: e.toString()));
    }
  }

  /// 删除文件
  static Future<LanzouResult<bool>> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      _logInfo('开始删除文件: ${file.name} (${file.id})');
      final repository = LanzouRepository.fromAccount(account);
      await repository.deleteFile(fileId: file.id);
      _logSuccess('文件删除成功');
      return LanzouResult.success(true);
    } catch (e) {
      _logError('删除文件异常', e);
      return LanzouResult.failure(LanzouFailure(message: e.toString()));
    }
  }
}
