/// 阿里云盘 API 配置与请求构建（精简版）
class AliConfig {
  /// 基础 URL
  static const String baseUrl = 'https://user.aliyundrive.com';
  static const String apiUrl = 'https://api.aliyundrive.com';

  /// 连接/接收超时
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// API 端点
  static const Map<String, String> apiEndpoints = {
    'getUserInfo': '/v2/user/get',
    'getQuotaInfo': '/adrive/v1/user/getUserCapacityInfo',
    'getFileList': '/adrive/v3/file/list',
    'createFolder': '/adrive/v2/file/createWithFolders',
    'moveFile': '/adrive/v4/batch',
    'deleteFile': '/adrive/v4/batch',
    'renameFile': '/v3/file/update',
    'downloadFile': '/v2/file/get_download_url',
    'getTaskStatus': '/adrive/v2/file/getLatestAsyncTask',
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

  static String getApiEndpoint(String key) => apiEndpoints[key] ?? '/';

  static Map<String, dynamic> buildUserInfoParams() => {};

  static Map<String, dynamic> buildQuotaInfoParams() => {};

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
        'video_thumbnail_process': videoThumbnailProcess ??
            'video/snapshot,t_120000,f_jpg,m_lfit,w_256,ar_auto,m_fast',
        'fields': fields,
        'order_by': orderBy,
        'order_direction': orderDirection,
        if (marker != null) 'next_marker': marker,
      };

  static Map<String, String> buildFileListQueryParams() => {
        'jsonmask':
            'next_marker,items(name,file_id,drive_id,type,size,created_at,updated_at,category,file_extension,parent_file_id,mime_type,starred,thumbnail,url,streams_info,content_hash,user_tags,user_meta,trashed,video_media_metadata,video_preview_metadata,sync_meta,sync_device_flag,sync_flag,punish_flag,from_share_id)',
      };

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

  static Map<String, dynamic> buildDownloadFileParams({
    required String driveId,
    required String fileId,
  }) => {
        'drive_id': driveId,
        'file_id': fileId,
      };

  static bool verboseLogging = true;
}
