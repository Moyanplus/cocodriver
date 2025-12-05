import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../../data/models/cloud_drive_entities.dart';
import '../../../shared/http_client.dart';
import '../models/quark_models.dart';
import '../utils/quark_logger.dart';
import 'quark_base_service.dart';
import 'quark_config.dart';

/// 夸克云盘统一操作封装。
class QuarkOperations {
  static Future<QuarkApiResult<QuarkFileListResponse>> listFiles({
    required CloudDriveAccount account,
    required QuarkFileListRequest request,
  }) {
    final startTime = DateTime.now();

    return _http(account).then((http) async {
      try {
        final uri = http.buildUri(
          '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('getFileList')}',
          request.toQueryParameters().map((k, v) => MapEntry(k, v.toString())),
        );

        QuarkLogger.network('GET', url: uri.toString());
        final response = await http.getResponse(uri);

        final result = QuarkResponseParser.parse<QuarkFileListResponse>(
          response: response.data,
          statusCode: response.statusCode,
          dataParser: (data) {
            return QuarkFileListResponse.fromJson(
              response.data as Map<String, dynamic>,
              request.parentFolderId,
            );
          },
        );

        if (result.isSuccess) {
          final duration = DateTime.now().difference(startTime);
          QuarkLogger.performance(
            '获取文件列表完成，共 ${result.data!.files.length} 个文件',
            duration: duration,
          );
        }

        return result;
      } catch (e, stackTrace) {
        QuarkLogger.error('获取文件列表失败', error: e, stackTrace: stackTrace);
        return _toFailure(e);
      }
    });
  }

