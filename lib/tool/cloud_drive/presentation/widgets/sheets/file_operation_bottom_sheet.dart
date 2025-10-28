import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../base/cloud_drive_file_service.dart';
import '../operation/operation.dart';
import '../file_detail/file_detail.dart';
import '../../../../../../core/logging/log_manager.dart';

/// 文件操作和详情底部弹窗
///
/// 整合了文件操作和详情查看功能
/// - 默认显示：快速操作按钮
/// - 可切换到：详细信息视图
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
  bool _showDetailView = false; // 是否显示详情视图
  Map<String, dynamic>? _fileDetail;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 顶部标题栏（带切换按钮）
        _buildHeader(),

        // 主要内容区域
        if (_showDetailView)
          _buildDetailView()
        else
          _buildOperationView(),
      ],
    );
  }

  /// 构建顶部标题栏
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CloudDriveUIConfig.spacingM,
        vertical: CloudDriveUIConfig.spacingS,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 返回按钮（仅在详情视图显示）
          if (_showDetailView)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _showDetailView = false;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (_showDetailView) SizedBox(width: CloudDriveUIConfig.spacingS),

          // 标题
          Expanded(
            child: Text(
              _showDetailView ? '文件详情' : '文件操作',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 切换按钮
          if (!_showDetailView)
            TextButton.icon(
              onPressed: _showFileDetail,
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('详情'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: CloudDriveUIConfig.spacingS,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建操作视图
  Widget _buildOperationView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 文件信息显示
        FileInfoDisplay(
          file: widget.file,
          onTap: _showFileDetail,
        ),

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

        SizedBox(height: CloudDriveUIConfig.spacingM),
      ],
    );
  }

  /// 构建详情视图
  Widget _buildDetailView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 文件信息区域
          FileInfoSection(
            file: widget.file,
            fileDetail: _fileDetail,
          ),

          // 预览区域（如果适用）
          if (_shouldShowPreview())
            PreviewSection(
              file: widget.file,
              fileDetail: _fileDetail,
            ),

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
          SizedBox(height: CloudDriveUIConfig.spacingL),
        ],
      ),
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

  /// 是否应该显示预览
  bool _shouldShowPreview() {
    final ext = widget.file.name.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'mp4', 'pdf'].contains(ext);
  }

  /// 显示文件详情
  void _showFileDetail() {
    setState(() {
      _showDetailView = true;
    });
    _loadFileDetail();
  }

  /// 加载文件详情
  Future<void> _loadFileDetail() async {
    if (_fileDetail != null) return; // 已加载过

    try {
      setState(() {
        _isLoading = true;
        _loadingMessage = '正在加载文件详情...';
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
          _loadingMessage = null;
        });

        LogManager().cloudDrive('✅ 文件详情加载成功');
      }
    } catch (e) {
      LogManager().error('❌ 加载文件详情失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载文件详情失败: $e'),
            backgroundColor: CloudDriveUIConfig.errorColor,
          ),
        );
      }
    }
  }

  /// 下载文件
  void _downloadFile() {
    setState(() {
      _isLoading = true;
      _loadingMessage = '正在准备下载...';
    });

    // TODO: 实现下载逻辑
    Future.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
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
      if (!mounted) return;
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
      if (!mounted) return;
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
      if (!mounted) return;
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
      if (!mounted) return;
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
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });
      widget.onOperationResult?.call('文件删除成功', true);
      widget.onClose?.call();
    });
  }
}
