import '../../../data/models/cloud_drive_entities.dart';
import '../baidu_cloud_drive_service.dart';
import '../models/requests/baidu_list_request.dart';
import '../models/requests/baidu_operation_requests.dart';
import '../models/responses/baidu_file_list_response.dart';
import '../models/responses/baidu_operation_response.dart';
import '../models/responses/baidu_api_result.dart';
import '../baidu_base_service.dart';
import '../baidu_config.dart';
import 'package:dio/dio.dart';

/// 百度网盘 API 客户端（当前复用已有 Service，统一 DTO）。
class BaiduApiClient {
  Future<BaiduFileListResponse> listFiles({
    required CloudDriveAccount account,
    required BaiduListRequest request,
  }) async {
    final dio = BaiduBaseService.createDio(account);
    final uri = Uri.parse('${dio.options.baseUrl}${BaiduConfig.getApiEndpoint('fileList')}');
    final params = BaiduBaseService.buildRequestParams(
      dir: request.folderId,
      page: request.page,
      num: request.pageSize,
    );

    final result = await _safeCall<Map<String, dynamic>>(
      () async {
        final response = await dio.getUri(uri.replace(queryParameters: params));
        final data = response.data as Map<String, dynamic>? ?? {};
        return BaiduBaseService.handleApiResponse(data);
      },
    );

    final respData = result.data ?? {};
    final list = respData['list'] as List<dynamic>? ?? [];
    final files = <CloudDriveFile>[];
    final folders = <CloudDriveFile>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final isDir = (item['isdir']?.toString() ?? '0') == '1';
        final file = CloudDriveFile(
          id: item['fs_id']?.toString() ?? '',
          name: item['server_filename']?.toString() ?? '',
          size: item['size'] is int ? item['size'] as int : int.tryParse('${item['size'] ?? ''}'),
          modifiedTime: item['server_mtime'] is int
              ? DateTime.fromMillisecondsSinceEpoch((item['server_mtime'] as int) * 1000)
              : null,
          isFolder: isDir,
          folderId: request.folderId,
        );
        if (isDir) {
          folders.add(file);
        } else {
          files.add(file);
        }
      }
    }
    return BaiduFileListResponse(files: files, folders: folders);
  }

  Future<BaiduOperationResponse> deleteFile({
    required CloudDriveAccount account,
    required BaiduDeleteRequest request,
  }) async {
    final dio = BaiduBaseService.createDio(account);
    final uri = Uri.parse(
      '${dio.options.baseUrl}${BaiduConfig.getApiEndpoint('delete')}',
    );
    final data = {
      'fid_list': [request.file.id],
    };
    final result = await _safeCall<Map<String, dynamic>>(
      () async {
        final response = await dio.postUri(uri, data: data);
        final body = response.data as Map<String, dynamic>? ?? {};
        return BaiduBaseService.handleApiResponse(body);
      },
    );
    return BaiduOperationResponse(
      success: result.success,
      message: result.message,
    );
  }

  Future<BaiduOperationResponse> renameFile({
    required CloudDriveAccount account,
    required BaiduRenameRequest request,
  }) async {
    final dio = BaiduBaseService.createDio(account);
    final uri = Uri.parse(
      '${dio.options.baseUrl}${BaiduConfig.getApiEndpoint('rename')}',
    );
    final data = {
      'file_id': request.file.id,
      'new_name': request.newName,
    };
    final result = await _safeCall<Map<String, dynamic>>(
      () async {
        final response = await dio.postUri(uri, data: data);
        final body = response.data as Map<String, dynamic>? ?? {};
        return BaiduBaseService.handleApiResponse(body);
      },
    );
    return BaiduOperationResponse(
      success: result.success,
      message: result.message,
    );
  }

  Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required BaiduCreateFolderRequest request,
  }) async {
    final dio = BaiduBaseService.createDio(account);
    final uri = Uri.parse(
      '${dio.options.baseUrl}${BaiduConfig.getApiEndpoint('createFolder')}',
    );
    final data = {
      'path': request.parentId ?? '/',
      'isdir': 1,
      'block_list': [],
      'size': 0,
      'uploadid': 'N/A',
      'rtype': 1,
      'name': request.name,
    };
    final result = await _safeCall<Map<String, dynamic>>(
      () async {
        final response = await dio.postUri(uri, data: data);
        final body = response.data as Map<String, dynamic>? ?? {};
        return BaiduBaseService.handleApiResponse(body);
      },
    );
    if (result.success) {
      return CloudDriveFile(
        id: '',
        name: request.name,
        isFolder: true,
        folderId: request.parentId ?? '/',
      );
    }
    return null;
  }

  Future<BaiduOperationResponse> moveFile({
    required CloudDriveAccount account,
    required BaiduMoveRequest request,
  }) async {
    final dio = BaiduBaseService.createDio(account);
    final uri = Uri.parse(
      '${dio.options.baseUrl}${BaiduConfig.getApiEndpoint('move')}',
    );
    final data = {
      'filelist': [
        {'fileid': request.file.id, 'path': request.targetFolderId}
      ],
    };
    final result = await _safeCall<Map<String, dynamic>>(
      () async {
        final response = await dio.postUri(uri, data: data);
        final body = response.data as Map<String, dynamic>? ?? {};
        return BaiduBaseService.handleApiResponse(body);
      },
    );
    return BaiduOperationResponse(
      success: result.success,
      message: result.message,
    );
  }

  Future<BaiduOperationResponse> copyFile({
    required CloudDriveAccount account,
    required BaiduCopyRequest request,
  }) async {
    final dio = BaiduBaseService.createDio(account);
    final uri = Uri.parse(
      '${dio.options.baseUrl}${BaiduConfig.getApiEndpoint('copy')}',
    );
    final data = {
      'filelist': [
        {'fileid': request.file.id, 'path': request.targetFolderId}
      ],
    };
    final result = await _safeCall<Map<String, dynamic>>(
      () async {
        final response = await dio.postUri(uri, data: data);
        final body = response.data as Map<String, dynamic>? ?? {};
        return BaiduBaseService.handleApiResponse(body);
      },
    );
    return BaiduOperationResponse(
      success: result.success,
      message: result.message,
    );
  }

  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required BaiduDownloadRequest request,
  }) {
    final dio = BaiduBaseService.createDio(account);
    final uri = Uri.parse(
      '${dio.options.baseUrl}${BaiduConfig.getApiEndpoint('download')}',
    );
    final data = {'fid_list': [request.file.id], 'type': 'dlink'};
    return _safeCall<String?>(() async {
      final response = await dio.postUri(uri, data: data);
      final body = response.data as Map<String, dynamic>? ?? {};
      final handled = BaiduBaseService.handleApiResponse(body);
      final dlinks = handled['dlink'] as List<dynamic>? ?? [];
      if (dlinks.isNotEmpty) {
        final first = dlinks.first as Map<String, dynamic>? ?? {};
        return first['dlink']?.toString();
      }
      return null;
    }).then((r) => r.data);
  }

  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    if (files.isEmpty) return null;
    return _safeCall<String?>(
      () => BaiduCloudDriveService.createShareLink(
        account: account,
        fileId: files.first.id,
        password: password,
        expireTime: expireDays ?? 0,
      ),
    ).then((r) => r.data);
  }

  Future<BaiduApiResult<T>> _safeCall<T>(Future<T> Function() fn) async {
    try {
      final data = await fn();
      return BaiduApiResult<T>(success: true, data: data);
    } catch (e) {
      return BaiduApiResult<T>(success: false, message: e.toString());
    }
  }
}
