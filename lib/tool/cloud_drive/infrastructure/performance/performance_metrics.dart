import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// 性能指标收集器
class PerformanceMetrics {
  static final PerformanceMetrics _instance = PerformanceMetrics._internal();
  factory PerformanceMetrics() => _instance;
  PerformanceMetrics._internal();

  final Map<String, List<PerformanceMetric>> _metrics = {};
  final StreamController<PerformanceMetric> _metricController = 
      StreamController<PerformanceMetric>.broadcast();

  /// 获取指标流
  Stream<PerformanceMetric> get metricStream => _metricController.stream;

  /// 记录性能指标
  void recordMetric({
    required String operation,
    required String category,
    required Duration duration,
    Map<String, dynamic>? metadata,
    String? error,
  }) {
    final metric = PerformanceMetric(
      operation: operation,
      category: category,
      duration: duration,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
      error: error,
    );

    _metrics.putIfAbsent(category, () => []).add(metric);
    _metricController.add(metric);

    if (kDebugMode) {
      _logMetric(metric);
    }
  }

  /// 记录API调用性能
  void recordApiCall({
    required String endpoint,
    required String method,
    required Duration duration,
    int? statusCode,
    int? responseSize,
    String? error,
  }) {
    recordMetric(
      operation: '$method $endpoint',
      category: 'api_call',
      duration: duration,
      metadata: {
        'endpoint': endpoint,
        'method': method,
        'status_code': statusCode,
        'response_size': responseSize,
      },
      error: error,
    );
  }

  /// 记录文件操作性能
  void recordFileOperation({
    required String operation,
    required String fileName,
    required Duration duration,
    int? fileSize,
    String? error,
  }) {
    recordMetric(
      operation: operation,
      category: 'file_operation',
      duration: duration,
      metadata: {
        'file_name': fileName,
        'file_size': fileSize,
      },
      error: error,
    );
  }

  /// 记录UI渲染性能
  void recordUIRender({
    required String widgetName,
    required Duration duration,
    Map<String, dynamic>? metadata,
  }) {
    recordMetric(
      operation: 'render_$widgetName',
      category: 'ui_render',
      duration: duration,
      metadata: metadata,
    );
  }

  /// 记录内存使用
  void recordMemoryUsage({
    required int usedMemory,
    required int totalMemory,
    String? context,
  }) {
    recordMetric(
      operation: 'memory_usage',
      category: 'memory',
      duration: Duration.zero,
      metadata: {
        'used_memory': usedMemory,
        'total_memory': totalMemory,
        'usage_percentage': (usedMemory / totalMemory * 100).toStringAsFixed(2),
        'context': context,
      },
    );
  }

  /// 记录网络性能
  void recordNetworkPerformance({
    required String operation,
    required Duration duration,
    int? bytesTransferred,
    String? error,
  }) {
    recordMetric(
      operation: operation,
      category: 'network',
      duration: duration,
      metadata: {
        'bytes_transferred': bytesTransferred,
        'speed_mbps': bytesTransferred != null 
            ? (bytesTransferred / duration.inMilliseconds * 8 / 1000).toStringAsFixed(2)
            : null,
      },
      error: error,
    );
  }

  /// 获取指定类别的指标
  List<PerformanceMetric> getMetrics(String category) {
    return _metrics[category] ?? [];
  }

  /// 获取所有指标
  Map<String, List<PerformanceMetric>> getAllMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// 获取性能统计
  PerformanceStats getStats(String category) {
    final metrics = getMetrics(category);
    if (metrics.isEmpty) {
      return PerformanceStats.empty();
    }

    final durations = metrics.map((m) => m.duration.inMilliseconds).toList();
    durations.sort();

    return PerformanceStats(
      category: category,
      totalOperations: metrics.length,
      averageDuration: Duration(
        milliseconds: (durations.reduce((a, b) => a + b) / durations.length).round(),
      ),
      minDuration: Duration(milliseconds: durations.first),
      maxDuration: Duration(milliseconds: durations.last),
      medianDuration: Duration(milliseconds: durations[durations.length ~/ 2]),
      errorRate: metrics.where((m) => m.error != null).length / metrics.length,
      lastUpdated: DateTime.now(),
    );
  }

