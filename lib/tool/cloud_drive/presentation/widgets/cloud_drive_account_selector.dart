import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../providers/cloud_drive_provider.dart';
import 'account/account_detail_bottom_sheet.dart';

/// 云盘账号选择器组件
///
/// 该组件用于显示和管理云盘账号列表，提供以下功能：
/// 1. 以水平滚动列表形式展示所有已添加的云盘账号
/// 2. 支持账号切换功能，点击账号卡片可切换当前活动账号
/// 3. 显示账号的基本信息：头像/图标、名称、云盘类型、登录状态
/// 4. 提供账号详情查看功能，点击信息图标可打开账号详情底部弹窗
/// 5. 支持长按账号卡片触发自定义操作（通过 onAccountTap 回调）
///
/// 调用关系：
/// - 被 CloudDrivePage 页面调用，作为云盘主界面的顶部账号选择区域
/// - 使用 CloudDriveProvider 管理账号状态和切换逻辑
/// - 调用 CloudInfoCard 组件显示账号详细信息
///
/// 示例：
/// ```dart
/// CloudDriveAccountSelector(
///   onAccountTap: (account) {
///     // 处理账号长按事件
///   },
/// )
/// ```
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
      // 【优化】减小 padding，从 16.w 改为 12.w，让布局更紧凑
      padding: ResponsiveUtils.getResponsivePadding(
        horizontal: 12.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.accounts.isNotEmpty) ...[
            SizedBox(
              // 【优化】减小高度，从 100.h 改为 85.h，让账号卡片更紧凑
              height: ResponsiveUtils.getResponsiveHeight(85.h),
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
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
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .onPrimaryContainer
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
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.info_outline,
                                        size: ResponsiveUtils.getIconSize(
                                          16.sp,
                                        ),
                                        color:
                                            isSelected
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimaryContainer
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        // 显示账号详情底部弹窗
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder:
                                              (
                                                context,
                                              ) => DraggableScrollableSheet(
                                                initialChildSize: 0.7,
                                                minChildSize: 0.5,
                                                maxChildSize: 0.95,
                                                builder:
                                                    (
                                                      context,
                                                      scrollController,
                                                    ) =>
                                                        AccountDetailBottomSheet(
                                                          account: account,
                                                        ),
                                              ),
                                        );
                                      },
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
          ] else ...[
            // 无账号提示
            SizedBox(
              // 【优化】与有账号时的高度保持一致
              height: ResponsiveUtils.getResponsiveHeight(85.h),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      size: ResponsiveUtils.getIconSize(32.sp),
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '暂无云盘账号',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(12.sp),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建账号图标
  ///
  /// 根据账号信息构建显示头像或云盘类型图标：
  /// 1. 如果账号有头像URL（[account.avatarUrl]不为空），则：
  ///    - 显示圆形头像
  ///    - 在右下角添加云盘类型的小图标徽章
  ///    - 徽章使用云盘对应的颜色和图标
  /// 2. 如果账号没有头像，则：
  ///    - 只显示对应云盘类型的图标
  ///    - 使用云盘对应的颜色
  ///
  /// 参数：
  /// - [context]: 构建上下文，用于获取主题数据
  /// - [account]: 云盘账号信息，包含头像URL、云盘类型等数据
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
