import 'dart:collection';
import '../../../../../core/logging/log_manager.dart';

/// 性能监控器 - 监控和优化云盘操作性能
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, PerformanceMetric> _metrics = {};
  final Queue<PerformanceEvent> _eventHistory = Queue<PerformanceEvent>();
  final int _maxHistorySize = 1000;

  /// 开始监控操作
  PerformanceTimer startOperation(
    String operationName, {
    Map<String, dynamic>? metadata,
  }) {
    final timer = PerformanceTimer._(operationName, metadata);
    LogManager().cloudDrive('⏱️ 开始监控操作: $operationName');
    return timer;
  }

  /// 记录操作完成
  void recordOperation(PerformanceTimer timer) {
    final duration = timer.duration;
    final operationName = timer.operationName;
    final metadata = timer.metadata;

    // 更新指标
    _updateMetric(operationName, duration, metadata);

    // 记录事件
    _recordEvent(
      PerformanceEvent(
        operationName: operationName,
        duration: duration,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      ),
    );

    LogManager().cloudDrive(
      '✅ 操作完成: $operationName (${duration.inMilliseconds}ms)',
    );
  }

  /// 记录错误
  void recordError(
    String operationName,
    dynamic error, {
    Map<String, dynamic>? metadata,
  }) {
    _recordEvent(
      PerformanceEvent(
        operationName: operationName,
        duration: Duration.zero,
        timestamp: DateTime.now(),
        metadata: {...?metadata, 'error': error.toString(), 'isError': true},
      ),
    );

    LogManager().error('❌ 操作失败: $operationName - $error');
  }

  /// 获取操作指标
  PerformanceMetric? getMetric(String operationName) {
    return _metrics[operationName];
  }

  /// 获取所有指标
  Map<String, PerformanceMetric> getAllMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// 获取性能报告
  PerformanceReport getPerformanceReport() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));

    final recentEvents =
        _eventHistory
            .where((event) => event.timestamp.isAfter(last24Hours))
            .toList();

    final errorCount = recentEvents.where((event) => event.isError).length;
    final successCount = recentEvents.where((event) => !event.isError).length;
    final totalCount = recentEvents.length;

    final averageDuration =
        recentEvents
            .where((event) => !event.isError)
            .map((event) => event.duration.inMilliseconds)
            .fold<int>(0, (sum, duration) => sum + duration) /
        (successCount > 0 ? successCount : 1);

    return PerformanceReport(
      totalOperations: totalCount,
      successfulOperations: successCount,
      failedOperations: errorCount,
      successRate: totalCount > 0 ? (successCount / totalCount) * 100 : 0,
      averageDuration: Duration(milliseconds: averageDuration.round()),
      slowestOperation: _getSlowestOperation(recentEvents),
      fastestOperation: _getFastestOperation(recentEvents),
      metrics: Map.unmodifiable(_metrics),
    );
  }

  /// 清理旧数据
  void cleanup() {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 7));

    _eventHistory.removeWhere((event) => event.timestamp.isBefore(cutoff));

    // 清理过期的指标
    _metrics.removeWhere((key, metric) {
      return metric.lastUpdated.isBefore(cutoff);
    });

    LogManager().cloudDrive('🧹 性能监控数据清理完成');
  }

  /// 重置所有数据
  void reset() {
    _metrics.clear();
    _eventHistory.clear();
    LogManager().cloudDrive('🔄 性能监控数据已重置');
  }

  /// 更新指标
  void _updateMetric(
    String operationName,
    Duration duration,
    Map<String, dynamic>? metadata,
  ) {
    final metric = _metrics[operationName];
    if (metric == null) {
      _metrics[operationName] = PerformanceMetric(
        operationName: operationName,
        totalCount: 1,
        totalDuration: duration,
        minDuration: duration,
        maxDuration: duration,
        lastUpdated: DateTime.now(),
      );
    } else {
      _metrics[operationName] = PerformanceMetric(
        operationName: operationName,
        totalCount: metric.totalCount + 1,
        totalDuration: metric.totalDuration + duration,
        minDuration:
            duration < metric.minDuration ? duration : metric.minDuration,
        maxDuration:
            duration > metric.maxDuration ? duration : metric.maxDuration,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// 记录事件
  void _recordEvent(PerformanceEvent event) {
    _eventHistory.add(event);

    // 保持历史记录大小
    while (_eventHistory.length > _maxHistorySize) {
      _eventHistory.removeFirst();
    }
  }

  /// 获取最慢操作
  String? _getSlowestOperation(List<PerformanceEvent> events) {
    if (events.isEmpty) return null;

    final slowest = events
        .where((event) => !event.isError)
        .reduce((a, b) => a.duration > b.duration ? a : b);

    return slowest.operationName;
  }

  /// 获取最快操作
  String? _getFastestOperation(List<PerformanceEvent> events) {
    if (events.isEmpty) return null;

    final fastest = events
        .where((event) => !event.isError)
        .reduce((a, b) => a.duration < b.duration ? a : b);

    return fastest.operationName;
  }
}

/// 性能计时器
class PerformanceTimer {
  final String operationName;
  final Map<String, dynamic>? metadata;
  final DateTime _startTime;

  PerformanceTimer._(this.operationName, this.metadata)
    : _startTime = DateTime.now();

  /// 获取持续时间
  Duration get duration => DateTime.now().difference(_startTime);

  /// 完成操作
  void complete() {
    PerformanceMonitor().recordOperation(this);
  }

  /// 记录错误
  void recordError(dynamic error) {
    PerformanceMonitor().recordError(operationName, error, metadata: metadata);
  }
}

/// 性能指标
class PerformanceMetric {
  final String operationName;
  final int totalCount;
  final Duration totalDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final DateTime lastUpdated;

  const PerformanceMetric({
    required this.operationName,
    required this.totalCount,
    required this.totalDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.lastUpdated,
  });

  /// 平均持续时间
  Duration get averageDuration {
    if (totalCount == 0) return Duration.zero;
    return Duration(milliseconds: totalDuration.inMilliseconds ~/ totalCount);
  }

  /// 操作频率（每分钟）
  double get operationsPerMinute {
    final minutesSinceLastUpdate =
        DateTime.now().difference(lastUpdated).inMinutes;
    if (minutesSinceLastUpdate == 0) return 0;
    return totalCount / minutesSinceLastUpdate;
  }

  @override
  String toString() {
    return 'PerformanceMetric('
        'operation: $operationName, '
        'count: $totalCount, '
        'avg: ${averageDuration.inMilliseconds}ms, '
        'min: ${minDuration.inMilliseconds}ms, '
        'max: ${maxDuration.inMilliseconds}ms'
        ')';
  }
}

/// 性能事件
class PerformanceEvent {
  final String operationName;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const PerformanceEvent({
    required this.operationName,
    required this.duration,
    required this.timestamp,
    required this.metadata,
  });

  /// 是否为错误事件
  bool get isError => metadata['isError'] == true;

  @override
  String toString() {
    return 'PerformanceEvent('
        'operation: $operationName, '
        'duration: ${duration.inMilliseconds}ms, '
        'timestamp: $timestamp, '
        'isError: $isError'
        ')';
  }
}

/// 性能报告
class PerformanceReport {
  final int totalOperations;
  final int successfulOperations;
  final int failedOperations;
  final double successRate;
  final Duration averageDuration;
  final String? slowestOperation;
  final String? fastestOperation;
  final Map<String, PerformanceMetric> metrics;

  const PerformanceReport({
    required this.totalOperations,
    required this.successfulOperations,
    required this.failedOperations,
    required this.successRate,
    required this.averageDuration,
    required this.slowestOperation,
    required this.fastestOperation,
    required this.metrics,
  });

  /// 生成报告摘要
  String get summary {
    final buffer = StringBuffer();
    buffer.writeln('📊 性能报告摘要');
    buffer.writeln('总操作数: $totalOperations');
    buffer.writeln('成功操作: $successfulOperations');
    buffer.writeln('失败操作: $failedOperations');
    buffer.writeln('成功率: ${successRate.toStringAsFixed(1)}%');
    buffer.writeln('平均耗时: ${averageDuration.inMilliseconds}ms');

    if (slowestOperation != null) {
      buffer.writeln('最慢操作: $slowestOperation');
    }

    if (fastestOperation != null) {
      buffer.writeln('最快操作: $fastestOperation');
    }

    return buffer.toString();
  }

  /// 生成详细报告
  String get detailedReport {
    final buffer = StringBuffer();
    buffer.writeln(summary);
    buffer.writeln('\n📈 详细指标:');

    for (final metric in metrics.values) {
      buffer.writeln('${metric.operationName}:');
      buffer.writeln('  调用次数: ${metric.totalCount}');
      buffer.writeln('  平均耗时: ${metric.averageDuration.inMilliseconds}ms');
      buffer.writeln('  最小耗时: ${metric.minDuration.inMilliseconds}ms');
      buffer.writeln('  最大耗时: ${metric.maxDuration.inMilliseconds}ms');
      buffer.writeln(
        '  调用频率: ${metric.operationsPerMinute.toStringAsFixed(1)}/分钟',
      );
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
