import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../download/services/download_config_service.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../base/cloud_drive_service_gateway.dart';
import '../../../data/cache/file_list_cache.dart'; // 导入缓存管理器
import '../../../core/result.dart';
import '../../utils/operation_guard.dart';
import '../operation/operation.dart';
import '../file_detail/file_detail.dart';
import '../../../../../../core/logging/log_manager.dart';
import '../common/authenticated_network_image.dart';
import '../../../utils/file_type_utils.dart';
import '../../providers/cloud_drive_provider.dart';
import '../../../../download/services/download_service.dart';

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
    extends ConsumerState<FileOperationBottomSheet>
    with SingleTickerProviderStateMixin {
  final bool _isLoading = false;
  String? _loadingMessage;
  bool _wasLoading = false;
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final CloudDriveServiceGateway _gateway;
  // 【已移除】_fileDetail - UI不需要此数据

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    _gateway = defaultCloudDriveGateway;
    // 【优化】移除不必要的文件详情加载
    // UI不需要账号详情信息，只需要文件本身的属性
    // _loadFileDetail();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_wasLoading && !_isLoading) {
      _controller.forward(from: 0);
    }
    _wasLoading = _isLoading;

    final child =
        _isLoading
            ? _buildLoadingState(key: const ValueKey('loading'))
            : _buildAnimatedSheet(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: child,
    );
  }

  Widget _buildAnimatedSheet(BuildContext context) {
    if (_controller.status == AnimationStatus.dismissed ||
        _controller.status == AnimationStatus.reverse) {
      _controller.forward();
    }

    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: SlideTransition(
        position: _offsetAnimation,
        child: _buildSheetContent(context),
      ),
    );
  }

  Widget _buildSheetContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FileInfoSection(file: widget.file, fileDetail: null),
                  _buildOperationButtons(),
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
          color: Colors.orange.withValues(alpha: 0.1),
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
        ).withValues(alpha: 0.1),
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
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
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
    final downloadSupported = _isOperationSupported('download');
    final shareSupported = _isOperationSupported('share');
    final copySupported = _isOperationSupported('copy');
    final moveSupported = _isOperationSupported('move');
    final deleteSupported = _isOperationSupported('delete');

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
        downloadEnabled: downloadSupported,
        shareEnabled: shareSupported,
        copyEnabled: copySupported,
        moveEnabled: moveSupported,
        deleteEnabled: deleteSupported,
        onFileDetail: null, // 不再需要详情按钮
      ),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState({Key? key}) {
    return Padding(
      key: key,
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

      final downloadUrl = await _gateway.getDownloadUrl(
        account: widget.account,
        file: widget.file,
      );
      if (downloadUrl == null) {
        throw Exception('无法获取下载链接');
      }
      final config = await DownloadConfigService().loadConfig();
      final resolvedDir = await DownloadService().getValidDownloadDirectory(
        config.downloadDirectory,
      );
      final isExternalStorage = resolvedDir.startsWith('/storage/emulated/0/');
      await DownloadService().createDownloadTask(
        url: downloadUrl,
        fileName: widget.file.name,
        downloadDir: resolvedDir,
        showNotification: config.showNotification,
        openFileFromNotification: config.openFileFromNotification,
        isExternalStorage: isExternalStorage,
        customHeaders: widget.account.authHeaders,
        thumbnailUrl: widget.file.thumbnailUrl,
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

      final downloadUrl = await _gateway.getDownloadUrl(
        account: widget.account,
        file: widget.file,
      );
      if (downloadUrl == null) {
        throw Exception('无法获取下载链接');
      }

      final resolvedDir = await DownloadService().getValidDownloadDirectory(
        (await DownloadConfigService().loadConfig()).downloadDirectory,
      );
      final isExternalStorage = resolvedDir.startsWith('/storage/emulated/0/');

      // TODO: 替换成统一 DownloadService 注入，这里先复用现有批量下载逻辑
      await DownloadService().createDownloadTask(
        url: downloadUrl,
        fileName: widget.file.name,
        downloadDir: resolvedDir,
        showNotification: true,
        openFileFromNotification: false,
        isExternalStorage: isExternalStorage,
        customHeaders: widget.account.authHeaders,
        thumbnailUrl: widget.file.thumbnailUrl,
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

      final shareUrl = await _gateway.createShareLink(
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
    final originalName = widget.file.name;
    final eventHandler = ref.read(cloudDriveEventHandlerProvider);
    final onClose = widget.onClose;
    final onOperationResult = widget.onOperationResult;
    final account = widget.account;
    final file = widget.file;
    final cacheManager = FileListCacheManager();
    final folderId = file.folderId ?? '/';

    onClose?.call();
    onOperationResult?.call('正在重命名...', true);

    try {
      final success = await OperationGuard.run<bool>(
        optimisticUpdate: () {
          eventHandler.updateFileInState(file.id, newName);
        },
        rollback: () {
          eventHandler.updateFileInState(file.id, originalName);
          cacheManager.updateFileInCache(
            account.id,
            folderId,
            file.id,
            originalName,
          );
        },
        action:
            () => _gateway.renameFile(
              account: account,
              file: file,
              newName: newName,
            ),
        rollbackWhen: (result) => !result,
      );

      if (success) {
        LogManager().cloudDrive('重命名成功: ${file.name} -> $newName');
        cacheManager.updateFileInCache(account.id, folderId, file.id, newName);
        onOperationResult?.call('文件重命名成功', true);
      } else {
        LogManager().cloudDrive('重命名失败，需要回滚');
        onOperationResult?.call('文件重命名失败，请刷新页面', false);
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      LogManager().error('重命名异常: $errorMessage');
      onOperationResult?.call('文件重命名失败: $errorMessage', false);
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
    final eventHandler = ref.read(cloudDriveEventHandlerProvider);
    final onClose = widget.onClose;
    final onOperationResult = widget.onOperationResult;
    final account = widget.account;
    final file = widget.file;
    final cacheManager = FileListCacheManager();
    final folderId = file.folderId ?? '/';

    onClose?.call();
    onOperationResult?.call('正在删除...', true);

    try {
      final success = await OperationGuard.run<bool>(
        optimisticUpdate: () {
          if (file.isFolder) {
            eventHandler.removeFolderFromState(file.id);
          } else {
            eventHandler.removeFileFromState(file.id);
          }
        },
        rollback: () {
          eventHandler.addFileToState(file);
          cacheManager.addFileToCache(account.id, folderId, file);
        },
        action: () => _gateway.deleteFile(account: account, file: file),
        rollbackWhen: (result) => !result,
      );

      if (success) {
        LogManager().cloudDrive('删除成功: ${file.name}');
        cacheManager.removeFileFromCache(account.id, folderId, file.id);
        onOperationResult?.call('文件删除成功', true);
      } else {
        LogManager().cloudDrive('删除失败，需要回滚');
        onOperationResult?.call('文件删除失败，请刷新页面', false);
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      LogManager().error('删除异常: $errorMessage');
      onOperationResult?.call('文件删除失败: $errorMessage', false);
    }
  }

  bool _isOperationSupported(String operation) {
    final support = _gateway.getSupportedOperations(widget.account);
    return support[operation] ?? false;
  }

  /// 提取更友好的错误提示，兼容各云盘自定义异常
  String _extractErrorMessage(Object error) {
    if (error is CloudDriveException) {
      return error.message.isNotEmpty
          ? error.message
          : error.userFriendlyMessage;
    }

    final raw = error.toString();
    final separatorIndex = raw.indexOf(':');
    if (separatorIndex == -1) {
      return raw;
    }
    return raw.substring(separatorIndex + 1).trim();
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
        child: SizedBox(
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
