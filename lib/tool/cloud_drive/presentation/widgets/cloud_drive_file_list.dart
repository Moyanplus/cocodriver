import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../providers/cloud_drive_provider.dart';
import 'sheets/file_operation_bottom_sheet.dart';
import 'cloud_drive_file_item.dart';

/// ========================================
/// 云盘文件列表组件
/// ========================================
/// 功能：显示云盘文件和文件夹列表
///
/// 特性：
///   1. 支持下拉刷新
///   2. 支持滚动懒加载（距离底部200px时自动加载更多）
///   3. 支持批量选择模式
///   4. 支持外部传入 ScrollController
///   5. 零 padding 布局，紧贴路径导航器
///
/// 显示内容：
///   - 文件夹（可点击进入）
///   - 文件（点击显示操作选项）
///   - 空状态提示
///   - 加载更多指示器
/// ========================================
class CloudDriveFileList extends ConsumerStatefulWidget {
  final ScrollController? scrollController;

  const CloudDriveFileList({super.key, this.scrollController});

  @override
  ConsumerState<CloudDriveFileList> createState() => _CloudDriveFileListState();
}

class _CloudDriveFileListState extends ConsumerState<CloudDriveFileList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // 使用外部传入的 ScrollController，如果没有则创建新的
    _scrollController = widget.scrollController ?? ScrollController();
    // 监听滚动事件，实现懒加载
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // 只有当 ScrollController 是内部创建的时候才dispose
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 距离底部200px时开始加载更多
      ref.read(cloudDriveProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cloudDriveProvider);

    if (state.folders.isEmpty && state.files.isEmpty && !state.isLoading) {
      return const Center(
        child: EmptyStateWidget(
          title: '暂无文件',
          subtitle: '当前文件夹为空',
          icon: Icons.folder_open,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(cloudDriveProvider.notifier)
              .loadFolder(forceRefresh: true);
        },
        child: ListView.builder(
          controller: _scrollController,
          // 【重要】移除 ListView 默认的顶部和底部 padding，让列表紧贴路径导航器
          padding: EdgeInsets.zero,
          itemCount: state.allItems.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.allItems.length) {
              // 加载更多指示器
              return Container(
                padding: EdgeInsets.all(16.w),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final item = state.allItems[index];
            final isFolder = state.folders.contains(item);

            return CloudDriveFileItem(
              file: item,
              account: state.currentAccount!,
              isFolder: isFolder,
              isSelected: state.selectedItems.contains(item.id),
              isBatchMode: state.isBatchMode,
              onTap: () => _handleItemTap(item, isFolder, state),
              onLongPress: () => _handleItemLongPress(item.id),
            );
          },
        ),
      ),
    );
  }

  void _handleItemTap(CloudDriveFile item, bool isFolder, dynamic state) {
    if (state.isBatchMode) {
      ref.read(cloudDriveProvider.notifier).toggleSelection(item.id);
    } else if (isFolder) {
      ref.read(cloudDriveProvider.notifier).enterFolder(item);
    } else {
      _showFileOptions(context, item, state.currentAccount);
    }
  }

  void _handleItemLongPress(String itemId) {
    ref.read(cloudDriveProvider.notifier).enterBatchMode(itemId);
  }

  // 显示文件操作选项
  void _showFileOptions(
    BuildContext context,
    CloudDriveFile file,
    CloudDriveAccount? account,
  ) {
    if (account == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('账号信息不可用')));
      return;
    }

    // 保存父组件的context引用
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder:
                (context, scrollController) => FileOperationBottomSheet(
                  file: file,
                  account: account,
                  onClose: () => Navigator.pop(context),
                  onOperationResult: (message, isSuccess) {
                    // 使用父组件的context显示SnackBar
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: isSuccess ? Colors.green : Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                ),
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
