# Flutter UI模板

这是一个基于可可世界设计的Flutter UI模板项目，提供了完整的UI框架和组件库。

## 特性

- 🎨 **丰富的主题系统** - 包含多种精美主题，支持浅色/深色模式
- 🧭 **流畅的导航系统** - 基于PageView的页面切换，支持底部导航
- 📱 **响应式设计** - 使用flutter_screenutil进行屏幕适配
- 🎭 **动画支持** - 集成Lottie动画和flutter_animate
- 🎯 **状态管理** - 使用Riverpod进行状态管理
- 🌍 **国际化支持** - 支持中英文切换
- 🎨 **Material Design 3** - 使用最新的Material Design规范

## 项目结构

```
lib/
├── core/                    # 核心功能
│   ├── theme/              # 主题系统
│   │   ├── app_colors.dart # 颜色定义
│   │   └── theme_service.dart # 主题服务
│   └── providers/          # 状态管理
│       ├── app_providers.dart
│       └── theme_provider.dart
├── presentation/           # 界面层
│   ├── pages/             # 页面
│   │   ├── main_screen_page.dart
│   │   ├── home_page.dart
│   │   ├── category_page.dart
│   │   ├── user_profile_page.dart
│   │   ├── settings_page.dart
│   │   └── theme_settings_page.dart
│   └── widgets/           # 组件
│       └── common/        # 通用组件
│           ├── app_drawer_widget.dart
│           └── common_widgets.dart
└── main.dart              # 应用入口
```

## 快速开始

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 运行项目

```bash
flutter run
```

### 3. 自定义主题

在 `lib/core/theme/theme_manager.dart` 中添加新的主题：

```dart
ThemeData _getCustomTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.yourColor,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    // ... 其他配置
  );
}
```

### 4. 添加新页面

1. 在 `lib/presentation/pages/` 中创建新页面
2. 在 `main_screen.dart` 中添加页面到pages列表
3. 在底部导航栏中添加对应的NavigationDestination

## 主要组件

### 主题系统

- 支持多种预设主题
- 自动保存用户选择
- 支持系统主题跟随

### 导航系统

- 基于PageView的流畅切换
- 底部导航栏
- 支持页面状态保持

### 通用组件

- 加载指示器
- 错误状态页面
- 空状态页面
- 通用按钮和卡片

## 依赖说明

- `flutter_riverpod` - 状态管理
- `flutter_screenutil` - 屏幕适配
- `google_fonts` - 字体支持
- `phosphor_flutter` - 图标库
- `lottie` - 动画支持
- `shared_preferences` - 本地存储

## 自定义指南

### 添加新主题

1. 在 `ThemeType` 枚举中添加新类型
2. 在 `ThemeManager` 中实现对应的主题方法
3. 在 `getThemeInfo` 中添加主题信息

### 添加新页面

1. 创建页面Widget
2. 在 `MainScreenState` 的pages列表中添加
3. 在底部导航栏中添加对应项目

### 自定义组件

在 `lib/presentation/widgets/` 中创建新的组件目录，按照功能分类组织。

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request来改进这个模板项目。