# 账号管理说明

梳理账号管理相关的文件、实现方式，以及当前缺陷与优先改进项。

## 主要文件

- `lib/tool/cloud_drive/data/models/cloud_drive_entities.dart`
  - `CloudDriveAccount`：账号模型，包含认证信息与持久化字段 `lastAuthValid/lastAuthTime/lastAuthError`。
  - `CloudDriveAccountDetails`：账号校验结果、容量等详情。
- `lib/tool/cloud_drive/base/cloud_drive_account_service.dart`
  - 账号增删改查持久化（SharedPreferences）；`AddAccountResult` 支持重复 ID 覆盖；`updateAuthState` 持久化校验结果；支持账号归一化。
- `lib/tool/cloud_drive/base/cloud_drive_account_normalizer.dart`
  - 归一化接口，基于云盘官方 UID 等生成稳定账号 ID。
- `lib/tool/cloud_drive/services/providers/pan123/pan123_account_normalizer.dart`
  - 123 云盘归一化实现，用 UID 生成 `pan123_<uid>`，避免重复；在 `pan123_provider_descriptor` 注册。
- `lib/tool/cloud_drive/services/providers/pan123/repository/pan123_repository.dart`
  - `getUserInfo` 供归一化和账号详情使用。
- `lib/tool/cloud_drive/services/registry/cloud_drive_provider_descriptor.dart`
  - 描述符支持 `accountNormalizer`；各云盘在 provider_descriptor 中注册。
- 状态与 UI
  - `lib/tool/cloud_drive/presentation/state/handlers/account_state_handler.dart`：加载账号、切换、校验；校验失败回滚并持久化失效状态。
  - `lib/tool/cloud_drive/presentation/state/cloud_drive_state_manager.dart`：封装 handler 调用。
  - `lib/tool/cloud_drive/presentation/widgets/browser/cloud_drive_account_selector.dart`：浏览页账号条，显示校验状态与当前账号徽标。
  - `lib/shared/widgets/common/app_drawer_widget.dart`：侧边栏账号列表，当前账号绿色图标，状态显示正常/失效/未登录。
  - `lib/features/app/pages/main_screen_page.dart`：添加账号成功/覆盖提示。
  - `lib/tool/cloud_drive/services/base/cloud_drive_api_logger.dart`：请求/响应日志，便于排查认证问题。

## 当前实现

- 账号 ID 可由各云盘 normalizer 生成稳定值；123 云盘已用 UID 生成 `pan123_<uid>`，重复添加会覆盖并返回 `replaced=true`。
- 校验状态持久化：`updateAuthState` 写入失效/时间/错误，加载账号时预填充；切换账号同步校验，失效则回滚并提示。
- UI 标注当前账号（绿色图标）并显示校验状态（校验中/未校验/有效/失效）。

## 缺陷 / 待改进

- 仅 123 云盘实现归一化，其它云盘仍用时间戳 ID，重复账号无法去重；需为各云盘补充 normalizer。
- 当前选中账号未持久化，重启后默认第一个；建议保存 `currentAccountId` 并恢复。
- 认证失效只提示并回滚，未自动清理过期凭证；可按需清空 cookies/token 或引导重新登录。
- 状态展示分散：浏览页/侧边栏已对齐，其他入口（如账号详情）可统一样式。
- 日志仍受 logcat 截断限制；可考虑文件日志或更细分片。
- 认证错误提示策略可统一（弹窗/Toast/侧边栏提示）。

## 耦合性

- 归一化和去重集中在 `CloudDriveAccountService` + descriptor/normalizer，UI 已解耦；各云盘 normalizer 需单独实现（职责清晰但分散）。
- 状态管理与 UI 解耦良好，切换校验/提示集中在 `account_state_handler`。
- 持久化字段定义在模型，使用点分布在 handler/service，需文档与测试覆盖。

## 建议优先事项

1) 为其它云盘补充 normalizer，彻底消除重复账号。  
2) 持久化 `currentAccountId`，启动时恢复当前账号。  
3) 制定统一的认证失效处理（清理凭证 / 引导重新登录 / 统一提示）。  
4) 统一账号状态展示样式；必要时增加文件日志或更细分片避免截断。  
