# 可可云盘（Coco Cloud Drive）

统一管理多家云盘账户的 Flutter 客户端，主打跨平台、插件化、可扩展。

---

## 👀 你能用它做什么？

- 在同一个应用里切换百度/阿里/夸克/蓝奏/123/中国移动等云盘账户
- 浏览、上传、下载、分享、复制、移动、批量操作文件
- 自定义排序、列表/图标视图、分组、索引导航
- 通过基于 OperationGuard 的“乐观更新 + 回滚”获得更顺滑的交互体验
- 统一的日志、搜索、缓存、性能监控工具，方便排障与调优

---

## 🏗️ 架构亮点

| 模块 | 说明 |
| --- | --- |
| **Provider Descriptor** | 每个云盘自描述（图标、名称、登录方式、能力矩阵）。新增云盘=新建目录+注册 descriptor。 |
| **BaseCloudDriveRepository** | 统一定义 CRUD、分享、直链、预览接口，仓库只关注各家 API。 |
| **CloudDriveServiceGateway** | 业务层唯一入口，负责调用策略、缓存、日志、错误处理。 |
| **CloudDriveOperationStrategy** | 处理各云盘的 UI 交互、状态更新、OperationGuard 回滚。 |
| **FolderStateHandler** | Riverpod 状态机，支持分页、缓存、排序、视图模式、批量模式。 |
| **CloudDriveApiLogger** | 标准化的 Dio 请求/响应日志，支持 verbose/compact 两种模式。 |
| **CloudDriveLogUtils** | 在日志中输出统一的文件/文件夹示例，排查字段差异。 |

架构图：

```
UI Widgets → ViewModel → FolderStateHandler/ServiceGateway
    │                                │
    └───────── OperationGuard ◄──────┘
                │
CloudDriveOperationStrategy
    │            │
    │            └─ BaseCloudDriveRepository (per provider)
    │                                │
    └─ Provider Descriptor ──────────┘
```

---

## 📁 目录一览

```
lib/
├─ core/                    # 日志、网络、DI、主题、工具
├─ features/
│  ├─ app/                  # 主框架 & 页面
│  └─ cloud_drive/          # 云盘模块（业务无关的公共层）
│      ├─ base/             # 基类、OperationGuard、ServiceGateway
│      ├─ config/           # 能力/能力矩阵配置
│      ├─ presentation/     # UI、状态管理（Riverpod）
│      ├─ services/         # 各云盘 provider，结构统一
│      │    ├─ ali/
│      │    ├─ baidu/
│      │    ├─ lanzou/
│      │    ├─ pan123/
│      │    ├─ quark/
│      │    └─ china_mobile/
│      └─ utils/            # 日志、文件类型、搜索等工具
└─ main.dart
```

**每个云盘目录统一结构：**

```
services/<vendor>/
├─ api/            # Dio client、请求构建、拦截器
├─ repository/     # 继承 BaseCloudDriveRepository
├─ strategy/       # 继承 CloudDriveOperationStrategy
├─ models/
│   ├─ requests/
│   └─ responses/
├─ provider_descriptor.dart
└─ utils/ (可选)
```

---

## 🚀 快速开始

### 1. 环境

- Flutter 3.16+
- Dart 3+
- iOS/Android/Web/Windows/macOS/Linux 对应的构建依赖

### 2. 安装依赖 & 运行

```bash
git clone <repo-url> coco_cloud_drive
cd coco_cloud_drive
flutter pub get
flutter run
```

### 3. 常用命令

```bash
flutter test
flutter build apk
flutter build ios
flutter build web
flutter build macos
```

---

## 🧩 如何接入新云盘？

1. **复制模板**：在 `lib/tool/cloud_drive/services/<vendor>` 仿照现有目录创建 `api/ repository/ strategy/ models/ provider_descriptor.dart`。
2. **实现 Repo**：继承 `BaseCloudDriveRepository`，确保所有接口返回 `CloudDriveFile`、`CloudDriveAccountDetails` 等统一模型。
3. **实现 Strategy**：继承 `CloudDriveOperationStrategy`，利用 OperationGuard 包装上传/重命名/移动等操作。
4. **注册 Descriptor**：在 `services/provider/default_cloud_drive_providers.dart` 中添加 descriptor，声明能力矩阵、图标、登录方式。
5. **更新能力**：如有特殊操作（预览、直链）在 `cloud_drive_capabilities.dart` 中声明。

> Tips：日志请统一使用 `CloudDriveApiLogger` + `CloudDriveLogUtils`，方便排查。

---

## 🧪 开发者指南

- **日志**：`LogManager().cloudDrive()` 用于业务日志，`LogManager().error()` 用于异常。
- **缓存**：`FileListCacheManager` 自动处理根目录缓存、分页缓存，可通过 `invalidateCache()` 刷新。
- **乐观更新**：`OperationGuard.run(optimisticUpdate, revert, action)` 让 UI 响应更快，失败时自动回滚。
- **分页**：FolderStateHandler 会根据云盘能力自动开启分页，蓝奏云专属逻辑已集成。
- **高级搜索 UI**：`CloudDriveSearchBottomSheet` 支持基础搜索 + 可选高级筛选（模式/正则/文件类型/大小）。

---

## 🤝 贡献

1. Fork & Clone
2. `git checkout -b feature/xxx`
3. 提交前运行 `flutter analyze` / `flutter test`
4. 发起 Pull Request，并描述你的更改与测试情况

---

## 📄 许可证

本项目采用 MIT License，详见 [LICENSE](LICENSE)。

---

Have fun hacking ☁️
