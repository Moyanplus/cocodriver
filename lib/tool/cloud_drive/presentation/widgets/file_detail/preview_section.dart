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

    // 根据文件类型决定是否显示预览
    if (!_canPreview(file.name)) {
      return _buildUnsupportedPreview(context, fileTypeInfo);
    }

    return Container(
      padding: CloudDriveUIConfig.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('预览', style: CloudDriveUIConfig.titleTextStyle),
          SizedBox(height: CloudDriveUIConfig.spacingM),

          Card(
            child: Container(
              width: double.infinity,
              height: 200,
              padding: CloudDriveUIConfig.cardPadding,
              child: _buildPreviewContent(context, fileTypeInfo),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建预览内容
  Widget _buildPreviewContent(BuildContext context, FileTypeInfo fileTypeInfo) {
    if (_isImage(file.name)) {
      return _buildImagePreview();
    } else if (_isText(file.name)) {
      return _buildTextPreview();
    } else {
      return _buildUnsupportedPreview(context, fileTypeInfo);
    }
  }

  /// 构建图片预览
  Widget _buildImagePreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image, size: 64, color: CloudDriveUIConfig.infoColor),
        SizedBox(height: CloudDriveUIConfig.spacingM),
        Text('图片预览', style: CloudDriveUIConfig.bodyTextStyle),
        SizedBox(height: CloudDriveUIConfig.spacingS),
        Text('点击下载查看完整图片', style: CloudDriveUIConfig.smallTextStyle),
      ],
    );
  }

  /// 构建文本预览
  Widget _buildTextPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.text_snippet, size: 64, color: CloudDriveUIConfig.infoColor),
        SizedBox(height: CloudDriveUIConfig.spacingM),
        Text('文本预览', style: CloudDriveUIConfig.bodyTextStyle),
        SizedBox(height: CloudDriveUIConfig.spacingS),
        Text('点击下载查看完整内容', style: CloudDriveUIConfig.smallTextStyle),
      ],
    );
  }

  /// 构建不支持的预览
  Widget _buildUnsupportedPreview(
    BuildContext context,
    FileTypeInfo fileTypeInfo,
  ) {
    return Container(
      padding: CloudDriveUIConfig.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('预览', style: CloudDriveUIConfig.titleTextStyle),
          SizedBox(height: CloudDriveUIConfig.spacingM),

          Card(
            child: Container(
              width: double.infinity,
              height: 200,
              padding: CloudDriveUIConfig.cardPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    fileTypeInfo.iconData,
                    size: 64,
                    color: fileTypeInfo.color,
                  ),
                  SizedBox(height: CloudDriveUIConfig.spacingM),
                  Text('不支持预览', style: CloudDriveUIConfig.bodyTextStyle),
                  SizedBox(height: CloudDriveUIConfig.spacingS),
                  Text(
                    '此文件类型不支持在线预览',
                    style: CloudDriveUIConfig.smallTextStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 判断是否可以预览
  bool _canPreview(String fileName) {
    return _isImage(fileName) || _isText(fileName);
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
}
