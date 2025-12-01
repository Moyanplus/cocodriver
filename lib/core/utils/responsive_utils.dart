/// 响应式布局工具类
///
/// 提供统一的屏幕适配和响应式布局方法
/// 基于flutter_screenutil实现跨设备屏幕适配
///
/// 主要功能：
/// - 屏幕尺寸获取
/// - 设备类型检测
/// - 响应式布局计算
/// - 屏幕适配工具
/// - 布局断点管理
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'platform_utils.dart';
import 'responsive_spec.dart';

/// 响应式布局工具类
///
/// 提供统一的屏幕适配和响应式布局方法
/// 基于flutter_screenutil实现跨设备屏幕适配
class ResponsiveUtils {
  ResponsiveUtils._();

  /// 获取屏幕宽度
  static double get screenWidth => ScreenUtil().screenWidth;

  /// 获取屏幕高度
  static double get screenHeight => ScreenUtil().screenHeight;

  /// 获取状态栏高度
  static double get statusBarHeight => ScreenUtil().statusBarHeight;

  /// 获取底部安全区域高度
  static double get bottomBarHeight => ScreenUtil().bottomBarHeight;

  /// 获取屏幕像素密度
  static double get pixelRatio => ScreenUtil().pixelRatio ?? 1.0;

  /// 获取屏幕方向
  static Orientation get orientation => ScreenUtil().orientation;

