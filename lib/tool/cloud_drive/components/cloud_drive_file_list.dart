import 'package:flutter/material.dart';
import '../models/cloud_drive_models.dart';
import 'cloud_drive_base_widgets.dart';
import 'cloud_drive_file_item.dart';

/// 文件列表显示模式
enum FileListDisplayMode {
  list, // 列表模式
  compact, // 紧凑模式
  grid, // 网格模式
  detailed, // 详细信息模式
}

/// 文件列表组件
class CloudDriveFileList extends StatelessWidget {
  final List<CloudDriveFile> files;
  final List<CloudDriveFile> folders;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final FileListDisplayMode displayMode;
  final List<String> selectedFileIds;
  final Function(CloudDriveFile)? onFileTap;
  final Function(CloudDriveFile)? onFileLongPress;
  final Function(CloudDriveFile)? onFolderTap;
  final Function(CloudDriveFile)? onFolderLongPress;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRetry;

  const CloudDriveFileList({
    super.key,
    required this.files,
    required this.folders,
    this.isLoading = false,
    this.hasMore = false,
    this.error,
    this.displayMode = FileListDisplayMode.list,
    this.selectedFileIds = const [],
    this.onFileTap,
    this.onFileLongPress,
    this.onFolderTap,
    this.onFolderLongPress,
    this.onLoadMore,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // 如果有错误，显示错误状态
    if (error != null) {
      return CloudDriveBaseWidgets.buildErrorState(
        message: error!,
        onRetry: onRetry,
      );
    }

    // 如果正在加载且没有数据，显示加载状态
    if (isLoading && files.isEmpty && folders.isEmpty) {
      return CloudDriveBaseWidgets.buildLoadingIndicator(
        message: '正在加载文件列表...',
      );
    }

    // 如果没有数据，显示空状态
    if (files.isEmpty && folders.isEmpty && !isLoading) {
      return CloudDriveBaseWidgets.buildEmptyState(
        message: '当前文件夹为空',
        icon: Icons.folder_open,
        onAction: onRetry,
        actionText: '刷新',
      );
    }

    // 根据显示模式构建不同的列表
    switch (displayMode) {
      case FileListDisplayMode.list:
        return _buildListView();
      case FileListDisplayMode.compact:
        return _buildCompactListView();
      case FileListDisplayMode.grid:
        return _buildGridView();
      case FileListDisplayMode.detailed:
        return _buildDetailedListView();
    }
  }

  /// 构建列表视图
  Widget _buildListView() {
    final allItems = [...folders, ...files];

    return ListView.builder(
      itemCount: allItems.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == allItems.length) {
          // 加载更多按钮
          return _buildLoadMoreButton();
        }

        final item = allItems[index];
        final isSelected = selectedFileIds.contains(item.id);

        if (item.isFolder) {
          return CloudDriveFileItem(
            file: item,
            isSelected: isSelected,
            onTap: () => onFolderTap?.call(item),
            onLongPress: () => onFolderLongPress?.call(item),
          );
        } else {
          return CloudDriveFileItem(
            file: item,
            isSelected: isSelected,
            onTap: () => onFileTap?.call(item),
            onLongPress: () => onFileLongPress?.call(item),
          );
        }
      },
    );
  }

  /// 构建紧凑列表视图
  Widget _buildCompactListView() {
    final allItems = [...folders, ...files];

    return ListView.builder(
      itemCount: allItems.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == allItems.length) {
          return _buildLoadMoreButton();
        }

        final item = allItems[index];
        final isSelected = selectedFileIds.contains(item.id);

        if (item.isFolder) {
          return CloudDriveFileItemCompact(
            file: item,
            isSelected: isSelected,
            onTap: () => onFolderTap?.call(item),
            onLongPress: () => onFolderLongPress?.call(item),
          );
        } else {
          return CloudDriveFileItemCompact(
            file: item,
            isSelected: isSelected,
            onTap: () => onFileTap?.call(item),
            onLongPress: () => onFileLongPress?.call(item),
          );
        }
      },
    );
  }

  /// 构建网格视图
  Widget _buildGridView() {
    final allItems = [...folders, ...files];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: allItems.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == allItems.length) {
          return _buildLoadMoreButton();
        }

        final item = allItems[index];
        final isSelected = selectedFileIds.contains(item.id);

        if (item.isFolder) {
          return CloudDriveFileItemGrid(
            file: item,
            isSelected: isSelected,
            onTap: () => onFolderTap?.call(item),
            onLongPress: () => onFolderLongPress?.call(item),
          );
        } else {
          return CloudDriveFileItemGrid(
            file: item,
            isSelected: isSelected,
            onTap: () => onFileTap?.call(item),
            onLongPress: () => onFileLongPress?.call(item),
          );
        }
      },
    );
  }

  /// 构建详细信息列表视图
  Widget _buildDetailedListView() {
    final allItems = [...folders, ...files];

    return ListView.builder(
      itemCount: allItems.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == allItems.length) {
          return _buildLoadMoreButton();
        }

        final item = allItems[index];
        final isSelected = selectedFileIds.contains(item.id);

        if (item.isFolder) {
          return CloudDriveFileItemDetailed(
            file: item,
            isSelected: isSelected,
            onTap: () => onFolderTap?.call(item),
            onLongPress: () => onFolderLongPress?.call(item),
          );
        } else {
          return CloudDriveFileItemDetailed(
            file: item,
            isSelected: isSelected,
            onTap: () => onFileTap?.call(item),
            onLongPress: () => onFileLongPress?.call(item),
          );
        }
      },
    );
  }

  /// 构建加载更多按钮
  Widget _buildLoadMoreButton() {
    if (!hasMore) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : CloudDriveBaseWidgets.buildButton(
                  text: '加载更多',
                  onPressed: onLoadMore ?? () {},
                  icon: Icons.expand_more,
                ),
      ),
    );
  }
}

/// 文件列表统计信息组件
class CloudDriveFileListStats extends StatelessWidget {
  final int fileCount;
  final int folderCount;
  final String totalSize;

  const CloudDriveFileListStats({
    super.key,
    required this.fileCount,
    required this.folderCount,
    required this.totalSize,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('文件夹', folderCount, Icons.folder),
        _buildStatItem('文件', fileCount, Icons.insert_drive_file),
        _buildStatItem('总大小', 0, Icons.storage, text: totalSize),
      ],
    ),
  );

  Widget _buildStatItem(
    String label,
    int count,
    IconData icon, {
    String? text,
  }) => Column(
    children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(height: 4),
      Text(
        text ?? count.toString(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    ],
  );
}
