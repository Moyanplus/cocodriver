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
  final List<CloudDriveAccount> accounts;
  final CloudDriveAccount? currentAccount;
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
  final bool showAccountSelector;
  final CloudDriveFile? pendingOperationFile;
  final String? pendingOperationType;
  final bool showFloatingActionButton;
  final CloudDriveSortField sortField;
  final bool isSortAscending;
  final CloudDriveViewMode viewMode;

  const CloudDriveState({
    this.accounts = const [],
    this.currentAccount,
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
    this.showAccountSelector = false,
    this.pendingOperationFile,
    this.pendingOperationType,
    this.showFloatingActionButton = false,
    this.sortField = CloudDriveSortField.name,
    this.isSortAscending = true,
    this.viewMode = CloudDriveViewMode.list,
  });

  /// 复制并更新状态
  CloudDriveState copyWith({
    List<CloudDriveAccount>? accounts,
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
  }) => CloudDriveState(
    accounts: accounts ?? this.accounts,
    currentAccount: currentAccount ?? this.currentAccount,
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
    showAccountSelector: showAccountSelector ?? this.showAccountSelector,
    pendingOperationFile: pendingOperationFile ?? this.pendingOperationFile,
    pendingOperationType: pendingOperationType ?? this.pendingOperationType,
    showFloatingActionButton:
        showFloatingActionButton ?? this.showFloatingActionButton,
    sortField: sortField ?? this.sortField,
    isSortAscending: isSortAscending ?? this.isSortAscending,
    viewMode: viewMode ?? this.viewMode,
  );

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
          accounts == other.accounts &&
          currentAccount == other.currentAccount &&
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
          showAccountSelector == other.showAccountSelector &&
      pendingOperationFile == other.pendingOperationFile &&
      pendingOperationType == other.pendingOperationType &&
      showFloatingActionButton == other.showFloatingActionButton &&
      sortField == other.sortField &&
      isSortAscending == other.isSortAscending &&
      viewMode == other.viewMode;

  @override
  int get hashCode =>
      accounts.hashCode ^
      currentAccount.hashCode ^
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
      showAccountSelector.hashCode ^
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

/// 云盘状态事件
sealed class CloudDriveEvent {
  const CloudDriveEvent();
}

/// 加载账号事件
class LoadAccountsEvent extends CloudDriveEvent {
  const LoadAccountsEvent();
}

/// 切换账号事件
class SwitchAccountEvent extends CloudDriveEvent {
  final int accountIndex;
  const SwitchAccountEvent(this.accountIndex);
}

/// 加载文件夹事件
class LoadFolderEvent extends CloudDriveEvent {
  final bool forceRefresh;
  const LoadFolderEvent({this.forceRefresh = false});
}

/// 进入文件夹事件
class EnterFolderEvent extends CloudDriveEvent {
  final CloudDriveFile folder;
  const EnterFolderEvent(this.folder);
}

/// 返回上级事件
class GoBackEvent extends CloudDriveEvent {
  const GoBackEvent();
}

/// 进入批量模式事件
class EnterBatchModeEvent extends CloudDriveEvent {
  final String itemId;
  const EnterBatchModeEvent(this.itemId);
}

/// 退出批量模式事件
class ExitBatchModeEvent extends CloudDriveEvent {
  const ExitBatchModeEvent();
}

/// 切换选择状态事件
class ToggleSelectionEvent extends CloudDriveEvent {
  final String itemId;
  const ToggleSelectionEvent(this.itemId);
}

/// 切换全选状态事件
class ToggleSelectAllEvent extends CloudDriveEvent {
  const ToggleSelectAllEvent();
}

/// 批量下载事件
class BatchDownloadEvent extends CloudDriveEvent {
  const BatchDownloadEvent();
}

/// 批量分享事件
class BatchShareEvent extends CloudDriveEvent {
  const BatchShareEvent();
}

/// 加载更多事件
class LoadMoreEvent extends CloudDriveEvent {
  const LoadMoreEvent();
}

/// 添加账号事件
class AddAccountEvent extends CloudDriveEvent {
  final CloudDriveAccount account;
  const AddAccountEvent(this.account);
}

/// 删除账号事件
class DeleteAccountEvent extends CloudDriveEvent {
  final String accountId;
  const DeleteAccountEvent(this.accountId);
}

