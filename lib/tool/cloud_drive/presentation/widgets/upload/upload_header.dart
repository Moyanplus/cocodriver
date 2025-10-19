import 'package:flutter/material.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';

/// 上传页面头部组件
class UploadHeader extends StatelessWidget {
  final CloudDriveAccount account;
  final String folderName;

  const UploadHeader({
    super.key,
    required this.account,
    required this.folderName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: CloudDriveUIConfig.pagePadding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: CloudDriveUIConfig.dividerColor.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.folder,
            color: CloudDriveUIConfig.folderColor,
            size: CloudDriveUIConfig.iconSize,
          ),
          SizedBox(width: CloudDriveUIConfig.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '上传到: $folderName',
                  style: CloudDriveUIConfig.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: CloudDriveUIConfig.spacingXS),
                Text(
                  '${account.type.displayName} - ${account.name}',
                  style: CloudDriveUIConfig.smallTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
