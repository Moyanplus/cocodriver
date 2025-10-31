import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/cloud_drive_state_manager.dart';
import '../state/cloud_drive_state_model.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import '../../utils/file_type_utils.dart';

/// 云盘状态管理器 Provider
final cloudDriveStateManagerProvider =
    StateNotifierProvider<CloudDriveStateManager, CloudDriveState>(
      (ref) => CloudDriveStateManager(),
    );

/// 云盘状态 Provider - 简化访问
final cloudDriveProvider = cloudDriveStateManagerProvider;

/// 云盘事件处理器 Provider
final cloudDriveEventHandlerProvider = Provider<CloudDriveEventHandler>(
  (ref) => CloudDriveEventHandler(ref),
);

/// 云盘事件处理器 - 简化事件处理
class CloudDriveEventHandler {
  final Ref _ref;

  CloudDriveEventHandler(this._ref);

  /// 获取状态管理器
  CloudDriveStateManager get _stateManager =>
      _ref.read(cloudDriveStateManagerProvider.notifier);

  /// 加载账号列表
  Future<void> loadAccounts() =>
      _stateManager.handleEvent(const LoadAccountsEvent());

  /// 切换账号
  Future<void> switchAccount(int index) =>
      _stateManager.handleEvent(SwitchAccountEvent(index));

  /// 加载文件夹
  Future<void> loadFolder({bool forceRefresh = false}) =>
      _stateManager.handleEvent(LoadFolderEvent(forceRefresh: forceRefresh));

  /// 进入文件夹
  Future<void> enterFolder(CloudDriveFile folder) =>
      _stateManager.handleEvent(EnterFolderEvent(folder));

  /// 返回上级
  Future<void> goBack() => _stateManager.handleEvent(const GoBackEvent());

  /// 跳转到路径中的指定位置
  Future<void> navigateToPathIndex(int pathIndex) =>
      _stateManager.navigateToPathIndex(pathIndex);

  /// 进入批量模式
  void enterBatchMode(String itemId) =>
      _stateManager.handleEvent(EnterBatchModeEvent(itemId));

  /// 退出批量模式
  void exitBatchMode() => _stateManager.handleEvent(const ExitBatchModeEvent());

  /// 切换选择状态
  void toggleSelection(String itemId) =>
      _stateManager.handleEvent(ToggleSelectionEvent(itemId));

  /// 切换全选状态
  void toggleSelectAll() =>
      _stateManager.handleEvent(const ToggleSelectAllEvent());

  /// 批量下载
  Future<void> batchDownload() =>
      _stateManager.handleEvent(const BatchDownloadEvent());

  /// 批量分享
  Future<void> batchShare() =>
      _stateManager.handleEvent(const BatchShareEvent());

  /// 加载更多
  Future<void> loadMore() => _stateManager.handleEvent(const LoadMoreEvent());

  /// 添加账号
  Future<void> addAccount(CloudDriveAccount account) =>
      _stateManager.handleEvent(AddAccountEvent(account));

  /// 删除账号
  Future<void> deleteAccount(String accountId) =>
      _stateManager.handleEvent(DeleteAccountEvent(accountId));

  /// 更新账号
  Future<void> updateAccount(CloudDriveAccount account) =>
      _stateManager.handleEvent(UpdateAccountEvent(account));

  /// 更新账号Cookie
  void updateAccountCookie(String accountId, String newCookies) => _stateManager
      .handleEvent(UpdateAccountCookieEvent(accountId, newCookies));

  /// 切换账号选择器
  void toggleAccountSelector() =>
      _stateManager.handleEvent(const ToggleAccountSelectorEvent());

  /// 设置待操作文件
  void setPendingOperation(CloudDriveFile file, String operationType) =>
      _stateManager.handleEvent(SetPendingOperationEvent(file, operationType));

  /// 清除待操作文件
  void clearPendingOperation() =>
      _stateManager.handleEvent(const ClearPendingOperationEvent());

  /// 执行待操作
  Future<void> executePendingOperation() =>
      _stateManager.handleEvent(const ExecutePendingOperationEvent());

  /// 添加文件到状态
  void addFileToState(CloudDriveFile file, {String? operationType}) =>
      _stateManager.handleEvent(
        AddFileToStateEvent(file, operationType: operationType),
      );

