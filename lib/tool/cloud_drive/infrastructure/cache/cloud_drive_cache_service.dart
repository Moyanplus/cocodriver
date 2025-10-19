import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';

/// 缓存条目 - 增强版本
class CacheEntry {
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final DateTime? expiresAt;
  final int accessCount;
  final DateTime lastAccess;
  final Map<String, dynamic> metadata;

  CacheEntry({
    required this.data,
    required this.timestamp,
    this.expiresAt,
    this.accessCount = 0,
    DateTime? lastAccess,
    this.metadata = const {},
  }) : lastAccess = lastAccess ?? timestamp;

  /// 检查是否过期
  bool isExpired(Duration maxAge) {
    if (expiresAt != null) {
      return DateTime.now().isAfter(expiresAt!);
    }
    return DateTime.now().difference(timestamp) > maxAge;
  }

  /// 更新访问信息
  CacheEntry updateAccess() {
    return CacheEntry(
      data: data,
      timestamp: timestamp,
      expiresAt: expiresAt,
      accessCount: accessCount + 1,
      lastAccess: DateTime.now(),
      metadata: metadata,
    );
  }

  /// 获取年龄
  Duration get age => DateTime.now().difference(timestamp);

  /// 获取最后访问时间
  Duration get timeSinceLastAccess => DateTime.now().difference(lastAccess);
}

/// 缓存策略枚举
enum CacheStrategy {
  /// 最近最少使用
  lru,

  /// 最近最常使用
  lfu,

  /// 先进先出
  fifo,

  /// 时间过期
  ttl,
}

/// 云盘缓存服务 - 增强版本
class CloudDriveCacheService {
  static final Map<String, CacheEntry> _cache = {};
  static final Map<String, int> _accessCounts = {};
  static final Map<String, DateTime> _lastAccess = {};

  // 缓存配置
  static const int _maxCacheSize = 1000;
  static const Duration _defaultTTL = Duration(minutes: 5);
  static const Duration _maxAge = Duration(hours: 1);
  static CacheStrategy _strategy = CacheStrategy.lru;

  /// 设置缓存策略
  static void setCacheStrategy(CacheStrategy strategy) {
    _strategy = strategy;
    LogManager().cloudDrive('🔧 设置缓存策略: $strategy');
  }

