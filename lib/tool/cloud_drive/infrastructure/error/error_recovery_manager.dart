import 'dart:async';
import 'dart:io';

import '../performance/performance_metrics.dart';

/// 错误恢复管理器
///
/// 提供错误恢复、重试策略、熔断器等功能，提高系统的容错能力。
class ErrorRecoveryManager {
  static final ErrorRecoveryManager _instance =
      ErrorRecoveryManager._internal();
  factory ErrorRecoveryManager() => _instance;
  ErrorRecoveryManager._internal();

  final Map<String, RetryConfig> _retryConfigs = {};
  final Map<String, List<RecoveryAttempt>> _recoveryHistory = {};
  final StreamController<RecoveryEvent> _recoveryController =
      StreamController<RecoveryEvent>.broadcast();

  /// 获取恢复事件流
  Stream<RecoveryEvent> get recoveryStream => _recoveryController.stream;

  /// 初始化默认重试配置
  void initialize() {
    _retryConfigs.addAll({
      'network_error': RetryConfig(
        maxAttempts: 3,
        baseDelay: const Duration(seconds: 1),
        maxDelay: const Duration(seconds: 30),
        backoffMultiplier: 2.0,
        retryableErrors: [SocketException, TimeoutException, HttpException],
      ),
      'api_error': RetryConfig(
        maxAttempts: 2,
        baseDelay: const Duration(milliseconds: 500),
        maxDelay: const Duration(seconds: 10),
        backoffMultiplier: 1.5,
        retryableErrors: [TimeoutException, HttpException],
      ),
      'file_operation': RetryConfig(
        maxAttempts: 2,
        baseDelay: const Duration(seconds: 2),
        maxDelay: const Duration(seconds: 20),
        backoffMultiplier: 2.0,
        retryableErrors: [FileSystemException, TimeoutException],
      ),
      'authentication_error': RetryConfig(
        maxAttempts: 1,
        baseDelay: const Duration(seconds: 1),
        maxDelay: const Duration(seconds: 5),
        backoffMultiplier: 1.0,
        retryableErrors: [],
        requiresReauth: true,
      ),
    });
  }

  /// 执行带重试的操作
  Future<T> executeWithRetry<T>({
    required String operationId,
    required String category,
    required Future<T> Function() operation,
    RetryConfig? customConfig,
    Map<String, dynamic>? context,
  }) async {
    final config =
        customConfig ?? _retryConfigs[category] ?? RetryConfig.defaultConfig();
    final startTime = DateTime.now();

    for (int attempt = 1; attempt <= config.maxAttempts; attempt++) {
      try {
        final result = await operation();

        // 成功执行，记录恢复历史
        if (attempt > 1) {
          _recordRecoverySuccess(
            operationId,
            category,
            attempt,
            startTime,
            context,
          );
        }

        return result;
      } catch (error, stackTrace) {
        final isLastAttempt = attempt == config.maxAttempts;
        final isRetryable = _isRetryableError(error, config);

        // 记录错误
        _recordRecoveryAttempt(
          operationId,
          category,
          attempt,
          error,
          stackTrace,
          context,
        );

        if (isLastAttempt || !isRetryable) {
          // 最后一次尝试或不可重试的错误
          _recordRecoveryFailure(
            operationId,
            category,
            attempt,
            error,
            context,
          );
          rethrow;
        }

        // 计算延迟时间
        final delay = _calculateDelay(attempt, config);

        // 发送恢复事件
        _recoveryController.add(
          RecoveryEvent(
            operationId: operationId,
            category: category,
            attempt: attempt,
            error: error,
            delay: delay,
            isRetryable: isRetryable,
            timestamp: DateTime.now(),
          ),
        );

        // 等待后重试
        await Future.delayed(delay);
      }
    }

    throw StateError('Unexpected end of retry loop');
  }

