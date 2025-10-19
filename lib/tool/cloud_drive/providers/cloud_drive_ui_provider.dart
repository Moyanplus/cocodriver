import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/logging/log_manager.dart';

/// UI状态管理
class CloudDriveUIState {
  final bool showAccountSelector;
  final bool showFloatingActionButton;
  final bool showSearchBar;
  final bool showSortOptions;
  final bool showFilterOptions;
  final String currentViewMode; // 'list', 'grid', 'detail'
  final String currentSortBy; // 'name', 'size', 'modified', 'type'
  final String currentSortOrder; // 'asc', 'desc'
  final List<String> activeFilters;
  final bool showBreadcrumb;
  final bool showFilePreview;
  final bool showOperationPanel;
  final String? selectedTheme; // 'light', 'dark', 'auto'

  const CloudDriveUIState({
    this.showAccountSelector = false,
    this.showFloatingActionButton = false,
    this.showSearchBar = true,
    this.showSortOptions = false,
    this.showFilterOptions = false,
    this.currentViewMode = 'list',
    this.currentSortBy = 'name',
    this.currentSortOrder = 'asc',
    this.activeFilters = const [],
    this.showBreadcrumb = true,
    this.showFilePreview = false,
    this.showOperationPanel = false,
    this.selectedTheme,
  });

  CloudDriveUIState copyWith({
    bool? showAccountSelector,
    bool? showFloatingActionButton,
    bool? showSearchBar,
    bool? showSortOptions,
    bool? showFilterOptions,
    String? currentViewMode,
    String? currentSortBy,
    String? currentSortOrder,
    List<String>? activeFilters,
    bool? showBreadcrumb,
    bool? showFilePreview,
    bool? showOperationPanel,
    String? selectedTheme,
  }) => CloudDriveUIState(
    showAccountSelector: showAccountSelector ?? this.showAccountSelector,
    showFloatingActionButton:
        showFloatingActionButton ?? this.showFloatingActionButton,
    showSearchBar: showSearchBar ?? this.showSearchBar,
    showSortOptions: showSortOptions ?? this.showSortOptions,
    showFilterOptions: showFilterOptions ?? this.showFilterOptions,
    currentViewMode: currentViewMode ?? this.currentViewMode,
    currentSortBy: currentSortBy ?? this.currentSortBy,
    currentSortOrder: currentSortOrder ?? this.currentSortOrder,
    activeFilters: activeFilters ?? this.activeFilters,
    showBreadcrumb: showBreadcrumb ?? this.showBreadcrumb,
    showFilePreview: showFilePreview ?? this.showFilePreview,
    showOperationPanel: showOperationPanel ?? this.showOperationPanel,
    selectedTheme: selectedTheme ?? this.selectedTheme,
  );

  /// 是否处于列表视图
  bool get isListView => currentViewMode == 'list';

  /// 是否处于网格视图
  bool get isGridView => currentViewMode == 'grid';

  /// 是否处于详情视图
  bool get isDetailView => currentViewMode == 'detail';

  /// 是否按升序排列
  bool get isAscending => currentSortOrder == 'asc';

  /// 是否按降序排列
  bool get isDescending => currentSortOrder == 'desc';

  /// 是否有活跃的过滤器
  bool get hasActiveFilters => activeFilters.isNotEmpty;
}

/// UI状态Provider
class CloudDriveUIProvider extends StateNotifier<CloudDriveUIState> {
  CloudDriveUIProvider() : super(const CloudDriveUIState());

  /// 切换账号选择器显示状态
  void toggleAccountSelector() {
    state = state.copyWith(showAccountSelector: !state.showAccountSelector);

    LogManager().cloudDrive(
      '🔄 切换账号选择器: ${state.showAccountSelector}',
      
    );
  }

  /// 设置悬浮按钮显示状态
  void setFloatingActionButton(bool show) {
    state = state.copyWith(showFloatingActionButton: show);

    LogManager().cloudDrive(
      '🔄 设置悬浮按钮: $show',
      
    );
  }

  /// 切换搜索栏显示状态
  void toggleSearchBar() {
    state = state.copyWith(showSearchBar: !state.showSearchBar);

    LogManager().cloudDrive(
      '🔄 切换搜索栏: ${state.showSearchBar}',
      
    );
  }

