import 'log_manager.dart';
import 'log_category.dart';

/// 日志系统测试类
/// 用于测试日志系统的各种功能
class LoggingTest {
  static final LogManager _logManager = LogManager();

  /// 运行所有日志测试
  static Future<void> runAllTests() async {
    await _testBasicLogging();
    await _testCategoryLogging();
    await _testErrorLogging();
    await _testPerformanceLogging();
    await _testCloudDriveLogging();
    await _testLogStatistics();
  }

  /// 测试基础日志功能
  static Future<void> _testBasicLogging() async {
    _logManager.debug('这是一条调试日志');
    _logManager.info('这是一条信息日志');
    _logManager.warning('这是一条警告日志');
    _logManager.error('这是一条错误日志');

    await Future.delayed(Duration(milliseconds: 100));
  }

  /// 测试分类日志功能
  static Future<void> _testCategoryLogging() async {
    _logManager.network('网络请求测试');
    _logManager.fileOperation('文件操作测试');
    _logManager.userAction('用户行为测试');
    _logManager.performance('性能监控测试');
    _logManager.cloudDrive('云盘服务测试');

    await Future.delayed(Duration(milliseconds: 100));
  }

  /// 测试错误日志功能
  static Future<void> _testErrorLogging() async {
    try {
      throw Exception('测试异常');
    } catch (e, stackTrace) {
      _logManager.error(
        '捕获到测试异常',
        category: LogCategory.error,
        className: 'LoggingTest',
        methodName: '_testErrorLogging',
        exception: e,
        stackTrace: stackTrace,
      );
    }

    await Future.delayed(Duration(milliseconds: 100));
  }

  /// 测试性能日志功能
  static Future<void> _testPerformanceLogging() async {
    final stopwatch = Stopwatch()..start();

    // 模拟一些工作
    await Future.delayed(Duration(milliseconds: 50));

    stopwatch.stop();

    _logManager.performance(
      '性能测试完成',
      className: 'LoggingTest',
      methodName: '_testPerformanceLogging',
      data: {'duration': stopwatch.elapsedMilliseconds, 'operation': '模拟工作'},
    );

    await Future.delayed(Duration(milliseconds: 100));
  }

  /// 测试云盘日志功能
  static Future<void> _testCloudDriveLogging() async {
    _logManager.cloudDrive(
      '模拟云盘文件上传',
      className: 'LoggingTest',
      methodName: '_testCloudDriveLogging',
      data: {
        'fileName': 'test_file.txt',
        'fileSize': 1024,
        'cloudType': 'ali',
        'status': 'uploading',
      },
    );

    await Future.delayed(Duration(milliseconds: 100));
  }

  /// 测试日志统计功能
  static Future<void> _testLogStatistics() async {
    try {
      final stats = await _logManager.getLogStatistics();

      final allLogs = await _logManager.getAllLogs();

      final cloudDriveLogs = await _logManager.getLogsByCategory(
        LogCategory.cloudDrive,
      );
    } catch (e) {}

    await Future.delayed(Duration(milliseconds: 100));
  }

  /// 测试日志导出功能
  static Future<void> testLogExport() async {
    try {
      final exportPath = await _logManager.exportLogs();
      if (exportPath != null) {
      } else {}
    } catch (e) {}
  }

  /// 测试日志清理功能
  static Future<void> testLogClear() async {
    try {
      await _logManager.clearLogs();
    } catch (e) {}
  }
}
