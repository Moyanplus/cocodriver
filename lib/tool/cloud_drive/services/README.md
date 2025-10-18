# 云盘服务目录

本目录包含各种云盘服务的具体实现，采用策略模式设计。

## 目录结构

```
services/
├── ali/                    # 阿里云盘服务
│   ├── ali_base_service.dart      # 基础服务
│   ├── ali_config.dart            # 配置
│   ├── ali_cloud_drive_service.dart # 云盘服务
│   ├── ali_file_list_service.dart # 文件列表服务
│   ├── ali_file_operation_service.dart # 文件操作服务
│   └── ali_operation_strategy.dart # 操作策略
├── quark/                  # 夸克云盘服务
│   ├── quark_base_service.dart    # 基础服务
│   ├── quark_config.dart          # 配置
│   ├── quark_auth_service.dart    # 认证服务
│   ├── quark_cloud_drive_service.dart # 云盘服务
│   ├── quark_file_list_service.dart # 文件列表服务
│   ├── quark_file_operation_service.dart # 文件操作服务
│   └── quark_operation_strategy.dart # 操作策略
├── baidu/                  # 百度云盘服务
│   ├── baidu_base_service.dart    # 基础服务
│   ├── baidu_config.dart          # 配置
│   ├── baidu_cloud_drive_service.dart # 云盘服务
│   ├── baidu_file_operation_service.dart # 文件操作服务
│   ├── baidu_operation_strategy.dart # 操作策略
│   ├── baidu_param_service.dart   # 参数服务
│   └── baidu_task_service.dart    # 任务服务
├── lanzou/                 # 蓝奏云盘服务
│   ├── lanzou_config.dart         # 配置
│   ├── lanzou_cloud_drive_service.dart # 云盘服务
│   ├── lanzou_operation_strategy.dart # 操作策略
│   ├── lanzou_direct_link_service.dart # 直链服务
│   └── lanzou_vei_service.dart    # VEI服务
├── pan123/                 # 123云盘服务
│   ├── pan123_base_service.dart   # 基础服务
│   ├── pan123_config.dart         # 配置
│   ├── pan123_cloud_drive_service.dart # 云盘服务
│   ├── pan123_file_list_service.dart # 文件列表服务
│   ├── pan123_file_operation_service.dart # 文件操作服务
│   ├── pan123_operation_strategy.dart # 操作策略
│   └── pan123_download_service.dart # 下载服务
└── services.dart           # 统一导出文件
```

## 设计原则

### 1. 策略模式
每个云盘类型都有自己的操作策略实现，通过 `CloudDriveOperationStrategy` 接口统一。

### 2. 基础服务
每个云盘都有基础服务类，提供：
- Dio实例创建
- 请求拦截器
- 通用响应处理

### 3. 配置管理
每个云盘都有独立的配置类，包含：
- API端点
- 请求头
- 超时设置
- 日志配置

### 4. 服务分离
- **文件列表服务**: 获取文件和文件夹列表
- **文件操作服务**: 下载、删除、重命名等操作
- **认证服务**: 登录、Token管理等
- **云盘服务**: 用户信息、容量信息等

## 使用方式

### 1. 通过策略模式使用
```dart
final strategy = CloudDriveOperationService.getStrategy(account.type);
final files = await strategy.getFileList(account: account, folderId: folderId);
```

### 2. 直接使用具体服务
```dart
import '../services/ali/ali_cloud_drive_service.dart';

final driveId = await AliCloudDriveService.getDriveId(account: account);
```

### 3. 通过依赖注入使用
```dart
final repository = CloudDriveDIProvider.repository;
final result = await repository.getFileList(request);
```

## 扩展新云盘

1. 创建新的云盘目录（如 `onedrive/`）
2. 实现 `CloudDriveOperationStrategy` 接口
3. 创建基础服务、配置、文件操作等服务类
4. 在 `services.dart` 中导出新服务
5. 在 `CloudDriveOperationService` 中注册新策略

## 注意事项

1. **认证方式**: 不同云盘使用不同的认证方式（Cookie、Token等）
2. **API差异**: 每个云盘的API结构和参数都有差异
3. **错误处理**: 需要针对不同云盘的错误码进行处理
4. **限流处理**: 注意API调用频率限制
5. **缓存策略**: 合理使用缓存提高性能 