/// 蓝奏云配置类
///
/// 集中管理蓝奏云的所有配置参数，包括 API 端点、请求头、超时设置等。
class LanzouConfig {
  // API 配置
  static const String baseUrl = 'https://pc.woozooo.com';
  static const String apiUrl = '$baseUrl/doupload.php';
  static const String uploadUrl = '$baseUrl/html5up.php';
  static const String mydiskUrl = '$baseUrl/mydisk.php';

  // 直链解析相关URL
  static const String lanzoupUrl = 'https://www.lanzoup.com';
  static const String lanzouxUrl = 'https://www.lanzoux.com';

  // 文件夹配置
  static const String rootFolderId = '-1'; // 根目录ID
  static const String defaultFolderId = '-1'; // 默认文件夹ID

  // vei参数配置
  static String? _veiParameter;
  static const String defaultVei = 'UVVTUQRWVwhUBA9f'; // 默认vei参数

  // API 任务配置
  static const Map<String, String> tasks = {
    'getFiles': '5', // 获取文件列表
    'getFolders': '47', // 获取文件夹列表
    'moveFile': '20', // 移动文件
    'deleteFile': '6', // 删除文件
    'renameFile': '46', // 重命名文件
    'createFolder': '2', // 创建文件夹
    'uploadFile': '1', // 上传文件
    'getFileDetail': '22', // 获取文件详情
    'validateCookies': '5', // 验证Cookie
  };

  // 请求头配置
  static const Map<String, String> defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    'Accept-Encoding': 'gzip, deflate, br',
    'DNT': '1',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
  };

  // 页面请求头配置（用于获取vei参数）
  static const Map<String, String> pageHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
  };

  // 直链解析请求头配置
  static const Map<String, String> directLinkHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Encoding': 'gzip, deflate',
    'Accept-Language': 'zh-CN,zh;q=0.9',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'Pragma': 'no-cache',
    'Upgrade-Insecure-Requests': '1',
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
  static const String logSubCategory = 'cloudDrive.lanzou';
  static bool verboseLogging = true;

  // MIME类型配置
  static const Map<String, String> mimeTypes = {
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx': 'application/msword',
    'xls': 'application/vnd.ms-excel',
    'xlsx': 'application/vnd.ms-excel',
    'ppt': 'application/vnd.ms-powerpoint',
    'pptx': 'application/vnd.ms-powerpoint',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'mp4': 'video/mp4',
    'mp3': 'audio/mpeg',
    'zip': 'application/zip',
    'rar': 'application/x-rar-compressed',
    '7z': 'application/x-7z-compressed',
    'txt': 'text/plain',
  };

  /// 设置vei参数
  static void setVeiParameter(String vei) {
    _veiParameter = vei;
  }

  /// 获取vei参数
  /// 如果未设置则返回默认值
  static String getVeiParameter() => _veiParameter ?? defaultVei;

  /// 检查vei参数是否已设置
  static bool hasVeiParameter() => _veiParameter != null;

  /// 清除vei参数
  static void clearVeiParameter() {
    _veiParameter = null;
  }

  /// 获取正确的文件夹ID
  /// 将路径格式的文件夹ID转换为API需要的格式
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

  /// 获取任务ID
  /// 根据操作类型获取对应的API任务ID
  static String getTaskId(String operation) => tasks[operation] ?? '';

  /// 验证任务ID是否有效
  static bool isValidTaskId(String taskId) => tasks.containsValue(taskId);

  /// 获取所有支持的操作
  static List<String> getSupportedOperations() => tasks.keys.toList();

  /// 获取MIME类型
  static String getMimeType(String extension) =>
      mimeTypes[extension.toLowerCase()] ?? 'application/octet-stream';

  /// 验证响应状态
  static bool isSuccessResponse(Map<String, dynamic> response) {
    return response['zt'] == 1;
  }

  /// 获取响应数据
  static Map<String, dynamic>? getResponseData(Map<String, dynamic> response) {
    return response['text'] as Map<String, dynamic>?;
  }

  /// 获取响应消息
  static String getResponseMessage(Map<String, dynamic> response) {
    return response['info']?.toString() ?? '未知错误';
  }
}
