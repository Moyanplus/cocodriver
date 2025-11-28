# Lanzou 模块 README

蓝奏云模块负责在 Flutter 应用中对接蓝奏云盘的所有 API，包括文件列表、上传、移动和直链解析等功能。代码遵循“配置 ➜ API 客户端 ➜ Repository ➜ Facade ➜ Operation Strategy”的分层架构，便于独立维护与扩展。

## 依赖与上下文

- 依赖 `tool/cloud_drive/data/models` 中的 `CloudDriveAccount`、`CloudDriveFile` 等通用实体。
- 需要合法的蓝奏云 Cookie（尤其是 `ylogin` 字段）来创建仓库对象，并由 `LanzouUtils.extractUid` 提取 UID。
- 蓝奏云接口要求提供 VEI 参数，模块通过 `LanzouVeiProvider` 自动获取/缓存，无需业务层操心。
- 日志统一通过 `LogManager().cloudDrive(...)` 写入，方便全局定位问题。

## 目录结构

```text
lib/tool/cloud_drive/services/lanzou
├── api/
│   ├── lanzou_dio_factory.dart     # Dio 统一配置、拦截器
│   ├── lanzou_api_client.dart       # 带 Cookie/UID 的 API 客户端
│   ├── lanzou_request_builder.dart  # 链式构造标准请求体
│   └── lanzou_vei_provider.dart      # VEI 参数抓取与缓存
├── exceptions/
│   └── lanzou_exceptions.dart       # 自定义异常
├── facade/
│   └── lanzou_cloud_drive_facade.dart  # 业务可直接调用的服务集合（含直链解析）
├── models/
│   ├── lanzou_direct_link_models.dart
│   ├── models/
│   │   ├── requests/lanzou_file_requests.dart
│   │   ├── responses/...
│   └── lanzou_result.dart           # 统一 Result/Failure
├── repository/
│   ├── lanzou_repository.dart       # 核心仓库，封装文件相关 API
│   ├── lanzou_direct_link_repository.dart
│   └── lanzou_share_repository.dart # 分享能力占位
├── utils/
│   └── lanzou_utils.dart            # UID/文件大小等通用工具
├── lanzou_config.dart               # 所有 URL、请求头、task id、超时配置
├── lanzou_operation_strategy.dart   # 接入 CloudDriveOperationStrategy
└── README.md                        # 当前文档
```

## 调用流程

```
CloudDriveOperationStrategy
        │
        ▼
LanzouCloudDriveFacade (Facade)
        │
        ▼
    LanzouRepository
        │
        ▼
LanzouApiClient + LanzouDioFactory + LanzouVeiProvider
        │
        ▼
蓝奏云官方接口 (doupload.php / html5up.php 等)
```

## 核心组件说明

### 配置（`lanzou_config.dart`）
- 统一维护 base URL、任务 ID、默认请求头、超时与日志配置。
- 提供 `getTaskId`、`getFolderId`、`getMimeType` 等便捷方法，避免在业务代码中硬编码。

### API 层（`api/`）
- `LanzouDioFactory`：集中创建带拦截器的 Dio，负责记录每次请求/响应。
- `LanzouApiClient`：基于账号 Cookie、UID 执行 POST，提供简单的重试机制。
- `LanzouVeiProvider`：拉取 mydisk 页面分析 VEI 参数，并写入 `LanzouConfig` 缓存。
- `LanzouRequestBuilder`：以链式方式拼装必要字段，保证 key、顺序与 folder/vei 逻辑统一。

### Repository 层（`repository/`）
- `LanzouRepository` 将 API 返回的 Map 映射为 `CloudDriveFile`，同时封装 cookie 校验、VEI 缓存、上传等逻辑。
- `LanzouRepository` 统一处理目录操作、上传、以及直链解析。直链解析在仓库内通过 HTML + Ajax 请求完成。
- `LanzouRepository.createShareLink` 暂不支持 API 分享，统一返回空。

