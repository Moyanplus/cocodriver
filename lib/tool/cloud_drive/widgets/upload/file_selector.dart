import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../config/cloud_drive_ui_config.dart';

/// 文件选择器组件
class FileSelector extends StatelessWidget {
  final VoidCallback onPickFiles;

  const FileSelector({super.key, required this.onPickFiles});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload,
            size: 64,
            color: CloudDriveUIConfig.secondaryTextColor,
          ),
          SizedBox(height: CloudDriveUIConfig.spacingM),
          Text(
            '选择要上传的文件',
            style: CloudDriveUIConfig.titleTextStyle.copyWith(
              color: CloudDriveUIConfig.secondaryTextColor,
            ),
          ),
          SizedBox(height: CloudDriveUIConfig.spacingS),
          Text(
            '支持各种类型的文件',
            style: CloudDriveUIConfig.bodyTextStyle.copyWith(
              color: CloudDriveUIConfig.secondaryTextColor,
            ),
          ),
          SizedBox(height: CloudDriveUIConfig.spacingL),
          ElevatedButton.icon(
            onPressed: onPickFiles,
            icon: const Icon(Icons.file_upload),
            label: const Text('选择文件'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CloudDriveUIConfig.primaryActionColor,
              foregroundColor: Colors.white,
              padding: CloudDriveUIConfig.buttonPadding,
            ),
          ),
        ],
      ),
    );
  }
}
