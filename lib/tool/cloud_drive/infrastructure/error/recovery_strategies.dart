import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'error_recovery_manager.dart';

/// 错误恢复策略
class RecoveryStrategies {
  static final ErrorRecoveryManager _recoveryManager = ErrorRecoveryManager();

  /// 网络操作恢复策略
  static Future<T> networkOperation<T>({
    required String operationId,
    required Future<T> Function() operation,
    Map<String, dynamic>? context,
  }) async {
    return await _recoveryManager.executeWithRetry(
      operationId: operationId,
      category: 'network_error',
      operation: operation,
      context: context,
    );
  }

  /// API调用恢复策略
  static Future<T> apiCall<T>({
    required String operationId,
    required Future<T> Function() operation,
    Map<String, dynamic>? context,
  }) async {
    return await _recoveryManager.executeWithRetry(
      operationId: operationId,
      category: 'api_error',
      operation: operation,
      context: context,
    );
  }

  /// 文件操作恢复策略
  static Future<T> fileOperation<T>({
    required String operationId,
    required Future<T> Function() operation,
    Map<String, dynamic>? context,
  }) async {
    return await _recoveryManager.executeWithRetry(
      operationId: operationId,
      category: 'file_operation',
      operation: operation,
      context: context,
    );
  }

  /// 认证操作恢复策略
  static Future<T> authentication<T>({
    required String operationId,
    required Future<T> Function() operation,
    Map<String, dynamic>? context,
  }) async {
    return await _recoveryManager.executeWithRetry(
      operationId: operationId,
      category: 'authentication_error',
      operation: operation,
      context: context,
    );
  }

  /// 带降级的网络操作
  static Future<T> networkOperationWithFallback<T>({
    required String operationId,
    required Future<T> Function() primaryOperation,
    required Future<T> Function() fallbackOperation,
    Map<String, dynamic>? context,
  }) async {
    return await _recoveryManager.executeWithFallback(
      operationId: operationId,
      category: 'network_error',
      primaryOperation: primaryOperation,
      fallbackOperation: fallbackOperation,
      context: context,
    );
  }

  /// 带熔断的操作
  static Future<T> operationWithCircuitBreaker<T>({
    required String operationId,
    required String category,
    required Future<T> Function() operation,
    CircuitBreakerConfig? circuitConfig,
    Map<String, dynamic>? context,
  }) async {
    return await _recoveryManager.executeWithCircuitBreaker(
      operationId: operationId,
      category: category,
      operation: operation,
      circuitConfig: circuitConfig,
      context: context,
    );
  }

  /// 带超时的操作
  static Future<T> operationWithTimeout<T>({
    required String operationId,
    required String category,
    required Future<T> Function() operation,
    Duration? timeout,
    Map<String, dynamic>? context,
  }) async {
    return await _recoveryManager.executeWithTimeout(
      operationId: operationId,
      category: category,
      operation: operation,
      timeout: timeout,
      context: context,
    );
  }

  /// 智能重试策略 - 根据错误类型自动选择策略
  static Future<T> smartRetry<T>({
    required String operationId,
    required Future<T> Function() operation,
    Map<String, dynamic>? context,
  }) async {
    try {
      return await operation();
    } catch (error) {
      // 根据错误类型选择不同的恢复策略
      if (error is SocketException || error is TimeoutException) {
        return await networkOperation(
          operationId: operationId,
          operation: operation,
          context: context,
        );
      } else if (error is HttpException) {
        return await apiCall(
          operationId: operationId,
          operation: operation,
          context: context,
        );
      } else if (error is FileSystemException) {
        return await fileOperation(
          operationId: operationId,
          operation: operation,
          context: context,
        );
      } else {
        // 默认重试策略
        return await _recoveryManager.executeWithRetry(
          operationId: operationId,
          category: 'default',
          operation: operation,
          context: context,
        );
      }
    }
  }

  /// 批量操作恢复策略
  static Future<List<T>> batchOperation<T>({
    required String operationId,
    required List<Future<T> Function()> operations,
    int? maxConcurrency,
    Map<String, dynamic>? context,
  }) async {
    final results = <T>[];
    final errors = <Exception>[];

    // 限制并发数
    final concurrency = maxConcurrency ?? 3;
    final semaphore = Semaphore(concurrency);

    final futures = operations.asMap().entries.map((entry) async {
      final index = entry.key;
      final operation = entry.value;

      await semaphore.acquire();
      try {
        final result = await smartRetry(
          operationId: '${operationId}_batch_$index',
          operation: operation,
          context: {...?context, 'batch_index': index},
        );
        results.add(result);
      } catch (error) {
        errors.add(error is Exception ? error : Exception(error.toString()));
      } finally {
        semaphore.release();
      }
    });

    await Future.wait(futures);

    if (errors.isNotEmpty && results.isEmpty) {
      throw BatchOperationException(
        'All batch operations failed',
        errors: errors,
      );
    }

    return results;
  }

  /// 指数退避重试
  static Future<T> exponentialBackoff<T>({
    required String operationId,
    required Future<T> Function() operation,
    int maxAttempts = 5,
    Duration initialDelay = const Duration(seconds: 1),
    double multiplier = 2.0,
    Duration maxDelay = const Duration(seconds: 60),
    Map<String, dynamic>? context,
  }) async {
    final config = RetryConfig(
      maxAttempts: maxAttempts,
      baseDelay: initialDelay,
      maxDelay: maxDelay,
      backoffMultiplier: multiplier,
      retryableErrors: [Exception],
    );

    return await _recoveryManager.executeWithRetry(
      operationId: operationId,
      category: 'exponential_backoff',
      operation: operation,
      customConfig: config,
      context: context,
    );
  }

  /// 固定延迟重试
  static Future<T> fixedDelayRetry<T>({
    required String operationId,
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 2),
    Map<String, dynamic>? context,
  }) async {
    final config = RetryConfig(
      maxAttempts: maxAttempts,
      baseDelay: delay,
      maxDelay: delay,
      backoffMultiplier: 1.0,
      retryableErrors: [Exception],
    );

    return await _recoveryManager.executeWithRetry(
      operationId: operationId,
      category: 'fixed_delay_retry',
      operation: operation,
      customConfig: config,
      context: context,
    );
  }

  /// 随机延迟重试（避免惊群效应）
  static Future<T> jitteredRetry<T>({
    required String operationId,
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration baseDelay = const Duration(seconds: 1),
    double jitterFactor = 0.1,
    Map<String, dynamic>? context,
  }) async {
    final config = RetryConfig(
      maxAttempts: maxAttempts,
      baseDelay: baseDelay,
      maxDelay: const Duration(seconds: 30),
      backoffMultiplier: 2.0,
      retryableErrors: [Exception],
    );

    return await _recoveryManager.executeWithRetry(
      operationId: operationId,
      category: 'jittered_retry',
      operation: operation,
      customConfig: config,
      context: context,
    );
  }
}

/// 信号量 - 用于控制并发数
class Semaphore {
  final int maxCount;
  int _currentCount;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Semaphore(this.maxCount) : _currentCount = maxCount;

  Future<void> acquire() async {
    if (_currentCount > 0) {
      _currentCount--;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _currentCount++;
    }
  }
}

/// 批量操作异常
class BatchOperationException implements Exception {
  final String message;
  final List<Exception> errors;

  const BatchOperationException(this.message, {required this.errors});

  @override
  String toString() =>
      'BatchOperationException: $message\nErrors: ${errors.length}';
}
