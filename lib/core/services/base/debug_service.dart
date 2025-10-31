import 'package:flutter/foundation.dart';

/// 调试分类枚举
enum DebugCategory {
  /// 通用调试
  general,

  /// 系统相关
  system,

  /// 主题相关
  theme,

  /// 用户管理
  user,

  /// 网络请求
  network,

  /// 状态管理
  state,

  /// 性能监控
  performance,

  /// 文件操作
  file,

  /// 缓存管理
  cache,

  /// 路由导航
  navigation,

  /// 工具功能
  tools,

  /// 其他
  other,
}

/// 调试服务 - 支持分类控制
class DebugService {
  static const String _prefix = '[DEBUG]';

  /// 调试开关 - 总开关
  static bool _isDebugEnabled = true;

  /// 分类调试开关 - 可以单独控制每个分类
  static final Map<DebugCategory, bool> _categorySwitches = {
    DebugCategory.general: true,
    DebugCategory.system: true,
    DebugCategory.theme: false,
    DebugCategory.user: true,
    DebugCategory.network: false,
    DebugCategory.state: false,
    DebugCategory.performance: false,
    DebugCategory.file: false,
    DebugCategory.cache: false,
    DebugCategory.navigation: false,
    DebugCategory.tools: true,
    DebugCategory.other: false,
  };

  /// 子分类控制 - 支持多级分类
  static final Map<String, bool> _subCategorySwitches = {
    // 工具分类的子分类
    'cloudDrive': true, // 工具-云盘助手
    'cloudDrive.lanzou': true, // 工具-云盘助手-蓝奏云
    'cloudDrive.baidu': true, // 工具-云盘助手-百度网盘
    'cloudDrive.ali': true, // 工具-云盘助手-阿里云盘
    'cloudDrive.pan123': true, // 工具-云盘助手-123云盘
    'cloudDrive.quark': true, // 工具-云盘助手-夸克云盘
    // token解析器子分类
    'tokenParser': true, // 工具-token解析器
    'tokenParser.ali': true, // 工具-token解析器-阿里云盘
    'tokenParser.baidu': true, // 工具-token解析器-百度网盘
    'tokenParser.lanzou': true, // 工具-token解析器-蓝奏云
    'tokenParser.pan123': true, // 工具-token解析器-123云盘
    'tokenParser.quark': true, // 工具-token解析器-夸克云盘
    // 其他工具子分类
    'imageConverter': false, // 工具-图片转换
    'videoConverter': false, // 工具-视频转换
    'qrCode': false, // 工具-二维码
  };

  /// 启用指定分类的调试日志
  static void enableCategory(DebugCategory category) {
    _categorySwitches[category] = true;
  }

  /// 禁用指定分类的调试日志
  static void disableCategory(DebugCategory category) {
    _categorySwitches[category] = false;
  }

  /// 启用指定子分类的调试日志
  static void enableSubCategory(String subCategory) {
    _subCategorySwitches[subCategory] = true;
  }

  /// 禁用指定子分类的调试日志
  static void disableSubCategory(String subCategory) {
    _subCategorySwitches[subCategory] = false;
  }

  /// 启用云盘助手相关的所有调试日志
  static void enableCloudDriveLogs() {
    enableCategory(DebugCategory.tools);
    enableSubCategory('cloudDrive');
    enableSubCategory('cloudDrive.lanzou');
    enableSubCategory('cloudDrive.baidu');
    enableSubCategory('cloudDrive.ali');
    enableSubCategory('cloudDrive.pan123');
    enableSubCategory('cloudDrive.quark');
  }

  /// 禁用云盘助手相关的所有调试日志
  static void disableCloudDriveLogs() {
    disableSubCategory('cloudDrive');
    disableSubCategory('cloudDrive.lanzou');
    disableSubCategory('cloudDrive.baidu');
    disableSubCategory('cloudDrive.ali');
    disableSubCategory('cloudDrive.pan123');
    disableSubCategory('cloudDrive.quark');
  }

  /// 启用Token解析器相关的所有调试日志
  static void enableTokenParserLogs() {
    enableCategory(DebugCategory.tools);
    enableSubCategory('tokenParser');
    enableSubCategory('tokenParser.ali');
    enableSubCategory('tokenParser.baidu');
    enableSubCategory('tokenParser.lanzou');
    enableSubCategory('tokenParser.pan123');
    enableSubCategory('tokenParser.quark');
  }

  /// 禁用Token解析器相关的所有调试日志
  static void disableTokenParserLogs() {
    disableSubCategory('tokenParser');
    disableSubCategory('tokenParser.ali');
    disableSubCategory('tokenParser.baidu');
    disableSubCategory('tokenParser.lanzou');
    disableSubCategory('tokenParser.pan123');
    disableSubCategory('tokenParser.quark');
  }

  /// 启用云盘助手和Token解析器的所有调试日志
  static void enableAllCloudDriveAndTokenLogs() {
    enableCloudDriveLogs();
    enableTokenParserLogs();
  }

