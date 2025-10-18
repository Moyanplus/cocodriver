import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/base/debug_service.dart';
import '../models/cloud_drive_models.dart';
import '../services/baidu/baidu_cloud_drive_service.dart';
import '../base/cloud_drive_account_service.dart';
import '../base/cloud_drive_cache_service.dart';
import '../base/cloud_drive_file_service.dart';
import '../base/cloud_drive_operation_service.dart';

/// 云盘状态管理
class CloudDriveState {
  final List<CloudDriveAccount> accounts;
  final int currentAccountIndex;
  final List<CloudDriveFile> folders;
  final List<CloudDriveFile> files;
  final List<PathInfo> folderPath; // 修改为PathInfo列表
  final bool isLoading;
  final String? error;
  final bool isBatchMode;
  final Set<String> selectedItems;
  final bool isAllSelected;
  final int currentPage;
  final bool hasMoreData;
  final bool isLoadingMore;
  final bool isRefreshing; // 新增：是否正在后台刷新
  final bool isFromCache; // 新增：数据是否来自缓存
  final DateTime? lastRefreshTime; // 新增：最后刷新时间
  final bool showAccountSelector; // 新增：是否显示账号选择器
  final CloudDriveFile? pendingOperationFile; // 新增：待操作的文件
  final String? pendingOperationType; // 新增：待操作类型 (copy/move)
  final bool showFloatingActionButton; // 新增：是否显示悬浮按钮

  const CloudDriveState({
    this.accounts = const [],
    this.currentAccountIndex = 0,
    this.folders = const [],
    this.files = const [],
    this.folderPath = const [], // 修改为PathInfo列表
    this.isLoading = false,
    this.error,
    this.isBatchMode = false,
    this.selectedItems = const {},
    this.isAllSelected = false,
    this.currentPage = 1,
    this.hasMoreData = true,
    this.isLoadingMore = false,
    this.isRefreshing = false, // 新增
    this.isFromCache = false, // 新增
    this.lastRefreshTime, // 新增
    this.showAccountSelector = false, // 新增：默认隐藏
    this.pendingOperationFile, // 新增
    this.pendingOperationType, // 新增
    this.showFloatingActionButton = false, // 新增
  });

  CloudDriveState copyWith({
    List<CloudDriveAccount>? accounts,
    int? currentAccountIndex,
    List<CloudDriveFile>? folders,
    List<CloudDriveFile>? files,
    List<PathInfo>? folderPath, // 修改为PathInfo列表
    bool? isLoading,
    String? error,
    bool? isBatchMode,
    Set<String>? selectedItems,
    bool? isAllSelected,
    int? currentPage,
    bool? hasMoreData,
    bool? isLoadingMore,
    bool? isRefreshing, // 新增
    bool? isFromCache, // 新增
    DateTime? lastRefreshTime, // 新增
    bool? showAccountSelector, // 新增
    CloudDriveFile? pendingOperationFile, // 新增
    String? pendingOperationType, // 新增
    bool? showFloatingActionButton, // 新增
  }) => CloudDriveState(
    accounts: accounts ?? this.accounts,
    currentAccountIndex: currentAccountIndex ?? this.currentAccountIndex,
    folders: folders ?? this.folders,
    files: files ?? this.files,
    folderPath: folderPath ?? this.folderPath, // 修改为PathInfo列表
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
    isBatchMode: isBatchMode ?? this.isBatchMode,
    selectedItems: selectedItems ?? this.selectedItems,
    isAllSelected: isAllSelected ?? this.isAllSelected,
    currentPage: currentPage ?? this.currentPage,
    hasMoreData: hasMoreData ?? this.hasMoreData,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isRefreshing: isRefreshing ?? this.isRefreshing, // 新增
    isFromCache: isFromCache ?? this.isFromCache, // 新增
    lastRefreshTime: lastRefreshTime ?? this.lastRefreshTime, // 新增
    showAccountSelector: showAccountSelector ?? this.showAccountSelector, // 新增
    pendingOperationFile:
        pendingOperationFile ?? this.pendingOperationFile, // 新增
    pendingOperationType:
        pendingOperationType ?? this.pendingOperationType, // 新增
    showFloatingActionButton:
        showFloatingActionButton ?? this.showFloatingActionButton, // 新增
  );

