import 'package:flutter/material.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../utils/file_type_utils.dart';

/// 文件信息区域组件
class FileInfoSection extends StatefulWidget {
  final CloudDriveFile file;
  final Map<String, dynamic>? fileDetail;

  const FileInfoSection({super.key, required this.file, this.fileDetail});

  @override
  State<FileInfoSection> createState() => _FileInfoSectionState();
}

class _FileInfoSectionState extends State<FileInfoSection>
    with SingleTickerProviderStateMixin {
  bool _detailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final file = widget.file;
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

          // 详细信息卡片（可折叠）
          _buildCollapsibleInfoCard(theme, file),
        ],
      ),
    );
  }

  Widget _buildCollapsibleInfoCard(ThemeData theme, CloudDriveFile file) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _detailsExpanded = !_detailsExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: CloudDriveUIConfig.spacingM,
                vertical: CloudDriveUIConfig.spacingM,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: CloudDriveUIConfig.spacingM),
                  Text(
                    '文件详情',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Spacer(),
                  Text(
                    _detailsExpanded ? '收起' : '展开',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Icon(
                    _detailsExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: SizedBox.shrink(),
            secondChild: Column(
              children: [
                if (file.modifiedTime != null)
                  _buildInfoItem(
                    theme,
                    icon: Icons.access_time_rounded,
                    label: '修改时间',
                    value: _formatDateTime(file.modifiedTime!),
                    isFirst: true,
                  ),
                _buildInfoItem(
                  theme,
                  icon: Icons.download_outlined,
                  label: '下载次数',
                  value: file.downloadCount >= 0
                      ? file.downloadCount.toString()
                      : '暂不提供',
                  isFirst: file.modifiedTime == null,
                  isLast: false,
                ),
                _buildInfoItem(
                  theme,
                  icon: Icons.share_outlined,
                  label: '分享次数',
                  value:
                      file.shareCount >= 0
                          ? file.shareCount.toString()
                          : '暂不提供',
                  isFirst: false,
                  isLast: false,
                ),
                _buildInfoItem(
                  theme,
                  icon: Icons.tag_rounded,
                  label: '文件ID',
                  value:
                      file.id.length > 20
                          ? '${file.id.substring(0, 20)}...'
                          : file.id,
                  isFirst: false,
                  isLast: true,
                ),
              ],
            ),
            crossFadeState:
                _detailsExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
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
}
