/// 主屏幕页面
///
/// 应用程序的主界面，包含底部导航栏和侧边抽屉
/// 负责管理页面导航、云盘功能集成等核心功能
///
/// 主要功能：
/// - 底部导航栏管理
/// - 侧边抽屉导航
/// - 云盘功能集成
/// - 响应式布局适配
/// - 多语言支持
///
/// 使用Riverpod进行状态管理，确保页面状态一致性
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../l10n/app_localizations.dart';

// 核心模块导入
import '../../../core/navigation/navigation_providers.dart';
import '../../../core/utils/responsive_utils.dart';

// 共享组件导入
import '../../../shared/widgets/common/app_drawer_widget.dart';
import '../../../shared/widgets/common/bottom_sheet_widget.dart';

// 云盘功能导入
import '../../../tool/cloud_drive/presentation/providers/cloud_drive_provider.dart';
import '../../../tool/cloud_drive/presentation/widgets/add_account_form_widget.dart';

/// 主屏幕Widget
///
/// 应用程序的主界面组件，使用Riverpod进行状态管理
/// 包含底部导航栏、侧边抽屉和页面内容区域
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

/// MainScreen的状态管理类
///
/// 负责监听导航状态变化，构建主界面的UI结构
/// 包括底部导航栏、侧边抽屉和页面内容的渲染
class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    // 监听页面导航状态
    final pageNavigationState = ref.watch(pageNavigationStateProvider);
    final currentIndex = pageNavigationState.currentIndex;
    final pageController = pageNavigationState.pageController;

    // 获取页面列表和导航提供者
    final pages = ref.watch(pagesProvider);
    final pageNavigation = ref.watch(pageNavigationProvider);

    // 获取本地化文本
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // 如果本地化未加载完成，显示加载指示器
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      drawer: const AppDrawerWidget(), // 侧边抽屉
      body: _buildBodyWithSliverAppBar(
        // 主体内容区域
        pageController,
        pages,
        currentIndex,
        pageNavigation,
        l10n,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(
        // 底部导航栏
        currentIndex,
        pageNavigation,
        l10n,
      ),
      resizeToAvoidBottomInset: false, // 避免键盘弹出时调整布局
    );
  }

  /// 构建带有SliverAppBar的页面内容
  Widget _buildBodyWithSliverAppBar(
    PageController pageController,
    List<Widget> pages,
    int currentIndex,
    PageNavigation pageNavigation,
    AppLocalizations l10n,
  ) => CustomScrollView(
    physics: const ClampingScrollPhysics(),
    slivers: [
      SliverAppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(l10n.appTitle),
        toolbarHeight: ResponsiveUtils.getNavigationBarHeight(context) * 0.8,
        floating: true,
        pinned: false,
        snap: false,
        actions: [
          // 云盘助手页面的图标按钮
          if (currentIndex == 1) ...[
            // 添加账号按钮
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _handleAddAccount,
              tooltip: '添加账号',
            ),
            // 切换账号选择器显示/隐藏按钮
            Consumer(
              builder: (context, ref, child) {
                final showSelector =
                    ref.watch(cloudDriveProvider).showAccountSelector;
                return IconButton(
                  icon: Icon(
                    showSelector
                        ? Icons.account_circle
                        : Icons.account_circle_outlined,
                  ),
                  onPressed:
                      () =>
                          ref
                              .read(cloudDriveEventHandlerProvider)
                              .toggleAccountSelector(),
                  tooltip: showSelector ? '隐藏账号选择器' : '显示账号选择器',
                );
              },
            ),
            // 取消待操作按钮
            Consumer(
              builder: (context, ref, child) {
                final showFloatingButton =
                    ref.watch(cloudDriveProvider).showFloatingActionButton;
                return showFloatingButton
                    ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed:
                          () =>
                              ref
                                  .read(cloudDriveEventHandlerProvider)
                                  .clearPendingOperation(),
                      tooltip: '取消操作',
                    )
                    : const SizedBox.shrink();
              },
            ),
            // 刷新按钮
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed:
                  () => ref
                      .read(cloudDriveEventHandlerProvider)
                      .loadFolder(forceRefresh: true),
              tooltip: '刷新',
            ),
            // 设置按钮
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: 打开设置页面
              },
              tooltip: '设置',
            ),
          ] else ...[
            // 其他页面的通知按钮
            Container(
              margin: EdgeInsets.only(right: 16.w),
              child: IconButton(
                icon: Icon(Icons.notifications, size: 24.w),
                onPressed: () {
                  // 通知功能
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.notificationFeature)),
                  );
                },
              ),
            ),
          ],
        ],
      ),
      SliverFillRemaining(
        child: _buildPageContent(
          pageController,
          pages,
          currentIndex,
          pageNavigation,
          l10n,
        ),
      ),
    ],
  );

  /// 构建页面内容
  Widget _buildPageContent(
    PageController pageController,
    List<Widget> pages,
    int currentIndex,
    PageNavigation pageNavigation,
    AppLocalizations l10n,
  ) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: ResponsiveUtils.getMaxWidth()),
      child: PageView(
        controller: pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (index) {
          pageNavigation.handlePageChange(index);
        },
        children: pages,
      ),
    ),
  );

  /// 构建底部导航栏
  Widget _buildBottomNavigationBar(
    int currentIndex,
    PageNavigation pageNavigation,
    AppLocalizations l10n,
  ) => SafeArea(
    bottom: false, // iOS优化：底部不需要额外的安全区域
    child: Container(
      // 动态计算高度：按钮高度 + 底部安全区域高度（iOS上是Home Indicator的高度）
      height:
          ResponsiveUtils.getButtonHeight() + ResponsiveUtils.bottomBarHeight,
      // 让导航栏在垂直方向居中显示，避免太靠上
      alignment: Alignment.center,
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          // 调整图标和标签之间的间距
          iconTheme: WidgetStateProperty.all(IconThemeData(size: 25.w)),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              fontSize: 12.sp,
              height: 0.5, // 减小行高，让标签更靠近图标
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) => pageNavigation.switchToPage(index),
          height: ResponsiveUtils.getButtonHeight(),
          destinations: [
            NavigationDestination(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 0.h), // 减小图标底部间距
                child: Icon(PhosphorIcons.house(), size: 25.w),
              ),
              selectedIcon: Padding(
                padding: EdgeInsets.only(bottom: 0.h),
                child: Icon(PhosphorIcons.house(), size: 25.w),
              ),
              label: l10n.home,
            ),
            NavigationDestination(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 0.h),
                child: Icon(PhosphorIcons.cloud(), size: 25.w),
              ),
              selectedIcon: Padding(
                padding: EdgeInsets.only(bottom: 0.h),
                child: Icon(PhosphorIcons.cloud(), size: 25.w),
              ),
              label: l10n.files,
            ),
            NavigationDestination(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 0.h),
                child: Icon(PhosphorIcons.user(), size: 25.w),
              ),
              selectedIcon: Padding(
                padding: EdgeInsets.only(bottom: 0.h),
                child: Icon(PhosphorIcons.user(), size: 25.w),
              ),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    ),
  );

  /// 处理添加账号
  void _handleAddAccount() {
    BottomSheetWidget.showWithTitle(
      context: context,
      title: '添加云盘账号',
      content: AddAccountFormWidget(
        onAccountCreated: (account) async {
          try {
            await ref.read(cloudDriveEventHandlerProvider).addAccount(account);
            if (context.mounted) {
              Navigator.pop(context);
              _showAccountAddSuccess(account.name);
            }
          } catch (e) {
            if (context.mounted) {
              _showAccountAddError(e);
            }
          }
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  /// 显示账号添加成功消息
  void _showAccountAddSuccess(String accountName) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('账号添加成功: $accountName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 显示账号添加错误消息
  void _showAccountAddError(dynamic e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('账号添加失败: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
