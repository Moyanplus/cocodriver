import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/cloud_drive_ui_config.dart';

/// 云盘通用UI组件库
/// 提供常用的UI组件，减少重复代码
class CloudDriveCommonWidgets {
  // 私有构造函数，防止实例化
  CloudDriveCommonWidgets._();

  /// 构建标准卡片
  static Widget buildCard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    List<BoxShadow>? shadow,
    double? borderRadius,
    VoidCallback? onTap,
  }) {
    final card = Container(
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? CloudDriveUIConfig.cardPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? CloudDriveUIConfig.cardBackgroundColor,
        borderRadius: BorderRadius.circular(
          borderRadius ?? CloudDriveUIConfig.cardRadius,
        ),
        boxShadow: shadow ?? CloudDriveUIConfig.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          borderRadius ?? CloudDriveUIConfig.cardRadius,
        ),
        child: card,
      );
    }

    return card;
  }

  /// 构建标准按钮
  static Widget buildButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    EdgeInsets? padding,
    double? borderRadius,
    double? height,
    bool isLoading = false,
    Widget? icon,
  }) {
    return SizedBox(
      height: height ?? CloudDriveUIConfig.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? CloudDriveUIConfig.primaryActionColor,
          foregroundColor: textColor ?? Colors.white,
          padding: padding ?? CloudDriveUIConfig.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? CloudDriveUIConfig.buttonRadius,
            ),
          ),
          elevation: 2,
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      icon,
                      SizedBox(width: CloudDriveUIConfig.spacingS),
                    ],
                    Text(text, style: CloudDriveUIConfig.buttonTextStyle),
                  ],
                ),
      ),
    );
  }

  /// 构建次要按钮
  static Widget buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    EdgeInsets? padding,
    double? borderRadius,
    double? height,
    Widget? icon,
  }) {
    return SizedBox(
      height: height ?? CloudDriveUIConfig.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? CloudDriveUIConfig.primaryActionColor,
          padding: padding ?? CloudDriveUIConfig.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? CloudDriveUIConfig.buttonRadius,
            ),
          ),
          side: BorderSide(
            color: backgroundColor ?? CloudDriveUIConfig.primaryActionColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon,
              SizedBox(width: CloudDriveUIConfig.spacingS),
            ],
            Text(
              text,
              style: CloudDriveUIConfig.buttonTextStyle.copyWith(
                color: textColor ?? CloudDriveUIConfig.primaryActionColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建输入框
  static Widget buildInputField({
    required String label,
    String? hint,
    String? initialValue,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool obscureText = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
    TextInputType? keyboardType,
    int? maxLines,
    EdgeInsets? padding,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CloudDriveUIConfig.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: CloudDriveUIConfig.spacingS),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: padding ?? CloudDriveUIConfig.inputPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                CloudDriveUIConfig.inputRadius,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                CloudDriveUIConfig.inputRadius,
              ),
              borderSide: BorderSide(color: CloudDriveUIConfig.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                CloudDriveUIConfig.inputRadius,
              ),
              borderSide: BorderSide(
                color: CloudDriveUIConfig.primaryActionColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建信息行
  static Widget buildInfoRow({
    required String label,
    required String value,
    VoidCallback? onTap,
    Widget? trailing,
    Color? labelColor,
    Color? valueColor,
  }) {
    final row = Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: CloudDriveUIConfig.bodyTextStyle.copyWith(
              color: labelColor ?? CloudDriveUIConfig.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: CloudDriveUIConfig.bodyTextStyle.copyWith(
              color: valueColor ?? CloudDriveUIConfig.textColor,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: CloudDriveUIConfig.spacingS),
          child: row,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: CloudDriveUIConfig.spacingS),
      child: row,
    );
  }

  /// 构建状态指示器
  static Widget buildStatusIndicator({
    required String status,
    Color? color,
    Widget? icon,
  }) {
    Color statusColor;
    Widget statusIcon;

    switch (status.toLowerCase()) {
      case 'success':
      case '成功':
        statusColor = CloudDriveUIConfig.successColor;
        statusIcon =
            icon ?? const Icon(Icons.check_circle, color: Colors.white);
        break;
      case 'error':
      case '错误':
      case '失败':
        statusColor = CloudDriveUIConfig.errorColor;
        statusIcon = icon ?? const Icon(Icons.error, color: Colors.white);
        break;
      case 'warning':
      case '警告':
        statusColor = CloudDriveUIConfig.warningColor;
        statusIcon = icon ?? const Icon(Icons.warning, color: Colors.white);
        break;
      case 'info':
      case '信息':
        statusColor = CloudDriveUIConfig.infoColor;
        statusIcon = icon ?? const Icon(Icons.info, color: Colors.white);
        break;
      default:
        statusColor = color ?? CloudDriveUIConfig.secondaryActionColor;
        statusIcon = icon ?? const Icon(Icons.circle, color: Colors.white);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CloudDriveUIConfig.spacingS,
        vertical: CloudDriveUIConfig.spacingXS,
      ),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(CloudDriveUIConfig.buttonRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: CloudDriveUIConfig.iconSizeS,
            height: CloudDriveUIConfig.iconSizeS,
            child: statusIcon,
          ),
          SizedBox(width: CloudDriveUIConfig.spacingXS),
          Text(
            status,
            style: CloudDriveUIConfig.smallTextStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建加载状态
  static Widget buildLoadingState({String? message, double? size}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 40.w,
            height: size ?? 40.h,
            child: const CircularProgressIndicator(),
          ),
          if (message != null) ...[
            SizedBox(height: CloudDriveUIConfig.spacingM),
            Text(message, style: CloudDriveUIConfig.bodyTextStyle),
          ],
        ],
      ),
    );
  }

  /// 构建空状态
  static Widget buildEmptyState({
    required String message,
    Widget? icon,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon,
            SizedBox(height: CloudDriveUIConfig.spacingM),
          ],
          Text(
            message,
            style: CloudDriveUIConfig.bodyTextStyle.copyWith(
              color: CloudDriveUIConfig.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[
            SizedBox(height: CloudDriveUIConfig.spacingL),
            buildButton(text: actionText, onPressed: onAction),
          ],
        ],
      ),
    );
  }

  /// 构建分割线
  static Widget buildDivider({
    double? height,
    Color? color,
    EdgeInsets? margin,
  }) {
    return Container(
      margin:
          margin ?? EdgeInsets.symmetric(vertical: CloudDriveUIConfig.spacingM),
      height: height ?? 1.h,
      color: color ?? CloudDriveUIConfig.dividerColor,
    );
  }

  /// 构建间距
  static Widget buildSpacing({double? height, double? width}) {
    return SizedBox(height: height, width: width);
  }

  /// 构建可点击的信息行
  static Widget buildClickableInfoRow({
    required String label,
    required String value,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
      child: Container(
        padding: CloudDriveUIConfig.cardPadding,
        decoration: BoxDecoration(
          border: Border.all(
            color: CloudDriveUIConfig.dividerColor.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: CloudDriveUIConfig.bodyTextStyle.copyWith(
                  color: CloudDriveUIConfig.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: CloudDriveUIConfig.bodyTextStyle.copyWith(
                  color: CloudDriveUIConfig.textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: CloudDriveUIConfig.spacingS),
              trailing,
            ],
            if (onTap != null) ...[
              SizedBox(width: CloudDriveUIConfig.spacingS),
              Icon(
                Icons.chevron_right,
                color: CloudDriveUIConfig.secondaryTextColor,
                size: CloudDriveUIConfig.iconSizeS,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
