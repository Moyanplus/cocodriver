import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_utils.dart';
import '../data/models/cloud_drive_entities.dart';
import '../utils/file_type_utils.dart';
import '../components/cloud_drive_base_widgets.dart';

/// 云盘文件项组件
class CloudDriveFileItem extends StatelessWidget {
  final CloudDriveFile file;
  final bool isFolder;
  final bool isSelected;
  final bool isBatchMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CloudDriveFileItem({
    super.key,
    required this.file,
    required this.isFolder,
    required this.isSelected,
    required this.isBatchMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(
          vertical: 2.h,
          horizontal: ResponsiveUtils.getSpacing() * 0.67,
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
            height: ResponsiveUtils.getResponsiveHeight(80.h),
            padding: ResponsiveUtils.getResponsivePadding(
              horizontal: 8.w,
              vertical: 4.h,
            ),
            child: Row(
              children: [
                // 文件/文件夹图标
                Container(
                  padding: ResponsiveUtils.getResponsivePadding(all: 3.w),
                  decoration: BoxDecoration(
                    color:
                        isFolder
                            ? Colors.orange.withValues(alpha: 0.1)
                            : FileTypeUtils.getFileTypeColor(
                              file.name,
                            ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getCardRadius() * 0.5,
                    ),
                  ),
                  child: Icon(
                    isFolder
                        ? Icons.folder
                        : FileTypeUtils.getFileTypeIcon(file.name),
                    color:
                        isFolder
                            ? Colors.orange
                            : FileTypeUtils.getFileTypeColor(file.name),
                    size: ResponsiveUtils.getIconSize(22.sp),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getSpacing() * 0.75),
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
                      SizedBox(height: ResponsiveUtils.getSpacing() * 0.25),
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
