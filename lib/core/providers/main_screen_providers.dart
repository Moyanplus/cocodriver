import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/pages/home_page.dart';
import '../../features/category/pages/category_page.dart';
import '../../features/user/pages/user_profile_page.dart';

/// 当前页面索引提供者
final currentPageIndexProvider = StateProvider<int>((ref) => 0);

/// 页面列表提供者
final pagesProvider = Provider<List<Widget>>(
  (ref) => const [HomePage(), CategoryPage(), UserProfilePage()],
);

/// 页面控制器提供者
final pageControllerProvider = Provider<PageController>((ref) {
  final currentIndex = ref.watch(currentPageIndexProvider);
  return PageController(initialPage: currentIndex);
});

/// 页面切换提供者
final pageNavigationProvider = Provider<PageNavigation>((ref) {
  return PageNavigation(ref);
});

/// 页面导航类
class PageNavigation {
  final Ref _ref;

  PageNavigation(this._ref);

  /// 切换到指定页面
  void switchToPage(int index) {
    if (index != _ref.read(currentPageIndexProvider)) {
      _ref.read(currentPageIndexProvider.notifier).state = index;
      _ref
          .read(pageControllerProvider)
          .animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
    }
  }

  /// 处理页面变化
  void handlePageChange(int index) {
    switchToPage(index);
  }
}
