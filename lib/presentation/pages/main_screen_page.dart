import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/providers/main_screen_providers.dart';
import '../../shared/widgets/common/app_drawer_widget.dart';

/// 主屏幕组件
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentPageIndexProvider);
    final pageController = ref.watch(pageControllerProvider);
    final pages = ref.watch(pagesProvider);
    final pageNavigation = ref.watch(pageNavigationProvider);

    return Scaffold(
      drawer: const AppDrawerWidget(),
      body: _buildBodyWithSliverAppBar(
        pageController,
        pages,
        currentIndex,
        pageNavigation,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(
        currentIndex,
        pageNavigation,
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
  ) => NestedScrollView(
    headerSliverBuilder:
        (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            title: const Text('Flutter UI模板'),
            toolbarHeight: 60,
            floating: true,
            pinned: false,
            snap: false,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    // 通知功能
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('通知功能')));
                  },
                ),
              ),
            ],
          ),
        ],
    body: _buildPageContent(
      pageController,
      pages,
      currentIndex,
      pageNavigation,
    ),
  );

  /// 构建页面内容
  Widget _buildPageContent(
    PageController pageController,
    List<Widget> pages,
    int currentIndex,
    PageNavigation pageNavigation,
  ) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
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
  ) => SafeArea(
    bottom: false,
    child: Container(
      height: 92,
      padding: const EdgeInsets.only(bottom: 0),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected:
            (index) => pageNavigation.handlePageChange(index),
        height: 56,
        destinations: [
          NavigationDestination(
            icon: Icon(PhosphorIcons.house()),
            selectedIcon: Icon(PhosphorIcons.house()),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.squaresFour()),
            selectedIcon: Icon(PhosphorIcons.squaresFour()),
            label: '分类',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.user()),
            selectedIcon: Icon(PhosphorIcons.user()),
            label: '我的',
          ),
        ],
      ),
    ),
  );
}
