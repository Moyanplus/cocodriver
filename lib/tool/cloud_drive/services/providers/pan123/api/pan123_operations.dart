import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';

import '../../../../../../core/logging/log_manager.dart';
import '../../../../base/cloud_drive_operation_service.dart';
import '../../../../core/result.dart';
import '../../../../data/models/cloud_drive_entities.dart';
import '../models/requests/pan123_operation_requests.dart';
import '../models/responses/pan123_upload_responses.dart';
import 'pan123_base_service.dart';
import 'pan123_config.dart';

/// 123 云盘文件/下载操作合集
class Pan123Operations {
  static void _log(String message) => LogManager().cloudDrive(message);
  static bool get _detailed => Pan123Config.enableDetailedLog;

  /// 重命名文件
  ///
  /// [account] 登录账号
  /// [request] 重命名请求体
  static Future<bool> rename({
    required CloudDriveAccount account,
    required Pan123RenameRequest request,
  }) async {
    const operationName = '123云盘-重命名文件';
    return _executeWithLogging<bool>(
      operationName: operationName,
      account: account,
      action: () async {
        _log('123云盘 - 开始重命名文件: ${request.file.id} -> ${request.newName}');
        final url = Uri.parse(
          Pan123Config.getApiUrl(Pan123Config.endpoints['rename']!),
        );
        final params = request.toApiParams();

        final dio = Pan123BaseService.createDio(account);
        final response = await dio.post(url.toString(), data: params);
        if (_detailed) _log('请求体: $params');
        final processed = Pan123BaseService.handleApiResponse(
          response.data as Map<String, dynamic>,
          operation: operationName,
        );
        if (_detailed) _log('响应体: ${response.data}');
        final ok = processed['code'] == 0;
        _log(ok ? '123云盘 - 文件重命名成功' : '123云盘 - 文件重命名失败');
        return ok;
      },
    );
  }

  /// 移动文件到新的父目录
  ///
  /// [account] 登录账号
  /// [request] 移动参数
  static Future<bool> move({
    required CloudDriveAccount account,
    required Pan123MoveRequest request,
  }) async {
    const operationName = '123云盘-移动文件';
    return _executeWithLogging<bool>(
      operationName: operationName,
      account: account,
      action: () async {
        _log('123云盘 - 开始移动文件: ${request.file.id} -> ${request.targetParentId}');

        final url = Uri.parse(
          Pan123Config.getApiUrl(Pan123Config.endpoints['move']!),
        );
        final params = request.toApiParams();

        final dio = Pan123BaseService.createDio(account);
        final response = await dio.post(url.toString(), data: params);
        final processed = Pan123BaseService.handleApiResponse(
          response.data as Map<String, dynamic>,
          operation: operationName,
        );
        if (_detailed) _log('响应体: ${response.data}');
        final ok = processed['code'] == 0;
        _log(ok ? '123云盘 - 文件移动成功' : '123云盘 - 文件移动失败');
        return ok;
      },
    );
  }

  /// 复制文件
  ///
  /// [account] 登录账号
  /// [request] 复制参数
  static Future<bool> copy({
    required CloudDriveAccount account,
    required Pan123CopyRequest request,
  }) async {
    const operationName = '123云盘-复制文件';
    return _executeWithLogging<bool>(
      operationName: operationName,
      account: account,
      action: () async {
        _log('123云盘 - 开始复制文件: ${request.file.id} -> ${request.targetParentId}');

        final url = Uri.parse(
          Pan123Config.getApiUrl(Pan123Config.endpoints['copy']!),
        );
        final params = request.toApiParams();

        final dio = Pan123BaseService.createDio(account);
        final response = await dio.post(url.toString(), data: params);
        final processed = Pan123BaseService.handleApiResponse(
          response.data as Map<String, dynamic>,
          operation: operationName,
        );
        if (_detailed) _log('响应体: ${response.data}');
        final ok = processed['code'] == 0;
        _log(ok ? '123云盘 - 文件复制成功' : '123云盘 - 文件复制失败');
        return ok;
      },
    );
  }