  /// 切换排序选项显示状态
  void toggleSortOptions() {
    state = state.copyWith(showSortOptions: !state.showSortOptions);

    LogManager().cloudDrive(
      '🔄 切换排序选项: ${state.showSortOptions}',
      
    );
  }

  /// 切换过滤器选项显示状态
  void toggleFilterOptions() {
    state = state.copyWith(showFilterOptions: !state.showFilterOptions);

    LogManager().cloudDrive(
      '🔄 切换过滤器选项: ${state.showFilterOptions}',
      
    );
  }

  /// 切换视图模式
  void toggleViewMode() {
    String newViewMode;
    switch (state.currentViewMode) {
      case 'list':
        newViewMode = 'grid';
        break;
      case 'grid':
        newViewMode = 'detail';
        break;
      case 'detail':
        newViewMode = 'list';
        break;
      default:
        newViewMode = 'list';
    }

    state = state.copyWith(currentViewMode: newViewMode);

    LogManager().cloudDrive(
      '🔄 切换视图模式: $newViewMode',
      
    );
  }

  /// 设置视图模式
  void setViewMode(String viewMode) {
    if (['list', 'grid', 'detail'].contains(viewMode)) {
      state = state.copyWith(currentViewMode: viewMode);

      LogManager().cloudDrive(
        '🔄 设置视图模式: $viewMode',
        
      );
    }
  }

  /// 设置排序方式
  void setSortBy(String sortBy) {
    if (['name', 'size', 'modified', 'type'].contains(sortBy)) {
      state = state.copyWith(currentSortBy: sortBy);

      LogManager().cloudDrive(
        '🔄 设置排序方式: $sortBy',
        
      );
    }
  }

  /// 切换排序顺序
  void toggleSortOrder() {
    final newOrder = state.isAscending ? 'desc' : 'asc';
    state = state.copyWith(currentSortOrder: newOrder);

    LogManager().cloudDrive(
      '🔄 切换排序顺序: $newOrder',
      
    );
  }

  /// 添加过滤器
  void addFilter(String filter) {
    if (!state.activeFilters.contains(filter)) {
      final newFilters = [...state.activeFilters, filter];
      state = state.copyWith(activeFilters: newFilters);

      LogManager().cloudDrive(
        '✅ 添加过滤器: $filter (共${newFilters.length}个)',
        
      );
    }
  }

  /// 移除过滤器
  void removeFilter(String filter) {
    final newFilters = state.activeFilters.where((f) => f != filter).toList();
    state = state.copyWith(activeFilters: newFilters);

    LogManager().cloudDrive(
      '❌ 移除过滤器: $filter (剩余${newFilters.length}个)',
      
    );
  }

  /// 清除所有过滤器
  void clearFilters() {
    state = state.copyWith(activeFilters: []);

    LogManager().cloudDrive(
      '🗑️ 清除所有过滤器',
      
    );
  }

  /// 切换面包屑显示状态
  void toggleBreadcrumb() {
    state = state.copyWith(showBreadcrumb: !state.showBreadcrumb);

    LogManager().cloudDrive(
      '🔄 切换面包屑: ${state.showBreadcrumb}',
      
    );
  }

  /// 切换文件预览显示状态
  void toggleFilePreview() {
    state = state.copyWith(showFilePreview: !state.showFilePreview);

    LogManager().cloudDrive(
      '🔄 切换文件预览: ${state.showFilePreview}',
      
    );
  }

  /// 切换操作面板显示状态
  void toggleOperationPanel() {
    state = state.copyWith(showOperationPanel: !state.showOperationPanel);

    LogManager().cloudDrive(
      '🔄 切换操作面板: ${state.showOperationPanel}',
      
    );
  }

  /// 设置主题
  void setTheme(String theme) {
    if (['light', 'dark', 'auto'].contains(theme)) {
      state = state.copyWith(selectedTheme: theme);

      LogManager().cloudDrive(
        '🎨 设置主题: $theme',
        
      );
    }
  }

  /// 重置UI状态
  void reset() {
    state = const CloudDriveUIState();

    LogManager().cloudDrive(
      '🔄 重置UI状态',
      
    );
  }
}

/// UI状态Provider实例
final cloudDriveUIProvider =
    StateNotifierProvider<CloudDriveUIProvider, CloudDriveUIState>(
      (ref) => CloudDriveUIProvider(),
    );