  /// 检查子分类是否启用
  static bool _isSubCategoryEnabled(String subCategory) =>
      _subCategorySwitches[subCategory] ?? false;

  /// 获取分类图标
  static String _getCategoryIcon(DebugCategory category) {
    switch (category) {
      case DebugCategory.general:
        return 'GENERAL';
      case DebugCategory.system:
        return 'SYSTEM';
      case DebugCategory.theme:
        return 'THEME';
      case DebugCategory.user:
        return 'USER';
      case DebugCategory.network:
        return 'NETWORK';
      case DebugCategory.state:
        return 'STATE';
      case DebugCategory.performance:
        return 'PERF';
      case DebugCategory.file:
        return 'FILE';
      case DebugCategory.cache:
        return 'CACHE';
      case DebugCategory.navigation:
        return 'NAV';
      case DebugCategory.tools:
        return 'TOOLS';
      case DebugCategory.other:
        return 'OTHER';
    }
  }

  /// 获取分类名称
  static String _getCategoryName(DebugCategory category) {
    switch (category) {
      case DebugCategory.general:
        return 'GENERAL';
      case DebugCategory.system:
        return 'SYSTEM';
      case DebugCategory.theme:
        return 'THEME';
      case DebugCategory.user:
        return 'USER';
      case DebugCategory.network:
        return 'NETWORK';
      case DebugCategory.state:
        return 'STATE';
      case DebugCategory.performance:
        return 'PERFORMANCE';
      case DebugCategory.file:
        return 'FILE';
      case DebugCategory.cache:
        return 'CACHE';
      case DebugCategory.navigation:
        return 'NAVIGATION';
      case DebugCategory.tools:
        return 'TOOLS';
      case DebugCategory.other:
        return 'OTHER';
    }
  }

  /// 检查是否应该输出调试信息
  static bool _shouldLog(DebugCategory category) =>
      _isDebugEnabled && (_categorySwitches[category] ?? true);

  /// 输出调试信息
  static void log(
    String message, {
    DebugCategory category = DebugCategory.general,
    String? subCategory,
  }) {
    if (!_shouldLog(category)) return;

    // 如果有子分类，检查子分类是否启用
    if (subCategory != null && !_isSubCategoryEnabled(subCategory)) {
      return;
    }

    final categoryName = _getCategoryName(category);
    final timestamp = DateTime.now().toString().substring(11, 19); // HH:MM:SS

    if (kDebugMode) {
      print('[$categoryName][$subCategory][$timestamp] $message');
    }
  }

  /// 输出带子分类的调试信息（通用方法）
  static void subLog(
    String message,
    String subCategory, {
    DebugCategory category = DebugCategory.general,
  }) {
    log(message, category: category, subCategory: subCategory);
  }

  /// 输出错误信息
  static void error(
    String message,
    Object? error, {
    DebugCategory category = DebugCategory.general,
    String? subCategory,
  }) {
    if (!_shouldLog(category)) return;

    // 如果有子分类，检查子分类是否启用
    if (subCategory != null && !_isSubCategoryEnabled(subCategory)) {
      return;
    }

    final icon = _getCategoryIcon(category);
    final categoryName = _getCategoryName(category);
    final timestamp = DateTime.now().toString().substring(11, 19);

    if (kDebugMode) {
      final errorInfo = error != null ? ' - $error' : '';
      final subCategoryInfo = subCategory != null ? '[$subCategory]' : '';
      print(
        '$_prefix $icon [$categoryName]$subCategoryInfo [$timestamp] ERROR: $message$errorInfo',
      );
    }
  }

  /// 输出警告信息
  static void warning(
    String message, {
    DebugCategory category = DebugCategory.general,
    String? subCategory,
  }) {
    if (!_shouldLog(category)) return;

    // 如果有子分类，检查子分类是否启用
    if (subCategory != null && !_isSubCategoryEnabled(subCategory)) {
      return;
    }

    final icon = _getCategoryIcon(category);
    final categoryName = _getCategoryName(category);
    final timestamp = DateTime.now().toString().substring(11, 19);

    if (kDebugMode) {
      final subCategoryInfo = subCategory != null ? '[$subCategory]' : '';
      print(
        '$_prefix $icon [$categoryName]$subCategoryInfo [$timestamp] WARNING: $message',
      );
    }
  }

  /// 输出信息（兼容旧接口）
  static void info(
    String message, {
    DebugCategory category = DebugCategory.general,
    String? subCategory,
  }) {
    log(message, category: category, subCategory: subCategory);
  }