  /// 从状态移除文件
  void removeFileFromState(String fileId) =>
      _stateManager.handleEvent(RemoveFileFromStateEvent(fileId));

  /// 从状态移除文件夹
  void removeFolderFromState(String folderId) =>
      _stateManager.handleEvent(RemoveFolderFromStateEvent(folderId));

  /// 更新文件信息
  void updateFileInState(String fileId, String newName) =>
      _stateManager.handleEvent(UpdateFileInStateEvent(fileId, newName));

  /// 清除错误
  void clearError() => _stateManager.handleEvent(const ClearErrorEvent());
}

/// 文件类型图标缓存 Provider
final fileTypeIconProvider = Provider.family<IconData, String>(
  (ref, fileName) => FileTypeUtils.getFileTypeIcon(fileName),
);

/// 文件类型颜色缓存 Provider
final fileTypeColorProvider = Provider.family<Color, String>(
  (ref, fileName) => FileTypeUtils.getFileTypeColor(fileName),
);

/// 文件类型信息缓存 Provider
final fileTypeInfoProvider = Provider.family<FileTypeInfo, String>(
  (ref, fileName) => FileTypeUtils.getFileTypeInfo(fileName),
);

/// 当前账号 Provider
final currentAccountProvider = Provider<CloudDriveAccount?>(
  (ref) => ref.watch(cloudDriveProvider).currentAccount,
);

/// 当前文件夹内容 Provider
final currentFolderContentProvider =
    Provider<Map<String, List<CloudDriveFile>>>((ref) {
      final state = ref.watch(cloudDriveProvider);
      return {'folders': state.folders, 'files': state.files};
    });

/// 文件统计信息 Provider
final fileStatsProvider = Provider<Map<String, int>>(
  (ref) => ref.watch(cloudDriveProvider).fileStats,
);

/// 批量模式状态 Provider
final batchModeProvider = Provider<bool>(
  (ref) => ref.watch(cloudDriveProvider).isBatchMode,
);

/// 选中项目 Provider
final selectedItemsProvider = Provider<Set<String>>(
  (ref) => ref.watch(cloudDriveProvider).selectedItems,
);

/// 选中文件 Provider
final selectedFilesProvider = Provider<List<CloudDriveFile>>(
  (ref) => ref.watch(cloudDriveProvider).selectedFiles,
);

/// 选中文件夹 Provider
final selectedFoldersProvider = Provider<List<CloudDriveFile>>(
  (ref) => ref.watch(cloudDriveProvider).selectedFolders,
);

/// 加载状态 Provider
final loadingStateProvider = Provider<Map<String, bool>>((ref) {
  final state = ref.watch(cloudDriveProvider);
  return {
    'isLoading': state.isLoading,
    'isRefreshing': state.isRefreshing,
    'isLoadingMore': state.isLoadingMore,
    'isBusy': state.isBusy,
  };
});

/// 错误状态 Provider
final errorStateProvider = Provider<String?>(
  (ref) => ref.watch(cloudDriveProvider).error,
);

/// 路径导航 Provider
final pathNavigationProvider = Provider<List<PathInfo>>(
  (ref) => ref.watch(cloudDriveProvider).folderPath,
);

/// 待操作文件 Provider
final pendingOperationProvider = Provider<Map<String, dynamic>?>((ref) {
  final state = ref.watch(cloudDriveProvider);
  if (state.pendingOperationFile == null) return null;

  return {
    'file': state.pendingOperationFile,
    'operationType': state.pendingOperationType,
    'showFloatingActionButton': state.showFloatingActionButton,
  };
});

/// 账号选择器状态 Provider
final accountSelectorProvider = Provider<bool>(
  (ref) => ref.watch(cloudDriveProvider).showAccountSelector,
);

/// 缓存状态 Provider
final cacheStateProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(cloudDriveProvider);
  return {
    'isFromCache': state.isFromCache,
    'lastRefreshTime': state.lastRefreshTime,
  };
});

/// 分页状态 Provider
final paginationProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(cloudDriveProvider);
  return {'currentPage': state.currentPage, 'hasMoreData': state.hasMoreData};
});
