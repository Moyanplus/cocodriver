import '../../../../../core/logging/log_manager.dart';

/// 中国移动云盘日志工具类
///
/// 提供统一的日志记录方法，包括操作开始、成功、失败、网络请求等。
class ChinaMobileLogger {
  /// 记录操作开始
  static void operationStart(String operation, {Map<String, dynamic>? params}) {
    LogManager().cloudDrive(
      '中国移动云盘 - $operation 开始',
      className: 'ChinaMobileLogger',
      methodName: 'operationStart',
      data: {'operation': operation, 'params': params ?? {}},
    );
  }

  /// 记录操作成功
  static void success(String message, {Map<String, dynamic>? data}) {
    LogManager().cloudDrive(
      '中国移动云盘 - $message',
      className: 'ChinaMobileLogger',
      methodName: 'success',
      data: data ?? {},
    );
  }

  /// 记录警告
  static void warning(String message, {Map<String, dynamic>? data}) {
    LogManager().cloudDrive(
      '中国移动云盘 - 警告: $message',
      className: 'ChinaMobileLogger',
      methodName: 'warning',
      data: data ?? {},
    );
  }

  /// 记录错误
  static void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    LogManager().error(
      '中国移动云盘 - $message',
      className: 'ChinaMobileLogger',
      methodName: 'error',
      data: data ?? {},
      exception: error,
      stackTrace: stackTrace,
    );
  }

  /// 记录调试信息
  static void debug(String message, {Map<String, dynamic>? data}) {
    LogManager().cloudDrive(
      '中国移动云盘 - 调试: $message',
      className: 'ChinaMobileLogger',
      methodName: 'debug',
      data: data ?? {},
    );
  }

  /// 记录网络请求
  static void network(
    String method, {
    String? url,
    Map<String, dynamic>? data,
  }) {
    LogManager().cloudDrive(
      '中国移动云盘 - $method 请求: $url',
      className: 'ChinaMobileLogger',
      methodName: 'network',
      data: {'method': method, 'url': url, 'data': data},
    );
  }

  /// 记录详细的网络请求信息（包括请求头）
  static void networkVerbose({
    required String method,
    String? url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? data,
  }) {
    LogManager().cloudDrive(
      '中国移动云盘 - $method 请求: $url',
      className: 'ChinaMobileLogger',
      methodName: 'networkVerbose',
      data: {
        'method': method,
        'url': url,
        'headers': headers,
        'data': data,
      },
    );
  }

  /// 记录性能指标
  static void performance(String message, {Duration? duration}) {
    LogManager().cloudDrive(
      '中国移动云盘 - 性能: $message${duration != null ? ' (耗时: ${duration.inMilliseconds}ms)' : ''}',
      className: 'ChinaMobileLogger',
      methodName: 'performance',
      data: duration != null ? {'duration': duration.inMilliseconds} : {},
    );
  }

  /// 记录任务信息
  static void task(String message, {String? taskId}) {
    LogManager().cloudDrive(
      '中国移动云盘 - 任务: $message${taskId != null ? ' (任务ID: $taskId)' : ''}',
      className: 'ChinaMobileLogger',
      methodName: 'task',
      data: taskId != null ? {'taskId': taskId} : {},
    );
  }
}
