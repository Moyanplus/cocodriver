import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../utils/file_type_utils.dart';
import 'cloud_drive_file_item.dart';
import '../../state/cloud_drive_state_model.dart';
import '../common/authenticated_network_image.dart';
import '../common/file_time_formatter.dart';

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
    // 当首次进入或刷新时会短暂展示骨架屏，避免空白闪烁
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
        child:
            state.viewMode == CloudDriveViewMode.grid
                ? _buildGridView(context)
                : _buildListView(context),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Container(
        // key 中带上 folderId，切换文件夹时能触发 AnimatedSwitcher 动画
        key: ValueKey('$showSkeleton-$showEmpty-${state.currentFolder?.id}'),
        decoration: BoxDecoration(color: theme.colorScheme.surface),
        child: child,
      ),
    );
  }

  /// 经典列表视图
  Widget _buildListView(BuildContext context) {
    if (_shouldUseIndexedList) {
      return _buildIndexedListView(context);
    }

    final items = state.allItems;
    final totalCount = items.length + (state.isLoadingMore ? 1 : 0);
    return ListView.builder(
      key: PageStorageKey<String>(
        'cloud_drive_list_${state.currentAccount?.id ?? 'no_account'}_${state.currentFolder?.id ?? 'root'}',
      ),
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final item = items[index];
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
                () =>
                    state.isBatchMode
                        ? onToggleSelection(item.id)
                        : isFolder
                        ? onFolderTap(item)
                        : onFileTap(item),
            onLongPress: () => onLongPress(item.id),
          ),
        );
      },
    );
  }

  /// 图标视图：按当前宽度自适应列数，便于在不同屏幕一次展示更多文件
  Widget _buildGridView(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final width =
              constraints.maxWidth == double.infinity
                  ? MediaQuery.of(context).size.width
                  : constraints.maxWidth;
          // 根据容器宽度动态计算列数，保证小屏也至少两列，大屏可展示更多
          var crossAxisCount = (width / 120).floor();
          if (crossAxisCount < 2) crossAxisCount = 2;
          if (crossAxisCount > 6) crossAxisCount = 6;
          final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 6.w,
            mainAxisSpacing: 6.w,
            childAspectRatio: 1,
          );

          final items = state.allItems;
          final totalCount = items.length + (state.isLoadingMore ? 1 : 0);
          return GridView.builder(
            key: PageStorageKey<String>(
              'cloud_drive_grid_${state.currentAccount?.id ?? 'no_account'}_${state.currentFolder?.id ?? 'root'}',
            ),
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
            gridDelegate: gridDelegate,
            itemCount: totalCount,
            itemBuilder: (context, index) {
              if (index >= items.length) {
                return Padding(
                  padding: EdgeInsets.all(16.w),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              return _buildGridTile(items[index]);
            },
          );
        },
      );

  Widget _buildGridTile(CloudDriveFile item) {
    final isFolder = state.folders.contains(item);
    final isSelected = state.selectedItems.contains(item.id);
    return _GridFileTile(
      account: account,
      file: item,
      isFolder: isFolder,
      isSelected: isSelected,
      isBatchMode: state.isBatchMode,
      onTap:
          () => state.isBatchMode
              ? onToggleSelection(item.id)
              : isFolder
                  ? onFolderTap(item)
                  : onFileTap(item),
      onLongPress: () => onLongPress(item.id),
    );
  }

  bool get _shouldUseIndexedList {
    if (state.viewMode != CloudDriveViewMode.list) return false;
    final supportsIndex =
        state.sortField == CloudDriveSortField.name ||
        state.sortField == CloudDriveSortField.createdTime ||
        state.sortField == CloudDriveSortField.modifiedTime;
    return supportsIndex && state.allItems.length >= 10;
  }

  Widget _buildIndexedListView(BuildContext context) {
    final entries = _buildIndexedEntries();
    final theme = Theme.of(context);
    final indexData = _buildIndexBarData(entries);
    final baseStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant,
    );

    return AzListView(
      data: entries,
      padding: EdgeInsets.zero,
      indexHintBuilder:
          (context, hint) => Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              hint,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
      indexBarData: indexData,
      indexBarMargin: EdgeInsets.only(right: 6.w),
      indexBarOptions: IndexBarOptions(
        needRebuild: true,
        decoration: const BoxDecoration(color: Colors.transparent),
        textStyle: baseStyle,
        downTextStyle: baseStyle.copyWith(
          color: theme.colorScheme.primary,
        ),
        selectTextStyle: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        selectItemDecoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.85),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      susItemBuilder: null,
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        if (entry.isLoader) {
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final file = entry.file!;
        final isFolder = state.folders.contains(file);
        return _AnimatedFileEntry(
          key: ValueKey('indexed_${state.currentFolder?.id}_${file.id}'),
          position: index,
          child: CloudDriveFileItem(
            file: file,
            account: account,
            isFolder: isFolder,
            isSelected: state.selectedItems.contains(file.id),
            isBatchMode: state.isBatchMode,
            onTap:
                () =>
                    state.isBatchMode
                        ? onToggleSelection(file.id)
                        : isFolder
                        ? onFolderTap(file)
                        : onFileTap(file),
            onLongPress: () => onLongPress(file.id),
          ),
        );
      },
    );
  }

  List<_IndexedEntry> _buildIndexedEntries() {
    final entries = <_IndexedEntry>[];
    for (final file in state.allItems) {
      final tag = _deriveIndexTag(file);
      entries.add(_IndexedEntry(file: file, tag: tag));
    }

    if (state.isLoadingMore) {
      entries.add(_IndexedEntry.loader());
    }

    return entries;
  }

  String _deriveIndexTag(CloudDriveFile file) {
    if (file.isFolder) return '@';
    if (state.sortField == CloudDriveSortField.name) {
      final name = file.name;
      if (name.isEmpty) return '#';
      final first = name.characters.first.toUpperCase();
      final code = first.codeUnitAt(0);
      final isLetter = code >= 65 && code <= 90;
      return isLetter ? first : '#';
    }

    final time = _resolveTimeForIndex(file);
    if (time == null) return '#';
    return '${time.month}月';
  }

  List<String> _buildIndexBarData(List<_IndexedEntry> entries) {
    final tags = <String>[];
    final seen = <String>{};
    for (final entry in entries) {
      if (entry.isLoader || entry.isFolder) continue;
      final tag = entry.tag;
      if (seen.add(tag)) {
        tags.add(tag);
      }
    }
    return tags.isEmpty ? ['#'] : tags;
  }

  DateTime? _resolveTimeForIndex(CloudDriveFile file) {
    const createdKeys = ['createdTime', 'createTime', 'created_at', 'createdAt', 'ctime'];
    const modifiedKeys = ['modifiedTime', 'updateTime', 'updated_at', 'updatedAt', 'mtime'];

    switch (state.sortField) {
      case CloudDriveSortField.createdTime:
        return _extractTimeFromMetadata(file, createdKeys) ??
            file.modifiedTime ??
            _extractTimeFromMetadata(file, modifiedKeys);
      case CloudDriveSortField.modifiedTime:
        return file.modifiedTime ??
            _extractTimeFromMetadata(file, modifiedKeys) ??
            _extractTimeFromMetadata(file, createdKeys);
      default:
        return null;
    }
  }

  DateTime? _extractTimeFromMetadata(
    CloudDriveFile file,
    List<String> keys,
  ) {
    final meta = file.metadata;
    if (meta == null) return null;
    for (final key in keys) {
      if (!meta.containsKey(key)) continue;
      final value = meta[key];
      final parsed = _parseDateTimeValue(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  DateTime? _parseDateTimeValue(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      final millis = value > 1000000000000 ? value : value * 1000;
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) return parsed;
      final secs = int.tryParse(trimmed);
      if (secs != null) {
        final millis = trimmed.length > 11 ? secs : secs * 1000;
        return DateTime.fromMillisecondsSinceEpoch(millis);
      }
    }
    return null;
  }
}

