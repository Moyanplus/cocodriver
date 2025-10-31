import 'package:flutter/material.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../utils/file_type_utils.dart';

/// 文件信息区域组件
class FileInfoSection extends StatelessWidget {
  final CloudDriveFile file;
  final Map<String, dynamic>? fileDetail;

  const FileInfoSection({super.key, required this.file, this.fileDetail});

  @override
  Widget build(BuildContext context) {
    final fileTypeInfo = FileTypeUtils.getFileTypeInfo(file.name);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: CloudDriveUIConfig.spacingM,
        vertical: CloudDriveUIConfig.spacingS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文件类型徽章和大小信息
          Row(
            children: [
              // 文件类型徽章
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: CloudDriveUIConfig.spacingM,
                  vertical: CloudDriveUIConfig.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: fileTypeInfo.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      fileTypeInfo.iconData,
                      size: 14,
                      color: fileTypeInfo.color,
                    ),
                    SizedBox(width: CloudDriveUIConfig.spacingXS),
                    Text(
                      fileTypeInfo.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: fileTypeInfo.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(),

              // 文件大小
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: CloudDriveUIConfig.spacingM,
                  vertical: CloudDriveUIConfig.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storage_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: CloudDriveUIConfig.spacingXS),
                    Text(
                      _formatFileSize(file.size ?? 0),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 详细信息卡片 - 使用网格布局
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // 修改时间
                if (file.modifiedTime != null)
                  _buildInfoItem(
                    context,
                    icon: Icons.access_time_rounded,
                    label: '修改时间',
                    value: _formatDateTime(file.modifiedTime!),
                    isFirst: true,
                  ),

                // 文件ID
                _buildInfoItem(
                  context,
                  icon: Icons.tag_rounded,
                  label: '文件ID',
                  value:
                      file.id.length > 20
                          ? '${file.id.substring(0, 20)}...'
                          : file.id,
                  isFirst: file.modifiedTime == null,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CloudDriveUIConfig.spacingM,
        vertical: CloudDriveUIConfig.spacingM,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom:
              !isLast
                  ? BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                    width: 0.5,
                  )
                  : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          // 图标
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),

          SizedBox(width: CloudDriveUIConfig.spacingM),

          // 标签和值
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化文件分类
  String _formatCategory(FileCategory category) {
    switch (category) {
      case FileCategory.image:
        return '图片';
      case FileCategory.video:
        return '视频';
      case FileCategory.audio:
        return '音频';
      case FileCategory.document:
        return '文档';
      case FileCategory.archive:
        return '压缩包';
      case FileCategory.other:
        return '其他';
    }
  }

  /// 构建metadata项目
  List<Widget> _buildMetadataItems(BuildContext context) {
    final items = <Widget>[];

    if (file.metadata != null) {
      // 如果metadata中有path
      if (file.metadata!['path'] != null &&
          file.metadata!['path'].toString().isNotEmpty) {
        // 如果file.path为空，才显示metadata中的path
        if (file.path == null || file.path!.isEmpty) {
          items.add(
            _buildInfoItem(
              context,
              icon: Icons.folder_open_rounded,
              label: '路径',
              value: file.metadata!['path'].toString(),
            ),
          );
        }
      }

      // 如果metadata中有其他有用的信息，也可以显示
      file.metadata!.forEach((key, value) {
        // 跳过已经显示的字段
        if (key != 'path' &&
            key != 'md5' &&
            value != null &&
            value.toString().isNotEmpty) {
          items.add(
            _buildInfoItem(
              context,
              icon: Icons.info_outline_rounded,
              label: key.toUpperCase(),
              value:
                  value.toString().length > 30
                      ? '${value.toString().substring(0, 30)}...'
                      : value.toString(),
            ),
          );
        }
      });
    }

    return items;
  }
}
