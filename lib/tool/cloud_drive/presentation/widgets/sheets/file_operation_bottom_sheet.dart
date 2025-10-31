import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../base/cloud_drive_file_service.dart';
import '../../../base/cloud_drive_operation_service.dart';
import '../../../data/cache/file_list_cache.dart'; // 导入缓存管理器
import '../operation/operation.dart';
import '../file_detail/file_detail.dart';
import '../../../../../../core/logging/log_manager.dart';
import '../authenticated_network_image.dart';
import '../../../utils/file_type_utils.dart';
import '../../providers/cloud_drive_provider.dart';

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
  // 【已移除】_fileDetail - UI不需要此数据

  @override
  void initState() {
    super.initState();
    // 【优化】移除不必要的文件详情加载
    // UI不需要账号详情信息，只需要文件本身的属性
    // _loadFileDetail();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部标题栏
          _buildHeader(),

          // 可滚动内容区域
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 文件信息区域
                  FileInfoSection(file: widget.file, fileDetail: null),

                  // 操作按钮区域
                  _buildOperationButtons(),

                  // 底部间距（安全区域）
                  SizedBox(height: CloudDriveUIConfig.spacingL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建文件图标或缩略图
  Widget _buildFileIcon() {
    final iconSize = 28.0;
    final containerSize = iconSize + (CloudDriveUIConfig.spacingS * 2);

    // 文件夹始终显示图标
    if (widget.file.isFolder) {
      return Container(
        width: containerSize,
        height: containerSize,
        padding: EdgeInsets.all(CloudDriveUIConfig.spacingS),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.folder_rounded, size: iconSize, color: Colors.orange),
      );
    }

    // 文件有预览图时显示图片（可点击查看大图）
    if (widget.file.thumbnailUrl != null &&
        widget.file.thumbnailUrl!.isNotEmpty) {
      return GestureDetector(
        onTap: () => _showThumbnailViewer(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: containerSize,
            height: containerSize,
            child: AuthenticatedNetworkImage(
              imageUrl: widget.file.thumbnailUrl!,
              account: widget.account,
              fit: BoxFit.cover,
              placeholderBuilder: () => _buildDefaultFileIcon(iconSize),
              errorBuilder: () => _buildDefaultFileIcon(iconSize),
            ),
          ),
        ),
      );
    }

    // 没有预览图时显示默认图标
    return _buildDefaultFileIcon(iconSize);
  }

  /// 构建默认文件图标
  Widget _buildDefaultFileIcon(double iconSize) {
    final containerSize = iconSize + (CloudDriveUIConfig.spacingS * 2);

    return Container(
      width: containerSize,
      height: containerSize,
      padding: EdgeInsets.all(CloudDriveUIConfig.spacingS),
      decoration: BoxDecoration(
        color: FileTypeUtils.getFileTypeColor(
          widget.file.name,
        ).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        FileTypeUtils.getFileTypeIcon(widget.file.name),
        size: iconSize,
        color: FileTypeUtils.getFileTypeColor(widget.file.name),
      ),
    );
  }

  /// 显示缩略图查看器（点击缩略图时）
  void _showThumbnailViewer(BuildContext context) {
    // 优先使用大缩略图，如果没有则使用小缩略图
    final imageUrl = widget.file.bigThumbnailUrl ?? widget.file.thumbnailUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => _ImageViewer(
              imageUrl: imageUrl,
              fileName: widget.file.name,
              account: widget.account,
            ),
        fullscreenDialog: true,
      ),
    );
  }

  /// 显示预览查看器（点击预览按钮时）
  void _showPreviewViewer(BuildContext context) {
    if (widget.file.previewUrl == null || widget.file.previewUrl!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('该文件暂无预览')));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => _ImageViewer(
              imageUrl: widget.file.previewUrl!,
              fileName: widget.file.name,
              account: widget.account,
            ),
        fullscreenDialog: true,
      ),
    );
  }

  /// 构建预览按钮
  Widget _buildPreviewButton(ThemeData theme) {
    final hasPreview =
        widget.file.previewUrl != null && widget.file.previewUrl!.isNotEmpty;

    return IconButton(
      icon: Icon(
        hasPreview ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
        color:
            hasPreview
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
      onPressed: () => _showPreviewViewer(context),
      tooltip: hasPreview ? '预览文件' : '暂无预览',
      padding: EdgeInsets.all(8),
      constraints: BoxConstraints(),
    );
  }

  /// 构建顶部标题栏
  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 拖动手柄
        Padding(
          padding: EdgeInsets.only(top: CloudDriveUIConfig.spacingM),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        SizedBox(height: CloudDriveUIConfig.spacingM),

        // 标题内容
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: CloudDriveUIConfig.spacingM,
          ),
          child: Row(
            children: [
              // 文件图标或缩略图（圆角容器）
              _buildFileIcon(),

              SizedBox(width: CloudDriveUIConfig.spacingM),

              // 文件名和大小（可点击重命名）
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: widget.file.isFolder ? null : _renameFile,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                widget.file.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!widget.file.isFolder) ...[
                              SizedBox(width: 4),
                              Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.file.formattedSize,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // 预览按钮（仅在有缩略图时显示）
              if (widget.file.thumbnailUrl != null &&
                  widget.file.thumbnailUrl!.isNotEmpty)
                _buildPreviewButton(theme),
            ],
          ),
        ),

        SizedBox(height: CloudDriveUIConfig.spacingM),
      ],
    );
  }

  /// 构建操作按钮区域
  Widget _buildOperationButtons() {
    return Padding(
      padding: EdgeInsets.all(CloudDriveUIConfig.spacingM),
      child: OperationButtons(
        file: widget.file,
        account: widget.account,
        isLoading: _isLoading,
        loadingMessage: _loadingMessage,
        onDownload: _downloadFile,
        onHighSpeedDownload: _highSpeedDownload,
        onShare: _shareFile,
        onCopy: _copyFile,
        onRename: null, // 重命名功能已整合到文件名点击
        onMove: _moveFile,
        onDelete: _deleteFile,
        onFileDetail: null, // 不再需要详情按钮
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

  /// 下载文件
  Future<void> _downloadFile() async {
    try {
      LogManager().cloudDrive('开始下载文件: ${widget.file.name}');

      // 调用批量下载服务（支持单个文件）
      await CloudDriveFileService.batchDownloadFiles(
        account: widget.account,
        files: [widget.file],
        folders: [],
      );

      if (!mounted) return;

      LogManager().cloudDrive('下载任务创建成功: ${widget.file.name}');
      widget.onOperationResult?.call('下载任务已创建', true);
      widget.onClose?.call();
    } catch (e) {
      LogManager().error('下载异常: $e');

      if (!mounted) return;

      widget.onOperationResult?.call('下载失败: $e', false);
    }
  }

  /// 高速下载
  Future<void> _highSpeedDownload() async {
    try {
      LogManager().cloudDrive('开始高速下载: ${widget.file.name}');

      // TODO: 高速下载功能暂未实现，暂时使用普通下载
      LogManager().cloudDrive('高速下载功能暂未实现，使用普通下载');

      // 调用批量下载服务
      await CloudDriveFileService.batchDownloadFiles(
        account: widget.account,
        files: [widget.file],
        folders: [],
      );

      if (!mounted) return;

      LogManager().cloudDrive('下载任务创建成功: ${widget.file.name}');
      widget.onOperationResult?.call('下载任务已创建（高速下载功能待开发）', true);
      widget.onClose?.call();
    } catch (e) {
      LogManager().error('下载异常: $e');

      if (!mounted) return;

      widget.onOperationResult?.call('下载失败: $e', false);
    }
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
  Future<void> _executeShareOperation(String? password, int expireDays) async {
    try {
      LogManager().cloudDrive('开始创建分享链接: ${widget.file.name}');

      // 调用统一的操作服务接口（自动根据云盘类型选择对应的实现）
      final shareUrl = await CloudDriveOperationService.createShareLink(
        account: widget.account,
        files: [widget.file],
        password: password,
        expireDays: expireDays,
      );

      if (!mounted) return;

      if (shareUrl != null && shareUrl.isNotEmpty) {
        LogManager().cloudDrive('分享链接创建成功: $shareUrl');

        // 显示分享结果
        showDialog(
          context: context,
          builder:
              (context) => ShareResultDialog(
                shareUrl: shareUrl,
                password: password,
                onClose: () => Navigator.of(context).pop(),
              ),
        );

        widget.onOperationResult?.call('分享链接创建成功', true);
      } else {
        LogManager().cloudDrive('分享链接创建失败');
        widget.onOperationResult?.call('分享链接创建失败', false);
      }
    } catch (e) {
      LogManager().error('分享异常: $e');

      if (!mounted) return;

      widget.onOperationResult?.call('分享链接创建失败: $e', false);
    }
  }

  /// 复制文件
  void _copyFile() {
    // 设置待操作文件为复制模式
    ref
        .read(cloudDriveEventHandlerProvider)
        .setPendingOperation(widget.file, 'copy');

    // 关闭弹窗
    widget.onClose?.call();

    // 显示提示
    widget.onOperationResult?.call('请选择目标文件夹，然后点击底部按钮完成复制', true);
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
  Future<void> _executeRenameOperation(String newName) async {
    LogManager().cloudDrive('开始重命名文件: ${widget.file.name} -> $newName');

    // 【优化】乐观更新：先更新UI，再执行实际操作
    // 1. 先更新本地状态（立即生效）
    ref
        .read(cloudDriveEventHandlerProvider)
        .updateFileInState(widget.file.id, newName);

    // 2. 保存回调引用（在 try 外部，确保 catch 能访问）
    final onClose = widget.onClose;
    final onOperationResult = widget.onOperationResult;
    final account = widget.account;
    final file = widget.file;

    // 3. 立即关闭弹窗
    onClose?.call();
    onOperationResult?.call('正在重命名...', true);

    try {
      // 4. 后台执行实际操作
      final success = await CloudDriveFileService.renameFile(
        account: account,
        file: file,
        newName: newName,
      );

      if (success) {
        LogManager().cloudDrive('重命名成功: ${file.name} -> $newName');

        // 【优化】更新缓存中的文件名
        FileListCacheManager().updateFileInCache(
          account.id,
          file.folderId ?? '/',
          file.id,
          newName,
        );

        onOperationResult?.call('文件重命名成功', true);
      } else {
        LogManager().cloudDrive('重命名失败，需要回滚');
        // 失败时回滚 - 但此时 ref 可能已失效，通过回调通知父组件刷新
        onOperationResult?.call('文件重命名失败，请刷新页面', false);
      }
    } catch (e) {
      LogManager().error('重命名异常: $e');
      onOperationResult?.call('文件重命名失败: $e', false);
    }
  }

  /// 移动文件
  void _moveFile() {
    // 设置待操作文件为移动模式
    ref
        .read(cloudDriveEventHandlerProvider)
        .setPendingOperation(widget.file, 'move');

    // 关闭弹窗
    widget.onClose?.call();

    // 显示提示
    widget.onOperationResult?.call('请选择目标文件夹，然后点击底部按钮完成移动', true);
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
  Future<void> _executeDeleteOperation() async {
    LogManager().cloudDrive('开始删除文件: ${widget.file.name}');

    // 【优化】乐观更新：先更新UI，再执行实际操作
    // 1. 先从本地状态移除文件（立即生效）
    if (widget.file.isFolder) {
      ref
          .read(cloudDriveEventHandlerProvider)
          .removeFolderFromState(widget.file.id);
    } else {
      ref
          .read(cloudDriveEventHandlerProvider)
          .removeFileFromState(widget.file.id);
    }

    // 2. 保存回调引用（在 try 外部，确保 catch 能访问）
    final onClose = widget.onClose;
    final onOperationResult = widget.onOperationResult;
    final account = widget.account;
    final file = widget.file;

    // 3. 立即关闭弹窗
    onClose?.call();
    onOperationResult?.call('正在删除...', true);

    try {
      // 4. 后台执行实际操作
      final success = await CloudDriveFileService.deleteFile(
        account: account,
        file: file,
      );

      if (success) {
        LogManager().cloudDrive('删除成功: ${file.name}');

        // 【优化】从缓存中移除该文件
        FileListCacheManager().removeFileFromCache(
          account.id,
          file.folderId ?? '/',
          file.id,
        );

        onOperationResult?.call('文件删除成功', true);
      } else {
        LogManager().cloudDrive('删除失败，需要回滚');
        // 失败时回滚 - 但此时 ref 可能已失效，通过回调通知父组件刷新
        onOperationResult?.call('文件删除失败，请刷新页面', false);
      }
    } catch (e) {
      LogManager().error('删除异常: $e');
      onOperationResult?.call('文件删除失败: $e', false);
    }
  }
}

/// 图片查看器
/// 全屏查看图片，支持缩放和滑动
class _ImageViewer extends StatefulWidget {
  final String imageUrl;
  final String fileName;
  final CloudDriveAccount account;

  const _ImageViewer({
    required this.imageUrl,
    required this.fileName,
    required this.account,
  });

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.fileName, style: const TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 4.0,
        boundaryMargin: EdgeInsets.all(double.infinity),
        constrained: false,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: AuthenticatedNetworkImage(
              imageUrl: widget.imageUrl,
              account: widget.account,
              fit: BoxFit.contain,
              placeholderBuilder:
                  () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
              errorBuilder:
                  () => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text('图片加载失败', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
