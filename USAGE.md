# Flutter UI模板使用指南

## 快速开始

### 1. 克隆或下载模板项目

```bash
# 如果你有git仓库
git clone <your-repo-url> my_flutter_app
cd my_flutter_app

# 或者直接使用当前模板
cd flutter_ui_template
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 运行项目

```bash
flutter run
```

## 自定义指南

### 修改应用名称

1. 修改 `pubspec.yaml` 中的 `name` 字段
2. 修改 `lib/main.dart` 中的 `title` 字段

### 添加新页面

1. 在 `lib/presentation/pages/` 中创建新页面文件
2. 在 `lib/presentation/pages/main_screen.dart` 中：
   - 将新页面添加到 `pages` 列表
   - 在 `destinations` 中添加对应的导航项

示例：

```dart
// 1. 创建新页面
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  // ... 实现页面
}

// 2. 在 main_screen.dart 中添加
pages: const [
  HomePage(),
  UserPage(),
  SettingsPage(), // 新增
],

// 3. 在导航栏中添加
destinations: [
  // ... 现有项目
  NavigationDestination(
    icon: Icon(Icons.settings),
    selectedIcon: Icon(Icons.settings),
    label: '设置',
  ),
],
```

### 自定义主题

1. 在 `lib/core/theme/app_colors.dart` 中添加新颜色
2. 在 `lib/core/theme/theme_manager.dart` 中：
   - 在 `ThemeType` 枚举中添加新类型
   - 实现对应的主题方法
   - 在 `getThemeInfo` 中添加主题信息

示例：

```dart
// 1. 添加新主题类型
enum ThemeType {
  // ... 现有主题
  customTheme, // 新增
}

// 2. 实现主题方法
ThemeData _getCustomTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.yourColor,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: GoogleFonts.interTextTheme(),
    // ... 其他配置
  );
}

// 3. 添加主题信息
case ThemeType.customTheme:
  return ThemeInfo(
    name: '自定义主题',
    description: '我的专属主题',
    icon: Icons.palette,
    color: Colors.yourColor,
    isPremium: false,
  );
```

### 添加新组件

在 `lib/presentation/widgets/` 中创建新的组件目录：

```
widgets/
├── common/          # 通用组件
├── forms/           # 表单组件
├── cards/           # 卡片组件
└── buttons/         # 按钮组件
```

### 状态管理

使用 Riverpod 进行状态管理：

```dart
// 1. 创建状态类
class MyState {
  final String data;
  final bool isLoading;
  
  MyState({required this.data, required this.isLoading});
}

// 2. 创建提供者
final myProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
  return MyNotifier();
});

// 3. 创建Notifier
class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(MyState(data: '', isLoading: false));
  
  void updateData(String newData) {
    state = state.copyWith(data: newData);
  }
}

// 4. 在Widget中使用
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myState = ref.watch(myProvider);
    
    return Text(myState.data);
  }
}
```

## 项目结构说明

```
lib/
├── core/                    # 核心功能层
│   ├── theme/              # 主题系统
│   │   ├── app_colors.dart # 颜色定义
│   │   └── theme_manager.dart # 主题管理器
│   └── providers/          # 状态管理
│       ├── app_providers.dart # 应用提供者
│       └── theme_provider.dart # 主题提供者
├── presentation/           # 表现层
│   ├── pages/             # 页面
│   │   ├── main_screen.dart # 主屏幕
│   │   ├── home_page.dart   # 首页
│   │   └── user_page.dart    # 用户页
│   └── widgets/           # 组件
│       └── common/        # 通用组件
│           └── common_widgets.dart
└── main.dart              # 应用入口
```

## 最佳实践

1. **保持代码整洁**：按照功能模块组织代码
2. **使用状态管理**：对于复杂状态使用Riverpod
3. **响应式设计**：使用flutter_screenutil进行屏幕适配
4. **主题一致性**：使用主题系统保持UI一致性
5. **组件复用**：将常用UI提取为可复用组件

## 常见问题

### Q: 如何添加新的依赖？

A: 在 `pubspec.yaml` 的 `dependencies` 部分添加新依赖，然后运行 `flutter pub get`。

### Q: 如何修改应用图标？

A: 使用 `flutter_launcher_icons` 包或手动替换各平台的图标文件。

### Q: 如何添加国际化支持？

A: 使用 `flutter_localizations` 和 `intl` 包，创建对应的arb文件。

### Q: 如何优化性能？

A: 使用 `AutomaticKeepAliveClientMixin` 保持页面状态，使用 `RepaintBoundary` 优化重绘。

## 技术支持

如果遇到问题，请查看：
1. Flutter官方文档
2. Riverpod文档
3. 项目README.md
4. 提交Issue到项目仓库
