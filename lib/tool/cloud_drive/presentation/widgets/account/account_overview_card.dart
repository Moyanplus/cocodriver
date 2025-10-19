import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../common/cloud_drive_common_widgets.dart';

/// 账号概览卡片组件
class AccountOverviewCard extends StatelessWidget {
  final CloudDriveAccount account;
  final VoidCallback? onTap;

  const AccountOverviewCard({super.key, required this.account, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CloudDriveCommonWidgets.buildCard(
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
                      style: CloudDriveUIConfig.titleTextStyle,
                    ),
                    SizedBox(height: CloudDriveUIConfig.spacingXS),
                    Text(
                      account.type.displayName,
                      style: CloudDriveUIConfig.smallTextStyle,
                    ),
                    SizedBox(height: CloudDriveUIConfig.spacingXS),
                    _buildStatusIndicator(account),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 账号详细信息
          _buildAccountDetails(account),
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
        child: _buildDefaultAvatar(account),
      );
    }
    return _buildDefaultAvatar(account);
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar(CloudDriveAccount account) => Container(
    width: 60.w,
    height: 60.h,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: _getAccountTypeColor(account.type),
    ),
    child: Icon(
      _getAccountTypeIcon(account.type),
      size: CloudDriveUIConfig.iconSizeL,
      color: Colors.white,
    ),
  );

  /// 构建状态指示器
  Widget _buildStatusIndicator(CloudDriveAccount account) {
    String status;
    Color statusColor;

    if (account.isLoggedIn) {
      status = '已登录';
      statusColor = CloudDriveUIConfig.successColor;
    } else {
      status = '未登录';
      statusColor = CloudDriveUIConfig.errorColor;
    }

    return CloudDriveCommonWidgets.buildStatusIndicator(
      status: status,
      color: statusColor,
    );
  }

  /// 构建账号详细信息
  Widget _buildAccountDetails(CloudDriveAccount account) {
    return Column(
      children: [
        CloudDriveCommonWidgets.buildInfoRow(label: '账号ID', value: account.id),
        // 注意：CloudDriveAccount模型中没有email和phone字段
        // 这些信息在CloudDriveAccountDetails.accountInfo中
        CloudDriveCommonWidgets.buildInfoRow(
          label: '创建时间',
          value: _formatDateTime(account.createdAt),
        ),
        CloudDriveCommonWidgets.buildInfoRow(
          label: '最后登录',
          value: _formatDateTime(account.lastLoginAt),
        ),
      ],
    );
  }

  /// 获取账号类型颜色
  Color _getAccountTypeColor(CloudDriveType type) {
    switch (type) {
      case CloudDriveType.ali:
        return Colors.blue;
      case CloudDriveType.baidu:
        return Colors.red;
      case CloudDriveType.quark:
        return Colors.green;
      case CloudDriveType.lanzou:
        return Colors.orange;
      case CloudDriveType.pan123:
        return Colors.purple;
      default:
        return CloudDriveUIConfig.secondaryActionColor;
    }
  }

  /// 获取账号类型图标
  IconData _getAccountTypeIcon(CloudDriveType type) {
    switch (type) {
      case CloudDriveType.ali:
        return Icons.cloud;
      case CloudDriveType.baidu:
        return Icons.storage;
      case CloudDriveType.quark:
        return Icons.speed;
      case CloudDriveType.lanzou:
        return Icons.link;
      case CloudDriveType.pan123:
        return Icons.folder;
      default:
        return Icons.cloud_queue;
    }
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '未知';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
