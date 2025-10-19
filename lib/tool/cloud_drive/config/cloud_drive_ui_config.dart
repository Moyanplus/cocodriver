import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 云盘UI配置类
/// 统一管理所有UI样式，包括颜色、间距、字体等
class CloudDriveUIConfig {
  // 私有构造函数，防止实例化
  CloudDriveUIConfig._();

  // ==================== 颜色配置 ====================

  /// 成功状态颜色
  static const Color successColor = Colors.green;

  /// 错误状态颜色
  static const Color errorColor = Colors.red;

  /// 警告状态颜色
  static const Color warningColor = Colors.orange;

  /// 信息状态颜色
  static const Color infoColor = Colors.blue;

  /// 文件夹颜色
  static const Color folderColor = Colors.orange;

  /// 主要操作颜色
  static const Color primaryActionColor = Colors.blue;

  /// 次要操作颜色
  static const Color secondaryActionColor = Colors.grey;

  /// 文本颜色
  static const Color textColor = Colors.black87;

  /// 次要文本颜色
  static const Color secondaryTextColor = Colors.grey;

  /// 背景颜色
  static const Color backgroundColor = Colors.white;

  /// 卡片背景颜色
  static const Color cardBackgroundColor = Colors.white;

  /// 分割线颜色
  static const Color dividerColor = Colors.grey;

  // ==================== 间距配置 ====================

  /// 超小间距
  static double get spacingXS => 4.w;

  /// 小间距
  static double get spacingS => 8.w;

  /// 中等间距
  static double get spacingM => 16.w;

  /// 大间距
  static double get spacingL => 24.w;

  /// 超大间距
  static double get spacingXL => 32.w;

  /// 页面边距
  static EdgeInsets get pagePadding => EdgeInsets.all(spacingM);

  /// 卡片内边距
  static EdgeInsets get cardPadding => EdgeInsets.all(spacingM);

  /// 按钮内边距
  static EdgeInsets get buttonPadding =>
      EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingS);

  /// 输入框内边距
  static EdgeInsets get inputPadding =>
      EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS);

  // ==================== 字体配置 ====================

  /// 超大标题字体大小
  static double get fontSizeXXL => 24.sp;

  /// 大标题字体大小
  static double get fontSizeXL => 20.sp;

  /// 标题字体大小
  static double get fontSizeL => 18.sp;

  /// 正文字体大小
  static double get fontSizeM => 16.sp;

  /// 小字体大小
  static double get fontSizeS => 14.sp;

  /// 超小字体大小
  static double get fontSizeXS => 12.sp;

  /// 标题字体样式
  static TextStyle get titleTextStyle => TextStyle(
    fontSize: fontSizeL,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  /// 正文字体样式
  static TextStyle get bodyTextStyle =>
      TextStyle(fontSize: fontSizeM, color: textColor);

  /// 小字体样式
  static TextStyle get smallTextStyle =>
      TextStyle(fontSize: fontSizeS, color: secondaryTextColor);

  /// 按钮字体样式
  static TextStyle get buttonTextStyle => TextStyle(
    fontSize: fontSizeM,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // ==================== 尺寸配置 ====================

  /// 图标大小
  static double get iconSize => 24.w;

  /// 小图标大小
  static double get iconSizeS => 16.w;

  /// 大图标大小
  static double get iconSizeL => 32.w;

  /// 按钮高度
  static double get buttonHeight => 48.h;

  /// 输入框高度
  static double get inputHeight => 48.h;

  /// 卡片圆角
  static double get cardRadius => 12.r;

  /// 按钮圆角
  static double get buttonRadius => 8.r;

  /// 输入框圆角
  static double get inputRadius => 8.r;

  // ==================== 阴影配置 ====================

  /// 卡片阴影
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8.r,
      offset: Offset(0, 2.h),
    ),
  ];

  /// 按钮阴影
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4.r,
      offset: Offset(0, 2.h),
    ),
  ];

  // ==================== 动画配置 ====================

  /// 标准动画时长
  static const Duration standardDuration = Duration(milliseconds: 300);

  /// 快速动画时长
  static const Duration fastDuration = Duration(milliseconds: 150);

  /// 慢速动画时长
  static const Duration slowDuration = Duration(milliseconds: 500);

  // ==================== 主题相关配置 ====================

  /// 获取主题相关的颜色
  static Color getThemeColor(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light ? lightColor : darkColor;
  }

  /// 获取主题相关的文本颜色
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// 获取主题相关的背景颜色
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// 获取主题相关的卡片颜色
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainer;
  }

  // ==================== 响应式配置 ====================

  /// 根据屏幕宽度获取列数
  static int getColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  /// 获取响应式字体大小
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return baseSize * 1.2;
    if (width < 600) return baseSize * 0.9;
    return baseSize;
  }

  /// 获取响应式间距
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return baseSpacing * 1.2;
    if (width < 600) return baseSpacing * 0.8;
    return baseSpacing;
  }
}
