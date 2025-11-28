import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';

/// 统一的云盘服务基础类，仅保留日志与类型信息。
///
/// 原 `cloud_drive_service_factory.dart` 已移除，避免旧依赖，这里只提供轻量日志能力。
abstract class CloudDriveServiceBase {
  CloudDriveServiceBase(this.type);

  final CloudDriveType type;

  /// 记录操作日志
  void logOperation(String operation, {Map<String, dynamic>? params}) {
    LogManager().cloudDrive('$serviceName - $operation');
    if (params != null) {
      for (final entry in params.entries) {
        LogManager().cloudDrive('${entry.key}: ${entry.value}');
      }
    }
  }

  /// 记录成功日志
  void logSuccess(String operation, {String? details}) {
    final message = details != null ? '$operation: $details' : operation;
    LogManager().cloudDrive('$serviceName - $message');
  }

  /// 记录错误日志
  void logError(String operation, dynamic error) {
    LogManager().error('$serviceName - $operation 失败: $error');
  }

  /// 记录警告日志
  void logWarning(String operation, String message) {
    LogManager().warning('$serviceName - $operation: $message');
  }

  String get serviceName => runtimeType.toString();
}
