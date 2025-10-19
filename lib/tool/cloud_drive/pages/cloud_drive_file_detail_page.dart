import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/logging/log_manager.dart';
import '../config/cloud_drive_ui_config.dart';
import '../models/cloud_drive_models.dart';
import '../widgets/file_detail/file_detail.dart';
import '../base/cloud_drive_file_service.dart';

/// 文件详情页面 - 重构版本
class CloudDriveFileDetailPage extends StatefulWidget {
  final CloudDriveFile file;
  final CloudDriveAccount account;

  const CloudDriveFileDetailPage({
    super.key,
    required this.file,
    required this.account,
  });

  @override
  State<CloudDriveFileDetailPage> createState() =>
      _CloudDriveFileDetailPageState();
}

class _CloudDriveFileDetailPageState extends State<CloudDriveFileDetailPage> {
  Map<String, dynamic>? _fileDetail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFileDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name),
        backgroundColor: CloudDriveUIConfig.primaryActionColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _copyFileId,
            icon: const Icon(Icons.copy),
            tooltip: '复制文件ID',
          ),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingState()
              : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: CloudDriveUIConfig.spacingM),
          Text('正在加载文件详情...', style: CloudDriveUIConfig.bodyTextStyle),
        ],
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: CloudDriveUIConfig.errorColor,
          ),
          SizedBox(height: CloudDriveUIConfig.spacingM),
          Text(
            '加载失败',
            style: CloudDriveUIConfig.titleTextStyle.copyWith(
              color: CloudDriveUIConfig.errorColor,
            ),
          ),
          SizedBox(height: CloudDriveUIConfig.spacingS),
          Text(
            _error!,
            style: CloudDriveUIConfig.bodyTextStyle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: CloudDriveUIConfig.spacingL),
          ElevatedButton(onPressed: _loadFileDetail, child: const Text('重试')),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 文件信息区域
          FileInfoSection(file: widget.file, fileDetail: _fileDetail),

          // 预览区域
          PreviewSection(file: widget.file, fileDetail: _fileDetail),

          // 操作区域
          ActionSection(
            file: widget.file,
            account: widget.account,
            onDownload: _downloadFile,
            onShare: _shareFile,
            onRename: _renameFile,
            onDelete: _deleteFile,
          ),

          // 底部间距
          SizedBox(height: CloudDriveUIConfig.spacingXL),
        ],
      ),
    );
  }

  /// 加载文件详情
  Future<void> _loadFileDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      LogManager().cloudDrive('📄 开始加载文件详情: ${widget.file.name}');

      final detail = await CloudDriveFileService.getFileDetail(
        account: widget.account,
        fileId: widget.file.id,
      );

      if (mounted) {
        setState(() {
          _fileDetail = detail;
          _isLoading = false;
        });

        LogManager().cloudDrive('✅ 文件详情加载成功');
      }
    } catch (e) {
      LogManager().error('❌ 加载文件详情失败: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// 复制文件ID
  void _copyFileId() {
    Clipboard.setData(ClipboardData(text: widget.file.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('文件ID已复制到剪贴板'),
        backgroundColor: CloudDriveUIConfig.successColor,
      ),
    );
  }

  /// 下载文件
  void _downloadFile() {
    // TODO: 实现下载逻辑
    LogManager().cloudDrive('下载文件: ${widget.file.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('开始下载: ${widget.file.name}'),
        backgroundColor: CloudDriveUIConfig.infoColor,
      ),
    );
  }

  /// 分享文件
  void _shareFile() {
    // TODO: 实现分享逻辑
    LogManager().cloudDrive('分享文件: ${widget.file.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('分享文件: ${widget.file.name}'),
        backgroundColor: CloudDriveUIConfig.infoColor,
      ),
    );
  }

  /// 重命名文件
  void _renameFile() {
    // TODO: 实现重命名逻辑
    LogManager().cloudDrive('重命名文件: ${widget.file.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('重命名文件: ${widget.file.name}'),
        backgroundColor: CloudDriveUIConfig.warningColor,
      ),
    );
  }

  /// 删除文件
  void _deleteFile() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除文件 "${widget.file.name}" 吗？此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _executeDelete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CloudDriveUIConfig.errorColor,
                ),
                child: const Text('删除', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  /// 执行删除
  void _executeDelete() {
    // TODO: 实现删除逻辑
    LogManager().cloudDrive('删除文件: ${widget.file.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('文件已删除: ${widget.file.name}'),
        backgroundColor: CloudDriveUIConfig.successColor,
      ),
    );
    Navigator.of(context).pop();
  }
}
