import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'platform_utils.dart';
import 'responsive_utils.dart';

/// 自适应UI工具类
/// 提供平台特定的UI组件和样式
class AdaptiveUtils {
  AdaptiveUtils._();

  // ==================== 平台特定按钮 ====================

  /// 自适应按钮
  static Widget adaptiveButton({
    required VoidCallback? onPressed,
    required Widget child,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    double? elevation,
    String? tooltip,
  }) {
    if (PlatformUtils.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        child: DefaultTextStyle(
          style: TextStyle(
            color: foregroundColor ?? CupertinoColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          child: child,
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4),
          ),
          elevation: elevation ?? 2,
        ),
        child: child,
      );
    }
  }

  /// 自适应文本按钮
  static Widget adaptiveTextButton({
    required VoidCallback? onPressed,
    required Widget child,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    String? tooltip,
  }) {
    if (PlatformUtils.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DefaultTextStyle(
          style: TextStyle(
            color: foregroundColor ?? CupertinoColors.activeBlue,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
          child: child,
        ),
      );
    } else {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: foregroundColor,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: child,
      );
    }
  }

  /// 自适应图标按钮
  static Widget adaptiveIconButton({
    required VoidCallback? onPressed,
    required Widget icon,
    Color? backgroundColor,
    Color? foregroundColor,
    double? size,
    String? tooltip,
  }) {
    if (PlatformUtils.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        padding: EdgeInsets.all(size ?? 8),
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: DefaultTextStyle(
          style: TextStyle(color: foregroundColor ?? CupertinoColors.white),
          child: icon,
        ),
      );
    } else {
      return IconButton(
        onPressed: onPressed,
        icon: icon,
        color: foregroundColor,
        iconSize: size ?? 24,
        tooltip: tooltip,
      );
    }
  }

  // ==================== 平台特定对话框 ====================

  /// 自适应对话框
  static Future<T?> showAdaptiveDialog<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    if (PlatformUtils.isIOS) {
      return showCupertinoDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder:
            (context) => CupertinoAlertDialog(
              title: title != null ? Text(title) : null,
              content: child,
              actions:
                  actions ??
                  [
                    CupertinoDialogAction(
                      child: const Text('确定'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
            ),
      );
    } else {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder:
            (context) => AlertDialog(
              title: title != null ? Text(title) : null,
              content: child,
              actions:
                  actions ??
                  [
                    TextButton(
                      child: const Text('确定'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
            ),
      );
    }
  }

  /// 自适应底部弹窗
  static Future<T?> showAdaptiveBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    if (PlatformUtils.isIOS) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder:
            (context) => Container(
              height: isScrollControlled ? null : 300,
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: child,
            ),
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => child,
      );
    }
  }

  // ==================== 平台特定输入框 ====================

  /// 自适应文本输入框
  static Widget adaptiveTextField({
    required TextEditingController controller,
    String? placeholder,
    String? label,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function()? onTap,
    bool readOnly = false,
    int? maxLines,
    int? maxLength,
  }) {
    if (PlatformUtils.isIOS) {
      return CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        obscureText: obscureText,
        keyboardType: keyboardType,
        prefix: prefixIcon,
        suffix: suffixIcon,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        maxLines: maxLines ?? 1,
        maxLength: maxLength,
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.separator),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    } else {
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        maxLines: maxLines ?? 1,
        maxLength: maxLength,
      );
    }
  }

  // ==================== 平台特定开关 ====================

  /// 自适应开关
  static Widget adaptiveSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    if (PlatformUtils.isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor ?? CupertinoColors.activeGreen,
      );
    } else {
      return Switch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        inactiveThumbColor: inactiveColor,
      );
    }
  }

  // ==================== 平台特定进度指示器 ====================

  /// 自适应进度指示器
  static Widget adaptiveProgressIndicator({
    double? value,
    Color? color,
    double? strokeWidth,
  }) {
    if (PlatformUtils.isIOS) {
      return CupertinoActivityIndicator(
        color: color ?? CupertinoColors.activeBlue,
        radius: (strokeWidth ?? 10) / 2,
      );
    } else {
      if (value != null) {
        return CircularProgressIndicator(
          value: value,
          color: color,
          strokeWidth: strokeWidth ?? 4,
        );
      } else {
        return CircularProgressIndicator(
          color: color,
          strokeWidth: strokeWidth ?? 4,
        );
      }
    }
  }

  // ==================== 平台特定列表项 ====================

  /// 自适应列表项
  static Widget adaptiveListTile({
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    if (PlatformUtils.isIOS) {
      return CupertinoListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: enabled ? onTap : null,
      );
    } else {
      return ListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: enabled ? onTap : null,
        enabled: enabled,
      );
    }
  }

  // ==================== 平台特定分割线 ====================

  /// 自适应分割线
  static Widget adaptiveDivider({
    double? height,
    double? thickness,
    Color? color,
    double? indent,
    double? endIndent,
  }) {
    if (PlatformUtils.isIOS) {
      return Container(
        height: height ?? 0.5,
        margin: EdgeInsets.only(left: indent ?? 0, right: endIndent ?? 0),
        color: color ?? CupertinoColors.separator,
      );
    } else {
      return Divider(
        height: height,
        thickness: thickness,
        color: color,
        indent: indent,
        endIndent: endIndent,
      );
    }
  }

  // ==================== 平台特定导航栏 ====================

  /// 自适应应用栏
  static PreferredSizeWidget adaptiveAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
  }) {
    if (PlatformUtils.isIOS) {
      return CupertinoNavigationBar(
        middle: Text(title),
        trailing:
            actions != null && actions.isNotEmpty
                ? Row(mainAxisSize: MainAxisSize.min, children: actions)
                : null,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor,
        brightness:
            (backgroundColor?.computeLuminance() ?? 0.5) > 0.5
                ? Brightness.light
                : Brightness.dark,
      );
    } else {
      return AppBar(
        title: Text(title),
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation,
      );
    }
  }

  // ==================== 平台特定主题 ====================

  /// 获取平台特定的主题数据
  static ThemeData getAdaptiveTheme({
    required bool isDarkMode,
    Color? primaryColor,
    Color? accentColor,
  }) {
    final baseTheme = isDarkMode ? ThemeData.dark() : ThemeData.light();

    return PlatformUtils.getPlatformTheme(
      lightTheme: baseTheme.copyWith(
        primaryColor: primaryColor,
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: primaryColor,
          secondary: accentColor,
        ),
      ),
      darkTheme: baseTheme.copyWith(
        primaryColor: primaryColor,
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: primaryColor,
          secondary: accentColor,
        ),
      ),
      isDarkMode: isDarkMode,
    );
  }
}
