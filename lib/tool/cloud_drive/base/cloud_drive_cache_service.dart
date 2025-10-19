import '../../../../core/logging/log_manager.dart';
import '../models/cloud_drive_models.dart';

/// 缓存条目
class CacheEntry {
  final Map<String, List<CloudDriveFile>> data;
  final DateTime timestamp;

  CacheEntry(this.data, this.timestamp);

  bool isExpired(Duration maxAge) =>
      DateTime.now().difference(timestamp) > maxAge;
}

/// 云盘缓存服务
class CloudDriveCacheService {
  static final Map<String, Map<String, dynamic>> _cache = {};

  /// 缓存数据
  static void cacheData(String cacheKey, Map<String, dynamic> data) {
    _cache[cacheKey] = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    LogManager().cloudDrive(
      '缓存数据: $cacheKey',
      className: 'CloudDriveCacheService',
      methodName: 'cacheData',
      data: {'cacheKey': cacheKey, 'dataSize': data.length},
    );
  }

  /// 获取缓存数据
  static Map<String, dynamic>? getCachedData(String cacheKey, Duration maxAge) {
    final cached = _cache[cacheKey];
    if (cached == null) {
      LogManager().cloudDrive(
        '缓存未命中: $cacheKey',
        className: 'CloudDriveCacheService',
        methodName: 'getCachedData',
        data: {'cacheKey': cacheKey},
      );
      return null;
    }

    final timestamp = cached['timestamp'] as int;
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    final maxAgeMs = maxAge.inMilliseconds;

    if (age > maxAgeMs) {
      LogManager().cloudDrive(
        '缓存已过期: $cacheKey (${age}ms > ${maxAgeMs}ms)',
        className: 'CloudDriveCacheService',
        methodName: 'getCachedData',
        data: {'cacheKey': cacheKey, 'age': age, 'maxAge': maxAgeMs},
      );
      _cache.remove(cacheKey);
      return null;
    }

    LogManager().cloudDrive(
      '缓存命中: $cacheKey (${age}ms < ${maxAgeMs}ms)',
      className: 'CloudDriveCacheService',
      methodName: 'getCachedData',
      data: {'cacheKey': cacheKey, 'age': age, 'maxAge': maxAgeMs},
    );
    return cached['data'] as Map<String, dynamic>;
  }

  /// 清除缓存
  static void clearCache([String? cacheKey]) {
    if (cacheKey != null) {
      _cache.remove(cacheKey);
    } else {
      _cache.clear();
    }
  }

  /// 生成缓存键
  static String generateCacheKey(String accountId, List<PathInfo> folderPath) {
    final pathString = folderPath.map((path) => path.id).join('/');
    return '${accountId}_$pathString';
  }

  /// 获取缓存统计信息
  static Map<String, dynamic> getCacheStats() => {
    'totalEntries': _cache.length,
    'cacheKeys': _cache.keys.toList(),
  };
}