/// 网格模式下的单个文件卡片，负责展示图标 / 名称 / 大小 / 时间等信息
class _GridFileTile extends StatelessWidget {
  const _GridFileTile({
    required this.account,
    required this.file,
    required this.isFolder,
    required this.isSelected,
    required this.isBatchMode,
    required this.onTap,
    required this.onLongPress,
  });

  final CloudDriveAccount account;
  final CloudDriveFile file;
  final bool isFolder;
  final bool isSelected;
  final bool isBatchMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor =
        isFolder ? Colors.orange : FileTypeUtils.getFileTypeColor(file.name);
    final typeIcon =
        isFolder
            ? Icons.folder_rounded
            : FileTypeUtils.getFileTypeIcon(file.name);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color:
              isSelected
                  ? theme.colorScheme.primaryContainer.withOpacity(0.4)
                  : theme.colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              // 批量模式下显示选中图标，非批量模式则留空保持布局一致
              child:
                  isBatchMode
                      ? Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color:
                            isSelected
                                ? typeColor
                                : theme.colorScheme.onSurfaceVariant,
                      )
                      : SizedBox(height: 2),
            ),
            _buildThumbOrIcon(typeColor, typeIcon),

            // SizedBox(height: 6.h),
            Text(
              file.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CloudDriveUIConfig.bodyTextStyle.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),

            Text(
              isFolder ? '文件夹' : file.formattedSize,
              style: CloudDriveUIConfig.smallTextStyle.copyWith(
                fontSize: 8,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 8, color: typeColor),
                SizedBox(width: 2.w),
                Text(
                  _formatTime(file.modifiedTime),
                  style: CloudDriveUIConfig.smallTextStyle.copyWith(
                    fontSize: 8,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    return FileTimeFormatter.format(time);
  }

  Widget _buildThumbOrIcon(Color typeColor, IconData typeIcon) {
    final radius = BorderRadius.circular(16);
    final size = 46.w;

    if (!isFolder && file.thumbnailUrl != null && file.thumbnailUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: size,
          height: size,
          child: AuthenticatedNetworkImage(
            imageUrl: file.thumbnailUrl!,
            account: account,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(bottom: 6.w),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.18),
        borderRadius: radius,
      ),
      child: Icon(typeIcon, color: typeColor, size: 26.w),
    );
  }
}

class _IndexedEntry extends ISuspensionBean {
  _IndexedEntry({
    required this.file,
    required String tag,
  })  : _tag = tag,
        isLoader = false,
        isFolder = file?.isFolder ?? false;

  _IndexedEntry.loader()
      : file = null,
        _tag = '~',
        isLoader = true,
        isFolder = false;

  final CloudDriveFile? file;
  final bool isLoader;
  final bool isFolder;
  String _tag;
  String get tag => _tag;

  @override
  String getSuspensionTag() => _tag;
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
      opacity: Tween<double>(
        begin: 0.4,
        end: 0.9,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
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
          child: Opacity(opacity: 1 - value * 0.4, child: child),
        );
      },
      child: child,
    );
  }
}
