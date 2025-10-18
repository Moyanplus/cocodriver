import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../components/cloud_drive_base_widgets.dart';
import '../components/cloud_drive_file_item.dart';
import '../models/cloud_drive_models.dart';
import '../providers/cloud_drive_provider.dart';
import '../providers/cloud_drive_main_provider.dart';
import 'cloud_drive_operation_options.dart';

/// 云盘文件列表组件
class CloudDriveWidget extends ConsumerStatefulWidget {
  final VoidCallback? onAddAccount;
  final Function(CloudDriveAccount)? onAccountTap;

  const CloudDriveWidget({super.key, this.onAddAccount, this.onAccountTap});

  @override
  ConsumerState<CloudDriveWidget> createState() => _CloudDriveWidgetState();
}

class _CloudDriveWidgetState extends ConsumerState<CloudDriveWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cloudDriveMainProvider.notifier).loadAccounts();
    });

    // 监听滚动事件，实现懒加载
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 距离底部200px时开始加载更多
      ref.read(cloudDriveProvider.notifier).loadMore();
    }
  }

  /// 获取文件类型图标
  IconData fileTypeIconProvider(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// 获取文件类型颜色
  Color fileTypeColorProvider(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Colors.indigo;
      case 'mp3':
      case 'wav':
        return Colors.teal;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cloudDriveProvider);

    return Column(
      children: [
        // 账号选择器
        _buildAccountSelector(state),

        // 路径导航栏
        if (state.folderPath.isNotEmpty) _buildPathNavigator(state),

        // 文件统计信息
        _buildFileStatistics(state),

        // 批量操作栏
        if (state.isBatchMode) _buildBatchActionBar(state),

        // 加载状态
        if (state.isLoading) _buildLoadingIndicator(),

        // 错误状态
        if (state.error != null) _buildErrorWidget(state.error!),

        // 文件列表
        Expanded(child: _buildFileList(state)),
      ],
    );
  }

  Widget _buildAccountSelector(CloudDriveState state) {
    // 如果不显示账号选择器，返回空容器
    if (!state.showAccountSelector) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
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
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed:
                    () =>
                        ref
                            .read(cloudDriveProvider.notifier)
                            .toggleAccountSelector(),
                tooltip: '关闭',
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (state.accounts.isNotEmpty) ...[
            SizedBox(
              height: 80.h,
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
                        widget.onAccountTap != null
                            ? () => widget.onAccountTap!(account)
                            : null,
                    child: Container(
                      width: 200.w,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
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
                        children: [
                          Row(
                            children: [
                              // 显示用户头像或云盘图标
                              _buildAccountIcon(context, account),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      account.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
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
                                    ),
                                    Text(
                                      account.type.displayName,
                                      style: TextStyle(
                                        fontSize: 11.sp,
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
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            account.isLoggedIn ? '已登录' : '未登录',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color:
                                  account.isLoggedIn
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.orange,
                            ),
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

  Widget _buildPathNavigator(CloudDriveState state) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
          size: 16.sp,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 根目录
                GestureDetector(
                  onTap: () => ref.read(cloudDriveProvider.notifier).goBack(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '返回上级',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                // 路径分隔符和文件夹
                ...state.folderPath.asMap().entries.map((entry) {
                  final index = entry.key;
                  final pathInfo = entry.value;
                  final account = state.currentAccount;

                  return Row(
                    children: [
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.chevron_right,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 8.w),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            pathInfo.name, // 直接使用PathInfo中的名称
                            style: TextStyle(
                              fontSize: 12.sp,
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

  Widget _buildFileStatistics(CloudDriveState state) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
          size: 16.sp,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 8.w),
        Text(
          '共 ${state.folders.length} 个文件夹，${state.files.length} 个文件',
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );

  Widget _buildBatchActionBar(CloudDriveState state) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
          ),
          label: Text(state.isAllSelected ? '取消全选' : '全选'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const Spacer(),
        if (state.selectedItems.isNotEmpty) ...[
          TextButton.icon(
            onPressed:
                () => ref.read(cloudDriveProvider.notifier).batchDownload(),
            icon: const Icon(Icons.download),
            label: const Text('下载'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => ref.read(cloudDriveProvider.notifier).batchShare(),
            icon: const Icon(Icons.share),
            label: const Text('分享'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ],
    ),
  );

  Widget _buildLoadingIndicator() => Container(
    padding: const EdgeInsets.all(16),
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _buildErrorWidget(String error) => Container(
    padding: const EdgeInsets.all(16),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text('加载失败', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                () => ref
                    .read(cloudDriveProvider.notifier)
                    .loadCurrentFolder(forceRefresh: true),
            child: const Text('重试'),
          ),
        ],
      ),
    ),
  );

  Widget _buildFileList(CloudDriveState state) {
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
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(cloudDriveProvider.notifier)
              .loadCurrentFolder(forceRefresh: true);
        },
        child: ListView.builder(
          controller: _scrollController,
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

            return _buildFileItem(item, isFolder, state);
          },
        ),
      ),
    );
  }

  Widget _buildFileItem(
    CloudDriveFile item,
    bool isFolder,
    CloudDriveState state,
  ) {
    final isSelected = state.selectedItems.contains(item.id);

    return GestureDetector(
      onTap:
          state.isBatchMode
              ? () =>
                  ref.read(cloudDriveProvider.notifier).toggleSelection(item.id)
              : isFolder
              ? () => ref.read(cloudDriveProvider.notifier).enterFolder(item)
              : () => _showFileOptions(
                context,
                item,
                state.currentAccount,
              ), // 添加文件点击处理
      onLongPress:
          () => ref.read(cloudDriveProvider.notifier).enterBatchMode(item.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shadowColor: Colors.transparent,
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
            side:
                state.isBatchMode && isSelected
                    ? BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.w,
                    )
                    : BorderSide.none,
          ),
          child: Container(
            height: 70.h, // 增加高度以避免溢出
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Row(
              children: [
                // 文件/文件夹图标
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color:
                        isFolder
                            ? Colors.orange.withValues(alpha: 0.1)
                            : fileTypeColorProvider(
                              item.name,
                            ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Icon(
                    isFolder ? Icons.folder : fileTypeIconProvider(item.name),
                    color:
                        isFolder
                            ? Colors.orange
                            : fileTypeColorProvider(item.name),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                // 文本内容
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h), // 增加间距
                      // 显示文件大小和修改时间
                      Text(
                        item.isFolder
                            ? (item.modifiedTime?.toString() ??
                                '') // 文件夹：如果没有时间就不显示
                            : _buildFileInfoText(item), // 文件：构建信息文本
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建文件信息文本
  String _buildFileInfoText(CloudDriveFile item) {
    final parts = <String>[];

    // 添加时间信息（如果有）
    if (item.modifiedTime != null) {
      parts.add(CloudDriveBaseWidgets.formatTime(item.modifiedTime));
    }

    // 添加大小信息（如果有）
    if (item.size != null && item.size! > 0) {
      parts.add(CloudDriveBaseWidgets.formatFileSize(item.size!));
    }

    // 如果没有任何信息，返回空字符串
    if (parts.isEmpty) {
      return '';
    }

    // 用 • 连接多个信息
    return parts.join(' • ');
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder:
          (context) => CloudDriveOperationOptions(
            file: file,
            account: account,
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
    );
  }

  // 构建账号图标
  Widget _buildAccountIcon(BuildContext context, CloudDriveAccount account) {
    if (account.avatarUrl != null && account.avatarUrl!.isNotEmpty) {
      // 如果有头像，显示头像并在右下角添加云盘类型小图标
      return Stack(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(account.avatarUrl!),
            radius: 16.r,
            backgroundColor: account.type.color.withOpacity(0.1),
          ),
          // 云盘类型小图标徽章
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12.r,
              height: 12.r,
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
                size: 8.sp,
              ),
            ),
          ),
        ],
      );
    }

    // 没有头像时只显示云盘类型图标
    return Icon(account.type.iconData, color: account.type.color, size: 24.sp);
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
          size: 64,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (onAction != null && actionText != null) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionText!),
          ),
        ],
      ],
    ),
  );
}
