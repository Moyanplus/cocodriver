/// 导航和状态管理提供者
///
/// 使用Riverpod管理应用程序的导航状态、主题状态等
/// 提供全局状态管理和页面导航功能
///
/// 主要功能：
/// - 应用Provider包装器
/// - 主题状态管理
/// - 页面导航管理
/// - 本地化状态管理
/// - 云盘类型管理
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 核心模块导入
import '../theme/theme_models.dart';
import '../services/theme_service.dart';

// 页面导入
import '../../features/home/pages/home_page.dart';
import '../../features/user/pages/user_profile_page.dart';
import '../../tool/cloud_drive/presentation/pages/cloud_drive_browser_page.dart';

// ==================== 应用Provider包装器 ====================
/// 应用提供者包装器
///
/// 为整个应用程序提供Riverpod的ProviderScope
/// 确保所有子组件都能访问到Provider状态
class AppProviders extends StatelessWidget {
  /// 子组件
  final Widget child;

  const AppProviders({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(child: child);
  }
}

// ==================== 主题Provider ====================
/// 主题提供者
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
    : super(
        ThemeState(
          currentTheme: ThemeType.system,
          themeData: ThemeService().getTheme(ThemeType.system),
        ),
      ) {
    _loadTheme();
  }

  /// 加载保存的主题
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = prefs.getString('selected_theme');

      if (themeName != null) {
        final themeType = ThemeType.values.firstWhere(
          (type) => type.name == themeName,
          orElse: () => ThemeType.system,
        );
        _setTheme(themeType);
      }
    } catch (e) {
      // 加载主题失败，使用默认主题
    }
  }

  /// 设置主题
  Future<void> setTheme(ThemeType themeType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_theme', themeType.name);
      _setTheme(themeType);
    } catch (e) {
      // 保存主题失败，继续使用当前主题
    }
  }

  /// 内部设置主题
  void _setTheme(ThemeType themeType) {
    final themeService = ThemeService();
    themeService.setTheme(themeType);
    final themeData = themeService.getTheme(themeType);

    state = state.copyWith(currentTheme: themeType, themeData: themeData);
  }
}

/// 主题提供者
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

/// 当前主题数据提供者
final themeDataProvider = Provider<ThemeData>((ref) {
  return ref.watch(themeProvider).themeData;
});

/// 当前主题类型提供者
final currentThemeProvider = Provider<ThemeType>((ref) {
  return ref.watch(themeProvider).currentTheme;
});

// ==================== 导航Provider ====================
/// 页面导航状态
class PageNavigationState {
  final int currentIndex;
  final PageController pageController;

  PageNavigationState({
    required this.currentIndex,
    required this.pageController,
  });

  PageNavigationState copyWith({
    int? currentIndex,
    PageController? pageController,
  }) {
    return PageNavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      pageController: pageController ?? this.pageController,
    );
  }
}

/// 页面导航状态管理器
class PageNavigationNotifier extends StateNotifier<PageNavigationState> {
  PageNavigationNotifier()
    : super(
        PageNavigationState(
          currentIndex: 0,
          pageController: PageController(initialPage: 0),
        ),
      );

  /// 切换到指定页面
  void switchToPage(int index) {
    if (index != state.currentIndex) {
      state = state.copyWith(currentIndex: index);
      state.pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 处理页面变化（由PageView的onPageChanged调用）
  void handlePageChange(int index) {
    if (index != state.currentIndex) {
      state = state.copyWith(currentIndex: index);
    }
  }

  @override
  void dispose() {
    state.pageController.dispose();
    super.dispose();
  }
}

/// 当前页面索引提供者
final currentPageIndexProvider = StateProvider<int>((ref) => 0);

/// 页面列表提供者
final pagesProvider = Provider<List<Widget>>(
  (ref) => const [HomePage(), CloudDriveBrowserPage(), UserProfilePage()],
);

/// 页面导航状态提供者
final pageNavigationStateProvider =
    StateNotifierProvider<PageNavigationNotifier, PageNavigationState>((ref) {
      return PageNavigationNotifier();
    });

/// 页面控制器提供者
final pageControllerProvider = Provider<PageController>((ref) {
  return ref.watch(pageNavigationStateProvider).pageController;
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
    _ref.read(pageNavigationStateProvider.notifier).switchToPage(index);
  }

  /// 处理页面变化
  void handlePageChange(int index) {
    _ref.read(pageNavigationStateProvider.notifier).handlePageChange(index);
  }
}