  /// 输出API请求信息
  static void apiRequest(
    String method,
    String url, {
    Map<String, String>? headers,
    String? body,
    DebugCategory category = DebugCategory.network,
    String? subCategory,
  }) {
    if (!_shouldLog(category)) return;

    // 如果有子分类，检查子分类是否启用
    if (subCategory != null && !_isSubCategoryEnabled(subCategory)) {
      return;
    }

    final icon = _getCategoryIcon(category);
    final categoryName = _getCategoryName(category);
    final timestamp = DateTime.now().toString().substring(11, 19);

    if (kDebugMode) {
      final headerInfo = headers != null ? ' - Headers: $headers' : '';
      final bodyInfo = body != null ? ' - Body: $body' : '';
      final subCategoryInfo = subCategory != null ? '[$subCategory]' : '';
      print(
        '$_prefix $icon [$categoryName]$subCategoryInfo [$timestamp] API REQUEST: $method $url$headerInfo$bodyInfo',
      );
    }
  }

  /// 输出API响应信息
  static void apiResponse(
    int statusCode,
    String body, {
    DebugCategory category = DebugCategory.network,
    String? subCategory,
  }) {
    if (!_shouldLog(category)) return;

    // 如果有子分类，检查子分类是否启用
    if (subCategory != null && !_isSubCategoryEnabled(subCategory)) {
      return;
    }

    final icon = _getCategoryIcon(category);
    final categoryName = _getCategoryName(category);
    final timestamp = DateTime.now().toString().substring(11, 19);

    if (kDebugMode) {
      final statusIcon = statusCode >= 200 && statusCode < 300 ? 'OK' : 'ERROR';
      final subCategoryInfo = subCategory != null ? '[$subCategory]' : '';
      print(
        '$_prefix $icon [$categoryName]$subCategoryInfo [$timestamp] API RESPONSE: $statusIcon $statusCode - Body: ${body.length > 200 ? '${body.substring(0, 200)}...' : body}',
      );
    }
  }

  /// 输出成功信息
  static void success(
    String message, {
    DebugCategory category = DebugCategory.general,
    String? subCategory,
  }) {
    if (!_shouldLog(category)) return;

    // 如果有子分类，检查子分类是否启用
    if (subCategory != null && !_isSubCategoryEnabled(subCategory)) {
      return;
    }

    final icon = _getCategoryIcon(category);
    final categoryName = _getCategoryName(category);
    final timestamp = DateTime.now().toString().substring(11, 19);

    if (kDebugMode) {
      final subCategoryInfo = subCategory != null ? '[$subCategory]' : '';
      print(
        '$_prefix $icon [$categoryName]$subCategoryInfo [$timestamp] SUCCESS: $message',
      );
    }
  }

  /// 设置总调试开关
  static void setDebugEnabled(bool enabled) {
    _isDebugEnabled = enabled;
    log('总调试开关: ${enabled ? "开启" : "关闭"}', category: DebugCategory.general);
  }

  /// 设置分类调试开关
  static void setCategoryEnabled(DebugCategory category, bool enabled) {
    _categorySwitches[category] = enabled;
    log(
      '${_getCategoryName(category)} 调试开关: ${enabled ? "开启" : "关闭"}',
      category: DebugCategory.general,
    );
  }

  /// 设置多个分类调试开关
  static void setCategoriesEnabled(Map<DebugCategory, bool> switches) {
    switches.forEach((category, enabled) {
      _categorySwitches[category] = enabled;
    });
    log('批量设置分类调试开关完成', category: DebugCategory.general);
  }

  /// 获取当前调试状态
  static Map<String, bool> getDebugStatus() {
    final status = <String, bool>{};
    status['总开关'] = _isDebugEnabled;
    _categorySwitches.forEach((category, enabled) {
      status[_getCategoryName(category)] = enabled;
    });
    return status;
  }

  /// 开启所有分类
  static void enableAllCategories() {
    _categorySwitches.forEach((category, _) {
      _categorySwitches[category] = true;
    });
    log('已开启所有分类调试', category: DebugCategory.general);
  }

  /// 关闭所有分类
  static void disableAllCategories() {
    _categorySwitches.forEach((category, _) {
      _categorySwitches[category] = false;
    });
    log('已关闭所有分类调试', category: DebugCategory.general);
  }

  /// 只开启指定分类
  static void enableOnlyCategories(List<DebugCategory> categories) {
    _categorySwitches.forEach((category, _) {
      _categorySwitches[category] = categories.contains(category);
    });
    log('已设置只开启指定分类调试', category: DebugCategory.general);
  }

  /// 快速关闭所有调试日志（用于生产环境或性能优化）
  static void disableAllLogs() {
    _isDebugEnabled = false;
    _categorySwitches.forEach((category, _) {
      _categorySwitches[category] = false;
    });
    _subCategorySwitches.forEach((subCategory, _) {
      _subCategorySwitches[subCategory] = false;
    });
  }

  /// 快速开启所有调试日志
  static void enableAllLogs() {
    _isDebugEnabled = true;
    _categorySwitches.forEach((category, _) {
      _categorySwitches[category] = true;
    });
    _subCategorySwitches.forEach((subCategory, _) {
      _subCategorySwitches[subCategory] = true;
    });
  }
}
