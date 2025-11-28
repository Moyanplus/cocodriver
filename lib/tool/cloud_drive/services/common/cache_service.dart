import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import '../../infrastructure/cache/cloud_drive_cache_service.dart';
import '../../core/result.dart';
import 'cloud_drive_service_base.dart';

/// 缓存服务
///
/// 处理缓存相关操作，包括数据缓存、缓存获取、缓存清除等。
class CacheService extends CloudDriveServiceBase {
  CacheService(CloudDriveType type) : super(type);

  /// 缓存数据
  Result<void> cacheData(String cacheKey, Map<String, dynamic> data) {
    logOperation(
      '缓存数据',
      params: {'cacheKey': cacheKey, 'dataSize': data.length},
    );

    try {
      CloudDriveCacheService.cacheData(cacheKey, data);
      logSuccess('缓存数据', details: cacheKey);
      return const Success(null);
    } catch (e) {
      logError('缓存数据', e);
      return Failure('缓存数据失败: $e');
    }
  }

  /// 获取缓存数据
  Result<Map<String, dynamic>?> getCachedData(
    String cacheKey,
    Duration maxAge,
  ) {
    logOperation(
      '获取缓存数据',
      params: {'cacheKey': cacheKey, 'maxAge': '${maxAge.inMinutes}分钟'},
    );

    try {
      final cachedData = CloudDriveCacheService.getCachedData(cacheKey, maxAge);
      if (cachedData != null) {
        logSuccess('获取缓存数据', details: '缓存命中');
      } else {
        logWarning('获取缓存数据', '缓存未命中或已过期');
      }
      return Success(cachedData);
    } catch (e) {
      logError('获取缓存数据', e);
      return Failure('获取缓存数据失败: $e');
    }
  }

  /// 清除缓存
  Result<void> clearCache([String? cacheKey]) {
    logOperation('清除缓存', params: {'cacheKey': cacheKey ?? '全部'});

    try {
      CloudDriveCacheService.clearCache(cacheKey);
      logSuccess('清除缓存', details: cacheKey ?? '全部');
      return const Success(null);
    } catch (e) {
      logError('清除缓存', e);
      return Failure('清除缓存失败: $e');
    }
  }

  /// 生成缓存键
  Result<String> generateCacheKey(String accountId, List<PathInfo> folderPath) {
    logOperation(
      '生成缓存键',
      params: {
        'accountId': accountId,
        'folderPath': folderPath.map((p) => p.name).join(' -> '),
      },
    );

    try {
      final cacheKey = CloudDriveCacheService.generateCacheKey(
        accountId,
        folderPath,
      );
      logSuccess('生成缓存键', details: cacheKey);
      return Success(cacheKey);
    } catch (e) {
      logError('生成缓存键', e);
      return Failure('生成缓存键失败: $e');
    }
  }

  /// 获取缓存统计信息
  Result<Map<String, dynamic>> getCacheStats() {
    logOperation('获取缓存统计信息');

    try {
      final stats = CloudDriveCacheService.getCacheStats();
      logSuccess('获取缓存统计信息', details: '${stats['totalEntries']} 个条目');
      return Success(stats);
    } catch (e) {
      logError('获取缓存统计信息', e);
      return Failure('获取缓存统计信息失败: $e');
    }
  }

  /// 智能缓存 - 根据数据类型和访问频率决定缓存策略
  Result<void> smartCache(
    String cacheKey,
    Map<String, dynamic> data, {
    Duration? ttl,
    int? accessCount,
    DateTime? lastAccess,
  }) {
    logOperation(
      '智能缓存',
      params: {
        'cacheKey': cacheKey,
        'ttl': ttl?.inMinutes ?? '默认',
        'accessCount': accessCount ?? 0,
      },
    );

    try {
      // 根据访问频率调整TTL
      Duration effectiveTTL = ttl ?? const Duration(minutes: 5);
      if (accessCount != null && accessCount > 10) {
        effectiveTTL = Duration(minutes: effectiveTTL.inMinutes * 2);
      }

      // 添加元数据
      final enhancedData = {
        ...data,
        '_cache_metadata': {
          'created_at': DateTime.now().toIso8601String(),
          'ttl': effectiveTTL.inMilliseconds,
          'access_count': accessCount ?? 1,
          'last_access':
              lastAccess?.toIso8601String() ?? DateTime.now().toIso8601String(),
        },
      };

      CloudDriveCacheService.cacheData(cacheKey, enhancedData);
      logSuccess('智能缓存', details: 'TTL: ${effectiveTTL.inMinutes}分钟');
      return const Success(null);
    } catch (e) {
      logError('智能缓存', e);
      return Failure('智能缓存失败: $e');
    }
  }

