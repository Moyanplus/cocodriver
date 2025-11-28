import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../common/cloud_drive_common_widgets.dart';
import '../../../services/provider/cloud_drive_provider_registry.dart';

/// 账号概览卡片组件
class AccountOverviewCard extends StatelessWidget {
  final CloudDriveAccount account;
  final VoidCallback? onTap;

  const AccountOverviewCard({super.key, required this.account, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return CloudDriveCommonWidgets.buildCard(
      backgroundColor: colorScheme.surfaceContainerHighest,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 账号头像和基本信息
          Row(
            children: [
              _buildAccountAvatar(context, account),
              SizedBox(width: CloudDriveUIConfig.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: CloudDriveUIConfig.spacingXS),
                    Text(
                      _getDescriptor(account.type).displayName ?? account.type.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: CloudDriveUIConfig.spacingXS),
                    _buildStatusIndicator(context, account),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 账号详细信息
          _buildAccountDetails(context, account),
        ],
      ),
    );
  }

  /// 构建账号头像
  Widget _buildAccountAvatar(BuildContext context, CloudDriveAccount account) {
    if (account.avatarUrl != null && account.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 30.r,
        backgroundImage: NetworkImage(account.avatarUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // 如果网络图片加载失败，使用默认头像
        },
        child: _buildDefaultAvatar(context, account),
      );
    }
    return _buildDefaultAvatar(context, account);
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar(BuildContext context, CloudDriveAccount account) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getDescriptor(account.type).color?.withOpacity(0.15) ??
            CloudDriveUIConfig.secondaryActionColor.withOpacity(0.15),
      ),
      child: Icon(
        _getDescriptor(account.type).iconData ?? Icons.cloud_queue,
        size: CloudDriveUIConfig.iconSizeL,
        color: colorScheme.onPrimary,
      ),
    );
  }

  /// 构建状态指示器
  Widget _buildStatusIndicator(BuildContext context, CloudDriveAccount account) {
    String status;
    final colorScheme = Theme.of(context).colorScheme;
    Color statusColor;

    if (account.isLoggedIn) {
      status = '已登录';
      statusColor = colorScheme.primary;
    } else {
      status = '未登录';
      statusColor = colorScheme.error;
    }

    return CloudDriveCommonWidgets.buildStatusIndicator(
      status: status,
      color: statusColor,
    );
  }

  /// 构建账号详细信息
  Widget _buildAccountDetails(BuildContext context, CloudDriveAccount account) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        CloudDriveCommonWidgets.buildInfoRow(
          label: '账号ID',
          value: account.id,
          labelColor: colorScheme.onSurfaceVariant,
          valueColor: colorScheme.onSurface,
        ),
        // 注意：CloudDriveAccount模型中没有email和phone字段
        // 这些信息在CloudDriveAccountDetails.accountInfo中
        CloudDriveCommonWidgets.buildInfoRow(
          label: '创建时间',
          value: _formatDateTime(account.createdAt),
          labelColor: colorScheme.onSurfaceVariant,
          valueColor: colorScheme.onSurface,
        ),
        CloudDriveCommonWidgets.buildInfoRow(
          label: '最后登录',
          value: _formatDateTime(account.lastLoginAt),
          labelColor: colorScheme.onSurfaceVariant,
          valueColor: colorScheme.onSurface,
        ),
      ],
    );
  }

  CloudDriveProviderDescriptor _getDescriptor(CloudDriveType type) {
    final descriptor = CloudDriveProviderRegistry.get(type);
    if (descriptor == null) {
      throw StateError('未注册云盘描述: $type');
    }
    return descriptor;
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '未知';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
