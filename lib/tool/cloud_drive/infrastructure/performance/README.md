# 性能优化模块

本模块提供了全面的性能优化功能，包括大文件处理、内存优化、性能监控等。

## 功能特性

### 1. 大文件处理器 (LargeFileProcessor)
- **分块上传**: 将大文件分割成小块并行上传
- **分块下载**: 支持断点续传和并行下载
- **重试机制**: 自动重试失败的分块
- **进度回调**: 实时显示上传/下载进度

### 2. 性能监控器 (PerformanceMonitor)
- **操作计时**: 自动监控操作执行时间
- **性能指标**: 统计平均耗时、成功率等
- **性能报告**: 生成详细的性能分析报告
- **历史记录**: 保存性能数据历史

### 3. 内存优化器 (MemoryOptimizer)
- **内存监控**: 实时监控内存使用情况
- **压力检测**: 自动检测内存压力级别
- **流式处理**: 优化大文件的内存使用
- **隔离处理**: 在独立隔离中处理大文件

### 4. 性能优化器 (PerformanceOptimizer)
- **综合管理**: 统一管理所有性能优化功能
- **自动优化**: 定期执行性能优化
- **智能建议**: 基于性能数据提供优化建议
- **一键应用**: 快速应用优化建议

## 使用方法

### 基本使用

```dart
import 'package:cloud_drive/infrastructure/performance/performance_optimizer.dart';

// 初始化性能优化器
final optimizer = PerformanceOptimizer();
await optimizer.initialize();

// 监控操作
final timer = optimizer.startOperation('upload_file');
try {
  // 执行操作
  await uploadFile();
  optimizer.completeOperation(timer);
} catch (e) {
  optimizer.recordError('upload_file', e);
}
```

### 大文件处理

```dart
// 分块上传大文件
final processor = optimizer.getLargeFileProcessor();
final result = await processor.uploadLargeFile(
  filePath: '/path/to/large/file.zip',
  uploadUrl: 'https://api.example.com/upload',
  account: cloudDriveAccount,
  fileName: 'large_file.zip',
  onProgress: (received, total) {
    print('上传进度: ${(received / total * 100).toStringAsFixed(1)}%');
  },
);

// 分块下载大文件
final downloadResult = await processor.downloadLargeFile(
  downloadUrl: 'https://api.example.com/download/file.zip',
  savePath: '/path/to/save/file.zip',
  account: cloudDriveAccount,
  fileName: 'large_file.zip',
  onProgress: (received, total) {
    print('下载进度: ${(received / total * 100).toStringAsFixed(1)}%');
  },
);
```

### 内存优化

```dart
// 流式处理大文件
await optimizer.processLargeFile(
  filePath: '/path/to/large/file.zip',
  processor: (stream) async {
    // 处理文件流
    await for (final chunk in stream) {
      // 处理每个数据块
      processChunk(chunk);
    }
  },
);

// 在隔离中处理大文件
final result = await optimizer.processLargeFileInIsolate(
  filePath: '/path/to/large/file.zip',
  processor: (bytes) {
    // 在隔离中处理文件数据
    return processFileData(bytes);
  },
);
```

### 性能监控

```dart
// 获取性能报告
final report = optimizer.getPerformanceReport();
print('成功率: ${report.successRate.toStringAsFixed(1)}%');
print('平均耗时: ${report.averageDuration.inMilliseconds}ms');

// 获取内存使用情况
final memoryUsage = optimizer.getMemoryUsage();
print('内存使用: ${memoryUsage.usedMB.toStringAsFixed(1)}MB / ${memoryUsage.totalMB.toStringAsFixed(1)}MB');

// 获取优化建议
final suggestions = optimizer.getOptimizationSuggestions();
for (final suggestion in suggestions) {
  print('建议: ${suggestion.title} - ${suggestion.description}');
  if (suggestion.priority == SuggestionPriority.high) {
    await optimizer.applyOptimization(suggestion);
  }
}
```

## 配置选项

### 大文件处理器配置

```dart
final processor = LargeFileProcessor(
  chunkSize: 2 * 1024 * 1024, // 2MB 分块大小
  maxConcurrentChunks: 5,      // 最大并发分块数
  retryAttempts: 5,            // 重试次数
  retryDelay: Duration(seconds: 3), // 重试延迟
);
```

### 内存优化器配置

```dart
final memoryOptimizer = MemoryOptimizer();
memoryOptimizer.startMonitoring(
  interval: Duration(seconds: 10), // 监控间隔
);
```

## 性能指标

### 关键指标
- **响应时间**: 操作的平均响应时间
- **成功率**: 操作的成功率百分比
- **内存使用**: 当前内存使用情况
- **并发数**: 同时处理的操作数量

### 性能阈值
- **响应时间**: 正常 < 3秒，警告 > 5秒
- **成功率**: 正常 > 95%，警告 < 90%
- **内存使用**: 正常 < 75%，警告 > 90%

## 最佳实践

### 1. 大文件处理
- 使用分块上传/下载处理大文件
- 设置合适的分块大小（1-2MB）
- 启用进度回调提升用户体验
- 使用重试机制处理网络异常

### 2. 内存优化
- 使用流式处理避免内存溢出
- 定期检查内存压力
- 在隔离中处理大文件
- 及时释放不需要的资源

### 3. 性能监控
- 监控关键操作的性能
- 定期分析性能报告
- 根据建议优化性能
- 设置合理的性能阈值

### 4. 错误处理
- 记录所有操作错误
- 分析错误模式
- 实现自动重试机制
- 提供用户友好的错误信息

## 故障排除

### 常见问题

1. **内存不足**
   - 减少分块大小
   - 使用流式处理
   - 在隔离中处理大文件

2. **上传/下载失败**
   - 检查网络连接
   - 增加重试次数
   - 调整超时时间

3. **性能下降**
   - 查看性能报告
   - 应用优化建议
   - 调整并发数

### 调试技巧

1. **启用详细日志**
   ```dart
   LogManager().setLevel(LogLevel.debug);
   ```

2. **监控内存使用**
   ```dart
   final memoryUsage = optimizer.getMemoryUsage();
   print('内存使用: $memoryUsage');
   ```

3. **分析性能数据**
   ```dart
   final report = optimizer.getPerformanceReport();
   print(report.detailedReport);
   ```

## 扩展功能

### 自定义优化策略
```dart
class CustomOptimizer extends PerformanceOptimizer {
  @override
  Future<void> _optimizeCache() async {
    // 实现自定义缓存优化逻辑
  }
}
```

### 自定义性能指标
```dart
class CustomPerformanceMetric extends PerformanceMetric {
  // 添加自定义性能指标
}
```

## 相关资源

- [Flutter性能优化指南](https://docs.flutter.dev/perf)
- [Dart内存管理](https://dart.dev/guides/language/effective-dart/usage)
- [网络请求优化](https://pub.dev/packages/dio)
