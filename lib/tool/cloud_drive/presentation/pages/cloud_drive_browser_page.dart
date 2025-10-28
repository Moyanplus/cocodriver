import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../config/cloud_drive_ui_config.dart';
import '../providers/cloud_drive_provider.dart';
import '../widgets/cloud_drive_file_list.dart';
import '../widgets/cloud_drive_account_selector.dart';
import '../widgets/cloud_drive_batch_action_bar.dart';
import '../widgets/cloud_drive_path_navigator.dart';

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

  @override
  void initState() {
    super.initState();
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cloudDriveProvider.notifier).loadAccounts();
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
    // 当滚动超过200像素时显示回到顶部按钮
    if (_scrollController.hasClients) {
      final showButton = _scrollController.offset > 200;
      if (showButton != _showScrollToTop) {
        setState(() {
          _showScrollToTop = showButton;
        });
      }
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
      body: _buildBody(state),
      bottomNavigationBar:
          state.isBatchMode ? const CloudDriveBatchActionBar() : null,
      floatingActionButton: _buildFloatingActionButton(state),
    );
  }

  /// 构建主体内容
  Widget _buildBody(dynamic state) {
    return Column(
      children: [
        // ========== 账号选择器 - 在顶部显示 ==========
        // 这是一个横向滚动的账号列表，高度约 130h（含 padding）
        const CloudDriveAccountSelector(),

        // ========== 主要内容区域 - 占据剩余空间 ==========
        // 使用 Expanded 让内容区域自动填充剩余高度，避免出现空白
        Expanded(child: _buildMainContent(state)),
      ],
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(dynamic state) {
    // ========== 条件1：检查是否有账号 ==========
    // 如果没有账号，显示空状态
    if (state.accounts.isEmpty && !state.isLoading) {
      return _buildEmptyState();
    }

    // ========== 条件2：检查是否选择了账号 ==========
    // 如果没有当前账号，显示账号选择提示
    if (state.currentAccount == null && state.accounts.isNotEmpty) {
      return _buildNoAccountSelectedState();
    }

    // ========== 正常显示：路径导航器 + 文件列表 ==========
    // 布局结构：
    // Column (紧凑布局，无多余间距)
    //   ├── CloudDrivePathNavigator (路径导航器 - 显示面包屑导航)
    //   └── Expanded(CloudDriveFileList) (文件列表 - 占据剩余空间，无上边距)
    return Column(
      // 【重要】设置为 min 避免 Column 占用多余空间
      mainAxisSize: MainAxisSize.min,
      // 【重要】设置为 stretch 让子组件填满宽度
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 【新增】路径导航器 - 显示当前路径（例如：📁 根目录 或 返回上级 > 文件夹1 > 文件夹2）
        const CloudDrivePathNavigator(),
        // 文件列表 - 使用 Expanded 让它占满剩余空间（紧贴路径导航器，无间隙）
        Expanded(
          child: CloudDriveFileList(scrollController: _scrollController),
        ),
      ],
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
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
  Widget _buildNoAccountSelectedState() {
    return Center(
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
  Widget? _buildFloatingActionButton(dynamic state) {
    if (state.isBatchMode) {
      return null; // 批量模式下不显示悬浮按钮
    }

    // 如果正在滚动，显示回到顶部按钮
    if (_showScrollToTop) {
      return FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.arrow_upward),
      );
    }

    // 默认显示添加账号按钮
    return FloatingActionButton(
      onPressed: () {
        // 添加账号功能由主应用工具栏处理
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }
}
