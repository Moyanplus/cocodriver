import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import 'pan123_base_service.dart';
import 'pan123_config.dart';

/// 123云盘文件列表服务
class Pan123FileListService {
  /// 统一错误处理
  static void _handleError(
    String operation,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    LogManager().cloudDrive('123云盘 - $operation 失败: $error');
    if (stackTrace != null) {
      LogManager().cloudDrive('错误堆栈: $stackTrace');
    }
  }

  /// 统一日志记录
  static void _logInfo(String message, {Map<String, dynamic>? params}) {
    LogManager().cloudDrive(message);
  }

  /// 统一成功日志记录
  static void _logSuccess(String message, {Map<String, dynamic>? details}) {
    LogManager().cloudDrive('123云盘 - $message');
  }

  /// 统一错误日志记录
  static void _logError(String message, dynamic error) {
    LogManager().cloudDrive('123云盘 - $message: $error');
  }

  /// 获取文件列表
  static Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String parentId = '0',
    int page = 1,
    int limit = 100,
    String? orderBy,
    String? orderDirection,
    String? searchValue,
  }) async {
    try {
      _logInfo('�� 123云盘 - 获取文件列表开始', params: {'parentId': parentId});
      _logInfo('123云盘 - 父文件夹ID: $parentId', params: {'parentId': parentId});
      _logInfo(
        '123云盘 - 页码: $page, 每页数量: $limit',
        params: {'page': page, 'limit': limit},
      );

      // 创建Dio实例
      final dio = Pan123BaseService.createDio(account);

      // 构建请求参数
      final params = Pan123BaseService.buildRequestParams(
        parentId: parentId,
        page: page,
        limit: limit,
        orderBy: orderBy,
        orderDirection: orderDirection,
        searchValue: searchValue,
      );

      // 使用配置中的API端点
      final url = Uri.parse(
        Pan123Config.getApiUrl(Pan123Config.endpoints['fileList']!),
      );

      _logInfo(
        '123云盘 - 请求URL: ${url.toString()}',
        params: {'url': url.toString()},
      );
      _logInfo('123云盘 - 查询参数: $params', params: {'params': params});

      // 发送GET请求，将参数作为查询参数
      final uri = url.replace(
        queryParameters: params.map((k, v) => MapEntry(k, v.toString())),
      );

      _logInfo('123云盘 - 完整请求URL: $uri', params: {'uri': uri.toString()});

      final response = await dio.get(uri.toString());

      _logInfo(
        '123云盘 - 响应状态: ${response.statusCode}',
        params: {'statusCode': response.statusCode},
      );

      final responseData = response.data as Map<String, dynamic>;

      _logInfo(
        '123云盘 - 原始响应数据: $responseData',
        params: {'responseData': responseData},
      );

      // 检查API响应码
      final code = responseData['code'] as int?;
      final message = responseData['message'] as String?;

      if (code != 200) {
        _logError('123云盘 - API返回错误: $message (code: $code)', message);

        // 特殊处理cookie验证失败
        if (code == 401 && message?.contains('cookie token is empty') == true) {
          throw Exception('123云盘账号登录已失效，请重新登录');
        }

        throw Exception('123云盘API错误: $message (code: $code)');
      }

      // 处理API响应
      final processedResponse = Pan123BaseService.handleApiResponse(
        responseData,
      );

      // 解析文件列表 - 适配新的API响应格式
      final files = <CloudDriveFile>[];

      // 检查响应数据结构
      final data = processedResponse['data'];
      if (data == null) {
        _logInfo('123云盘 - 响应中没有data字段', params: {'data': data});
        return files;
      }

      // 新版API可能直接在data中包含文件列表，也可能在file_info_bean_list中
      List<dynamic> fileList = [];

      if (data is List) {
        // 如果data直接是列表
        fileList = data;
      } else if (data is Map<String, dynamic>) {
        // 根据实际的API响应格式，文件列表在InfoList中
        fileList =
            (data['InfoList'] as List?) ??
            (data['file_info_bean_list'] as List?) ??
            (data['list'] as List?) ??
            (data['files'] as List?) ??
            [];
      }

      _logInfo(
        '123云盘 - 解析到的文件列表数量: ${fileList.length}',
        params: {'fileListLength': fileList.length},
      );

      // 如果有总数信息，也记录一下
      if (data is Map<String, dynamic>) {
        final total = data['Total'] as int?;
        final len = data['Len'] as int?;
        if (total != null || len != null) {
          _logInfo(
            '123云盘 - API返回统计: Total=$total, Len=$len',
            params: {'total': total, 'len': len},
          );
        }
      }

      for (int i = 0; i < fileList.length; i++) {
        final fileData = fileList[i] as Map<String, dynamic>;

        try {
          final file = _parseFileData(fileData);
          files.add(file);

          _logInfo(
            '123云盘 - 解析文件成功: ${file.name} (ID: ${file.id})',
            params: {'fileName': file.name, 'fileId': file.id},
          );
        } catch (e) {
          _logError('123云盘 - 解析文件失败: $fileData, 错误: $e', e);
        }
      }

      _logSuccess(
        '123云盘 - 成功获取 ${files.length} 个文件',
        details: {'fileCount': files.length},
      );

      return files;
    } catch (e) {
      _handleError('获取文件列表', e, null);
      rethrow;
    }
  }

  /// 解析文件数据
  static CloudDriveFile _parseFileData(Map<String, dynamic> fileData) {
    _logInfo('123云盘 - 解析文件数据: $fileData', params: {'fileData': fileData});

    // 根据实际API响应格式解析字段
    final id = fileData['FileId']?.toString() ?? '';
    final name = fileData['FileName']?.toString() ?? '';
    final size = fileData['Size']?.toString() ?? '0';
    final type = fileData['Type'] as int? ?? 0;
    final isFolder = type == 1; // Type=1表示文件夹，Type=0表示文件
    final updateAt = fileData['UpdateAt']?.toString() ?? '';

    _logInfo(
      '123云盘 - 解析结果: ID=$id, Name=$name, Size=$size, Type=$type, IsFolder=$isFolder',
      params: {
        'id': id,
        'name': name,
        'size': size,
        'type': type,
        'isFolder': isFolder,
      },
    );

    // 使用配置中的文件大小格式化
    String formattedSize = '0 B';
    if (size != '0' && !isFolder) {
      final sizeInBytes = int.tryParse(size);
      if (sizeInBytes != null && sizeInBytes > 0) {
        formattedSize = Pan123Config.formatFileSize(sizeInBytes);
      }
    }

    // 时间格式化 - 处理ISO 8601格式
    String formattedTime = '';
    if (updateAt.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(updateAt);
        formattedTime = Pan123Config.formatDateTime(dateTime);
      } catch (e) {
        _logError('123云盘 - 时间解析失败: $updateAt, 错误: $e', e);
        formattedTime = updateAt;
      }
    }

    final file = CloudDriveFile(
      id: id,
      name: name,
      size: int.tryParse(formattedSize) ?? 0,
      modifiedTime: DateTime.tryParse(formattedTime),
      isFolder: isFolder,
      folderId: fileData['ParentFileId']?.toString() ?? '0',
    );

    _logInfo(
      '123云盘 - 文件解析完成: ${file.name} (${file.isFolder ? '文件夹' : '文件'})',
      params: {'fileName': file.name, 'isFolder': file.isFolder},
    );

    return file;
  }
}