  static Future<QuarkApiResult<QuarkFileOperationResponse>> operate({
    required CloudDriveAccount account,
    required QuarkFileOperationRequest request,
  }) async {
    try {
      final http = await _http(account);
      final operationName = _getOperationName(request.operationType);
      final uri = http.buildUri(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint(operationName)}',
        request.toQueryParameters().map((k, v) => MapEntry(k, v.toString())),
      );

      QuarkLogger.network('POST', url: uri.toString());
      QuarkLogger.debug('请求体', data: request.toRequestBody());

      final response = await http.postResponse(
        uri,
        data: request.toRequestBody(),
      );

      return QuarkResponseParser.parse<QuarkFileOperationResponse>(
        response: response.data,
        statusCode: response.statusCode,
        dataParser: (data) => QuarkFileOperationResponse.fromJson(data),
      );
    } catch (e, stackTrace) {
      QuarkLogger.error('文件操作失败', error: e, stackTrace: stackTrace);
      return _toFailure(e);
    }
  }

  static Future<QuarkApiResult<QuarkCreateFolderResponse>> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    QuarkLogger.operationStart(
      '创建文件夹',
      params: {
        'folderName': folderName,
        'parentFolderId': parentFolderId ?? '根目录',
      },
    );

    try {
      final http = await _http(account);
      final uri = http.buildUri(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('createFolder')}',
        QuarkConfig.buildCreateFolderParams().map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );

      final requestBody = {
        QuarkConfig.responseFields['pdirFid']: QuarkConfig.getFolderId(
          parentFolderId,
        ),
        QuarkConfig.responseFields['fileName']: folderName,
        QuarkConfig.responseFields['dirPath']: '',
        QuarkConfig.responseFields['dirInitLock']: false,
      };

      QuarkLogger.debug('请求体', data: requestBody);
      final response = await http.postResponse(uri, data: requestBody);

      if (response.statusCode != 200) {
        throw Exception('HTTP请求失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      if (responseData['code'] != 0) {
        final message = responseData['message'];
        throw Exception('API返回错误: $message');
      }

      final data = responseData[QuarkConfig.responseFields['data']];
      final finish = data[QuarkConfig.responseFields['finish']] as bool?;
      final fid = data[QuarkConfig.responseFields['fid']] as String?;

      QuarkLogger.success('文件夹创建成功 - 文件夹ID: $fid');

      if (fid != null) {
        return QuarkApiResult.success(
          QuarkCreateFolderResponse(folderId: fid, isFinished: finish ?? false),
        );
      } else {
        QuarkLogger.error('文件夹创建成功但未返回文件夹ID');
        return QuarkApiResult.success(
          QuarkCreateFolderResponse(
            folderId: null,
            isFinished: finish ?? false,
          ),
        );
      }
    } catch (e, stackTrace) {
      QuarkLogger.error('创建文件夹失败', error: e, stackTrace: stackTrace);
      return _toFailure(e);
    }
  }

  static Future<QuarkApiResult<QuarkShareResponse>> createShare({
    required CloudDriveAccount account,
    required QuarkShareRequest request,
  }) async {
    QuarkLogger.operationStart(
      '创建分享链接',
      params: {
        'fileCount': request.fileIds.length,
        'title': request.title ?? '分享文件',
        'hasPasscode': request.passcode != null,
        'expiredType': request.expiredType.name,
      },
    );

    try {
      final http = await _http(account);
      final url = http.buildUri(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('createShare')}',
        const {},
      );
      final requestBody = request.toRequestBody();
      QuarkLogger.debug('请求体', data: requestBody);

      final response = await http.postResponse(url, data: requestBody);

      Map<String, dynamic> responseData;
      try {
        if (response.data is String) {
          final responseText = response.data as String;
          QuarkLogger.debug('响应文本长度: ${responseText.length}');
          responseData = json.decode(responseText) as Map<String, dynamic>;
        } else {
          responseData = response.data as Map<String, dynamic>;
        }
      } catch (e) {
        QuarkLogger.error('JSON解析失败', error: e);
        final responseText = response.data as String;
        final preview =
            responseText.length > 100
                ? responseText.substring(0, 100)
                : responseText;
        QuarkLogger.debug('响应内容预览: $preview');
        return QuarkApiResult.failure(
          message: '响应解析失败: $e',
          code: 'PARSE_ERROR',
        );
      }

      return QuarkResponseParser.parse<QuarkShareResponse>(
        response: responseData,
        statusCode: response.statusCode,
        dataParser: (data) {
          final taskResp = data['task_resp'];
          final taskData = taskResp['data'];
          final shareId = taskData['share_id'];
          final shareUrl = QuarkConfig.buildShareUrl(shareId);

          QuarkLogger.success('创建分享链接成功');
          QuarkLogger.share('分享链接已创建', url: shareUrl);

          return QuarkShareResponse.fromJson(taskData, shareUrl);
        },
      );
    } catch (e, stackTrace) {
      QuarkLogger.error('创建分享链接失败', error: e, stackTrace: stackTrace);
      return _toFailure(e);
    }
  }

  static Future<QuarkApiResult<String>> getDownloadUrl({
    required CloudDriveAccount account,
    required String fileId,
    required String fileName,
    int? size,
  }) async {
    QuarkLogger.operationStart(
      '获取下载链接',
      params: {
        'fileId': fileId,
        'fileName': fileName,
        'size':
            size != null
                ? '${(size / 1024 / 1024).toStringAsFixed(2)} MB'
                : '未知',
      },
    );

    final request = QuarkDownloadRequest(fileIds: [fileId]);

    try {
      final http = await _http(account);
      final uri = http.buildUri(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('getDownloadUrl')}',
        request.toQueryParameters().map((k, v) => MapEntry(k, v.toString())),
      );

      QuarkLogger.network('POST', url: uri.toString());
      QuarkLogger.debug('请求体', data: request.toRequestBody());

      final response = await http.postResponse(
        uri,
        data: request.toRequestBody(),
      );

      final parsed = QuarkResponseParser.parse<QuarkDownloadResponse>(
        response: response.data,
        statusCode: response.statusCode,
        dataParser: (data) {
          if (data is! List || data.isEmpty) {
            throw Exception('响应数据为空');
          }
          final fileData = data.first as Map<String, dynamic>;
          return QuarkDownloadResponse.fromJson(fileData);
        },
      );

      if (parsed.isSuccess && parsed.data != null) {
        QuarkLogger.success('下载链接获取成功');
        return QuarkApiResult.success(parsed.data!.downloadUrl);
      }
      QuarkLogger.error('获取下载链接失败: ${parsed.errorMessage}');
      return QuarkApiResult.failure(
        message: parsed.errorMessage ?? '获取下载链接失败',
        code: parsed.errorCode,
      );
    } catch (e, stackTrace) {
      QuarkLogger.error('获取下载链接失败', error: e, stackTrace: stackTrace);
      return _toFailure<String>(e);
    }
  }

  static String _getOperationName(FileOperationType type) {
    switch (type) {
      case FileOperationType.move:
        return 'moveFile';
      case FileOperationType.copy:
        return 'copyFile';
      case FileOperationType.delete:
        return 'deleteFile';
      case FileOperationType.rename:
        return 'renameFile';
    }
  }

  static Future<CloudDriveHttpClient> _http(CloudDriveAccount account) =>
      QuarkBaseService.createHttpClientWithAuth(account);

  static QuarkApiResult<T> _toFailure<T>(Object e) {
    if (e is DioException) {
      final req = e.requestOptions;
      final code = e.response?.statusCode;
      final msg =
          'HTTP ${code ?? 'error'} ${req.method} ${req.uri}: ${e.message}';
      return QuarkApiResult.failure(message: msg);
    }
    return QuarkApiResult.fromException(e as Exception);
  }
}
