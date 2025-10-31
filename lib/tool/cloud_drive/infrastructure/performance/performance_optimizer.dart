import 'dart:async';
import 'dart:collection';
import '../../../../../core/logging/log_manager.dart';
import 'performance_monitor.dart';
import 'memory_optimizer.dart';
import 'large_file_processor.dart';

/// 性能优化器 - 综合性能优化管理
class PerformanceOptimizer {
  static final PerformanceOptimizer _instance =
      PerformanceOptimizer._internal();
  factory PerformanceOptimizer() => _instance;
  PerformanceOptimizer._internal();

  final PerformanceMonitor _monitor = PerformanceMonitor();
  final MemoryOptimizer _memoryOptimizer = MemoryOptimizer();
  final Queue<OptimizationSuggestion> _suggestions =
      Queue<OptimizationSuggestion>();

  bool _isInitialized = false;
  Timer? _optimizationTimer;

  /// 初始化性能优化器
  Future<void> initialize() async {
    if (_isInitialized) return;

    LogManager().cloudDrive('初始化性能优化器');

    // 开始内存监控
    _memoryOptimizer.startMonitoring();

    // 开始定期优化
    _startPeriodicOptimization();

    _isInitialized = true;
    LogManager().cloudDrive('性能优化器初始化完成');
  }

  /// 开始监控操作
  PerformanceTimer startOperation(
    String operationName, {
    Map<String, dynamic>? metadata,
  }) {
    return _monitor.startOperation(operationName, metadata: metadata);
  }

  /// 完成操作
  void completeOperation(PerformanceTimer timer) {
    timer.complete();
    _analyzePerformance(timer.operationName);
  }

  /// 记录错误
  void recordError(
    String operationName,
    dynamic error, {
    Map<String, dynamic>? metadata,
  }) {
    _monitor.recordError(operationName, error, metadata: metadata);
  }

  /// 获取性能报告
  PerformanceReport getPerformanceReport() {
    return _monitor.getPerformanceReport();
  }

  /// 获取内存使用情况
  MemoryUsage getMemoryUsage() {
    return _memoryOptimizer.getCurrentMemoryUsage();
  }

  /// 获取优化建议
  List<OptimizationSuggestion> getOptimizationSuggestions() {
    return List.unmodifiable(_suggestions);
  }

  /// 应用优化建议
  Future<void> applyOptimization(OptimizationSuggestion suggestion) async {
    LogManager().cloudDrive('应用优化建议: ${suggestion.title}');

    try {
      switch (suggestion.type) {
        case OptimizationType.memoryCleanup:
          await _memoryOptimizer.optimizeMemory();
          break;
        case OptimizationType.cacheOptimization:
          await _optimizeCache();
          break;
        case OptimizationType.networkOptimization:
          await _optimizeNetwork();
          break;
        case OptimizationType.concurrencyOptimization:
          await _optimizeConcurrency();
          break;
      }

      suggestion.isApplied = true;
      LogManager().cloudDrive('优化建议应用成功: ${suggestion.title}');
    } catch (e) {
      LogManager().error('优化建议应用失败: ${suggestion.title} - $e');
    }
  }

  /// 处理大文件
  Future<T> processLargeFile<T>({
    required String filePath,
    required Future<T> Function(Stream<List<int>>) processor,
  }) async {
    return await _memoryOptimizer.processLargeFile(
      filePath: filePath,
      processor: processor,
    );
  }

  /// 在隔离中处理大文件
  Future<T> processLargeFileInIsolate<T>({
    required String filePath,
    required T Function(List<int>) processor,
  }) async {
    return await _memoryOptimizer.processLargeFileInIsolate(
      filePath: filePath,
      processor: processor,
    );
  }

  /// 分块处理大文件
  Future<void> processLargeFileInChunks({
    required String filePath,
    required Future<void> Function(List<int>) chunkProcessor,
    int chunkSize = 1024 * 1024,
  }) async {
    return await _memoryOptimizer.processLargeFileInChunks(
      filePath: filePath,
      chunkProcessor: chunkProcessor,
      chunkSize: chunkSize,
    );
  }

  /// 获取大文件处理器
  LargeFileProcessor getLargeFileProcessor() {
    return LargeFileProcessor();
  }

