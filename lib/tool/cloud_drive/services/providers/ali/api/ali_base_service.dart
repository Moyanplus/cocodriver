import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../../../core/logging/log_manager.dart';
import '../../../../data/models/cloud_drive_entities.dart';
import '../../../base/cloud_drive_api_logger.dart';
import 'ali_config.dart';

/// 阿里云盘基础服务
///
/// 提供通用的 Dio 配置和响应处理功能。
abstract class AliBaseService {
  /// 创建配置好的 Dio 实例
  ///
  /// [account] 阿里云盘账号信息
  static Dio createDio(CloudDriveAccount account) {
    // 记录云盘服务初始化日志
    LogManager().cloudDrive(
      '创建阿里云盘Dio实例',
      className: 'AliBaseService',
      methodName: 'createDio',
      data: {
        'accountId': account.id,
        'accountName': account.name,
        'baseUrl': AliConfig.baseUrl,
      },
    );

    final dio = Dio(
      BaseOptions(
        baseUrl: AliConfig.baseUrl,
        connectTimeout: AliConfig.connectTimeout,
        receiveTimeout: AliConfig.receiveTimeout,
        headers: _buildHeaders(account),
      ),
    );

    _addInterceptors(dio, providerLabel: '阿里云盘');
    return dio;
  }

  /// 创建用于API调用的Dio实例
  ///
  /// 创建使用api.aliyundrive.com的Dio实例，用于API调用
  ///
  /// [account] 阿里云盘账号信息
  /// 返回配置好的API Dio实例
  static Dio createApiDio(CloudDriveAccount account) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AliConfig.apiUrl,
        connectTimeout: AliConfig.connectTimeout,
        receiveTimeout: AliConfig.receiveTimeout,
        headers: _buildHeaders(account),
      ),
    );

    _addInterceptors(dio, providerLabel: '阿里云盘API');
    return dio;
  }

  /// 构建请求头
  ///
  /// 为阿里云盘账号构建HTTP请求头
  ///
  /// [account] 阿里云盘账号信息
  /// 返回请求头映射
  static Map<String, String> _buildHeaders(CloudDriveAccount account) {
    final headers = Map<String, String>.from(AliConfig.defaultHeaders);

    final authValue = account.primaryAuthValue;
    if (authValue != null && authValue.isNotEmpty) {
      if (account.authType == AuthType.cookie) {
        headers['Cookie'] = authValue;
      } else {
        headers['Authorization'] = 'Bearer $authValue';
      }
    }

    // 尝试补充 userId，用于部分接口要求的 x-forwarded-user-id
    final userId = parseUserIdFromToken(account.authValue) ?? account.driveId;
    if (userId != null && userId.isNotEmpty) {
      headers['x-forwarded-user-id'] = userId;
    }

    return headers;
  }

  /// 解析 Authorization Bearer token，获取 userId。
  static String? parseUserIdFromToken(String? token) {
    if (token == null || token.isEmpty || !token.contains('.')) return null;
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final jsonStr = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return map['userId']?.toString();
    } catch (_) {
      return null;
    }
  }

  /// 添加拦截器
  ///
  /// 为Dio实例添加请求、响应和错误拦截器
  ///
  /// [dio] Dio实例
  static void _addInterceptors(
    Dio dio, {
    String providerLabel = '阿里云盘',
  }) {
    dio.interceptors.add(
      CloudDriveLoggingInterceptor(
        logger: CloudDriveApiLogger(
          provider: providerLabel,
          verbose: AliConfig.verboseLogging,
        ),
      ),
    );
  }

  /// 检查HTTP响应是否成功
  ///
  /// 检查HTTP状态码是否表示成功
  ///
  /// [statusCode] HTTP状态码
  /// 返回是否成功
  static bool isHttpSuccess(int? statusCode) =>
      statusCode != null && statusCode >= 200 && statusCode < 300;

  /// 检查API响应是否成功
  static bool isApiSuccess(Map<String, dynamic> response) {
    if (response.containsKey('success')) {
      return response['success'] == true;
    }
    final code = response['code']?.toString();
    return code == null || code.isEmpty || code.toLowerCase() == 'success';
  }

  /// 获取响应数据
  ///
  /// 从API响应中提取数据部分
  ///
  /// [response] API响应数据
  /// 返回响应数据
  static dynamic getResponseData(Map<String, dynamic> response) => response;

  /// 获取错误信息
  static String getErrorMessage(Map<String, dynamic> response) {
    return response['message']?.toString() ??
        response['code']?.toString() ??
        'unknown error';
  }

  /// 解析文件条目为 CloudDriveFile。
  static CloudDriveFile? parseFileItem(Map<String, dynamic> data) {
    try {
      final fileId = data['file_id']?.toString();
      // create 接口返回字段为 file_name，这里兼容两种字段名称
      final name = data['name']?.toString() ?? data['file_name']?.toString();
      if (fileId == null || name == null) {
        return null;
      }

      final type = data['type']?.toString() ?? 'file';
      final isFolder = type == 'folder';
      final size =
          data['size'] is int
              ? data['size'] as int
              : int.tryParse('${data['size'] ?? ''}');
      final updatedAtRaw = data['updated_at']?.toString();
      DateTime? updatedAt;
      if (updatedAtRaw != null) {
        updatedAt = DateTime.tryParse(updatedAtRaw);
      }
      final createdAtRaw = data['created_at']?.toString();
      DateTime? createdAt;
      if (createdAtRaw != null) {
        createdAt = DateTime.tryParse(createdAtRaw);
      }
      final parentId = data['parent_file_id']?.toString();

      final thumbnail = data['thumbnail']?.toString();
      final url = data['url']?.toString();
      final mimeType =
          data['mime_type']?.toString() ?? data['content_type']?.toString();
      final category = data['category']?.toString();

      // 部分接口只返回 modified_at，这里用作 updatedAt 的回退。
      final modifiedAtRaw = data['modified_at']?.toString();
      if (updatedAt == null && modifiedAtRaw != null) {
        updatedAt = DateTime.tryParse(modifiedAtRaw);
      }

      return CloudDriveFile(
        id: fileId,
        name: name,
        size: size,
        updatedAt: updatedAt,
        createdAt: createdAt,
        isFolder: isFolder,
        folderId: parentId,
        thumbnailUrl: thumbnail,
        bigThumbnailUrl: thumbnail,
        downloadUrl: url,
        previewUrl: url,
        metadata: {
          'driveId': data['drive_id'],
          'category': category,
          'mimeType': mimeType,
          'contentType': data['content_type'],
          'fileExtension': data['file_extension'],
          'starred': data['starred'],
          'contentHash': data['content_hash'],
          'crc64Hash': data['crc64_hash'],
          'uploadId': data['upload_id'],
          'revisionId': data['revision_id'],
          'contentUri': data['content_uri'],
          'location': data['location'],
          'localModifiedAt': data['local_modified_at'],
          'status': data['status'],
          'userTags': data['user_tags'],
          'userMeta': data['user_meta'],
          'videoMediaMetadata': data['video_media_metadata'],
          'videoPreviewMetadata': data['video_preview_metadata'],
        },
      );
    } catch (_) {
      return null;
    }
  }
}
