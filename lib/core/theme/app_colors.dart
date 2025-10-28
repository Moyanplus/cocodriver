/// 应用颜色定义类
///
/// 统一管理应用程序中使用的所有颜色，包括基础颜色、主题色、自定义色等
/// 提供一致的颜色方案，便于主题切换和维护
///
/// 主要功能：
/// - 基础颜色定义
/// - 主题主色管理
/// - 自定义颜色色系
/// - 颜色透明度控制
/// - 主题色彩搭配
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年

import 'package:flutter/material.dart';

/// 应用颜色定义类
///
/// 统一管理应用程序中使用的所有颜色，包括基础颜色、主题色、自定义色等
/// 提供一致的颜色方案，便于主题切换和维护
class AppColors {
  // 基础颜色
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  static const Color grey = Colors.grey;

  // 主题主色
  static const Color blue = Colors.blue;
  static const Color indigo = Colors.indigo;
  static const Color amber = Colors.amber;

  // 热带粉红色系
  static const Color tropicalPink = Color(0xFFE91E63);
  static const Color lightPink = Color(0xFFF8BBD9);
  static const Color softPink = Color(0xFFFFB3D9);
  static const Color palePink = Color(0xFFFFCDD2);

  // 远山青色系
  static const Color mountainBlue = Color(0xFF4A90E2);
  static const Color skyBlue = Color(0xFF64B5F6);
  static const Color lightBlue = Color(0xFFBBDEFB);
  static const Color paleBlue = Color(0xFFE3F2FD);

  // 薰衣草紫色系
  static const Color lavender = Color(0xFF9C27B0);
  static const Color lightLavender = Color(0xFFE1BEE7);
  static const Color softLavender = Color(0xFFCE93D8);
  static const Color paleLavender = Color(0xFFF3E5F5);

  // 樱花粉色系
  static const Color cherryPink = Color(0xFFE91E63);
  static const Color lightCherry = Color(0xFFFFB3D9);
  static const Color softCherry = Color(0xFFFFCDD2);
  static const Color paleCherry = Color(0xFFFCE4EC);

  // 春绿色系
  static const Color springGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF8BC34A);
  static const Color softGreen = Color(0xFFCDDC39);
  static const Color paleGreen = Color(0xFFC8E6C9);
  static const Color mintGreen = Color(0xFF81C784);

  // 橙色系
  static const Color orange = Color(0xFFFF9800);
  static const Color lightOrange = Color(0xFFFFB74D);

  // 棕色系
  static const Color brown = Color(0xFF795548);

  // 背景色
  static const Color lightGreyBg = Color(0xFFF8F9FA);
  static const Color paleBlueBg = Color(0xFFF0F8FF);
  static const Color paleLavenderBg = Color(0xFFF8F5FF);
  static const Color paleCherryBg = Color(0xFFFFF5F7);
  static const Color paleGreenBg = Color(0xFFF1F8E9);

  // 表面色
  static const Color lightGreySurface = Color(0xFFF3F4F6);
  static const Color paleBlueSurface = Color(0xFFE3F2FD);
  static const Color paleLavenderSurface = Color(0xFFF3E5F5);
  static const Color paleCherrySurface = Color(0xFFFCE4EC);
  static const Color paleGreenSurface = Color(0xFFE8F5E8);

  // 文字色
  static const Color darkText = Color(0xFF1C1B1F);
  static const Color mediumText = Color(0xFF49454F);
  static const Color lightText = Color(0xFF79747E);

  // 错误色
  static const Color error = Color(0xFFB00020);

  // 阴影和遮罩
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);

  // 反转色
  static const Color inverseSurface = Color(0xFF313033);
  static const Color onInverseSurface = Color(0xFFF4EFF4);
}

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

/// 主题信息模型
class ThemeInfo {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isPremium;

  const ThemeInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isPremium = false,
  });

  /// 从JSON创建主题信息
  factory ThemeInfo.fromJson(Map<String, dynamic> json) {
    return ThemeInfo(
      name: json['name'] as String,
      description: json['description'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] as int),
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'icon': icon.codePoint,
      'color': color.value,
      'isPremium': isPremium,
    };
  }

  /// 复制并修改
  ThemeInfo copyWith({
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    bool? isPremium,
  }) {
    return ThemeInfo(
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeInfo &&
        other.name == name &&
        other.description == description &&
        other.icon == icon &&
        other.color == color &&
        other.isPremium == isPremium;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        description.hashCode ^
        icon.hashCode ^
        color.hashCode ^
        isPremium.hashCode;
  }

  @override
  String toString() {
    return 'ThemeInfo(name: $name, description: $description, isPremium: $isPremium)';
  }
}

/// 主题状态模型
class ThemeState {
  final ThemeType currentTheme;
  final ThemeData themeData;
  final bool isSystemTheme;

  const ThemeState({
    required this.currentTheme,
    required this.themeData,
    this.isSystemTheme = false,
  });

  /// 复制并修改
  ThemeState copyWith({
    ThemeType? currentTheme,
    ThemeData? themeData,
    bool? isSystemTheme,
  }) {
    return ThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      themeData: themeData ?? this.themeData,
      isSystemTheme: isSystemTheme ?? this.isSystemTheme,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState &&
        other.currentTheme == currentTheme &&
        other.themeData == themeData &&
        other.isSystemTheme == isSystemTheme;
  }

  @override
  int get hashCode {
    return currentTheme.hashCode ^ themeData.hashCode ^ isSystemTheme.hashCode;
  }

  @override
  String toString() {
    return 'ThemeState(currentTheme: $currentTheme, isSystemTheme: $isSystemTheme)';
  }
}
