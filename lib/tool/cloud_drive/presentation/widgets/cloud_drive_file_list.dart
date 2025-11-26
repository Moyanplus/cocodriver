import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../data/models/cloud_drive_entities.dart';
import 'cloud_drive_file_item.dart';
import '../state/cloud_drive_state_model.dart';

/// ========================================
/// 云盘文件列表组件
/// ========================================
/// 功能：显示云盘文件和文件夹列表
///
/// 特性：
///   1. 支持下拉刷新
///   2. 支持滚动懒加载（距离底部200px时自动加载更多）
///   3. 支持批量选择模式
///   4. 事件回调由外部注入，组件只关注 UI
///   5. 支持外部传入 ScrollController
///   6. 零 padding 布局，紧贴路径导航器
///
/// 显示内容：
///   - 文件夹（可点击进入）
///   - 文件（点击显示操作选项）
///   - 空状态提示
///   - 加载更多指示器
/// ========================================
class CloudDriveFileList extends StatelessWidget {
  final ScrollController scrollController;
  final CloudDriveState state;
  final CloudDriveAccount account;
  final Future<void> Function() onRefresh;
  final void Function(CloudDriveFile folder) onFolderTap;
  final void Function(CloudDriveFile file) onFileTap;
  final void Function(String itemId) onLongPress;
  final void Function(String itemId) onToggleSelection;

  const CloudDriveFileList({
    super.key,
    required this.scrollController,
    required this.state,
    required this.account,
    required this.onRefresh,
    required this.onFolderTap,
    required this.onFileTap,
    required this.onLongPress,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool showSkeleton = state.isLoading && !state.hasData;
    final bool showEmpty =
        !showSkeleton && state.folders.isEmpty && state.files.isEmpty;

    Widget child;
    if (showSkeleton) {
      child = const _FileListSkeleton();
    } else if (showEmpty) {
      child = const Center(
        child: EmptyStateWidget(
          title: '暂无文件',
          subtitle: '当前文件夹为空',
          icon: Icons.folder_open,
        ),
      );
    } else {
      child = RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          key: ValueKey('${state.currentFolder?.id}_${state.allItems.length}'),
          controller: scrollController,
          padding: EdgeInsets.zero,
          itemCount: state.allItems.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.allItems.length) {
              return Container(
                padding: EdgeInsets.all(16.w),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final item = state.allItems[index];
            final isFolder = state.folders.contains(item);

            return _AnimatedFileEntry(
              key: ValueKey('${state.currentFolder?.id}_${item.id}'),
              position: index,
              child: CloudDriveFileItem(
                file: item,
                account: account,
                isFolder: isFolder,
                isSelected: state.selectedItems.contains(item.id),
                isBatchMode: state.isBatchMode,
                onTap:
                    () => state.isBatchMode
                        ? onToggleSelection(item.id)
                        : isFolder
                            ? onFolderTap(item)
                            : onFileTap(item),
                onLongPress: () => onLongPress(item.id),
              ),
            );
          },
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Container(
        key: ValueKey('$showSkeleton-$showEmpty-${state.currentFolder?.id}'),
        decoration: BoxDecoration(color: theme.colorScheme.surface),
        child: child,
      ),
    );
  }
}

/// 空状态组件
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: ResponsiveUtils.getIconSize(64.sp),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(height: ResponsiveUtils.getSpacing()),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: ResponsiveUtils.getResponsiveFontSize(20.sp),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing() * 0.5),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
          ),
        ),
        if (onAction != null && actionText != null) ...[
          SizedBox(height: ResponsiveUtils.getSpacing() * 1.5),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: Icon(Icons.add, size: ResponsiveUtils.getIconSize(20.sp)),
            label: Text(
              actionText!,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
              ),
            ),
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
          ),
        ],
      ],
    ),
  );
}

class _FileListSkeleton extends StatelessWidget {
  const _FileListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.getSpacing(),
        horizontal: ResponsiveUtils.getSpacing() * 0.5,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: _SkeletonItem(delay: index * 60),
        );
      },
    );
  }
}

class _SkeletonItem extends StatefulWidget {
  const _SkeletonItem({required this.delay});

  final int delay;

  @override
  State<_SkeletonItem> createState() => _SkeletonItemState();
}

class _SkeletonItemState extends State<_SkeletonItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward(from: widget.delay / 1200);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 0.9).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getCardRadius() * 0.6,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            Container(
              width: ResponsiveUtils.getIconSize(20.sp) * 1.6,
              height: ResponsiveUtils.getIconSize(20.sp) * 1.6,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getCardRadius() * 0.5,
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.getSpacing() * 0.5),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 10.h,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedFileEntry extends StatelessWidget {
  const _AnimatedFileEntry({
    super.key,
    required this.child,
    required this.position,
  });

  final Widget child;
  final int position;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 220 + (position % 8) * 30);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * 12),
          child: Opacity(
            opacity: 1 - value * 0.4,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
