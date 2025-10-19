import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/log_manager.dart';
import '../base/cloud_drive_cache_service.dart';

/// 缓存状态管理
class CloudDriveCacheState {
  final bool isFromCache;
  final DateTime? lastRefreshTime;
  final Duration cacheAge;
  final bool isCacheValid;
  final int cacheHitCount;
  final int cacheMissCount;
  final Map<String, DateTime> cacheTimestamps;
  final List<String> cacheKeys;
  final bool enableCache;
  final Duration cacheExpiration;

  const CloudDriveCacheState({
    this.isFromCache = false,
    this.lastRefreshTime,
    this.cacheAge = Duration.zero,
    this.isCacheValid = true,
    this.cacheHitCount = 0,
    this.cacheMissCount = 0,
    this.cacheTimestamps = const {},
    this.cacheKeys = const [],
    this.enableCache = true,
    this.cacheExpiration = const Duration(minutes: 5),
  });

  CloudDriveCacheState copyWith({
    bool? isFromCache,
    DateTime? lastRefreshTime,
    Duration? cacheAge,
    bool? isCacheValid,
    int? cacheHitCount,
    int? cacheMissCount,
    Map<String, DateTime>? cacheTimestamps,
    List<String>? cacheKeys,
    bool? enableCache,
    Duration? cacheExpiration,
  }) => CloudDriveCacheState(
    isFromCache: isFromCache ?? this.isFromCache,
    lastRefreshTime: lastRefreshTime ?? this.lastRefreshTime,
    cacheAge: cacheAge ?? this.cacheAge,
    isCacheValid: isCacheValid ?? this.isCacheValid,
    cacheHitCount: cacheHitCount ?? this.cacheHitCount,
    cacheMissCount: cacheMissCount ?? this.cacheMissCount,
    cacheTimestamps: cacheTimestamps ?? this.cacheTimestamps,
    cacheKeys: cacheKeys ?? this.cacheKeys,
    enableCache: enableCache ?? this.enableCache,
    cacheExpiration: cacheExpiration ?? this.cacheExpiration,
  );

  /// 缓存命中率
  double get cacheHitRate {
    final total = cacheHitCount + cacheMissCount;
    return total > 0 ? cacheHitCount / total : 0.0;
  }

  /// 缓存是否过期
  bool get isExpired => cacheAge > cacheExpiration;

  /// 缓存统计信息
  Map<String, dynamic> get cacheStats => {
    'hitCount': cacheHitCount,
    'missCount': cacheMissCount,
    'hitRate': cacheHitRate,
    'totalKeys': cacheKeys.length,
    'isValid': isCacheValid,
    'isExpired': isExpired,
    'cacheAge': cacheAge.inSeconds,
    'expiration': cacheExpiration.inSeconds,
  };
}

/// 缓存状态Provider
class CloudDriveCacheProvider extends StateNotifier<CloudDriveCacheState> {
  CloudDriveCacheProvider() : super(const CloudDriveCacheState());

  /// 设置数据来自缓存
  void setFromCache(bool fromCache) {
    state = state.copyWith(isFromCache: fromCache);

    LogManager().cloudDrive(
      '💾 设置缓存来源: $fromCache',
      
    );
  }

  /// 更新最后刷新时间
  void updateLastRefreshTime() {
    final now = DateTime.now();
    state = state.copyWith(
      lastRefreshTime: now,
      cacheAge: Duration.zero,
      isFromCache: false,
    );

    LogManager().cloudDrive(
      '🕒 更新刷新时间: ${now.toIso8601String()}',
      
    );
  }

  /// 更新缓存年龄
  void updateCacheAge() {
    if (state.lastRefreshTime != null) {
      final age = DateTime.now().difference(state.lastRefreshTime!);
      final isValid = age <= state.cacheExpiration;

      state = state.copyWith(cacheAge: age, isCacheValid: isValid);

      LogManager().cloudDrive(
        '⏰ 更新缓存年龄: ${age.inSeconds}秒, 有效: $isValid',
        
      );
    }
  }

