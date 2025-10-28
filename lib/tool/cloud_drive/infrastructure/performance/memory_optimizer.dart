import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import '../../../../../core/logging/log_manager.dart';

/// 内存优化器 - 优化大文件处理时的内存使用
class MemoryOptimizer {
  static final MemoryOptimizer _instance = MemoryOptimizer._internal();
  factory MemoryOptimizer() => _instance;
  MemoryOptimizer._internal();

  final Queue<MemoryUsage> _memoryHistory = Queue<MemoryUsage>();
  final int _maxHistorySize = 100;
  Timer? _monitoringTimer;
  bool _isMonitoring = false;

  /// 开始内存监控
  void startMonitoring({Duration interval = const Duration(seconds: 5)}) {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(interval, (_) {
      _recordMemoryUsage();
    });

    LogManager().cloudDrive('🔍 开始内存监控');
  }

  /// 停止内存监控
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;
    LogManager().cloudDrive('⏹️ 停止内存监控');
  }

  /// 获取当前内存使用情况
  MemoryUsage getCurrentMemoryUsage() {
    return _getMemoryUsage();
  }

  /// 获取内存使用历史
  List<MemoryUsage> getMemoryHistory() {
    return List.unmodifiable(_memoryHistory);
  }

  /// 检查内存压力
  MemoryPressureLevel checkMemoryPressure() {
    final current = getCurrentMemoryUsage();
    final totalMB = current.totalMB;
    final usedMB = current.usedMB;
    final usagePercentage = (usedMB / totalMB) * 100;

    if (usagePercentage > 90) {
      return MemoryPressureLevel.critical;
    } else if (usagePercentage > 75) {
      return MemoryPressureLevel.high;
    } else if (usagePercentage > 50) {
      return MemoryPressureLevel.medium;
    } else {
      return MemoryPressureLevel.low;
    }
  }

  /// 优化内存使用
  Future<void> optimizeMemory() async {
    final pressure = checkMemoryPressure();

    if (pressure == MemoryPressureLevel.critical) {
      LogManager().cloudDrive('🚨 内存压力严重，执行强制垃圾回收');
      await _forceGarbageCollection();
    } else if (pressure == MemoryPressureLevel.high) {
      LogManager().cloudDrive('⚠️ 内存压力较高，执行垃圾回收');
      await _forceGarbageCollection();
    }

    // 清理历史记录
    _cleanupHistory();
  }

  /// 处理大文件时的内存优化
  Future<T> processLargeFile<T>({
    required String filePath,
    required Future<T> Function(Stream<List<int>>) processor,
    int bufferSize = 64 * 1024, // 64KB
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('文件不存在: $filePath');
    }

    final fileSize = await file.length();
    LogManager().cloudDrive('📁 开始处理大文件: ${_formatFileSize(fileSize)}');

    // 检查内存压力
    final pressure = checkMemoryPressure();
    if (pressure == MemoryPressureLevel.critical) {
      LogManager().cloudDrive('🚨 内存压力严重，调整缓冲区大小');
      bufferSize = 32 * 1024; // 减少到32KB
    } else if (pressure == MemoryPressureLevel.high) {
      LogManager().cloudDrive('⚠️ 内存压力较高，调整缓冲区大小');
      bufferSize = 48 * 1024; // 减少到48KB
    }

    try {
      // 使用流式处理
      final stream = file.openRead();
      final result = await processor(stream);

      LogManager().cloudDrive('✅ 大文件处理完成');
      return result;
    } catch (e) {
      LogManager().error('❌ 大文件处理失败: $e');
      rethrow;
    } finally {
      // 处理完成后优化内存
      await optimizeMemory();
    }
  }

  /// 在隔离中处理大文件
  Future<T> processLargeFileInIsolate<T>({
    required String filePath,
    required T Function(List<int>) processor,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('文件不存在: $filePath');
    }

    final fileSize = await file.length();
    LogManager().cloudDrive('🔄 在隔离中处理大文件: ${_formatFileSize(fileSize)}');

    try {
      // 在隔离中读取文件
      final result = await Isolate.run(() async {
        final bytes = await file.readAsBytes();
        return processor(bytes);
      });

      LogManager().cloudDrive('✅ 隔离处理完成');
      return result;
    } catch (e) {
      LogManager().error('❌ 隔离处理失败: $e');
      rethrow;
    } finally {
      // 处理完成后优化内存
      await optimizeMemory();
    }
  }

  /// 分块处理大文件
  Future<void> processLargeFileInChunks({
    required String filePath,
    required Future<void> Function(List<int>) chunkProcessor,
    int chunkSize = 1024 * 1024, // 1MB
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('文件不存在: $filePath');
    }

    final fileSize = await file.length();
    final totalChunks = (fileSize / chunkSize).ceil();

    LogManager().cloudDrive('📦 开始分块处理: $totalChunks 个分块');

    try {
      final stream = file.openRead();
      final buffer = <int>[];

      await for (final chunk in stream) {
        buffer.addAll(chunk);

        // 当缓冲区达到分块大小时处理
        while (buffer.length >= chunkSize) {
          final chunkData = buffer.take(chunkSize).toList();
          buffer.removeRange(0, chunkSize);

          await chunkProcessor(chunkData);

          // 检查内存压力
          final pressure = checkMemoryPressure();
          if (pressure == MemoryPressureLevel.critical) {
            LogManager().cloudDrive('🚨 内存压力严重，暂停处理');
            await _forceGarbageCollection();
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
      }

      // 处理剩余数据
      if (buffer.isNotEmpty) {
        await chunkProcessor(buffer);
      }

      LogManager().cloudDrive('✅ 分块处理完成');
    } catch (e) {
      LogManager().error('❌ 分块处理失败: $e');
      rethrow;
    } finally {
      await optimizeMemory();
    }
  }

  /// 获取内存使用情况
  MemoryUsage _getMemoryUsage() {
    final info = ProcessInfo.currentRss;
    final total = ProcessInfo.maxRss;

    return MemoryUsage(
      usedBytes: info,
      totalBytes: total,
      timestamp: DateTime.now(),
    );
  }

  /// 记录内存使用情况
  void _recordMemoryUsage() {
    final usage = _getMemoryUsage();
    _memoryHistory.add(usage);

    // 保持历史记录大小
    while (_memoryHistory.length > _maxHistorySize) {
      _memoryHistory.removeFirst();
    }
  }

  /// 强制垃圾回收
  Future<void> _forceGarbageCollection() async {
    // 在Dart中，垃圾回收是自动的，但我们可以通过创建大量对象来触发
    final temp = List.generate(1000, (i) => List.generate(1000, (j) => i * j));
    temp.clear();

    // 等待垃圾回收
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// 清理历史记录
  void _cleanupHistory() {
    if (_memoryHistory.length > _maxHistorySize ~/ 2) {
      final toRemove = _memoryHistory.length - (_maxHistorySize ~/ 2);
      for (int i = 0; i < toRemove; i++) {
        _memoryHistory.removeFirst();
      }
    }
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 释放资源
  void dispose() {
    stopMonitoring();
    _memoryHistory.clear();
  }
}

/// 内存使用情况
class MemoryUsage {
  final int usedBytes;
  final int totalBytes;
  final DateTime timestamp;

  const MemoryUsage({
    required this.usedBytes,
    required this.totalBytes,
    required this.timestamp,
  });

  /// 已使用内存（MB）
  double get usedMB => usedBytes / (1024 * 1024);

  /// 总内存（MB）
  double get totalMB => totalBytes / (1024 * 1024);

  /// 使用率（百分比）
  double get usagePercentage => (usedBytes / totalBytes) * 100;

  @override
  String toString() {
    return 'MemoryUsage('
        'used: ${usedMB.toStringAsFixed(1)}MB, '
        'total: ${totalMB.toStringAsFixed(1)}MB, '
        'usage: ${usagePercentage.toStringAsFixed(1)}%'
        ')';
  }
}

/// 内存压力级别
enum MemoryPressureLevel { low, medium, high, critical }

/// 进程信息（简化版本）
class ProcessInfo {
  static int get currentRss {
    // 在实际应用中，这里应该获取真实的进程内存使用情况
    // 这里返回一个模拟值
    return 100 * 1024 * 1024; // 100MB
  }

  static int get maxRss {
    // 在实际应用中，这里应该获取真实的系统总内存
    // 这里返回一个模拟值
    return 8 * 1024 * 1024 * 1024; // 8GB
  }
}