  /// 获取上下文对应的响应式规格
  static ResponsiveSpec specOf(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      return _fallbackSpec();
    }
    return ResponsiveSpec.resolve(mediaQuery.size, mediaQuery.viewPadding);
  }

  static ResponsiveSpec _fallbackSpec() {
    final width = ScreenUtil().screenWidth;
    final height = ScreenUtil().screenHeight;
    if (width > 0 && height > 0) {
      return ResponsiveSpec.resolve(Size(width, height), EdgeInsets.zero);
    }
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    if (dispatcher.views.isNotEmpty) {
      final view = dispatcher.views.first;
      final logicalSize = view.physicalSize / view.devicePixelRatio;
      return ResponsiveSpec.resolve(logicalSize, EdgeInsets.zero);
    }
    return ResponsiveSpec.resolve(const Size(375, 812), EdgeInsets.zero);
  }

  // ==================== 新版响应式辅助 ====================

  /// 当前断点的最大内容宽度
  static double contentMaxWidth(BuildContext context) =>
      specOf(context).maxContentWidth;

  /// 当前断点的默认内边距
  static EdgeInsets contentPadding(BuildContext context, {double? vertical}) =>
      specOf(context).contentPadding(vertical: vertical);

  /// 当前断点的默认间距
  static double spacingOf(BuildContext context) => specOf(context).spacing;

  /// 当前断点的按钮高度
  static double buttonHeightOf(BuildContext context) =>
      specOf(context).buttonHeight;

  /// 当前断点的圆角
  static double cardRadiusOf(BuildContext context) =>
      specOf(context).cardRadius;

  /// 根据断点缩放字体大小
  static double fontSizeOf(BuildContext context, double base) =>
      specOf(context).scaleFont(base);

  /// 根据断点缩放图标大小
  static double iconSizeOf(BuildContext context, double base) =>
      specOf(context).scaleIcon(base);

  /// 当前断点的AppBar高度
  static double navigationBarHeightOf(BuildContext context) =>
      specOf(context).appBarHeight;

  /// 根据断点选择不同的取值
  static T responsiveValue<T>({
    required BuildContext context,
    required T compact,
    T? medium,
    T? expanded,
    T? large,
    T? extraLarge,
  }) {
    final spec = specOf(context);
    switch (spec.sizeClass) {
      case ResponsiveSizeClass.compact:
        return compact;
      case ResponsiveSizeClass.medium:
        return medium ?? compact;
      case ResponsiveSizeClass.expanded:
        return expanded ?? medium ?? compact;
      case ResponsiveSizeClass.large:
        return large ?? expanded ?? medium ?? compact;
      case ResponsiveSizeClass.extraLarge:
        return extraLarge ?? large ?? expanded ?? medium ?? compact;
    }
  }

  // ==================== 设备类型检测 ====================

  /// 检查是否为手机
  static bool get isMobile => screenWidth < 600;

  /// 检查是否为平板
  static bool get isTablet => screenWidth >= 600 && screenWidth < 1200;

  /// 检查是否为桌面
  static bool get isDesktop => screenWidth >= 1200;

  /// 检查是否为横屏
  static bool get isLandscape => orientation == Orientation.landscape;

  /// 检查是否为竖屏
  static bool get isPortrait => orientation == Orientation.portrait;

  /// 检查是否为小屏幕设备
  static bool get isSmallScreen => screenWidth < 360;

  /// 检查是否为大屏幕设备
  static bool get isLargeScreen => screenWidth > 1200;

  // ==================== 响应式布局方法 ====================

  /// 根据屏幕类型获取列数
  static int getGridColumns() => _fallbackSpec().gridColumns;

  /// 根据屏幕类型获取最大宽度
  static double getMaxWidth() => _fallbackSpec().maxContentWidth;

  /// 根据屏幕类型获取内边距
  static EdgeInsets getPadding() {
    final spec = _fallbackSpec();
    return EdgeInsets.all(spec.horizontalPadding);
  }

  /// 根据屏幕类型获取间距
  static double getSpacing() => _fallbackSpec().spacing;

  /// 根据屏幕类型获取字体大小
  static double getFontSize(double baseSize) =>
      _fallbackSpec().scaleFont(baseSize);

  /// 根据屏幕类型获取图标大小
  static double getIconSize(double baseSize) =>
      _fallbackSpec().scaleIcon(baseSize);

  /// 根据屏幕类型获取按钮高度
  static double getButtonHeight() => _fallbackSpec().buttonHeight;

  /// 根据屏幕类型获取卡片圆角
  static double getCardRadius() => _fallbackSpec().cardRadius;

  // ==================== 平台特定适配 ====================

  /// 获取平台特定的导航栏高度
  static double getNavigationBarHeight(BuildContext context) =>
      specOf(context).appBarHeight;

  /// 获取平台特定的底部安全区域
  static double getBottomSafeArea(BuildContext context) {
    return PlatformUtils.getBottomSafeArea(context);
  }

  /// 获取平台特定的状态栏高度
  static double getStatusBarHeight(BuildContext context) {
    return PlatformUtils.getStatusBarHeight(context);
  }

  // ==================== 布局辅助方法 ====================

  /// 获取响应式宽度
  static double getResponsiveWidth(double width) {
    if (isMobile) return width;
    if (isTablet) return width * 1.2;
    return width * 1.5;
  }

  /// 获取响应式高度
  static double getResponsiveHeight(double height) {
    if (isMobile) return height;
    if (isTablet) return height * 1.1;
    return height * 1.2;
  }

  /// 获取响应式字体大小
  static double getResponsiveFontSize(double fontSize) {
    if (isSmallScreen) return fontSize * 0.85;
    if (isMobile) return fontSize;
    if (isTablet) return fontSize * 1.1;
    return fontSize * 1.2;
  }

  /// 获取响应式内边距
  static EdgeInsets getResponsivePadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
    BuildContext? context,
  }) {
    final spec = context != null ? specOf(context) : _fallbackSpec();
    final scale = _scaleForSpec(spec);

    return EdgeInsets.only(
      top: (top ?? vertical ?? all ?? 0) * scale,
      bottom: (bottom ?? vertical ?? all ?? 0) * scale,
      left: (left ?? horizontal ?? all ?? 0) * scale,
      right: (right ?? horizontal ?? all ?? 0) * scale,
    );
  }

  /// 获取响应式外边距
  static EdgeInsets getResponsiveMargin({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
    BuildContext? context,
  }) {
    final spec = context != null ? specOf(context) : _fallbackSpec();
    final scale = _scaleForSpec(spec);

    return EdgeInsets.only(
      top: (top ?? vertical ?? all ?? 0) * scale,
      bottom: (bottom ?? vertical ?? all ?? 0) * scale,
      left: (left ?? horizontal ?? all ?? 0) * scale,
      right: (right ?? horizontal ?? all ?? 0) * scale,
    );
  }

  // ==================== 断点检测 ====================

  /// 检查是否在指定断点范围内
  static bool isBreakpoint(double minWidth, double maxWidth) {
    return screenWidth >= minWidth && screenWidth < maxWidth;
  }

  /// 检查是否超过指定断点
  static bool isBreakpointUp(double minWidth) {
    return screenWidth >= minWidth;
  }

  /// 检查是否低于指定断点
  static bool isBreakpointDown(double maxWidth) {
    return screenWidth < maxWidth;
  }

  // ==================== 布局构建器 ====================

  /// 响应式布局构建器
  static Widget responsiveBuilder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? expanded,
    Widget? desktop,
    Widget? extraLarge,
  }) {
    final spec = specOf(context);
    switch (spec.sizeClass) {
      case ResponsiveSizeClass.compact:
        return mobile;
      case ResponsiveSizeClass.medium:
        return tablet ?? mobile;
      case ResponsiveSizeClass.expanded:
        return expanded ?? tablet ?? mobile;
      case ResponsiveSizeClass.large:
        return desktop ?? expanded ?? tablet ?? mobile;
      case ResponsiveSizeClass.extraLarge:
        return extraLarge ?? desktop ?? expanded ?? tablet ?? mobile;
    }
  }

  /// 响应式列布局
  static Widget responsiveColumn({
    required BuildContext context,
    required List<Widget> children,
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    double? spacing,
    double? runSpacing,
  }) {
    responsiveValue<int>(
      context: context,
      compact: mobileColumns ?? 1,
      medium: tabletColumns ?? mobileColumns ?? 2,
      expanded: desktopColumns ?? tabletColumns ?? 3,
      large: desktopColumns ?? 3,
      extraLarge: desktopColumns ?? 4,
    );

    return Wrap(
      spacing: spacing ?? getSpacing(),
      runSpacing: runSpacing ?? getSpacing(),
      children: children,
    );
  }

  /// 响应式网格布局
  static Widget responsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    double? spacing,
    double? runSpacing,
  }) {
    final columns = responsiveValue<int>(
      context: context,
      compact: mobileColumns ?? 2,
      medium: tabletColumns ?? mobileColumns ?? 3,
      expanded: desktopColumns ?? tabletColumns ?? 4,
      large: desktopColumns ?? 5,
      extraLarge: desktopColumns ?? 6,
    );

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing ?? getSpacing(),
        mainAxisSpacing: runSpacing ?? getSpacing(),
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  static double _scaleForSpec(ResponsiveSpec spec) {
    switch (spec.sizeClass) {
      case ResponsiveSizeClass.compact:
        return 1.0;
      case ResponsiveSizeClass.medium:
        return 1.1;
      case ResponsiveSizeClass.expanded:
        return 1.15;
      case ResponsiveSizeClass.large:
        return 1.2;
      case ResponsiveSizeClass.extraLarge:
        return 1.25;
    }
  }
}
