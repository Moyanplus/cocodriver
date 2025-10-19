import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_utils.dart';
import '../models/cloud_drive_models.dart';
import '../providers/cloud_drive_provider.dart';
import '../providers/cloud_drive_main_provider.dart';
import '../widgets/cloud_drive_account_selector.dart';
import '../widgets/cloud_drive_path_navigator.dart';
import '../widgets/cloud_drive_file_statistics.dart';
import '../widgets/cloud_drive_batch_action_bar.dart';
import '../widgets/cloud_drive_file_list.dart';

/// 云盘文件列表组件
class CloudDriveWidget extends ConsumerStatefulWidget {
  final VoidCallback? onAddAccount;
  final Function(CloudDriveAccount)? onAccountTap;

  const CloudDriveWidget({super.key, this.onAddAccount, this.onAccountTap});

  @override
  ConsumerState<CloudDriveWidget> createState() => _CloudDriveWidgetState();
}

class _CloudDriveWidgetState extends ConsumerState<CloudDriveWidget> {
  @override
  void initState() {
    super.initState();
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cloudDriveMainProvider.notifier).loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cloudDriveProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // 账号选择器
          CloudDriveAccountSelector(onAccountTap: widget.onAccountTap),

          // 路径导航栏
          const CloudDrivePathNavigator(),

          // 文件统计信息
          const CloudDriveFileStatistics(),

          // 批量操作栏
          const CloudDriveBatchActionBar(),

          // 加载状态
          if (state.isLoading) _buildLoadingIndicator(),

          // 错误状态
          if (state.error != null) _buildErrorWidget(state.error!),

          // 文件列表
          const Expanded(child: CloudDriveFileList()),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() => Container(
    padding: ResponsiveUtils.getResponsivePadding(all: 16.w),
    child: Center(
      child: CircularProgressIndicator(
        strokeWidth: ResponsiveUtils.isMobile ? 2.0 : 3.0,
      ),
    ),
  );

  Widget _buildErrorWidget(String error) => Container(
    padding: ResponsiveUtils.getResponsivePadding(all: 16.w),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveUtils.getIconSize(48.sp),
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: ResponsiveUtils.getSpacing()),
          Text(
            '加载失败',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: ResponsiveUtils.getResponsiveFontSize(18.sp),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing() * 0.5),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getSpacing()),
          ElevatedButton(
            onPressed:
                () => ref
                    .read(cloudDriveProvider.notifier)
                    .loadCurrentFolder(forceRefresh: true),
            style: ElevatedButton.styleFrom(
              padding: ResponsiveUtils.getResponsivePadding(
                horizontal: 24.w,
                vertical: 12.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getCardRadius(),
                ),
              ),
            ),
            child: Text(
              '重试',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