/// 更新账号事件
class UpdateAccountEvent extends CloudDriveEvent {
  final CloudDriveAccount account;
  const UpdateAccountEvent(this.account);
}

/// 更新账号Cookie事件
class UpdateAccountCookieEvent extends CloudDriveEvent {
  final String accountId;
  final String newCookies;
  const UpdateAccountCookieEvent(this.accountId, this.newCookies);
}

/// 切换账号选择器事件
class ToggleAccountSelectorEvent extends CloudDriveEvent {
  const ToggleAccountSelectorEvent();
}

/// 设置待操作文件事件
class SetPendingOperationEvent extends CloudDriveEvent {
  final CloudDriveFile file;
  final String operationType;
  const SetPendingOperationEvent(this.file, this.operationType);
}

/// 清除待操作文件事件
class ClearPendingOperationEvent extends CloudDriveEvent {
  const ClearPendingOperationEvent();
}

/// 执行待操作事件
class ExecutePendingOperationEvent extends CloudDriveEvent {
  const ExecutePendingOperationEvent();
}

/// 添加文件到状态事件
class AddFileToStateEvent extends CloudDriveEvent {
  final CloudDriveFile file;
  final String? operationType;
  const AddFileToStateEvent(this.file, {this.operationType});
}

/// 从状态移除文件事件
class RemoveFileFromStateEvent extends CloudDriveEvent {
  final String fileId;
  const RemoveFileFromStateEvent(this.fileId);
}

/// 从状态移除文件夹事件
class RemoveFolderFromStateEvent extends CloudDriveEvent {
  final String folderId;
  const RemoveFolderFromStateEvent(this.folderId);
}

/// 更新文件信息事件
class UpdateFileInStateEvent extends CloudDriveEvent {
  final String fileId;
  final String newName;
  const UpdateFileInStateEvent(this.fileId, this.newName);
}

/// 清除错误事件
class ClearErrorEvent extends CloudDriveEvent {
  const ClearErrorEvent();
}

/// 刷新事件
class RefreshEvent extends CloudDriveEvent {
  const RefreshEvent();
}

/// 更新排序选项事件
class UpdateSortOptionEvent extends CloudDriveEvent {
  final CloudDriveSortField field;
  final bool ascending;
  const UpdateSortOptionEvent(this.field, this.ascending);
}

/// 更新视图模式事件
class UpdateViewModeEvent extends CloudDriveEvent {
  final CloudDriveViewMode mode;
  const UpdateViewModeEvent(this.mode);
}

/// 批量删除事件
class BatchDeleteEvent extends CloudDriveEvent {
  const BatchDeleteEvent();
}

/// 创建文件夹事件
class CreateFolderEvent extends CloudDriveEvent {
  final String name;
  final String parentId;
  const CreateFolderEvent({required this.name, required this.parentId});
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

/// 账号状态
class AccountState {
  final List<CloudDriveAccount> accounts;
  final int currentAccountIndex;
  final bool isLoading;
  final String? error;
  final bool showAccountSelector;

  const AccountState({
    this.accounts = const [],
    this.currentAccountIndex = -1,
    this.isLoading = false,
    this.error,
    this.showAccountSelector = false,
  });

  /// 复制并更新状态
  AccountState copyWith({
    List<CloudDriveAccount>? accounts,
    int? currentAccountIndex,
    bool? isLoading,
    String? error,
    bool? showAccountSelector,
  }) => AccountState(
    accounts: accounts ?? this.accounts,
    currentAccountIndex: currentAccountIndex ?? this.currentAccountIndex,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
    showAccountSelector: showAccountSelector ?? this.showAccountSelector,
  );

  /// 获取当前账号
  CloudDriveAccount? get currentAccount {
    if (currentAccountIndex < 0 || currentAccountIndex >= accounts.length) {
      return null;
    }
    return accounts[currentAccountIndex];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountState &&
          runtimeType == other.runtimeType &&
          accounts == other.accounts &&
          currentAccountIndex == other.currentAccountIndex &&
          isLoading == other.isLoading &&
          error == other.error &&
          showAccountSelector == other.showAccountSelector;

  @override
  int get hashCode =>
      accounts.hashCode ^
      currentAccountIndex.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      showAccountSelector.hashCode;

  @override
  String toString() =>
      'AccountState{accounts: ${accounts.length}, currentAccountIndex: $currentAccountIndex}';
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
