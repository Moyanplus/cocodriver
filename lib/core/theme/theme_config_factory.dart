import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/theme_service.dart';
import 'app_colors.dart';

/// 主题配置工厂
/// 负责创建和缓存主题配置，避免重复创建
class ThemeConfigFactory {
  // 主题数据缓存
  static final Map<ThemeType, ThemeData> _themeCache = {};

  // 字体主题缓存
  static TextTheme? _lightTextTheme;
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
      return _darkTextTheme ??= GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      );
    } else {
      return _lightTextTheme ??= GoogleFonts.interTextTheme();
    }
  }

  /// 创建应用栏主题
  static AppBarTheme _createAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onPrimary,
      ),
      toolbarTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onPrimary,
      ),
    );
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
