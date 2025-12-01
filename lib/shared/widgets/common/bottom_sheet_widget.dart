/// 通用底部弹窗组件工具类
///
/// 提供跨平台的底部弹窗功能，支持iOS和Android的原生样式
/// 使用AdaptiveUtils实现平台适配，确保在不同平台上有一致的用户体验
///
/// 主要功能：
/// - 跨平台底部弹窗显示
/// - 自定义标题和内容
/// - 操作按钮支持
/// - 滚动控制
/// - 拖拽和关闭控制
/// - 高度限制
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/adaptive_utils.dart';

/// 通用底部弹窗组件工具类
///
/// 提供跨平台的底部弹窗功能，支持iOS和Android的原生样式
/// 使用AdaptiveUtils实现平台适配，确保在不同平台上有一致的用户体验
class BottomSheetWidget {
  /// 显示底部弹窗
  ///
  /// [context] 构建上下文
  /// [title] 弹窗标题（可选）
  /// [content] 弹窗内容
  /// [actions] 操作按钮列表（可选）
  /// [isScrollControlled] 是否支持滚动控制
  /// [isDismissible] 是否可以通过点击外部关闭
  /// [enableDrag] 是否支持拖拽关闭
  /// [maxHeight] 最大高度限制（可选）
  ///
  /// 返回泛型结果，如果用户取消则返回null
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    double? maxHeight,
  }) {
    return AdaptiveUtils.showAdaptiveBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      maxHeight: maxHeight,
      child: _BottomSheetContent(
        title: title,
        content: content,
        actions: actions,
        maxHeight: maxHeight,
      ),
    );
  }

  /// 显示简单的底部弹窗（只有内容）
  static Future<T?> showSimple<T>({
    required BuildContext context,
    required Widget content,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return show<T>(
      context: context,
      content: content,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  /// 显示带标题的底部弹窗
  static Future<T?> showWithTitle<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    double? maxHeight,
  }) {
    return show<T>(
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
}

/// 底部弹窗内容组件
class _BottomSheetContent extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final double? maxHeight;

  const _BottomSheetContent({
    this.title,
    required this.content,
    this.actions,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          maxHeight != null ? BoxConstraints(maxHeight: maxHeight!) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          _buildDragHandle(context),

          // 标题区域
          if (title != null) _buildTitle(context),

          // 内容区域
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: content,
            ),
          ),

          // 操作按钮区域
          if (actions != null && actions!.isNotEmpty) _buildActions(context),

          // 底部安全区域
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// 构建拖拽指示器
  Widget _buildDragHandle(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 构建标题
  Widget _buildTitle(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 32.w, right: 16.w, top: 0.h, bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20.w),
            onPressed: () => Navigator.of(context).pop(),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children:
            actions!
                .map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: action,
                  ),
                )
                .toList(),
      ),
    );
  }
}

/// 底部弹窗工具类
class BottomSheetUtils {
  /// 显示确认对话框
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = '确认',
    String cancelText = '取消',
    Color? confirmColor,
  }) async {
    final result = await BottomSheetWidget.show<bool>(
      context: context,
      title: title,
      content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style:
              confirmColor != null
                  ? ElevatedButton.styleFrom(backgroundColor: confirmColor)
                  : null,
          child: Text(confirmText),
        ),
      ],
    );
    return result ?? false;
  }

  /// 显示信息对话框
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = '确定',
  }) async {
    await BottomSheetWidget.show(
      context: context,
      title: title,
      content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(buttonText),
        ),
      ],
    );
  }

  /// 显示选择列表
  static Future<T?> showSelectionList<T>({
    required BuildContext context,
    required String title,
    required List<SelectionItem<T>> items,
  }) async {
    return await BottomSheetWidget.show<T>(
      context: context,
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            items.map((item) => _buildSelectionItem(context, item)).toList(),
      ),
    );
  }

  /// 构建选择项
  static Widget _buildSelectionItem<T>(
    BuildContext context,
    SelectionItem<T> item,
  ) {
    return ListTile(
      leading: item.icon,
      title: Text(item.title),
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      onTap: () => Navigator.of(context).pop(item.value),
    );
  }
}

/// 选择项数据模型
class SelectionItem<T> {
  final T value;
  final String title;
  final String? subtitle;
  final Widget? icon;

  const SelectionItem({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
  });
}
