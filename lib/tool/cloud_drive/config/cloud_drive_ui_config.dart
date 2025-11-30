import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/responsive_utils.dart';

/// 云盘 UI 配置
///
/// 兼容旧的静态调用，同时内部使用 ResponsiveUtils 做基础缩放。
class CloudDriveUIConfig {
  CloudDriveUIConfig._();

  // 颜色
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color infoColor = Colors.blue;
  static const Color folderColor = Colors.orange;
  static const Color primaryActionColor = Colors.blue;
  static const Color secondaryActionColor = Colors.grey;
  static const Color textColor = Colors.black87;
  static const Color secondaryTextColor = Colors.grey;
  static const Color backgroundColor = Colors.white;
  static const Color cardBackgroundColor = Colors.white;
  static const Color dividerColor = Colors.grey;

  // 间距
  static double get spacingXS => ResponsiveUtils.getSpacing() * 0.5;
  static double get spacingS => ResponsiveUtils.getSpacing() * 1.0;
  static double get spacingM => ResponsiveUtils.getSpacing() * 2.0;
  static double get spacingL => ResponsiveUtils.getSpacing() * 3.0;
  static double get spacingXL => ResponsiveUtils.getSpacing() * 4.0;

  static EdgeInsets get pagePadding => EdgeInsets.all(spacingM);
  static EdgeInsets get cardPadding => EdgeInsets.all(spacingM);
  static EdgeInsets get buttonPadding =>
      EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingS);
  static EdgeInsets get inputPadding =>
      EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS);

  // 字体
  static double get fontSizeXXL => ResponsiveUtils.getFontSize(24.sp);
  static double get fontSizeXL => ResponsiveUtils.getFontSize(20.sp);
  static double get fontSizeL => ResponsiveUtils.getFontSize(18.sp);
  static double get fontSizeM => ResponsiveUtils.getFontSize(16.sp);
  static double get fontSizeS => ResponsiveUtils.getFontSize(14.sp);
  static double get fontSizeXS => ResponsiveUtils.getFontSize(12.sp);

  static TextStyle get titleTextStyle => TextStyle(
        fontSize: fontSizeL,
        fontWeight: FontWeight.bold,
        color: textColor,
      );

  static TextStyle get bodyTextStyle =>
      TextStyle(fontSize: fontSizeM, color: textColor);

  static TextStyle get smallTextStyle =>
      TextStyle(fontSize: fontSizeS, color: secondaryTextColor);

  static TextStyle get buttonTextStyle => TextStyle(
        fontSize: fontSizeM,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  // 尺寸
  static double get iconSize => ResponsiveUtils.getIconSize(24.sp);
  static double get iconSizeS => ResponsiveUtils.getIconSize(16.sp);
  static double get iconSizeL => ResponsiveUtils.getIconSize(32.sp);
  static double get buttonHeight => ResponsiveUtils.getButtonHeight();
  static double get inputHeight => 48.h;
  static double get cardRadius => ResponsiveUtils.getCardRadius();
  static double get buttonRadius => 8.r;
  static double get inputRadius => 8.r;

  // 阴影
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8.r,
          offset: Offset(0, 2.h),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4.r,
          offset: Offset(0, 2.h),
        ),
      ];

  // 动画
  static const Duration standardDuration = Duration(milliseconds: 300);
  static const Duration fastDuration = Duration(milliseconds: 150);
  static const Duration slowDuration = Duration(milliseconds: 500);
}
