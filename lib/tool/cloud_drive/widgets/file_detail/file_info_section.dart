import 'package:flutter/material.dart';
import '../../config/cloud_drive_ui_config.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../utils/file_type_utils.dart';

/// 文件信息区域组件
class FileInfoSection extends StatelessWidget {
  final CloudDriveFile file;
  final Map<String, dynamic>? fileDetail;

  const FileInfoSection({super.key, required this.file, this.fileDetail});

  @override
  Widget build(BuildContext context) {
    final fileTypeInfo = FileTypeUtils.getFileTypeInfo(file.name);

    return Container(
      padding: CloudDriveUIConfig.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('文件信息', style: CloudDriveUIConfig.titleTextStyle),
          SizedBox(height: CloudDriveUIConfig.spacingM),

          Card(
            child: Padding(
              padding: CloudDriveUIConfig.cardPadding,
              child: Column(
                children: [
                  // 文件图标和名称
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(CloudDriveUIConfig.spacingM),
                        decoration: BoxDecoration(
                          color: fileTypeInfo.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            CloudDriveUIConfig.cardRadius,
                          ),
                        ),
                        child: Icon(
                          fileTypeInfo.iconData,
                          color: fileTypeInfo.color,
                          size: CloudDriveUIConfig.iconSizeL,
                        ),
                      ),
                      SizedBox(width: CloudDriveUIConfig.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.name,
                              style: CloudDriveUIConfig.titleTextStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: CloudDriveUIConfig.spacingXS),
                            Text(
                              fileTypeInfo.category,
                              style: CloudDriveUIConfig.smallTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: CloudDriveUIConfig.spacingM),

                  // 详细信息
                  _buildInfoRow('文件ID', file.id),
                  _buildInfoRow('文件大小', _formatFileSize(file.size ?? 0)),
                  _buildInfoRow('创建时间', _formatDateTime(DateTime.now())),
                  _buildInfoRow('修改时间', _formatDateTime(DateTime.now())),
                  if (fileDetail != null) ...[
                    if (fileDetail!['md5'] != null)
                      _buildInfoRow('MD5', fileDetail!['md5']),
                    if (fileDetail!['sha1'] != null)
                      _buildInfoRow('SHA1', fileDetail!['sha1']),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: CloudDriveUIConfig.spacingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: CloudDriveUIConfig.smallTextStyle.copyWith(
                color: CloudDriveUIConfig.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value, style: CloudDriveUIConfig.bodyTextStyle)),
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
