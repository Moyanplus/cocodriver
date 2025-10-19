import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/logging/log_manager.dart';
import '../utils/cloud_drive_ui_utils.dart';
import '../business/cloud_drive_business_service.dart';
import '../models/cloud_drive_models.dart';

/// 云盘文件上传页面
class CloudDriveUploadPage extends StatefulWidget {
  final CloudDriveAccount account;
  final String folderId;
  final String folderName;

  const CloudDriveUploadPage({
    super.key,
    required this.account,
    required this.folderId,
    required this.folderName,
  });

  @override
  State<CloudDriveUploadPage> createState() => _CloudDriveUploadPageState();
}

class _CloudDriveUploadPageState extends State<CloudDriveUploadPage> {
  List<PlatformFile> _selectedFiles = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _currentUploadingFile = '';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('上传文件'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      actions: [
        if (_selectedFiles.isNotEmpty && !_isUploading)
          TextButton(
            onPressed: _startUpload,
            child: const Text('开始上传', style: TextStyle(color: Colors.white)),
          ),
      ],
    ),
    body: Column(
      children: [
        // 目标文件夹信息
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.folder, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '上传到: ${widget.folderName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.account.type.displayName} - ${widget.account.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 文件选择区域
        if (!_isUploading)
          Expanded(
            child:
                _selectedFiles.isEmpty ? _buildEmptyState() : _buildFileList(),
          ),

        // 上传进度
        if (_isUploading) _buildUploadProgress(),
      ],
    ),
  );

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload,
          size: 64,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          '选择要上传的文件',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '支持各种类型的文件',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.file_upload),
          label: const Text('选择文件'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    ),
  );

  Widget _buildFileList() => Column(
    children: [
      // 文件列表
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _selectedFiles.length,
          itemBuilder: (context, index) {
            final file = _selectedFiles[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CloudDriveUIUtils.buildFileTypeIcon(
                  file.extension ?? '',
                  size: 24,
                ),
                title: Text(
                  file.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  _formatFileSize(file.size),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () => _removeFile(index),
                  icon: const Icon(Icons.close),
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          },
        ),
      ),

      // 底部操作按钮
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.add),
                label: const Text('添加更多文件'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _startUpload,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('开始上传'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildUploadProgress() => Expanded(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(value: _uploadProgress, strokeWidth: 4),
          const SizedBox(height: 16),
          Text(
            '正在上传: $_currentUploadingFile',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_uploadProgress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });

        LogManager().cloudDrive('📁 选择了 ${result.files.length} 个文件');
        for (final file in result.files) {
          LogManager().cloudDrive(
            '📄 文件: ${file.name} (${_formatFileSize(file.size)})',
          );
        }
      }
    } catch (e) {
      LogManager().error('❌ 选择文件失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择文件失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _startUpload() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // 验证上传权限
      final validation =
          await CloudDriveBusinessService.validateUploadPermission(
            account: widget.account,
            folderId: widget.folderId,
          );

      if (!validation.isValid) {
        CloudDriveUIUtils.showErrorMessage(context, validation.message);
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // 准备文件路径和文件名列表
      final filePaths = _selectedFiles.map((file) => file.path!).toList();
      final fileNames = _selectedFiles.map((file) => file.name).toList();

      // 使用业务服务进行批量上传
      final result = await CloudDriveBusinessService.uploadMultipleFiles(
        account: widget.account,
        filePaths: filePaths,
        fileNames: fileNames,
        folderId: widget.folderId,
        onProgress: (current, total, fileName) {
          setState(() {
            _currentUploadingFile = fileName;
            _uploadProgress = (current - 1) / total; // 调整进度计算
          });
        },
      );

      // 更新最终状态
      setState(() {
        _isUploading = false;
        _uploadProgress = 1.0;
      });

      if (mounted) {
        _showUploadResult(result);
      }
    } catch (e) {
      LogManager().error('❌ 上传过程异常: $e');
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        _showErrorMessage('上传过程异常: $e');
      }
    }
  }

  /// 显示上传结果
  void _showUploadResult(UploadBatchResult result) {
    if (result.isSuccess) {
      CloudDriveUIUtils.showSuccessMessage(context, result.summaryMessage);
    } else if (result.hasPartialSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.summaryMessage),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: '查看详情',
            textColor: Colors.white,
            onPressed: () => _showDetailedResults(result),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.summaryMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: '查看详情',
            textColor: Colors.white,
            onPressed: () => _showDetailedResults(result),
          ),
        ),
      );
    }

    // 如果有成功上传的文件，返回上一页
    if (result.successCount > 0) {
      Navigator.pop(context, true);
    }
  }

  /// 显示详细结果
  void _showDetailedResults(UploadBatchResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('上传结果详情'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('总计: ${result.totalCount} 个文件'),
                  Text('成功: ${result.successCount} 个'),
                  Text('失败: ${result.failCount} 个'),
                  const SizedBox(height: 16),
                  if (result.results.isNotEmpty) ...[
                    const Text(
                      '详细信息:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: result.results.length,
                        itemBuilder: (context, index) {
                          final item = result.results[index];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              item.success ? Icons.check_circle : Icons.error,
                              color: item.success ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            title: Text(
                              item.fileName,
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle:
                                item.success
                                    ? null
                                    : Text(
                                      item.message,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
    );
  }

  /// 显示错误消息
  void _showErrorMessage(String message) {
    CloudDriveUIUtils.showErrorMessage(context, message);
  }

  String _formatFileSize(int bytes) {
    return CloudDriveBusinessService.formatFileSize(bytes);
  }

  Color _getFileTypeColor(String extension) {
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
        return Colors.teal;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getFileTypeIcon(String extension) {
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
        return Icons.audio_file;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }
}
