import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/cloud_drive_ui_config.dart';
import '../../models/cloud_drive_models.dart';
import '../common/cloud_drive_common_widgets.dart';
import '../../utils/file_type_utils.dart';

/// 文件信息显示组件
class FileInfoDisplay extends StatelessWidget {
  final CloudDriveFile file;
  final VoidCallback? onTap;

  const FileInfoDisplay({
    super.key,
    required this.file,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CloudDriveCommonWidgets.buildCard(
      onTap: onTap,
      child: Row(
        children: [
          // 文件图标
          _buildFileIcon(),
          
          SizedBox(width: CloudDriveUIConfig.spacingM),
          
          // 文件信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 文件名
                Text(
                  file.name,
                  style: CloudDriveUIConfig.titleTextStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: CloudDriveUIConfig.spacingXS),
                
                // 文件大小和类型
                Text(
                  _getFileInfoText(),
                  style: CloudDriveUIConfig.smallTextStyle,
                ),
                
                SizedBox(height: CloudDriveUIConfig.spacingXS),
                
                // 文件路径（注意：CloudDriveFile模型中没有path字段）
                // 如果需要显示路径，应该从其他地方获取
              ],
            ),
          ),
          
          // 箭头图标
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: CloudDriveUIConfig.secondaryTextColor,
              size: CloudDriveUIConfig.iconSize,
            ),
        ],
      ),
    );
  }

  /// 构建文件图标
  Widget _buildFileIcon() {
    final fileTypeInfo = FileTypeUtils.getFileTypeInfo(file.name);
    
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: file.isFolder 
            ? CloudDriveUIConfig.folderColor.withOpacity(0.1)
            : fileTypeInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
      ),
      child: Icon(
        file.isFolder ? Icons.folder : fileTypeInfo.iconData,
        color: file.isFolder 
            ? CloudDriveUIConfig.folderColor
            : fileTypeInfo.color,
        size: CloudDriveUIConfig.iconSizeL,
      ),
    );
  }

  /// 获取文件信息文本
  String _getFileInfoText() {
    if (file.isFolder) {
      return '文件夹';
    }
    
    final sizeText = _formatFileSize(file.size);
    final extension = _getFileExtension(file.name);
    
    return '$sizeText • $extension';
  }

  /// 格式化文件大小
  String _formatFileSize(int? bytes) {
    if (bytes == null || bytes == 0) return '未知大小';
    
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
  }

  /// 获取文件扩展名
  String _getFileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.last.toUpperCase();
    }
    return 'FILE';
  }
}
