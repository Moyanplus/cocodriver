import '../../data/models/cloud_drive_entities.dart';
import '../../config/cloud_drive_cache_config.dart';
import '../../../../core/logging/log_manager.dart';

/// 文件列表缓存管理器
///
/// 提供文件列表缓存功能，支持智能过期策略和 LRU 策略。

/// 文件列表缓存项类
class FileListCacheEntry {
  final List<CloudDriveFile> files;
  final List<CloudDriveFile> folders;
  final DateTime timestamp;
  final Duration ttl; // Time To Live 生存时间

  FileListCacheEntry({
    required this.files,
    required this.folders,
    required this.timestamp,
    this.ttl = CloudDriveCacheConfig.defaultFolderCacheTtl,
  });

  /// 是否已过期
  bool get isExpired {
    final now = DateTime.now();
    return now.difference(timestamp) > ttl;
  }

  /// 剩余有效时间（秒）
  int get remainingSeconds {
    if (isExpired) return 0;
    final remaining = ttl - DateTime.now().difference(timestamp);
    return remaining.inSeconds;
  }

  @override
  String toString() =>
      'CacheEntry{files: ${files.length}, folders: ${folders.length}, '
      'age: ${DateTime.now().difference(timestamp).inSeconds}s, '
      'remainingTime: ${remainingSeconds}s, expired: $isExpired}';
}

/// 文件列表缓存管理器类
class FileListCacheManager {
  // 单例模式
  static final FileListCacheManager _instance =
      FileListCacheManager._internal();
  factory FileListCacheManager() => _instance;
  FileListCacheManager._internal();

  /// 缓存存储 Map<accountId_folderId, CacheEntry>
  final Map<String, FileListCacheEntry> _cache = {};

  /// 缓存访问时间记录（用于LRU）
  final Map<String, DateTime> _accessTime = {};

  /// 最大缓存数量
  static const int _maxCacheSize =
      CloudDriveCacheConfig.maxFolderCacheEntries;

  /// 构建缓存键
  String _buildKey(String accountId, String folderId) {
    return '${accountId}_${folderId.isEmpty ? 'root' : folderId}';
  }

  /// 获取缓存
  ///
  /// [accountId] 账号ID
  /// [folderId] 文件夹ID
  /// [ignoreExpired] 是否忽略过期的缓存（默认false）
  FileListCacheEntry? get(
    String accountId,
    String folderId, {
    bool ignoreExpired = false,
  }) {
    final key = _buildKey(accountId, folderId);
    final entry = _cache[key];

    if (entry == null) {
      LogManager().cloudDrive('📦 缓存未命中: $key');
      return null;
    }

    // 检查是否过期
    if (!ignoreExpired && entry.isExpired) {
      LogManager().cloudDrive('⏰ 缓存已过期: $key (${entry.remainingSeconds}s ago)');
      _cache.remove(key);
      _accessTime.remove(key);
      return null;
    }

    // 更新访问时间（LRU）
    _accessTime[key] = DateTime.now();

    LogManager().cloudDrive(
      '✅ 缓存命中: $key (${entry.files.length} 文件, '
      '${entry.folders.length} 文件夹, 剩余 ${entry.remainingSeconds}s)',
    );

    return entry;
  }

  /// 设置缓存
  ///
  /// [accountId] 账号ID
  /// [folderId] 文件夹ID
  /// [files] 文件列表
  /// [folders] 文件夹列表
  /// [ttl] 缓存有效期（可选，默认5分钟）
  void set(
    String accountId,
    String folderId,
    List<CloudDriveFile> files,
    List<CloudDriveFile> folders, {
    Duration? ttl,
  }) {
    final key = _buildKey(accountId, folderId);

    // LRU 清理：如果缓存满了，移除最久未访问的
    if (_cache.length >= _maxCacheSize) {
      _evictLeastRecentlyUsed();
    }

    final entry = FileListCacheEntry(
      files: List.unmodifiable(files), // 不可变列表
      folders: List.unmodifiable(folders),
      timestamp: DateTime.now(),
      ttl: ttl ?? CloudDriveCacheConfig.defaultFolderCacheTtl,
    );

    _cache[key] = entry;
    _accessTime[key] = DateTime.now();

    LogManager().cloudDrive(
      '💾 缓存已保存: $key (${files.length} 文件, ${folders.length} 文件夹, TTL: ${entry.ttl.inMinutes}min)',
    );
  }

  /// 清除指定缓存
  void remove(String accountId, String folderId) {
    final key = _buildKey(accountId, folderId);
    final removed = _cache.remove(key);
    _accessTime.remove(key);

    if (removed != null) {
      LogManager().cloudDrive('🗑️ 缓存已清除: $key');
    }
  }

