import 'package:flutter/material.dart';

/// 屏幕断点枚举
enum ResponsiveSizeClass { compact, medium, expanded, large, extraLarge }

/// 响应式布局规格定义
class ResponsiveSpec {
  const ResponsiveSpec({
    required this.sizeClass,
    required this.screenSize,
    required this.safeArea,
    required this.maxContentWidth,
    required this.horizontalPadding,
    required this.spacing,
    required this.buttonHeight,
    required this.cardRadius,
    required this.iconScale,
    required this.fontScale,
    required this.gridColumns,
    required this.appBarHeight,
  });

  final ResponsiveSizeClass sizeClass;
  final Size screenSize;
  final EdgeInsets safeArea;
  final double maxContentWidth;
  final double horizontalPadding;
  final double spacing;
  final double buttonHeight;
  final double cardRadius;
  final double iconScale;
  final double fontScale;
  final int gridColumns;
  final double appBarHeight;

  double get safeBottom => safeArea.bottom;

  double scaleFont(double base) => base * fontScale;

  double scaleIcon(double base) => base * iconScale;

  EdgeInsets contentPadding({double? vertical}) => EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: vertical ?? spacing,
      );

  /// 根据屏幕尺寸和安全区域解析规格
  static ResponsiveSpec resolve(Size size, EdgeInsets safeArea) {
    final width = size.width;
    if (width < 600) {
      return ResponsiveSpec._(
        sizeClass: ResponsiveSizeClass.compact,
        screenSize: size,
        safeArea: safeArea,
        maxContentWidth: size.width,
        horizontalPadding: 16,
        spacing: 12,
        buttonHeight: 52,
        cardRadius: 10,
        iconScale: 1.0,
        fontScale: 1.0,
        gridColumns: width < 420 ? 1 : 2,
        appBarHeight: 56,
      );
    }
    if (width < 840) {
      return ResponsiveSpec._(
        sizeClass: ResponsiveSizeClass.medium,
        screenSize: size,
        safeArea: safeArea,
        maxContentWidth: size.width,
        horizontalPadding: 20,
        spacing: 16,
        buttonHeight: 54,
        cardRadius: 12,
        iconScale: 1.05,
        fontScale: 1.05,
        gridColumns: 2,
        appBarHeight: 60,
      );
    }
    if (width < 1200) {
      return ResponsiveSpec._(
        sizeClass: ResponsiveSizeClass.expanded,
        screenSize: size,
        safeArea: safeArea,
        maxContentWidth: size.width.clamp(0, 960),
        horizontalPadding: 24,
        spacing: 20,
        buttonHeight: 56,
        cardRadius: 14,
        iconScale: 1.1,
        fontScale: 1.08,
        gridColumns: 3,
        appBarHeight: 64,
      );
    }
    if (width < 1600) {
      return ResponsiveSpec._(
        sizeClass: ResponsiveSizeClass.large,
        screenSize: size,
        safeArea: safeArea,
        maxContentWidth: size.width.clamp(0, 1200),
        horizontalPadding: 28,
        spacing: 24,
        buttonHeight: 58,
        cardRadius: 16,
        iconScale: 1.15,
        fontScale: 1.12,
        gridColumns: 4,
        appBarHeight: 68,
      );
    }
    return ResponsiveSpec._(
      sizeClass: ResponsiveSizeClass.extraLarge,
      screenSize: size,
      safeArea: safeArea,
      maxContentWidth: size.width.clamp(0, 1440),
      horizontalPadding: 32,
      spacing: 28,
      buttonHeight: 60,
      cardRadius: 18,
      iconScale: 1.2,
      fontScale: 1.15,
      gridColumns: 5,
      appBarHeight: 72,
    );
  }

  const ResponsiveSpec._({
    required this.sizeClass,
    required this.screenSize,
    required this.safeArea,
    required this.maxContentWidth,
    required this.horizontalPadding,
    required this.spacing,
    required this.buttonHeight,
    required this.cardRadius,
    required this.iconScale,
    required this.fontScale,
    required this.gridColumns,
    required this.appBarHeight,
  });
}
