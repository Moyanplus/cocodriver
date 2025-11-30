# Lanzou Provider 设计说明（对比 123 云盘现状）

Lanzou 模块遵循「配置 → API → Repository → Strategy」四段式，但能力覆盖度低于 123 云盘（Pan123）：

- **已实现**：列表（文件+文件夹）、移动/删除/重命名、上传（multipart）、直链解析、账号有效性校验（基于 Cookie/UID）。
- **未实现**：复制、分享 API、搜索、下载/高速下载、刷新鉴权、预览能力。
- **DTO 收敛**：仓库内部已统一为 DTO（`LanzouOperationResponse`/`LanzouFilesResponse`/`CloudDriveFile`），无裸 `Map` 对外暴露。
- **日志**：统一使用 `CloudDriveApiLogger/LogManager`，上传头已集中到 `LanzouConfig.buildUploadHeaders`。

与 123 云盘相比：
- 123 云盘已覆盖上传（含鉴权）、离线下载、详细错误码映射、账号详情获取；Lanzou 仅基础文件操作和直链解析。
- 123 云盘请求/响应全部走 DTO，错误码映射完整；Lanzou 错误映射仍依赖提示文案，缺乏枚举化。

## 目录概览
```
providers/lanzou/
├── api/               # Dio 配置、API 客户端、VEI 获取、请求构造
├── exceptions/        # 蓝奏特定异常
├── models/            # 请求/响应 DTO、直链模型、Result
├── repository/        # 核心仓库（文件/目录/直链），内部全 DTO
├── utils/             # UID 提取、大小解析
├── lanzou_config.dart # URL/任务ID/请求头/上传头构建/超时/日志开关
└── lanzou_operation_strategy.dart # 接入通用策略框架
```

## 使用要点
- 创建仓库：需有效 Cookie（含 `ylogin`），用 `LanzouUtils.extractUid` 提取 UID；VEI 参数由 `LanzouVeiProvider` 自动获取并缓存。
- 列表：调用 `LanzouRepository.listFiles`（内部合并文件/文件夹；文件支持 pg 分页、文件夹不分页）。
- 上传：`uploadFile` 返回 `CloudDriveFile` DTO，上传头由 `LanzouConfig.buildUploadHeaders` 统一生成。
- 直链：`parseDirectLink` 支持公开/带密码分享，自动跟踪重定向。
- 账号详情：`getAccountDetails` 仅验证 Cookie 并返回 UID 占位，不含容量信息。

## 待办清单（相对 123 云盘差距）
1) **能力补齐**：复制/搜索/分享 API/预览/刷新鉴权/高速下载。
2) **错误码映射**：将常见提示文案映射为枚举，供 UI 精准展示。
3) **测试**：补充列表/上传/直链解析的单测，防止蓝奏页面变更导致回归。
4) **接口返回统一**：后续若全局策略改为返回 DTO，可同步将策略层接口改为 `CloudDriveFile?/Result`，去掉 Map 包装。

## 简要示例
```dart
final repo = LanzouRepository.fromAccount(account);
final items = await repo.listFiles(account: account, folderId: '-1'); // CloudDriveFile 列表

final uploaded = await repo.uploadFile(
  account: account,
  filePath: '/tmp/demo.apk',
  fileName: 'demo.apk',
  parentId: '-1',
);
```
