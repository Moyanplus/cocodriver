import 'package:flutter/material.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../utils/file_type_utils.dart';

/// 预览区域组件
class PreviewSection extends StatelessWidget {
  final CloudDriveFile file;
  final Map<String, dynamic>? fileDetail;

  const PreviewSection({super.key, required this.file, this.fileDetail});

  @override
  Widget build(BuildContext context) {
    final fileTypeInfo = FileTypeUtils.getFileTypeInfo(file.name);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: CloudDriveUIConfig.spacingM,
        vertical: CloudDriveUIConfig.spacingS,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              fileTypeInfo.color.withOpacity(0.05),
              fileTypeInfo.color.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: fileTypeInfo.color.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: _buildPreviewContent(context, fileTypeInfo),
      ),
    );
  }

  /// 构建预览内容
  Widget _buildPreviewContent(BuildContext context, FileTypeInfo fileTypeInfo) {
    if (_isImage(file.name)) {
      return _buildImagePreview(context, fileTypeInfo);
    } else if (_isText(file.name)) {
      return _buildTextPreview(context, fileTypeInfo);
    } else if (_isVideo(file.name)) {
      return _buildVideoPreview(context, fileTypeInfo);
    } else {
      return _buildUnsupportedPreview(context, fileTypeInfo);
    }
  }

  /// 构建图片预览
  Widget _buildImagePreview(BuildContext context, FileTypeInfo fileTypeInfo) {
    return Padding(
      padding: EdgeInsets.all(CloudDriveUIConfig.spacingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标容器
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: fileTypeInfo.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_rounded,
              size: 48,
              color: fileTypeInfo.color,
            ),
          ),

          SizedBox(height: CloudDriveUIConfig.spacingM),

          Text(
            '图片文件',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: fileTypeInfo.color,
            ),
          ),

          SizedBox(height: CloudDriveUIConfig.spacingXS),

          Text(
            '下载后可查看完整图片',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建文本预览
  Widget _buildTextPreview(BuildContext context, FileTypeInfo fileTypeInfo) {
    return Padding(
      padding: EdgeInsets.all(CloudDriveUIConfig.spacingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: fileTypeInfo.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_rounded,
              size: 48,
              color: fileTypeInfo.color,
            ),
          ),

          SizedBox(height: CloudDriveUIConfig.spacingM),

          Text(
            '文本文件',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: fileTypeInfo.color,
            ),
          ),

          SizedBox(height: CloudDriveUIConfig.spacingXS),

          Text(
            '下载后可查看完整内容',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建视频预览
  Widget _buildVideoPreview(BuildContext context, FileTypeInfo fileTypeInfo) {
    return Padding(
      padding: EdgeInsets.all(CloudDriveUIConfig.spacingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: fileTypeInfo.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_circle_outline_rounded,
              size: 48,
              color: fileTypeInfo.color,
            ),
          ),

          SizedBox(height: CloudDriveUIConfig.spacingM),

          Text(
            '视频文件',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: fileTypeInfo.color,
            ),
          ),

          SizedBox(height: CloudDriveUIConfig.spacingXS),

          Text(
            '下载后可播放视频',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建不支持的预览
  Widget _buildUnsupportedPreview(
    BuildContext context,
    FileTypeInfo fileTypeInfo,
  ) {
    return Padding(
      padding: EdgeInsets.all(CloudDriveUIConfig.spacingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: fileTypeInfo.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              fileTypeInfo.iconData,
              size: 48,
              color: fileTypeInfo.color,
            ),
          ),

          SizedBox(height: CloudDriveUIConfig.spacingM),

          Text(
            fileTypeInfo.category,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: fileTypeInfo.color,
            ),
          ),

          SizedBox(height: CloudDriveUIConfig.spacingXS),

          Text(
            '此文件类型暂不支持预览',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 判断是否为图片
  bool _isImage(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// 判断是否为文本
  bool _isText(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return ['txt', 'md', 'json', 'xml', 'csv', 'log'].contains(extension);
  }

  /// 判断是否为视频
  bool _isVideo(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return [
      'mp4',
      'avi',
      'mov',
      'wmv',
      'flv',
      'mkv',
      'webm',
    ].contains(extension);
  }
}