  /// 获取系统性能信息
  Future<SystemPerformanceInfo> getSystemPerformance() async {
    try {
      final processInfo = ProcessInfo.currentRss;
      final totalMemory = Platform.numberOfProcessors * 1024 * 1024 * 1024; // 估算

      return SystemPerformanceInfo(
        memoryUsage: processInfo,
        totalMemory: totalMemory,
        cpuUsage: await _getCpuUsage(),
        diskUsage: await _getDiskUsage(),
        networkStats: await _getNetworkStats(),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return SystemPerformanceInfo.error(e.toString());
    }
  }

  /// 清理旧指标
  void cleanup({Duration? olderThan}) {
    final cutoff = olderThan ?? const Duration(hours: 24);
    final cutoffTime = DateTime.now().subtract(cutoff);

    for (final category in _metrics.keys) {
      _metrics[category]!.removeWhere(
        (metric) => metric.timestamp.isBefore(cutoffTime),
      );
    }
  }

  /// 重置所有指标
  void reset() {
    _metrics.clear();
  }

  void _logMetric(PerformanceMetric metric) {
    final status = metric.error != null ? '❌' : '✅';
    final duration = '${metric.duration.inMilliseconds}ms';
    print('📊 $status ${metric.category}/${metric.operation}: $duration');
    
    if (metric.error != null) {
      print('   Error: ${metric.error}');
    }
    
    if (metric.metadata.isNotEmpty) {
      print('   Metadata: ${metric.metadata}');
    }
  }

  Future<double> _getCpuUsage() async {
    // 简化的CPU使用率计算
    // 在实际应用中，这里应该使用更精确的方法
    return 0.0;
  }

  Future<DiskUsage> _getDiskUsage() async {
    // 简化的磁盘使用率计算
    return DiskUsage(
      used: 0,
      total: 0,
      free: 0,
    );
  }

  Future<NetworkStats> _getNetworkStats() async {
    // 简化的网络统计
    return NetworkStats(
      bytesReceived: 0,
      bytesSent: 0,
      packetsReceived: 0,
      packetsSent: 0,
    );
  }

  void dispose() {
    _metricController.close();
  }
}

/// 性能指标数据模型
class PerformanceMetric {
  final String operation;
  final String category;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final String? error;

  const PerformanceMetric({
    required this.operation,
    required this.category,
    required this.duration,
    required this.timestamp,
    required this.metadata,
    this.error,
  });

  bool get isSuccess => error == null;

  Map<String, dynamic> toJson() => {
    'operation': operation,
    'category': category,
    'duration_ms': duration.inMilliseconds,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
    'error': error,
  };
}

/// 性能统计数据模型
class PerformanceStats {
  final String category;
  final int totalOperations;
  final Duration averageDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final Duration medianDuration;
  final double errorRate;
  final DateTime lastUpdated;

  const PerformanceStats({
    required this.category,
    required this.totalOperations,
    required this.averageDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.medianDuration,
    required this.errorRate,
    required this.lastUpdated,
  });

  factory PerformanceStats.empty() {
    return PerformanceStats(
      category: '',
      totalOperations: 0,
      averageDuration: Duration.zero,
      minDuration: Duration.zero,
      maxDuration: Duration.zero,
      medianDuration: Duration.zero,
      errorRate: 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'total_operations': totalOperations,
    'average_duration_ms': averageDuration.inMilliseconds,
    'min_duration_ms': minDuration.inMilliseconds,
    'max_duration_ms': maxDuration.inMilliseconds,
    'median_duration_ms': medianDuration.inMilliseconds,
    'error_rate': errorRate,
    'last_updated': lastUpdated.toIso8601String(),
  };
}

/// 系统性能信息
class SystemPerformanceInfo {
  final int memoryUsage;
  final int totalMemory;
  final double cpuUsage;
  final DiskUsage diskUsage;
  final NetworkStats networkStats;
  final DateTime timestamp;
  final String? error;

  const SystemPerformanceInfo({
    required this.memoryUsage,
    required this.totalMemory,
    required this.cpuUsage,
    required this.diskUsage,
    required this.networkStats,
    required this.timestamp,
    this.error,
  });

  factory SystemPerformanceInfo.error(String error) {
    return SystemPerformanceInfo(
      memoryUsage: 0,
      totalMemory: 0,
      cpuUsage: 0.0,
      diskUsage: DiskUsage(used: 0, total: 0, free: 0),
      networkStats: NetworkStats(
        bytesReceived: 0,
        bytesSent: 0,
        packetsReceived: 0,
        packetsSent: 0,
      ),
      timestamp: DateTime.now(),
      error: error,
    );
  }

  double get memoryUsagePercentage => 
      totalMemory > 0 ? (memoryUsage / totalMemory * 100) : 0.0;

  Map<String, dynamic> toJson() => {
    'memory_usage': memoryUsage,
    'total_memory': totalMemory,
    'memory_usage_percentage': memoryUsagePercentage,
    'cpu_usage': cpuUsage,
    'disk_usage': diskUsage.toJson(),
    'network_stats': networkStats.toJson(),
    'timestamp': timestamp.toIso8601String(),
    'error': error,
  };
}

/// 磁盘使用情况
class DiskUsage {
  final int used;
  final int total;
  final int free;

  const DiskUsage({
    required this.used,
    required this.total,
    required this.free,
  });

  double get usagePercentage => total > 0 ? (used / total * 100) : 0.0;

  Map<String, dynamic> toJson() => {
    'used': used,
    'total': total,
    'free': free,
    'usage_percentage': usagePercentage,
  };
}

/// 网络统计信息
class NetworkStats {
  final int bytesReceived;
  final int bytesSent;
  final int packetsReceived;
  final int packetsSent;

  const NetworkStats({
    required this.bytesReceived,
    required this.bytesSent,
    required this.packetsReceived,
    required this.packetsSent,
  });

  Map<String, dynamic> toJson() => {
    'bytes_received': bytesReceived,
    'bytes_sent': bytesSent,
    'packets_received': packetsReceived,
    'packets_sent': packetsSent,
  };
}
