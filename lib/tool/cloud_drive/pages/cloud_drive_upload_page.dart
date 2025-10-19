import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/logging/log_manager.dart';
import '../config/cloud_drive_ui_config.dart';
import '../models/cloud_drive_models.dart';
import '../widgets/upload/upload.dart';

/// 云盘文件上传页面 - 重构版本
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('上传文件'),
        backgroundColor: CloudDriveUIConfig.primaryActionColor,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedFiles.isNotEmpty && !_isUploading)
            TextButton(
              onPressed: _startUpload,
              child: Text(
                '开始上传',
                style: TextStyle(color: CloudDriveUIConfig.backgroundColor),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 头部信息
          UploadHeader(account: widget.account, folderName: widget.folderName),

          // 主要内容
          Expanded(
            child:
                _isUploading
                    ? UploadProgress(
                      progress: _uploadProgress,
                      currentFile: _currentUploadingFile,
                      isUploading: _isUploading,
                    )
                    : _selectedFiles.isEmpty
                    ? FileSelector(onPickFiles: _pickFiles)
                    : FileList(
                      files: _selectedFiles,
                      onRemoveFile: _removeFile,
                    ),
          ),
        ],
      ),
    );
  }

  /// 选择文件
  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });

        LogManager().cloudDrive('选择了 ${result.files.length} 个文件');
      }
    } catch (e) {
      LogManager().error('选择文件失败: $e');
      _showError('选择文件失败: $e');
    }
  }

  /// 移除文件
  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles.remove(file);
    });
  }

  /// 开始上传
  Future<void> _startUpload() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _currentUploadingFile = '';
    });

    try {
      LogManager().cloudDrive('开始上传 ${_selectedFiles.length} 个文件');

      for (int i = 0; i < _selectedFiles.length; i++) {
        final file = _selectedFiles[i];
        _currentUploadingFile = file.name;

        setState(() {
          _uploadProgress = i / _selectedFiles.length;
        });

        // 模拟上传过程
        await _uploadFile(file);
      }

      setState(() {
        _uploadProgress = 1.0;
        _isUploading = false;
      });

      _showSuccess('所有文件上传完成');

      // 延迟返回上一页
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      LogManager().error('上传失败: $e');
      setState(() {
        _isUploading = false;
      });
      _showError('上传失败: $e');
    }
  }

  /// 上传单个文件
  Future<void> _uploadFile(PlatformFile file) async {
    try {
      // TODO: 实现实际的上传逻辑
      // 这里使用模拟上传
      await Future.delayed(Duration(seconds: 2));

      LogManager().cloudDrive('文件上传完成: ${file.name}');
    } catch (e) {
      LogManager().error('文件上传失败: ${file.name}, 错误: $e');
      rethrow;
    }
  }

  /// 显示成功提示
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: CloudDriveUIConfig.successColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 显示错误提示
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: CloudDriveUIConfig.errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
