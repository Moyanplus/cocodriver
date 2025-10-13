import 'package:flutter/material.dart';

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
