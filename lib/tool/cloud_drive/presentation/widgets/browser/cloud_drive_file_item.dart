import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../utils/file_type_utils.dart';
import '../../ui/cloud_drive_base_widgets.dart';
import '../common/authenticated_network_image.dart';
import '../common/file_time_formatter.dart';

/// 云盘文件项组件
class CloudDriveFileItem extends StatelessWidget {
  final CloudDriveFile file;
  final CloudDriveAccount account;
  final bool isFolder;
  final bool isSelected;
  final bool isBatchMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CloudDriveFileItem({
    super.key,
    required this.file,
    required this.account,
    required this.isFolder,
    required this.isSelected,
    required this.isBatchMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(
      ResponsiveUtils.getCardRadius() * 0.5,
    );

    final bool highlight = isBatchMode && isSelected;
    final bool isUploading = file.metadata?['isUploading'] == true;
    final double? uploadProgress =
        (file.metadata?['uploadProgress'] as num?)?.toDouble();

    final overlay =
        MaterialStateProperty.all(theme.colorScheme.primary.withOpacity(0.08));
    final splashColor = theme.colorScheme.primary.withOpacity(0.16);
    final highlightColor = theme.colorScheme.primary.withOpacity(0.06);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 1.h,
        horizontal: ResponsiveUtils.getSpacing() * 0.5,
      ),
      child: Material(
        // 使用实体背景让水波纹清晰可见
        color: theme.colorScheme.surface,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: splashColor,
          highlightColor: highlightColor,
          overlayColor: overlay,
          splashFactory: InkRipple.splashFactory,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color:
                  highlight
                      ? theme.colorScheme.primary.withValues(alpha: 0.08)
                      : theme.colorScheme.surface,  // 保持系统默认背景

              borderRadius: borderRadius,
              border:
                  highlight
                      ? Border.all(
                        color: theme.colorScheme.primary,
                        width: 1.6.w,
                      )
                      : null,
            ),
            constraints: BoxConstraints(
              minHeight: ResponsiveUtils.getResponsiveHeight(52.h),
            ),
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                if (isUploading && uploadProgress != null)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: uploadProgress.clamp(0.0, 1.0),
                        child: Container(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: ResponsiveUtils.getResponsivePadding(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    children: [
                    AnimatedScale(
                      scale: highlight ? 1.05 : 1,
                      duration: const Duration(milliseconds: 180),
                      child: _buildFileIcon(context),
                    ),
                    SizedBox(width: ResponsiveUtils.getSpacing() * 0.5),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                12.sp,
                              ),
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: ResponsiveUtils.getSpacing() * 0.15),
                          Text(
                            _buildSecondaryText(isUploading, uploadProgress),
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                10.sp,
                              ),
                              color: theme.colorScheme.onSurfaceVariant,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建文件图标或预览图
  Widget _buildFileIcon(BuildContext context) {
    final iconPadding = ResponsiveUtils.getResponsivePadding(all: 7.w);

    // 文件夹始终显示图标
    if (isFolder) {
      return Container(
        padding: iconPadding,
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getCardRadius() * 0.5,
          ),
        ),
        child: Icon(
          Icons.folder,
          color: Colors.orange,
          size: ResponsiveUtils.getIconSize(20.sp),
        ),
      );
    }

    // 文件有预览图时显示图片
    if (file.thumbnailUrl != null && file.thumbnailUrl!.isNotEmpty) {
      // 缩略图直接占满容器，不需要padding和背景色
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getCardRadius() * 0.5,
        ),
        child: SizedBox(
          width: ResponsiveUtils.getIconSize(20.sp) + iconPadding.horizontal,
          height: ResponsiveUtils.getIconSize(20.sp) + iconPadding.vertical,
          child: AuthenticatedNetworkImage(
            imageUrl: file.thumbnailUrl!,
            account: account,
            fit: BoxFit.cover,
            placeholderBuilder:
                () => Container(
                  padding: iconPadding,
                  decoration: BoxDecoration(
                    color: FileTypeUtils.getFileTypeColor(
                      file.name,
                    ).withValues(alpha: 0.1),
                  ),
                  child: _buildDefaultIcon(),
                ),
            errorBuilder:
                () => Container(
                  padding: iconPadding,
                  decoration: BoxDecoration(
                    color: FileTypeUtils.getFileTypeColor(
                      file.name,
                    ).withValues(alpha: 0.1),
                  ),
                  child: _buildDefaultIcon(),
                ),
          ),
        ),
      );
    }

    // LogManager().cloudDrive('[${file.name}] 没有缩略图，使用默认图标');

    // 没有预览图时显示默认图标
    return Container(
      padding: iconPadding,
      decoration: BoxDecoration(
        color: FileTypeUtils.getFileTypeColor(file.name).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getCardRadius() * 0.5,
        ),
      ),
      child: _buildDefaultIcon(),
    );
  }

  /// 构建默认文件图标
  Widget _buildDefaultIcon() {
    return Icon(
      FileTypeUtils.getFileTypeIcon(file.name),
      color: FileTypeUtils.getFileTypeColor(file.name),
      size: ResponsiveUtils.getIconSize(20.sp),
    );
  }

  String _buildSecondaryText(bool isUploading, double? progress) {
    if (isUploading && progress != null) {
      final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);
      return '上传中 · $percent%';
    }
    if (isFolder) {
      return _formatTime(file.updatedAt ?? file.createdAt);
    }
    return _buildFileInfoText(file);
  }

  // 构建文件信息文本
  String _buildFileInfoText(CloudDriveFile item) {
    final parts = <String>[];

    // 添加时间信息（如果有）
    final time = item.updatedAt ?? item.createdAt;
    if (time != null) {
      parts.add(_formatTime(time));
    }

    // 添加大小信息（如果有）
    if (item.size != null && item.size! > 0) {
      parts.add(CloudDriveBaseWidgets.formatFileSize(item.size!));
    }

    // 下载量/分享量（>=0 才显示）

    // 如果没有任何信息，返回空字符串
    if (parts.isEmpty) {
      return '';
    }

    // 用 • 连接多个信息
    return parts.join(' • ');
  }

  String _formatTime(DateTime? time) => FileTimeFormatter.format(time);
}