  /// 增加缓存命中计数
  void incrementCacheHit() {
    state = state.copyWith(cacheHitCount: state.cacheHitCount + 1);

    LogManager().cloudDrive(
      '✅ 缓存命中: ${state.cacheHitCount}',
      
    );
  }

  /// 增加缓存未命中计数
  void incrementCacheMiss() {
    state = state.copyWith(cacheMissCount: state.cacheMissCount + 1);

    LogManager().cloudDrive(
      '❌ 缓存未命中: ${state.cacheMissCount}',
      
    );
  }

  /// 添加缓存键
  void addCacheKey(String key) {
    if (!state.cacheKeys.contains(key)) {
      final newKeys = [...state.cacheKeys, key];
      final newTimestamps = Map<String, DateTime>.from(state.cacheTimestamps);
      newTimestamps[key] = DateTime.now();

      state = state.copyWith(
        cacheKeys: newKeys,
        cacheTimestamps: newTimestamps,
      );

      LogManager().cloudDrive(
        '➕ 添加缓存键: $key (共${newKeys.length}个)',
        
      );
    }
  }

  /// 移除缓存键
  void removeCacheKey(String key) {
    final newKeys = state.cacheKeys.where((k) => k != key).toList();
    final newTimestamps = Map<String, DateTime>.from(state.cacheTimestamps);
    newTimestamps.remove(key);

    state = state.copyWith(cacheKeys: newKeys, cacheTimestamps: newTimestamps);

    LogManager().cloudDrive(
      '➖ 移除缓存键: $key (剩余${newKeys.length}个)',
      
    );
  }

  /// 清除所有缓存
  void clearAllCache() {
    state = state.copyWith(
      cacheKeys: [],
      cacheTimestamps: {},
      cacheHitCount: 0,
      cacheMissCount: 0,
      isFromCache: false,
      lastRefreshTime: null,
      cacheAge: Duration.zero,
      isCacheValid: true,
    );

    // 调用缓存服务清除缓存
    CloudDriveCacheService.clearCache();

    LogManager().cloudDrive(
      '🗑️ 清除所有缓存',
      
    );
  }

  /// 切换缓存启用状态
  void toggleCache() {
    state = state.copyWith(enableCache: !state.enableCache);

    LogManager().cloudDrive(
      '🔄 切换缓存: ${state.enableCache}',
      
    );
  }

  /// 设置缓存过期时间
  void setCacheExpiration(Duration expiration) {
    state = state.copyWith(cacheExpiration: expiration);

    LogManager().cloudDrive(
      '⏰ 设置缓存过期时间: ${expiration.inMinutes}分钟',
      
    );
  }

  /// 检查缓存是否有效
  bool isCacheValidForKey(String key) {
    final timestamp = state.cacheTimestamps[key];
    if (timestamp == null) return false;

    final age = DateTime.now().difference(timestamp);
    return age <= state.cacheExpiration;
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    final stats = CloudDriveCacheService.getCacheStats();
    return {
      ...stats,
      'hitRate': state.cacheHitRate,
      'isValid': state.isCacheValid,
      'isExpired': state.isExpired,
      'enableCache': state.enableCache,
    };
  }

  /// 预加载缓存
  Future<void> preloadCache(List<String> keys) async {
    LogManager().cloudDrive(
      '🔄 预加载缓存: ${keys.length}个键',
      
    );

    // TODO: 实现预加载逻辑
    for (final key in keys) {
      addCacheKey(key);
    }
  }

  /// 重置缓存状态
  void reset() {
    state = const CloudDriveCacheState();

    LogManager().cloudDrive(
      '🔄 重置缓存状态',
      
    );
  }
}

/// 缓存状态Provider实例
final cloudDriveCacheProvider =
    StateNotifierProvider<CloudDriveCacheProvider, CloudDriveCacheState>(
      (ref) => CloudDriveCacheProvider(),
    );
