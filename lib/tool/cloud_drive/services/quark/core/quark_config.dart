/// 夸克云盘配置类
/// 集中管理夸克云盘的所有配置参数，避免硬编码和耦合
class QuarkConfig {
  // API 配置
  static const String baseUrl = 'https://drive-pc.quark.cn';
  static const String panUrl = 'https://pan.quark.cn';
  static const String uopUrl = 'https://uop.quark.cn'; // 用户操作平台URL
  static const String suUrl = 'https://su.quark.cn'; // 扫码登录URL

  // 文件夹配置
  static const String rootFolderId = '0'; // 根目录ID
  static const String defaultFolderId = '0'; // 默认文件夹ID

  // API 任务配置
  static const Map<String, String> apiEndpoints = {
    'getFileList': '/1/clouddrive/file/sort', // 获取文件列表
    'createShare': '/1/clouddrive/share', // 创建分享
    'getShareInfo': '/1/clouddrive/share/info', // 获取分享信息
    'createFolder': '/1/clouddrive/file', // 创建文件夹
    'deleteFile': '/1/clouddrive/file/delete', // 删除文件
    'moveFile': '/1/clouddrive/file/move', // 移动文件
    'renameFile': '/1/clouddrive/file/rename', // 重命名文件
    'copyFile': '/1/clouddrive/file/copy', // 复制文件
    'getDownloadUrl': '/1/clouddrive/file/download', // 获取下载链接
    'getAccountInfo': '/account/info', // 获取个人信息
    'getMember': '/1/clouddrive/member', // 获取容量信息
    'getTask': '/1/clouddrive/task', // 查询任务状态
    'flushAuth': '/1/clouddrive/auth/pc/flush', // 刷新认证token
  };

  // Pan URL API 端点 (使用pan.quark.cn域名)
  static const Map<String, String> panApiEndpoints = {
    'getAccountInfo': '/account/info', // 获取个人信息
  };

  // UOP URL API 端点 (用于二维码登录，使用uop.quark.cn域名)
  static const Map<String, String> uopApiEndpoints = {
    'generateQRToken': '/cas/ajax/getTokenForQrcodeLogin', // 生成二维码token
    'checkQRStatus': '/cas/ajax/getServiceTicketByQrcodeToken', // 查询二维码状态
  };

  // 请求头配置
  static const Map<String, String> defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Referer': '$panUrl/',
    'Origin': panUrl,
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
  static const String logSubCategory = 'cloudDrive.quark';

  // 响应状态码配置
  static const Map<String, dynamic> responseStatus = {
    'httpSuccess': 200,
    'apiSuccess': 0,
    'apiFailure': -1,
    'qrLoginSuccess': 2000000, // 二维码登录成功状态码
  };

  // 二维码登录配置
  static const Map<String, dynamic> qrLoginConfig = {
    'clientId': '532', // 客户端ID
    'version': '1.2', // API版本
    'requestId': 'fe1e0586-c493-4504-b2ca-f6b5426197a9', // 固定请求ID
    'ssbType': 'weblogin', // 登录类型
    'ucParamStr': '', // UC参数
    'ucBizStr':
        'S:custom|OPT:SAREA@0|OPT:IMMERSIVE@1|OPT:BACK_BTN_STYLE@0', // UC业务参数
    'timeout': 30, // 超时时间(秒)
    'pollInterval': 2, // 轮询间隔(秒)
    'maxPollCount': 150, // 最大轮询次数
    'qrExpireTime': 300, // 二维码过期时间(秒)
  };

  // 响应字段名配置
  static const Map<String, String> responseFields = {
    // 基础字段
    'success': 'success',
    'code': 'code',
    'status': 'status',
    'message': 'message',
    'data': 'data',
    'list': 'list',
    'fid': 'fid',
    'finish': 'finish',
    // 文件字段
    'fileName': 'file_name',
    'name': 'name',
    'size': 'size',
    'fileType': 'file_type',
    'category': 'category',
    'lUpdatedAt': 'l_updated_at',
    'updatedAt': 'updated_at',
    'utime': 'utime',
    'thumbnail': 'thumbnail',
    'bigThumbnail': 'big_thumbnail',
    'previewUrl': 'preview_url',
    // 分享字段
    'shareUrl': 'share_url',
    'fidList': 'fid_list',
    'title': 'title',
    'urlType': 'url_type',
    'expiredType': 'expired_type',
    'passcode': 'passcode',
    'taskResp': 'task_resp',
    'shareId': 'share_id',
    'eventId': 'event_id',
    // 下载字段
    'downloadUrl': 'download_url',
    'fids': 'fids',
    // 账号字段
    'nickname': 'nickname',
    'avatarUri': 'avatarUri',
    'mobilekps': 'mobilekps',
    'totalCapacity': 'total_capacity',
    'useCapacity': 'use_capacity',
    'memberType': 'member_type',
    'isVip': 'is_vip',
    'vipEndTime': 'vip_end_time',
    'memberLevel': 'member_level',
    // 任务字段
    'taskId': 'task_id',
    'taskType': 'task_type',
    'taskTitle': 'task_title',
    'taskStatus': 'status',
    'createdAt': 'created_at',
    'affectedFileNum': 'affected_file_num',
    // 文件夹字段
    'pdirFid': 'pdir_fid',
    'dirPath': 'dir_path',
    'dirInitLock': 'dir_init_lock',
  };

