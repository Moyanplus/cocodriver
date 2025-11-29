/// 中国移动云盘配置类
///
/// 集中管理中国移动云盘的所有配置参数，包括 API 端点、请求头、超时设置等。
class ChinaMobileConfig {
  // API 配置
  // 基础 API 域名（使用实际返回 200 的 personal 节点，避免 302 跳转）
  static const String baseUrl = 'https://personal-kd-njs.yun.139.com';

  // 编排服务 URL（保持原值，如需调整可按实际接口地址修改）
  static const String orchestrationUrl = 'https://orchestration.139.com';

  // 文件夹配置
  static const String rootFolderId = '/'; // 根目录ID
  static const String defaultFolderId = '/'; // 默认文件夹ID

  // API 端点配置
  static const Map<String, String> apiEndpoints = {
    'getFileList': '/hcy/file/list', // 获取文件列表
    'createFolder': '/hcy/file/create', // 创建文件夹
    'createFile': '/hcy/file/create', // 初始化文件上传
    'completeUpload': '/hcy/file/complete', // 完成上传
    'getDownloadUrl': '/hcy/file/getDownloadUrl', // 获取下载链接
    'getShareLink':
        '/orchestration/personalCloud-rebuild/outlink/v1.0/getOutLink', // 获取分享链接
    'updateFile': '/hcy/file/update', // 重命名文件
    'batchMove': '/hcy/file/batchMove', // 移动文件
    'batchCopy': '/hcy/file/batchCopy', // 复制文件
    'batchTrash': '/hcy/recyclebin/batchTrash', // 删除文件
    'getTask': '/hcy/task/get', // 查询任务状态
    'searchFile': '/search/SearchFile', // 搜索文件
    'getPreviewInfo': '/hcy/videoPreview/getPreviewInfo', // 获取预览信息
  };

  // 请求头配置
  static const Map<String, String> defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0',
    // 'Accept': 'application/json, text/plain, */*',
    // 'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    // 'Accept-Encoding': 'gzip, deflate, br',
    // 'Connection': 'keep-alive',
    // 'Content-Type': 'application/json',
    'Referer': '$baseUrl/',
    'Origin': baseUrl,
    'x-yun-api-version': 'v1',
    'x-yun-app-channel': '10000034',
    'x-yun-client-info':
        '||9|7.16.2|edge||f810f0e1d62dac1dbe172f49b307ee27||macos 10.15.7||zh-CN|||ZWRnZQ==||',
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
  static const String logSubCategory = 'cloudDrive.chinaMobile';

  // 详细日志配置 - 控制是否打印请求头等详细信息
  static bool verboseLogging = true;

  // 响应状态码配置
  static const Map<String, dynamic> responseStatus = {
    'httpSuccess': 200,
    'apiSuccess': true,
    'apiFailure': false,
  };

  // 响应字段名配置
  static const Map<String, String> responseFields = {
    // 基础字段
    'success': 'success',
    'code': 'code',
    'message': 'message',
    'data': 'data',
    // 文件字段
    'fileId': 'fileId',
    'fileName': 'name',
    'name': 'name',
    'size': 'size',
    'updatedAt': 'updated_at',
    'parentFileId': 'parentFileId',
    'thumbnail': 'thumbnail',
    'bigThumbnail': 'bigThumbnail',
    // 下载字段
    'url': 'url',
    'expiration': 'expiration',
    'cdnUrl': 'cdnUrl',
    'cdnSwitch': 'cdnSwitch',
    // 分享字段
    'shareUrl': 'shareUrl',
    'shareId': 'shareId',
    'password': 'password',
    // 任务字段
    'taskId': 'taskId',
    'taskStatus': 'status',
    // 审核字段
    'metadataAuditInfo': 'metadataAuditInfo',
    'contentAuditInfo': 'contentAuditInfo',
    'auditStatus': 'auditStatus',
    'auditLevel': 'auditLevel',
    'auditResult': 'auditResult',
  };

