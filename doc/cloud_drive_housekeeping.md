# CloudDrive 模块瘦身/归档建议

`lib/tool/cloud_drive` 包含 base/services/presentation/data/infrastructure/utils 等子域以及各云盘的 API/模型/策略，文件数较多。可逐步通过以下实践降低复杂度。

## 1. 文档归档
- 将模块内的 README/QUALITY/说明类文件迁移到 `doc/`，代码目录只保留源码。

## 2. 结构统一
- 各 provider 目录保持一致结构：`api/`、`models/`、`repository/`、`strategy/`，避免分散/命名不一。
- 清理无用/重复模型及旧 facade（例如已废弃的实现）。

## 3. 通用基类合并
- 检查 common/logging/cache/utils 是否有重复实现，可抽到 shared/ 或 core/ 复用，减少多处定义。

## 4. 生成物隔离
- build_runner 生成的 `*.g.dart`/`*.freezed.dart` 与手写代码分开，避免混放。

## 5. 定期清理
- 用 `rg --files | wc -l` 统计、排查孤儿文件；配合 import 检查无引用文件并删除。
- 定期审视依赖与目录，移除不再使用的模块或冗余代码。

## 6. 总体思路
- 保持现有层次（base/services/presentation/…）不变，通过文档归档、删除死代码、复用通用工具来降低心智负担。
