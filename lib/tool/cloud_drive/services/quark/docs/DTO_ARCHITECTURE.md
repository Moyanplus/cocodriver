# 📦 夸克云盘 DTO 架构文档

## 概述

本文档说明夸克云盘服务的 DTO（Data Transfer Object）架构设计，包括请求和响应的强类型结构体设计。

---

## 🎯 设计目标

### 为什么需要 DTO？

**优化前**（使用 Map）：
```dart
// ❌ 问题：
// 1. 没有类型安全
// 2. 字段名容易写错
// 3. 没有代码提示
// 4. 难以维护
final requestBody = {
  'fid_list': fileIds,
  'title': title,
  'url_type': 2,  // 这个2是什么意思？
  'expired_type': 1,
};
```

**优化后**（使用 DTO）：
```dart
// ✅ 优势：
// 1. 编译时类型检查
// 2. IDE 自动完成
// 3. 清晰的文档
// 4. 易于测试
final request = QuarkShareRequest(
  fileIds: fileIds,
  title: title,
  urlType: ShareUrlType.standard,  // 枚举，含义清晰
  expiredType: ShareExpiredType.permanent,
);
```

---

## 📁 目录结构

```
models/
├── quark_api_result.dart         # API 响应统一封装
├── quark_models.dart              # 统一导出入口
├── requests/                      # 请求 DTOs
│   ├── index.dart
│   ├── quark_account_request.dart
│   ├── quark_download_request.dart
│   ├── quark_file_list_request.dart
│   ├── quark_file_operation_request.dart
│   └── quark_share_request.dart
└── responses/                     # 响应 DTOs
    ├── index.dart
    ├── quark_download_response.dart
    ├── quark_file_operation_response.dart
    └── quark_share_response.dart
```

---

## 📋 请求 DTOs

### 1. 文件列表请求

```dart
final request = QuarkFileListRequest(
  parentFolderId: '0',
  page: 1,
  pageSize: 50,
  sort: 'file_type:asc,updated_at:desc',
);

// 转换为 API 查询参数
final queryParams = request.toQueryParameters();
```

### 2. 分享请求

```dart
final request = QuarkShareRequest(
  fileIds: ['file_id_1', 'file_id_2'],
  title: '我的分享',
  urlType: ShareUrlType.standard,
  expiredType: ShareExpiredType.sevenDays,
  passcode: '1234',
);

// 转换为 API 请求体
final body = request.toRequestBody();
```

### 3. 文件操作请求

```dart
// 移动文件
final moveRequest = QuarkMoveFileRequest(
  targetFolderId: 'folder_123',
  fileIds: ['file_1', 'file_2'],
);

// 复制文件
final copyRequest = QuarkCopyFileRequest(
  targetFolderId: 'folder_456',
  fileIds: ['file_3'],
);

// 删除文件
final deleteRequest = QuarkDeleteFileRequest(
  fileIds: ['file_4', 'file_5'],
);

// 重命名文件
final renameRequest = QuarkRenameFileRequest(
  fileId: 'file_6',
  newName: '新文件名.txt',
);
```

### 4. 创建文件夹请求

```dart
final request = QuarkCreateFolderRequest(
  parentFolderId: '0',
  folderName: '我的文件夹',
);
```

### 5. 下载请求

```dart
final request = QuarkDownloadRequest(
  fileIds: ['file_1', 'file_2'],
);
```

---

## 📤 响应 DTOs

### 1. 文件操作响应

```dart
// 从 API 响应解析
final response = QuarkFileOperationResponse.fromJson(jsonData);

if (response.isFinished) {
  print('操作立即完成');
} else if (response.taskId != null) {
  print('创建异步任务: ${response.taskId}');
}
```

### 2. 任务状态响应

```dart
final response = QuarkTaskStatusResponse.fromJson(jsonData);

if (response.isSuccess) {
  print('任务执行成功');
} else if (response.isFailed) {
  print('任务执行失败');
} else if (response.isPending) {
  print('任务进行中...');
}
```

### 3. 分享响应

```dart
final response = QuarkShareResponse.fromJson(jsonData, shareUrl);
print('分享链接: ${response.shareUrl}');
print('提取码: ${response.passcode}');
```

