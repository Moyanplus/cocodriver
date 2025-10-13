/// 应用常量
class AppConstants {
  // 存储键
  static const String selectedThemeKey = 'selected_theme';
  static const String userPreferencesKey = 'user_preferences';
  static const String appSettingsKey = 'app_settings';

  // 路由名称
  static const String homeRoute = '/';
  static const String settingsRoute = '/settings';
  static const String themeSettingsRoute = '/settings/theme';
  static const String categoryRoute = '/category';
  static const String userProfileRoute = '/user';

  // 主题相关
  static const String defaultTheme = 'system';
  static const String lightTheme = 'light';
  static const String darkTheme = 'dark';

  // 本地化
  static const String defaultLocale = 'zh';
  static const String englishLocale = 'en';

  // 网络配置
  static const int connectionTimeout = 30000; // 30秒
  static const int receiveTimeout = 30000; // 30秒

  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 缓存配置
  static const int cacheExpirationDays = 7;
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
}