  /// 清除账号的所有缓存
  void removeAccount(String accountId) {
    final keysToRemove =
        _cache.keys.where((key) => key.startsWith('${accountId}_')).toList();

    for (final key in keysToRemove) {
      _cache.remove(key);
      _accessTime.remove(key);
    }

    LogManager().cloudDrive(
      '🗑️ 清除账号缓存: $accountId (${keysToRemove.length} 项)',
    );
  }

  /// 清除所有缓存
  void clearAll() {
    final count = _cache.length;
    _cache.clear();
    _accessTime.clear();
    LogManager().cloudDrive('🗑️ 清除所有缓存 (${count} 项)');
  }

  /// LRU 淘汰：移除最久未访问的缓存
  void _evictLeastRecentlyUsed() {
    if (_cache.isEmpty) return;

    // 找到最久未访问的key
    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _accessTime.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
      _accessTime.remove(oldestKey);
      LogManager().cloudDrive('♻️ LRU淘汰: $oldestKey');
    }
  }

  /// 更新缓存中的单个文件（如重命名后）
  void updateFileInCache(
    String accountId,
    String folderId,
    String fileId,
    String newName,
  ) {
    final key = _buildKey(accountId, folderId);
    final entry = _cache[key];

    if (entry == null) return;

    // 更新文件列表中的文件名
    final updatedFiles =
        entry.files.map((file) {
          if (file.id == fileId) {
            return CloudDriveFile(
              id: file.id,
              name: newName,
              size: file.size,
              modifiedTime: file.modifiedTime,
              isFolder: file.isFolder,
              folderId: file.folderId,
              thumbnailUrl: file.thumbnailUrl,
              bigThumbnailUrl: file.bigThumbnailUrl,
              previewUrl: file.previewUrl,
            );
          }
          return file;
        }).toList();

    // 更新文件夹列表中的文件名
    final updatedFolders =
        entry.folders.map((folder) {
          if (folder.id == fileId) {
            return CloudDriveFile(
              id: folder.id,
              name: newName,
              size: folder.size,
              modifiedTime: folder.modifiedTime,
              isFolder: folder.isFolder,
              folderId: folder.folderId,
            );
          }
          return folder;
        }).toList();

    // 更新缓存
    set(accountId, folderId, updatedFiles, updatedFolders, ttl: entry.ttl);

    LogManager().cloudDrive('📝 缓存已更新: $key (重命名 $fileId -> $newName)');
  }

  /// 从缓存中移除文件（如删除后）
  void removeFileFromCache(String accountId, String folderId, String fileId) {
    final key = _buildKey(accountId, folderId);
    final entry = _cache[key];

    if (entry == null) return;

    final updatedFiles = entry.files.where((f) => f.id != fileId).toList();
    final updatedFolders = entry.folders.where((f) => f.id != fileId).toList();

    set(accountId, folderId, updatedFiles, updatedFolders, ttl: entry.ttl);

    LogManager().cloudDrive('🗑️ 文件已从缓存移除: $key (文件ID: $fileId)');
  }

  /// 将文件重新放回缓存（如删除失败需要回滚）
  void addFileToCache(
    String accountId,
    String folderId,
    CloudDriveFile file, {
    int? index,
  }) {
    final key = _buildKey(accountId, folderId);
    final entry = _cache[key];

    if (entry == null) return;

    final updatedFiles = entry.files.toList();
    final updatedFolders = entry.folders.toList();

    if (file.isFolder) {
      if (!updatedFolders.any((f) => f.id == file.id)) {
        if (index != null && index >= 0 && index <= updatedFolders.length) {
          updatedFolders.insert(index, file);
        } else {
          updatedFolders.add(file);
        }
      }
    } else {
      if (!updatedFiles.any((f) => f.id == file.id)) {
        if (index != null && index >= 0 && index <= updatedFiles.length) {
          updatedFiles.insert(index, file);
        } else {
          updatedFiles.add(file);
        }
      }
    }

    set(accountId, folderId, updatedFiles, updatedFolders, ttl: entry.ttl);

    LogManager().cloudDrive('↩️ 文件已回滚到缓存: $key (文件ID: ${file.id})');
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    int totalFiles = 0;
    int totalFolders = 0;
    int expiredCount = 0;

    for (final entry in _cache.values) {
      totalFiles += entry.files.length;
      totalFolders += entry.folders.length;
      if (entry.isExpired) expiredCount++;
    }

    return {
      'totalCacheEntries': _cache.length,
      'totalFiles': totalFiles,
      'totalFolders': totalFolders,
      'expiredEntries': expiredCount,
      'maxSize': _maxCacheSize,
      'cacheKeys': _cache.keys.toList(),
    };
  }

  /// 清理所有过期缓存
  void cleanExpired() {
    final keysToRemove = <String>[];

    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
      _accessTime.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      LogManager().cloudDrive('🧹 清理过期缓存: ${keysToRemove.length} 项');
    }
  }
}
