// import 'package:flutter/material.dart'; // 未使用
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
// import '../../core/result.dart'; // 未使用

enum CloudDriveSortField {
  name,
  createdTime,
  modifiedTime,
  size,
  downloadCount,
}

enum CloudDriveViewMode {
  list,
  grid,
}

/// 云盘状态模型 - 使用 freezed 风格设计
class CloudDriveState {
  final AccountViewState accountState;
  final CloudDriveFile? currentFolder;
  final List<CloudDriveFile> folders;
  final List<CloudDriveFile> files;
  final List<PathInfo> folderPath;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final bool isBatchMode;
  final bool isInBatchMode;
  final Set<String> selectedItems;
  final bool isAllSelected;
  final int currentPage;
  final bool hasMoreData;
  final bool isLoadingMore;
  final bool isFromCache;
  final DateTime? lastRefreshTime;
  final CloudDriveFile? pendingOperationFile;
  final String? pendingOperationType;
  final bool showFloatingActionButton;
  final CloudDriveSortField sortField;
  final bool isSortAscending;
  final CloudDriveViewMode viewMode;

  const CloudDriveState({
    this.accountState = const AccountViewState(),
    this.currentFolder,
    this.folders = const [],
    this.files = const [],
    this.folderPath = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.isBatchMode = false,
    this.isInBatchMode = false,
    this.selectedItems = const {},
    this.isAllSelected = false,
    this.currentPage = 1,
    this.hasMoreData = true,
    this.isLoadingMore = false,
    this.isFromCache = false,
    this.lastRefreshTime,
    this.pendingOperationFile,
    this.pendingOperationType,
    this.showFloatingActionButton = false,
    this.sortField = CloudDriveSortField.name,
    this.isSortAscending = true,
    this.viewMode = CloudDriveViewMode.list,
  });

