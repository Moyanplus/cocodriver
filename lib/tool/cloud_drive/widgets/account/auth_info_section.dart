import 'package:flutter/material.dart';
import '../../config/cloud_drive_ui_config.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../common/cloud_drive_common_widgets.dart';

/// 认证信息组件
class AuthInfoSection extends StatelessWidget {
  final CloudDriveAccount account;
  final VoidCallback? onCopy;
  final VoidCallback? onView;

  const AuthInfoSection({
    super.key,
    required this.account,
    this.onCopy,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    if (!account.isLoggedIn) {
      return const SizedBox.shrink();
    }

    return CloudDriveCommonWidgets.buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('认证信息', style: CloudDriveUIConfig.titleTextStyle),
          SizedBox(height: CloudDriveUIConfig.spacingM),

          _buildAuthInfoRow(context, account),
        ],
      ),
    );
  }

  /// 构建认证信息行
  Widget _buildAuthInfoRow(BuildContext context, CloudDriveAccount account) {
    String paramInfo = '';
    String paramValue = '';

    switch (account.type.authType) {
      case AuthType.cookie:
        if (account.cookies != null) {
          paramInfo = 'Cookie';
          final cookieStr = account.cookies!;
          // 显示前50个字符，避免过长
          paramValue =
              cookieStr.length > 50
                  ? '${cookieStr.substring(0, 50)}...'
                  : cookieStr;
        }
        break;
      case AuthType.authorization:
        if (account.authorizationToken != null) {
          paramInfo = 'Token';
          final tokenStr = account.authorizationToken!;
          // 显示前30个字符，避免过长
          paramValue =
              tokenStr.length > 30
                  ? '${tokenStr.substring(0, 30)}...'
                  : tokenStr;
        }
        break;
      case AuthType.qrCode:
        paramInfo = '二维码';
        paramValue = account.qrCodeToken ?? '未知';
        break;
    }

    if (paramInfo.isEmpty || paramValue.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        CloudDriveCommonWidgets.buildClickableInfoRow(
          label: paramInfo,
          value: paramValue,
          onTap: onView,
        ),

        SizedBox(height: CloudDriveUIConfig.spacingS),

        // 操作按钮
        Row(
          children: [
            CloudDriveCommonWidgets.buildSecondaryButton(
              text: '查看完整信息',
              onPressed: onView ?? () {},
              icon: const Icon(Icons.visibility),
            ),

            SizedBox(width: CloudDriveUIConfig.spacingS),

            CloudDriveCommonWidgets.buildSecondaryButton(
              text: '复制',
              onPressed: onCopy ?? () {},
              icon: const Icon(Icons.copy),
            ),
          ],
        ),
      ],
    );
  }
}

/// 可点击的信息行组件
class ClickableInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ClickableInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
      child: Container(
        padding: CloudDriveUIConfig.cardPadding,
        decoration: BoxDecoration(
          border: Border.all(
            color: CloudDriveUIConfig.dividerColor.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: CloudDriveUIConfig.bodyTextStyle.copyWith(
                  color: CloudDriveUIConfig.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: CloudDriveUIConfig.bodyTextStyle.copyWith(
                  color: CloudDriveUIConfig.textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: CloudDriveUIConfig.spacingS),
              trailing!,
            ],
            if (onTap != null) ...[
              SizedBox(width: CloudDriveUIConfig.spacingS),
              Icon(
                Icons.chevron_right,
                color: CloudDriveUIConfig.secondaryTextColor,
                size: CloudDriveUIConfig.iconSizeS,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
