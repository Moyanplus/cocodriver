import '../../../../../core/logging/log_manager.dart';

/// 阿里云盘配置
class AliConfig {
  /// 基础URL
  static const String baseUrl = 'https://user.aliyundrive.com';
  static const String apiUrl = 'https://api.aliyundrive.com';

  /// 连接超时时间
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// 日志子分类
  static const String logSubCategory = 'cloudDrive.ali';

  /// API端点映射
  static const Map<String, String> apiEndpoints = {
    'getUserInfo': '/v2/user/get',
    'getQuotaInfo': '/adrive/v1/user/getUserCapacityInfo', // 更新为正确的容量API端点
    'getFileList': '/adrive/v3/file/list',
    'createFolder': '/adrive/v2/file/createWithFolders',
    'moveFile': '/adrive/v4/batch', // 批量移动文件API
    'deleteFile': '/adrive/v4/batch', // 批量删除文件API
    'renameFile': '/v3/file/update', // 重命名文件API
    'downloadFile': '/v2/file/get_download_url', // 获取下载链接API
    'getTaskStatus': '/adrive/v2/file/getLatestAsyncTask', // 查询任务状态API
  };

  /// 默认请求头
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    'Cache-Control': 'no-cache',
    'Pragma': 'no-cache',
  };

  /// 获取API端点
  static String getApiEndpoint(String key) => apiEndpoints[key] ?? '/';

  /// 构建用户信息请求参数
  static Map<String, dynamic> buildUserInfoParams() => {};

  /// 构建容量信息请求参数
  static Map<String, dynamic> buildQuotaInfoParams() {
    return {}; // 容量API需要空的请求体
  }

  /// 构建文件列表请求参数
  static Map<String, dynamic> buildFileListParams({
    required String driveId,
    String? parentFileId,
    int limit = 20,
    String? marker,
    String orderBy = 'updated_at',
    String orderDirection = 'DESC',
    bool all = false,
    int urlExpireSec = 14400,
    String? imageThumbnailProcess,
    String? imageUrlProcess,
    String? videoThumbnailProcess,
    String fields = '*',
  }) => {
    'drive_id': driveId,
    'parent_file_id': parentFileId ?? 'root',
    'limit': limit,
    'all': all,
    'url_expire_sec': urlExpireSec,
    'image_thumbnail_process':
        imageThumbnailProcess ?? 'image/resize,w_256/format,avif',
    'image_url_process': imageUrlProcess ?? 'image/resize,w_1920/format,avif',
    'video_thumbnail_process':
        videoThumbnailProcess ??
        'video/snapshot,t_120000,f_jpg,m_lfit,w_256,ar_auto,m_fast',
    'fields': fields,
    'order_by': orderBy,
    'order_direction': orderDirection,
    if (marker != null) 'next_marker': marker,
  };

  /// 构建文件列表URL查询参数 (jsonmask)
  static Map<String, String> buildFileListQueryParams() => {
    'jsonmask':
        'next_marker,items(name,file_id,drive_id,type,size,created_at,updated_at,category,file_extension,parent_file_id,mime_type,starred,thumbnail,url,streams_info,content_hash,user_tags,user_meta,trashed,video_media_metadata,video_preview_metadata,sync_meta,sync_device_flag,sync_flag,punish_flag,from_share_id)',
  };

  /// 构建创建文件夹请求参数
  static Map<String, dynamic> buildCreateFolderParams({
    required String name,
    String? parentFileId,
    required String driveId,
  }) => {
    'drive_id': driveId,
    'parent_file_id': parentFileId ?? 'root',
    'name': name,
    'type': 'folder',
    'check_name_mode': 'refuse',
  };

  /// 构建重命名文件请求参数
  static Map<String, dynamic> buildRenameFileParams({
    required String driveId,
    required String fileId,
    required String newName,
    String checkNameMode = 'refuse',
  }) => {
    'drive_id': driveId,
    'file_id': fileId,
    'name': newName,
    'check_name_mode': checkNameMode,
  };

  /// 构建移动文件请求参数（批量API格式）
  static Map<String, dynamic> buildMoveFileParams({
    required String driveId,
    required String fileId,
    required String fileName,
    required String fileType,
    required String toParentFileId,
  }) => {
    'requests': [
      {
        'body': {
          'drive_id': driveId,
          'file_id': fileId,
          'file_name': fileName,
          'type': fileType,
          'to_drive_id': driveId,
          'to_parent_file_id': toParentFileId,
        },
        'headers': {'Content-Type': 'application/json'},
        'id': fileId,
        'method': 'POST',
        'url': '/file/move',
      },
    ],
    'resource': 'file',
  };

  /// 构建删除文件请求参数（批量API格式）
  static Map<String, dynamic> buildDeleteFileParams({
    required String driveId,
    required String fileId,
  }) => {
    'requests': [
      {
        'body': {'drive_id': driveId, 'file_id': fileId},
        'headers': {'Content-Type': 'application/json'},
        'id': fileId,
        'method': 'POST',
        'url': '/recyclebin/trash',
      },
    ],
    'resource': 'file',
  };

  /// 构建下载文件请求参数
  static Map<String, dynamic> buildDownloadFileParams({
    required String driveId,
    required String fileId,
  }) => {'drive_id': driveId, 'file_id': fileId};

  /// 支持的操作状态
  static Map<String, bool> getSupportedOperationsStatus() => {
    'getFileList': true, // ✅ 已实现
    'getAccountDetails': true, // ✅ 已实现
    'createFolder': true, // ✅ 已实现
    'rename': true, // ✅ 已实现
    'move': true, // ✅ 已实现 - 使用批量API
    'copy': false, // ❌ 阿里云盘暂不支持复制
    'delete': true, // ✅ 已实现 - 使用批量API
    'download': true, // ✅ 已实现
    'upload': false, // 🔄 待实现
    'share': false, // 🔄 待实现
  };

  /// 响应状态映射
  static const Map<String, String> responseStatus = {
    'success': '成功',
    'error': '错误',
    'unauthorized': '未授权',
    'forbidden': '禁止访问',
    'not_found': '未找到',
    'rate_limit': '请求频率限制',
  };

  /// VIP身份映射
  static const Map<String, String> vipIdentityMapping = {
    'member': '普通会员',
    'vip': 'VIP会员',
    'svip': '超级VIP',
  };

  /// 格式化时间戳
  static String formatTimestamp(int timestamp) {
    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      LogManager().cloudDrive('⚠️ 时间戳格式化失败: $e');
      return '未知时间';
    }
  }

  /// 格式化文件大小
  static String formatFileSize(int? bytes) {
    if (bytes == null || bytes == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${suffixes[i]}';
  }

  /// 验证响应是否成功
  static bool isResponseSuccess(Map<String, dynamic> response) {
    // 阿里云盘没有统一的错误码字段，通常成功的响应会包含预期的数据字段
    return response.isNotEmpty &&
        !response.containsKey('code') &&
        !response.containsKey('error');
  }

  /// 获取错误信息
  static String getErrorMessage(Map<String, dynamic> response) {
    if (response.containsKey('message')) {
      return response['message'].toString();
    }
    if (response.containsKey('error')) {
      return response['error'].toString();
    }
    if (response.containsKey('error_message')) {
      return response['error_message'].toString();
    }
    return '未知错误';
  }
}
