import '../../../data/models/cloud_drive_entities.dart';
import '../core/china_mobile_base_service.dart';
import '../core/china_mobile_config.dart';
import '../models/china_mobile_models.dart';
import '../utils/china_mobile_logger.dart';

/// 中国移动云盘文件操作服务
///
/// 提供移动、删除、复制、重命名等操作功能。
class ChinaMobileFileOperationService {
  /// 移动文件到目标文件夹
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) async {
    ChinaMobileLogger.operationStart(
      '移动文件',
      params: {
        'fileName': file.name,
        'fileId': file.id,
        'targetFolderId': targetFolderId,
      },
    );

    try {
      final dio = ChinaMobileBaseService.createDio(account);
      final uri = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('batchMove')}',
      );

      final request = ChinaMobileMoveFileRequest(
        fileIds: [file.id],
        toParentFileId: targetFolderId,
      );

      ChinaMobileLogger.network('POST', url: uri.toString());
      ChinaMobileLogger.debug('请求体', data: request.toRequestBody());

      final response = await dio.postUri(uri, data: request.toRequestBody());

      if (ChinaMobileBaseService.isHttpSuccess(response.statusCode) &&
          ChinaMobileBaseService.isApiSuccess(response.data)) {
        ChinaMobileLogger.success('移动文件完成: ${file.name}');
        return true;
      } else {
        final errorMsg = ChinaMobileBaseService.getErrorMessage(
          response.data ?? {},
        );
        ChinaMobileLogger.error('移动文件失败: $errorMsg');
        return false;
      }
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('移动文件失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 复制文件到目标文件夹
  static Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) async {
    ChinaMobileLogger.operationStart(
      '复制文件',
      params: {
        'fileName': file.name,
        'fileId': file.id,
        'targetFolderId': targetFolderId,
      },
    );

    try {
      final dio = ChinaMobileBaseService.createDio(account);
      final uri = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('batchCopy')}',
      );

      final request = ChinaMobileCopyFileRequest(
        fileIds: [file.id],
        toParentFileId: targetFolderId,
      );

      ChinaMobileLogger.network('POST', url: uri.toString());
      ChinaMobileLogger.debug('请求体', data: request.toRequestBody());

      final response = await dio.postUri(uri, data: request.toRequestBody());

      if (ChinaMobileBaseService.isHttpSuccess(response.statusCode) &&
          ChinaMobileBaseService.isApiSuccess(response.data)) {
        ChinaMobileLogger.success('复制文件完成: ${file.name}');
        return true;
      } else {
        final errorMsg = ChinaMobileBaseService.getErrorMessage(
          response.data ?? {},
        );
        ChinaMobileLogger.error('复制文件失败: $errorMsg');
        return false;
      }
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('复制文件失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 删除文件
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    ChinaMobileLogger.operationStart(
      '删除文件',
      params: {
        'fileName': file.name,
        'fileId': file.id,
        'isFolder': file.isFolder,
      },
    );

    try {
      final dio = ChinaMobileBaseService.createDio(account);
      final uri = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('batchTrash')}',
      );

      final request = ChinaMobileDeleteFileRequest(fileIds: [file.id]);

      ChinaMobileLogger.network('POST', url: uri.toString());
      ChinaMobileLogger.debug('请求体', data: request.toRequestBody());

      final response = await dio.postUri(uri, data: request.toRequestBody());

      if (ChinaMobileBaseService.isHttpSuccess(response.statusCode) &&
          ChinaMobileBaseService.isApiSuccess(response.data)) {
        ChinaMobileLogger.success('删除文件完成: ${file.name}');
        return true;
      } else {
        final errorMsg = ChinaMobileBaseService.getErrorMessage(
          response.data ?? {},
        );
        ChinaMobileLogger.error('删除文件失败: $errorMsg');
        return false;
      }
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('删除文件失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 重命名文件或文件夹
  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    ChinaMobileLogger.operationStart(
      '重命名文件',
      params: {'fileName': file.name, 'newName': newName, 'fileId': file.id},
    );

    try {
      final dio = ChinaMobileBaseService.createDio(account);
      final uri = Uri.parse(
        '${ChinaMobileConfig.baseUrl}${ChinaMobileConfig.getApiEndpoint('updateFile')}',
      );

      final request = ChinaMobileRenameFileRequest(
        fileId: file.id,
        name: newName,
      );

      ChinaMobileLogger.network('POST', url: uri.toString());
      ChinaMobileLogger.debug('请求体', data: request.toRequestBody());

      final response = await dio.postUri(uri, data: request.toRequestBody());

      if (ChinaMobileBaseService.isHttpSuccess(response.statusCode) &&
          ChinaMobileBaseService.isApiSuccess(response.data)) {
        ChinaMobileLogger.success('重命名文件完成: ${file.name} -> $newName');
        return true;
      } else {
        final errorMsg = ChinaMobileBaseService.getErrorMessage(
          response.data ?? {},
        );
        ChinaMobileLogger.error('重命名文件失败: $errorMsg');
        return false;
      }
    } catch (e, stackTrace) {
      ChinaMobileLogger.error('重命名文件失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