  /// 执行带降级的操作
  Future<T> executeWithFallback<T>({
    required String operationId,
    required String category,
    required Future<T> Function() primaryOperation,
    required Future<T> Function() fallbackOperation,
    RetryConfig? customConfig,
    Map<String, dynamic>? context,
  }) async {
    try {
      return await executeWithRetry(
        operationId: operationId,
        category: category,
        operation: primaryOperation,
        customConfig: customConfig,
        context: context,
      );
    } catch (error) {
      // 主操作失败，尝试降级操作
      try {
        _recoveryController.add(
          RecoveryEvent(
            operationId: operationId,
            category: category,
            attempt: 0,
            error: error,
            delay: Duration.zero,
            isRetryable: false,
            isFallback: true,
            timestamp: DateTime.now(),
          ),
        );

        return await executeWithRetry(
          operationId: '${operationId}_fallback',
          category: category,
          operation: fallbackOperation,
          customConfig: customConfig,
          context: {...?context, 'is_fallback': true},
        );
      } catch (fallbackError) {
        _recordRecoveryFailure(operationId, category, 0, fallbackError, {
          ...?context,
          'fallback_failed': true,
        });
        rethrow;
      }
    }
  }

  /// 执行带熔断的操作
  Future<T> executeWithCircuitBreaker<T>({
    required String operationId,
    required String category,
    required Future<T> Function() operation,
    CircuitBreakerConfig? circuitConfig,
    Map<String, dynamic>? context,
  }) async {
    final config = circuitConfig ?? CircuitBreakerConfig.defaultConfig();
    final breaker = _getCircuitBreaker(operationId, config);

    if (breaker.isOpen) {
      throw CircuitBreakerOpenException(
        'Circuit breaker is open for operation: $operationId',
        operationId: operationId,
        openedAt: breaker.openedAt,
      );
    }

    try {
      final result = await operation();
      breaker.recordSuccess();
      return result;
    } catch (error) {
      breaker.recordFailure();
      rethrow;
    }
  }

  /// 执行带超时的操作
  Future<T> executeWithTimeout<T>({
    required String operationId,
    required String category,
    required Future<T> Function() operation,
    Duration? timeout,
    Map<String, dynamic>? context,
  }) async {
    final timeoutDuration = timeout ?? const Duration(seconds: 30);

    try {
      return await operation().timeout(timeoutDuration);
    } catch (error) {
      if (error is TimeoutException) {
        _recoveryController.add(
          RecoveryEvent(
            operationId: operationId,
            category: category,
            attempt: 0,
            error: error,
            delay: Duration.zero,
            isRetryable: true,
            isTimeout: true,
            timestamp: DateTime.now(),
          ),
        );
      }
      rethrow;
    }
  }

  /// 获取恢复历史
  List<RecoveryAttempt> getRecoveryHistory(String operationId) {
    return _recoveryHistory[operationId] ?? [];
  }

  /// 获取所有恢复历史
  Map<String, List<RecoveryAttempt>> getAllRecoveryHistory() {
    return Map.unmodifiable(_recoveryHistory);
  }

  /// 清理恢复历史
  void cleanupHistory({Duration? olderThan}) {
    final cutoff = olderThan ?? const Duration(hours: 24);
    final cutoffTime = DateTime.now().subtract(cutoff);

    for (final operationId in _recoveryHistory.keys) {
      _recoveryHistory[operationId]!.removeWhere(
        (attempt) => attempt.timestamp.isBefore(cutoffTime),
      );
    }
  }

  /// 重置所有状态
  void reset() {
    _recoveryHistory.clear();
    _circuitBreakers.clear();
  }

  bool _isRetryableError(dynamic error, RetryConfig config) {
    if (config.retryableErrors.isEmpty) return false;

    return config.retryableErrors.any((type) => error.runtimeType == type);
  }

  Duration _calculateDelay(int attempt, RetryConfig config) {
    final delay = config.baseDelay * (config.backoffMultiplier * (attempt - 1));

    return delay > config.maxDelay ? config.maxDelay : delay;
  }

  void _recordRecoveryAttempt(
    String operationId,
    String category,
    int attempt,
    dynamic error,
    StackTrace stackTrace,
    Map<String, dynamic>? context,
  ) {
    final recoveryAttempt = RecoveryAttempt(
      operationId: operationId,
      category: category,
      attempt: attempt,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      context: context ?? {},
    );

    _recoveryHistory.putIfAbsent(operationId, () => []).add(recoveryAttempt);

    // 记录性能指标
    PerformanceMetrics().recordMetric(
      operation: operationId,
      category: 'error_recovery',
      duration: Duration.zero,
      metadata: {
        'attempt': attempt,
        'error_type': error.runtimeType.toString(),
        'category': category,
      },
      error: error.toString(),
    );
  }

