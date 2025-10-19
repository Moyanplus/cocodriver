import 'package:flutter/material.dart';
import '../../../config/cloud_drive_ui_config.dart';

/// 上传进度组件
class UploadProgress extends StatelessWidget {
  final double progress;
  final String currentFile;
  final bool isUploading;

  const UploadProgress({
    super.key,
    required this.progress,
    required this.currentFile,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: CloudDriveUIConfig.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 进度图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CloudDriveUIConfig.primaryActionColor.withOpacity(0.1),
            ),
            child: Stack(
              children: [
                Center(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CloudDriveUIConfig.primaryActionColor,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: CloudDriveUIConfig.smallTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: CloudDriveUIConfig.primaryActionColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: CloudDriveUIConfig.spacingL),

          // 状态文本
          Text(
            isUploading ? '正在上传...' : '上传完成',
            style: CloudDriveUIConfig.titleTextStyle,
          ),

          SizedBox(height: CloudDriveUIConfig.spacingS),

          // 当前文件
          if (currentFile.isNotEmpty) ...[
            Container(
              padding: CloudDriveUIConfig.cardPadding,
              decoration: BoxDecoration(
                color: CloudDriveUIConfig.cardBackgroundColor,
                borderRadius: BorderRadius.circular(
                  CloudDriveUIConfig.cardRadius,
                ),
                border: Border.all(
                  color: CloudDriveUIConfig.dividerColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    color: CloudDriveUIConfig.primaryActionColor,
                    size: CloudDriveUIConfig.iconSize,
                  ),
                  SizedBox(width: CloudDriveUIConfig.spacingM),
                  Expanded(
                    child: Text(
                      currentFile,
                      style: CloudDriveUIConfig.bodyTextStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: CloudDriveUIConfig.spacingL),

          // 进度条
          LinearProgressIndicator(
            value: progress,
            backgroundColor: CloudDriveUIConfig.dividerColor.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              CloudDriveUIConfig.primaryActionColor,
            ),
          ),
        ],
      ),
    );
  }
}
