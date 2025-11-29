/// 主题配置工厂类
///
/// 负责创建和缓存主题配置，避免重复创建，提高性能
/// 使用工厂模式和缓存机制，支持多种主题类型的快速切换
///
/// 主要功能：
/// - 主题数据创建和缓存
/// - 字体主题管理
/// - 主题切换优化
/// - 内存管理
/// - 主题配置生成
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme_models.dart';

/// 主题配置工厂类
///
/// 负责创建和缓存主题配置，避免重复创建，提高性能
/// 使用工厂模式和缓存机制，支持多种主题类型的快速切换
class ThemeConfigFactory {
  // 主题数据缓存映射
  static final Map<ThemeType, ThemeData> _themeCache = {};

  // 浅色字体主题缓存
  static TextTheme? _lightTextTheme;

  // 深色字体主题缓存
  static TextTheme? _darkTextTheme;

  /// 获取指定主题类型的 ThemeData
  /// 使用缓存机制避免重复创建
  static ThemeData getTheme(ThemeType type) {
    return _themeCache.putIfAbsent(type, () => _createTheme(type));
  }

  /// 清除主题缓存
  /// 在内存不足或需要重新加载时调用
  static void clearCache() {
    _themeCache.clear();
    _lightTextTheme = null;
    _darkTextTheme = null;
  }

  /// 获取缓存的主题数量
  static int get cacheSize => _themeCache.length;

