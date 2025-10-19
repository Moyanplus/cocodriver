import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../providers/cloud_drive_provider.dart';

/// 云盘路径导航器组件
class CloudDrivePathNavigator extends ConsumerWidget {
  const CloudDrivePathNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudDriveProvider);

    // 如果路径为空，不显示导航器
    if (state.folderPath.isEmpty) {
      return const SizedBox.shrink();
    }

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
            Icons.folder,
            size: ResponsiveUtils.getIconSize(16.sp),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: ResponsiveUtils.getSpacing() * 0.67),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // 根目录
                  GestureDetector(
                    onTap: () => ref.read(cloudDriveProvider.notifier).goBack(),
                    child: Container(
                      padding: ResponsiveUtils.getResponsivePadding(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getCardRadius(),
                        ),
                      ),
                      child: Text(
                        '返回上级',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            12.sp,
                          ),
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  // 路径分隔符和文件夹
                  ...state.folderPath.asMap().entries.map((entry) {
                    final pathInfo = entry.value;

                    return Row(
                      children: [
                        SizedBox(width: ResponsiveUtils.getSpacing() * 0.67),
                        Icon(
                          Icons.chevron_right,
                          size: ResponsiveUtils.getIconSize(16.sp),
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: ResponsiveUtils.getSpacing() * 0.67),
                        GestureDetector(
                          onTap:
                              () => ref
                                  .read(cloudDriveProvider.notifier)
                                  .enterFolder(
                                    CloudDriveFile(
                                      id: pathInfo.id,
                                      name: pathInfo.name,
                                      isFolder: true,
                                    ),
                                  ),
                          child: Container(
                            padding: ResponsiveUtils.getResponsivePadding(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.getCardRadius(),
                              ),
                            ),
                            child: Text(
                              pathInfo.name,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  12.sp,
                                ),
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
