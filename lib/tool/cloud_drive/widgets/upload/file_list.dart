import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../config/cloud_drive_ui_config.dart';

/// 文件列表组件
class FileList extends StatelessWidget {
  final List<PlatformFile> files;
  final Function(PlatformFile) onRemoveFile;

  const FileList({super.key, required this.files, required this.onRemoveFile});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: CloudDriveUIConfig.pagePadding,
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return _buildFileItem(context, file);
      },
    );
  }

  /// 构建文件项
  Widget _buildFileItem(BuildContext context, PlatformFile file) {
    return Card(
      margin: EdgeInsets.only(bottom: CloudDriveUIConfig.spacingS),
      child: ListTile(
        leading: Icon(
          _getFileIcon(file.extension),
          color: _getFileColor(file.extension),
          size: CloudDriveUIConfig.iconSizeL,
        ),
        title: Text(
          file.name,
          style: CloudDriveUIConfig.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _formatFileSize(file.size),
          style: CloudDriveUIConfig.smallTextStyle,
        ),
        trailing: IconButton(
          onPressed: () => onRemoveFile(file),
          icon: const Icon(Icons.remove_circle_outline),
          color: CloudDriveUIConfig.errorColor,
        ),
      ),
    );
  }

  /// 获取文件图标
  IconData _getFileIcon(String? extension) {
    if (extension == null) return Icons.insert_drive_file;

    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audio_file;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// 获取文件颜色
  Color _getFileColor(String? extension) {
    if (extension == null) return CloudDriveUIConfig.secondaryTextColor;

    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Colors.indigo;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Colors.teal;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.brown;
      default:
        return CloudDriveUIConfig.secondaryTextColor;
    }
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
