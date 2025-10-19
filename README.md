# 可可云盘 (Coco Cloud Drive)

## 🎯 项目简介

可可云盘是一款第三方聚合云盘客户端，支持多个主流云盘服务的统一管理。通过网页版API实现文件的上传、下载、分享、复制、移动、创建等操作，为用户提供便捷的云盘管理体验。

## ✨ 主要特性

### 🌐 多云盘支持
- **百度网盘** - 支持文件管理、下载、分享
- **阿里云盘** - 支持文件操作、高速下载
- **夸克云盘** - 支持文件管理、分享功能
- **蓝奏云盘** - 支持文件上传、下载、分享
- **更多云盘** - 持续扩展支持

### 🎨 现代化UI设计
- **Material Design 3** - 使用最新的Material Design规范
- **多主题支持** - 内置多种精美主题，支持浅色/深色模式
- **响应式设计** - 适配不同屏幕尺寸
- **流畅动画** - 集成Lottie动画和flutter_animate

### 🏗️ 技术架构
- **分层架构** - 清晰的分层结构，便于维护和扩展
- **功能模块化** - 按业务功能组织代码结构
- **依赖注入** - 使用GetIt进行依赖管理
- **状态管理** - 集成Riverpod和Provider

### 🌍 国际化支持
- **多语言支持** - 支持中英文切换
- **本地化服务** - 完整的本地化解决方案

### 📱 多平台支持
- **Android** - 完整的Android支持
- **iOS** - 完整的iOS支持
- **Web** - Web平台支持
- **Desktop** - Windows、macOS、Linux支持

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
│   ├── cloud_drives/       # 云盘管理
│   │   ├── baidu/          # 百度网盘
│   │   ├── aliyun/         # 阿里云盘
│   │   ├── quark/          # 夸克云盘
│   │   └── lanzou/         # 蓝奏云盘
│   ├── file_manager/       # 文件管理
│   ├── download/           # 下载管理
│   ├── upload/             # 上传管理
│   ├── share/              # 分享功能
│   └── settings/           # 设置功能
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
# 1. 克隆项目
git clone <your-repo-url> coco_cloud_drive
cd coco_cloud_drive

# 2. 安装依赖
flutter pub get

# 3. 运行项目
flutter run
```

### 3. 构建应用

```bash
# Android APK
flutter build apk

# iOS
flutter build ios

# Web
flutter build web

# Desktop
flutter build windows
flutter build macos
flutter build linux
```

## 🛠️ 开发指南

### 添加新云盘支持

1. 在 `lib/features/cloud_drives/` 下创建新的云盘模块
2. 实现云盘API接口
3. 创建对应的数据模型和服务
4. 在文件管理器中集成新云盘

### 添加新功能

1. 在 `lib/features/` 下创建功能模块
2. 实现业务逻辑和UI界面
3. 集成到主应用中

### 自定义主题

1. 在 `lib/core/theme/` 中添加主题配置
2. 在主题服务中注册新主题
3. 在设置页面中添加主题选择

## 📦 依赖说明

### 核心依赖
- `flutter_riverpod` - 状态管理
- `flutter_screenutil` - 屏幕适配
- `google_fonts` - 字体支持
- `phosphor_flutter` - 图标库

### 网络请求
- `dio` - HTTP客户端
- `retrofit` - API客户端生成
- `dio_cache_interceptor` - 缓存拦截器

### 数据存储
- `shared_preferences` - 本地存储
- `hive` - 数据库
- `flutter_secure_storage` - 安全存储

### 文件操作
- `file_picker` - 文件选择
- `path_provider` - 路径提供
- `permission_handler` - 权限管理

### 多平台支持
- `device_info_plus` - 设备信息
- `platform` - 平台检测
- `url_launcher` - URL启动
- `share_plus` - 分享功能

## 🔧 配置说明

### 应用信息
- **包名**: `com.driver.coco`
- **应用名称**: `可可云盘`
- **版本**: `1.0.0+1`

### 平台配置
- **Android**: 支持API 21+
- **iOS**: 支持iOS 11.0+
- **Web**: 支持现代浏览器
- **Desktop**: 支持Windows 10+, macOS 10.14+, Ubuntu 18.04+

## 📚 文档

- [使用指南](USAGE.md)
- [API文档](docs/API.md)
- [开发指南](docs/DEVELOPMENT.md)
- [部署指南](docs/DEPLOYMENT.md)

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个项目。

### 贡献指南
1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建Pull Request

## 📄 许可证

MIT License

## 📞 支持

如果您在使用过程中遇到问题，请：

1. 查看文档和FAQ
2. 搜索已有的Issue
3. 创建新的Issue描述问题

## 🎯 开发计划

### 第一阶段 (v1.0)
- [x] 基础架构搭建
- [x] 多平台支持
- [x] 主题系统
- [ ] 百度网盘集成
- [ ] 阿里云盘集成

### 第二阶段 (v1.1)
- [ ] 夸克云盘集成
- [ ] 蓝奏云盘集成
- [ ] 文件管理功能
- [ ] 下载管理

### 第三阶段 (v1.2)
- [ ] 上传管理
- [ ] 分享功能
- [ ] 批量操作
- [ ] 性能优化

---

**注意**: 本项目仅供学习和研究使用，请遵守各云盘服务的使用条款。