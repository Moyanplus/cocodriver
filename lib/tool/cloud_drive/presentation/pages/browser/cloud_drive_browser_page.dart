import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/responsive_utils.dart';
import '../../../core/result.dart';
import '../../../../../core/logging/log_manager.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../base/cloud_drive_service_gateway.dart';
import '../../providers/cloud_drive_provider.dart';
import '../../state/cloud_drive_state_model.dart';
import '../../state/cloud_drive_state_manager.dart';
import '../../widgets/browser/cloud_drive_file_list.dart';
import '../../widgets/browser/cloud_drive_batch_action_bar.dart';
import '../../widgets/browser/cloud_drive_path_navigator.dart';
import '../../widgets/common/snack_bar_helper.dart';
import '../../widgets/sheets/file_operation_bottom_sheet.dart';
import '../../widgets/sheets/create_folder_bottom_sheet.dart';

/// ========================================
/// 云盘文件浏览器页面 - 主文件浏览页面
/// ========================================
/// 功能：云盘文件浏览的主页面
///
/// 页面结构：
/// Scaffold
///   └── Body (Column)
///       ├── CloudDriveAccountSelector (账号选择器)
///       └── Expanded (主内容区)
///           └── Column
///               ├── CloudDrivePathNavigator (路径导航器 - 面包屑导航)
///               └── Expanded(CloudDriveFileList) (文件列表)
///
/// 显示逻辑：
///   1. 无账号 → 显示空状态提示
///   2. 有账号但未选择 → 显示选择账号提示
///   3. 已选择账号 → 显示路径导航器 + 文件列表
/// ========================================
class CloudDriveBrowserPage extends ConsumerStatefulWidget {
  const CloudDriveBrowserPage({super.key});

  @override
  ConsumerState<CloudDriveBrowserPage> createState() =>
      _CloudDriveBrowserPageState();
}

