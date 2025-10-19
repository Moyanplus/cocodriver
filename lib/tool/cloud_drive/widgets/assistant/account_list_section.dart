import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/cloud_drive_ui_config.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../providers/cloud_drive_provider.dart';

/// 账号列表区域组件
class AccountListSection extends ConsumerWidget {
  final Function(CloudDriveAccount) onAccountTap;

  const AccountListSection({super.key, required this.onAccountTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudDriveProvider);
    final accounts = state.accounts;

    if (accounts.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: CloudDriveUIConfig.pagePadding,
          child: Text('云盘账号', style: CloudDriveUIConfig.titleTextStyle),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: CloudDriveUIConfig.spacingM,
          ),
          itemCount: accounts.length,
          separatorBuilder:
              (context, index) => SizedBox(height: CloudDriveUIConfig.spacingS),
          itemBuilder: (context, index) {
            final account = accounts[index];
            return _buildAccountCard(context, account);
          },
        ),
      ],
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: CloudDriveUIConfig.pagePadding,
      child: Column(
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: CloudDriveUIConfig.secondaryTextColor,
          ),
          SizedBox(height: CloudDriveUIConfig.spacingM),
          Text(
            '暂无云盘账号',
            style: CloudDriveUIConfig.titleTextStyle.copyWith(
              color: CloudDriveUIConfig.secondaryTextColor,
            ),
          ),
          SizedBox(height: CloudDriveUIConfig.spacingS),
          Text(
            '点击右上角添加按钮开始添加云盘账号',
            style: CloudDriveUIConfig.smallTextStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建账号卡片
  Widget _buildAccountCard(BuildContext context, CloudDriveAccount account) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
      ),
      child: InkWell(
        onTap: () => onAccountTap(account),
        borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
        child: Padding(
          padding: CloudDriveUIConfig.cardPadding,
          child: Row(
            children: [
              // 账号图标
              Container(
                padding: EdgeInsets.all(CloudDriveUIConfig.spacingS),
                decoration: BoxDecoration(
                  color: account.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    CloudDriveUIConfig.buttonRadius,
                  ),
                ),
                child: Icon(
                  account.type.iconData,
                  color: account.type.color,
                  size: CloudDriveUIConfig.iconSizeL,
                ),
              ),

              SizedBox(width: CloudDriveUIConfig.spacingM),

              // 账号信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: CloudDriveUIConfig.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: CloudDriveUIConfig.spacingXS),
                    Text(
                      account.type.displayName,
                      style: CloudDriveUIConfig.smallTextStyle,
                    ),
                    if (account.lastLoginAt != null) ...[
                      SizedBox(height: CloudDriveUIConfig.spacingXS),
                      Text(
                        '最后登录: ${_formatDateTime(account.lastLoginAt!)}',
                        style: CloudDriveUIConfig.smallTextStyle.copyWith(
                          color: CloudDriveUIConfig.secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 状态指示器
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: CloudDriveUIConfig.spacingS,
                  vertical: CloudDriveUIConfig.spacingXS,
                ),
                decoration: BoxDecoration(
                  color:
                      account.isLoggedIn
                          ? CloudDriveUIConfig.successColor.withOpacity(0.1)
                          : CloudDriveUIConfig.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    CloudDriveUIConfig.buttonRadius,
                  ),
                  border: Border.all(
                    color:
                        account.isLoggedIn
                            ? CloudDriveUIConfig.successColor
                            : CloudDriveUIConfig.warningColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      account.isLoggedIn ? Icons.check_circle : Icons.warning,
                      color:
                          account.isLoggedIn
                              ? CloudDriveUIConfig.successColor
                              : CloudDriveUIConfig.warningColor,
                      size: 16,
                    ),
                    SizedBox(width: CloudDriveUIConfig.spacingXS),
                    Text(
                      account.isLoggedIn ? '已登录' : '未登录',
                      style: CloudDriveUIConfig.smallTextStyle.copyWith(
                        color:
                            account.isLoggedIn
                                ? CloudDriveUIConfig.successColor
                                : CloudDriveUIConfig.warningColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: CloudDriveUIConfig.spacingS),

              // 箭头图标
              Icon(
                Icons.chevron_right,
                color: CloudDriveUIConfig.secondaryTextColor,
                size: CloudDriveUIConfig.iconSizeS,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
