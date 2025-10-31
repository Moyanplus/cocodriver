import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../utils/file_type_utils.dart';
import '../ui/cloud_drive_base_widgets.dart';
import 'authenticated_network_image.dart';

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
    // 打印文件数据，查看thumbnailUrl
    LogManager().cloudDrive(
      '文件项数据: name=${file.name}, '
      'isFolder=$isFolder, '
      'thumbnailUrl=${file.thumbnailUrl}, '
      'size=${file.size}, '
      'id=${file.id}',
    );

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(
          vertical: 1.h,
          horizontal: ResponsiveUtils.getSpacing() * 0.5,
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shadowColor: Colors.transparent,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getCardRadius() * 0.5,
            ),
            side:
                isBatchMode && isSelected
                    ? BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.w,
                    )
                    : BorderSide.none,
          ),
          child: Container(
            height: ResponsiveUtils.getResponsiveHeight(42.h),
            padding: ResponsiveUtils.getResponsivePadding(
              horizontal: 6.w,
              vertical: 2.h,
            ),
            child: Row(
              children: [
                // 文件/文件夹图标或预览图
                _buildFileIcon(context),
                SizedBox(width: ResponsiveUtils.getSpacing() * 0.5),
                // 文本内容
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
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: ResponsiveUtils.getSpacing() * 0.15),
                      // 显示文件大小和修改时间
                      Text(
                        isFolder
                            ? (file.modifiedTime?.toString() ?? '')
                            : _buildFileInfoText(file),
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            10.sp,
                          ),
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
      LogManager().cloudDrive(
        '[${file.name}] 准备加载缩略图: ${file.thumbnailUrl}',
      );

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

    LogManager().cloudDrive('[${file.name}] 没有缩略图，使用默认图标');

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
}
