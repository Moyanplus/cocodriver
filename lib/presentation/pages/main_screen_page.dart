import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../features/home/pages/home_page.dart';
import '../../features/category/pages/category_page.dart';
import '../../features/user/pages/user_profile_page.dart';
import '../../shared/widgets/common/app_drawer_widget.dart';

/// 主屏幕状态
class MainScreenState {
  final int currentIndex;
  final PageController pageController;
  final List<Widget> pages;

  MainScreenState({
    required this.currentIndex,
    required this.pageController,
    required this.pages,
  });

  MainScreenState copyWith({
    int? currentIndex,
    PageController? pageController,
    List<Widget>? pages,
  }) {
    return MainScreenState(
      currentIndex: currentIndex ?? this.currentIndex,
      pageController: pageController ?? this.pageController,
      pages: pages ?? this.pages,
    );
  }
}

/// 主屏幕提供者
class MainScreenNotifier extends StateNotifier<MainScreenState> {
  MainScreenNotifier()
    : super(
        MainScreenState(
          currentIndex: 0,
          pageController: PageController(initialPage: 0),
          pages: const [HomePage(), CategoryPage(), UserProfilePage()],
        ),
      );

  /// 切换页面
  void switchPage(int index) {
    if (index != state.currentIndex) {
      state.pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      state = state.copyWith(currentIndex: index);
    }
  }

  /// 处理页面变化
  void handlePageChange(int index, WidgetRef ref) {
    switchPage(index);
  }

  @override
  void dispose() {
    state.pageController.dispose();
    super.dispose();
  }
}

/// 主屏幕提供者
final mainScreenProvider =
    StateNotifierProvider<MainScreenNotifier, MainScreenState>((ref) {
      return MainScreenNotifier();
    });

/// 主屏幕组件
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final mainScreenState = ref.watch(mainScreenProvider);
    final mainScreenNotifier = ref.read(mainScreenProvider.notifier);
    final currentIndex = mainScreenState.currentIndex;

    return Scaffold(
      drawer: const AppDrawerWidget(),
      body: _buildBodyWithSliverAppBar(
        mainScreenState,
        mainScreenNotifier,
        currentIndex,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(
        mainScreenState,
        mainScreenNotifier,
        currentIndex,
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  /// 构建带有SliverAppBar的页面内容
  Widget _buildBodyWithSliverAppBar(
    MainScreenState state,
    MainScreenNotifier notifier,
    int currentIndex,
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
    body: _buildPageContent(state, notifier, currentIndex),
  );

  /// 构建页面内容
  Widget _buildPageContent(
    MainScreenState state,
    MainScreenNotifier notifier,
    int currentIndex,
  ) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: PageView(
        controller: state.pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            notifier.switchPage(index);
          });
        },
        children: state.pages,
      ),
    ),
  );

  /// 构建底部导航栏
  Widget _buildBottomNavigationBar(
    MainScreenState state,
    MainScreenNotifier notifier,
    int currentIndex,
  ) => SafeArea(
    bottom: false,
    child: Container(
      height: 92,
      padding: const EdgeInsets.only(bottom: 0),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => notifier.handlePageChange(index, ref),
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
