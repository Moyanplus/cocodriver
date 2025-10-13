import 'package:dio/dio.dart';

import '../../error/exceptions.dart';
import '../../error/failures.dart';
import '../../error/error_handler.dart';
import '../data_sources/local/local_data_source.dart';
import '../data_sources/remote/remote_data_source.dart';

/// 仓库基类
/// 提供通用的数据访问和错误处理逻辑
abstract class BaseRepository {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;
  final ErrorHandler _errorHandler = ErrorHandler();

  BaseRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  /// 处理网络请求
  Future<T> handleNetworkRequest<T>(
    Future<T> Function() request, {
    T? fallbackValue,
    bool useCache = false,
    String? cacheKey,
    Duration? cacheTtl,
  }) async {
    try {
      final result = await request();

      // 如果需要缓存，保存到本地
      if (useCache && cacheKey != null && result != null) {
        await _saveToCache(cacheKey, result, cacheTtl);
      }

      return result;
    } catch (e) {
      // 如果是网络错误且启用了缓存，尝试从缓存获取
      if (useCache && cacheKey != null && _isNetworkError(e)) {
        final cachedData = await _getFromCache<T>(cacheKey);
        if (cachedData != null) {
          return cachedData;
        }
      }

      // 如果有fallback值，返回fallback值
      if (fallbackValue != null) {
        return fallbackValue;
      }

      // 否则重新抛出异常
      rethrow;
    }
  }

  /// 处理本地数据操作
  Future<T> handleLocalOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      throw _errorHandler.handleException(e);
    }
  }

  /// 保存数据到缓存
  Future<void> _saveToCache<T>(String key, T data, Duration? ttl) async {
    try {
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'ttl': ttl?.inMilliseconds,
      };
      await localDataSource.save(key, cacheData);
    } catch (e) {
      // 缓存失败不应该影响主流程
      print('Failed to save to cache: $e');
    }
  }

  /// 从缓存获取数据
  Future<T?> _getFromCache<T>(String key) async {
    try {
      final cacheData = await localDataSource.get<Map<String, dynamic>>(key);
      if (cacheData == null) return null;

      final timestamp = cacheData['timestamp'] as int?;
      final ttl = cacheData['ttl'] as int?;

      if (timestamp != null && ttl != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - timestamp > ttl) {
          // 缓存过期，删除
          await localDataSource.delete(key);
          return null;
        }
      }

      return cacheData['data'] as T?;
    } catch (e) {
      // 缓存读取失败不应该影响主流程
      print('Failed to get from cache: $e');
      return null;
    }
  }

  /// 检查是否为网络错误
  bool _isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError;
    }
    return false;
  }

  /// 清理过期缓存
  Future<void> cleanExpiredCache() async {
    try {
      // 这里可以实现清理过期缓存的逻辑
      // 比如遍历所有缓存键，检查是否过期
    } catch (e) {
      print('Failed to clean expired cache: $e');
    }
  }
}

/// 用户仓库
class UserRepository extends BaseRepository {
  UserRepository({
    required super.localDataSource,
    required super.remoteDataSource,
  });

  /// 获取用户设置
  Future<Map<String, dynamic>> getUserSettings({bool useCache = true}) async {
    const cacheKey = 'user_settings';
    const cacheTtl = Duration(hours: 1);

    return await handleNetworkRequest(
      () async {
        final response = await (remoteDataSource as dynamic).getUserSettings();
        return response;
      },
      useCache: useCache,
      cacheKey: cacheKey,
      cacheTtl: cacheTtl,
      fallbackValue: await _getDefaultUserSettings(),
    );
  }

  /// 更新用户设置
  Future<Map<String, dynamic>> updateUserSettings(
    Map<String, dynamic> settings,
  ) async {
    return await handleNetworkRequest(() async {
      final response = await (remoteDataSource as dynamic).updateUserSettings(
        settings,
      );

      // 更新成功后，清除相关缓存
      await localDataSource.delete('user_settings');

      return response;
    });
  }

