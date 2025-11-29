import 'package:flutter/foundation.dart';

/// 统一处理「乐观更新 + 回滚」的轻量工具。
///
/// 调用方式：
/// ```dart
/// await OperationGuard.run<bool>(
///   optimisticUpdate: () => ...,  // 先更新UI
///   action: () async => await doSomething(),
///   rollback: () => ...,          // 失败或异常时恢复
///   onSuccess: (result) => ...,   // 成功后的补充操作
///   rollbackWhen: (result) => !result, // 当 action 返回失败时也触发回滚
/// );
/// ```
class OperationGuard {
  const OperationGuard._();

  /// 执行包裹了乐观更新与回滚的异步操作。
  static Future<T> run<T>({
    VoidCallback? optimisticUpdate,
    required Future<T> Function() action,
    VoidCallback? rollback,
    ValueChanged<T>? onSuccess,
    bool Function(T result)? rollbackWhen,
    ValueChanged<Object>? onError,
  }) async {
    optimisticUpdate?.call();

    try {
      final result = await action();
      final shouldRollback = rollbackWhen?.call(result) ?? false;
      if (shouldRollback) {
        rollback?.call();
      } else {
        onSuccess?.call(result);
      }
      return result;
    } catch (error, stackTrace) {
      rollback?.call();
      onError?.call(error);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
