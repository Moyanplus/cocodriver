import 'package:dio/dio.dart';

import '../../../../data/models/cloud_drive_entities.dart';
import '../../../shared/http_client.dart';
import '../models/requests/baidu_list_request.dart';
import '../models/requests/baidu_operation_requests.dart';
import '../models/responses/baidu_file_list_response.dart';
import '../models/responses/baidu_operation_response.dart';
import '../models/responses/baidu_api_result.dart';
import '../models/responses/baidu_share_record.dart';
import '../services/baidu_base_service.dart';
import '../baidu_config.dart';
import '../services/baidu_param_service.dart';

/// 百度网盘 API 客户端（当前复用已有 Service，统一 DTO）。
class BaiduApiClient {
  Future<BaiduFileListResponse> listFiles({
    required CloudDriveAccount account,
    required BaiduListRequest request,
  }) async {
    final http = BaiduBaseService.createHttpClient(account);
    final uri = http.buildUri(
      '${BaiduConfig.baseUrl}${BaiduConfig.getApiEndpoint('fileList')}',
      BaiduBaseService.buildRequestParams(
        dir: request.folderId,
        page: request.page,
        num: request.pageSize,
      ).map((k, v) => MapEntry(k, v.toString())),
    );

    final result = await _safeCall<Map<String, dynamic>>(() async {
      final data = await http.getMap(uri);
      return BaiduBaseService.handleApiResponse(data);
    }, client: http);

    final respData = result.data ?? {};
    final list = respData['list'] as List<dynamic>? ?? [];
    final files = <CloudDriveFile>[];
    final folders = <CloudDriveFile>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final isDir = (item['isdir']?.toString() ?? '0') == '1';
        final timestamp =
            item['server_mtime'] is int
                ? DateTime.fromMillisecondsSinceEpoch(
                  (item['server_mtime'] as int) * 1000,
                )
                : null;
        final file = CloudDriveFile(
          id: item['fs_id']?.toString() ?? '',
          name: item['server_filename']?.toString() ?? '',
          size:
              item['size'] is int
                  ? item['size'] as int
                  : int.tryParse('${item['size'] ?? ''}'),
          updatedAt: timestamp,
          createdAt: timestamp,
          isFolder: isDir,
          folderId: request.folderId,
          path: item['path']?.toString(),
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
    return _fileManagerOperation(
      account: account,
      operation: 'delete',
      filePaths: [request.sourcePath],
    );
  }

  Future<BaiduOperationResponse> renameFile({
    required CloudDriveAccount account,
    required BaiduRenameRequest request,
  }) async {
    return _fileManagerOperation(
      account: account,
      operation: 'rename',
      filePaths: [request.sourcePath],
      newName: request.newName,
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
    final result = await _safeCall<Map<String, dynamic>>(() async {
      final response = await dio.postUri(uri, data: data);
      final body = response.data as Map<String, dynamic>? ?? {};
      return BaiduBaseService.handleApiResponse(body);
    });
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
    return _fileManagerOperation(
      account: account,
      operation: 'move',
      filePaths: [request.sourcePath],
      targetPath: request.targetFolderId,
    );
  }

  Future<BaiduOperationResponse> copyFile({
    required CloudDriveAccount account,
    required BaiduCopyRequest request,
  }) async {
    return _fileManagerOperation(
      account: account,
      operation: 'copy',
      filePaths: [request.sourcePath],
      targetPath: request.targetFolderId,
    );
  }

  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required BaiduDownloadRequest request,
  }) {
    final http = BaiduBaseService.createHttpClient(account);
    final uri = http.buildUri(
      '${BaiduConfig.baseUrl}${BaiduConfig.getApiEndpoint('download')}',
      const {},
    );
    final data = {
      'fid_list': [request.file.id],
      'type': 'dlink',
    };
    return _safeCall<String?>(() async {
      final body = await http.postMap(uri, data: data);
      final handled = BaiduBaseService.handleApiResponse(body);
      final dlinks = handled['dlink'] as List<dynamic>? ?? [];
      if (dlinks.isNotEmpty) {
        final first = dlinks.first as Map<String, dynamic>? ?? {};
        return first['dlink']?.toString();
      }
      return null;
    }, client: http).then((r) => r.data);
  }

  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    if (files.isEmpty) return null;
    final bdstoken = await _bdstokenOrThrow(account);
    final http = BaiduBaseService.createHttpClient(account);
    final url = http.buildUri(
      BaiduConfig.getApiUrl(BaiduConfig.endpoints['share']!),
      {'bdstoken': bdstoken},
    );
    final filePaths =
        files
            .map(
              (f) =>
                  f.path != null && f.path!.isNotEmpty ? f.path! : '/${f.name}',
            )
            .toList();
    final body = BaiduConfig.buildShareParams(
      fileList: filePaths,
      password: password,
      expireTime: expireDays,
    );

    final result = await _safeCall<Map<String, dynamic>>(() async {
      final data = await http.postMap(url, data: body);
      return BaiduBaseService.handleApiResponse(data);
    });