  /// 获取当前账号
  CloudDriveAccount? get currentAccount {
    if (accounts.isEmpty || currentAccountIndex >= accounts.length) {
      return null;
    }
    return accounts[currentAccountIndex];
  }

  /// 获取所有项目（文件夹+文件）
  List<CloudDriveFile> get allItems => [...folders, ...files];

  /// 获取选中项目
  List<CloudDriveFile> get selectedFolders =>
      folders.where((folder) => selectedItems.contains(folder.id)).toList();

  List<CloudDriveFile> get selectedFiles =>
      files.where((file) => selectedItems.contains(file.id)).toList();

  /// 检查是否全选
  bool get isAllSelectedComputed {
    final totalItems = folders.length + files.length;
    return totalItems > 0 && selectedItems.length == totalItems;
  }
}

/// 云盘状态管理器
class CloudDriveNotifier extends StateNotifier<CloudDriveState> {
  CloudDriveNotifier() : super(const CloudDriveState());

  /// 加载账号列表
  Future<void> loadAccounts() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final accounts = await CloudDriveAccountService.loadAccounts();
      state = state.copyWith(
        accounts: accounts,
        isLoading: false,
        currentAccountIndex: accounts.isNotEmpty ? 0 : -1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 切换账号
  Future<void> switchAccount(int index) async {
    if (index < 0 || index >= state.accounts.length) return;

    state = state.copyWith(
      currentAccountIndex: index,
      folderPath: [],
      folders: [],
      files: [],
      currentPage: 1,
      hasMoreData: true,
    );

    await loadCurrentFolder();
  }

  /// 加载当前文件夹内容（智能缓存版本）
  Future<void> loadCurrentFolder({bool forceRefresh = false}) async {
    DebugService.log(
      '📂 云盘提供者 - 开始加载当前文件夹',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );
    DebugService.log(
      '🔄 强制刷新: $forceRefresh',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );
    DebugService.log(
      '📂 当前路径: ${state.folderPath}',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );
    DebugService.log(
      '👤 当前账号: ${state.currentAccount?.name} (${state.currentAccount?.type.displayName})',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );

    final account = state.currentAccount;
    if (account == null) {
      DebugService.log(
        '❌ 云盘提供者 - 当前账号为空',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
      return;
    }

    // 生成缓存键
    final cacheKey = CloudDriveCacheService.generateCacheKey(
      account.id,
      state.folderPath, // 直接传递PathInfo列表
    );
    DebugService.log(
      '🔑 缓存键: $cacheKey',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );

    try {
      // 如果不是强制刷新，先尝试显示缓存数据
      if (!forceRefresh) {
        DebugService.log(
          '🔍 云盘提供者 - 尝试获取缓存数据',
          category: DebugCategory.tools,
          subCategory: 'tools.cloudDrive.navigation',
        );
        final cachedData = CloudDriveCacheService.getCachedData(
          cacheKey,
          const Duration(minutes: 5), // 缓存5分钟
        );

        if (cachedData != null) {
          DebugService.log(
            '📦 显示缓存数据: $cacheKey',
            category: DebugCategory.tools,
            subCategory: 'tools.cloudDrive.navigation',
          );
          DebugService.log(
            '📁 缓存文件夹数量: ${cachedData['folders']?.length ?? 0}',
            category: DebugCategory.tools,
            subCategory: 'tools.cloudDrive.navigation',
          );
          DebugService.log(
            '📄 缓存文件数量: ${cachedData['files']?.length ?? 0}',
            category: DebugCategory.tools,
            subCategory: 'tools.cloudDrive.navigation',
          );

          state = state.copyWith(
            folders: cachedData['folders'] ?? [],
            files: cachedData['files'] ?? [],
            isLoading: false,
            isFromCache: true,
            error: null,
          );

          // 如果有缓存数据，后台静默刷新，不显示加载状态
          DebugService.log(
            '🔄 云盘提供者 - 开始后台刷新',
            category: DebugCategory.tools,
            subCategory: 'tools.cloudDrive.navigation',
          );
          state = state.copyWith(isRefreshing: true);
        } else {
          // 没有缓存数据，显示加载状态
          DebugService.log(
            '📡 云盘提供者 - 无缓存数据，显示加载状态',
            category: DebugCategory.tools,
            subCategory: 'tools.cloudDrive.navigation',
          );
          state = state.copyWith(isLoading: true);
        }
      } else {
        // 强制刷新，显示加载状态
        DebugService.log(
          '🔄 云盘提供者 - 强制刷新，显示加载状态',
          category: DebugCategory.tools,
          subCategory: 'tools.cloudDrive.navigation',
        );
        state = state.copyWith(
          isLoading: true,
          error: null,
          currentPage: 1,
          hasMoreData: true,
          isRefreshing: false,
          isFromCache: false,
        );
      }

      // 使用策略模式获取目标文件夹ID，解耦具体云盘的路径构建逻辑
      final folderId =
          state.folderPath.isEmpty
              ? null // 传 null 让 getFileList 使用配置的 rootDir
              : CloudDriveOperationService.convertPathToTargetFolderId(
                cloudDriveType: account.type,
                folderPath: state.folderPath,
              );

      DebugService.log(
        '📁 目标文件夹ID: $folderId',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
      DebugService.log(
        ' 页码: ${forceRefresh ? 1 : state.currentPage}',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );

      // 获取最新数据
      DebugService.log(
        '📡 云盘提供者 - 开始调用文件列表API',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
      final result = await CloudDriveFileService.getFileList(
        account: account,
        folderId: folderId,
        page: forceRefresh ? 1 : state.currentPage,
      );

      DebugService.log(
        '✅ 云盘提供者 - 文件列表API调用成功',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
      DebugService.log(
        '📁 返回文件夹数量: ${result['folders']?.length ?? 0}',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
      DebugService.log(
        '📄 返回文件数量: ${result['files']?.length ?? 0}',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );

      // 更新缓存
      CloudDriveCacheService.cacheData(cacheKey, result);
      DebugService.log(
        '💾 更新缓存: $cacheKey',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );

      // 更新状态
      final newFolders = result['folders'] ?? [];
      final newFiles = result['files'] ?? [];
      final hasMore = (newFolders.length + newFiles.length) >= 50;

      DebugService.log(
        '📊 是否还有更多数据: $hasMore',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );

      // 无论是强制刷新还是后台刷新，都应该替换数据而不是追加
      state = state.copyWith(
        folders: newFolders,
        files: newFiles,
        isLoading: false,
        isRefreshing: false,
        isFromCache: false,
        lastRefreshTime: DateTime.now(),
        error: null,
        currentPage: forceRefresh ? 1 : state.currentPage + 1,
        hasMoreData: hasMore,
      );

      DebugService.log(
        '✅ 数据加载完成: ${newFolders.length} 个文件夹, ${newFiles.length} 个文件',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
    } catch (e) {
      DebugService.log(
        '❌ 加载文件夹失败: $e',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  /// 进入文件夹
  Future<void> enterFolder(CloudDriveFile folder) async {
    DebugService.log(
      '🚀 云盘提供者 - 开始进入文件夹',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );
    DebugService.log(
      '📁 文件夹名称: ${folder.name}',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );
    DebugService.log(
      '🆔 文件夹ID: ${folder.id}',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );
    DebugService.log(
      '📂 当前路径: ${state.folderPath}',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );
    DebugService.log(
      '👤 当前账号: ${state.currentAccount?.name} (${state.currentAccount?.type.displayName})',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );

    final account = state.currentAccount;
    if (account == null) {
      DebugService.log(
        '❌ 云盘提供者 - 当前账号为空',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
      return;
    }

    // 使用文件夹的实际路径，而不是名称
    List<PathInfo> newPath;
    if (account.type == CloudDriveType.pan123 ||
        account.type == CloudDriveType.quark) {
      // 123云盘和夸克云盘：保存文件夹ID和名称
      newPath = [
        ...state.folderPath,
        PathInfo(id: folder.id, name: folder.name),
      ];
      DebugService.log(
        '📂 ${account.type.displayName}新路径（使用ID）: ${newPath.map((p) => '${p.name}(${p.id})').join(' -> ')}',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
    } else {
      // 其他云盘：使用文件夹名称和ID
      newPath = [
        ...state.folderPath,
        PathInfo(id: folder.id, name: folder.name),
      ];
      DebugService.log(
        '📂 其他云盘新路径（使用名称）: ${newPath.map((p) => '${p.name}(${p.id})').join(' -> ')}',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
    }

    DebugService.log(
      '🔍 进入文件夹: ${folder.name}, 路径: ${folder.id}',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );

    try {
      DebugService.log(
        '🔄 云盘提供者 - 更新状态为加载中',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
      state = state.copyWith(
        folderPath: newPath,
        folders: [],
        files: [],
        currentPage: 1,
        hasMoreData: true,
        isLoading: true,
        error: null,
      );

      // 使用策略模式获取目标文件夹ID，解耦具体云盘的路径构建逻辑
      final folderId = CloudDriveOperationService.convertPathToTargetFolderId(
        cloudDriveType: account.type,
        folderPath: newPath,
      );

      DebugService.log(
        '🔧 策略模式路径构建结果: $folderId',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );

      DebugService.log(
        '📡 云盘提供者 - 开始调用文件列表API',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
      DebugService.log(
        '📡 目标文件夹ID: $folderId',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
      DebugService.log(
        '📡 页码: 1',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );

      // 直接调用 API 服务
      final result = await CloudDriveFileService.getFileList(
        account: account,
        folderId: folderId,
        page: 1,
      );

      DebugService.log(
        '✅ 云盘提供者 - 文件列表API调用成功',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
      DebugService.log(
        '📁 返回文件夹数量: ${result['folders']?.length ?? 0}',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
      DebugService.log(
        '📄 返回文件数量: ${result['files']?.length ?? 0}',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );

      // 打印返回的文件和文件夹详情
      final folders = result['folders'] ?? [];
      final files = result['files'] ?? [];

      for (int i = 0; i < folders.length; i++) {
        final f = folders[i];
        DebugService.log(
          '📁 文件夹 ${i + 1}: ${f.name} (ID: ${f.id})',
          category: DebugCategory.tools,
          subCategory: 'tools.cloudDrive.navigation',
        );
      }

      for (int i = 0; i < files.length; i++) {
        final f = files[i];
        DebugService.log(
          '📄 文件 ${i + 1}: ${f.name} (ID: ${f.id})',
          category: DebugCategory.tools,
          subCategory: 'tools.cloudDrive.navigation',
        );
      }

      final hasMoreData = (folders.length + files.length) >= 50;
      DebugService.log(
        '�� 是否还有更多数据: $hasMoreData',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );

      state = state.copyWith(
        folders: folders,
        files: files,
        isLoading: false,
        hasMoreData: hasMoreData,
      );

      DebugService.log(
        '✅ 云盘提供者 - 进入文件夹完成',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
    } catch (e) {
      DebugService.log(
        '❌ 云盘提供者 - 进入文件夹失败: $e',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 返回上级
  Future<void> goBack() async {
    DebugService.log(
      '🔙 云盘提供者 - 开始返回上级',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );
    DebugService.log(
      '📂 当前路径: ${state.folderPath}',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );
    DebugService.log(
      '📂 路径长度: ${state.folderPath.length}',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );

    if (state.folderPath.isEmpty) {
      DebugService.log(
        '⚠️ 云盘提供者 - 已在根目录，无法返回',
        category: DebugCategory.tools,
        subCategory: 'tools.cloudDrive.navigation',
      );
      return;
    }

    final newPath = state.folderPath.sublist(0, state.folderPath.length - 1);
    DebugService.log(
      '📂 新路径: $newPath',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );

    DebugService.log(
      '🔄 云盘提供者 - 更新状态',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );
    state = state.copyWith(
      folderPath: newPath,
      folders: [],
      files: [],
      currentPage: 1,
      hasMoreData: true,
    );

    DebugService.log(
      '📡 云盘提供者 - 开始加载当前文件夹',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );
    await loadCurrentFolder();
    DebugService.log(
      '✅ 云盘提供者 - 返回上级完成',
      category: DebugCategory.tools,
      subCategory: 'tools.cloudDrive.navigation',
    );
  }

  /// 进入批量模式
  void enterBatchMode(String itemId) {
    state = state.copyWith(
      isBatchMode: true,
      selectedItems: {itemId},
      isAllSelected: false,
    );
  }

  /// 退出批量模式
  void exitBatchMode() {
    state = state.copyWith(
      isBatchMode: false,
      selectedItems: {},
      isAllSelected: false,
    );
  }

  /// 切换选择状态
  void toggleSelection(String itemId) {
    final newSelectedItems = Set<String>.from(state.selectedItems);

    if (newSelectedItems.contains(itemId)) {
      newSelectedItems.remove(itemId);
    } else {
      newSelectedItems.add(itemId);
    }

    // 如果没有选中项，自动关闭批量模式
    if (newSelectedItems.isEmpty) {
      state = state.copyWith(
        selectedItems: newSelectedItems,
        isBatchMode: false,
        isAllSelected: false,
      );
    } else {
      state = state.copyWith(
        selectedItems: newSelectedItems,
        isAllSelected: newSelectedItems.length == state.allItems.length,
      );
    }
  }

  /// 切换全选状态
  void toggleSelectAll() {
    if (state.isAllSelected) {
      // 取消全选并退出批量模式
      state = state.copyWith(
        selectedItems: {},
        isAllSelected: false,
        isBatchMode: false,
      );
    } else {
      // 全选所有项目
      final allIds = state.allItems.map((item) => item.id).toSet();
      state = state.copyWith(selectedItems: allIds, isAllSelected: true);
    }
  }

  /// 批量下载
  Future<void> batchDownload() async {
    final account = state.currentAccount;
    if (account == null || state.selectedItems.isEmpty) return;

    try {
      await CloudDriveFileService.batchDownloadFiles(
        account: account,
        files: state.selectedFiles,
        folders: state.selectedFolders,
      );

      // 下载完成后退出批量模式
      exitBatchMode();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 批量分享
  Future<void> batchShare() async {
    // TODO: 实现批量分享逻辑
    exitBatchMode();
  }

  /// 加载更多数据
  Future<void> loadMore() async {
    if (!state.hasMoreData || state.isLoadingMore) return;
    await loadCurrentFolder();
  }

  /// 添加账号
  Future<void> addAccount(CloudDriveAccount account) async {
    try {
      DebugService.log(
        '➕ 开始添加账号: ${account.name} (${account.type.displayName})',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.account',
      );
      DebugService.log(
        '🍪 Cookie长度: ${account.cookies?.length ?? 0}',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.account',
      );

      await CloudDriveAccountService.addAccount(account);
      DebugService.log(
        '✅ 账号已保存到本地存储',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.account',
      );

      // 执行云盘特定的初始化逻辑
      await _performAccountInitialization(account);

      await loadAccounts(); // 重新加载账号列表
      DebugService.log(
        '✅ 账号列表已重新加载',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.account',
      );
    } catch (e) {
      DebugService.log(
        '❌ 添加账号失败: $e',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.account',
      );
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 执行账号特定的初始化逻辑
  Future<void> _performAccountInitialization(CloudDriveAccount account) async {
    try {
      DebugService.log(
        '🔧 开始执行账号初始化: ${account.type.displayName}',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.account',
      );

      switch (account.type) {
        case CloudDriveType.baidu:
          // 百度网盘：自动获取API参数
          try {
            DebugService.log(
              '🔄 百度网盘 - 开始获取API参数',
              category: DebugCategory.tools,
              subCategory: 'cloudDrive.account',
            );
            await BaiduCloudDriveService.getBaiduParams(account);
            DebugService.log(
              '✅ 百度网盘 - API参数获取成功',
              category: DebugCategory.tools,
              subCategory: 'cloudDrive.account',
            );
          } catch (e) {
            DebugService.log(
              '⚠️ 百度网盘 - API参数获取失败: $e',
              category: DebugCategory.tools,
              subCategory: 'cloudDrive.account',
            );
            // 参数获取失败不影响账号添加，只记录警告
          }
          break;
        case CloudDriveType.quark:
          // 夸克云盘：可以添加特定的初始化逻辑
          DebugService.log(
            '🔧 夸克云盘 - 无需特殊初始化',
            category: DebugCategory.tools,
            subCategory: 'cloudDrive.account',
          );
          break;
        case CloudDriveType.lanzou:
        case CloudDriveType.pan123:
        case CloudDriveType.ali:
          // 其他云盘：暂无特殊初始化需求
          DebugService.log(
            '🔧 ${account.type.displayName} - 无需特殊初始化',
            category: DebugCategory.tools,
            subCategory: 'cloudDrive.account',
          );
          break;
      }

      DebugService.log(
        '✅ 账号初始化完成: ${account.type.displayName}',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.account',
      );
    } catch (e) {
      DebugService.log(
        '⚠️ 账号初始化过程中发生异常: $e',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.account',
      );
      // 初始化失败不影响账号添加
    }
  }

  /// 删除账号
  Future<void> deleteAccount(String accountId) async {
    try {
      await CloudDriveAccountService.deleteAccount(accountId);
      await loadAccounts(); // 重新加载账号列表
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 更新账号
  Future<void> updateAccount(CloudDriveAccount account) async {
    try {
      await CloudDriveAccountService.updateAccount(account);
      await loadAccounts(); // 重新加载账号列表
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 更新账号Cookie
  void updateAccountCookie(String accountId, String newCookies) {
    final accounts =
        state.accounts.map((account) {
          if (account.id == accountId) {
            final updatedAccount = account.copyWith(cookies: newCookies);

            // 清除百度网盘参数缓存
            if (account.type == CloudDriveType.baidu) {
              BaiduCloudDriveService.clearParamCache(accountId);
            }

            return updatedAccount;
          }
          return account;
        }).toList();

    state = state.copyWith(accounts: accounts);
    CloudDriveAccountService.saveAccounts(accounts);
  }

  /// 切换账号选择器显示状态
  void toggleAccountSelector() {
    state = state.copyWith(showAccountSelector: !state.showAccountSelector);
  }

  /// 添加文件到状态（复制/移动成功后调用）
  void addFileToState(CloudDriveFile file, {String? operationType}) {
    DebugService.log(
      '➕ 添加文件到状态: ${file.name} (${file.isFolder ? '文件夹' : '文件'})',
    );
    DebugService.log('🔧 操作类型: ${operationType ?? 'unknown'}');

    final currentState = state;
    final account = currentState.currentAccount;

    if (account == null) {
      DebugService.log('❌ 无法添加文件到状态：当前账号为空');
      return;
    }

    // 使用策略模式获取当前目录路径
    final currentPath = CloudDriveOperationService.convertPathToTargetFolderId(
      cloudDriveType: account.type,
      folderPath: currentState.folderPath,
    );

    // 使用策略模式更新文件的路径信息
    final updatedFile =
        CloudDriveOperationService.updateFilePathForTargetDirectory(
          cloudDriveType: account.type,
          file: file,
          targetPath: currentPath,
        );

    if (updatedFile.isFolder) {
      // 添加到文件夹列表
      final updatedFolders = [...currentState.folders, updatedFile];
      state = currentState.copyWith(folders: updatedFolders);
      DebugService.log('✅ 文件夹已添加到状态，总文件夹数: ${updatedFolders.length}');
    } else {
      // 添加到文件列表
      final updatedFiles = [...currentState.files, updatedFile];
      state = currentState.copyWith(files: updatedFiles);
      DebugService.log('✅ 文件已添加到状态，总文件数: ${updatedFiles.length}');
    }
  }

  /// 从本地状态中移除文件（删除成功后调用）
  void removeFileFromState(String fileId) {
    DebugService.log('🗑️ 从状态中移除文件: $fileId');

    final currentState = state;
    final updatedFiles =
        currentState.files.where((file) => file.id != fileId).toList();
    final updatedFolders =
        currentState.folders.where((folder) => folder.id != fileId).toList();

    state = currentState.copyWith(files: updatedFiles, folders: updatedFolders);

    DebugService.log(
      '✅ 文件已从状态中移除，剩余文件数: ${updatedFiles.length}，文件夹数: ${updatedFolders.length}',
    );
  }

  /// 从本地状态中移除文件夹（移动成功后调用）
  void removeFolderFromState(String folderId) {
    DebugService.log('🗑️ 从状态中移除文件夹: $folderId');

    final currentState = state;
    final updatedFolders =
        currentState.folders.where((folder) => folder.id != folderId).toList();

    state = currentState.copyWith(folders: updatedFolders);

    DebugService.log('✅ 文件夹已从状态中移除，剩余文件夹数: ${updatedFolders.length}');
  }

  /// 更新文件信息（重命名成功后调用）
  void updateFileInState(String fileId, String newName) {
    DebugService.log('✏️ 更新文件信息: $fileId -> $newName');

    final currentState = state;

    // 更新文件列表
    final updatedFiles =
        currentState.files.map((file) {
          if (file.id == fileId) {
            return file.copyWith(name: newName);
          }
          return file;
        }).toList();

    // 更新文件夹列表
    final updatedFolders =
        currentState.folders.map((folder) {
          if (folder.id == fileId) {
            return folder.copyWith(name: newName);
          }
          return folder;
        }).toList();

    state = currentState.copyWith(files: updatedFiles, folders: updatedFolders);

    DebugService.log('✅ 文件信息已更新');
  }

  /// 设置待操作文件（复制/移动）
  void setPendingOperation(CloudDriveFile file, String operationType) {
    DebugService.log('🎯 设置待操作文件: ${file.name} ($operationType)');

    state = state.copyWith(
      pendingOperationFile: file,
      pendingOperationType: operationType,
      showFloatingActionButton: true,
    );
  }

  /// 清除待操作文件
  void clearPendingOperation() {
    DebugService.log('🧹 清除待操作文件');

    state = state.copyWith(
      pendingOperationFile: null,
      pendingOperationType: null,
      showFloatingActionButton: false,
    );
  }

  /// 执行待操作（复制/移动到当前目录）
  Future<bool> executePendingOperation() async {
    final file = state.pendingOperationFile;
    final operationType = state.pendingOperationType;
    final account = state.currentAccount;

    DebugService.log('🚀 executePendingOperation 开始执行');
    DebugService.log(
      '📄 文件信息: ${file?.name ?? 'null'} (ID: ${file?.id ?? 'null'})',
    );
    DebugService.log('🔧 操作类型: ${operationType ?? 'null'}');
    DebugService.log(
      '👤 账号信息: ${account?.name ?? 'null'} (${account?.type.displayName ?? 'null'})',
    );

    if (file == null || operationType == null || account == null) {
      DebugService.log('❌ 待操作信息不完整');
      DebugService.log('📄 file: ${file?.name ?? 'null'}');
      DebugService.log('🔧 operationType: ${operationType ?? 'null'}');
      DebugService.log('👤 account: ${account?.name ?? 'null'}');
      return false;
    }

    DebugService.log('✅ 参数验证通过');

    // 获取当前目录路径或ID - 使用策略模式解耦
    final targetFolderId =
        CloudDriveOperationService.convertPathToTargetFolderId(
          cloudDriveType: account.type,
          folderPath: state.folderPath,
        );

    DebugService.log('📁 目标文件夹ID: $targetFolderId');
    DebugService.log('📂 当前文件夹路径: ${state.folderPath}');

    try {
      bool success = false;

      if (operationType == 'copy') {
        DebugService.log('📋 开始执行复制操作');
        success = await CloudDriveOperationService.copyFile(
          account: account,
          file: file,
          destPath: targetFolderId,
        );
        DebugService.log('📋 复制操作结果: $success');
      } else if (operationType == 'move') {
        DebugService.log('📋 开始执行移动操作');
        success = await CloudDriveOperationService.moveFile(
          account: account,
          file: file,
          targetFolderId: targetFolderId,
        );
        DebugService.log('📋 移动操作结果: $success');
      } else {
        DebugService.log('❌ 未知的操作类型: $operationType');
        return false;
      }

      if (success) {
        DebugService.log('✅ 操作执行成功');

        // 对于复制操作，直接添加文件到当前状态（如果目标是当前目录）
        if (operationType == 'copy') {
          DebugService.log('📋 复制操作成功，直接添加文件到当前状态');
          addFileToState(file, operationType: operationType);
        } else if (operationType == 'move') {
          // 对于移动操作，也添加文件到当前状态（如果目标是当前目录）
          DebugService.log('📋 移动操作成功，直接添加文件到当前状态');
          addFileToState(file, operationType: operationType);
        }

        DebugService.log('🧹 开始清除待操作状态');
        // 清除待操作状态
        clearPendingOperation();

        // 不再需要重新加载整个目录，因为已经直接更新了状态
        DebugService.log('✅ 状态更新完成，无需重新加载目录');
        return true;
      } else {
        DebugService.log('❌ 操作执行失败');
        DebugService.log('📄 失败的文件: ${file.name}');
        DebugService.log('🔧 失败的操作: $operationType');
        DebugService.log('📁 目标路径: $targetFolderId');
        return false;
      }
    } catch (e) {
      DebugService.error('❌ 执行操作异常', e);
      DebugService.log('📄 异常的文件: ${file.name}');
      DebugService.log('🔧 异常的操作: $operationType');
      DebugService.log('📁 目标路径: $targetFolderId');
      return false;
    } finally {
      DebugService.log('🚀 executePendingOperation 执行结束');
    }
  }
}

/// Provider 定义
final cloudDriveProvider =
    StateNotifierProvider<CloudDriveNotifier, CloudDriveState>(
      (ref) => CloudDriveNotifier(),
    );

/// 文件类型图标缓存 Provider
final fileTypeIconProvider = Provider.family<IconData, String>(
  (ref, fileName) => _getFileTypeIcon(fileName),
);

/// 文件类型颜色缓存 Provider
final fileTypeColorProvider = Provider.family<Color, String>(
  (ref, fileName) => _getFileTypeColor(fileName),
);

/// 获取文件类型图标（缓存版本）
IconData _getFileTypeIcon(String fileName) {
  final extension = fileName.split('.').last.toLowerCase();
  switch (extension) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'doc':
    case 'docx':
      return Icons.description;
    case 'xls':
    case 'xlsx':
      return Icons.table_chart;
    case 'ppt':
    case 'pptx':
      return Icons.slideshow;
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
      return Icons.image;
    case 'mp4':
    case 'avi':
    case 'mov':
      return Icons.video_file;
    case 'mp3':
    case 'wav':
      return Icons.audio_file;
    case 'zip':
    case 'rar':
    case '7z':
      return Icons.archive;
    default:
      return Icons.insert_drive_file;
  }
}

/// 获取文件类型颜色（缓存版本）
Color _getFileTypeColor(String fileName) {
  final extension = fileName.split('.').last.toLowerCase();
  switch (extension) {
    case 'pdf':
      return Colors.red;
    case 'doc':
    case 'docx':
      return Colors.blue;
    case 'xls':
    case 'xlsx':
      return Colors.green;
    case 'ppt':
    case 'pptx':
      return Colors.orange;
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
      return Colors.purple;
    case 'mp4':
    case 'avi':
    case 'mov':
      return Colors.indigo;
    case 'mp3':
    case 'wav':
      return Colors.teal;
    case 'zip':
    case 'rar':
    case '7z':
      return Colors.amber;
    default:
      return Colors.grey;
  }
}
