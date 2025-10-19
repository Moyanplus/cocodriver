import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../providers/cloud_drive_provider.dart';

/// 快速操作区域组件
class QuickActionsSection extends ConsumerWidget {
  final VoidCallback onAddAccount;
  final VoidCallback onDirectLink;
  final VoidCallback onUpload;

  const QuickActionsSection({
    super.key,
    required this.onAddAccount,
    required this.onDirectLink,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudDriveProvider);
    final hasAccounts = state.accounts.isNotEmpty;

    return Container(
      padding: CloudDriveUIConfig.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('快速操作', style: CloudDriveUIConfig.titleTextStyle),
          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 操作按钮网格
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: CloudDriveUIConfig.spacingM,
            mainAxisSpacing: CloudDriveUIConfig.spacingM,
            childAspectRatio: 1.5,
            children: [
              _buildActionCard(
                context: context,
                icon: Icons.add_circle_outline,
                title: '添加账号',
                subtitle: '添加新的云盘账号',
                color: CloudDriveUIConfig.primaryActionColor,
                onTap: onAddAccount,
              ),
              _buildActionCard(
                context: context,
                icon: Icons.link,
                title: '直链解析',
                subtitle: '解析分享链接',
                color: CloudDriveUIConfig.infoColor,
                onTap: onDirectLink,
                enabled: true,
              ),
              _buildActionCard(
                context: context,
                icon: Icons.cloud_upload,
                title: '文件上传',
                subtitle: '上传文件到云盘',
                color: CloudDriveUIConfig.successColor,
                onTap: onUpload,
                enabled: hasAccounts,
              ),
              _buildActionCard(
                context: context,
                icon: Icons.settings,
                title: '设置',
                subtitle: '管理应用设置',
                color: CloudDriveUIConfig.secondaryActionColor,
                onTap: () => _showSettings(context),
                enabled: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建操作卡片
  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Card(
      elevation: enabled ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
        child: Container(
          padding: CloudDriveUIConfig.cardPadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
            color:
                enabled
                    ? null
                    : CloudDriveUIConfig.secondaryTextColor.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: CloudDriveUIConfig.iconSizeL,
                color: enabled ? color : CloudDriveUIConfig.secondaryTextColor,
              ),
              SizedBox(height: CloudDriveUIConfig.spacingS),
              Text(
                title,
                style: CloudDriveUIConfig.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      enabled
                          ? CloudDriveUIConfig.textColor
                          : CloudDriveUIConfig.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: CloudDriveUIConfig.spacingXS),
              Text(
                subtitle,
                style: CloudDriveUIConfig.smallTextStyle.copyWith(
                  color:
                      enabled
                          ? CloudDriveUIConfig.secondaryTextColor
                          : CloudDriveUIConfig.secondaryTextColor.withOpacity(
                            0.6,
                          ),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!enabled) ...[
                SizedBox(height: CloudDriveUIConfig.spacingXS),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: CloudDriveUIConfig.spacingXS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: CloudDriveUIConfig.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '需要账号',
                    style: CloudDriveUIConfig.smallTextStyle.copyWith(
                      color: CloudDriveUIConfig.warningColor,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 显示设置
  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('设置'),
            content: Text('设置功能开发中...'),
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
