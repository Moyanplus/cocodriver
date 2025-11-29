import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../error/exceptions.dart';

/// 本地数据源基类
abstract class LocalDataSource {
  /// 获取数据
  Future<T?> get<T>(String key);

  /// 保存数据
  Future<void> save<T>(String key, T value);

  /// 删除数据
  Future<void> delete(String key);

  /// 检查数据是否存在
  Future<bool> contains(String key);

  /// 清空所有数据
  Future<void> clear();
}

/// SharedPreferences数据源
class SharedPreferencesDataSource implements LocalDataSource {
  final SharedPreferences _prefs;

  SharedPreferencesDataSource(this._prefs);

  @override
  Future<T?> get<T>(String key) async {
    try {
      final value = _prefs.get(key);
      if (value == null) return null;

      // 处理不同类型的数据
      if (T == String) {
        return value as T;
      } else if (T == int) {
        return value as T;
      } else if (T == double) {
        return value as T;
      } else if (T == bool) {
        return value as T;
      } else if (T == List<String>) {
        return _prefs.getStringList(key) as T?;
      }

      return null;
    } catch (e) {
      throw StorageException(
        message: 'Failed to get data for key: $key',
        originalError: e,
      );
    }
  }

  @override
  Future<void> save<T>(String key, T value) async {
    try {
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is List<String>) {
        await _prefs.setStringList(key, value);
      } else {
        throw StorageException(
          message: 'Unsupported type for SharedPreferences: ${T.toString()}',
        );
      }
    } catch (e) {
      throw StorageException(
        message: 'Failed to save data for key: $key',
        originalError: e,
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      throw StorageException(
        message: 'Failed to delete data for key: $key',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> contains(String key) async {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      throw StorageException(
        message: 'Failed to check if key exists: $key',
        originalError: e,
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _prefs.clear();
    } catch (e) {
      throw StorageException(
        message: 'Failed to clear SharedPreferences',
        originalError: e,
      );
    }
  }
}

/// Hive数据源
class HiveDataSource implements LocalDataSource {
  final Box _box;

  HiveDataSource(this._box);

  @override
  Future<T?> get<T>(String key) async {
    try {
      return _box.get(key);
    } catch (e) {
      throw StorageException(
        message: 'Failed to get data from Hive for key: $key',
        originalError: e,
      );
    }
  }

  @override
  Future<void> save<T>(String key, T value) async {
    try {
      await _box.put(key, value);
    } catch (e) {
      throw StorageException(
        message: 'Failed to save data to Hive for key: $key',
        originalError: e,
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _box.delete(key);
    } catch (e) {
      throw StorageException(
        message: 'Failed to delete data from Hive for key: $key',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> contains(String key) async {
    try {
      return _box.containsKey(key);
    } catch (e) {
      throw StorageException(
        message: 'Failed to check if key exists in Hive: $key',
        originalError: e,
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _box.clear();
    } catch (e) {
      throw StorageException(
        message: 'Failed to clear Hive box',
        originalError: e,
      );
    }
  }

  /// 获取所有键
  Future<List<String>> getAllKeys() async {
    try {
      return _box.keys.cast<String>().toList();
    } catch (e) {
      throw StorageException(
        message: 'Failed to get all keys from Hive',
        originalError: e,
      );
    }
  }

  /// 获取所有值
  Future<List<T>> getAllValues<T>() async {
    try {
      return _box.values.cast<T>().toList();
    } catch (e) {
      throw StorageException(
        message: 'Failed to get all values from Hive',
        originalError: e,
      );
    }
  }

  /// 批量保存
  Future<void> saveAll<T>(Map<String, T> data) async {
    try {
      await _box.putAll(data);
    } catch (e) {
      throw StorageException(
        message: 'Failed to save multiple data to Hive',
        originalError: e,
      );
    }
  }

  /// 批量删除
  Future<void> deleteAll(List<String> keys) async {
    try {
      await _box.deleteAll(keys);
    } catch (e) {
      throw StorageException(
        message: 'Failed to delete multiple data from Hive',
        originalError: e,
      );
    }
  }
}

/// 缓存数据源
class CacheDataSource {
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _defaultTtl;

  CacheDataSource({Duration? defaultTtl})
    : _defaultTtl = defaultTtl ?? const Duration(minutes: 5);

  /// 获取缓存数据
  T? get<T>(String key) {
    if (!_cache.containsKey(key)) return null;

    final timestamp = _cacheTimestamps[key];
    if (timestamp != null &&
        DateTime.now().difference(timestamp) > _defaultTtl) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    return _cache[key] as T?;
  }

  /// 保存缓存数据
  void save<T>(String key, T value, {Duration? ttl}) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// 删除缓存数据
  void delete(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// 检查缓存是否存在
  bool contains(String key) {
    if (!_cache.containsKey(key)) return false;

    final timestamp = _cacheTimestamps[key];
    if (timestamp != null &&
        DateTime.now().difference(timestamp) > _defaultTtl) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return false;
    }

    return true;
  }

  /// 清空所有缓存
  void clear() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// 清理过期缓存
  void cleanExpired() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _defaultTtl) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }
}
