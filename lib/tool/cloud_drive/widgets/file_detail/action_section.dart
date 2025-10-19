import 'package:flutter/material.dart';
import '../../config/cloud_drive_ui_config.dart';
import '../../data/models/cloud_drive_entities.dart';

/// 操作区域组件
class ActionSection extends StatelessWidget {
  final CloudDriveFile file;
  final CloudDriveAccount account;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const ActionSection({
    super.key,
    required this.file,
    required this.account,
    this.onDownload,
    this.onShare,
    this.onRename,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: CloudDriveUIConfig.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('操作', style: CloudDriveUIConfig.titleTextStyle),
          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 主要操作按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download),
                  label: const Text('下载'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CloudDriveUIConfig.primaryActionColor,
                    foregroundColor: Colors.white,
                    padding: CloudDriveUIConfig.buttonPadding,
                  ),
                ),
              ),
              SizedBox(width: CloudDriveUIConfig.spacingM),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share),
                  label: const Text('分享'),
                  style: OutlinedButton.styleFrom(
                    padding: CloudDriveUIConfig.buttonPadding,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 次要操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRename,
                  icon: const Icon(Icons.edit),
                  label: const Text('重命名'),
                  style: OutlinedButton.styleFrom(
                    padding: CloudDriveUIConfig.buttonPadding,
                  ),
                ),
              ),
              SizedBox(width: CloudDriveUIConfig.spacingM),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('删除'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: CloudDriveUIConfig.buttonPadding,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
