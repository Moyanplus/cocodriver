import '../../../../../core/logging/log_manager.dart';
import '../services/lanzou/models/lanzou_result.dart';
import '../services/lanzou/exceptions/lanzou_exceptions.dart';

/// 云盘错误工具类，负责将底层异常转换为用户可读的信息。
class CloudDriveErrorUtils {
  CloudDriveErrorUtils._();

  static String format(dynamic error) {
    if (error is LanzouFailure) return error.message;
    if (error is LanzouApiException) return error.message;
    final message = error?.toString() ?? '未知错误';
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }
}