  /// 获取用户统计信息
  Future<Map<String, dynamic>> getUserStatistics({bool useCache = true}) async {
    const cacheKey = 'user_statistics';
    const cacheTtl = Duration(minutes: 30);

    return await handleNetworkRequest(
      () async {
        final response =
            await (remoteDataSource as dynamic).getUserStatistics();
        return response;
      },
      useCache: useCache,
      cacheKey: cacheKey,
      cacheTtl: cacheTtl,
      fallbackValue: await _getDefaultUserStatistics(),
    );
  }

  /// 获取默认用户设置
  Future<Map<String, dynamic>> _getDefaultUserSettings() async {
    return await handleLocalOperation(() async {
      return {
        'language': 'zh',
        'theme': 'system',
        'notifications': true,
        'darkMode': false,
        'autoUpdate': true,
      };
    });
  }

  /// 获取默认用户统计信息
  Future<Map<String, dynamic>> _getDefaultUserStatistics() async {
    return await handleLocalOperation(() async {
      return {
        'totalSessions': 0,
        'totalTime': 0,
        'totalActions': 0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    });
  }
}

/// 系统仓库
class SystemRepository extends BaseRepository {
  SystemRepository({
    required super.localDataSource,
    required super.remoteDataSource,
  });

  /// 获取系统信息
  Future<Map<String, dynamic>> getSystemInfo({bool useCache = true}) async {
    const cacheKey = 'system_info';
    const cacheTtl = Duration(hours: 24);

    return await handleNetworkRequest(
      () async {
        final response = await (remoteDataSource as dynamic).getSystemInfo();
        return response;
      },
      useCache: useCache,
      cacheKey: cacheKey,
      cacheTtl: cacheTtl,
      fallbackValue: await _getDefaultSystemInfo(),
    );
  }

  /// 获取应用版本信息
  Future<Map<String, dynamic>> getAppVersion({bool useCache = true}) async {
    const cacheKey = 'app_version';
    const cacheTtl = Duration(hours: 12);

    return await handleNetworkRequest(
      () async {
        final response = await (remoteDataSource as dynamic).getAppVersion();
        return response;
      },
      useCache: useCache,
      cacheKey: cacheKey,
      cacheTtl: cacheTtl,
      fallbackValue: await _getDefaultAppVersion(),
    );
  }

  /// 获取默认系统信息
  Future<Map<String, dynamic>> _getDefaultSystemInfo() async {
    return await handleLocalOperation(() async {
      return {
        'name': 'Flutter UI Template',
        'version': '1.0.0',
        'environment': 'production',
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    });
  }

  /// 获取默认应用版本信息
  Future<Map<String, dynamic>> _getDefaultAppVersion() async {
    return await handleLocalOperation(() async {
      return {
        'currentVersion': '1.0.0',
        'latestVersion': '1.0.0',
        'hasUpdate': false,
        'updateUrl': null,
        'releaseNotes': null,
      };
    });
  }
}

/// 反馈仓库
class FeedbackRepository extends BaseRepository {
  FeedbackRepository({
    required super.localDataSource,
    required super.remoteDataSource,
  });

  /// 提交反馈
  Future<Map<String, dynamic>> submitFeedback(
    Map<String, dynamic> feedback,
  ) async {
    return await handleNetworkRequest(() async {
      final response = await (remoteDataSource as dynamic).submitFeedback(
        feedback,
      );
      return response;
    });
  }

  /// 报告Bug
  Future<Map<String, dynamic>> reportBug(Map<String, dynamic> bugReport) async {
    return await handleNetworkRequest(() async {
      final response = await (remoteDataSource as dynamic).reportBug(bugReport);
      return response;
    });
  }

  /// 请求新功能
  Future<Map<String, dynamic>> requestFeature(
    Map<String, dynamic> featureRequest,
  ) async {
    return await handleNetworkRequest(() async {
      final response = await (remoteDataSource as dynamic).requestFeature(
        featureRequest,
      );
      return response;
    });
  }
}
