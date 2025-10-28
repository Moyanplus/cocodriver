# CloudDrive 测试文档

## 概述

本目录包含云盘模块的完整测试套件，包括单元测试、集成测试和性能测试。

## 目录结构

```
test/tool/cloud_drive/
├── unit/                          # 单元测试
│   ├── services/                  # 服务层测试
│   │   ├── cloud_drive_operation_service_test.dart
│   │   └── cloud_drive_cache_service_test.dart
│   ├── models/                    # 模型层测试
│   │   ├── result_test.dart
│   │   └── cloud_drive_state_test.dart
│   └── providers/                 # Provider测试
├── integration/                   # 集成测试
│   └── cloud_drive_integration_test.dart
├── widget/                        # Widget测试
├── test_helpers.dart              # 测试辅助工具
├── test_config.dart               # 测试配置
├── run_tests.dart                 # 测试运行器
└── README.md                      # 本文档
```

## 测试类型

### 1. 单元测试 (Unit Tests)

测试单个组件或类的功能，不依赖外部资源。

#### 服务层测试
- **CloudDriveOperationService**: 测试云盘操作服务的核心功能
- **CloudDriveCacheService**: 测试缓存服务的各种操作

#### 模型层测试
- **Result**: 测试结果包装类的各种方法
- **CloudDriveState**: 测试状态管理模型

### 2. 集成测试 (Integration Tests)

测试多个组件协同工作的场景。

- **缓存集成**: 测试缓存与业务逻辑的集成
- **错误处理集成**: 测试错误处理流程
- **批量操作集成**: 测试批量操作功能
- **性能集成**: 测试性能相关功能

### 3. 性能测试 (Performance Tests)

测试系统在各种负载下的性能表现。

- **大量数据处理**: 测试处理大量文件时的性能
- **缓存性能**: 测试缓存操作的性能
- **批量操作性能**: 测试批量操作的性能

## 运行测试

### 运行所有测试
```bash
flutter test test/tool/cloud_drive/
```

### 运行特定类型的测试
```bash
# 运行单元测试
flutter test test/tool/cloud_drive/unit/

# 运行集成测试
flutter test test/tool/cloud_drive/integration/

# 运行特定测试文件
flutter test test/tool/cloud_drive/unit/services/cloud_drive_operation_service_test.dart
```

### 运行测试并生成报告
```bash
flutter test --coverage test/tool/cloud_drive/
genhtml coverage/lcov.info -o coverage/html
```

## 测试配置

### 超时设置
- **默认超时**: 5秒
- **长时间超时**: 30秒
- **短时间超时**: 1秒

### 性能阈值
- **单次操作**: 最大1秒
- **批量操作**: 最大5秒
- **缓存操作**: 最大100毫秒

### 测试数据
- **小文件**: 1KB
- **中等文件**: 1MB
- **大文件**: 10MB

## 测试辅助工具

### TestHelpers
提供创建测试数据的静态方法：
- `createTestAccount()`: 创建测试账号
- `createTestFile()`: 创建测试文件
- `createTestFolder()`: 创建测试文件夹
- `createSuccessResult()`: 创建成功结果
- `createFailureResult()`: 创建失败结果

### TestData
提供预定义的测试数据：
- `testAccounts`: 测试账号列表
- `testFiles`: 测试文件列表
- `testFolders`: 测试文件夹列表

### TestConfig
提供测试配置常量：
- 超时时间设置
- 性能阈值
- 测试数据大小

## 测试最佳实践

### 1. 测试命名
- 使用描述性的测试名称
- 遵循 "应该...当...时" 的格式
- 使用中文描述，便于理解

### 2. 测试结构
- 使用 Arrange-Act-Assert 模式
- 每个测试只验证一个功能点
- 保持测试的独立性

### 3. 测试数据
- 使用测试辅助工具创建数据
- 避免硬编码测试数据
- 确保测试数据的真实性

### 4. 错误处理
- 测试正常流程和异常流程
- 验证错误类型和错误消息
- 测试重试和恢复机制

### 5. 性能测试
- 设置合理的性能阈值
- 测试不同规模的数据
- 监控内存使用情况

## 测试覆盖率

目标测试覆盖率：
- **行覆盖率**: ≥ 80%
- **分支覆盖率**: ≥ 70%
- **函数覆盖率**: ≥ 90%

## 持续集成

测试在以下情况下自动运行：
- 代码提交时
- 创建Pull Request时
- 每日构建时

## 故障排除

### 常见问题

1. **测试超时**
   - 检查网络连接
   - 增加超时时间
   - 优化测试逻辑

2. **测试失败**
   - 检查测试数据
   - 验证Mock设置
   - 查看错误日志

3. **性能测试失败**
   - 检查系统资源
   - 优化测试数据量
   - 调整性能阈值

### 调试技巧

1. **使用print语句**
   ```dart
   print('调试信息: $variable');
   ```

2. **使用debugger**
   ```dart
   debugger(); // 在IDE中设置断点
   ```

3. **查看测试日志**
   ```bash
   flutter test --verbose
   ```

## 贡献指南

### 添加新测试

1. 确定测试类型（单元/集成/性能）
2. 选择合适的测试文件或创建新文件
3. 使用测试辅助工具创建测试数据
4. 遵循测试最佳实践
5. 确保测试通过

### 修改现有测试

1. 理解现有测试的目的
2. 保持测试的向后兼容性
3. 更新相关文档
4. 运行所有相关测试

## 相关资源

- [Flutter测试文档](https://docs.flutter.dev/testing)
- [Mockito文档](https://pub.dev/packages/mockito)
- [测试最佳实践](https://docs.flutter.dev/testing/best-practices)
