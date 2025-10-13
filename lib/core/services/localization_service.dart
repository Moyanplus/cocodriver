import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地化服务
/// 管理应用的多语言支持
class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  static const String _localeKey = 'selected_locale';

  /// 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', ''), // 中文
    Locale('en', ''), // 英文
  ];

  /// 默认语言
  static const Locale defaultLocale = Locale('zh', '');

  /// 当前语言
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
