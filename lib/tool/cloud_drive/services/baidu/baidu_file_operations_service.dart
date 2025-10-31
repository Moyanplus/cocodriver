import 'package:dio/dio.dart';

import '../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import 'baidu_base_service.dart';

/// 百度网盘文件操作服务
class BaiduFileOperationsService {
  static const String _baseUrl = 'https://pan.baidu.com/api';

  /// 删除文件
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required String fileId,
  }) async {
    try {
      final dio = BaiduBaseService.createDio(account);

      final response = await dio.post(
        '$_baseUrl/filemanager',
        data: {
          'opera': 'delete',
          'async': 1,
          'filelist': [
            {'fs_id': fileId},
          ],
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errno'] == 0) {
          _logSuccess('删除文件成功: $fileId');
          return true;
        } else {
          final errorMsg = _getErrorMessage(data['errno']);
          _logError('删除文件失败', errorMsg);
          return false;
        }
      } else {
        _logError('删除文件失败', 'HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logError('删除文件异常', e);
      return false;
    }
  }

  /// 移动文件
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required String fileId,
    required String targetFolderId,
  }) async {
    try {
      final dio = BaiduBaseService.createDio(account);

      final response = await dio.post(
        '$_baseUrl/filemanager',
        data: {
          'opera': 'move',
          'async': 1,
          'filelist': [
            {'fs_id': fileId},
          ],
          'dest': targetFolderId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errno'] == 0) {
          _logSuccess('移动文件成功: $fileId -> $targetFolderId');
          return true;
        } else {
          final errorMsg = _getErrorMessage(data['errno']);
          _logError('移动文件失败', errorMsg);
          return false;
        }
      } else {
        _logError('移动文件失败', 'HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logError('移动文件异常', e);
      return false;
    }
  }

  /// 重命名文件
  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required String fileId,
    required String newName,
  }) async {
    try {
      final dio = BaiduBaseService.createDio(account);

      final response = await dio.post(
        '$_baseUrl/filemanager',
        data: {
          'opera': 'rename',
          'async': 1,
          'filelist': [
            {'fs_id': fileId, 'newname': newName},
          ],
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errno'] == 0) {
          _logSuccess('重命名文件成功: $fileId -> $newName');
          return true;
        } else {
          final errorMsg = _getErrorMessage(data['errno']);
          _logError('重命名文件失败', errorMsg);
          return false;
        }
      } else {
        _logError('重命名文件失败', 'HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logError('重命名文件异常', e);
      return false;
    }
  }

  /// 复制文件
  static Future<bool> copyFile({
    required CloudDriveAccount account,
    required String fileId,
    required String targetFolderId,
  }) async {
    try {
      final dio = BaiduBaseService.createDio(account);

      final response = await dio.post(
        '$_baseUrl/filemanager',
        data: {
          'opera': 'copy',
          'async': 1,
          'filelist': [
            {'fs_id': fileId},
          ],
          'dest': targetFolderId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errno'] == 0) {
          _logSuccess('复制文件成功: $fileId -> $targetFolderId');
          return true;
        } else {
          final errorMsg = _getErrorMessage(data['errno']);
          _logError('复制文件失败', errorMsg);
          return false;
        }
      } else {
        _logError('复制文件失败', 'HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logError('复制文件异常', e);
      return false;
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
    LogManager().cloudDrive('百度网盘文件操作 - $message');
  }

  /// 统一错误日志记录
  static void _logError(String message, dynamic error) {
    LogManager().cloudDrive('百度网盘文件操作 - $message: $error');
  }

  /// 创建文件夹
  static Future<bool> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    try {
      final dio = BaiduBaseService.createDio(account);

      final response = await dio.post(
        '$_baseUrl/filemanager',
        data: {
          'opera': 'create',
          'async': 1,
          'filelist': [
            {'path': parentFolderId ?? '/', 'isdir': 1, 'block_list': []},
          ],
          'dest': parentFolderId ?? '/',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['errno'] == 0;
      }

      return false;
    } catch (e) {
      LogManager().error('创建文件夹失败: $e');
      return false;
    }
  }
}
