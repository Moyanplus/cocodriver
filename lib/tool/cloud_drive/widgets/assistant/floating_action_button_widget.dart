import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/cloud_drive_ui_config.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../providers/cloud_drive_provider.dart';
import '../../../../core/logging/log_manager.dart';

/// 悬浮按钮组件
class FloatingActionButtonWidget extends ConsumerWidget {
  const FloatingActionButtonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudDriveProvider);

    // 如果有待操作的文件，显示操作按钮
    if (state.showFloatingActionButton && state.pendingOperationFile != null) {
      final file = state.pendingOperationFile!;
      final operationType = state.pendingOperationType;

      return FloatingActionButton.extended(
        onPressed: () => _handleOperation(context, ref, file, operationType),
        backgroundColor:
            operationType == 'copy'
                ? CloudDriveUIConfig.infoColor
                : CloudDriveUIConfig.warningColor,
        foregroundColor: Colors.white,
        icon: Icon(
          operationType == 'copy' ? Icons.copy : Icons.drive_file_move,
        ),
        label: Text(operationType == 'copy' ? '复制文件' : '移动文件'),
      );
    }

    // 默认显示添加账号按钮
    return FloatingActionButton(
      onPressed: () => _showAddAccountDialog(context, ref),
      backgroundColor: CloudDriveUIConfig.primaryActionColor,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }

  /// 处理文件操作
  Future<void> _handleOperation(
    BuildContext context,
    WidgetRef ref,
    CloudDriveFile file,
    String? operationType,
  ) async {
    final notifier = ref.read(cloudDriveProvider.notifier);

    LogManager().cloudDrive('🎯 悬浮按钮点击事件开始');
    LogManager().cloudDrive('📄 待操作文件: ${file.name}');
    LogManager().cloudDrive('🔧 操作类型: ${operationType}');

    try {
      // 执行操作
      LogManager().cloudDrive('🚀 调用 executePendingOperation');
      final success = await notifier.executePendingOperation();
      LogManager().cloudDrive('✅ executePendingOperation 执行完成，结果: $success');

      // 根据操作结果显示不同的提示
      if (context.mounted) {
        if (success) {
          LogManager().cloudDrive('📱 显示成功提示 SnackBar');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '文件${operationType == 'copy' ? '复制' : '移动'}成功: ${file.name}',
              ),
              backgroundColor: CloudDriveUIConfig.successColor,
              duration: const Duration(seconds: 3),
            ),
          );
          LogManager().cloudDrive('✅ 成功 SnackBar 显示完成');
        } else {
          LogManager().cloudDrive('📱 显示失败提示 SnackBar');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '文件${operationType == 'copy' ? '复制' : '移动'}失败: ${file.name}',
              ),
              backgroundColor: CloudDriveUIConfig.errorColor,
              duration: const Duration(seconds: 3),
            ),
          );
          LogManager().cloudDrive('✅ 失败 SnackBar 显示完成');
        }
      } else {
        LogManager().cloudDrive('⚠️ Widget 已卸载，无法显示 SnackBar');
      }
    } catch (e) {
      LogManager().error('❌ 执行操作时发生异常', exception: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: CloudDriveUIConfig.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 显示添加账号对话框
  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    // 这里需要导入AddAccountFormWidget，暂时用简单的对话框代替
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('添加账号'),
            content: Text('添加账号功能需要从原页面导入'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('关闭'),
              ),
            ],
          ),
    );
  }
}
