import '../../../../../core/logging/log_manager.dart';

abstract class CloudDriveLoggerAdapter {
  void info(String message);
  void warning(String message);
  void error(String message);
}

class DefaultCloudDriveLoggerAdapter implements CloudDriveLoggerAdapter {
  final LogManager _logManager = LogManager();

  @override
  void info(String message) {
    _logManager.cloudDrive(message);
  }

  @override
  void warning(String message) {
    _logManager.cloudDrive(message);
  }

  @override
  void error(String message) {
    _logManager.error(message);
  }
}
