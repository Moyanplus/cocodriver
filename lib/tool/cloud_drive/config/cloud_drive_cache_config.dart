/// 云盘缓存配置，集中管理缓存策略相关常量。
class CloudDriveCacheConfig {
  const CloudDriveCacheConfig._();

  /// 文件/文件夹列表默认缓存时间。
  static const Duration defaultFolderCacheTtl = Duration(minutes: 5);

  /// 文件列表缓存最大数量（LRU 淘汰）。
  static const int maxFolderCacheEntries = 100;
}
