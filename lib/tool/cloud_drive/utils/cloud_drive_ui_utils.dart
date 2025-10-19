import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/logging/log_manager.dart';

/// 云盘UI工具类
/// 提供通用的UI辅助方法，减少代码重复
class CloudDriveUIUtils {
  /// 显示成功消息
  static void showSuccessMessage(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration,
      ),
    );
  }

  /// 显示错误消息
  static void showErrorMessage(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: duration,
      ),
    );
  }

  /// 显示警告消息
  static void showWarningMessage(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: duration,
      ),
    );
  }

  /// 显示信息消息
  static void showInfoMessage(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: duration,
      ),
    );
  }

  /// 复制文本到剪贴板
  static Future<void> copyToClipboard(
    BuildContext context,
    String text, {
    String? successMessage,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));

      if (context.mounted && successMessage != null) {
        showSuccessMessage(context, successMessage);
      }

      LogManager().cloudDrive(
        '文本已复制到剪贴板: ${text.length > 50 ? '${text.substring(0, 50)}...' : text}',
        className: 'CloudDriveUIUtils',
        methodName: 'copyToClipboard',
        data: {'textLength': text.length},
      );
    } catch (e) {
      LogManager().error(
        '复制到剪贴板失败',
        className: 'CloudDriveUIUtils',
        methodName: 'copyToClipboard',
        exception: e,
      );

      if (context.mounted) {
        showErrorMessage(context, '复制失败: ${e.toString()}');
      }
    }
  }

  /// 显示加载对话框
  static void showLoadingDialog(
    BuildContext context,
    String message, {
    bool barrierDismissible = false,
  }) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Expanded(child: Text(message)),
              ],
            ),
          ),
    );
  }

  /// 关闭对话框
  static void dismissDialog(BuildContext context) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  /// 显示确认对话框
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = '确认',
    String cancelText = '取消',
    Color? confirmColor,
  }) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style:
                    confirmColor != null
                        ? TextButton.styleFrom(foregroundColor: confirmColor)
                        : null,
                child: Text(confirmText),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  /// 显示信息对话框
  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = '确认',
  }) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(buttonText),
              ),
            ],
          ),
    );
  }

  /// 获取文件类型颜色
  static Color getFileTypeColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Colors.purple;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return Colors.indigo;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Colors.teal;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
        return Colors.amber;
      case 'txt':
      case 'md':
        return Colors.grey[600] ?? Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// 获取文件类型图标
  static IconData getFileTypeIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audio_file;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
        return Icons.archive;
      case 'txt':
      case 'md':
        return Icons.text_snippet;
      case 'code':
      case 'js':
      case 'ts':
      case 'dart':
      case 'py':
      case 'java':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// 构建文件类型图标组件
  static Widget buildFileTypeIcon(
    String extension, {
    double size = 24,
    EdgeInsets padding = const EdgeInsets.all(8),
  }) {
    final color = getFileTypeColor(extension);
    final icon = getFileTypeIcon(extension);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }

  /// 显示进度对话框
  static void showProgressDialog(
    BuildContext context, {
    required String title,
    required double progress,
    String? subtitle,
    bool barrierDismissible = false,
  }) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 16),
                Text('${(progress * 100).toInt()}%'),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
    );
  }

  /// 验证输入是否为空
  static bool validateInput(
    BuildContext context,
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      showWarningMessage(context, '请输入$fieldName');
      return false;
    }
    return true;
  }

  /// 验证URL格式
  static bool validateUrl(BuildContext context, String? url) {
    if (!validateInput(context, url, '链接')) {
      return false;
    }

    final uri = Uri.tryParse(url!.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      showWarningMessage(context, '请输入有效的链接地址');
      return false;
    }

    return true;
  }
}
