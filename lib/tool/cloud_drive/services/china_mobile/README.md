# 中国移动云盘服务

> 专业的中国移动云盘API服务实现

---

## 📂 目录结构

```
china_mobile/
├── core/                           # 核心服务
│   ├── china_mobile_config.dart    # 配置管理
│   └── china_mobile_base_service.dart  # 基础服务
├── models/                         # 数据模型
│   ├── china_mobile_api_result.dart    # API结果包装
│   ├── requests/                       # 请求模型
│   │   ├── china_mobile_file_list_request.dart
│   │   ├── china_mobile_download_request.dart
│   │   ├── china_mobile_file_operation_request.dart
│   │   ├── china_mobile_share_request.dart
│   │   ├── china_mobile_task_request.dart
│   │   └── china_mobile_search_request.dart
│   └── responses/                     # 响应模型
│       ├── china_mobile_file_list_response.dart
│       └── china_mobile_download_response.dart
├── services/                       # 服务实现
│   ├── china_mobile_file_list_service.dart      # 文件列表服务
│   ├── china_mobile_file_operation_service.dart # 文件操作服务
│   ├── china_mobile_download_service.dart       # 下载服务
│   ├── china_mobile_share_service.dart          # 分享服务
│   ├── china_mobile_task_service.dart           # 任务服务
│   └── china_mobile_search_service.dart         # 搜索服务
├── utils/                         # 工具类
│   └── china_mobile_logger.dart   # 日志工具
└── README.md                       # 本文件
```

---

## ⚡ 快速开始

### 1. 获取文件列表

```dart
import 'china_mobile_file_list_service.dart';

final files = await ChinaMobileFileListService.getFileList(
  account: myAccount,
  parentFileId: '/', // 根目录
  pageSize: 100,
);
```

### 2. 文件操作

```dart
import 'china_mobile_file_operation_service.dart';

// 删除文件
await ChinaMobileFileOperationService.deleteFile(
  account: myAccount,
  file: selectedFile,
);

// 重命名文件
await ChinaMobileFileOperationService.renameFile(
  account: myAccount,
  file: selectedFile,
  newName: '新文件名.txt',
);

// 移动文件
await ChinaMobileFileOperationService.moveFile(
  account: myAccount,
  file: selectedFile,
  targetFolderId: '/target/folder',
);

// 复制文件
await ChinaMobileFileOperationService.copyFile(
  account: myAccount,
  file: selectedFile,
  targetFolderId: '/target/folder',
);
```

### 3. 获取下载链接

```dart
import 'china_mobile_download_service.dart';

final downloadUrl = await ChinaMobileDownloadService.getDownloadUrl(
  account: myAccount,
  file: selectedFile,
);
```

### 4. 创建分享链接

```dart
import 'china_mobile_share_service.dart';

final shareUrl = await ChinaMobileShareService.getShareLink(
  account: myAccount,
  files: [selectedFile],
  accountNumber: '13155350190',
);
```

### 5. 搜索文件

```dart
import 'china_mobile_search_service.dart';

final results = await ChinaMobileSearchService.searchFile(
  account: myAccount,
  keyword: 'png',
  owner: '13155350190',
);
```

### 6. 查询任务状态

```dart
import 'china_mobile_task_service.dart';

final taskInfo = await ChinaMobileTaskService.getTask(
  account: myAccount,
  taskId: '1808833969471457408',
);
```

---

## 🎯 核心特性

### ✨ 统一的API响应模型
```dart
class ChinaMobileApiResult<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;
}
```

### 📝 统一的日志系统
```dart
ChinaMobileLogger.operationStart('操作名称', params: {...});
ChinaMobileLogger.success('操作成功');
ChinaMobileLogger.error('操作失败', error: e, stackTrace: stackTrace);
```

### 📦 模块化设计
- 文件列表服务
- 文件操作服务（移动、删除、重命名、复制）
- 下载服务
- 分享服务
- 任务服务
- 搜索服务

---

## 📋 API端点

根据 `默认模块.md` 文档实现的API端点：

| 操作 | 端点 | 方法 |
|------|------|------|
| 获取文件列表 | `/hcy/file/list` | POST |
| 获取下载链接 | `/hcy/file/getDownloadUrl` | POST |
| 获取分享链接 | `/orchestration/personalCloud-rebuild/outlink/v1.0/getOutLink` | POST |
| 重命名文件 | `/hcy/file/update` | POST |
| 移动文件 | `/hcy/file/batchMove` | POST |
| 复制文件 | `/hcy/file/batchCopy` | POST |
| 删除文件 | `/hcy/recyclebin/batchTrash` | POST |
| 查询任务 | `/hcy/task/get` | POST |
| 搜索文件 | `/search/SearchFile` | POST |

---

## 🎓 使用DTO模式

推荐使用DTO（数据传输对象）模式进行API调用：

```dart
// 文件列表
final request = ChinaMobileFileListRequest(
  parentFileId: '/',
  pageInfo: PageInfo(pageSize: 100),
);

final result = await ChinaMobileFileListService.getFileListWithDTO(
  account: account,
  request: request,
);

if (result.isSuccess) {
  final files = result.data!.files;
  // 处理文件列表
}

// 下载
final downloadRequest = ChinaMobileDownloadRequest(fileId: file.id);
final downloadResult = await ChinaMobileDownloadService.getDownloadUrlWithDTO(
  account: account,
  request: downloadRequest,
);

if (downloadResult.isSuccess) {
  final url = downloadResult.data!.url;
  // 使用下载链接
}
```

---

## 📊 代码质量

- ✅ 零Linter错误
- ✅ 完整文档注释
- ✅ 100%类型安全
- ✅ 统一代码风格

---

## 📞 支持

如有问题，请查阅：
1. `默认模块.md` - API文档
2. 代码中的详细注释
3. 夸克云盘实现作为参考

---

**最后更新**: 2025年1月14日  
**版本**: v1.0  
**状态**: ✅ 生产就绪

