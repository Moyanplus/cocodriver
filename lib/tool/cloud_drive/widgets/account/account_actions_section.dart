import 'package:flutter/material.dart';
import '../../config/cloud_drive_ui_config.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../common/cloud_drive_common_widgets.dart';

/// 账号操作按钮组件
class AccountActionsSection extends StatelessWidget {
  final CloudDriveAccount account;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRefresh;
  final VoidCallback? onLogin;
  final VoidCallback? onLogout;
  final VoidCallback? onTest;

  const AccountActionsSection({
    super.key,
    required this.account,
    this.onEdit,
    this.onDelete,
    this.onRefresh,
    this.onLogin,
    this.onLogout,
    this.onTest,
  });

  @override
  Widget build(BuildContext context) {
    return CloudDriveCommonWidgets.buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('操作', style: CloudDriveUIConfig.titleTextStyle),
          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 主要操作按钮
          _buildPrimaryActions(context),

          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 次要操作按钮
          _buildSecondaryActions(context),
        ],
      ),
    );
  }

  /// 构建主要操作按钮
  Widget _buildPrimaryActions(BuildContext context) {
    return Column(
      children: [
        // 登录/登出按钮
        if (account.isLoggedIn)
          CloudDriveCommonWidgets.buildButton(
            text: '退出登录',
            onPressed: onLogout ?? () {},
            backgroundColor: CloudDriveUIConfig.errorColor,
            icon: const Icon(Icons.logout, color: Colors.white),
          )
        else
          CloudDriveCommonWidgets.buildButton(
            text: '登录',
            onPressed: onLogin ?? () {},
            backgroundColor: CloudDriveUIConfig.successColor,
            icon: const Icon(Icons.login, color: Colors.white),
          ),

        SizedBox(height: CloudDriveUIConfig.spacingS),

        // 测试连接按钮
        if (account.isLoggedIn)
          CloudDriveCommonWidgets.buildSecondaryButton(
            text: '测试连接',
            onPressed: onTest ?? () {},
            icon: const Icon(Icons.network_check),
          ),
      ],
    );
  }

  /// 构建次要操作按钮
  Widget _buildSecondaryActions(BuildContext context) {
    return Column(
      children: [
        // 编辑按钮
        CloudDriveCommonWidgets.buildSecondaryButton(
          text: '编辑账号',
          onPressed: onEdit ?? () {},
          icon: const Icon(Icons.edit),
        ),

        SizedBox(height: CloudDriveUIConfig.spacingS),

        // 刷新按钮
        CloudDriveCommonWidgets.buildSecondaryButton(
          text: '刷新信息',
          onPressed: onRefresh ?? () {},
          icon: const Icon(Icons.refresh),
        ),

        SizedBox(height: CloudDriveUIConfig.spacingS),

        // 删除按钮
        CloudDriveCommonWidgets.buildSecondaryButton(
          text: '删除账号',
          onPressed: onDelete ?? () {},
          textColor: CloudDriveUIConfig.errorColor,
          backgroundColor: CloudDriveUIConfig.errorColor,
          icon: Icon(Icons.delete, color: CloudDriveUIConfig.errorColor),
        ),
      ],
    );
  }
}
