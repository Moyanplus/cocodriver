import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../providers/cloud_drive_provider.dart';

/// 云盘批量操作栏组件
class CloudDriveBatchActionBar extends ConsumerWidget {
  const CloudDriveBatchActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudDriveProvider);

    // 如果不是批量模式，不显示操作栏
    if (!state.isBatchMode) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(
        horizontal: 16.w,
        vertical: 0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed:
                () => ref.read(cloudDriveProvider.notifier).toggleSelectAll(),
            icon: Icon(
              state.isAllSelected
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              size: ResponsiveUtils.getIconSize(20.sp),
            ),
            label: Text(
              state.isAllSelected ? '取消全选' : '全选',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              padding: ResponsiveUtils.getResponsivePadding(
                horizontal: 8.w,
                vertical: 4.h,
              ),
            ),
          ),
          const Spacer(),
          if (state.selectedItems.isNotEmpty) ...[
            TextButton.icon(
              onPressed:
                  () => ref.read(cloudDriveProvider.notifier).batchDownload(),
              icon: Icon(
                Icons.download,
                size: ResponsiveUtils.getIconSize(20.sp),
              ),
              label: Text(
                '下载',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
                padding: ResponsiveUtils.getResponsivePadding(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.getSpacing() * 0.67),
            TextButton.icon(
              onPressed:
                  () => ref.read(cloudDriveProvider.notifier).batchShare(),
              icon: Icon(Icons.share, size: ResponsiveUtils.getIconSize(20.sp)),
              label: Text(
                '分享',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
                padding: ResponsiveUtils.getResponsivePadding(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
