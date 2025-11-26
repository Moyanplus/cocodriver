import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../config/cloud_drive_ui_config.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../providers/cloud_drive_provider.dart';
import '../state/cloud_drive_state_model.dart';
import '../view_models/cloud_drive_browser_view_model.dart';
import '../widgets/cloud_drive_file_list.dart';
import '../widgets/cloud_drive_account_selector.dart';
import '../widgets/cloud_drive_batch_action_bar.dart';
import '../widgets/cloud_drive_path_navigator.dart';
import '../widgets/sheets/file_operation_bottom_sheet.dart';

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
  final CloudDriveBrowserViewModel _viewModel =
      const CloudDriveBrowserViewModel();

  CloudDriveEventHandler get _eventHandler =>
      ref.read(cloudDriveEventHandlerProvider);

  @override
  void initState() {
    super.initState();
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventHandler.loadAccounts();
    });

    // 监听滚动事件
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final showButton = offset > 200;
    if (showButton != _showScrollToTop) {
      setState(() {
        _showScrollToTop = showButton;
      });
    }

    final position = _scrollController.position;
    final isNearBottom = position.maxScrollExtent - offset <= 200;
    if (isNearBottom && !_isLoadMorePending) {
      final state = ref.read(cloudDriveProvider);
      if (!state.hasMoreData || state.isLoadingMore) {
        return;
      }
      _isLoadMorePending = true;
      _eventHandler.loadMore().whenComplete(() {
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
    final eventHandler = _eventHandler;

    return Scaffold(
      backgroundColor: CloudDriveUIConfig.backgroundColor,
      body: _buildBody(state, eventHandler),
      bottomNavigationBar:
          state.isBatchMode ? const CloudDriveBatchActionBar() : null,
      floatingActionButton: _buildFloatingActionButton(state, eventHandler),
    );
  }

  /// 构建主体内容
  Widget _buildBody(CloudDriveState state, CloudDriveEventHandler handler) {
    final bodyType = _viewModel.resolveBody(state);
    return Column(
      children: [
        const CloudDriveAccountSelector(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _buildMainContent(state, handler, bodyType),
          ),
        ),
      ],
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(
    CloudDriveState state,
    CloudDriveEventHandler handler,
    CloudDriveBrowserBodyType bodyType,
  ) {
    switch (bodyType) {
      case CloudDriveBrowserBodyType.noAccount:
        return _buildEmptyState(key: const ValueKey('no-accounts'));
      case CloudDriveBrowserBodyType.selectAccount:
        return _buildNoAccountSelectedState(key: const ValueKey('select-account'));
      case CloudDriveBrowserBodyType.content:
        return _buildContent(state, handler);
    }
  }

  Widget _buildContent(
    CloudDriveState state,
    CloudDriveEventHandler handler,
  ) {
    // ========== 正常显示：路径导航器 + 文件列表 ==========
    // 布局结构：
    // Column (紧凑布局，无多余间距)
    //   ├── CloudDrivePathNavigator (路径导航器 - 显示面包屑导航)
    //   └── Expanded(CloudDriveFileList) (文件列表 - 占据剩余空间，无上边距)
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
            onRefresh: () => handler.loadFolder(forceRefresh: true),
            onFolderTap: handler.enterFolder,
            onFileTap: (file) => _showFileOptions(file, state.currentAccount),
            onLongPress: handler.enterBatchMode,
            onToggleSelection: handler.toggleSelection,
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
  Widget? _buildFloatingActionButton(
    CloudDriveState state,
    CloudDriveEventHandler handler,
  ) {
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
          await handler.executePendingOperation();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isMove ? '文件移动成功' : '文件复制成功'),
                backgroundColor: Colors.green,
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
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: fab,
    );
  }

  // 显示文件操作选项
  void _showFileOptions(
    CloudDriveFile file,
    CloudDriveAccount? account,
  ) {
    if (account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('账号信息不可用')),
      );
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
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                  ),
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
