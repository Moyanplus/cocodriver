# Flutter UI模板 - 文件命名规范

## 概述

本文档定义了Flutter UI模板项目的统一文件命名规范，确保代码库的一致性和可维护性。

## 基本原则

1. **使用snake_case**：所有文件名使用小写字母和下划线
2. **语义化命名**：文件名应清楚表达其功能和用途
3. **一致性**：整个项目保持统一的命名风格
4. **可读性**：文件名应易于理解和记忆

## 文件命名规范

### 1. Dart文件命名

#### 页面文件 (Pages)
```
格式: {功能}_{page}.dart
示例:
- home_page.dart
- category_page.dart
- user_profile_page.dart
- settings_page.dart
- theme_settings_page.dart
```

#### 组件文件 (Widgets)
```
格式: {功能}_{widget}.dart
示例:
- app_drawer_widget.dart
- loading_indicator_widget.dart
- custom_button_widget.dart
- theme_selector_widget.dart
```

#### 服务文件 (Services)
```
格式: {功能}_service.dart
示例:
- theme_service.dart
- storage_service.dart
- api_service.dart
- navigation_service.dart
```

#### 模型文件 (Models)
```
格式: {实体}_model.dart
示例:
- user_model.dart
- theme_model.dart
- settings_model.dart
- category_model.dart
```

#### 提供者文件 (Providers)
```
格式: {功能}_provider.dart
示例:
- theme_provider.dart
- user_provider.dart
- settings_provider.dart
- navigation_provider.dart
```

#### 工具文件 (Utils)
```
格式: {功能}_utils.dart
示例:
- date_utils.dart
- string_utils.dart
- validation_utils.dart
- color_utils.dart
```

#### 常量文件 (Constants)
```
格式: {功能}_constants.dart
示例:
- app_constants.dart
- theme_constants.dart
- api_constants.dart
- ui_constants.dart
```

### 2. 目录命名规范

#### 核心目录 (Core)
```
core/
├── config/           # 配置文件
├── constants/        # 常量定义
├── services/         # 服务层
├── models/          # 数据模型
├── providers/       # 状态管理
├── utils/           # 工具类
└── theme/           # 主题相关
```

#### 展示层目录 (Presentation)
```
presentation/
├── pages/           # 页面
├── widgets/         # 组件
│   ├── common/      # 通用组件
│   ├── forms/       # 表单组件
│   ├── navigation/  # 导航组件
│   └── themed/      # 主题组件
└── dialogs/         # 对话框
```

#### 功能模块目录
```
features/
├── home/            # 首页功能
├── category/        # 分类功能
├── user/            # 用户功能
├── settings/        # 设置功能
└── theme/           # 主题功能
```

### 3. 类命名规范

#### 页面类
```dart
格式: {功能}Page
示例:
class HomePage extends StatelessWidget {}
class CategoryPage extends StatelessWidget {}
class UserProfilePage extends StatelessWidget {}
```

#### 组件类
```dart
格式: {功能}Widget
示例:
class AppDrawerWidget extends StatelessWidget {}
class LoadingIndicatorWidget extends StatelessWidget {}
class CustomButtonWidget extends StatelessWidget {}
```

#### 服务类
```dart
格式: {功能}Service
示例:
class ThemeService {}
class StorageService {}
class ApiService {}
```

#### 模型类
```dart
格式: {实体}Model
示例:
class UserModel {}
class ThemeModel {}
class SettingsModel {}
```

#### 提供者类
```dart
格式: {功能}Provider
示例:
class ThemeProvider extends StateNotifier<ThemeState> {}
class UserProvider extends StateNotifier<UserState> {}
```

### 4. 变量和函数命名

#### 私有变量
```dart
格式: _{camelCase}
示例:
String _userName;
bool _isLoading;
List<String> _categoryList;
```

#### 公共变量
```dart
格式: {camelCase}
示例:
String userName;
bool isLoading;
List<String> categoryList;
```

#### 函数
```dart
格式: {camelCase}
示例:
void loadUserData() {}
bool validateInput() {}
String formatDate() {}
```

#### 常量
```dart
格式: {UPPER_SNAKE_CASE}
示例:
const String API_BASE_URL = 'https://api.example.com';
const int MAX_RETRY_COUNT = 3;
const double DEFAULT_PADDING = 16.0;
```

## 文件重命名计划

### 当前文件 → 新文件名

#### 页面文件
- `main_screen.dart` → `main_screen_page.dart`
- `home_page.dart` → `home_page.dart` ✓ (已符合规范)
- `category_page.dart` → `category_page.dart` ✓ (已符合规范)
- `user_page.dart` → `user_profile_page.dart`
- `settings_page.dart` → `settings_page.dart` ✓ (已符合规范)
- `theme_settings_page.dart` → `theme_settings_page.dart` ✓ (已符合规范)

#### 组件文件
- `app_drawer.dart` → `app_drawer_widget.dart`
- `common_widgets.dart` → `common_widgets.dart` ✓ (已符合规范)

#### 提供者文件
- `app_providers.dart` → `app_providers.dart` ✓ (已符合规范)
- `theme_provider.dart` → `theme_provider.dart` ✓ (已符合规范)

#### 主题文件
- `app_colors.dart` → `app_colors.dart` ✓ (已符合规范)
- `theme_manager.dart` → `theme_service.dart`

## 实施步骤

1. **创建规范文档** ✓
2. **分析现有文件命名**
3. **重命名不符合规范的文件**
4. **更新所有import语句**
5. **验证重命名后的功能正常**

## 注意事项

1. **向后兼容性**：重命名时要确保所有引用都已更新
2. **测试验证**：重命名后要运行测试确保功能正常
3. **文档更新**：更新相关文档中的文件引用
4. **团队协作**：确保团队成员了解新的命名规范

## 工具支持

可以使用以下工具辅助重命名：

1. **IDE重构功能**：使用IDE的重构功能进行安全重命名
2. **搜索替换**：使用全局搜索替换更新import语句
3. **Git跟踪**：使用Git跟踪重命名操作

## 维护指南

1. **新文件创建**：严格按照本规范创建新文件
2. **代码审查**：在代码审查中检查命名规范
3. **定期检查**：定期检查项目中的命名一致性
4. **文档更新**：及时更新本规范文档