### 4. 下载响应

```dart
// 单个文件下载
final response = QuarkDownloadResponse.fromJson(jsonData);
print('下载链接: ${response.downloadUrl}');

// 批量下载
final batchResponse = QuarkBatchDownloadResponse.fromJsonList(jsonList);
final url = batchResponse.getDownloadUrl('file_id_1');
```

---

## 🔄 与 QuarkApiResult 结合使用

```dart
// 服务层返回统一的 QuarkApiResult
Future<QuarkApiResult<QuarkShareResponse>> createShare(
  QuarkShareRequest request,
) async {
  try {
    final response = await dio.post(
      endpoint,
      data: request.toRequestBody(),
    );
    
    return QuarkResponseParser.parse<QuarkShareResponse>(
      response: response.data,
      statusCode: response.statusCode,
      dataParser: (data) {
        return QuarkShareResponse.fromJson(
          data['task_resp']['data'],
          shareUrl,
        );
      },
    );
  } catch (e) {
    return QuarkApiResult.fromException(e);
  }
}

// 调用层使用
final result = await service.createShare(request);

result.fold(
  onSuccess: (response) {
    print('分享创建成功: ${response.shareUrl}');
  },
  onFailure: (error) {
    print('分享创建失败: $error');
  },
);
```

---

## ✨ 核心优势

| 特性 | Map 方式 | DTO 方式 |
|------|---------|---------|
| **类型安全** | ❌ 运行时错误 | ✅ 编译时检查 |
| **IDE 支持** | ❌ 无代码提示 | ✅ 自动完成 |
| **字段文档** | ❌ 需要查API文档 | ✅ 内置注释 |
| **重构友好** | ❌ 容易遗漏 | ✅ 编译器提示 |
| **单元测试** | ❌ 需要构造Map | ✅ 直接创建对象 |
| **可维护性** | ❌ 低 | ✅ 高 |

---

## 🚀 迁移指南

### 第一步：导入 DTO

```dart
import '../models/quark_models.dart';
```

### 第二步：替换请求构建

**旧代码**：
```dart
final queryParams = {
  'pr': 'ucpro',
  'fr': 'pc',
  'pdir_fid': folderId,
  '_page': page.toString(),
  '_size': pageSize.toString(),
};
```

**新代码**：
```dart
final request = QuarkFileListRequest(
  parentFolderId: folderId,
  page: page,
  pageSize: pageSize,
);
final queryParams = request.toQueryParameters();
```

### 第三步：替换响应解析

**旧代码**：
```dart
final taskId = responseData['data']['task_id'] as String?;
final isFinished = responseData['data']['finish'] as bool? ?? false;
```

**新代码**：
```dart
final response = QuarkFileOperationResponse.fromJson(
  responseData['data'],
);
final taskId = response.taskId;
final isFinished = response.isFinished;
```

---

## 📝 最佳实践

### 1. 使用枚举代替魔法数字

```dart
// ❌ 不好
final urlType = 2;

// ✅ 好
final urlType = ShareUrlType.standard;
```

### 2. 提供默认值

```dart
class QuarkFileListRequest {
  final int page;
  final int pageSize;
  
  const QuarkFileListRequest({
    this.page = 1,          // 默认第一页
    this.pageSize = 50,     // 默认50条
  });
}
```

### 3. 实现 toString 方便调试

```dart
@override
String toString() => 'QuarkShareRequest('
    'fileIds: ${fileIds.length} files, '
    'title: $title)';
```

### 4. 添加便捷方法

```dart
class QuarkTaskStatusResponse {
  final int status;
  
  bool get isSuccess => status == 2;
  bool get isFailed => status == 3;
  bool get isPending => status == 0 || status == 1;
}
```

---

## 🎊 总结

DTO 架构带来的好处：

1. ✅ **类型安全** - 编译时发现错误
2. ✅ **开发效率** - IDE 自动完成和提示
3. ✅ **代码质量** - 清晰的结构和文档
4. ✅ **易于测试** - 简单创建测试数据
5. ✅ **易于维护** - 修改时编译器会提示所有影响点
6. ✅ **可扩展性** - 添加新字段或方法很容易

这是现代 Flutter/Dart 项目的标准做法，强烈推荐使用！

