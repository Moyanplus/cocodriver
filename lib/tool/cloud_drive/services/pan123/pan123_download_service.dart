import '../../../../core/logging/log_manager.dart';
import '../../models/cloud_drive_models.dart';
import 'pan123_base_service.dart';
import 'pan123_config.dart';

/// 123云盘下载服务
class Pan123DownloadService {
  /// 统一错误处理
  static void _handleError(
    String operation,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    LogManager().cloudDrive(
      '❌ 123云盘 - $operation 失败: $error',
      
    );
    if (stackTrace != null) {
      LogManager().cloudDrive(
        '📄 错误堆栈: $stackTrace',
        
      );
    }
  }

  /// 统一日志记录
  static void _logInfo(String message, {Map<String, dynamic>? params}) {
    LogManager().cloudDrive(
      message,
      
    );
  }

  /// 统一成功日志记录
  static void _logSuccess(String message, {Map<String, dynamic>? details}) {
    LogManager().cloudDrive(
      '✅ 123云盘 - $message',
      
    );
  }

  /// 统一错误日志记录
  static void _logError(String message, dynamic error) {
    LogManager().cloudDrive(
      '❌ 123云盘 - $message: $error',
      
    );
  }

  /// 获取文件下载链接
  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required String fileId,
    required String fileName,
    int? size,
    String? s3keyFlag,
    String? etag,
  }) async {
    try {
      _logInfo(
        '🔗 123云盘 - 获取下载链接开始',
        params: {'fileId': fileId, 'fileName': fileName},
      );
      _logInfo(
        '📄 123云盘 - 文件信息: $fileName (ID: $fileId)',
        params: {'fileId': fileId, 'fileName': fileName},
      );
      _logInfo(
        '📏 123云盘 - 文件大小: ${size ?? '未知'} bytes',
        params: {'size': size},
      );

      // 创建Dio实例
      final dio = Pan123BaseService.createDio(account);

      // 构建请求参数
      final params = <String, dynamic>{'fileId': fileId, 'fileName': fileName};

      if (size != null) {
        params['size'] = size.toString();
      }
      if (s3keyFlag != null && s3keyFlag.isNotEmpty) {
        params['s3keyFlag'] = s3keyFlag;
      }
      if (etag != null && etag.isNotEmpty) {
        params['etag'] = etag;
      }

      _logInfo('📤 123云盘 - 请求参数: $params', params: {'params': params});

      // 使用配置中的API端点
      final url = Uri.parse(
        Pan123Config.getApiUrl(Pan123Config.endpoints['downloadInfo']!),
      );

      _logInfo(
        '🌐 123云盘 - 请求URL: ${url.toString()}',
        params: {'url': url.toString()},
      );

      // 发送请求
      final response = await dio.post(url.toString(), data: params);

      _logInfo(
        '📡 123云盘 - 响应状态: ${response.statusCode}',
        params: {'statusCode': response.statusCode},
      );

      final responseData = response.data as Map<String, dynamic>;

      // 处理API响应
      final processedResponse = Pan123BaseService.handleApiResponse(
        responseData,
      );

      // 提取下载链接
      final downloadUrl = processedResponse['data']['downloadUrl'] as String?;

      if (downloadUrl != null && downloadUrl.isNotEmpty) {
        final preview =
            downloadUrl.length > 100
                ? '${downloadUrl.substring(0, 100)}...'
                : downloadUrl;

        _logSuccess(
          '获取下载链接成功: $preview',
          details: {'downloadUrl': downloadUrl},
        );

        return downloadUrl;
      } else {
        _logError('响应中没有下载链接', 'downloadUrl字段为空或不存在');
        return null;
      }
    } catch (e) {
      _handleError('获取下载链接', e, null);
      return null;
    }
  }

  /// 获取高速下载链接列表
  static Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    try {
      _logInfo(
        '🚀 123云盘 - 获取高速下载链接开始',
        params: {'fileName': file.name, 'shareUrl': shareUrl},
      );

      // 123云盘暂不支持高速下载，返回null
      _logInfo('⚠️ 123云盘 - 暂不支持高速下载功能', params: {'reason': '功能未实现'});

      return null;
    } catch (e) {
      _handleError('获取高速下载链接', e, null);
      return null;
    }
  }
}
