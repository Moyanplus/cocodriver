## Pan123 Provider Code Quality Review（对比 Lanzou）

### 总体评价
Pan123（123 云盘）在功能完备度、DTO 收敛、错误码映射上明显领先 Lanzou。分层清晰（`api / models / repository / strategy / services`），日志与错误映射统一，可维护性【良好】。

### 亮点
1. **分层明确**：`Pan123Operations` 统一封装 API/日志；`ApiClient/Repository/Strategy` 各司其职。
2. **错误处理统一**：`Pan123ErrorMapper + CloudDriveException` 覆盖常见错误码，UI 可直接展示友好提示。
3. **详细日志**：支持开关，上传/离线等请求体、响应可选输出。
4. **账号能力**：`getUserInfo` 映射到通用 `CloudDriveAccountDetails`，侧边栏可复用。
5. **上传/离线**：离线解析/提交/列表已并入 `Pan123Operations`；上传流程（init→auth→PUT→complete）走统一 helper。

### 与 Lanzou 的差距
- 功能：Pan123 已有上传、离线下载、错误码映射、账号详情；Lanzou 仅基础文件操作+直链解析。
- DTO：Pan123 全链路 DTO 化；Lanzou 刚完成仓库层 DTO 化，策略返回仍保留 Map 包装。
- 错误码：Pan123 映射完善；Lanzou 仍以文案提示为主。

### 待改进
| 范畴 | 现状 | 建议 |
| --- | --- | --- |
| 上传高级形态 | 仅单分片，未做并发/断点/秒传 | 规划多分片与秒传，完善 ETag/分片合并 |
| 分享/预览 | 分享直链、预览未实现 | 补充接口或返回占位错误，防止误用 |
| 日志复用 | 详细日志开关与截断逻辑分散 | 抽到通用 `CloudDriveApiLoggerConfig` |
| 测试覆盖 | 初步用例，未覆盖上传/离线/用户信息 | 补充 mock Dio 单测覆盖 rename/move/delete/copy/list/upload/offline/userInfo |

### 已完成功能（123 云盘）
- ✅ 文件列表/搜索
- ✅ 基础操作：重命名、移动、复制、删除、创建文件夹
- ✅ 离线下载：解析、提交任务、任务列表
- ✅ 上传：单分片上传（MD5 ETag）、进度回调
- ✅ 错误映射与详细日志
- ✅ 账号详情：`getUserInfo` → `CloudDriveAccountDetails`
- ⏳ 分享/预览、秒传/多分片未实现

### 后续建议
1. 补充单元测试：覆盖离线/上传/用户信息及错误码映射。
2. 规划多分片/秒传能力，梳理接口形态。
3. 日志开关/截断策略抽到通用层，减少重复配置。
4. 分享/预览若短期不做，策略层直接返回未支持提示，避免误用。
