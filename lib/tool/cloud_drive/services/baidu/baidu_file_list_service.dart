import '../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import 'baidu_base_service.dart';

/// 百度网盘文件列表服务
class BaiduFileListService {
  static const String _baseUrl = 'https://pan.baidu.com/api';

  /// 获取文件列表
  ///
  /// 获取指定文件夹下的文件和文件夹列表
  ///
  /// [account] 百度网盘账号信息
  /// [folderId] 文件夹ID（默认根目录）
  /// [page] 页码（默认1）
  /// [pageSize] 每页大小（默认50）
  /// 返回包含文件和文件夹列表的映射
  static Future<Map<String, List<CloudDriveFile>>> getFileList({
    required CloudDriveAccount account,
    String folderId = '/',
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final dio = BaiduBaseService.createDio(account);

      final response = await dio.get(
        '$_baseUrl/list',
        queryParameters: {
          'dir': folderId,
          'page': page,
          'num': pageSize,
          'order': 'time',
          'desc': 1,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errno'] == 0) {
          final list = data['list'] as List<dynamic>? ?? [];
          final files = <CloudDriveFile>[];
          final folders = <CloudDriveFile>[];

          for (final item in list) {
            final file = _parseFileItem(item);
            if (file.isDirectory) {
              folders.add(file);
            } else {
              files.add(file);
            }
          }

          _logSuccess('获取文件列表成功: ${files.length}个文件, ${folders.length}个文件夹');
          return {'files': files, 'folders': folders};
        } else {
          final errorMsg = _getErrorMessage(data['errno']);
          _logError('获取文件列表失败', errorMsg);
          throw Exception(errorMsg);
        }
      } else {
        _logError('获取文件列表失败', 'HTTP ${response.statusCode}');
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      _logError('获取文件列表异常', e);
      rethrow;
    }
  }

  /// 解析文件项
  ///
  /// 将百度网盘API返回的文件项数据解析为CloudDriveFile对象
  ///
  /// [item] 文件项数据
  /// 返回解析后的文件对象
  static CloudDriveFile _parseFileItem(Map<String, dynamic> item) {
    final isDirectory = item['isdir'] == 1;
    final size = isDirectory ? 0 : (item['size'] as int? ?? 0);
    final serverTime = item['server_time'] as int? ?? 0;

    return CloudDriveFile(
      id: item['fs_id'].toString(),
      name: item['server_filename'] ?? '',
      isFolder: isDirectory,
      size: size,
      modifiedTime: DateTime.fromMillisecondsSinceEpoch(serverTime * 1000),
      folderId: item['parent_path']?.toString(),
      downloadUrl: isDirectory ? null : item['download_url'],
      thumbnailUrl: item['thumbs']?['url1'],
      metadata: {'path': item['path'] ?? '', 'md5': item['md5']},
      category: _getFileCategory(item['server_filename'] ?? ''),
    );
  }

  /// 获取文件分类
  ///
  /// 根据文件扩展名确定文件分类
  ///
  /// [fileName] 文件名
  /// 返回文件分类
  static FileCategory _getFileCategory(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return FileCategory.image;
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
      case 'wmv':
      case 'flv':
        return FileCategory.video;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
      case 'ogg':
        return FileCategory.audio;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'xls':
      case 'xlsx':
      case 'ppt':
      case 'pptx':
      case 'txt':
        return FileCategory.document;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return FileCategory.archive;
      default:
        return FileCategory.other;
    }
  }

  /// 格式化时间戳
  ///
  /// 将时间戳格式化为相对时间描述
  ///
  /// [timestamp] 时间戳（秒）
  /// 返回格式化的时间字符串
  static String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 格式化文件大小
  ///
  /// 将字节数格式化为可读的文件大小字符串
  ///
  /// [bytes] 字节数
  /// 返回格式化的文件大小字符串
  static String _formatFileSize(int bytes) {
    if (bytes == 0) return '0B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 1)}${units[unitIndex]}';
  }

  /// 获取错误消息
  ///
  /// 根据错误码获取对应的错误消息
  ///
  /// [errno] 错误码
  /// 返回错误消息字符串
  static String _getErrorMessage(int errno) {
    switch (errno) {
      case 0:
        return '成功';
      case -1:
        return '系统错误';
      case -2:
        return '参数错误';
      case -3:
        return '网络错误';
      case -4:
        return '权限不足';
      case -5:
        return '文件不存在';
      case -6:
        return '文件已存在';
      case -7:
        return '存储空间不足';
      case -8:
        return '操作失败';
      case -9:
        return '登录已过期';
      default:
        return '未知错误($errno)';
    }
  }

  /// 统一成功日志记录
  ///
  /// 记录成功操作的日志信息
  ///
  /// [message] 日志消息
  static void _logSuccess(String message) {
    LogManager().cloudDrive('✅ 百度网盘文件列表 - $message');
  }

  /// 统一错误日志记录
  ///
  /// 记录错误操作的日志信息
  ///
  /// [message] 日志消息
  /// [error] 错误信息
  static void _logError(String message, dynamic error) {
    LogManager().cloudDrive('❌ 百度网盘文件列表 - $message: $error');
  }
}
