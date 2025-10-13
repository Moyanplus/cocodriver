import 'package:flutter/material.dart';

import '../theme/theme_models.dart';
import '../theme/theme_config_factory.dart';

/// 主题服务
class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  ThemeType _currentTheme = ThemeType.system;
  ThemeType get currentTheme => _currentTheme;

  /// 获取指定主题类型的 ThemeData
  /// 使用工厂模式，支持缓存机制
  ThemeData getTheme(ThemeType type) {
    return ThemeConfigFactory.getTheme(type);
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
}
