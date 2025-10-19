import 'package:flutter/material.dart';
import '../data/models/cloud_drive_entities.dart';
import '../utils/file_type_utils.dart';

/// 云盘基础组件
class CloudDriveBaseWidgets {
  /// 云盘类型图标
  static Widget buildCloudDriveIcon(CloudDriveType type, {double size = 24}) =>
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: type.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(type.iconData, size: size * 0.6, color: type.color),
      );

  /// 文件类型图标
  static Widget buildFileIcon(CloudDriveFile file, {double size = 24}) {
    if (file.isFolder) {
      return Icon(Icons.folder, size: size, color: Colors.blue);
    }

    // 使用统一的文件类型工具类
    final fileTypeInfo = FileTypeUtils.getFileTypeInfo(file.name);
    return Icon(fileTypeInfo.iconData, size: size, color: fileTypeInfo.color);
  }

  /// 格式化文件大小
  static String formatFileSize(int size) {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// 时间格式化
  static String formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 加载指示器
  static Widget buildLoadingIndicator({String? message}) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ],
    ),
  );

  /// 空状态组件
  static Widget buildEmptyState({
    required String message,
    IconData? icon,
    VoidCallback? onAction,
    String? actionText,
  }) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon ?? Icons.folder_open, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        if (onAction != null && actionText != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onAction, child: Text(actionText)),
        ],
      ],
    ),
  );

  /// 错误状态组件
  static Widget buildErrorState({
    required String message,
    VoidCallback? onRetry,
    String? retryText,
  }) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(fontSize: 14, color: Colors.red),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text(retryText ?? '重试')),
        ],
      ],
    ),
  );

  /// 分割线
  static Widget buildDivider({double height = 1, Color? color}) =>
      Container(height: height, color: color ?? Colors.grey.shade300);

  /// 间距
  static Widget buildSpacing({double height = 16}) => SizedBox(height: height);

  /// 卡片容器
  static Widget buildCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double? borderRadius,
    BoxBorder? border,
  }) => Container(
    margin: margin ?? const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(borderRadius ?? 8),
      border: border,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
  );

  /// 按钮
  static Widget buildButton({
    required String text,
    required VoidCallback onPressed,
    ButtonStyle? style,
    bool isLoading = false,
    IconData? icon,
  }) => ElevatedButton(
    onPressed: isLoading ? null : onPressed,
    style: style,
    child:
        isLoading
            ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
            : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16),
                  const SizedBox(width: 8),
                ],
                Text(text),
              ],
            ),
  );

  /// 文本按钮
  static Widget buildTextButton({
    required String text,
    required VoidCallback onPressed,
    TextStyle? style,
    IconData? icon,
  }) => TextButton(
    onPressed: onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 8)],
        Text(text, style: style),
      ],
    ),
  );
}