  // 会员类型映射
  static const Map<String, Map<String, String>> memberTypeMapping = {
    'EXP_SVIP': {'type': '超级会员(体验)', 'status': '体验中'},
    'SVIP': {'type': '超级会员', 'status': '已开通'},
    'VIP': {'type': '会员', 'status': '已开通'},
    'default': {'type': '普通用户', 'status': '未开通'},
  };

  // 任务状态配置
  static const Map<String, int> taskStatus = {
    'pending': 0, // 等待中
    'running': 1, // 运行中
    'success': 2, // 成功
    'failed': 3, // 失败
  };

  // 操作类型配置
  static const Map<String, int> actionTypes = {
    'move': 1, // 移动
    'delete': 2, // 删除
    'copy': 3, // 复制
    'rename': 4, // 重命名
  };

  // 文件类型配置
  static const Map<String, int> fileTypes = {
    'folder': 0, // 文件夹
    'file': 1, // 文件
  };

  // 分享过期类型配置
  static const Map<String, int> shareExpiredTypes = {
    'permanent': 1, // 永久
    'oneDay': 2, // 1天
    'sevenDays': 3, // 7天
    'thirtyDays': 4, // 30天
  };

  // 排序配置
  static const Map<String, String> sortOptions = {
    'fileTypeAsc': 'file_type:asc,updated_at:desc', // 文件类型升序，更新时间降序
    'nameAsc': 'file_name:asc', // 文件名升序
    'nameDesc': 'file_name:desc', // 文件名降序
    'sizeAsc': 'size:asc', // 大小升序
    'sizeDesc': 'size:desc', // 大小降序
    'timeAsc': 'updated_at:asc', // 时间升序
    'timeDesc': 'updated_at:desc', // 时间降序
  };

  // 分页配置
  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;

  // 性能配置
  static const Map<String, dynamic> performanceConfig = {
    // 任务轮询配置
    'taskMaxRetries': 30, // 任务最大重试次数
    'taskRetryDelay': 1, // 任务重试间隔(秒)
    // 认证缓存配置
    'authHeadersCacheDuration': 5, // 认证头缓存时间(秒)
    'tokenRefreshThreshold': 1, // token刷新阈值(小时)
    // 日志输出配置
    'downloadUrlPreviewLength': 100, // 下载链接预览长度
    'responseDataTruncateLength': 500, // 响应数据截断长度
    'cookiePreviewLength': 100, // Cookie预览长度
  };

  // 文件列表查询配置
  static const Map<String, String> fileListQueryConfig = {
    'fetchTotal': '1', // 获取总数
    'fetchSubDirs': '0', // 不获取子目录信息
  };

  // Cookie配置
  static const Map<String, String> cookieConfig = {
    'puusKey': '__puus', // __puus cookie键名
    'pusKey': '__pus', // __pus cookie键名
    'expiresPrefix': 'Expires=', // 过期时间前缀
    'gmtSuffix': ' GMT', // GMT时区后缀
  };

  // 默认值配置
  static const Map<String, dynamic> defaultValues = {
    // 账号相关
    'quarkUk': 0, // 夸克云盘没有uk概念，设为0
    'phoneBindStatus': '已绑定', // 手机绑定状态文本
    'normalMemberType': '普通会员', // 普通会员类型
    'vipMemberType': '超级会员', // VIP会员类型
    'memberLevelPrefix': 'LV', // 会员等级前缀
    // 文件相关
    'folderSize': 0, // 文件夹大小固定为0
    'defaultShareTitle': '分享文件', // 默认分享标题
    // 响应状态
    'apiSuccessCode': 'OK', // API成功响应码(字符串)
  };

