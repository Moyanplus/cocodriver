# 云盘服务目录（重构版）

本目录在进行「可插拔 + 目录规范」重构，目标是**新增云盘只改各自目录，公共层零散修改最小化**。请优先参考本文与 `doc/CLOUD_DRIVE_REFACTOR_PLAN.md`。

## 目录概览

```
services/
├── provider/                # 可插拔注册：descriptor + registry
├── lanzou/                  # 示例：已按新规范拆分的云盘
│   ├── api/                 # 请求构建、Dio封装
│   ├── config/              # API 常量、超时、headers
│   ├── models/requests/     # 请求 DTO
│   ├── models/responses/    # 响应 DTO
│   ├── repository/          # 继承 BaseCloudDriveRepository
│   ├── facade/              # 组合能力（如直链解析、上传）
│   └── lanzou_operation_strategy.dart
├── ali/ baidu/ pan123/ ...  # 其他云盘（逐步迁移中）
└── strategy_registry.dart           # 新版策略注册入口
```

## 新架构要点
- **Descriptor 驱动**：每个云盘提供 `CloudDriveProviderDescriptor(type + strategyFactory + capabilities + UI 元数据)`，在 `CloudDriveProviderRegistry` 中注册。
- **可选插件**：如二维码登录服务可随 descriptor 一并注册（示例：Quark）。
- **统一接口**：仓库继承 `BaseCloudDriveRepository`，策略实现 `CloudDriveOperationStrategy`；上层只依赖这两个接口。
- **能力集中**：能力表通过 `CloudDriveCapabilities` 注册，UI/业务读能力而非硬编码。
- **目录自包含**：请求/响应/配置/仓库/策略尽量封装在各自云盘目录内。

## 如何新增云盘（建议流程）
1. 在 `services/<provider>/` 创建目录，按 lanzou 的拆分方式放置 `config/api/models/repository/strategy`。
2. 实现 `<provider>_operation_strategy.dart`，内部调用仓库即可。
3. 定义 `<provider>` 的 `CloudDriveProviderDescriptor` 并注册（可加入默认列表）。
4. 在能力表里注册能力（`cloud_drive_capabilities.dart`），供 UI/规则使用。

## 旧接口状态
- 旧模式（cloud_drive_service_factory / services_registry）已移除；新功能请直接走 `CloudDriveOperationStrategy + ProviderDescriptor` 路径。必要的日志基类见 `common/cloud_drive_service_base.dart`。

## 其他注意事项
- 认证方式、错误码、限流策略因云盘而异，保持在各自目录内处理。
- 注释使用 Dart 文档注释 `///`，对外暴露的类/方法需补充语义清晰的说明。文件头部库注释请避免悬空，避免 analyzer 的 `dangling_library_doc_comments`。
