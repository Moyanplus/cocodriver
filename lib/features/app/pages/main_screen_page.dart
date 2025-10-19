import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/navigation/navigation_providers.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/common/app_drawer_widget.dart';
import '../../../tool/cloud_drive/presentation/providers/cloud_drive_provider.dart';
import '../../../tool/cloud_drive/presentation/widgets/add_account_form_widget.dart';
import '../../../shared/widgets/common/bottom_sheet_widget.dart';

/// 主屏幕组件
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final pageNavigationState = ref.watch(pageNavigationStateProvider);
    final currentIndex = pageNavigationState.currentIndex;
    final pageController = pageNavigationState.pageController;
    final pages = ref.watch(pagesProvider);
    final pageNavigation = ref.watch(pageNavigationProvider);
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      drawer: const AppDrawerWidget(),
      body: _buildBodyWithSliverAppBar(
        pageController,
        pages,
        currentIndex,
        pageNavigation,
        l10n,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(
        currentIndex,
        pageNavigation,
        l10n,
      ),
      resizeToAvoidBottomInset: false,
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
        toolbarHeight: ResponsiveUtils.getNavigationBarHeight(context),
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
    bottom: false,
    child: Container(
      height: 92.h,
      padding: EdgeInsets.only(bottom: 0),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => pageNavigation.switchToPage(index),
        height: ResponsiveUtils.getButtonHeight(),
        destinations: [
          NavigationDestination(
            icon: Icon(PhosphorIcons.house(), size: 24.w),
            selectedIcon: Icon(PhosphorIcons.house(), size: 24.w),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.cloud(), size: 24.w),
            selectedIcon: Icon(PhosphorIcons.cloud(), size: 24.w),
            label: '云盘助手',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.user(), size: 24.w),
            selectedIcon: Icon(PhosphorIcons.user(), size: 24.w),
            label: l10n.profile,
          ),
        ],
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