  // 文件大小单位配置
  static const Map<String, int> sizeUnits = {
    'B': 1,
    'KB': 1024,
    'MB': 1024 * 1024,
    'GB': 1024 * 1024 * 1024,
    'TB': 1024 * 1024 * 1024 * 1024,
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

  /// 获取分享过期类型
  /// 根据过期天数获取对应的类型ID
  static int getShareExpiredType(int? expireDays) {
    if (expireDays == null) {
      return shareExpiredTypes['permanent']!;
    }

    switch (expireDays) {
      case 1:
        return shareExpiredTypes['oneDay']!;
      case 7:
        return shareExpiredTypes['sevenDays']!;
      case 30:
        return shareExpiredTypes['thirtyDays']!;
      default:
        return shareExpiredTypes['permanent']!;
    }
  }

  /// 获取排序选项
  /// 根据排序类型获取对应的排序字符串
  static String getSortOption(String sortType) =>
      sortOptions[sortType] ?? sortOptions['fileTypeAsc']!;

  /// 验证文件类型
  static bool isValidFileType(int fileType) =>
      fileTypes.containsValue(fileType);

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
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

  /// 解析文件大小字符串
  /// 将文件大小字符串转换为字节数
  static int? parseFileSize(String sizeStr) {
    if (sizeStr.isEmpty || sizeStr == '0 B') {
      return 0;
    }

    final match = RegExp(r'(\d+(?:\.\d+)?)\s*([KMGT]?B)').firstMatch(sizeStr);
    if (match != null) {
      final sizeValue = double.parse(match.group(1)!);
      final sizeUnit = match.group(2)!;

      switch (sizeUnit) {
        case 'B':
          return sizeValue.toInt();
        case 'KB':
          return (sizeValue * sizeUnits['KB']!).toInt();
        case 'MB':
          return (sizeValue * sizeUnits['MB']!).toInt();
        case 'GB':
          return (sizeValue * sizeUnits['GB']!).toInt();
        case 'TB':
          return (sizeValue * sizeUnits['TB']!).toInt();
      }
    }

    return null;
  }

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

  /// 构建分享链接
  static String buildShareUrl(String shareId) => '$panUrl/s/$shareId';

  /// 获取Pan URL API端点
  /// 根据操作类型获取对应的Pan URL API端点
  static String getPanApiEndpoint(String operation) =>
      panApiEndpoints[operation] ?? '';

  /// 构建账号信息请求参数
  /// 用于获取夸克账号的个人信息
  static Map<String, dynamic> buildAccountInfoParams() => {
    'fr': 'pc',
    'platform': 'pc',
  };

  /// 构建会员信息请求参数
  /// 用于获取夸克账号的容量和会员信息
  static Map<String, dynamic> buildMemberParams() => {
    'pr': 'ucpro',
    'fr': 'pc',
    'uc_param_str': '',
    'fetch_subscribe': 'true',
    '_ch': 'home',
    'fetch_identity': 'true',
  };

  /// 构建创建文件夹请求参数
  /// 用于夸克云盘创建文件夹API的查询参数
  static Map<String, dynamic> buildCreateFolderParams() => {
    'pr': 'ucpro',
    'fr': 'pc',
    'uc_param_str': '',
  };

  /// 构建文件操作请求参数
  /// 用于夸克云盘移动、删除等文件操作API的查询参数
  static Map<String, dynamic> buildFileOperationParams() => {
    'pr': 'ucpro',
    'fr': 'pc',
    'uc_param_str': '',
  };

  /// 构建移动文件请求体
  /// 用于夸克云盘移动文件API的请求体
  static Map<String, dynamic> buildMoveFileBody({
    required String targetFolderId,
    required List<String> fileIds,
  }) => {
    'action_type': actionTypes['move'],
    'to_pdir_fid': targetFolderId,
    'filelist': fileIds,
    'exclude_fids': <String>[],
  };

  /// 构建复制文件请求体
  /// 用于夸克云盘复制文件API的请求体
  static Map<String, dynamic> buildCopyFileBody({
    required String targetFolderId,
    required List<String> fileIds,
  }) => {
    'action_type': actionTypes['copy'],
    'to_pdir_fid': targetFolderId,
    'filelist': fileIds,
    'exclude_fids': <String>[],
  };

  /// 构建删除文件请求体
  /// 用于夸克云盘删除文件API的请求体
  static Map<String, dynamic> buildDeleteFileBody({
    required List<String> fileIds,
  }) => {
    'action_type': actionTypes['delete'],
    'filelist': fileIds,
    'exclude_fids': <String>[],
  };

  /// 构建重命名文件请求体
  /// 用于夸克云盘重命名文件API的请求体
  static Map<String, dynamic> buildRenameFileBody({
    required String fileId,
    required String newName,
  }) => {'fid': fileId, 'file_name': newName};

  /// 构建下载文件请求体
  /// 用于夸克云盘下载文件API的请求体
  static Map<String, dynamic> buildDownloadFileBody({
    required List<String> fileIds,
  }) => {'fids': fileIds};

  /// 构建任务查询请求参数
  /// 用于夸克云盘任务状态查询API的查询参数
  static Map<String, dynamic> buildTaskQueryParams({
    required String taskId,
    int retryIndex = 0,
  }) => {
    'pr': 'ucpro',
    'fr': 'pc',
    'uc_param_str': '',
    'task_id': taskId,
    'retry_index': retryIndex.toString(),
  };

  /// 获取操作UI配置
  static Map<String, dynamic> getOperationUIConfig() => {
    'download': {'icon': 'download', 'label': '下载', 'color': 'blue'},
    'delete': {'icon': 'delete', 'label': '删除', 'color': 'red'},
    'move': {'icon': 'move', 'label': '移动', 'color': 'orange'},
    'rename': {'icon': 'edit', 'label': '重命名', 'color': 'green'},
    'copy': {'icon': 'copy', 'label': '复制', 'color': 'purple'},
    'share': {'icon': 'share', 'label': '分享', 'color': 'teal'},
    'createFolder': {'icon': 'folder_add', 'label': '新建文件夹', 'color': 'indigo'},
  };

  /// 获取支持的操作状态
  /// 返回各个操作是否支持的状态
  static Map<String, bool> getSupportedOperationsStatus() => {
    'download': true, // 已实现
    'copy': true, // 已实现
    'move': true, // 已实现
    'delete': true, // 已实现
    'rename': true, // 已实现
    'createFolder': true, // 已实现
  };

  // ==================== 二维码登录相关方法 ====================

  /// 获取UOP API端点
  /// 根据操作类型获取对应的UOP API端点
  static String getUopApiEndpoint(String operation) =>
      uopApiEndpoints[operation] ?? '';

  /// 构建二维码内容URL
  /// 根据token生成完整的二维码扫描URL
  static String buildQRContentUrl(String token) {
    final clientId = qrLoginConfig['clientId'];
    final ssbType = qrLoginConfig['ssbType'];
    final ucParamStr = qrLoginConfig['ucParamStr'];
    final ucBizStr = qrLoginConfig['ucBizStr'];

    return '$suUrl/4_eMHBJ?token=$token&client_id=$clientId&ssb=$ssbType&uc_param_str=$ucParamStr&uc_biz_str=$ucBizStr';
  }

  /// 构建二维码状态查询参数
  /// 用于查询二维码登录状态的请求参数
  static Map<String, String> buildQRStatusQueryParams(String token) => {
    'client_id': qrLoginConfig['clientId'] as String,
    'v': qrLoginConfig['version'] as String,
    'token': token,
    'request_id': qrLoginConfig['requestId'] as String,
  };

  /// 构建账号信息查询参数（用于二维码登录后获取Cookie）
  /// 用于通过service_ticket获取完整的账号信息和Cookie
  static Map<String, String> buildQRAccountInfoParams(String serviceTicket) => {
    'st': serviceTicket,
    'lw': 'scan',
  };

  /// 解析Cookie字符串为Map
  /// 将set-cookie响应头解析为键值对映射
  static Map<String, String> parseCookieString(String cookieString) {
    final cookieMap = <String, String>{};

    if (cookieString.isEmpty) {
      return cookieMap;
    }

    // 处理多个cookie（分号分隔）
    for (final cookie in cookieString.split(';')) {
      final trimmedCookie = cookie.trim();
      if (trimmedCookie.isEmpty) continue;

      final parts = trimmedCookie.split('=');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        final value = parts.sublist(1).join('=').trim();
        cookieMap[name] = value;
      }
    }

    return cookieMap;
  }

  /// 从Set-Cookie响应头列表中提取Cookie
  /// 只提取cookie的键值对部分，过滤掉Path、Expires等属性
  static String extractCookiesFromHeaders(List<String> setCookieHeaders) {
    final cookieMap = <String, String>{};

    for (final setCookie in setCookieHeaders) {
      // 只取分号前的第一部分（cookie键值对）
      final cookiePart = setCookie.split(';')[0].trim();
      if (cookiePart.isEmpty) continue;

      final parts = cookiePart.split('=');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        final value = parts.sublist(1).join('=').trim();
        cookieMap[name] = value;
      }
    }

    // 构建cookie字符串
    return cookieMap.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  /// 验证二维码登录响应状态
  /// 检查响应状态码是否表示登录成功
  static bool isQRLoginSuccess(int? statusCode) {
    return statusCode == responseStatus['qrLoginSuccess'];
  }
}
