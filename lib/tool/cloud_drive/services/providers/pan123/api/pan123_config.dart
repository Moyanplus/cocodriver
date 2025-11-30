/// 123云盘配置类
///
/// 集中管理 123 云盘所有常量、端点与工具方法，其他模块只需依赖此类即可保持配置一致。
class Pan123Config {
  // API 配置
  static const String baseUrl = 'https://www.123pan.com';
  static const String apiBaseUrl = 'https://www.123pan.com/b/api';
  // 分享域名带上 /b/api 前缀，避免返回 HTML
  static const String shareBaseUrl = 'https://www.123684.com/b/api';

  // API 端点配置
  static const Map<String, String> endpoints = {
    'fileList': '/file/list/new', // 获取文件列表
    'fileInfo': '/file/info', // 获取文件信息
    'downloadInfo': '/file/download_info', // 获取下载信息
    'download': '/file/download', // 获取下载链接
    'upload': '/file/upload', // 上传文件
    // 删除接口：使用 /file/trash 将文件移入回收站，避免误用永久删除接口
    'delete': '/file/trash',
    'move': '/file/mod_pid', // 移动文件
    'copy': '/restful/goapi/v1/file/copy/async', // 复制文件
    'rename': '/file/rename', // 重命名文件
    'createFolder': '/file/upload_request', // 创建文件夹 / 上传初始化
    'share': '/file/share', // 分享文件
    'search': '/file/search', // 搜索文件
    'recycle': '/file/trash', // 回收站
    'shareListFree': '/share/list', // 免费分享列表
    'shareListPaid': '/restful/goapi/v1/share/content/payment/list', // 付费分享列表
    'shareDelete': '/share/delete', // 取消分享
    'userInfo': '/user/info', // 用户信息
    'space': '/user/space', // 空间信息
    // 上传相关
    'uploadInit': '/file/upload_request',
    'uploadAuth': '/file/s3_upload_object/auth',
    'uploadComplete': '/file/upload_complete/v2',
    // 离线下载
    'offlineResolve': '/v2/offline_download/task/resolve',
    'offlineSubmit': '/v2/offline_download/task/submit',
    'offlineList': '/offline_download/task/list',
  };

  // 请求头配置
  static const Map<String, String> defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'App-Version': '3',
    'Platform': 'web',
    'Referer': 'https://www.123pan.com/',
    'Origin': 'https://www.123pan.com',
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
  static const bool enableDetailedLog = true; // 详细日志开关（请求头/响应体）

  // 文件夹配置
  static const String rootFolderId = '0'; // 根目录ID
  static const String defaultFolderId = '0'; // 默认文件夹ID

  // 分页配置
  static const int defaultPageSize = 100; // 默认每页数量
  static const int maxPageSize = 1000; // 最大每页数量

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
}
