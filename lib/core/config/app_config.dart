/// 应用程序配置和常量类
///
/// 使用静态常量定义所有配置项，确保全局一致性
/// 所有配置项都应该是不可变的常量
library;

import 'package:flutter/material.dart';

class AppConfig {
  // ==================== 应用信息 ====================
  static const String appName = 'Flutter UI模板';
  static const String appVersion = '1.0.0';
  static const String appDescription = '基于可可世界设计的Flutter UI模板项目';

  // ==================== 设计稿配置 ====================
  static const double designWidth = 393.0;
  static const double designHeight = 852.0;
  static const bool minTextAdapt = true;
  static const bool splitScreenMode = true;

  // ==================== 动画配置 ====================
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // ==================== 存储键 ====================
  static const String selectedThemeKey = 'selected_theme';
  static const String userPreferencesKey = 'user_preferences';
  static const String appSettingsKey = 'app_settings';

  // ==================== 路由配置 ====================
  static const String homeRoute = '/';
  static const String settingsRoute = '/settings';
  static const String themeSettingsRoute = '/settings/theme';
  static const String categoryRoute = '/category';
  static const String userProfileRoute = '/user';

  // ==================== 主题配置 ====================
  static const String defaultTheme = 'system';
  static const String lightTheme = 'light';
  static const String darkTheme = 'dark';

  // ==================== 本地化配置 ====================
  static const String defaultLocale = 'zh';
  static const String englishLocale = 'en';

  // ==================== 网络配置 ====================
  static const int connectionTimeout = 30000; // 30秒
  static const int receiveTimeout = 30000; // 30秒

  // ==================== 分页配置 ====================
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ==================== 缓存配置 ====================
  static const int cacheExpirationDays = 7;
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB

  // ==================== UI配置 ====================
  // 间距配置
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double tinySpacing = 4.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double hugeSpacing = 32.0;

  // 圆角配置
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;

  // 阴影配置
  static const double defaultElevation = 2.0;
  static const double highElevation = 8.0;

  // 颜色透明度
  static const double lightAlpha = 0.1;
  static const double mediumAlpha = 0.3;
  static const double highAlpha = 0.5;
  static const double fullAlpha = 1.0;

  // 字体大小
  static const double smallFontSize = 12.0;
  static const double mediumFontSize = 14.0;
  static const double largeFontSize = 16.0;
  static const double titleFontSize = 18.0;
  static const double headlineFontSize = 20.0;

  // 字体权重
  static const FontWeight lightWeight = FontWeight.w300;
  static const FontWeight normalWeight = FontWeight.w400;
  static const FontWeight mediumWeight = FontWeight.w500;
  static const FontWeight semiBoldWeight = FontWeight.w600;
  static const FontWeight boldWeight = FontWeight.w700;

  // 图标大小
  static const double smallIconSize = 16.0;
  static const double mediumIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double hugeIconSize = 48.0;

  // 头像大小
  static const double smallAvatarSize = 32.0;
  static const double mediumAvatarSize = 48.0;
  static const double largeAvatarSize = 64.0;
  static const double hugeAvatarSize = 96.0;

  // 按钮高度
  static const double smallButtonHeight = 32.0;
  static const double mediumButtonHeight = 48.0;
  static const double largeButtonHeight = 56.0;

  // 输入框高度
  static const double smallInputHeight = 40.0;
  static const double mediumInputHeight = 48.0;
  static const double largeInputHeight = 56.0;

  // 卡片配置
  static const double cardElevation = 2.0;
  static const double cardRadius = 12.0;
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);

  // 列表配置
  static const double listItemHeight = 56.0;
  static const double listItemPadding = 16.0;

  // 网格配置
  static const int defaultGridColumns = 2;
  static const double gridSpacing = 12.0;
  static const double gridChildAspectRatio = 1.5;
}