  /// 开始定期优化
  void _startPeriodicOptimization() {
    _optimizationTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performPeriodicOptimization(),
    );
  }

  /// 执行定期优化
  Future<void> _performPeriodicOptimization() async {
    LogManager().cloudDrive('执行定期性能优化');

    try {
      // 分析性能
      _analyzeOverallPerformance();

      // 检查内存压力
      final memoryPressure = _memoryOptimizer.checkMemoryPressure();
      if (memoryPressure == MemoryPressureLevel.high ||
          memoryPressure == MemoryPressureLevel.critical) {
        await _memoryOptimizer.optimizeMemory();
      }

      // 清理旧数据
      _monitor.cleanup();

      LogManager().cloudDrive('定期性能优化完成');
    } catch (e) {
      LogManager().error('定期性能优化失败: $e');
    }
  }

  /// 分析性能
  void _analyzePerformance(String operationName) {
    final metric = _monitor.getMetric(operationName);
    if (metric == null) return;

    // 检查平均响应时间
    if (metric.averageDuration.inMilliseconds > 5000) {
      // 5秒
      _addSuggestion(
        OptimizationSuggestion(
          type: OptimizationType.networkOptimization,
          title: '优化网络请求',
          description:
              '操作 "$operationName" 平均响应时间过长 (${metric.averageDuration.inMilliseconds}ms)',
          priority: SuggestionPriority.high,
        ),
      );
    }

    // 检查操作频率
    if (metric.operationsPerMinute > 60) {
      // 每分钟超过60次
      _addSuggestion(
        OptimizationSuggestion(
          type: OptimizationType.concurrencyOptimization,
          title: '优化并发处理',
          description:
              '操作 "$operationName" 调用频率过高 (${metric.operationsPerMinute.toStringAsFixed(1)}/分钟)',
          priority: SuggestionPriority.medium,
        ),
      );
    }
  }

  /// 分析整体性能
  void _analyzeOverallPerformance() {
    final report = _monitor.getPerformanceReport();

    // 检查成功率
    if (report.successRate < 95) {
      _addSuggestion(
        OptimizationSuggestion(
          type: OptimizationType.networkOptimization,
          title: '提高操作成功率',
          description:
              '当前成功率为 ${report.successRate.toStringAsFixed(1)}%，建议优化网络连接',
          priority: SuggestionPriority.high,
        ),
      );
    }

    // 检查平均响应时间
    if (report.averageDuration.inMilliseconds > 3000) {
      // 3秒
      _addSuggestion(
        OptimizationSuggestion(
          type: OptimizationType.networkOptimization,
          title: '优化响应时间',
          description: '平均响应时间过长 (${report.averageDuration.inMilliseconds}ms)',
          priority: SuggestionPriority.medium,
        ),
      );
    }

    // 检查内存使用
    final memoryPressure = _memoryOptimizer.checkMemoryPressure();
    if (memoryPressure == MemoryPressureLevel.high) {
      _addSuggestion(
        OptimizationSuggestion(
          type: OptimizationType.memoryCleanup,
          title: '清理内存',
          description: '内存使用率较高，建议清理缓存',
          priority: SuggestionPriority.high,
        ),
      );
    }
  }

  /// 添加优化建议
  void _addSuggestion(OptimizationSuggestion suggestion) {
    // 检查是否已存在相同建议
    final exists = _suggestions.any(
      (s) =>
          s.type == suggestion.type &&
          s.title == suggestion.title &&
          !s.isApplied,
    );

    if (!exists) {
      _suggestions.add(suggestion);
      LogManager().cloudDrive('新增优化建议: ${suggestion.title}');
    }
  }

  /// 优化缓存
  Future<void> _optimizeCache() async {
    LogManager().cloudDrive('优化缓存策略');
    // 这里可以实现具体的缓存优化逻辑
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// 优化网络
  Future<void> _optimizeNetwork() async {
    LogManager().cloudDrive('优化网络配置');
    // 这里可以实现具体的网络优化逻辑
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// 优化并发
  Future<void> _optimizeConcurrency() async {
    LogManager().cloudDrive('优化并发处理');
    // 这里可以实现具体的并发优化逻辑
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// 释放资源
  void dispose() {
    _optimizationTimer?.cancel();
    _memoryOptimizer.dispose();
    _monitor.reset();
    _suggestions.clear();
    _isInitialized = false;
    LogManager().cloudDrive('性能优化器已释放');
  }
}

/// 优化建议
class OptimizationSuggestion {
  final OptimizationType type;
  final String title;
  final String description;
  final SuggestionPriority priority;
  bool isApplied;

  OptimizationSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    this.isApplied = false,
  });

  @override
  String toString() {
    return 'OptimizationSuggestion('
        'type: $type, '
        'title: $title, '
        'priority: $priority, '
        'isApplied: $isApplied'
        ')';
  }
}

/// 优化类型
enum OptimizationType {
  memoryCleanup,
  cacheOptimization,
  networkOptimization,
  concurrencyOptimization,
}

/// 建议优先级
enum SuggestionPriority { low, medium, high, critical }
