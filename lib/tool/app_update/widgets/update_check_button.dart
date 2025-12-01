/// 检查更新按钮组件
///
/// 在设置页面或其他地方使用的检查更新按钮
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/update_provider.dart';
import '../models/update_models.dart';
import 'update_dialog.dart';

/// 检查更新按钮
class UpdateCheckButton extends ConsumerWidget {
  /// 是否显示图标
  final bool showIcon;

  /// 按钮文本
  final String? text;

  /// 是否作为 ListTile
  final bool asListTile;

  /// 点击回调
  final VoidCallback? onPressed;

  const UpdateCheckButton({
    super.key,
    this.showIcon = true,
    this.text,
    this.asListTile = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateProvider);

    ref.listen<UpdateState>(updateProvider, (previous, state) {
      _handleStateChange(context, state);
    });

    if (asListTile) {
      return _buildListTile(context, ref, updateState);
    }

    return _buildButton(context, ref, updateState);
  }

  Widget _buildButton(BuildContext context, WidgetRef ref, UpdateState state) {
    final isChecking = state is UpdateStateChecking;

    return FilledButton.icon(
      onPressed:
          isChecking
              ? null
              : () {
                onPressed?.call();
                _checkForUpdate(ref);
              },
      icon:
          isChecking
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : Icon(showIcon ? Icons.system_update : null),
      label: Text(text ?? '检查更新'),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    WidgetRef ref,
    UpdateState state,
  ) {
    final isChecking = state is UpdateStateChecking;

    return ListTile(
      leading: showIcon ? const Icon(Icons.system_update) : null,
      title: Text(text ?? '检查更新'),
      subtitle: _buildSubtitle(state),
      trailing:
          isChecking
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.chevron_right),
      onTap:
          isChecking
              ? null
              : () {
                onPressed?.call();
                _checkForUpdate(ref);
              },
    );
  }

  Widget? _buildSubtitle(UpdateState state) {
    return switch (state) {
      UpdateStateNoUpdate(:final currentVersion) => Text(
        '当前版本: ${currentVersion.versionName}',
      ),
      UpdateStateAvailable() => const Text(
        '发现新版本',
        style: TextStyle(color: Colors.green),
      ),
      UpdateStateError(:final message) => Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
      _ => null,
    };
  }

  void _checkForUpdate(WidgetRef ref) {
    ref.read(updateProvider.notifier).checkForUpdate(showNoUpdateMessage: true);
  }

  void _handleStateChange(BuildContext context, UpdateState state) {
    switch (state) {
      case UpdateStateAvailable(:final updateInfo):
        // 有更新，显示更新对话框
        showUpdateDialog(context, updateInfo: updateInfo);
        break;

      case UpdateStateNoUpdate(showMessage: true, :final currentVersion):
        // 没有更新，显示提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('当前已是最新版本 ${currentVersion.versionName}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;

      case UpdateStateError(:final message):
        // 错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;

      case UpdateStateReadyToInstall(:final updateInfo, :final filePath):
        // 下载完成，准备安装
        _showInstallDialog(context, updateInfo, filePath);
        break;

      default:
        break;
    }
  }

  void _showInstallDialog(
    BuildContext context,
    UpdateInfo updateInfo,
    String filePath,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !updateInfo.isForceUpdate,
      builder:
          (context) => AlertDialog(
            title: const Text('下载完成'),
            content: const Text('新版本已下载完成，是否立即安装？'),
            actions: [
              if (!updateInfo.isForceUpdate)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('稍后安装'),
                ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: 执行安装
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('开始安装...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('立即安装'),
              ),
            ],
          ),
    );
  }
}
