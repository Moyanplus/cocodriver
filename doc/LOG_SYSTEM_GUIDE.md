# 日志系统使用指南

## 📋 概述

本项目实现了一个完整的日志管理系统，包括日志记录、查看、导出和管理功能。

## ✨ 主要特性

### 1. **优化的日志格式**
- ✅ **控制台输出**：`[10-30 17:29:00] [I] 消息内容`
- ✅ **文件保存**：`[10-30 17:29:00] [云盘服务] 消息内容`
- ✅ 移除了年份和毫秒，使日志更简洁
- ✅ 移除了 emoji 表情，避免编码问题
- ✅ 保留了中文字符，确保信息完整

### 2. **日志文件管理**
- 📁 **自动轮转**：单个文件超过 10MB 自动创建新文件
- 🗑️ **自动清理**：只保留最新 7 个日志文件
- 📅 **按日期命名**：`app_log_20251030.txt`
- 💾 **持久化存储**：保存在 `Documents/logs/` 目录

### 3. **日志查看器** 🔍

#### 访问方式
```
设置 → 高级设置 → 日志查看器
```

#### 功能列表
- ✅ **实时搜索**：支持关键词搜索
- ✅ **分类过滤**：按日志类别筛选
- ✅ **统计信息**：查看各类日志数量
- ✅ **复制功能**：单条/批量复制
- ✅ **导出分享**：导出并分享日志文件
- ✅ **清空日志**：一键清空所有日志

## 🚀 使用示例

### 1. 记录日志

```dart
import 'package:flutter_ui_template/core/logging/log_manager.dart';

final logManager = LogManager();

// 普通信息
logManager.info('用户登录成功');

// 云盘操作
logManager.cloudDrive(
  '文件上传成功',
  data: {
    'fileName': 'test.jpg',
    'size': 1024,
  },
);

// 网络请求
logManager.network(
  'API请求成功',
  data: {
    'url': 'https://api.example.com',
    'method': 'GET',
  },
);

// 错误日志
logManager.error(
  '文件下载失败',
  exception: e,
  stackTrace: stack,
);
```

### 2. 查看日志

```dart
// 获取所有日志
final logs = await logManager.getAllLogs();

// 按类别获取
final cloudLogs = await logManager.getLogsByCategory(
  LogCategory.cloudDrive,
);

// 获取统计信息
final stats = await logManager.getLogStatistics();
```

### 3. 导出日志

```dart
// 导出到文件
final filePath = await logManager.exportLogs();
if (filePath != null) {
  // 分享文件
  await Share.shareXFiles([XFile(filePath)]);
}
```

## 📂 文件结构

```
lib/core/logging/
├── log_manager.dart              # 日志管理器（主入口）
├── log_file_manager.dart         # 文件管理（轮转、清理）
├── custom_log_printer.dart       # 自定义日志打印器
├── log_category.dart             # 日志分类定义
├── log_config.dart               # 日志配置
└── log_formatter.dart            # 日志格式化

lib/tool/log_viewer/
└── pages/
    └── log_viewer_page.dart      # 日志查看器界面
```

## 🎨 日志分类

| 分类 | 说明 | 使用场景 |
|-----|------|---------|
| 🐛 Debug | 调试信息 | 开发调试 |
| 💡 Info | 一般信息 | 正常操作 |
| ⚠️ Warning | 警告 | 潜在问题 |
| ❌ Error | 错误 | 异常情况 |
| 🌐 Network | 网络请求 | API调用 |
| 📁 FileOperation | 文件操作 | 文件读写 |
| 👤 UserAction | 用户行为 | 用户交互 |
| ☁️ CloudDrive | 云盘服务 | 云盘操作 |
| ⚡ Performance | 性能 | 性能监控 |

## 📊 日志格式示例

### 优化前
```
flutter: │ #0   LogManager._log (package:coco_cloud_drive/core/logging/log_manager.dart:236:19)
flutter: │ #1   LogManager.cloudDrive (package:coco_cloud_drive/core/logging/log_manager.dart:178:5)
flutter: ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
flutter: │ 17:08:36.824 (+0:00:58.639693)
flutter: ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
flutter: │ 💡 [云盘服务] 📊 账号详情: CloudDriveAccountDetails{id: 做事果断的猫头鹰, name: 做事果断的猫头鹰, isValid: true}
```

### 优化后
```
[10-30 17:29:00] [I] [云盘服务] 账号详情: CloudDriveAccountDetails{id: 做事果断的猫头鹰, name: 做事果断的猫头鹰, isValid: true}
```

## 🔧 配置说明

### 日志文件配置
```dart
// lib/core/logging/log_file_manager.dart

/// 最大日志文件大小（10MB）
static const int maxFileSize = 10 * 1024 * 1024;

/// 保留的日志文件数量
static const int maxLogFiles = 7;
```

### 日志级别配置
```dart
// lib/core/logging/log_config.dart

// 可以配置是否启用控制台日志
final isConsoleLoggingEnabled = true;

// 可以配置是否启用文件日志
final isFileLoggingEnabled = true;
```

## 💡 最佳实践

### 1. 合理使用日志级别
```dart
// ✅ 好的做法
logManager.debug('正在处理数据...');  // 开发时使用
logManager.info('文件上传成功');      // 正常操作
logManager.warning('磁盘空间不足');   // 警告
logManager.error('网络请求失败', exception: e);  // 错误

// ❌ 避免的做法
logManager.error('用户点击按钮');  // 不应该用 error
logManager.debug('系统崩溃');      // 应该用 error
```

### 2. 添加上下文信息
```dart
// ✅ 好的做法
logManager.cloudDrive(
  '文件下载失败',
  data: {
    'fileName': 'test.jpg',
    'fileId': 'abc123',
    'accountId': '12345',
    'errorCode': 404,
  },
);

// ❌ 避免的做法
logManager.cloudDrive('下载失败');  // 缺少上下文
```

### 3. 定期清理日志
```dart
// 在适当的时机清理日志
await logManager.clearLogs();
```

## 🐛 问题排查

### 问题1：日志文件编码错误
**解决方案**：已实现自动编码清理，如遇到问题：
1. 进入日志查看器
2. 点击"清空日志"
3. 重新生成日志

### 问题2：日志文件过大
**解决方案**：
- 系统会自动轮转，超过10MB自动创建新文件
- 只保留最新7个文件
- 可手动清空日志

### 问题3：无法导出日志
**解决方案**：
1. 检查存储权限
2. 确保有足够的存储空间
3. 使用日志查看器的"分享"功能

## 📝 更新日志

### v1.0.0 (2025-10-30)
- ✅ 优化日志格式（移除年份和毫秒）
- ✅ 移除 emoji 表情，解决编码问题
- ✅ 实现日志文件自动轮转
- ✅ 添加日志查看器界面
- ✅ 支持日志搜索和过滤
- ✅ 支持日志导出和分享
- ✅ 自动清理旧日志文件

## 🔗 相关链接

- [Logger 文档](https://pub.dev/packages/logger)
- [项目结构说明](PROJECT_STRUCTURE.md)

---

**提示**：如需修改日志格式，请编辑 `lib/core/logging/custom_log_printer.dart` 文件。

