import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_utils.dart';
import '../presentation/providers/cloud_drive_provider.dart';

/// 云盘文件统计信息组件
class CloudDriveFileStatistics extends ConsumerWidget {
  const CloudDriveFileStatistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudDriveProvider);

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: ResponsiveUtils.getIconSize(16.sp),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: ResponsiveUtils.getSpacing() * 0.67),
          Text(
            '共 ${state.folders.length} 个文件夹，${state.files.length} 个文件',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(12.sp),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