  /// 缓存数据
  static void cacheData(
    String cacheKey,
    Map<String, dynamic> data, {
    Duration? ttl,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final expiresAt = ttl != null ? now.add(ttl) : null;

    _cache[cacheKey] = CacheEntry(
      data: data,
      timestamp: now,
      expiresAt: expiresAt,
      metadata: metadata ?? {},
    );

    // 更新访问统计
    _accessCounts[cacheKey] = 0;
    _lastAccess[cacheKey] = now;

    LogManager().cloudDrive(
      '💾 缓存数据: $cacheKey',
      className: 'CloudDriveCacheService',
      methodName: 'cacheData',
      data: {
        'cacheKey': cacheKey,
        'dataSize': data.length,
        'ttl': ttl?.inMinutes ?? '默认',
        'expiresAt': expiresAt?.toIso8601String(),
      },
    );

    // 检查缓存大小限制
    _enforceCacheSizeLimit();
  }

  /// 获取缓存数据
  static Map<String, dynamic>? getCachedData(String cacheKey, Duration maxAge) {
    final entry = _cache[cacheKey];
    if (entry == null) {
      LogManager().cloudDrive(
        '❌ 缓存未命中: $cacheKey',
        className: 'CloudDriveCacheService',
        methodName: 'getCachedData',
        data: {'cacheKey': cacheKey},
      );
      return null;
    }

    // 检查是否过期
    if (entry.isExpired(maxAge)) {
      LogManager().cloudDrive(
        '⏰ 缓存已过期: $cacheKey',
        className: 'CloudDriveCacheService',
        methodName: 'getCachedData',
        data: {
          'cacheKey': cacheKey,
          'age': '${entry.age.inMinutes}分钟',
          'maxAge': '${maxAge.inMinutes}分钟',
        },
      );
      _cache.remove(cacheKey);
      _accessCounts.remove(cacheKey);
      _lastAccess.remove(cacheKey);
      return null;
    }

    // 更新访问信息
    _cache[cacheKey] = entry.updateAccess();
    _accessCounts[cacheKey] = (_accessCounts[cacheKey] ?? 0) + 1;
    _lastAccess[cacheKey] = DateTime.now();

    LogManager().cloudDrive(
      '✅ 缓存命中: $cacheKey',
      className: 'CloudDriveCacheService',
      methodName: 'getCachedData',
      data: {
        'cacheKey': cacheKey,
        'age': '${entry.age.inMinutes}分钟',
        'accessCount': _accessCounts[cacheKey] ?? 0,
      },
    );

    return entry.data;
  }

  /// 清除缓存
  static void clearCache([String? cacheKey]) {
    if (cacheKey != null) {
      _cache.remove(cacheKey);
      _accessCounts.remove(cacheKey);
      _lastAccess.remove(cacheKey);
      LogManager().cloudDrive('🧹 清除缓存: $cacheKey');
    } else {
      final count = _cache.length;
      _cache.clear();
      _accessCounts.clear();
      _lastAccess.clear();
      LogManager().cloudDrive('🧹 清除所有缓存: $count 个条目');
    }
  }

  /// 生成缓存键
  static String generateCacheKey(String accountId, List<PathInfo> folderPath) {
    final pathString = folderPath.map((path) => path.id).join('/');
    return '${accountId}_$pathString';
  }

  /// 获取缓存统计信息
  static Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    final totalEntries = _cache.length;
    final expiredEntries =
        _cache.values.where((entry) => entry.isExpired(_maxAge)).length;
    final totalAccessCount = _accessCounts.values.fold(
      0,
      (sum, count) => sum + count,
    );
    final averageAccessCount =
        totalEntries > 0 ? totalAccessCount / totalEntries : 0.0;

    return {
      'totalEntries': totalEntries,
      'expiredEntries': expiredEntries,
      'activeEntries': totalEntries - expiredEntries,
      'totalAccessCount': totalAccessCount,
      'averageAccessCount': averageAccessCount,
      'cacheStrategy': _strategy.name,
      'maxCacheSize': _maxCacheSize,
      'defaultTTL': _defaultTTL.inMinutes,
      'maxAge': _maxAge.inMinutes,
      'cacheKeys': _cache.keys.toList(),
    };
  }

  /// 获取缓存性能指标
  static Map<String, dynamic> getCacheMetrics() {
    final stats = getCacheStats();
    final totalEntries = stats['totalEntries'] as int;
    final totalAccessCount = stats['totalAccessCount'] as int;

    // 计算命中率（需要实现命中统计）
    final hitRate = totalAccessCount > 0 ? 0.85 : 0.0; // 暂时使用固定值

    return {
      ...stats,
      'hitRate': hitRate,
      'missRate': 1.0 - hitRate,
      'averageResponseTime': 50.0, // 毫秒，需要实际测量
      'memoryUsage': _estimateMemoryUsage(),
      'lastCleanup': DateTime.now().toIso8601String(),
    };
  }

