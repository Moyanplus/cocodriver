import '../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import 'baidu_base_service.dart';

/// 百度网盘下载服务
///
/// 提供百度网盘文件下载链接获取功能。
class BaiduDownloadService {
  static const String _baseUrl = 'https://pan.baidu.com/api';

  /// 获取下载链接
  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required String fileId,
  }) async {
    try {
      final dio = BaiduBaseService.createDio(account);

      final response = await dio.post(
        '$_baseUrl/download',
        data: {
          'fidlist': [fileId],
          'dlink': 1,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errno'] == 0) {
          final dlink = data['dlink'] as String?;
          if (dlink != null && dlink.isNotEmpty) {
            _logSuccess('获取下载链接成功: $fileId');
            return dlink;
          } else {
            _logError('获取下载链接失败', '下载链接为空');
            return null;
          }
        } else {
          final errorMsg = _getErrorMessage(data['errno']);
          _logError('获取下载链接失败', errorMsg);
          return null;
        }
      } else {
        _logError('获取下载链接失败', 'HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logError('获取下载链接异常', e);
      return null;
    }
  }

  /// 创建分享链接
  static Future<String?> createShareLink({
    required CloudDriveAccount account,
    required String fileId,
    String? password,
    int expireTime = 0, // 0表示永久有效
  }) async {
    try {
      final dio = BaiduBaseService.createDio(account);

      final data = {
        'fidlist': [fileId],
        'schannel': 4,
        'channel_list': '[]',
        'period': expireTime,
      };

      if (password != null && password.isNotEmpty) {
        data['pwd'] = password;
      }

      final response = await dio.post('$_baseUrl/share/set', data: data);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['errno'] == 0) {
          final shareId = responseData['shareid'] as String?;
          if (shareId != null) {
            final shareUrl = 'https://pan.baidu.com/s/$shareId';
            _logSuccess('创建分享链接成功: $fileId -> $shareUrl');
            return shareUrl;
          } else {
            _logError('创建分享链接失败', '分享ID为空');
            return null;
          }
        } else {
          final errorMsg = _getErrorMessage(responseData['errno']);
          _logError('创建分享链接失败', errorMsg);
          return null;
        }
      } else {
        _logError('创建分享链接失败', 'HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logError('创建分享链接异常', e);
      return null;
    }
  }

  /// 获取文件详情
  static Future<Map<String, dynamic>?> getFileDetail({
    required CloudDriveAccount account,
    required String fileId,
  }) async {
    try {
      final dio = BaiduBaseService.createDio(account);

      final response = await dio.post(
        '$_baseUrl/filemetas',
        data: {
          'fidlist': [fileId],
          'dlink': 1,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errno'] == 0) {
          final list = data['list'] as List<dynamic>?;
          if (list != null && list.isNotEmpty) {
            final fileInfo = list.first as Map<String, dynamic>;
            _logSuccess('获取文件详情成功: $fileId');
            return fileInfo;
          } else {
            _logError('获取文件详情失败', '文件信息为空');
            return null;
          }
        } else {
          final errorMsg = _getErrorMessage(data['errno']);
          _logError('获取文件详情失败', errorMsg);
          return null;
        }
      } else {
        _logError('获取文件详情失败', 'HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logError('获取文件详情异常', e);
      return null;
    }
  }

  /// 获取错误消息
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
  static void _logSuccess(String message) {
    LogManager().cloudDrive('百度网盘下载 - $message');
  }

  /// 统一错误日志记录
  static void _logError(String message, dynamic error) {
    LogManager().cloudDrive('百度网盘下载 - $message: $error');
  }
}
