import 'dart:convert';

/// 百度网盘配置类
///
/// 集中管理百度网盘的所有配置参数，包括 API 端点、请求头、超时设置等。
class BaiduConfig {
  // API 配置
  static const String baseUrl = 'https://pan.baidu.com';
  static const String apiBaseUrl = 'https://pan.baidu.com/api';

  // API 端点配置（后续可补充校验/重试等）
  static const Map<String, String> endpoints = {
    'fileList': '/api/list', // 获取文件列表
    'delete': '/api/delete', // 删除
    'rename': '/api/rename', // 重命名
    'move': '/api/move', // 移动
    'copy': '/api/copy', // 复制
    'download': '/api/download', // 获取下载链接
    'createFolder': '/api/create', // 新建文件夹
    'share': '/api/share/set', // 分享
    // filemanager 已经在 apiBaseUrl 下，避免重复 /api，末尾不再带 /api 前缀
    'fileManager': '/filemanager', // 文件操作（移动/复制/删除等）
  };

  static String getApiEndpoint(String key) => endpoints[key] ?? '/';

  // 默认请求头
  static const Map<String, String> defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Referer': 'https://pan.baidu.com/disk/home',
    'Accept': 'application/json, text/plain, */*',
    'Content-Type': 'application/x-www-form-urlencoded',
    'Origin': 'https://pan.baidu.com',
  };

  // 超时配置
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // 重定向配置
  static const bool followRedirects = true;
  static const int maxRedirects = 5;

  // 状态码验证
  static bool Function(int?)? get validateStatus =>
      (statusCode) =>
          statusCode != null && statusCode >= 200 && statusCode < 300;

  // 日志分类
  static const String logSubCategory = 'cloudDrive.baidu';

  // 文件夹配置
  static const String rootFolderId = '/';
  static const String defaultFolderId = '/';
  static const int defaultPageSize = 100;
  static const int maxPageSize = 1000;

  // 文件大小单位
  static const List<String> sizeUnits = ['B', 'KB', 'MB', 'GB', 'TB'];

  // 错误码映射
  static const Map<int, String> errorMessages = {
    0: '请求成功',
    1: '参数错误',
    2: '文件不存在',
    3: '权限不足',
    4: '文件已存在',
    5: '空间不足',
    6: '网络错误',
    7: '服务器错误',
    8: '操作超时',
    9: '文件被占用',
    10: '文件名包含非法字符',
    11: '文件过大',
    12: '文件类型不支持',
    13: '分享链接已失效',
    14: '分享密码错误',
    15: '分享文件不存在',
    16: '分享已过期',
    17: '分享次数已达上限',
    18: '分享功能被禁用',
    19: '文件正在被其他用户操作',
    20: '操作过于频繁，请稍后再试',
    -1: '未知错误',
    -2: '网络连接失败',
    -3: '认证失败',
    -4: '会话过期',
    -5: '账号被限制',
    -6: 'IP被限制',
    -7: '设备被限制',
    -8: '操作被拒绝',
    -9: '文件系统错误',
    -10: '数据库错误',
    132: '需要安全验证（验证码/滑块），请在网页完成验证后重试',
  };

  // 支持的文件类型
  static const List<String> supportedFileTypes = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
    'mp4',
    'avi',
    'mov',
    'wmv',
    'flv',
    'mkv',
    'webm',
    'mp3',
    'wav',
    'flac',
    'aac',
    'ogg',
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'rtf',
    'zip',
    'rar',
    '7z',
    'tar',
    'gz',
  ];

  // 上传配置
  static const int maxUploadSize = 2 * 1024 * 1024 * 1024; // 2GB
  static const int chunkSize = 4 * 1024 * 1024; // 4MB
  static const int maxConcurrentUploads = 3;
  static const int maxConcurrentDownloads = 5;
  static const Duration downloadTimeout = Duration(minutes: 30);

  /// 获取完整的API URL
  static String getApiUrl(String endpoint) => '$apiBaseUrl$endpoint';

  /// 获取错误信息
  static String getErrorMessage(int errno) =>
      errorMessages[errno] ?? errorMessages[-1] ?? '未知错误 (errno: $errno)';

  /// 获取文件夹ID
  static String getFolderId(String folderId) {
    if (folderId.isEmpty || folderId == '/') {
      return rootFolderId;
    }
    return folderId.startsWith('/') ? folderId : '/$folderId';
  }

  /// 解析文件大小
  static int? parseFileSize(String sizeStr) {
    if (sizeStr.isEmpty) return null;

    // 移除所有空格
    final cleanSize = sizeStr.replaceAll(RegExp(r'\s+'), '');

    // 匹配数字和单位
    final match = RegExp(
      r'^(\d+(?:\.\d+)?)\s*([KMGT]?B)$',
      caseSensitive: false,
    ).firstMatch(cleanSize);
    if (match == null) return null;

    final value = double.parse(match.group(1)!);
    final unit = match.group(2)!.toUpperCase();

    switch (unit) {
      case 'B':
        return value.toInt();
      case 'KB':
        return (value * 1024).toInt();
      case 'MB':
        return (value * 1024 * 1024).toInt();
      case 'GB':
        return (value * 1024 * 1024 * 1024).toInt();
      case 'TB':
        return (value * 1024 * 1024 * 1024 * 1024).toInt();
      default:
        return null;
    }
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < sizeUnits.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    if (unitIndex == 0) {
      return '${size.toInt()} ${sizeUnits[unitIndex]}';
    } else {
      return '${size.toStringAsFixed(1)} ${sizeUnits[unitIndex]}';
    }
  }

  /// 检查文件类型是否支持
  static bool isFileTypeSupported(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return supportedFileTypes.contains(extension);
  }

  /// 获取MIME类型
  static String getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      case 'mp3':
        return 'audio/mpeg';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'application/octet-stream';
    }
  }

  /// 检查响应是否成功
  static bool isSuccessResponse(Map<String, dynamic> response) {
    final errno = response['errno'] as int?;
    return errno == 0;
  }

  /// 获取响应数据
  static Map<String, dynamic>? getResponseData(Map<String, dynamic> response) =>
      response['data'] as Map<String, dynamic>?;

  /// 获取响应消息
  static String getResponseMessage(Map<String, dynamic> response) {
    final errno = response['errno'] as int? ?? -1;
    final message = response['errmsg'] as String?;

    if (message != null && message.isNotEmpty) {
      return message;
    }

    return getErrorMessage(errno);
  }

  /// 构建文件管理操作参数
  static Map<String, dynamic> buildFileManagerParams({
    required String operation,
    required List<String> fileList,
    String? targetPath,
    String? newName,
    Map<String, dynamic>? extraParams,
  }) {
    final params = <String, dynamic>{'opera': operation};

    // 根据操作类型构建不同的filelist格式
    if (operation == 'move' || operation == 'copy') {
      // 移动和复制操作使用新的API格式
      params['filelist'] =
          fileList.map((filePath) {
            final fileName = filePath.split('/').last;
            return {
              'path': filePath,
              'dest': targetPath ?? '/',
              'newname': fileName,
            };
          }).toList();
    } else {
      // 其他操作（重命名、删除等）使用原有格式
      params['filelist'] =
          fileList.map((file) => '["$file",null,null]').toList();
    }

    if (targetPath != null && (operation == 'move' || operation == 'copy')) {
      params['target'] = targetPath;
    }

    if (newName != null) {
      params['newname'] = newName;
    }

    if (extraParams != null) {
      params.addAll(extraParams);
    }

    return params;
  }

  /// 构建文件管理操作URL查询参数
  static Map<String, dynamic> buildFileManagerUrlParams({
    required String operation,
    String? bdstoken,
    Map<String, dynamic>? extraParams,
  }) {
    final params = <String, dynamic>{
      // 使用同步模式(0)等待服务端完成，避免异步 taskid 导致列表刷新为空
      'async': 0,
      'onnest': 'fail',
      'opera': operation,
      'clienttype': 0,
      'app_id': 250528,
      'web': 1,
      'dp-logid': DateTime.now().millisecondsSinceEpoch.toString().padLeft(
        20,
        '0',
      ),
    };

    if (bdstoken != null) {
      params['bdstoken'] = bdstoken;
    }

    if (extraParams != null) {
      params.addAll(extraParams);
    }

    return params;
  }

  /// 构建文件管理操作请求体（表单数据格式）
  static Map<String, String> buildFileManagerBody({
    required String operation,
    required List<String> fileList,
    String? targetPath,
    String? newName,
  }) {
    final body = <String, String>{};

    // 根据操作类型构建不同的filelist格式
    String filelistJson;
    if (operation == 'move' || operation == 'copy') {
      // 移动和复制操作：构建包含path、dest、newname的对象数组
      final fileListData =
          fileList.map((filePath) {
            final fileName = filePath.split('/').last;
            return {
              'path': filePath,
              'dest': targetPath ?? '/',
              'newname': fileName,
            };
          }).toList();
      filelistJson = jsonEncode(fileListData);
    } else if (operation == 'delete') {
      // 删除操作：使用简单的文件路径数组
      filelistJson = jsonEncode(fileList);
    } else if (operation == 'rename') {
      // 重命名操作：包含path和newname
      final fileListData =
          fileList
              .map(
                (file) => {
                  'path': file,
                  'newname': newName ?? file.split('/').last,
                },
              )
              .toList();
      filelistJson = jsonEncode(fileListData);
    } else {
      // 其他操作：使用原有格式
      final fileListData =
          fileList.map((file) => '["$file",null,null]').toList();
      filelistJson = jsonEncode(fileListData);
    }

    // 将filelist作为字符串值添加到表单数据中
    body['filelist'] = filelistJson;

    return body;
  }

  /// 构建分享参数
  static Map<String, dynamic> buildShareParams({
    required List<String> fileList,
    String? password,
    int? expireTime,
    bool? isPublic,
  }) {
    final params = <String, dynamic>{
      'schannel': 4,
      'channel_list': '[]',
      'period': expireTime ?? 0,
      'pwd': password ?? '',
      'fid_list': fileList.map((file) => '["$file",null,null]').toList(),
    };

    if (isPublic != null) {
      params['public'] = isPublic ? 1 : 0;
    }

    return params;
  }

  /// 验证文件路径
  static bool isValidPath(String path) {
    if (path.isEmpty) return false;

    // 检查是否包含非法字符
    final invalidChars = RegExp(r'[<>:"|?*]');
    if (invalidChars.hasMatch(path)) return false;

    // 检查路径长度
    if (path.length > 255) return false;

    return true;
  }

  /// 清理文件名
  static String sanitizeFileName(String fileName) {
    // 移除或替换非法字符
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  /// 获取操作类型描述
  static String getOperationDescription(String operation) {
    switch (operation) {
      case 'copy':
        return '复制';
      case 'move':
        return '移动';
      case 'rename':
        return '重命名';
      case 'delete':
        return '删除';
      case 'download':
        return '下载';
      case 'upload':
        return '上传';
      case 'share':
        return '分享';
      default:
        return operation;
    }
  }

  /// 构建账号配额查询参数
  static Map<String, dynamic> buildQuotaParams() {
    return {
      'clienttype': 0,
      'app_id': 250528,
      'web': 1,
      'dp-logid': DateTime.now().millisecondsSinceEpoch.toString().padLeft(
        20,
        '0',
      ),
    };
  }

  /// 构建用户信息查询参数
  static Map<String, dynamic> buildUserInfoParams() {
    return {
      'method': 'query',
      'clienttype': 0,
      'app_id': 250528,
      'web': 1,
      'dp-logid': DateTime.now().millisecondsSinceEpoch.toString().padLeft(
        20,
        '0',
      ),
    };
  }

  /// 构建新建文件夹的URL查询参数
  static Map<String, dynamic> buildCreateFolderUrlParams({String? bdstoken}) {
    final params = <String, dynamic>{
      'a': 'commit',
      'clienttype': 0,
      'app_id': 250528,
      'web': 1,
      'dp-logid': DateTime.now().millisecondsSinceEpoch.toString().padLeft(
        20,
        '0',
      ),
    };

    if (bdstoken != null) {
      params['bdstoken'] = bdstoken;
    }

    return params;
  }

  /// 构建新建文件夹的请求体（表单数据格式）
  static Map<String, String> buildCreateFolderBody({
    required String folderName,
    required String parentPath,
  }) {
    // 确保路径格式正确
    String fullPath = parentPath;
    if (!fullPath.endsWith('/')) {
      fullPath += '/';
    }
    fullPath += folderName;

    return {'path': fullPath, 'isdir': '1', 'block_list': '[]'};
  }

  static bool verboseLogging = true;
}
