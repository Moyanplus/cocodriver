# 项目结构优化方案

## 当前结构问题分析

### 1. 空目录问题
- `lib/core/config/` - 空目录，无实际用途
- `lib/presentation/widgets/themed/` - 空目录，无实际用途

### 2. 缺乏功能模块化
- 所有页面混在一个 `pages/` 目录下
- 缺乏按业务功能组织的模块结构
- 难以扩展和维护

### 3. 组件分类不清晰
- `common/` 目录下组件功能差异大
- 缺乏按功能类型细分的组件目录

### 4. 缺乏完整的分层架构
- 没有数据模型层 (`models/`)
- 没有服务层 (`services/`)
- 没有工具类层 (`utils/`)
- 没有配置管理层 (`config/`)

## 优化后的项目结构

```
lib/
├── core/                           # 核心层
│   ├── config/                     # 配置管理
│   │   ├── app_config.dart         # 应用配置
│   │   ├── theme_config.dart       # 主题配置
│   │   └── constants.dart          # 应用常量
│   ├── constants/                  # 常量定义
│   │   ├── app_constants.dart      # 应用常量
│   │   ├── ui_constants.dart       # UI常量
│   │   └── api_constants.dart      # API常量
│   ├── models/                     # 数据模型
│   │   ├── theme_model.dart        # 主题模型
│   │   ├── user_model.dart         # 用户模型
│   │   └── settings_model.dart     # 设置模型
│   ├── services/                   # 服务层
│   │   ├── theme_service.dart      # 主题服务
│   │   ├── storage_service.dart    # 存储服务
│   │   └── navigation_service.dart # 导航服务
│   ├── utils/                      # 工具类
│   │   ├── date_utils.dart         # 日期工具
│   │   ├── string_utils.dart       # 字符串工具
│   │   └── validation_utils.dart   # 验证工具
│   ├── providers/                  # 状态管理
│   │   ├── app_providers.dart      # 应用提供者
│   │   ├── theme_provider.dart     # 主题提供者
│   │   └── user_provider.dart      # 用户提供者
│   └── theme/                      # 主题相关
│       ├── app_colors.dart         # 颜色定义
│       ├── app_text_styles.dart    # 文本样式
│       └── app_theme.dart          # 主题定义
├── features/                       # 功能模块
│   ├── home/                       # 首页功能
│   │   ├── pages/
│   │   │   └── home_page.dart
│   │   ├── widgets/
│   │   │   ├── home_header_widget.dart
│   │   │   └── feature_card_widget.dart
│   │   └── providers/
│   │       └── home_provider.dart
│   ├── category/                   # 分类功能
│   │   ├── pages/
│   │   │   └── category_page.dart
│   │   ├── widgets/
│   │   │   ├── category_section_widget.dart
│   │   │   └── function_button_widget.dart
│   │   └── providers/
│   │       └── category_provider.dart
│   ├── user/                       # 用户功能
│   │   ├── pages/
│   │   │   └── user_profile_page.dart
│   │   ├── widgets/
│   │   │   ├── user_avatar_widget.dart
│   │   │   └── user_info_widget.dart
│   │   └── providers/
│   │       └── user_provider.dart
│   └── settings/                   # 设置功能
│       ├── pages/
│       │   ├── settings_page.dart
│       │   └── theme_settings_page.dart
│       ├── widgets/
│       │   ├── settings_tile_widget.dart
│       │   └── theme_selector_widget.dart
│       └── providers/
│           └── settings_provider.dart
├── shared/                         # 共享组件
│   ├── widgets/                    # 通用组件
│   │   ├── common/                 # 基础组件
│   │   │   ├── app_drawer_widget.dart
│   │   │   ├── loading_widget.dart
│   │   │   ├── error_widget.dart
│   │   │   └── empty_widget.dart
│   │   ├── forms/                  # 表单组件
│   │   │   ├── custom_button_widget.dart
│   │   │   ├── custom_text_field_widget.dart
│   │   │   └── custom_switch_widget.dart
│   │   ├── navigation/             # 导航组件
│   │   │   ├── bottom_nav_widget.dart
│   │   │   └── app_bar_widget.dart
│   │   └── themed/                 # 主题组件
│   │       ├── themed_card_widget.dart
│   │       └── themed_button_widget.dart
│   ├── dialogs/                    # 对话框
│   │   ├── confirm_dialog.dart
│   │   ├── info_dialog.dart
│   │   └── loading_dialog.dart
│   └── utils/                      # 共享工具
│       ├── responsive_utils.dart   # 响应式工具
│       └── animation_utils.dart    # 动画工具
├── presentation/                   # 展示层（保留用于主框架）
│   ├── pages/
│   │   └── main_screen_page.dart   # 主屏幕
│   └── widgets/
│       └── (移动到shared/widgets)
└── main.dart                       # 应用入口
```

## 优化优势

### 1. **功能模块化**
- 每个功能模块独立组织
- 便于团队协作开发
- 易于功能扩展和维护

### 2. **清晰的分层架构**
- 核心层：配置、模型、服务、工具
- 功能层：按业务功能组织
- 共享层：通用组件和工具

### 3. **组件分类清晰**
- 按功能类型细分组件目录
- 便于组件复用和维护
- 提高开发效率

### 4. **易于扩展**
- 新功能可以独立添加模块
- 不影响现有功能
- 支持微前端架构

## 实施计划

### 阶段1：创建新目录结构
1. 创建 `features/` 目录及各功能模块
2. 创建 `shared/` 目录及子目录
3. 创建 `core/` 下的新目录

### 阶段2：文件迁移
1. 将页面文件迁移到对应功能模块
2. 将组件文件迁移到 `shared/widgets`
3. 创建缺失的模型、服务、工具文件

### 阶段3：更新引用
1. 更新所有import语句
2. 调整Provider结构
3. 更新路由配置

### 阶段4：验证和优化
1. 运行测试确保功能正常
2. 优化import路径
3. 更新文档

## 迁移策略

### 1. 渐进式迁移
- 先创建新结构，再逐步迁移文件
- 保持现有功能正常运行
- 分模块进行迁移

### 2. 向后兼容
- 保留原有import路径一段时间
- 逐步更新引用
- 确保无破坏性变更

### 3. 测试验证
- 每个阶段完成后进行测试
- 确保功能完整性
- 性能无回归

## 预期效果

1. **提高可维护性**：清晰的结构便于理解和维护
2. **增强可扩展性**：模块化设计便于功能扩展
3. **改善开发体验**：清晰的目录结构提高开发效率
4. **支持团队协作**：模块化便于多人协作开发
5. **便于测试**：独立的功能模块便于单元测试