  void _recordRecoverySuccess(
    String operationId,
    String category,
    int attempts,
    DateTime startTime,
    Map<String, dynamic>? context,
  ) {
    final duration = DateTime.now().difference(startTime);

    PerformanceMetrics().recordMetric(
      operation: operationId,
      category: 'error_recovery_success',
      duration: duration,
      metadata: {
        'attempts': attempts,
        'category': category,
        'context': context ?? {},
      },
    );
  }

  void _recordRecoveryFailure(
    String operationId,
    String category,
    int attempts,
    dynamic error,
    Map<String, dynamic>? context,
  ) {
    PerformanceMetrics().recordMetric(
      operation: operationId,
      category: 'error_recovery_failure',
      duration: Duration.zero,
      metadata: {
        'attempts': attempts,
        'category': category,
        'context': context ?? {},
      },
      error: error.toString(),
    );
  }

  final Map<String, CircuitBreaker> _circuitBreakers = {};

  CircuitBreaker _getCircuitBreaker(
    String operationId,
    CircuitBreakerConfig config,
  ) {
    return _circuitBreakers.putIfAbsent(
      operationId,
      () => CircuitBreaker(config),
    );
  }

  void dispose() {
    _recoveryController.close();
  }
}

/// 重试配置类
class RetryConfig {
  final int maxAttempts;
  final Duration baseDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final List<Type> retryableErrors;
  final bool requiresReauth;

  const RetryConfig({
    required this.maxAttempts,
    required this.baseDelay,
    required this.maxDelay,
    required this.backoffMultiplier,
    required this.retryableErrors,
    this.requiresReauth = false,
  });

  factory RetryConfig.defaultConfig() {
    return const RetryConfig(
      maxAttempts: 3,
      baseDelay: Duration(seconds: 1),
      maxDelay: Duration(seconds: 30),
      backoffMultiplier: 2.0,
      retryableErrors: [TimeoutException, SocketException],
    );
  }
}

/// 熔断器配置类
class CircuitBreakerConfig {
  final int failureThreshold;
  final Duration timeout;
  final Duration resetTimeout;

  const CircuitBreakerConfig({
    required this.failureThreshold,
    required this.timeout,
    required this.resetTimeout,
  });

  factory CircuitBreakerConfig.defaultConfig() {
    return const CircuitBreakerConfig(
      failureThreshold: 5,
      timeout: Duration(seconds: 60),
      resetTimeout: Duration(seconds: 30),
    );
  }
}

/// 熔断器类
class CircuitBreaker {
  final CircuitBreakerConfig config;
  int _failureCount = 0;
  int _successCount = 0;
  DateTime? _openedAt;

  CircuitBreaker(this.config);

  bool get isOpen =>
      _openedAt != null &&
      DateTime.now().difference(_openedAt!) < config.resetTimeout;

  DateTime? get openedAt => _openedAt;

  void recordSuccess() {
    _successCount++;
    if (_successCount >= config.failureThreshold) {
      _reset();
    }
  }

  void recordFailure() {
    _failureCount++;

    if (_failureCount >= config.failureThreshold) {
      _openedAt = DateTime.now();
    }
  }

  void _reset() {
    _failureCount = 0;
    _successCount = 0;
    _openedAt = null;
  }
}

/// 恢复尝试记录类
class RecoveryAttempt {
  final String operationId;
  final String category;
  final int attempt;
  final dynamic error;
  final StackTrace stackTrace;
  final DateTime timestamp;
  final Map<String, dynamic> context;

  const RecoveryAttempt({
    required this.operationId,
    required this.category,
    required this.attempt,
    required this.error,
    required this.stackTrace,
    required this.timestamp,
    required this.context,
  });
}

/// 恢复事件类
class RecoveryEvent {
  final String operationId;
  final String category;
  final int attempt;
  final dynamic error;
  final Duration delay;
  final bool isRetryable;
  final bool isFallback;
  final bool isTimeout;
  final DateTime timestamp;

  const RecoveryEvent({
    required this.operationId,
    required this.category,
    required this.attempt,
    required this.error,
    required this.delay,
    required this.isRetryable,
    this.isFallback = false,
    this.isTimeout = false,
    required this.timestamp,
  });
}

/// 熔断器打开异常类
class CircuitBreakerOpenException implements Exception {
  final String message;
  final String operationId;
  final DateTime? openedAt;

  const CircuitBreakerOpenException(
    this.message, {
    required this.operationId,
    this.openedAt,
  });

  @override
  String toString() => 'CircuitBreakerOpenException: $message';
}
