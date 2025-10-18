import 'package:flutter/material.dart';
import '../models/cloud_drive_models.dart';
import 'cloud_drive_base_widgets.dart';

/// 文件列表项组件
class CloudDriveFileItem extends StatelessWidget {
  final CloudDriveFile file;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<Widget>? trailingActions;

  const CloudDriveFileItem({
    super.key,
    required this.file,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.trailingActions,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      border: isSelected ? Border.all(color: Colors.blue, width: 1) : null,
    ),
    child: ListTile(
      leading: CloudDriveBaseWidgets.buildFileIcon(file, size: 32),
      title: Text(
        file.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!file.isFolder) ...[
            Text(
              CloudDriveBaseWidgets.formatFileSize(file.size ?? 0),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          Text(
            CloudDriveBaseWidgets.formatTime(file.modifiedTime),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      trailing:
          trailingActions != null
              ? Row(mainAxisSize: MainAxisSize.min, children: trailingActions!)
              : null,
      onTap: onTap,
      onLongPress: onLongPress,
    ),
  );
}

/// 文件列表项（紧凑模式）
class CloudDriveFileItemCompact extends StatelessWidget {
  final CloudDriveFile file;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CloudDriveFileItemCompact({
    super.key,
    required this.file,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    decoration: BoxDecoration(
      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
    ),
    child: ListTile(
      dense: true,
      leading: CloudDriveBaseWidgets.buildFileIcon(file, size: 24),
      title: Text(
        file.name,
        style: const TextStyle(fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle:
          !file.isFolder
              ? Text(
                CloudDriveBaseWidgets.formatFileSize(file.size ?? 0),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              )
              : null,
      onTap: onTap,
      onLongPress: onLongPress,
    ),
  );
}

/// 文件列表项（网格模式）
class CloudDriveFileItemGrid extends StatelessWidget {
  final CloudDriveFile file;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CloudDriveFileItemGrid({
    super.key,
    required this.file,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    onLongPress: onLongPress,
    child: Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border:
            isSelected
                ? Border.all(color: Colors.blue, width: 2)
                : Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CloudDriveBaseWidgets.buildFileIcon(file, size: 48),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              file.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          if (!file.isFolder) ...[
            const SizedBox(height: 4),
            Text(
              CloudDriveBaseWidgets.formatFileSize(file.size ?? 0),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ],
      ),
    ),
  );
}

/// 文件列表项（详细信息模式）
class CloudDriveFileItemDetailed extends StatelessWidget {
  final CloudDriveFile file;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<Widget>? trailingActions;

  const CloudDriveFileItemDetailed({
    super.key,
    required this.file,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.trailingActions,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
      borderRadius: BorderRadius.circular(8),
      border:
          isSelected
              ? Border.all(color: Colors.blue, width: 1)
              : Border.all(color: Colors.grey.shade300, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CloudDriveBaseWidgets.buildFileIcon(file, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (!file.isFolder) ...[
                  Text(
                    '大小: ${CloudDriveBaseWidgets.formatFileSize(file.size ?? 0)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  '修改时间: ${CloudDriveBaseWidgets.formatTime(file.modifiedTime)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${file.id}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (trailingActions != null) ...[
            const SizedBox(width: 8),
            ...trailingActions!,
          ],
        ],
      ),
    ),
  );
}
