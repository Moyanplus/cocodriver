import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'platform_utils.dart';

/// 响应式布局工具类
/// 提供统一的屏幕适配和响应式布局方法
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
  static int getGridColumns() {
    if (isMobile) return 2;
    if (isTablet) return 3;
    return 4;
  }

  /// 根据屏幕类型获取最大宽度
  static double getMaxWidth() {
    if (isMobile) return screenWidth;
    if (isTablet) return 800.w;
    return 1200.w;
  }

  /// 根据屏幕类型获取内边距
  static EdgeInsets getPadding() {
    if (isMobile) return EdgeInsets.all(16.w);
    if (isTablet) return EdgeInsets.all(24.w);
    return EdgeInsets.all(32.w);
  }

  /// 根据屏幕类型获取间距
  static double getSpacing() {
    if (isMobile) return 12.w;
    if (isTablet) return 16.w;
    return 20.w;
  }

  /// 根据屏幕类型获取字体大小
  static double getFontSize(double baseSize) {
    if (isSmallScreen) return baseSize * 0.9;
    if (isLargeScreen) return baseSize * 1.1;
    return baseSize;
  }

  /// 根据屏幕类型获取图标大小
  static double getIconSize(double baseSize) {
    if (isMobile) return baseSize;
    if (isTablet) return baseSize * 1.2;
    return baseSize * 1.4;
  }

  /// 根据屏幕类型获取按钮高度
  static double getButtonHeight() {
    if (isMobile) return 48.h;
    if (isTablet) return 52.h;
    return 56.h;
  }

  /// 根据屏幕类型获取卡片圆角
  static double getCardRadius() {
    if (isMobile) return 8.r;
    if (isTablet) return 12.r;
    return 16.r;
  }

  // ==================== 平台特定适配 ====================

  /// 获取平台特定的导航栏高度
  static double getNavigationBarHeight(BuildContext context) {
    final baseHeight = PlatformUtils.getNavigationBarHeight(context);
    if (isTablet) return baseHeight * 1.2;
    if (isDesktop) return baseHeight * 0.8;
    return baseHeight;
  }

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
  }) {
    final scale = isMobile ? 1.0 : (isTablet ? 1.2 : 1.4);

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
  }) {
    final scale = isMobile ? 1.0 : (isTablet ? 1.2 : 1.4);

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
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop && desktop != null) {
      return desktop;
    } else if (isTablet && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// 响应式数值选择器
  static T responsiveValue<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) {
      return desktop;
    } else if (isTablet && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// 响应式列布局
  static Widget responsiveColumn({
    required List<Widget> children,
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    double? spacing,
    double? runSpacing,
  }) {
    final columns = responsiveValue<int>(
      mobile: mobileColumns ?? 1,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 3,
    );

    return Wrap(
      children: children,
      spacing: spacing ?? getSpacing(),
      runSpacing: runSpacing ?? getSpacing(),
    );
  }

  /// 响应式网格布局
  static Widget responsiveGrid({
    required List<Widget> children,
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    double? spacing,
    double? runSpacing,
  }) {
    final columns = responsiveValue<int>(
      mobile: mobileColumns ?? 2,
      tablet: tabletColumns ?? 3,
      desktop: desktopColumns ?? 4,
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
}
