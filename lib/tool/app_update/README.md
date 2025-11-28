# 应用内更新功能模块

这是一个完整的应用内更新功能模块，支持版本检查、下载和安装。

## 功能特性

- ✅ **版本检查**：自动检查是否有新版本
- ✅ **Mock数据**：开发阶段使用模拟数据
- ✅ **强制更新**：支持强制更新和可选更新
- ✅ **下载管理**：显示下载进度、速度、剩余时间
- ✅ **状态管理**：使用 Riverpod 管理更新状态
- ✅ **UI组件**：提供对话框和详情页面
- ✅ **错误处理**：完整的错误处理和重试机制

## 目录结构

```
lib/tool/app_update/
├── models/
│   └── update_models.dart          # 数据模型定义
├── services/
│   ├── mock_update_service.dart    # Mock数据服务
│   └── update_service.dart         # 更新服务
├── providers/
│   └── update_provider.dart        # Riverpod状态管理
├── widgets/
│   ├── update_dialog.dart          # 更新对话框
│   └── update_check_button.dart    # 检查更新按钮
├── pages/
│   └── update_detail_page.dart     # 更新详情页面
├── app_update.dart                 # 模块导出文件
└── README.md                       # 本文档
```

## 使用方法

### 1. 在设置页面添加更新入口

已在 `lib/features/settings/pages/settings_page.dart` 中集成：

```dart
import '../../../tool/app_update/app_update.dart';

// 在设置页面添加更新选项
_buildSettingsTile(
  icon: Icons.system_update,
  title: '检查更新',
  subtitle: '检查应用是否有新版本',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UpdateDetailPage(),
      ),
    );
  },
),
```

### 2. 使用更新按钮组件

```dart
import 'package:coco_cloud_drive/tool/app_update/app_update.dart';

// 按钮样式
UpdateCheckButton(
  showIcon: true,
  text: '检查更新',
)

// ListTile样式
UpdateCheckButton(
  asListTile: true,
)
```

### 3. 直接使用Provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coco_cloud_drive/tool/app_update/app_update.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateProvider);
    
    // 检查更新
    ref.read(updateProvider.notifier).checkForUpdate();
    
    // 开始下载
    ref.read(updateProvider.notifier).startDownload(updateInfo);
    
    // 取消下载
    ref.read(updateProvider.notifier).cancelDownload();
    
    return Container();
  }
}
```

### 4. 显示更新对话框

```dart
import 'package:coco_cloud_drive/tool/app_update/app_update.dart';

// 显示更新对话框
showUpdateDialog(
  context,
  updateInfo: updateInfo,
  barrierDismissible: true,
);
```

## 数据模型

### VersionInfo - 版本信息

```dart
class VersionInfo {
  final String version;        // 版本号（1.0.0）
  final int versionCode;       // 版本代码
  final String versionName;    // 版本名称（v1.0.0）
  final String buildNumber;    // 构建号
}
```

### UpdateInfo - 更新信息

```dart
class UpdateInfo {
  final VersionInfo version;           // 版本信息
  final UpdateType updateType;         // 更新类型（强制/推荐/可选）
  final String title;                  // 更新标题
  final String description;            // 更新描述
  final List<String> features;         // 更新内容列表
  final String downloadUrl;            // 下载地址
  final int fileSize;                  // 文件大小
  final String? md5;                   // MD5校验值
  final DateTime releaseTime;          // 发布时间
}
```

### DownloadProgress - 下载进度

```dart
class DownloadProgress {
  final int downloadedBytes;           // 已下载字节数
  final int totalBytes;                // 总字节数
  final double speed;                  // 下载速度
  final DownloadStatus status;         // 下载状态
  final String? error;                 // 错误信息
  final String? filePath;              // 本地文件路径
}
```

## Mock数据测试

模块提供了多种测试场景：

```dart
// 测试推荐更新
ref.read(updateProvider.notifier).checkForUpdate(
  forceUpdate: false,
  hasUpdate: true,
);

// 测试强制更新
ref.read(updateProvider.notifier).checkForUpdate(
  forceUpdate: true,
  hasUpdate: true,
);

// 测试无更新
ref.read(updateProvider.notifier).checkForUpdate(
  hasUpdate: false,
);
```

在 `UpdateDetailPage` 中提供了测试菜单，可以快速切换不同场景。

## 状态流转

```
Initial（初始）
    ↓
Checking（检查中）
    ↓
Available（有更新） / NoUpdate（无更新） / Error（错误）
    ↓
Downloading（下载中）
    ↓
ReadyToInstall（准备安装） / DownloadError（下载错误）
    ↓
Installing（安装中）
    ↓
Installed（已安装） / InstallError（安装错误）
```

## 自定义配置

### 修改Mock数据

编辑 `services/mock_update_service.dart`：

```dart
// 修改模拟的文件大小
int _getMockFileSize() {
  return 25 * 1024 * 1024; // 25MB
}

// 修改更新特性
List<String> _getMockFeatures(bool forceUpdate) {
  return [
    '新增XXX功能',
    '优化XXX性能',
  ];
}
```

### 集成真实API

编辑 `services/update_service.dart`，修改 `checkForUpdate` 方法：

```dart
Future<UpdateCheckResult> checkForUpdate() async {
  try {
    // 调用真实API
    final response = await _dio.get('https://api.example.com/check-update');
    final updateInfo = UpdateInfo.fromJson(response.data);
    
    // 处理结果...
  } catch (e) {
    // 错误处理...
  }
}
```

## 注意事项

1. **Android安装**：需要集成 APK 安装插件（如 `install_plugin`）
2. **iOS更新**：iOS不支持应用内安装，需引导用户前往 App Store
3. **权限申请**：Android需要存储权限和安装权限
4. **网络权限**：确保 `pubspec.yaml` 中配置了 `dio` 和 `package_info_plus`
5. **文件验证**：生产环境建议启用MD5校验

## 依赖项

已在项目中包含：

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  dio: ^5.4.0
  path_provider: ^2.1.1
  package_info_plus: ^8.0.0
```

## 后续优化

- [ ] 集成真实的更新API
- [ ] 实现断点续传
- [ ] 添加差分更新支持
- [ ] 支持多语言
- [ ] 添加更新历史记录
- [ ] 实现自动更新检查
- [ ] 添加更新通知

## 贡献

如需添加新功能或修复问题，请参考项目的贡献指南。