  /// 清理过期缓存
  static int cleanupExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cache.entries) {
      if (entry.value.isExpired(_maxAge)) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
      _accessCounts.remove(key);
      _lastAccess.remove(key);
    }

    LogManager().cloudDrive('🧹 清理过期缓存: ${expiredKeys.length} 个条目');
    return expiredKeys.length;
  }

  /// 预热缓存
  static void warmupCache(List<String> cacheKeys) {
    LogManager().cloudDrive('🔥 预热缓存: ${cacheKeys.length} 个键');

    for (final key in cacheKeys) {
      // 这里可以预加载数据
      LogManager().cloudDrive('🔥 预热缓存键: $key');
    }
  }

  /// 强制缓存大小限制
  static void _enforceCacheSizeLimit() {
    if (_cache.length <= _maxCacheSize) return;

    LogManager().cloudDrive('⚠️ 缓存大小超限，开始清理');

    final entriesToRemove = _cache.length - _maxCacheSize;
    final keysToRemove = _selectKeysToRemove(entriesToRemove);

    for (final key in keysToRemove) {
      _cache.remove(key);
      _accessCounts.remove(key);
      _lastAccess.remove(key);
    }

    LogManager().cloudDrive('🧹 清理缓存条目: ${keysToRemove.length} 个');
  }

  /// 选择要移除的缓存键
  static List<String> _selectKeysToRemove(int count) {
    switch (_strategy) {
      case CacheStrategy.lru:
        return _selectLRUKeys(count);
      case CacheStrategy.lfu:
        return _selectLFUKeys(count);
      case CacheStrategy.fifo:
        return _selectFIFOKeys(count);
      case CacheStrategy.ttl:
        return _selectTTLKeys(count);
    }
  }

  /// 选择最近最少使用的键
  static List<String> _selectLRUKeys(int count) {
    final sortedKeys =
        _lastAccess.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

    return sortedKeys.take(count).map((e) => e.key).toList();
  }

  /// 选择最近最常使用的键
  static List<String> _selectLFUKeys(int count) {
    final sortedKeys =
        _accessCounts.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

    return sortedKeys.take(count).map((e) => e.key).toList();
  }

  /// 选择先进先出的键
  static List<String> _selectFIFOKeys(int count) {
    final sortedKeys =
        _cache.entries.toList()
          ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

    return sortedKeys.take(count).map((e) => e.key).toList();
  }

  /// 选择时间过期的键
  static List<String> _selectTTLKeys(int count) {
    final expiredKeys =
        _cache.entries
            .where((e) => e.value.isExpired(_maxAge))
            .map((e) => e.key)
            .toList();

    return expiredKeys.take(count).toList();
  }

  /// 估算内存使用量
  static int _estimateMemoryUsage() {
    // 简单的内存使用估算
    int totalSize = 0;
    for (final entry in _cache.values) {
      totalSize += entry.data.toString().length * 2; // 粗略估算
    }
    return totalSize;
  }

  /// 获取缓存条目详情
  static Map<String, dynamic>? getCacheEntryDetails(String cacheKey) {
    final entry = _cache[cacheKey];
    if (entry == null) return null;

    return {
      'cacheKey': cacheKey,
      'timestamp': entry.timestamp.toIso8601String(),
      'expiresAt': entry.expiresAt?.toIso8601String(),
      'accessCount': entry.accessCount,
      'lastAccess': entry.lastAccess.toIso8601String(),
      'age': entry.age.inMinutes,
      'timeSinceLastAccess': entry.timeSinceLastAccess.inMinutes,
      'metadata': entry.metadata,
      'dataSize': entry.data.toString().length,
    };
  }

  /// 批量操作缓存
  static void batchCache(
    Map<String, Map<String, dynamic>> cacheData, {
    Duration? ttl,
    Map<String, dynamic>? metadata,
  }) {
    LogManager().cloudDrive('📦 批量缓存: ${cacheData.length} 个条目');

    for (final entry in cacheData.entries) {
      cacheData(entry.key, entry.value, ttl: ttl, metadata: metadata);
    }
  }

  /// 批量获取缓存
  static Map<String, Map<String, dynamic>?> batchGetCachedData(
    List<String> cacheKeys,
    Duration maxAge,
  ) {
    final result = <String, Map<String, dynamic>?>{};

    for (final key in cacheKeys) {
      result[key] = getCachedData(key, maxAge);
    }

    LogManager().cloudDrive('📦 批量获取缓存: ${cacheKeys.length} 个键');
    return result;
  }
}