  /// 创建主题数据
  static ThemeData _createTheme(ThemeType type) {
    final colorScheme = _getColorScheme(type);
    final brightness = colorScheme.brightness;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _getTextTheme(brightness),
      appBarTheme: _createAppBarTheme(colorScheme),
      iconTheme: _createIconTheme(colorScheme),
      primaryIconTheme: _createPrimaryIconTheme(colorScheme),
      splashColor: _getSplashColor(type).withValues(alpha: 0.3),
      highlightColor: _getSplashColor(type).withValues(alpha: 0.2),
    );
  }

  /// 获取颜色方案
  static ColorScheme _getColorScheme(ThemeType type) {
    switch (type) {
      case ThemeType.system:
        return ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: Brightness.light,
        );
      case ThemeType.light:
        return ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: Brightness.light,
        );
      case ThemeType.dark:
        return ColorScheme.fromSeed(
          seedColor: AppColors.indigo,
          brightness: Brightness.dark,
        );
      case ThemeType.hawaiianNight:
        return ColorScheme.fromSeed(
          seedColor: AppColors.tropicalPink,
          brightness: Brightness.light,
        );
      case ThemeType.yuanShanQingDai:
        return ColorScheme.fromSeed(
          seedColor: AppColors.mountainBlue,
          brightness: Brightness.light,
        );
      case ThemeType.seaSaltCheese:
        return ColorScheme.fromSeed(
          seedColor: AppColors.skyBlue,
          brightness: Brightness.light,
        );
      case ThemeType.crabapple:
        return ColorScheme.fromSeed(
          seedColor: AppColors.tropicalPink,
          brightness: Brightness.light,
        );
      case ThemeType.icelandSunrise:
        return ColorScheme.fromSeed(
          seedColor: AppColors.mintGreen,
          brightness: Brightness.light,
        );
      case ThemeType.lavender:
        return ColorScheme.fromSeed(
          seedColor: AppColors.lavender,
          brightness: Brightness.light,
        );
      case ThemeType.forgetMeNot:
        return ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: Brightness.light,
        );
      case ThemeType.daisy:
        return ColorScheme.fromSeed(
          seedColor: AppColors.lightGreen,
          brightness: Brightness.light,
        );
      case ThemeType.freshOrange:
        return ColorScheme.fromSeed(
          seedColor: AppColors.orange,
          brightness: Brightness.light,
        );
      case ThemeType.cherryBlossom:
        return ColorScheme.fromSeed(
          seedColor: AppColors.cherryPink,
          brightness: Brightness.light,
        );
      case ThemeType.rainbowBlue:
        return ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: Brightness.light,
        );
      case ThemeType.springGreen:
        return ColorScheme.fromSeed(
          seedColor: AppColors.springGreen,
          brightness: Brightness.light,
        );
      case ThemeType.midsummer:
        return ColorScheme.fromSeed(
          seedColor: AppColors.orange,
          brightness: Brightness.light,
        );
      case ThemeType.coolAutumn:
        return ColorScheme.fromSeed(
          seedColor: AppColors.brown,
          brightness: Brightness.light,
        );
      case ThemeType.clearWinter:
        return ColorScheme.fromSeed(
          seedColor: AppColors.grey,
          brightness: Brightness.light,
        );
    }
  }

  /// 获取文字主题（带缓存）
  static TextTheme _getTextTheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return _darkTextTheme ??= _createTextTheme(ThemeData.dark().textTheme);
    } else {
      return _lightTextTheme ??= _createTextTheme(ThemeData.light().textTheme);
    }
  }

  /// 创建文字主题，支持离线模式
  static TextTheme _createTextTheme(TextTheme baseTheme) {
    try {
      // 尝试使用Google Fonts
      return GoogleFonts.interTextTheme(baseTheme);
    } catch (e) {
      // 如果Google Fonts加载失败，使用系统默认字体
      return baseTheme;
    }
  }

  /// 创建应用栏主题
  static AppBarTheme _createAppBarTheme(ColorScheme colorScheme) {
    // 根据主题亮度选择合适的颜色
    final bool isDark = colorScheme.brightness == Brightness.dark;
    final Color foregroundColor =
        isDark ? colorScheme.onSurface : colorScheme.onSurface;

    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: foregroundColor,
      elevation: 0,
      scrolledUnderElevation: 3,
      iconTheme: IconThemeData(color: foregroundColor),
      actionsIconTheme: IconThemeData(color: foregroundColor),
      titleTextStyle: _createTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: foregroundColor,
      ),
      toolbarTextStyle: _createTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: foregroundColor,
      ),
    );
  }

  /// 创建文字样式，支持离线模式
  static TextStyle _createTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    try {
      // 尝试使用Google Fonts
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    } catch (e) {
      // 如果Google Fonts加载失败，使用系统默认字体
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }
  }

  /// 创建图标主题
  static IconThemeData _createIconTheme(ColorScheme colorScheme) {
    return IconThemeData(color: colorScheme.onSurface, size: 24);
  }

  /// 创建主图标主题
  static IconThemeData _createPrimaryIconTheme(ColorScheme colorScheme) {
    return IconThemeData(color: colorScheme.onPrimary, size: 24);
  }

  /// 获取主题对应的主色调
  static Color _getSplashColor(ThemeType type) {
    switch (type) {
      case ThemeType.system:
      case ThemeType.light:
      case ThemeType.forgetMeNot:
      case ThemeType.rainbowBlue:
        return AppColors.blue;
      case ThemeType.dark:
        return AppColors.indigo;
      case ThemeType.hawaiianNight:
      case ThemeType.crabapple:
        return AppColors.tropicalPink;
      case ThemeType.yuanShanQingDai:
        return AppColors.mountainBlue;
      case ThemeType.seaSaltCheese:
        return AppColors.skyBlue;
      case ThemeType.icelandSunrise:
        return AppColors.mintGreen;
      case ThemeType.lavender:
        return AppColors.lavender;
      case ThemeType.daisy:
        return AppColors.lightGreen;
      case ThemeType.freshOrange:
      case ThemeType.midsummer:
        return AppColors.orange;
      case ThemeType.cherryBlossom:
        return AppColors.cherryPink;
      case ThemeType.springGreen:
        return AppColors.springGreen;
      case ThemeType.coolAutumn:
        return AppColors.brown;
      case ThemeType.clearWinter:
        return AppColors.grey;
    }
  }
}