### Facade（`facade/`）
- `LanzouCloudDriveFacade`：业务层常用入口，例如 `getFiles`、`uploadFile`、`moveFile`、直链解析等，内部统一捕获异常并返回 `LanzouResult`。

### Operation Strategy（`lanzou_operation_strategy.dart`）
- 实现 `CloudDriveOperationStrategy`，把蓝奏云能力接入通用的“云盘操作”框架。
- 根据平台特性标注支持/不支持的操作，并转调 Facade。

### 模型与工具（`models/`, `utils/`）
- 请求/响应模型解耦 Map 解析，`LanzouResult` 负责统一的成功/失败返回。
- `LanzouUtils` 暴露 UID 提取、临时账号创建、文件大小解析等跨层使用的工具方法。

## 已实现能力

- 列表：`getFiles`、`getFolders`、`getFileList`（合并文件/文件夹）。
- 文件操作：`moveFile`、`uploadFile`（multipart）、`getFileDetail`。
- 账号：`validateCookies`、`getAccountDetails`（基于 UID 推断）。
- 分享：直链解析支持公开/带密码的分享页，并自动处理重定向。
- 错误与日志：所有入口都在 Facade/Strategy 层抓取异常并输出 LogManager 日志。

未实现或受限能力：删除、重命名、复制、创建文件夹、API 下载/高速下载、搜索、刷新鉴权。`lanzou_operation_strategy.dart` 中保留了 TODO 以供后续扩展。

## 使用示例

```dart
final cookies = account.cookies ?? '';
final uid = LanzouCloudDriveFacade.extractUidFromCookies(cookies);
if (uid == null) throw Exception('Cookie 缺少 ylogin');

final filesResult = await LanzouCloudDriveFacade.getFiles(
  cookies: cookies,
  uid: uid,
  folderId: LanzouConfig.rootFolderId,
);

if (filesResult.isSuccess) {
  final files = filesResult.data!;
  // 展示文件列表
} else {
  LogManager().cloudDrive('获取文件失败: ${filesResult.error?.message}');
}
```

上传文件需要完整账号对象：

```dart
final uploadResult = await LanzouCloudDriveFacade.uploadFile(
  account: account,
  filePath: '/tmp/demo.pdf',
  fileName: 'demo.pdf',
  folderId: '-1',
);
```

## 日志与错误处理

- Facade/Strategy 层提供 `_logInfo/_logSuccess/_logError` 统一入口，所有异常都会记录堆栈，方便链路追踪。
- Repository 层在遇到 `zt != 1` 或响应格式异常时，会抛出 `LanzouApiException`，上层自动转换为 `LanzouResult.failure`。
- 直链解析流程中既会捕获蓝奏返回的错误，也会处理 HTML 结构变化导致的解析失败。

## 测试

现有单元测试位于 `test/tool/cloud_drive/lanzou_repository_test.dart`，覆盖 `LanzouResult` 基础行为。

```bash
flutter test test/tool/cloud_drive/lanzou_repository_test.dart
```

如需为 Repository/Fascade 增加更多测试，可使用 `package:mockito` 或 `fake_async` 对 Dio 与日志进行替身模拟。

## 扩展建议

1. **API 能力补齐**：补充删除、重命名、复制、创建文件夹、搜索等操作，建议在 `lanzou_repository.dart` 中新增对应请求模型，再暴露到 Facade/Strategy。
2. **依赖注入**：将 `LogManager`、`Dio` 等依赖通过构造函数注入，便于单元测试。
3. **错误码枚举化**：将蓝奏云常见错误信息映射为更友好的 `LanzouFailure.code`，方便 UI 精确展示。
4. **更多测试**：为直链解析、上传、VEI 缓存等核心流程补齐单测，防止蓝奏云页面结构变动导致回归。

通过以上结构与约定，可以快速定位蓝奏云模块中的责任边界，并安全地扩展新的 API 或业务能力。