  /// 复制并更新状态
  CloudDriveState copyWith({
    AccountViewState? accountState,
    List<CloudDriveAccount>? accounts,
    Map<String, CloudDriveAccountDetails>? accountDetails,
    CloudDriveAccount? currentAccount,
    CloudDriveFile? currentFolder,
    List<CloudDriveFile>? folders,
    List<CloudDriveFile>? files,
    List<PathInfo>? folderPath,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool? isBatchMode,
    bool? isInBatchMode,
    Set<String>? selectedItems,
    bool? isAllSelected,
    int? currentPage,
    bool? hasMoreData,
    bool? isLoadingMore,
    bool? isFromCache,
    DateTime? lastRefreshTime,
    bool? showAccountSelector,
    CloudDriveFile? pendingOperationFile,
    String? pendingOperationType,
    bool? showFloatingActionButton,
    CloudDriveSortField? sortField,
    bool? isSortAscending,
    CloudDriveViewMode? viewMode,
  }) {
    // 合并账号子状态，兼容旧参数（accounts/accountDetails/currentAccount/showAccountSelector）
    AccountViewState mergedAccountState = accountState ?? this.accountState;
    if (accounts != null ||
        accountDetails != null ||
        currentAccount != null ||
        showAccountSelector != null) {
      mergedAccountState = mergedAccountState.copyWith(
        accounts: accounts,
        accountDetails: accountDetails,
        currentAccount: currentAccount,
        showAccountSelector: showAccountSelector,
      );
    }

    return CloudDriveState(
      accountState: mergedAccountState,
      currentFolder: currentFolder ?? this.currentFolder,
      folders: folders ?? this.folders,
      files: files ?? this.files,
      folderPath: folderPath ?? this.folderPath,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error ?? this.error,
      isBatchMode: isBatchMode ?? this.isBatchMode,
      isInBatchMode: isInBatchMode ?? this.isInBatchMode,
      selectedItems: selectedItems ?? this.selectedItems,
      isAllSelected: isAllSelected ?? this.isAllSelected,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFromCache: isFromCache ?? this.isFromCache,
      lastRefreshTime: lastRefreshTime ?? this.lastRefreshTime,
      pendingOperationFile: pendingOperationFile ?? this.pendingOperationFile,
      pendingOperationType: pendingOperationType ?? this.pendingOperationType,
      showFloatingActionButton:
          showFloatingActionButton ?? this.showFloatingActionButton,
      sortField: sortField ?? this.sortField,
      isSortAscending: isSortAscending ?? this.isSortAscending,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  // 兼容旧字段访问
  List<CloudDriveAccount> get accounts => accountState.accounts;
  Map<String, CloudDriveAccountDetails> get accountDetails =>
      accountState.accountDetails;
  CloudDriveAccount? get currentAccount => accountState.currentAccount;
  bool get showAccountSelector => accountState.showAccountSelector;

  /// 获取所有项目（文件夹+文件）
  List<CloudDriveFile> get allItems => [...folders, ...files];

  /// 获取选中的文件夹
  List<CloudDriveFile> get selectedFolders =>
      folders.where((folder) => selectedItems.contains(folder.id)).toList();

  /// 获取选中的文件
  List<CloudDriveFile> get selectedFiles =>
      files.where((file) => selectedItems.contains(file.id)).toList();

  /// 检查是否全选
  bool get isAllSelectedComputed {
    final totalItems = folders.length + files.length;
    return totalItems > 0 && selectedItems.length == totalItems;
  }

  /// 获取当前账号索引
  int get currentAccountIndex {
    if (currentAccount == null || accounts.isEmpty) return -1;
    return accounts.indexWhere((account) => account.id == currentAccount!.id);
  }

  /// 检查是否有错误
  bool get hasError => error != null && error!.isNotEmpty;

  /// 检查是否正在加载
  bool get isBusy => isLoading || isRefreshing || isLoadingMore;

  /// 检查是否有数据
  bool get hasData => folders.isNotEmpty || files.isNotEmpty;

  /// 检查是否为空状态
  bool get isEmpty => !isLoading && !hasData && !hasError;

  /// 获取文件统计信息
  Map<String, int> get fileStats => {
    'total': allItems.length,
    'files': files.length,
    'folders': folders.length,
    'selected': selectedItems.length,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudDriveState &&
          runtimeType == other.runtimeType &&
          accountState == other.accountState &&
          folders == other.folders &&
          files == other.files &&
          folderPath == other.folderPath &&
          isLoading == other.isLoading &&
          isRefreshing == other.isRefreshing &&
          error == other.error &&
          isBatchMode == other.isBatchMode &&
          selectedItems == other.selectedItems &&
          isAllSelected == other.isAllSelected &&
          currentPage == other.currentPage &&
          hasMoreData == other.hasMoreData &&
          isLoadingMore == other.isLoadingMore &&
          isFromCache == other.isFromCache &&
          lastRefreshTime == other.lastRefreshTime &&
      pendingOperationFile == other.pendingOperationFile &&
      pendingOperationType == other.pendingOperationType &&
      showFloatingActionButton == other.showFloatingActionButton &&
      sortField == other.sortField &&
      isSortAscending == other.isSortAscending &&
      viewMode == other.viewMode;

  @override
  int get hashCode =>
      accountState.hashCode ^
      folders.hashCode ^
      files.hashCode ^
      folderPath.hashCode ^
      isLoading.hashCode ^
      isRefreshing.hashCode ^
      error.hashCode ^
      isBatchMode.hashCode ^
      selectedItems.hashCode ^
      isAllSelected.hashCode ^
      currentPage.hashCode ^
      hasMoreData.hashCode ^
      isLoadingMore.hashCode ^
      isFromCache.hashCode ^
      lastRefreshTime.hashCode ^
      pendingOperationFile.hashCode ^
      pendingOperationType.hashCode ^
      showFloatingActionButton.hashCode ^
      sortField.hashCode ^
      isSortAscending.hashCode ^
      viewMode.hashCode;

  @override
  String toString() =>
      'CloudDriveState{'
      'accounts: ${accounts.length}, '
      'currentAccount: ${currentAccount?.name}, '
      'folders: ${folders.length}, '
      'files: ${files.length}, '
      'isLoading: $isLoading, '
      'error: $error, '
      'isBatchMode: $isBatchMode, '
      'selectedItems: ${selectedItems.length}, '
      'sortField: $sortField, '
      'isSortAscending: $isSortAscending, '
      'viewMode: $viewMode'
      '}';
}

/// 账号子状态
class AccountViewState {
  final List<CloudDriveAccount> accounts;
  final Map<String, CloudDriveAccountDetails> accountDetails;
  final CloudDriveAccount? currentAccount;
  final bool showAccountSelector;

  const AccountViewState({
    this.accounts = const [],
    this.accountDetails = const {},
    this.currentAccount,
    this.showAccountSelector = false,
  });

  AccountViewState copyWith({
    List<CloudDriveAccount>? accounts,
    Map<String, CloudDriveAccountDetails>? accountDetails,
    CloudDriveAccount? currentAccount,
    bool? showAccountSelector,
  }) => AccountViewState(
    accounts: accounts ?? this.accounts,
    accountDetails: accountDetails ?? this.accountDetails,
    currentAccount: currentAccount ?? this.currentAccount,
    showAccountSelector: showAccountSelector ?? this.showAccountSelector,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountViewState &&
          runtimeType == other.runtimeType &&
          accounts == other.accounts &&
          accountDetails == other.accountDetails &&
          currentAccount == other.currentAccount &&
          showAccountSelector == other.showAccountSelector;

  @override
  int get hashCode =>
      accounts.hashCode ^
      accountDetails.hashCode ^
      currentAccount.hashCode ^
      showAccountSelector.hashCode;
}

/// 文件列表状态
class FileListState {
  final List<CloudDriveFile> folders;
  final List<CloudDriveFile> files;
  final List<PathInfo> folderPath;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final int currentPage;
  final bool hasMoreData;
  final bool isLoadingMore;
  final bool isFromCache;
  final DateTime? lastRefreshTime;

  const FileListState({
    this.folders = const [],
    this.files = const [],
    this.folderPath = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.currentPage = 1,
    this.hasMoreData = true,
    this.isLoadingMore = false,
    this.isFromCache = false,
    this.lastRefreshTime,
  });

  /// 复制并更新状态
  FileListState copyWith({
    List<CloudDriveFile>? folders,
    List<CloudDriveFile>? files,
    List<PathInfo>? folderPath,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    int? currentPage,
    bool? hasMoreData,
    bool? isLoadingMore,
    bool? isFromCache,
    DateTime? lastRefreshTime,
  }) => FileListState(
    folders: folders ?? this.folders,
    files: files ?? this.files,
    folderPath: folderPath ?? this.folderPath,
    isLoading: isLoading ?? this.isLoading,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    error: error ?? this.error,
    currentPage: currentPage ?? this.currentPage,
    hasMoreData: hasMoreData ?? this.hasMoreData,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isFromCache: isFromCache ?? this.isFromCache,
    lastRefreshTime: lastRefreshTime ?? this.lastRefreshTime,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileListState &&
          runtimeType == other.runtimeType &&
          folders == other.folders &&
          files == other.files &&
          folderPath == other.folderPath &&
          isLoading == other.isLoading &&
          isRefreshing == other.isRefreshing &&
          error == other.error &&
          currentPage == other.currentPage &&
          hasMoreData == other.hasMoreData &&
          isLoadingMore == other.isLoadingMore &&
          isFromCache == other.isFromCache &&
          lastRefreshTime == other.lastRefreshTime;

  @override
  int get hashCode =>
      folders.hashCode ^
      files.hashCode ^
      folderPath.hashCode ^
      isLoading.hashCode ^
      isRefreshing.hashCode ^
      error.hashCode ^
      currentPage.hashCode ^
      hasMoreData.hashCode ^
      isLoadingMore.hashCode ^
      isFromCache.hashCode ^
      lastRefreshTime.hashCode;

  @override
  String toString() =>
      'FileListState{folders: ${folders.length}, files: ${files.length}, isLoading: $isLoading}';
}

/// 批量操作状态
class BatchOperationState {
  final bool isBatchMode;
  final Set<String> selectedItems;
  final bool isAllSelected;
  final bool isLoading;
  final String? error;

  const BatchOperationState({
    this.isBatchMode = false,
    this.selectedItems = const {},
    this.isAllSelected = false,
    this.isLoading = false,
    this.error,
  });

  /// 复制并更新状态
  BatchOperationState copyWith({
    bool? isBatchMode,
    Set<String>? selectedItems,
    bool? isAllSelected,
    bool? isLoading,
    String? error,
  }) => BatchOperationState(
    isBatchMode: isBatchMode ?? this.isBatchMode,
    selectedItems: selectedItems ?? this.selectedItems,
    isAllSelected: isAllSelected ?? this.isAllSelected,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );

  /// 获取选中项目数量
  int get selectedCount => selectedItems.length;

  /// 检查是否有选中项目
  bool get hasSelectedItems => selectedItems.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchOperationState &&
          runtimeType == other.runtimeType &&
          isBatchMode == other.isBatchMode &&
          selectedItems == other.selectedItems &&
          isAllSelected == other.isAllSelected &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode =>
      isBatchMode.hashCode ^
      selectedItems.hashCode ^
      isAllSelected.hashCode ^
      isLoading.hashCode ^
      error.hashCode;

  @override
  String toString() =>
      'BatchOperationState{isBatchMode: $isBatchMode, selectedCount: ${selectedItems.length}}';
}
