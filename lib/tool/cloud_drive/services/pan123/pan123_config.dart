/// 123云盘配置类
/// 集中管理123云盘的所有配置参数，避免硬编码和耦合
class Pan123Config {
  // API 配置
  static const String baseUrl = 'https://www.123pan.com';
  static const String apiBaseUrl = 'https://www.123pan.com/b/api';

  // API 端点配置
  static const Map<String, String> endpoints = {
    'fileList': '/file/list/new', // 获取文件列表
    'fileInfo': '/file/info', // 获取文件信息
    'downloadInfo': '/file/download_info', // 获取下载信息
    'download': '/file/download', // 获取下载链接
    'upload': '/file/upload', // 上传文件
    'delete': '/file/delete', // 删除文件
    'move': '/file/mod_pid', // 移动文件
    'copy': '/restful/goapi/v1/file/copy/async', // 复制文件
    'rename': '/file/rename', // 重命名文件
    'createFolder': '/file/create', // 创建文件夹
    'share': '/file/share', // 分享文件
    'search': '/file/search', // 搜索文件
    'recycle': '/file/trash', // 回收站
    'userInfo': '/user/info', // 用户信息
    'space': '/user/space', // 空间信息
  };

  // 请求头配置
  static const Map<String, String> defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Referer': 'https://www.123pan.com/',
    'Origin': 'https://www.123pan.com',
    'Sec-Fetch-Dest': 'empty',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Site': 'same-origin',
  };

  // 超时配置
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // 重定向配置
  static const bool followRedirects = true;
  static const int maxRedirects = 5;

  // 验证状态码配置
  static bool Function(int?)? validateStatus =
      (status) => status != null && status < 500;

  // 日志配置
  static const String logSubCategory = 'cloudDrive.pan123';

  // 文件夹配置
  static const String rootFolderId = '0'; // 根目录ID
  static const String defaultFolderId = '0'; // 默认文件夹ID

  // 分页配置
  static const int defaultPageSize = 100; // 默认每页数量
  static const int maxPageSize = 1000; // 最大每页数量

  // 文件大小单位转换配置
  static const Map<String, int> sizeUnits = {
    'B': 1,
    'KB': 1024,
    'MB': 1024 * 1024,
    'GB': 1024 * 1024 * 1024,
    'TB': 1024 * 1024 * 1024 * 1024,
  };

  // 错误码配置
  static const Map<int, String> errorMessages = {
    0: '请求成功',
    -1: '参数错误',
    -2: '文件不存在',
    -3: '父级文件ID不存在或文件已在当前文件夹中',
    -4: '文件已存在',
    -5: '权限不足',
    -6: '空间不足',
    -7: '文件过大',
    -8: '文件类型不支持',
    -9: '网络错误',
    -10: '服务器错误',
    -11: '登录已过期',
    -12: '账号被限制',
    -13: '文件正在处理中',
    -14: '操作过于频繁',
    -15: '文件已被删除',
    -16: '分享链接已失效',
    -17: '密码错误',
    -18: '文件已被占用',
    -19: '不支持的操作',
    -20: '系统维护中',
  };

  // 支持的文件类型配置
  static const List<String> supportedFileTypes = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', // 图片
    'mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv', 'webm', // 视频
    'mp3', 'wav', 'flac', 'aac', 'ogg', // 音频
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', // 文档
    'txt', 'md', 'json', 'xml', 'csv', // 文本
    'zip', 'rar', '7z', 'tar', 'gz', // 压缩包
    'apk', 'ipa', 'exe', 'dmg', 'deb', 'rpm', // 安装包
  ];

  // 上传配置
  static const int maxUploadSize = 5 * 1024 * 1024 * 1024; // 5GB
  static const int chunkSize = 1024 * 1024; // 1MB 分块大小
  static const int maxConcurrentUploads = 3; // 最大并发上传数

  // 下载配置
  static const int maxConcurrentDownloads = 5; // 最大并发下载数
  static const int downloadTimeout = 300; // 下载超时时间（秒）

  /// 获取完整的API URL
  static String getApiUrl(String endpoint) => '$apiBaseUrl$endpoint';

  /// 获取错误信息
  static String getErrorMessage(int code) =>
      errorMessages[code] ?? '未知错误 (code: $code)';

  /// 获取正确的文件夹ID
  static String getFolderId(String? folderId) {
    if (folderId == null || folderId.isEmpty) {
      return defaultFolderId;
    }

    // 处理路径格式的文件夹ID
    if (folderId == '/' || folderId == '\\') {
      return rootFolderId;
    }

    return folderId;
  }

  /// 解析文件大小字符串为字节数
  static int? parseFileSize(String? sizeString) {
    if (sizeString == null || sizeString.isEmpty || sizeString == '0 B') {
      return null;
    }

    final sizeMatch = RegExp(
      r'(\d+(?:\.\d+)?)\s*([KMGT]?B)',
    ).firstMatch(sizeString);
    if (sizeMatch != null) {
      final sizeValue = double.parse(sizeMatch.group(1)!);
      final sizeUnit = sizeMatch.group(2)!;
      final unitMultiplier = sizeUnits[sizeUnit] ?? 1;
      return (sizeValue * unitMultiplier).toInt();
    }

    return null;
  }

  /// 格式化文件大小为可读字符串
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    if (bytes < 1024 * 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(1)} TB';
  }

  /// 验证文件类型是否支持
  static bool isFileTypeSupported(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return supportedFileTypes.contains(extension);
  }

  /// 获取文件MIME类型
  static String getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mp3':
        return 'audio/mpeg';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  /// 验证响应状态
  static bool isSuccessResponse(Map<String, dynamic> response) =>
      response['code'] == 0;

  /// 获取响应数据
  static Map<String, dynamic>? getResponseData(Map<String, dynamic> response) {
    if (isSuccessResponse(response)) {
      return response['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// 获取响应消息
  static String getResponseMessage(Map<String, dynamic> response) =>
      response['message'] as String? ??
      getErrorMessage(response['code'] as int? ?? -1);

  /// 格式化日期时间
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    // 如果是今年，只显示月-日 时:分
    if (year == now.year) {
      return '$month-$day $hour:$minute';
    } else {
      // 如果不是今年，显示年-月-日 时:分
      return '$year-$month-$day $hour:$minute';
    }
  }
}
