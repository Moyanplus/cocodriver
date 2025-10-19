import 'log_manager.dart';
import 'log_category.dart';

/// 日志系统测试类
/// 用于测试日志系统的各种功能
class LoggingTest {
  static final LogManager _logManager = LogManager();

  /// 运行所有日志测试
  static Future<void> runAllTests() async {
    print('开始日志系统测试...');

    await _testBasicLogging();
    await _testCategoryLogging();
    await _testErrorLogging();
    await _testPerformanceLogging();
    await _testCloudDriveLogging();
    await _testLogStatistics();

    print('日志系统测试完成！');
  }

  /// 测试基础日志功能
  static Future<void> _testBasicLogging() async {
    print('测试基础日志功能...');

    _logManager.debug('这是一条调试日志');
    _logManager.info('这是一条信息日志');
    _logManager.warning('这是一条警告日志');
    _logManager.error('这是一条错误日志');

    await Future.delayed(Duration(milliseconds: 100));
  }

  /// 测试分类日志功能
  static Future<void> _testCategoryLogging() async {
    print('测试分类日志功能...');

    _logManager.network('网络请求测试');
    _logManager.fileOperation('文件操作测试');
    _logManager.userAction('用户行为测试');
    _logManager.performance('性能监控测试');
    _logManager.cloudDrive('云盘服务测试');

    await Future.delayed(Duration(milliseconds: 100));
  }

  /// 测试错误日志功能
  static Future<void> _testErrorLogging() async {
    print('测试错误日志功能...');

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
    print('测试性能日志功能...');

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
    print('测试云盘日志功能...');

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
    print('测试日志统计功能...');

    try {
      final stats = await _logManager.getLogStatistics();
      print('日志统计结果: $stats');

      final allLogs = await _logManager.getAllLogs();
      print('总日志数量: ${allLogs.length}');

      final cloudDriveLogs = await _logManager.getLogsByCategory(
        LogCategory.cloudDrive,
      );
      print('云盘日志数量: ${cloudDriveLogs.length}');
    } catch (e) {
      print('获取日志统计失败: $e');
    }

    await Future.delayed(Duration(milliseconds: 100));
  }

  /// 测试日志导出功能
  static Future<void> testLogExport() async {
    print('测试日志导出功能...');

    try {
      final exportPath = await _logManager.exportLogs();
      if (exportPath != null) {
        print('日志导出成功: $exportPath');
      } else {
        print('日志导出失败');
      }
    } catch (e) {
      print('日志导出异常: $e');
    }
  }

  /// 测试日志清理功能
  static Future<void> testLogClear() async {
    print('测试日志清理功能...');

    try {
      await _logManager.clearLogs();
      print('日志清理成功');
    } catch (e) {
      print('日志清理失败: $e');
    }
  }
}
