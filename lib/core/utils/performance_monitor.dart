import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// 性能监控器
/// 监控应用性能指标，包括帧率、渲染时间等
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final List<double> _frameTimes = [];
  final List<Duration> _renderTimes = [];
  bool _isMonitoring = false;
  int _frameCount = 0;
  DateTime? _lastFrameTime;
  static const int _maxSamples = 60; // 保留最近60帧的数据

  /// 开始性能监控
  void startMonitoring() {
    if (kDebugMode && !_isMonitoring) {
      _isMonitoring = true;
      _frameCount = 0;
      _lastFrameTime = DateTime.now();

      // 监听帧回调
      SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);

      developer.log('性能监控已启动');
    }
  }

  /// 停止性能监控
  void stopMonitoring() {
    if (_isMonitoring) {
      _isMonitoring = false;
      // 注意：Flutter没有removePersistentFrameCallback方法
      // 我们通过_isMonitoring标志来控制
      developer.log('性能监控已停止');
    }
  }

  /// 帧回调处理
  void _onFrame(Duration timeStamp) {
    if (!_isMonitoring) return;

    final now = DateTime.now();
    _frameCount++;

    // 计算帧时间
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!);
      _frameTimes.add(frameTime.inMicroseconds / 1000.0); // 转换为毫秒

      // 保持样本数量在限制范围内
      if (_frameTimes.length > _maxSamples) {
        _frameTimes.removeAt(0);
      }
    }

    _lastFrameTime = now;

    // 每60帧输出一次性能报告
    if (_frameCount % 60 == 0) {
      _logPerformanceReport();
    }
  }

  /// 记录渲染时间
  void recordRenderTime(Duration renderTime) {
    if (kDebugMode) {
      _renderTimes.add(renderTime);

      // 保持样本数量在限制范围内
      if (_renderTimes.length > _maxSamples) {
        _renderTimes.removeAt(0);
      }
    }
  }

  /// 输出性能报告
  void _logPerformanceReport() {
    if (_frameTimes.isEmpty) return;

    final avgFrameTime =
        _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    final maxFrameTime = _frameTimes.reduce((a, b) => a > b ? a : b);
    final minFrameTime = _frameTimes.reduce((a, b) => a < b ? a : b);
    final fps = 1000.0 / avgFrameTime;

    developer.log('''
性能报告:
  平均帧时间: ${avgFrameTime.toStringAsFixed(2)}ms
  最大帧时间: ${maxFrameTime.toStringAsFixed(2)}ms
  最小帧时间: ${minFrameTime.toStringAsFixed(2)}ms
  平均FPS: ${fps.toStringAsFixed(1)}
  帧数: $_frameCount
''');

    // 性能警告
    if (avgFrameTime > 16.67) {
      // 60fps = 16.67ms per frame
      developer.log('⚠️ 性能警告: 平均帧时间超过16.67ms，可能影响流畅度');
    }
  }

  /// 获取性能统计信息
  Map<String, dynamic> getPerformanceStats() {
    if (_frameTimes.isEmpty) {
      return {
        'isMonitoring': _isMonitoring,
        'frameCount': _frameCount,
        'hasData': false,
      };
    }

    final avgFrameTime =
        _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    final maxFrameTime = _frameTimes.reduce((a, b) => a > b ? a : b);
    final minFrameTime = _frameTimes.reduce((a, b) => a < b ? a : b);
    final fps = 1000.0 / avgFrameTime;

    return {
      'isMonitoring': _isMonitoring,
      'frameCount': _frameCount,
      'hasData': true,
      'avgFrameTime': avgFrameTime,
      'maxFrameTime': maxFrameTime,
      'minFrameTime': minFrameTime,
      'fps': fps,
      'sampleCount': _frameTimes.length,
      'isGoodPerformance': avgFrameTime <= 16.67,
    };
  }

  /// 获取渲染时间统计
  Map<String, dynamic> getRenderTimeStats() {
    if (_renderTimes.isEmpty) {
      return {'hasData': false, 'sampleCount': 0};
    }

    final avgRenderTime =
        _renderTimes.reduce((a, b) => a + b).inMicroseconds /
        _renderTimes.length /
        1000.0;
    final maxRenderTime =
        _renderTimes.reduce((a, b) => a > b ? a : b).inMicroseconds / 1000.0;
    final minRenderTime =
        _renderTimes.reduce((a, b) => a < b ? a : b).inMicroseconds / 1000.0;

    return {
      'hasData': true,
      'sampleCount': _renderTimes.length,
      'avgRenderTime': avgRenderTime,
      'maxRenderTime': maxRenderTime,
      'minRenderTime': minRenderTime,
      'isGoodRenderPerformance': avgRenderTime <= 8.0, // 8ms以下为良好
    };
  }

  /// 重置统计数据
  void resetStats() {
    _frameTimes.clear();
    _renderTimes.clear();
    _frameCount = 0;
    _lastFrameTime = null;
    developer.log('性能统计数据已重置');
  }

  /// 销毁性能监控器
  void dispose() {
    stopMonitoring();
    resetStats();
  }
}
