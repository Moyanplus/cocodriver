import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/common/bottom_sheet_widget.dart';
import '../config/cloud_drive_ui_config.dart';
import '../models/cloud_drive_models.dart';
import '../providers/cloud_drive_provider.dart';
import '../widgets/add_account_form_widget.dart';
import '../widgets/assistant/assistant.dart';
import 'cloud_drive_account_detail_page.dart';
import 'cloud_drive_direct_link_page.dart';
import 'cloud_drive_upload_page.dart';

/// 云盘助手页面 - 重构版本
class CloudDriveAssistantPageNew extends ConsumerStatefulWidget {
  const CloudDriveAssistantPageNew({super.key});

  @override
  ConsumerState<CloudDriveAssistantPageNew> createState() =>
      _CloudDriveAssistantPageNewState();
}

class _CloudDriveAssistantPageNewState
    extends ConsumerState<CloudDriveAssistantPageNew> {
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
      backgroundColor: CloudDriveUIConfig.backgroundColor,
      body:
          state.accounts.isEmpty && !state.isLoading
              ? _buildEmptyState()
              : _buildContent(),
      floatingActionButton: const FloatingActionButtonWidget(),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 80,
            color: CloudDriveUIConfig.secondaryTextColor,
          ),
          SizedBox(height: CloudDriveUIConfig.spacingL),
          Text(
            '暂无云盘账号',
            style: CloudDriveUIConfig.titleTextStyle.copyWith(
              color: CloudDriveUIConfig.secondaryTextColor,
            ),
          ),
          SizedBox(height: CloudDriveUIConfig.spacingS),
          Text(
            '点击右下角按钮添加您的第一个云盘账号',
            style: CloudDriveUIConfig.bodyTextStyle.copyWith(
              color: CloudDriveUIConfig.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: CloudDriveUIConfig.spacingXL),
          ElevatedButton.icon(
            onPressed: _handleAddAccount,
            icon: const Icon(Icons.add),
            label: const Text('添加账号'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CloudDriveUIConfig.primaryActionColor,
              foregroundColor: Colors.white,
              padding: CloudDriveUIConfig.buttonPadding,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // 头部区域
        SliverToBoxAdapter(
          child: AssistantHeader(onAddAccount: _handleAddAccount),
        ),

        // 账号列表区域
        SliverToBoxAdapter(
          child: AccountListSection(onAccountTap: _handleAccountTap),
        ),

        // 快速操作区域
        SliverToBoxAdapter(
          child: QuickActionsSection(
            onAddAccount: _handleAddAccount,
            onDirectLink: _handleDirectLink,
            onUpload: _handleUpload,
          ),
        ),

        // 底部间距
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
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

  /// 处理直链解析
  void _handleDirectLink() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CloudDriveDirectLinkPage()),
    );
  }

  /// 处理文件上传
  void _handleUpload() {
    final state = ref.read(cloudDriveProvider);
    final currentAccount = state.currentAccount;

    if (currentAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先选择一个云盘账号'),
          backgroundColor: CloudDriveUIConfig.warningColor,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CloudDriveUploadPage(
              account: currentAccount,
              folderId: 'root',
              folderName: '根目录',
            ),
      ),
    );
  }

  /// 显示账号添加成功提示
  void _showAccountAddSuccess(String accountName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('账号 "$accountName" 添加成功'),
          ],
        ),
        backgroundColor: CloudDriveUIConfig.successColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 显示账号添加错误提示
  void _showAccountAddError(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('添加账号失败: $error')),
          ],
        ),
        backgroundColor: CloudDriveUIConfig.errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