  // 分页配置
  static const int defaultPageSize = 100;
  static const int maxPageSize = 1000;

  // 排序配置
  static const Map<String, String> sortOptions = {
    'updatedAtDesc': 'updated_at:DESC', // 更新时间降序
    'updatedAtAsc': 'updated_at:ASC', // 更新时间升序
    'nameAsc': 'name:ASC', // 名称升序
    'nameDesc': 'name:DESC', // 名称降序
    'sizeAsc': 'size:ASC', // 大小升序
    'sizeDesc': 'size:DESC', // 大小降序
  };

  // 缩略图样式配置
  static const List<String> thumbnailStyles = ['Small', 'Large'];

  // 默认值配置
  static const Map<String, dynamic> defaultValues = {
    'orderBy': 'updated_at',
    'orderDirection': 'DESC',
    'imageThumbnailStyleList': ['Small', 'Large'],
  };

  // 性能配置
  static const Map<String, dynamic> performanceConfig = {
    // 任务轮询配置
    'taskMaxRetries': 30, // 任务最大重试次数
    'taskRetryDelay': 1, // 任务重试间隔(秒)
    // 日志输出配置
    'downloadUrlPreviewLength': 100, // 下载链接预览长度
    'responseDataTruncateLength': 500, // 响应数据截断长度
  };

  /// 获取API端点
  /// 根据操作类型获取对应的API端点
  static String getApiEndpoint(String operation) =>
      apiEndpoints[operation] ?? '';

  /// 验证API端点是否有效
  static bool isValidApiEndpoint(String endpoint) =>
      apiEndpoints.containsValue(endpoint);

  /// 获取所有支持的操作
  static List<String> getSupportedOperations() => apiEndpoints.keys.toList();

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

  /// 获取排序选项
  /// 根据排序类型获取对应的排序字符串
  static String getSortOption(String sortType) =>
      sortOptions[sortType] ?? sortOptions['updatedAtDesc']!;

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    const sizeUnits = {
      'B': 1,
      'KB': 1024,
      'MB': 1024 * 1024,
      'GB': 1024 * 1024 * 1024,
      'TB': 1024 * 1024 * 1024 * 1024,
    };

    if (bytes < sizeUnits['KB']!) {
      return '$bytes B';
    } else if (bytes < sizeUnits['MB']!) {
      return '${(bytes / sizeUnits['KB']!).toStringAsFixed(1)} KB';
    } else if (bytes < sizeUnits['GB']!) {
      return '${(bytes / sizeUnits['MB']!).toStringAsFixed(1)} MB';
    } else if (bytes < sizeUnits['TB']!) {
      return '${(bytes / sizeUnits['GB']!).toStringAsFixed(1)} GB';
    } else {
      return '${(bytes / sizeUnits['TB']!).toStringAsFixed(1)} TB';
    }
  }

  /// 获取操作UI配置
  static Map<String, dynamic> getOperationUIConfig() => {
    'download': {'icon': 'download', 'label': '下载', 'color': 'blue'},
    'delete': {'icon': 'delete', 'label': '删除', 'color': 'red'},
    'move': {'icon': 'move', 'label': '移动', 'color': 'orange'},
    'rename': {'icon': 'edit', 'label': '重命名', 'color': 'green'},
    'copy': {'icon': 'copy', 'label': '复制', 'color': 'purple'},
    'share': {'icon': 'share', 'label': '分享', 'color': 'teal'},
  };

  /// 获取支持的操作状态
  /// 返回各个操作是否支持的状态
  static Map<String, bool> getSupportedOperationsStatus() => {
    'download': true, // 已实现
    'copy': true, // 已实现
    'move': true, // 已实现
    'delete': true, // 已实现
    'rename': true, // 已实现
    'share': true, // 已实现
    'search': true, // 已实现
    'preview': true,
  };
}
