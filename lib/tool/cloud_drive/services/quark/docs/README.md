# 夸克云盘服务模块

## 📁 目录结构

```
quark/
├── models/                          # 数据模型
│   └── quark_api_result.dart       # API响应封装
├── quark_config.dart                # 配置管理
├── quark_base_service.dart          # 基础服务
├── quark_auth_service.dart          # 认证服务
├── quark_file_list_service.dart     # 文件列表服务
├── quark_file_operation_service.dart # 文件操作服务
├── quark_cloud_drive_service.dart   # 主服务类
├── quark_operation_strategy.dart    # 策略实现
├── quark_qr_login_service.dart      # 二维码登录
└── README.md                        # 本文档
```

## 🏗️ 架构设计

### 分层架构

```
┌─────────────────────────────────────────┐
│     QuarkOperationStrategy              │  ← 策略层（对外接口）
│     (实现 CloudDriveOperationStrategy)  │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│     Service Layer (服务层)               │
│  ┌────────────────────────────────────┐ │
│  │ QuarkCloudDriveService            │ │  ← 主服务
│  │ QuarkFileListService              │ │  ← 文件列表
│  │ QuarkFileOperationService         │ │  ← 文件操作
│  │ QuarkAuthService                  │ │  ← 认证管理
│  │ QuarkQRLoginService               │ │  ← 二维码登录
│  └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│     QuarkBaseService                    │  ← 基础服务
│     (Dio实例管理、拦截器、工具方法)      │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│     QuarkConfig                         │  ← 配置中心
│     (API端点、常量、工具方法)            │
└─────────────────────────────────────────┘
```

### 职责划分

#### 1. **QuarkConfig** - 配置中心
- ✅ **职责**: 集中管理所有配置项、API端点、常量
- ✅ **特点**: 只包含静态方法和常量，无状态
- ✅ **优点**: 易于维护，避免硬编码

```dart
// 使用示例
final endpoint = QuarkConfig.getApiEndpoint('getFileList');
final sortOption = QuarkConfig.getSortOption('fileTypeAsc');
final formattedSize = QuarkConfig.formatFileSize(1024);
```

#### 2. **QuarkBaseService** - 基础服务
- ✅ **职责**: 提供Dio实例创建、请求拦截、响应处理
- ✅ **特点**: 抽象类，提供通用工具方法
- ✅ **优点**: 代码复用，统一请求处理

```dart
// 使用示例
final dio = await QuarkBaseService.createDioWithAuth(account);
final isSuccess = QuarkBaseService.isApiSuccess(response.data);
```

#### 3. **QuarkAuthService** - 认证服务
- ✅ **职责**: 管理token刷新、Cookie管理、认证头构建
- ✅ **特点**: 单例模式，缓存token和认证头
- ✅ **优点**: 自动刷新token，优化性能

```dart
// 使用示例
final authHeaders = await QuarkAuthService.buildAuthHeaders(account);
QuarkAuthService.clearTokenCache(accountId);
```

#### 4. **QuarkFileListService** - 文件列表服务
- ✅ **职责**: 获取和解析文件列表
- ✅ **特点**: 专注于文件列表相关操作
- ✅ **优点**: 单一职责，易于测试

```dart
// 使用示例
final files = await QuarkFileListService.getFileList(
  account: account,
  parentFileId: folderId,
);
```

#### 5. **QuarkFileOperationService** - 文件操作服务
- ✅ **职责**: 文件的增删改查操作
- ✅ **特点**: 包含移动、删除、重命名、复制等操作
- ✅ **优点**: 操作集中，易于维护

```dart
// 使用示例
await QuarkFileOperationService.deleteFile(account: account, file: file);
await QuarkFileOperationService.renameFile(account: account, file: file, newName: 'new');
```

#### 6. **QuarkCloudDriveService** - 主服务类
- ✅ **职责**: 提供账号信息、分享链接、下载链接等功能
- ✅ **特点**: 整合其他服务，提供高级功能
- ✅ **优点**: 统一入口

```dart
// 使用示例
final downloadUrl = await QuarkCloudDriveService.getDownloadUrl(...);
final shareResult = await QuarkCloudDriveService.createShareLink(...);
final accountDetails = await QuarkCloudDriveService.getAccountDetails(...);
```

#### 7. **QuarkOperationStrategy** - 策略实现
- ✅ **职责**: 实现CloudDriveOperationStrategy接口
- ✅ **特点**: 适配器模式，连接服务层和业务层
- ✅ **优点**: 统一接口，易于切换云盘实现

## 📐 设计原则

### 1. **单一职责原则 (SRP)**
- ✅ 每个服务类只负责一个功能领域
- ✅ 避免"上帝类"，保持类的精简

### 2. **开闭原则 (OCP)**
- ✅ 通过配置类扩展功能，无需修改服务代码
- ✅ 使用策略模式支持不同云盘

### 3. **依赖倒置原则 (DIP)**
- ✅ 服务层依赖抽象接口，不依赖具体实现
- ✅ 通过接口隔离不同模块

### 4. **接口隔离原则 (ISP)**
- ✅ 提供细粒度的服务接口
- ✅ 客户端只依赖所需的方法

### 5. **DRY原则 (Don't Repeat Yourself)**
- ✅ 公共逻辑提取到QuarkBaseService
- ✅ 配置集中到QuarkConfig

## 🎯 编码规范

### 命名规范

