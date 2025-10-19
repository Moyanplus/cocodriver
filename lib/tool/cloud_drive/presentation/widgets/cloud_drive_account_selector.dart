import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../providers/cloud_drive_provider.dart';

/// 云盘账号选择器组件
class CloudDriveAccountSelector extends ConsumerWidget {
  final Function(CloudDriveAccount)? onAccountTap;

  const CloudDriveAccountSelector({super.key, this.onAccountTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudDriveProvider);

    // 如果不显示账号选择器，返回空容器
    if (!state.showAccountSelector) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(all: 16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '选择账号',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: ResponsiveUtils.getIconSize(24.sp),
                ),
                onPressed:
                    () =>
                        ref
                            .read(cloudDriveProvider.notifier)
                            .toggleAccountSelector(),
                tooltip: '关闭',
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing()),
          if (state.accounts.isNotEmpty) ...[
            SizedBox(
              height: ResponsiveUtils.getResponsiveHeight(100.h),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.accounts.length,
                itemBuilder: (context, index) {
                  final account = state.accounts[index];
                  final isSelected = index == state.currentAccountIndex;

                  return GestureDetector(
                    onTap:
                        () => ref
                            .read(cloudDriveProvider.notifier)
                            .switchAccount(index),
                    onLongPress:
                        onAccountTap != null
                            ? () => onAccountTap!(account)
                            : null,
                    child: Container(
                      width: ResponsiveUtils.getResponsiveWidth(220.w),
                      margin: EdgeInsets.only(
                        right: ResponsiveUtils.getSpacing(),
                      ),
                      padding: ResponsiveUtils.getResponsivePadding(all: 10.w),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getCardRadius(),
                        ),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.3),
                          width: isSelected ? 2.w : 1.w,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              // 显示用户头像或云盘图标
                              _buildAccountIcon(context, account),
                              SizedBox(
                                width: ResponsiveUtils.getSpacing() * 0.5,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      account.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            ResponsiveUtils.getResponsiveFontSize(
                                              12.sp,
                                            ),
                                        color:
                                            isSelected
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimaryContainer
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      account.type.displayName,
                                      style: TextStyle(
                                        fontSize:
                                            ResponsiveUtils.getResponsiveFontSize(
                                              10.sp,
                                            ),
                                        color:
                                            isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer
                                                    .withOpacity(0.7)
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.getSpacing() * 0.25),
                          Text(
                            account.isLoggedIn ? '已登录' : '未登录',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                10.sp,
                              ),
                              fontWeight: FontWeight.w500,
                              color:
                                  account.isLoggedIn
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.orange,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建账号图标
  Widget _buildAccountIcon(BuildContext context, CloudDriveAccount account) {
    if (account.avatarUrl != null && account.avatarUrl!.isNotEmpty) {
      // 如果有头像，显示头像并在右下角添加云盘类型小图标
      return Stack(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(account.avatarUrl!),
            radius: ResponsiveUtils.getIconSize(14.sp),
            backgroundColor: account.type.color.withOpacity(0.1),
          ),
          // 云盘类型小图标徽章
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: ResponsiveUtils.getIconSize(10.sp),
              height: ResponsiveUtils.getIconSize(10.sp),
              decoration: BoxDecoration(
                color: account.type.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1,
                ),
              ),
              child: Icon(
                account.type.iconData,
                color: Colors.white,
                size: ResponsiveUtils.getIconSize(8.sp),
              ),
            ),
          ),
        ],
      );
    }

    // 没有头像时只显示云盘类型图标
    return Icon(
      account.type.iconData,
      color: account.type.color,
      size: ResponsiveUtils.getIconSize(24.sp),
    );
  }
}
