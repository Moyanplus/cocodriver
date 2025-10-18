# Flutter UI 模板项目

## 🎯 项目简介

这是一个功能完整的Flutter UI模板项目，基于现代Flutter开发最佳实践构建。项目采用清晰的分层架构，集成了丰富的UI组件、主题系统、状态管理和多平台支持。

## ✨ 主要特性

### 🎨 UI设计
- **Material Design 3** - 使用最新的Material Design规范
- **多主题支持** - 内置多种精美主题，支持浅色/深色模式
- **响应式设计** - 使用flutter_screenutil进行屏幕适配
- **动画支持** - 集成Lottie动画和flutter_animate
- **图标库** - 使用Phosphor图标库

### 🏗️ 架构设计
- **分层架构** - 清晰的分层结构，便于维护和扩展
- **功能模块化** - 按业务功能组织代码结构
- **依赖注入** - 使用GetIt进行依赖管理
- **状态管理** - 集成Riverpod和Provider

### 🌍 国际化
- **多语言支持** - 支持中英文切换
- **本地化服务** - 完整的本地化解决方案

### 📱 多平台支持
- **Android** - 完整的Android支持
- **iOS** - 完整的iOS支持
- **Web** - Web平台支持
- **Desktop** - Windows、macOS、Linux支持

### 🔧 开发工具
- **构建脚本** - 提供多种构建选项
- **代码生成** - 集成代码生成工具
- **性能监控** - 内置性能监控工具

## 📁 项目结构

```
lib/
├── core/                    # 核心功能层
│   ├── config/             # 配置管理
│   ├── data/               # 数据层
│   │   ├── data_sources/   # 数据源
│   │   ├── models/         # 数据模型
│   │   └── repositories/   # 仓库层
│   ├── di/                 # 依赖注入
│   ├── error/              # 错误处理
│   ├── mixins/             # 混入
│   ├── navigation/         # 导航
│   ├── network/            # 网络层
│   ├── providers/          # 状态管理
│   ├── services/           # 服务层
│   ├── theme/              # 主题系统
│   └── utils/              # 工具类
├── features/               # 功能模块
│   ├── app/                # 应用主框架
│   ├── category/           # 分类功能
│   ├── home/               # 首页功能
│   ├── settings/           # 设置功能
│   └── user/               # 用户功能
├── l10n/                   # 国际化文件
├── shared/                 # 共享组件
│   └── widgets/            # 通用组件
└── main.dart               # 应用入口
```

## 🚀 快速开始

### 1. 环境要求

- Flutter SDK >= 3.7.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Git

### 2. 项目初始化

```bash
# 1. 解压模板到目标目录
unzip flutter_ui_template.zip
cd flutter_ui_template

# 2. 运行初始化脚本
chmod +x setup.sh
./setup.sh

# 3. 安装依赖
flutter pub get

# 4. 运行项目
flutter run
```

### 3. 自定义配置

#### 修改应用信息
```yaml
# pubspec.yaml
name: your_app_name
description: "Your app description"
version: 1.0.0+1
```

#### 修改应用标题
```dart
// lib/main.dart
title: 'Your App Name',
```

## 🛠️ 开发指南

### 添加新页面

1. 在 `lib/features/` 下创建功能模块
2. 在模块内创建 `pages/` 目录
3. 在 `main_screen_page.dart` 中添加页面

### 添加新主题

1. 在 `lib/core/theme/` 中添加主题配置
2. 在主题服务中注册新主题
3. 在设置页面中添加主题选择

### 添加新组件

1. 在 `lib/shared/widgets/` 下创建组件
2. 按功能分类组织组件
3. 导出组件供其他模块使用

## 📦 构建选项

项目提供了多种构建脚本：

```bash
# 最小体积构建
./scripts/build_minimal.sh

# 优化构建
./scripts/build_optimized.sh

# 发布构建
./scripts/build_release.sh
```

## 🔧 依赖说明

### 核心依赖
- `flutter_riverpod` - 状态管理
- `flutter_screenutil` - 屏幕适配
- `google_fonts` - 字体支持
- `phosphor_flutter` - 图标库

### UI组件
- `lottie` - 动画支持
- `flutter_animate` - 动画库
- `auto_size_text` - 自适应文本
- `responsive_framework` - 响应式布局

### 数据存储
- `shared_preferences` - 本地存储
- `hive` - 数据库
- `flutter_secure_storage` - 安全存储

### 网络请求
- `dio` - HTTP客户端
- `retrofit` - API客户端生成

### 多平台支持
- `device_info_plus` - 设备信息
- `platform` - 平台检测
- `url_launcher` - URL启动
- `file_picker` - 文件选择

## 📚 文档

- [使用指南](USAGE.md)
- [项目结构优化](PROJECT_STRUCTURE_OPTIMIZATION.md)
- [命名规范](doc/NAMING_CONVENTIONS.md)

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个模板项目。

## 📄 许可证

MIT License

## 📞 支持

如果您在使用过程中遇到问题，请：

1. 查看文档和FAQ
2. 搜索已有的Issue
3. 创建新的Issue描述问题

---

**注意**: 这是一个模板项目，请根据您的实际需求进行定制和修改。
