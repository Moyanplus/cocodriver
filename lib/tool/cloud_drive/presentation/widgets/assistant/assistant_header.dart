import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../providers/cloud_drive_provider.dart';

/// 助手页面头部组件
class AssistantHeader extends ConsumerWidget {
  final VoidCallback onAddAccount;

  const AssistantHeader({super.key, required this.onAddAccount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudDriveProvider);
    final currentAccount = state.currentAccount;

    return Container(
      padding: CloudDriveUIConfig.pagePadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CloudDriveUIConfig.primaryActionColor,
            CloudDriveUIConfig.primaryActionColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和添加按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '云盘助手',
                    style: CloudDriveUIConfig.titleTextStyle.copyWith(
                      color: Colors.white,
                      fontSize: CloudDriveUIConfig.fontSizeXXL,
                    ),
                  ),
                  Text(
                    '管理您的云盘账号',
                    style: CloudDriveUIConfig.smallTextStyle.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onAddAccount,
                icon: const Icon(Icons.add, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),

          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 当前账号信息
          if (currentAccount != null) ...[
            Container(
              padding: CloudDriveUIConfig.cardPadding,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  CloudDriveUIConfig.cardRadius,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    currentAccount.type.iconData,
                    color: Colors.white,
                    size: CloudDriveUIConfig.iconSizeL,
                  ),
                  SizedBox(width: CloudDriveUIConfig.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentAccount.name,
                          style: CloudDriveUIConfig.bodyTextStyle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentAccount.type.displayName,
                          style: CloudDriveUIConfig.smallTextStyle.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: CloudDriveUIConfig.spacingS,
                      vertical: CloudDriveUIConfig.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color:
                          currentAccount.isLoggedIn
                              ? CloudDriveUIConfig.successColor
                              : CloudDriveUIConfig.warningColor,
                      borderRadius: BorderRadius.circular(
                        CloudDriveUIConfig.buttonRadius,
                      ),
                    ),
                    child: Text(
                      currentAccount.isLoggedIn ? '已登录' : '未登录',
                      style: CloudDriveUIConfig.smallTextStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: CloudDriveUIConfig.cardPadding,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  CloudDriveUIConfig.cardRadius,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_off,
                    color: Colors.white.withOpacity(0.6),
                    size: CloudDriveUIConfig.iconSizeL,
                  ),
                  SizedBox(width: CloudDriveUIConfig.spacingM),
                  Expanded(
                    child: Text(
                      '暂无云盘账号',
                      style: CloudDriveUIConfig.bodyTextStyle.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