```dart
// ✅ 类名: PascalCase
class QuarkFileListService {}

// ✅ 方法名: camelCase
Future<List<CloudDriveFile>> getFileList() {}

// ✅ 私有方法: _camelCase
static CloudDriveFile? _parseFileData() {}

// ✅ 常量: UPPER_SNAKE_CASE 或 camelCase
static const String baseUrl = 'https://...';
static const Duration connectTimeout = Duration(seconds: 30);

// ✅ 参数名: camelCase，使用完整单词
Future<void> createFolder({
  required String folderName,  // ✅ 清晰
  required String parentFolderId,  // ✅ 完整
})

// ❌ 避免缩写
// fid → fileId
// pdir_fid → parentFolderId
```

### 文档注释

```dart
/// 获取文件列表
///
/// 从夸克云盘获取指定文件夹下的所有文件和子文件夹。
///
/// **参数说明**:
/// - [account] 云盘账号
/// - [parentFileId] 父文件夹ID，null表示根目录
/// - [page] 页码，从1开始
/// - [pageSize] 每页数量，默认50
///
/// **返回值**:
/// 返回文件列表，包含文件和文件夹。如果获取失败，返回空列表。
///
/// **异常**:
/// - [QuarkApiException] 当API调用失败时抛出
///
/// **示例**:
/// ```dart
/// final files = await getFileList(
///   account: myAccount,
///   parentFileId: '123',
///   page: 1,
/// );
/// ```
static Future<List<CloudDriveFile>> getFileList({
  required CloudDriveAccount account,
  String? parentFileId,
  int page = 1,
  int pageSize = 50,
}) async {
  // 实现...
}
```

### 错误处理

```dart
// ✅ 推荐：使用Result模式
Future<QuarkApiResult<T>> operation() async {
  try {
    // 操作...
    return QuarkApiResult.success(data);
  } catch (e) {
    return QuarkApiResult.fromException(e);
  }
}

// ✅ 调用方处理
result.fold(
  onSuccess: (data) => print('成功: $data'),
  onFailure: (error) => print('失败: $error'),
);

// ❌ 避免：静默失败
try {
  // 操作...
  return data;
} catch (e) {
  return null;  // ❌ 错误信息丢失
}
```

### 日志记录

```dart
// ✅ 推荐：结构化日志
LogManager().cloudDrive('📂 加载文件夹: $folderName (ID: $folderId)');
LogManager().cloudDrive('✅ 操作成功: 获取到 ${files.length} 个文件');
LogManager().cloudDrive('❌ 操作失败: $errorMessage');

// 使用表情符号提高可读性
// 📂 文件夹操作
// 📄 文件操作
// ✅ 成功
// ❌ 失败
// ⚡ 缓存命中
// 🌐 网络请求
// 💾 缓存保存
// 🔑 认证相关
```

## 🔧 最佳实践

### 1. **异步操作**

```dart
// ✅ 推荐：使用async/await
Future<List<CloudDriveFile>> getFiles() async {
  final response = await dio.get(url);
  return parseFiles(response.data);
}

// ❌ 避免：.then链
Future<List<CloudDriveFile>> getFiles() {
  return dio.get(url).then((response) {
    return parseFiles(response.data);
  });
}
```

### 2. **空安全**

```dart
// ✅ 推荐：明确处理null
final folderId = parentFileId ?? QuarkConfig.rootFolderId;

// ✅ 推荐：使用?. 操作符
final name = fileData['name']?.toString();

// ❌ 避免：强制解包
final name = fileData['name']! as String;  // 可能崩溃
```

### 3. **常量提取**

```dart
// ✅ 推荐：使用配置类
final url = QuarkConfig.getApiEndpoint('getFileList');

// ❌ 避免：硬编码
final url = '/1/clouddrive/file/sort';
```

### 4. **代码组织**

```dart
class QuarkFileListService {
  // 1. 公共静态方法
  static Future<List<CloudDriveFile>> getFileList() {}
  
  // 2. 私有工具方法
  static CloudDriveFile? _parseFileData() {}
  static Map<String, String> _buildParams() {}
  
  // 按功能分组，相关方法放在一起
}
```

## 🧪 测试建议

```dart
// 单元测试示例
test('解析文件数据 - 正常情况', () {
  final fileData = {
    'fid': '123',
    'file_name': 'test.txt',
    'size': 1024,
  };
  
  final file = QuarkFileListService._parseFileData(fileData, '0');
  
  expect(file?.id, '123');
  expect(file?.name, 'test.txt');
  expect(file?.size, 1024);
});
```

## 📊 性能优化

### 1. **缓存策略**
- ✅ Token缓存（5秒）
- ✅ 认证头缓存（5秒）
- ✅ 文件列表缓存（5分钟）

### 2. **请求优化**
- ✅ 复用Dio实例
- ✅ 并发请求（获取账号信息+容量信息）
- ✅ 防抖机制（Cookie更新）

### 3. **内存优化**
- ✅ LRU缓存策略
- ✅ 不可变列表（防止意外修改）
- ✅ 及时清理过期缓存

## 🔄 未来优化方向

1. **更多API支持**
   - 文件搜索
   - 离线下载
   - 文件上传

2. **性能提升**
   - 请求重试机制
   - 指数退避策略
   - 更智能的缓存策略

3. **代码质量**
   - 增加单元测试
   - 集成测试
   - 代码覆盖率

## 📚 参考资料

- [Dart编码规范](https://dart.dev/guides/language/effective-dart/style)
- [Flutter最佳实践](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)
- [Clean Code原则](https://github.com/ryanmcdermott/clean-code-javascript)

