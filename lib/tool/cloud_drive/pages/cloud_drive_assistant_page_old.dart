import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/logging/log_manager.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/widgets/common/bottom_sheet_widget.dart';
import '../../../../shared/widgets/common/common_widgets.dart';
import '../config/cloud_drive_ui_config.dart';
import 'cloud_drive_account_detail_page.dart';
import 'cloud_drive_widgets.dart';
import '../base/cloud_drive_operation_service.dart';
import '../models/cloud_drive_models.dart';
import '../providers/cloud_drive_provider.dart';
import '../widgets/add_account_form_widget.dart';

/// 云盘助手页面
class CloudDriveAssistantPage extends ConsumerStatefulWidget {
  const CloudDriveAssistantPage({super.key});

  @override
  ConsumerState<CloudDriveAssistantPage> createState() =>
      _CloudDriveAssistantPageState();
}

class _CloudDriveAssistantPageState
    extends ConsumerState<CloudDriveAssistantPage> {
  @override
  void initState() {
    super.initState();
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cloudDriveProvider.notifier).loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cloudDriveProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body:
          state.accounts.isEmpty && !state.isLoading
              ? Center(
                child: CommonWidgets.buildEmptyState(
                  message: '暂无云盘账号',
                  onAction: _handleAddAccount,
                  actionText: '添加账号',
                ),
              )
              : const CloudDriveWidget(),
      // 添加悬浮按钮
      floatingActionButton: _buildFloatingActionButton(state),
    );
  }

  /// 处理添加账号
  void _handleAddAccount() {
    BottomSheetWidget.showWithTitle(
      context: context,
      title: '添加云盘账号',
      content: AddAccountFormWidget(
        onAccountCreated: (account) async {
          try {
            await ref.read(cloudDriveProvider.notifier).addAccount(account);
            Navigator.pop(context);
            _showAccountAddSuccess(account.name);
          } catch (e) {
            _showAccountAddError(e);
          }
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  /// 处理账号点击
  void _handleAccountTap(CloudDriveAccount account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CloudDriveAccountDetailPage(account: account),
      ),
    );
  }

  Widget _buildFloatingActionButton(CloudDriveState state) {
    // 如果有待操作的文件，显示复制/移动按钮
    if (state.showFloatingActionButton && state.pendingOperationFile != null) {
      final file = state.pendingOperationFile!;
      final operationType = state.pendingOperationType;

      return FloatingActionButton.extended(
        onPressed: () async {
          final notifier = ref.read(cloudDriveProvider.notifier);

          LogManager().cloudDrive('🎯 悬浮按钮点击事件开始');
          LogManager().cloudDrive('📄 待操作文件: ${file.name}');
          LogManager().cloudDrive('🔧 操作类型: ${operationType}');
          LogManager().cloudDrive(
            '👤 当前账号: ${state.currentAccount?.name ?? 'null'}',
          );

          LogManager().cloudDrive('✅ 参数验证通过，开始执行操作');

          try {
            // 执行操作
            LogManager().cloudDrive('🚀 调用 executePendingOperation');
            final success = await notifier.executePendingOperation();
            LogManager().cloudDrive(
              '✅ executePendingOperation 执行完成，结果: $success',
            );

            // 根据操作结果显示不同的提示
            if (mounted) {
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
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('操作异常: $e'),
                  backgroundColor: CloudDriveUIConfig.errorColor,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }

          LogManager().cloudDrive('🎯 悬浮按钮点击事件结束');
        },
        icon: Icon(
          state.pendingOperationType == 'copy'
              ? Icons.copy
              : Icons.drive_file_move,
          color: CloudDriveUIConfig.backgroundColor,
        ),
        label: Text(
          state.pendingOperationType == 'copy' ? '复制到这里' : '移动到这里',
          style: TextStyle(color: CloudDriveUIConfig.backgroundColor),
        ),
        backgroundColor:
            state.pendingOperationType == 'copy'
                ? CloudDriveUIConfig.infoColor
                : CloudDriveUIConfig.warningColor,
      );
    }

    // 默认显示创建文件夹和上传按钮
    return FloatingActionButton(
      onPressed: () => _showActionMenu(context),
      tooltip: '更多操作',
      child: const Icon(Icons.add),
    );
  }

  void _showActionMenu(BuildContext context) {
    final state = ref.read(cloudDriveProvider);
    final currentAccount = state.currentAccount;

    // 如果没有当前账号，显示提示
    if (currentAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先选择云盘账号'),
          backgroundColor: CloudDriveUIConfig.warningColor,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 检查支持的操作
    final supportsCreateFolder =
        CloudDriveOperationService.isOperationSupported(
          currentAccount,
          'createFolder',
        );

    // 使用响应式底部弹窗
    BottomSheetWidget.show(
      context: context,
      title: '更多操作',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 创建文件夹选项
          if (supportsCreateFolder) ...[
            _buildResponsiveListTile(
              context: context,
              icon: Icons.create_new_folder,
              title: '创建文件夹',
              onTap: () {
                Navigator.pop(context);
                _showCreateFolderDialog(context);
              },
            ),
          ] else ...[
            _buildResponsiveListTile(
              context: context,
              icon: Icons.create_new_folder,
              title: '创建文件夹（暂不支持）',
              enabled: false,
            ),
          ],
          // 上传文件选项（暂时都不支持）
          _buildResponsiveListTile(
            context: context,
            icon: Icons.upload_file,
            title: '上传文件（开发中）',
            enabled: false,
          ),
        ],
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getCardRadius(),
              ),
            ),
            title: Text(
              '创建文件夹',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: ResponsiveUtils.getResponsiveFontSize(20.sp),
              ),
            ),
            content: Container(
              width: ResponsiveUtils.getMaxWidth() * 0.8,
              child: TextField(
                controller: controller,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
                ),
                decoration: InputDecoration(
                  labelText: '文件夹名称',
                  hintText: '请输入文件夹名称',
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
                  ),
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.w,
                    ),
                  ),
                  contentPadding: ResponsiveUtils.getResponsivePadding(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                autofocus: true,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: ResponsiveUtils.getResponsivePadding(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                ),
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final folderName = controller.text.trim();
                  if (folderName.isNotEmpty) {
                    Navigator.pop(context);
                    _createFolder(folderName);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: ResponsiveUtils.getResponsivePadding(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  '创建',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _createFolder(String folderName) async {
    final state = ref.read(cloudDriveProvider);
    final currentAccount = state.currentAccount;

    if (currentAccount == null) {
      _showErrorMessage('请先选择云盘账号');
      return;
    }

    // 检查是否支持创建文件夹
    if (!CloudDriveOperationService.isOperationSupported(
      currentAccount,
      'createFolder',
    )) {
      _showErrorMessage('当前云盘不支持创建文件夹功能');
      return;
    }

    // 获取当前文件夹ID
    String? parentFolderId;
    if (state.folderPath.isNotEmpty) {
      parentFolderId = state.folderPath.last.id;
    }

    _logFolderCreation(folderName, parentFolderId, currentAccount);

    try {
      // 使用统一的操作服务创建文件夹
      final result = await CloudDriveOperationService.createFolder(
        account: currentAccount,
        folderName: folderName,
        parentFolderId: parentFolderId,
      );

      await _handleCreateFolderResult(result, folderName);
    } catch (e, stackTrace) {
      _handleCreateFolderError(e, stackTrace, folderName);
    }
  }

  /// 显示错误消息
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 显示成功消息
  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: CloudDriveUIConfig.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 记录文件夹创建日志
  void _logFolderCreation(
    String folderName,
    String? parentFolderId,
    CloudDriveAccount account,
  ) {
    LogManager().cloudDrive('📁 开始创建文件夹');
    LogManager().cloudDrive('📝 文件夹名称: $folderName');
    LogManager().cloudDrive('📂 父文件夹ID: ${parentFolderId ?? '根目录'}');
    LogManager().cloudDrive(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
    );
  }

  /// 处理创建文件夹结果
  Future<void> _handleCreateFolderResult(
    Map<String, dynamic>? result,
    String folderName,
  ) async {
    if (result != null && result['success'] == true) {
      LogManager().cloudDrive('✅ 文件夹创建成功');

      // 如果返回结果中包含文件夹对象，直接添加到状态
      if (result['folder'] != null) {
        final folder = result['folder'] as CloudDriveFile;
        LogManager().cloudDrive('📁 添加新文件夹到状态: ${folder.name}');

        // 直接添加文件夹到当前状态
        ref
            .read(cloudDriveProvider.notifier)
            .addFileToState(folder, operationType: 'create');
      } else {
        // 兜底方案：重新加载目录
        LogManager().cloudDrive('🔄 未返回文件夹对象，重新加载目录');
        await ref
            .read(cloudDriveProvider.notifier)
            .loadCurrentFolder(forceRefresh: true);
      }

      _showSuccessMessage('文件夹创建成功: $folderName');
    } else {
      LogManager().cloudDrive('❌ 文件夹创建失败');
      _showErrorMessage('文件夹创建失败，请重试');
    }
  }

  /// 处理创建文件夹错误
  void _handleCreateFolderError(
    dynamic e,
    StackTrace stackTrace,
    String folderName,
  ) {
    LogManager().cloudDrive('❌ 创建文件夹异常: $e');
    LogManager().cloudDrive('📄 错误堆栈: $stackTrace');

    _showErrorMessage('创建文件夹失败: $e');
  }

  void _showAccountAddSuccess(String accountName) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('账号添加成功: $accountName'),
          backgroundColor: CloudDriveUIConfig.successColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showAccountAddError(dynamic e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('账号添加失败: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 构建响应式ListTile
  Widget _buildResponsiveListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              enabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.5),
          size: ResponsiveUtils.getIconSize(24.sp),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color:
                enabled
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.5),
            fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
          ),
        ),
        onTap: enabled ? onTap : null,
        enabled: enabled,
        contentPadding: ResponsiveUtils.getResponsivePadding(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.getCardRadius()),
        ),
      ),
    );
  }
}