  /// 删除文件或文件夹
  ///
  /// [account] 登录账号
  /// [request] 删除请求
  static Future<bool> delete({
    required CloudDriveAccount account,
    required Pan123DeleteRequest request,
  }) async {
    const operationName = '123云盘-删除文件';
    return _executeWithLogging<bool>(
      operationName: operationName,
      account: account,
      action: () async {
        _log('123云盘 - 删除文件: ${request.file.id} (${request.file.name})');

        final url = Uri.parse(
          Pan123Config.getApiUrl(Pan123Config.endpoints['delete']!),
        );
        final params = request.toApiParams();

        final dio = Pan123BaseService.createDio(account);
        final response = await dio.post(url.toString(), data: params);
        final processed = Pan123BaseService.handleApiResponse(
          response.data as Map<String, dynamic>,
          operation: operationName,
        );
        if (_detailed) _log('响应体: ${response.data}');
        final ok = processed['code'] == 0;
        _log(ok ? '123云盘 - 文件删除成功' : '123云盘 - 文件删除失败');
        return ok;
      },
    );
  }

  /// 创建文件夹
  ///
  /// [account] 登录账号
  /// [request] 创建参数
  static Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required Pan123CreateFolderRequest request,
  }) async {
    return _executeWithLogging<CloudDriveFile?>(
      operationName: '123云盘-创建文件夹',
      account: account,
      action: () async {
        _log('123云盘 - 创建文件夹: ${request.name} @ ${request.parentId ?? '0'}');

        final base = Uri.parse(
          Pan123Config.getApiUrl(Pan123Config.endpoints['createFolder']!),
        );
        final queryNoise = Pan123BaseService.buildNoiseQueryParams();
        final url = base.replace(queryParameters: queryNoise);
        final params = request.toApiParams();

        final dio = Pan123BaseService.createDio(account);
        final response = await dio.post(url.toString(), data: params);
        if (_detailed) _log('请求体: $params');
        final processed = Pan123BaseService.handleApiResponse(
          response.data as Map<String, dynamic>,
        );
        if (_detailed) _log('响应体: ${response.data}');
        final data = processed['data'] as Map<String, dynamic>? ?? {};
        final info = (data['Info'] ?? data['info']) as Map<String, dynamic>?;
        if (info == null) {
          _log('123云盘 - 创建文件夹响应缺少 Info 字段');
          return null;
        }

        DateTime? parseDate(dynamic value) {
          if (value is String && value.isNotEmpty) {
            return DateTime.tryParse(value);
          }
          return null;
        }

        final result = CloudDriveFile(
          id: info['FileId']?.toString() ?? '',
          name: info['FileName']?.toString() ?? request.name,
          isFolder: true,
          folderId: info['ParentFileId']?.toString() ?? request.parentId ?? '0',
          size: (info['Size'] as num?)?.toInt(),
          createdAt: parseDate(info['CreateAt']),
          updatedAt: parseDate(info['UpdateAt']),
          metadata: info,
        );
        _log('123云盘 - 创建文件夹成功: ${result.name} (${result.id})');
        return result;
      },
    );
  }

  /// 获取文件的下载链接
  ///
  /// [account] 登录账号
  /// [request] 下载请求
  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required Pan123DownloadRequest request,
  }) async {
    const operationName = '123云盘-获取下载链接';
    return _executeWithLogging<String?>(
      operationName: operationName,
      account: account,
      action: () async {
        _log('123云盘 - 获取下载链接: ${request.file.name} (${request.file.id})');
        final dio = Pan123BaseService.createDio(account);
        final params = request.toApiParams();

        final url = Uri.parse(
          Pan123Config.getApiUrl(Pan123Config.endpoints['downloadInfo']!),
        );
        final response = await dio.post(url.toString(), data: params);
        final processed = Pan123BaseService.handleApiResponse(
          response.data as Map<String, dynamic>,
          operation: operationName,
        );
        final downloadUrl = processed['data']?['downloadUrl']?.toString();
        if (downloadUrl != null && downloadUrl.isNotEmpty) {
          final preview =
              downloadUrl.length > 100
                  ? '${downloadUrl.substring(0, 100)}...'
                  : downloadUrl;
          _log('123云盘 - 下载链接获取成功: $preview');
          return downloadUrl;
        }
        _log('123云盘 - 响应中无下载链接');
        return null;
      },
    );
  }

  static Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    _log('123云盘 - 暂不支持高速下载');
    return null;
  }

  /// 上传文件（单分片）
  static Future<CloudDriveFile?> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String? parentId,
    UploadProgressCallback? onProgress,
  }) async {
    const operationName = '123云盘-上传文件';
    return _executeWithLogging<CloudDriveFile?>(
      operationName: operationName,
      account: account,
      action: () async {
        _log('123云盘 - 上传文件: $fileName -> ${parentId ?? '0'}');
        final file = File(filePath);
        final fileSize = await file.length();

        // 1) 初始化
        final initResp = await _initUpload(
          account: account,
          fileName: fileName,
          parentId: parentId ?? '0',
          size: fileSize,
          file: file,
        );
        if (_detailed) {
          _log('上传初始化: bucket=${initResp.bucket}, key=${initResp.key}');
        }

        // 2) 获取预签名 URL
        final authResp = await _getUploadAuth(
          account: account,
          bucket: initResp.bucket,
          key: initResp.key,
          uploadId: initResp.uploadId,
          storageNode: initResp.storageNode,
        );
        final uploadUrl = authResp.firstUrl;
        if (uploadUrl == null || uploadUrl.isEmpty) {
          throw CloudDriveException(
            '未获得有效的上传 URL',
            CloudDriveErrorType.clientError,
            operation: operationName,
          );
        }

        // 3) PUT 上传文件
        final dio = Pan123BaseService.createDio(account);
        final mime = lookupMimeType(fileName) ?? 'application/octet-stream';
        await dio.put(
          uploadUrl,
          data: file.openRead(),
          options: Options(
            headers: {
              HttpHeaders.contentLengthHeader: fileSize,
              HttpHeaders.contentTypeHeader: mime,
            },
          ),
          onSendProgress: (sent, total) {
            if (onProgress != null && total > 0) {
              onProgress(sent / total);
            }
          },
        );

        // 4) 完成上传
        final completeResp = await _completeUpload(
          account: account,
          init: initResp,
          fileSize: fileSize,
        );
        final info = completeResp.fileInfo;
        final createdAt = DateTime.tryParse(info['CreateAt']?.toString() ?? '');
        final updatedAt = DateTime.tryParse(info['UpdateAt']?.toString() ?? '');
        final result = CloudDriveFile(
          id: info['FileId']?.toString() ?? '',
          name: info['FileName']?.toString() ?? fileName,
          isFolder: false,
          folderId: info['ParentFileId']?.toString() ?? parentId ?? '0',
          size: (info['Size'] as num?)?.toInt(),
          createdAt: createdAt,
          updatedAt: updatedAt,
          downloadUrl: info['DownloadUrl']?.toString(),
          metadata: info,
        );
        _log('123云盘 - 上传完成: ${result.name} (${result.id})');
        return result;
      },
    );
  }

  // 上传初始化
  static Future<Pan123UploadInitResponse> _initUpload({
    required CloudDriveAccount account,
    required String fileName,
    required String parentId,
    required int size,
    required File file,
  }) async {
    final base = Uri.parse(
      Pan123Config.getApiUrl(Pan123Config.endpoints['uploadInit']!),
    );
    final noise = Pan123BaseService.buildNoiseQueryParams();
    final url = base.replace(queryParameters: noise);
    final dio = Pan123BaseService.createDio(account);

    final etag = await _sha256(file);
    final body = {
      'driveId': 0,
      'etag': etag,
      'fileName': fileName,
      'parentFileId': int.tryParse(parentId) ?? 0,
      'size': size,
      'type': 0,
      'duplicate': 1,
      'NotReuse': true,
      'RequestSource': null,
    };
    if (_detailed) _log('上传初始化请求: $body');
    final response = await dio.post(url.toString(), data: body);
    final processed = Pan123BaseService.handleApiResponse(
      response.data as Map<String, dynamic>,
      operation: '上传初始化',
    );
    if (_detailed) _log('上传初始化响应: ${response.data}');
    return Pan123UploadInitResponse.fromJson(processed);
  }

  static Future<Pan123UploadAuthResponse> _getUploadAuth({
    required CloudDriveAccount account,
    required String bucket,
    required String key,
    required String uploadId,
    required String storageNode,
  }) async {
    final base = Uri.parse(
      Pan123Config.getApiUrl(Pan123Config.endpoints['uploadAuth']!),
    );
    final noise = Pan123BaseService.buildNoiseQueryParams();
    final url = base.replace(queryParameters: noise);
    final dio = Pan123BaseService.createDio(account);

    final body = {
      'bucket': bucket,
      'key': key,
      'partNumberEnd': 1,
      'partNumberStart': 1,
      'uploadId': uploadId,
      'StorageNode': storageNode,
    };
    if (_detailed) _log('上传鉴权请求: $body');
    final response = await dio.post(url.toString(), data: body);
    final processed = Pan123BaseService.handleApiResponse(
      response.data as Map<String, dynamic>,
      operation: '上传鉴权',
    );
    if (_detailed) _log('上传鉴权响应: ${response.data}');
    return Pan123UploadAuthResponse.fromJson(processed);
  }

  static Future<Pan123UploadCompleteResponse> _completeUpload({
    required CloudDriveAccount account,
    required Pan123UploadInitResponse init,
    required int fileSize,
  }) async {
    final base = Uri.parse(
      Pan123Config.getApiUrl(Pan123Config.endpoints['uploadComplete']!),
    );
    final noise = Pan123BaseService.buildNoiseQueryParams();
    final url = base.replace(queryParameters: noise);
    final dio = Pan123BaseService.createDio(account);

    final body = {
      'fileId': init.fileId,
      'bucket': init.bucket,
      'fileSize': fileSize,
      'key': init.key,
      'isMultipart': false,
      'uploadId': init.uploadId,
      'StorageNode': init.storageNode,
    };
    if (_detailed) _log('上传完成请求: $body');
    final response = await dio.post(url.toString(), data: body);
    final processed = Pan123BaseService.handleApiResponse(
      response.data as Map<String, dynamic>,
      operation: '上传完成',
    );
    if (_detailed) _log('上传完成响应: ${response.data}');
    return Pan123UploadCompleteResponse.fromJson(processed);
  }

  static Future<String> _sha256(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  static Future<T> _executeWithLogging<T>({
    required String operationName,
    required CloudDriveAccount account,
    required Future<T> Function() action,
  }) async {
    _ensureLoggedIn(operationName, account);
    try {
      return await action();
    } on CloudDriveException {
      rethrow;
    } catch (e, s) {
      _log('$operationName - 异常: $e');
      _log('堆栈: $s');
      throw CloudDriveException(
        e.toString(),
        CloudDriveErrorType.unknown,
        operation: operationName,
        context: {'stackTrace': s.toString()},
      );
    }
  }

  static void _ensureLoggedIn(String operationName, CloudDriveAccount account) {
    _log(
      '$operationName - 账号信息: ${account.name} (${account.type.displayName})',
    );
    if (!account.isLoggedIn) {
      throw CloudDriveException(
        '账号未登录',
        CloudDriveErrorType.authentication,
        operation: operationName,
      );
    }
  }
}