    if (!result.success) return null;
    final data = result.data ?? {};
    final shareId = data['shareid']?.toString();
    return shareId == null ? null : 'https://pan.baidu.com/s/$shareId';
  }

  /// 获取分享记录列表
  Future<List<BaiduShareRecord>> listShareRecords({
    required CloudDriveAccount account,
    int page = 1,
    int pageSize = 50,
  }) async {
    final http = BaiduBaseService.createHttpClient(account);
    final uri = http.buildUri('${BaiduConfig.baseUrl}/share/record', {
      'channel': 'chunlei',
      'num': pageSize.toString(),
      'page': page.toString(),
      'order': 'ctime',
      'desc': '1',
      'is_batch': '1',
    });

    final result = await _safeCall<Map<String, dynamic>>(() async {
      final data = await http.getMap(uri);
      return BaiduBaseService.handleApiResponse(data);
    });

    if (!(result.success)) return const [];
    final data = result.data ?? {};
    final list = data['list'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(BaiduShareRecord.fromJson)
        .toList(growable: false);
  }

  /// 回收站列表
  Future<List<CloudDriveFile>> listRecycle({
    required CloudDriveAccount account,
    int page = 1,
    int pageSize = 100,
  }) async {
    final http = BaiduBaseService.createHttpClient(account);
    final uri = http.buildUri('${BaiduConfig.baseUrl}/api/recycle/list/', {
      'num': pageSize.toString(),
      'page': page.toString(),
    });

    final result = await _safeCall<Map<String, dynamic>>(() async {
      final data = await http.getMap(uri);
      return BaiduBaseService.handleApiResponse(data);
    });

    if (!result.success) return const [];
    final list =
        (result.data?['list'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>();

    DateTime? _ts(int? v) =>
        v == null ? null : DateTime.fromMillisecondsSinceEpoch(v * 1000);

    return list
        .map(
          (item) => CloudDriveFile(
            id: item['fs_id']?.toString() ?? '',
            name: item['server_filename']?.toString() ?? '',
            isFolder: (item['isdir'] ?? 0) == 1,
            size: item['size'] as int?,
            createdAt: _ts(item['server_ctime'] as int?),
            updatedAt: _ts(item['server_mtime'] as int?),
            path: item['path']?.toString(),
            metadata: {
              'leftTime': item['leftTime'],
              'deleteType': item['delete_type'],
              'md5': item['md5'],
            },
          ),
        )
        .toList(growable: false);
  }

  Future<BaiduOperationResponse> _fileManagerOperation({
    required CloudDriveAccount account,
    required String operation,
    required List<String> filePaths,
    String? targetPath,
    String? newName,
  }) async {
    final String bdstoken;
    try {
      bdstoken = await _bdstokenOrThrow(account);
    } catch (e) {
      return BaiduOperationResponse(success: false, message: e.toString());
    }

    final http = BaiduBaseService.createHttpClient(account);
    final urlParams = BaiduConfig.buildFileManagerUrlParams(
      operation: operation,
      bdstoken: bdstoken,
    );
    final body = BaiduConfig.buildFileManagerBody(
      operation: operation,
      fileList: filePaths,
      targetPath: targetPath,
      newName: newName,
    );
    final formData = FormData.fromMap(body);
    final uri = http.buildUri(
      BaiduConfig.getApiUrl(BaiduConfig.endpoints['fileManager']!),
      urlParams.map((k, v) => MapEntry(k, v.toString())),
    );

    final result = await _safeCall<Map<String, dynamic>>(() async {
      final data = await http.postMap(uri, data: formData);
      return BaiduBaseService.handleApiResponse(data);
    });

    final data = result.data ?? {};
    final errno = data['errno'] as int? ?? (result.success ? 0 : -1);
    final success = result.success && errno == 0;
    final message = result.message ?? BaiduConfig.getResponseMessage(data);

    return BaiduOperationResponse(success: success, message: message);
  }

  Future<BaiduApiResult<T>> _safeCall<T>(
    Future<T> Function() fn, {
    CloudDriveHttpClient? client,
  }) async {
    try {
      final data = await fn();
      return BaiduApiResult<T>(success: true, data: data);
    } catch (e) {
      if (e is DioException) {
        final msg =
            client?.formatDioError(e) ??
            'HTTP ${e.response?.statusCode ?? 'error'} ${e.requestOptions.method} ${e.requestOptions.uri}: ${e.message}';
        return BaiduApiResult<T>(success: false, message: msg);
      }
      return BaiduApiResult<T>(success: false, message: e.toString());
    }
  }

  Future<String> _bdstokenOrThrow(CloudDriveAccount account) async {
    final params = await BaiduParamService.getBaiduParams(account);
    final bdstoken = params['bdstoken']?.toString();
    if (bdstoken == null || bdstoken.isEmpty) {
      throw Exception('未获取到bdstoken，请重新登录');
    }
    return bdstoken;
  }

  CloudDriveHttpClient _http(Dio dio) => CloudDriveHttpClient(
    provider: '百度网盘',
    dio: dio,
    defaultQueryBuilder: (extra) => BaiduConfig.buildDefaultQuery(extra: extra),
  );
}
