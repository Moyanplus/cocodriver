/// 通用组件工具类
/// 
/// 提供应用程序中常用的UI组件和工具方法
/// 包括加载指示器、错误状态、空状态等通用组件
/// 
/// 主要功能：
/// - 加载指示器组件
/// - 错误状态组件
/// - 空状态组件
/// - 确认对话框
/// - 其他通用UI组件
/// 
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年

import 'package:flutter/material.dart';
import 'bottom_sheet_widget.dart';
  /// 构建加载指示器
  static Widget buildLoadingIndicator({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 16)),
          ],
        ],
      ),
    );
  }

  /// 构建错误状态
  static Widget buildErrorState({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              '出现错误',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onRetry, child: const Text('重试')),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建空状态
  static Widget buildEmptyState({
    required String message,
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onAction, child: Text(actionText)),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建按钮
  static Widget buildButton({
    required String text,
    required VoidCallback onPressed,
    Icon? icon,
    ButtonStyle? style,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon, const SizedBox(width: 8)],
          Text(text),
        ],
      ),
    );
  }

  /// 构建卡片
  static Widget buildCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  /// 构建列表项
  static Widget buildListTile({
    required String title,
    String? subtitle,
    IconData? leading,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: leading != null ? CircleAvatar(child: Icon(leading)) : null,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  // ==================== 底部弹窗便捷方法 ====================

  /// 显示底部弹窗
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    double? maxHeight,
  }) {
    return BottomSheetWidget.show<T>(
      context: context,
      title: title,
      content: content,
      actions: actions,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      maxHeight: maxHeight,
    );
  }

  /// 显示简单的底部弹窗
  static Future<T?> showSimpleBottomSheet<T>({
    required BuildContext context,
    required Widget content,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return BottomSheetWidget.showSimple<T>(
      context: context,
      content: content,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  /// 显示带标题的底部弹窗
  static Future<T?> showBottomSheetWithTitle<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return BottomSheetWidget.showWithTitle<T>(
      context: context,
      title: title,
      content: content,
      actions: actions,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  /// 显示确认对话框（底部弹窗版本）
  static Future<bool> showConfirmBottomSheet({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = '确认',
    String cancelText = '取消',
    Color? confirmColor,
  }) {
    return BottomSheetUtils.showConfirmDialog(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmColor: confirmColor,
    );
  }

  /// 显示信息对话框（底部弹窗版本）
  static Future<void> showInfoBottomSheet({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = '确定',
  }) {
    return BottomSheetUtils.showInfoDialog(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }
}
