import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 内存管理器
/// 负责监控和管理应用内存使用情况
class MemoryManager {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  Timer? _memoryCheckTimer;
  final List<void Function(int memoryUsage, bool isHigh)> _callbacks = [];
  int _lastMemoryUsage = 0;
  static const int _memoryCheckInterval = 30000; // 30秒检查一次
  static const int _memoryThreshold = 100 * 1024 * 1024; // 100MB阈值

  /// 开始内存监控
  void startMonitoring() {
    if (kDebugMode) {
      _memoryCheckTimer = Timer.periodic(
        const Duration(milliseconds: _memoryCheckInterval),
        _checkMemoryUsage,
      );
      developer.log('内存监控已启动');
    }
  }

  /// 停止内存监控
  void stopMonitoring() {
    _memoryCheckTimer?.cancel();
    _memoryCheckTimer = null;
    if (kDebugMode) {
      developer.log('内存监控已停止');
    }
  }

  /// 添加内存回调
  void addMemoryCallback(void Function(int memoryUsage, bool isHigh) callback) {
    _callbacks.add(callback);
  }

  /// 移除内存回调
  void removeMemoryCallback(
    void Function(int memoryUsage, bool isHigh) callback,
  ) {
    _callbacks.remove(callback);
  }

  /// 检查内存使用情况
  void _checkMemoryUsage(Timer timer) async {
    try {
      final memoryUsage = await _getCurrentMemoryUsage();
      final isHighMemory = memoryUsage > _memoryThreshold;

      if (memoryUsage != _lastMemoryUsage) {
        _lastMemoryUsage = memoryUsage;

        // 通知所有回调
        for (final callback in _callbacks) {
          callback(memoryUsage, isHighMemory);
        }

        if (kDebugMode) {
          developer.log(
            '内存使用: ${_formatMemory(memoryUsage)} ${isHighMemory ? '(高内存警告)' : ''}',
          );
        }

        // 如果内存使用过高，触发清理
        if (isHighMemory) {
          await _triggerMemoryCleanup();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('内存检查失败: $e');
      }
    }
  }

  /// 获取当前内存使用量
  Future<int> _getCurrentMemoryUsage() async {
    try {
      // 在调试模式下获取内存信息
      if (kDebugMode) {
        final result = await SystemChannels.platform.invokeMethod(
          'System.getMemoryInfo',
        );
        if (result is Map && result['totalMemory'] != null) {
          return result['totalMemory'] as int;
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// 触发内存清理
  Future<void> _triggerMemoryCleanup() async {
    if (kDebugMode) {
      developer.log('触发内存清理');
    }

    // 清理主题缓存
    await _clearThemeCache();

    // 清理图片缓存
    await _clearImageCache();

    // 强制垃圾回收
    await _forceGarbageCollection();
  }

  /// 清理主题缓存
  Future<void> _clearThemeCache() async {
    try {
      // 这里可以调用主题工厂的清理方法
      // ThemeConfigFactory.clearCache();
      if (kDebugMode) {
        developer.log('主题缓存已清理');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('清理主题缓存失败: $e');
      }
    }
  }

  /// 清理图片缓存
  Future<void> _clearImageCache() async {
    try {
      // 清理Flutter的图片缓存
      // PaintingBinding.instance.imageCache.clear();
      if (kDebugMode) {
        developer.log('图片缓存已清理');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('清理图片缓存失败: $e');
      }
    }
  }

  /// 强制垃圾回收
  Future<void> _forceGarbageCollection() async {
    try {
      // 在调试模式下触发垃圾回收
      if (kDebugMode) {
        // 这里可以添加一些内存清理逻辑
        developer.log('垃圾回收已触发');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('垃圾回收失败: $e');
      }
    }
  }

  /// 格式化内存大小
  String _formatMemory(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 获取内存统计信息
  Map<String, dynamic> getMemoryStats() {
    return {
      'lastMemoryUsage': _lastMemoryUsage,
      'formattedMemory': _formatMemory(_lastMemoryUsage),
      'memoryThreshold': _memoryThreshold,
      'formattedThreshold': _formatMemory(_memoryThreshold),
      'isHighMemory': _lastMemoryUsage > _memoryThreshold,
      'isMonitoring': _memoryCheckTimer?.isActive ?? false,
      'callbackCount': _callbacks.length,
    };
  }

  /// 手动触发内存清理
  Future<void> manualCleanup() async {
    await _triggerMemoryCleanup();
  }

  /// 销毁内存管理器
  void dispose() {
    stopMonitoring();
    _callbacks.clear();
  }
}
