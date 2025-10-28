import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../operation/operation.dart';
import '../../../../../../core/logging/log_manager.dart';

/// 文件操作底部弹窗内容组件
///
/// 用于在底部弹窗中显示文件操作选项
/// 包括：下载、分享、重命名、移动、删除等操作
class FileOperationBottomSheet extends ConsumerStatefulWidget {
  final CloudDriveFile file;
  final CloudDriveAccount account;
  final VoidCallback? onClose;
  final Function(String message, bool isSuccess)? onOperationResult;

  const FileOperationBottomSheet({
    super.key,
    required this.file,
    required this.account,
    this.onClose,
    this.onOperationResult,
  });

  @override
  ConsumerState<FileOperationBottomSheet> createState() =>
      _FileOperationBottomSheetState();
}

class _FileOperationBottomSheetState
    extends ConsumerState<FileOperationBottomSheet> {
  bool _isLoading = false;
  String? _loadingMessage;

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? _buildLoadingState()
        : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 文件信息显示
            FileInfoDisplay(file: widget.file, onTap: _showFileDetail),

            SizedBox(height: CloudDriveUIConfig.spacingM),

            // 操作按钮
            OperationButtons(
              file: widget.file,
              account: widget.account,
              isLoading: _isLoading,
              loadingMessage: _loadingMessage,
              onDownload: _downloadFile,
              onHighSpeedDownload: _highSpeedDownload,
              onShare: _shareFile,
              onCopy: _copyFile,
              onRename: _renameFile,
              onMove: _moveFile,
              onDelete: _deleteFile,
              onFileDetail: _showFileDetail,
            ),
          ],
        );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(CloudDriveUIConfig.spacingM),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: CloudDriveUIConfig.spacingM),
          Text(
            _loadingMessage ?? '正在处理...',
            style: CloudDriveUIConfig.bodyTextStyle,
          ),
        ],
      ),
    );
  }

  /// 显示文件详情
  void _showFileDetail() {
    // TODO: 实现文件详情显示
    LogManager().cloudDrive('显示文件详情: ${widget.file.name}');
  }

  /// 下载文件
  void _downloadFile() {
    setState(() {
      _isLoading = true;
      _loadingMessage = '正在准备下载...';
    });

    // TODO: 实现下载逻辑
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });
      widget.onOperationResult?.call('下载已开始', true);
      widget.onClose?.call();
    });
  }

  /// 高速下载
  void _highSpeedDownload() {
    setState(() {
      _isLoading = true;
      _loadingMessage = '正在获取高速下载链接...';
    });

    // TODO: 实现高速下载逻辑
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });
      widget.onOperationResult?.call('高速下载已开始', true);
      widget.onClose?.call();
    });
  }

  /// 分享文件
  void _shareFile() {
    showDialog(
      context: context,
      builder:
          (context) => ShareDialog(
            fileName: widget.file.name,
            onCancel: () => Navigator.of(context).pop(),
            onConfirm: (password, expireDays) {
              Navigator.of(context).pop();
              _executeShareOperation(password, expireDays);
            },
          ),
    );
  }

  /// 执行分享操作
  void _executeShareOperation(String? password, int expireDays) {
    setState(() {
      _isLoading = true;
      _loadingMessage = '正在创建分享链接...';
    });

    // TODO: 实现分享逻辑
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });

      // 显示分享结果
      showDialog(
        context: context,
        builder:
            (context) => ShareResultDialog(
              shareUrl: 'https://example.com/share/123456',
              password: password,
              onClose: () => Navigator.of(context).pop(),
            ),
      );
    });
  }

  /// 复制文件
  void _copyFile() {
    setState(() {
      _isLoading = true;
      _loadingMessage = '正在复制文件...';
    });

    // TODO: 实现复制逻辑
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });
      widget.onOperationResult?.call('文件复制成功', true);
      widget.onClose?.call();
    });
  }

  /// 重命名文件
  void _renameFile() {
    showDialog(
      context: context,
      builder:
          (context) => RenameDialog(
            currentName: widget.file.name,
            onCancel: () => Navigator.of(context).pop(),
            onConfirm: (newName) {
              Navigator.of(context).pop();
              _executeRenameOperation(newName);
            },
          ),
    );
  }

  /// 执行重命名操作
  void _executeRenameOperation(String newName) {
    setState(() {
      _isLoading = true;
      _loadingMessage = '正在重命名文件...';
    });

    // TODO: 实现重命名逻辑
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });
      widget.onOperationResult?.call('文件重命名成功', true);
      widget.onClose?.call();
    });
  }

  /// 移动文件
  void _moveFile() {
    setState(() {
      _isLoading = true;
      _loadingMessage = '正在移动文件...';
    });

    // TODO: 实现移动逻辑
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });
      widget.onOperationResult?.call('文件移动成功', true);
      widget.onClose?.call();
    });
  }

  /// 删除文件
  void _deleteFile() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('确认删除'),
            content: Text('确定要删除文件 "${widget.file.name}" 吗？此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _executeDeleteOperation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CloudDriveUIConfig.errorColor,
                ),
                child: Text('删除', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  /// 执行删除操作
  void _executeDeleteOperation() {
    setState(() {
      _isLoading = true;
      _loadingMessage = '正在删除文件...';
    });

    // TODO: 实现删除逻辑
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });
      widget.onOperationResult?.call('文件删除成功', true);
      widget.onClose?.call();
    });
  }
}
