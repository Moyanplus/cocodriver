import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// 主题类型枚举
enum ThemeType {
  system, // 跟随系统
  light, // 浅色主题
  dark, // 深色主题
  // 高级主题
  hawaiianNight, // 夏威夷夜晚
  yuanShanQingDai, // 远山青黛
  seaSaltCheese, // 海盐芝士
  crabapple, // 海棠依旧
  icelandSunrise, // 冰岛日出
  lavender, // 薰衣草
  forgetMeNot, // 勿忘草
  daisy, // 雏菊
  freshOrange, // 鲜橙
  cherryBlossom, // 樱粉
  rainbowBlue, // 虹蓝
  springGreen, // 春绿
  midsummer, // 盛夏
  coolAutumn, // 凉秋
  clearWinter, // 清冬
}

/// 主题服务
class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  ThemeType _currentTheme = ThemeType.system;
  ThemeType get currentTheme => _currentTheme;

  /// 获取指定主题类型的 ThemeData
  ThemeData getTheme(ThemeType type) {
    switch (type) {
      case ThemeType.system:
        return _getSystemTheme();
      case ThemeType.light:
        return _getLightTheme();
      case ThemeType.dark:
        return _getDarkTheme();
      case ThemeType.hawaiianNight:
        return _getHawaiianNightTheme();
      case ThemeType.yuanShanQingDai:
        return _getYuanShanQingDaiTheme();
      case ThemeType.seaSaltCheese:
        return _getSeaSaltCheeseTheme();
      case ThemeType.crabapple:
        return _getCrabappleTheme();
      case ThemeType.icelandSunrise:
        return _getIcelandSunriseTheme();
      case ThemeType.lavender:
        return _getLavenderTheme();
      case ThemeType.forgetMeNot:
        return _getForgetMeNotTheme();
      case ThemeType.daisy:
        return _getDaisyTheme();
      case ThemeType.freshOrange:
        return _getFreshOrangeTheme();
      case ThemeType.cherryBlossom:
        return _getCherryBlossomTheme();
      case ThemeType.rainbowBlue:
        return _getRainbowBlueTheme();
      case ThemeType.springGreen:
        return _getSpringGreenTheme();
      case ThemeType.midsummer:
        return _getMidsummerTheme();
      case ThemeType.coolAutumn:
        return _getCoolAutumnTheme();
      case ThemeType.clearWinter:
        return _getClearWinterTheme();
    }
  }

  /// 设置当前主题类型
  void setTheme(ThemeType type) {
    _currentTheme = type;
  }

  /// 获取主题信息
  ThemeInfo getThemeInfo(ThemeType type) {
    switch (type) {
      case ThemeType.system:
        return ThemeInfo(
          name: '跟随系统',
          description: '自动跟随系统主题设置',
          icon: Icons.brightness_auto,
          color: AppColors.grey,
          isPremium: false,
        );
      case ThemeType.light:
        return ThemeInfo(
          name: '浅色主题',
          description: '经典浅色主题',
          icon: Icons.light_mode,
          color: AppColors.amber,
          isPremium: false,
        );
      case ThemeType.dark:
        return ThemeInfo(
          name: '深色主题',
          description: '护眼深色主题',
          icon: Icons.dark_mode,
          color: AppColors.indigo,
          isPremium: false,
        );
      case ThemeType.hawaiianNight:
        return ThemeInfo(
          name: '夏威夷夜晚',
          description: '热带夜晚风情',
          icon: Icons.nightlife,
          color: AppColors.tropicalPink,
          isPremium: true,
        );
      case ThemeType.yuanShanQingDai:
        return ThemeInfo(
          name: '远山青黛',
          description: '山水画意境',
          icon: Icons.landscape,
          color: AppColors.mountainBlue,
          isPremium: true,
        );
      case ThemeType.seaSaltCheese:
        return ThemeInfo(
          name: '海盐芝士',
          description: '清新海洋风味',
          icon: Icons.beach_access,
          color: AppColors.skyBlue,
          isPremium: true,
        );
      case ThemeType.crabapple:
        return ThemeInfo(
          name: '海棠依旧',
          description: '古典诗意主题',
          icon: Icons.local_florist,
          color: AppColors.tropicalPink,
          isPremium: true,
        );
      case ThemeType.icelandSunrise:
        return ThemeInfo(
          name: '冰岛日出',
          description: '北欧极光风情',
          icon: Icons.ac_unit,
          color: AppColors.mintGreen,
          isPremium: true,
        );
      case ThemeType.lavender:
        return ThemeInfo(
          name: '薰衣草',
          description: '普罗旺斯风情',
          icon: Icons.spa,
          color: AppColors.lavender,
          isPremium: true,
        );
      case ThemeType.forgetMeNot:
        return ThemeInfo(
          name: '勿忘草',
          description: '浪漫花语主题',
          icon: Icons.favorite_border,
          color: AppColors.blue,
          isPremium: true,
        );
      case ThemeType.daisy:
        return ThemeInfo(
          name: '雏菊',
          description: '田园清新主题',
          icon: Icons.eco,
          color: AppColors.lightGreen,
          isPremium: false,
        );
      case ThemeType.freshOrange:
        return ThemeInfo(
          name: '鲜橙',
          description: '活力柑橘主题',
          icon: Icons.local_dining,
          color: AppColors.orange,
          isPremium: false,
        );
      case ThemeType.cherryBlossom:
        return ThemeInfo(
          name: '樱粉',
          description: '樱花季节主题',
          icon: Icons.local_florist,
          color: AppColors.cherryPink,
          isPremium: false,
        );
      case ThemeType.rainbowBlue:
        return ThemeInfo(
          name: '虹蓝',
          description: '彩虹蓝色主题',
          icon: Icons.color_lens,
          color: AppColors.blue,
          isPremium: false,
        );
      case ThemeType.springGreen:
        return ThemeInfo(
          name: '春绿',
          description: '春天绿色主题',
          icon: Icons.grass,
          color: AppColors.springGreen,
          isPremium: false,
        );
      case ThemeType.midsummer:
        return ThemeInfo(
          name: '盛夏',
          description: '夏日炎炎主题',
          icon: Icons.wb_sunny,
          color: AppColors.orange,
          isPremium: false,
        );
      case ThemeType.coolAutumn:
        return ThemeInfo(
          name: '凉秋',
          description: '秋高气爽主题',
          icon: Icons.eco,
          color: AppColors.brown,
          isPremium: false,
        );
      case ThemeType.clearWinter:
        return ThemeInfo(
          name: '清冬',
          description: '冬日清冷主题',
          icon: Icons.ac_unit,
          color: AppColors.grey,
          isPremium: false,
        );
    }
  }

  /// 获取所有主题类型列表
  List<ThemeType> getAllThemes() => ThemeType.values;

  // 私有方法：获取各种主题的 ThemeData
  ThemeData _getSystemTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
      primaryIconTheme: IconThemeData(color: colorScheme.onPrimary, size: 24),
      splashColor: AppColors.blue.withValues(alpha: 0.3),
      highlightColor: AppColors.blue.withValues(alpha: 0.2),
    );
  }

  ThemeData _getLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
      primaryIconTheme: IconThemeData(color: colorScheme.onPrimary, size: 24),
      splashColor: AppColors.blue.withValues(alpha: 0.3),
      highlightColor: AppColors.blue.withValues(alpha: 0.2),
    );
  }

  ThemeData _getDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.indigo,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
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
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
      primaryIconTheme: IconThemeData(color: colorScheme.onPrimary, size: 24),
      splashColor: AppColors.indigo.withValues(alpha: 0.3),
      highlightColor: AppColors.indigo.withValues(alpha: 0.2),
    );
  }

  // 其他主题的简化实现
  ThemeData _getHawaiianNightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.tropicalPink,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.tropicalPink.withValues(alpha: 0.3),
      highlightColor: AppColors.tropicalPink.withValues(alpha: 0.2),
    );
  }

  ThemeData _getYuanShanQingDaiTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.mountainBlue,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.mountainBlue.withValues(alpha: 0.3),
      highlightColor: AppColors.mountainBlue.withValues(alpha: 0.2),
    );
  }

  ThemeData _getSeaSaltCheeseTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.skyBlue,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.skyBlue.withValues(alpha: 0.3),
      highlightColor: AppColors.skyBlue.withValues(alpha: 0.2),
    );
  }

  ThemeData _getCrabappleTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.tropicalPink,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.tropicalPink.withValues(alpha: 0.3),
      highlightColor: AppColors.tropicalPink.withValues(alpha: 0.2),
    );
  }

  ThemeData _getIcelandSunriseTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.mintGreen,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.mintGreen.withValues(alpha: 0.3),
      highlightColor: AppColors.mintGreen.withValues(alpha: 0.2),
    );
  }

  ThemeData _getLavenderTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.lavender,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.lavender.withValues(alpha: 0.3),
      highlightColor: AppColors.lavender.withValues(alpha: 0.2),
    );
  }

  ThemeData _getForgetMeNotTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.blue.withValues(alpha: 0.3),
      highlightColor: AppColors.blue.withValues(alpha: 0.2),
    );
  }

  ThemeData _getDaisyTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.lightGreen,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.lightGreen.withValues(alpha: 0.3),
      highlightColor: AppColors.lightGreen.withValues(alpha: 0.2),
    );
  }

  ThemeData _getFreshOrangeTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.orange.withValues(alpha: 0.3),
      highlightColor: AppColors.orange.withValues(alpha: 0.2),
    );
  }

  ThemeData _getCherryBlossomTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.cherryPink,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.cherryPink.withValues(alpha: 0.3),
      highlightColor: AppColors.cherryPink.withValues(alpha: 0.2),
    );
  }

  ThemeData _getRainbowBlueTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.blue.withValues(alpha: 0.3),
      highlightColor: AppColors.blue.withValues(alpha: 0.2),
    );
  }

  ThemeData _getSpringGreenTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.springGreen,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.springGreen.withValues(alpha: 0.3),
      highlightColor: AppColors.springGreen.withValues(alpha: 0.2),
    );
  }

  ThemeData _getMidsummerTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.orange.withValues(alpha: 0.3),
      highlightColor: AppColors.orange.withValues(alpha: 0.2),
    );
  }

  ThemeData _getCoolAutumnTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brown,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.brown.withValues(alpha: 0.3),
      highlightColor: AppColors.brown.withValues(alpha: 0.2),
    );
  }

  ThemeData _getClearWinterTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.grey,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
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
      ),
      splashColor: AppColors.grey.withValues(alpha: 0.3),
      highlightColor: AppColors.grey.withValues(alpha: 0.2),
    );
  }
}

/// 主题信息类
class ThemeInfo {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isPremium;

  ThemeInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isPremium = false,
  });
}