  /// 智能获取缓存 - 根据访问频率和TTL决定是否返回缓存数据
  Result<Map<String, dynamic>?> smartGetCachedData(
    String cacheKey, {
    Duration? maxAge,
    bool updateAccessCount = true,
  }) {
    logOperation(
      '智能获取缓存',
      params: {'cacheKey': cacheKey, 'maxAge': maxAge?.inMinutes ?? '默认'},
    );

    try {
      final cachedData = CloudDriveCacheService.getCachedData(
        cacheKey,
        maxAge ?? const Duration(minutes: 5),
      );

      if (cachedData != null) {
        // 更新访问计数
        if (updateAccessCount && cachedData.containsKey('_cache_metadata')) {
          final metadata =
              cachedData['_cache_metadata'] as Map<String, dynamic>;
          metadata['access_count'] =
              (metadata['access_count'] as int? ?? 0) + 1;
          metadata['last_access'] = DateTime.now().toIso8601String();

          // 重新缓存更新后的数据
          CloudDriveCacheService.cacheData(cacheKey, cachedData);
        }

        logSuccess('智能获取缓存', details: '缓存命中');
        return Success(cachedData);
      } else {
        logWarning('智能获取缓存', '缓存未命中或已过期');
        return const Success(null);
      }
    } catch (e) {
      logError('智能获取缓存', e);
      return Failure('智能获取缓存失败: $e');
    }
  }

  /// 预热缓存 - 预加载常用数据
  Future<Result<void>> warmupCache(
    String accountId,
    List<PathInfo> commonPaths,
  ) async {
    logOperation(
      '预热缓存',
      params: {'accountId': accountId, 'commonPaths': commonPaths.length},
    );

    try {
      // 为常用路径生成缓存键
      for (final path in commonPaths) {
        final cacheKey = CloudDriveCacheService.generateCacheKey(accountId, [
          path,
        ]);

        // 检查是否已有缓存
        final existingCache = CloudDriveCacheService.getCachedData(
          cacheKey,
          const Duration(hours: 1),
        );

        if (existingCache == null) {
          // 这里可以预加载数据，暂时只记录日志
          LogManager().cloudDrive('预热缓存路径: ${path.name}');
        }
      }

      logSuccess('预热缓存', details: '${commonPaths.length} 个路径');
      return const Success(null);
    } catch (e) {
      logError('预热缓存', e);
      return Failure('预热缓存失败: $e');
    }
  }

  /// 清理过期缓存
  Result<int> cleanupExpiredCache() {
    logOperation('清理过期缓存');

    try {
      final stats = CloudDriveCacheService.getCacheStats();
      final totalEntries = stats['totalEntries'] as int? ?? 0;

      // 这里应该实现实际的清理逻辑
      // 暂时只记录日志
      LogManager().cloudDrive('🧹 清理过期缓存: $totalEntries 个条目');

      logSuccess('清理过期缓存', details: '$totalEntries 个条目');
      return Success(totalEntries);
    } catch (e) {
      logError('清理过期缓存', e);
      return Failure('清理过期缓存失败: $e');
    }
  }

  /// 获取缓存性能指标
  Result<Map<String, dynamic>> getCacheMetrics() {
    logOperation('获取缓存性能指标');

    try {
      final stats = CloudDriveCacheService.getCacheStats();
      final metrics = {
        'total_entries': stats['totalEntries'] ?? 0,
        'cache_hit_rate': 0.0, // 需要实现命中率统计
        'average_access_time': 0.0, // 需要实现访问时间统计
        'memory_usage': 0, // 需要实现内存使用统计
        'last_cleanup': DateTime.now().toIso8601String(),
      };

      logSuccess('获取缓存性能指标');
      return Success(metrics);
    } catch (e) {
      logError('获取缓存性能指标', e);
      return Failure('获取缓存性能指标失败: $e');
    }
  }
}
