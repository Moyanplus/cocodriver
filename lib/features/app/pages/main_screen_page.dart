import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/navigation/navigation_providers.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/common/app_drawer_widget.dart';

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
            icon: Icon(PhosphorIcons.squaresFour(), size: 24.w),
            selectedIcon: Icon(PhosphorIcons.squaresFour(), size: 24.w),
            label: l10n.category,
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
}