class _CloudDriveBrowserPageState extends ConsumerState<CloudDriveBrowserPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _isLoadMorePending = false;
  double _lastScrollOffset = 0;
  // final CloudDriveBrowserViewModel _viewModel =
  //     const CloudDriveBrowserViewModel();
  ProviderSubscription<CloudDriveState>? _accountSub;

  CloudDriveStateManager get _manager =>
      ref.read(cloudDriveStateManagerProvider.notifier);
  CloudDriveServiceGateway get _gateway => ref.read(cloudDriveGatewayProvider);

  @override
  void initState() {
    super.initState();
    // 监听滚动事件
    _scrollController.addListener(_onScroll);

    // 账号切换后自动加载根目录
    _accountSub = ref.listenManual<CloudDriveState>(cloudDriveProvider, (
      previous,
      next,
    ) {
      final prevId = previous?.currentAccount?.id;
      final nextId = next.currentAccount?.id;
      if (nextId != null && prevId != nextId) {
        _manager.loadFolder(forceRefresh: true);
      }
    });

    // 初次进入，如果已有账号但未加载文件，则拉取根目录
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(cloudDriveProvider);
      final hasAccount = state.currentAccount != null;
      if (hasAccount && state.files.isEmpty && state.folders.isEmpty) {
        _manager.loadFolder(forceRefresh: true);
      }
    });
  }

  /// 展示创建弹窗，处理文件/媒体上传或新建文件夹操作。
  Future<void> _showCreateEntrySheet() async {
    final selectedCreateFolder = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (sheetContext) => SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              decoration: BoxDecoration(
                color: Theme.of(sheetContext).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '创建',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _buildCreateActionButton(
                        icon: Icons.insert_drive_file_rounded,
                        label: '选择文件',
                        onTap: () {
                          Navigator.pop(sheetContext, false);
                          _pickAndUploadFile(type: FileType.any, label: '文件');
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildCreateActionButton(
                        icon: Icons.photo_library_rounded,
                        label: '选择媒体',
                        onTap: () {
                          Navigator.pop(sheetContext, false);
                          _pickAndUploadFile(type: FileType.media, label: '媒体');
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildCreateActionButton(
                        icon: Icons.create_new_folder_rounded,
                        label: '新建文件夹',
                        onTap: () => Navigator.pop(sheetContext, true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );

    if (selectedCreateFolder == true) {
      await _showCreateFolderSheet();
    }
  }

  /// 创建入口按钮（文件/媒体/新建文件夹）通用构建。
  Widget _buildCreateActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _pickAndUploadFile({
    required FileType type,
    required String label,
  }) async {
    final state = ref.read(cloudDriveProvider);
    final account = state.currentAccount;
    final folderId = state.currentFolder?.id ?? '/';
    if (account == null) {
      _showSnack('请先选择账号', success: false);
      return;
    }

    final tempId = 'temp_upload_${DateTime.now().microsecondsSinceEpoch}';
    CloudDriveFile? tempFile;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final file = result.files.first;
      final path = file.path;
      if (path == null) {
        _showSnack('无法获取文件路径', success: false);
        return;
      }
      final now = DateTime.now();
      tempFile = CloudDriveFile(
        id: tempId,
        name: file.name,
        isFolder: false,
        size: file.size,
        createdAt: now,
        updatedAt: now,
        folderId: folderId,
        metadata: {
          'temporary': true,
          'isUploading': true,
          'uploadProgress': 0.0,
        },
      );
      _manager.addFileToState(tempFile);

      _showSnack('正在上传$label：${file.name}');
      final uploadResult = await _gateway.uploadFile(
        account: account,
        filePath: path,
        fileName: file.name,
        folderId: folderId,
        onProgress: (progress) {
          _manager.updateFileMetadata(tempId, (metadata) {
            final map = Map<String, dynamic>.from(metadata ?? {});
            map['uploadProgress'] = progress.clamp(0.0, 1.0);
            map['isUploading'] = true;
            return map;
          });
        },
      );
      final success = uploadResult['success'] == true;
      if (success) {
        final uploadedFile = uploadResult['file'] as CloudDriveFile?;
        _manager.removeFileFromState(tempId);
        if (uploadedFile != null) {
          _manager.addFileToState(uploadedFile);
        } else {
          await _manager.loadFolder(forceRefresh: true);
        }
        _showSnack('$label上传成功');
      } else {
        _manager.removeFileFromState(tempId);
        _showSnack(
          uploadResult['message']?.toString() ?? '$label上传失败',
          success: false,
        );
      }
    } catch (e) {
      if (tempFile != null) {
        _manager.removeFileFromState(tempId);
      }
      _showSnack('$label上传失败: $e', success: false);
    }
  }

  void _showSnack(String message, {bool success = true}) {
    if (!mounted) return;
    SnackBarHelper.show(context, message: message, success: success);
  }

  Future<void> _showCreateFolderSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => CreateFolderBottomSheet(
            onSubmit: (name) async {
              final currentState = ref.read(cloudDriveProvider);
              final currentAccount = currentState.currentAccount;
              final currentFolderId = currentState.currentFolder?.id ?? '/';
              if (currentAccount == null) {
                return '请选择账号';
              }
              try {
                final created = await _manager.createFolder(
                  name: name,
                  parentId: currentFolderId,
                );
                return created ? null : '文件夹创建失败';
              } on CloudDriveException catch (e) {
                return e.message;
              } catch (e) {
                return '文件夹创建失败: $e';
              }
            },
          ),
    );

    if (!mounted || result != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('文件夹创建成功'),
        backgroundColor: Colors.green,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _accountSub?.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final delta = offset - _lastScrollOffset;
    final scrollingDown = delta > 5;
    final scrollingUp = delta < -5;

    LogManager().cloudDrive(
      '[CloudDriveBrowser] offset=$offset, delta=$delta, down=$scrollingDown, up=$scrollingUp',
    );

    bool showButton = _showScrollToTop;
    if (scrollingDown && offset > 200) {
      showButton = true;
    } else if (scrollingUp || offset <= 100) {
      showButton = false;
    }

    if (showButton != _showScrollToTop) {
      LogManager().cloudDrive(
        '[CloudDriveBrowser] 切换FAB: showScrollToTop=$showButton (old=$_showScrollToTop)',
      );
      setState(() {
        _showScrollToTop = showButton;
      });
    }
    _lastScrollOffset = offset;

    final position = _scrollController.position;
    final isNearBottom = position.maxScrollExtent - offset <= 200;
    if (isNearBottom && !_isLoadMorePending) {
      final state = ref.read(cloudDriveProvider);
      if (!state.hasMoreData || state.isLoadingMore) {
        return;
      }
      _isLoadMorePending = true;
      _manager.loadMore().whenComplete(() {
        _isLoadMorePending = false;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cloudDriveProvider);

    return Scaffold(
      backgroundColor: CloudDriveUIConfig.backgroundColor,
      // body: _buildBody(state),
      bottomNavigationBar:
          state.isBatchMode ? const CloudDriveBatchActionBar() : null,
      floatingActionButton: _buildFloatingActionButton(state),
    );
  }

  /// 构建主体内容
  // Widget _buildBody(CloudDriveState state) {
  //   final bodyType = _viewModel.resolveBody(state);
  //   return Column(
  //     children: [
  //       const CloudDriveAccountSelector(),
  //       Expanded(
  //         child: AnimatedSwitcher(
  //           duration: const Duration(milliseconds: 250),
  //           switchInCurve: Curves.easeOut,
  //           switchOutCurve: Curves.easeIn,
  //           child: _buildMainContent(state, bodyType),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  /// 构建主要内容
  // Widget _buildMainContent(
  //   CloudDriveState state,
  //   CloudDriveBrowserBodyType bodyType,
  // ) {
  //   switch (bodyType) {
  //     case CloudDriveBrowserBodyType.noAccount:
  //       return _buildEmptyState(key: const ValueKey('no-accounts'));
  //     case CloudDriveBrowserBodyType.selectAccount:
  //       return _buildNoAccountSelectedState(
  //         key: const ValueKey('select-account'),
  //       );
  //     case CloudDriveBrowserBodyType.content:
  //       return _buildContent(state);
  //   }
  // }

  Widget _buildContent(CloudDriveState state) {
    // ========== 正常显示：路径导航器 + 文件列表 ==========
    // 布局结构：
    // Column (紧凑布局，无多余间距)
    //   ├── CloudDrivePathNavigator (路径导航器 - 显示面包屑导航)
    //   └── Expanded(CloudDriveFileList) (文件列表 - 占据剩余空间，无上边距)
    final supportsLoadMore =
        state.currentAccount?.type == CloudDriveType.lanzou;

    return Column(
      key: ValueKey(
        'content-${state.currentAccount?.id}-${state.currentFolder?.id}',
      ),
      // 【重要】设置为 min 避免 Column 占用多余空间
      mainAxisSize: MainAxisSize.min,
      // 【重要】设置为 stretch 让子组件填满宽度
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 【新增】路径导航器 - 显示当前路径（例如：根目录 或 返回上级 > 文件夹1 > 文件夹2）
        const CloudDrivePathNavigator(),
        // 文件列表 - 使用 Expanded 让它占满剩余空间（紧贴路径导航器，无间隙）
        Expanded(
          child: CloudDriveFileList(
            scrollController: _scrollController,
            state: state,
            account: state.currentAccount!,
            onRefresh: () => _manager.loadFolder(forceRefresh: true),
            onFolderTap: _manager.enterFolder,
            onFileTap: (file) => _showFileOptions(file, state.currentAccount!),
            onLongPress: _manager.enterBatchMode,
            onToggleSelection: _manager.toggleSelection,
            onLoadMore: supportsLoadMore ? _manager.loadMore : null,
          ),
        ),
      ],
    );
  }

  /// 构建空状态
  Widget _buildEmptyState({Key? key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: ResponsiveUtils.getIconSize(80.sp),
            color: CloudDriveUIConfig.secondaryTextColor,
          ),
          SizedBox(height: ResponsiveUtils.getSpacing() * 1.5),
          Text(
            '暂无云盘账号',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(18.sp),
              fontWeight: FontWeight.bold,
              color: CloudDriveUIConfig.secondaryTextColor,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing() * 0.5),
          Text(
            '点击右上角按钮添加您的第一个云盘账号',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
              color: CloudDriveUIConfig.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getSpacing() * 2),
          ElevatedButton.icon(
            onPressed: () {
              // 添加账号功能由主应用工具栏处理
            },
            icon: Icon(Icons.add, size: ResponsiveUtils.getIconSize(20.sp)),
            label: const Text('添加账号'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CloudDriveUIConfig.primaryActionColor,
              foregroundColor: Colors.white,
              padding: ResponsiveUtils.getResponsivePadding(
                horizontal: 24.w,
                vertical: 12.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建未选择账号状态
  Widget _buildNoAccountSelectedState({Key? key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: ResponsiveUtils.getIconSize(80.sp),
            color: CloudDriveUIConfig.secondaryTextColor,
          ),
          SizedBox(height: ResponsiveUtils.getSpacing() * 1.5),
          Text(
            '请选择云盘账号',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(18.sp),
              fontWeight: FontWeight.bold,
              color: CloudDriveUIConfig.secondaryTextColor,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing() * 0.5),
          Text(
            '点击右上角账号图标选择要浏览的云盘账号',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
              color: CloudDriveUIConfig.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getSpacing() * 2),
          ElevatedButton.icon(
            onPressed: () {
              // 账号选择功能由主应用工具栏处理
            },
            icon: Icon(
              Icons.account_circle,
              size: ResponsiveUtils.getIconSize(20.sp),
            ),
            label: const Text('选择账号'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CloudDriveUIConfig.primaryActionColor,
              foregroundColor: Colors.white,
              padding: ResponsiveUtils.getResponsivePadding(
                horizontal: 24.w,
                vertical: 12.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建悬浮按钮
  Widget? _buildFloatingActionButton(CloudDriveState state) {
    if (state.isBatchMode) {
      return null;
    }

    Widget fab;
    if (state.pendingOperationFile != null &&
        state.pendingOperationType != null) {
      final isMove = state.pendingOperationType == 'move';
      fab = FloatingActionButton.extended(
        key: const ValueKey('fab-operation'),
        onPressed: () async {
          try {
            final opResult = await _manager.executePendingOperation();
            final success = opResult == true;
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? (isMove ? '文件移动成功' : '文件复制成功')
                      : (isMove ? '文件移动失败' : '文件复制失败'),
                ),
                backgroundColor:
                    success
                        ? Colors.green
                        : Theme.of(context).colorScheme.error,
              ),
            );
          } on CloudDriveException catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: Icon(isMove ? Icons.drive_file_move : Icons.file_copy),
        label: Text(isMove ? '移动到此处' : '复制到此处'),
      );
    } else if (_showScrollToTop) {
      fab = FloatingActionButton(
        key: const ValueKey('fab-scroll'),
        onPressed: _scrollToTop,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.arrow_upward),
      );
    } else {
      fab = FloatingActionButton(
        key: const ValueKey('fab-add'),
        onPressed: _showCreateEntrySheet,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder:
          (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
      child: fab,
    );
  }

  // 显示文件操作选项
  void _showFileOptions(CloudDriveFile file, CloudDriveAccount? account) {
    if (account == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('账号信息不可用')));
      return;
    }

    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(context),
                  child: Container(color: Colors.black.withOpacity(0.2)),
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.5,
                maxChildSize: 0.9,
                builder:
                    (context, scrollController) => GestureDetector(
                      behavior: HitTestBehavior.deferToChild,
                      onTap: () {},
                      child: FileOperationBottomSheet(
                        file: file,
                        account: account,
                        onClose: () => Navigator.pop(context),
                        onOperationResult: (message, isSuccess) {
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor:
                                  isSuccess ? Colors.green : Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                      ),
                    ),
              ),
            ],
          ),
    );
  }
}
