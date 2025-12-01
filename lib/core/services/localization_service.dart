/// 本地化服务
///
/// 负责管理应用程序的多语言支持，包括语言切换、语言设置保存等功能
/// 支持中文和英文两种语言，可以扩展到更多语言
///
/// 主要功能：
/// - 语言切换和管理
/// - 语言设置持久化存储
/// - 语言显示名称获取
/// - 支持的语言列表管理
///
/// 使用单例模式，确保全局语言状态一致性
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地化服务类
///
/// 负责管理应用程序的多语言支持，包括语言切换、语言设置保存等功能
/// 支持中文和英文两种语言，可以扩展到更多语言
///
/// 主要功能：
/// - 语言切换和管理
/// - 语言设置持久化存储
/// - 语言显示名称获取
/// - 支持的语言列表管理
///
/// 使用单例模式，确保全局语言状态一致性
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年
class LocalizationService {
  /// 单例实例
  static final LocalizationService _instance = LocalizationService._internal();

  factory LocalizationService() => _instance;
  LocalizationService._internal();

  // SharedPreferences存储键
  static const String _localeKey = 'selected_locale';

  /// 支持的语言列表
  /// 目前支持中文和英文，可以扩展更多语言
  static const List<Locale> supportedLocales = [
    Locale('zh', ''), // 中文
    Locale('en', ''), // 英文
  ];

  /// 默认语言设置
  /// 当无法获取用户设置时使用此语言
  static const Locale defaultLocale = Locale('zh', '');

  /// 当前选中的语言
  Locale _currentLocale = defaultLocale;
  Locale get currentLocale => _currentLocale;

  /// 获取语言显示名称
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  /// 获取语言显示名称（本地化）
  String getLocalizedLanguageName(Locale locale, BuildContext context) {
    switch (locale.languageCode) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  /// 设置语言
  Future<void> setLocale(Locale locale) async {
    if (supportedLocales.contains(locale)) {
      _currentLocale = locale;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_localeKey, locale.languageCode);
      } catch (e) {
        // 保存失败，继续使用当前语言
      }
    }
  }

  /// 加载保存的语言
  Future<Locale> loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);

      if (localeCode != null) {
        final locale = Locale(localeCode);
        if (supportedLocales.contains(locale)) {
          _currentLocale = locale;
          return locale;
        }
      }
    } catch (e) {
      // 加载失败，使用默认语言
    }

    _currentLocale = defaultLocale;
    return defaultLocale;
  }

  /// 重置为默认语言
  Future<void> resetToDefault() async {
    await setLocale(defaultLocale);
  }

  /// 检查是否为中文
  bool get isChinese => _currentLocale.languageCode == 'zh';

  /// 检查是否为英文
  bool get isEnglish => _currentLocale.languageCode == 'en';

  /// 获取语言代码
  String get languageCode => _currentLocale.languageCode;
}
