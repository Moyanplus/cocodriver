/// 应用配置
class AppConfig {
  // 应用信息
  static const String appName = 'Flutter UI模板';
  static const String appVersion = '1.0.0';
  static const String appDescription = '基于可可世界设计的Flutter UI模板项目';

  // 设计稿尺寸
  static const double designWidth = 393.0;
  static const double designHeight = 852.0;

  // 屏幕适配
  static const bool minTextAdapt = true;
  static const bool splitScreenMode = true;

  // 动画配置
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // 页面配置
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // 圆角配置
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;

  // 阴影配置
  static const double defaultElevation = 2.0;
  static const double highElevation = 8.0;
}
