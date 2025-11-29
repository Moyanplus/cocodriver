import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/logging/cloud_drive_logger_adapter.dart';
import '../state/cloud_drive_state_manager.dart';
import '../state/cloud_drive_state_model.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import '../../utils/file_type_utils.dart';
import '../state/handlers/account_state_handler.dart';
import '../state/handlers/folder_state_handler.dart';
import '../state/handlers/batch_operation_handler.dart';
import '../../base/cloud_drive_service_gateway.dart';

typedef _HandlerBuilder<T> = T Function(CloudDriveStateManager manager);

final cloudDriveLoggerProvider = Provider<CloudDriveLoggerAdapter>(
  (ref) => DefaultCloudDriveLoggerAdapter(),
);

final accountHandlerBuilderProvider =
    Provider<_HandlerBuilder<AccountStateHandler>>((ref) {
      final logger = ref.watch(cloudDriveLoggerProvider);
      return (manager) => AccountStateHandler(manager, logger: logger);
    });

final folderHandlerBuilderProvider =
    Provider<_HandlerBuilder<FolderStateHandler>>((ref) {
      final logger = ref.watch(cloudDriveLoggerProvider);
      final gateway = ref.watch(cloudDriveGatewayProvider);
      return (manager) => FolderStateHandler(
        manager,
        logger: logger,
        gateway: gateway,
      );
    });

final batchHandlerBuilderProvider =
    Provider<_HandlerBuilder<BatchOperationHandler>>((ref) {
      final logger = ref.watch(cloudDriveLoggerProvider);
      final gateway = ref.watch(cloudDriveGatewayProvider);
      return (manager) => BatchOperationHandler(
        manager,
        logger: logger,
        gateway: gateway,
      );
    });

final pendingHandlerBuilderProvider =
    Provider<_HandlerBuilder<PendingOperationHandler>>((ref) {
      final gateway = ref.watch(cloudDriveGatewayProvider);
      return (manager) => PendingOperationHandler(manager, gateway: gateway);
    });

/// 云盘服务网关 Provider（可在测试/特定环境替换）
final cloudDriveGatewayProvider = Provider<CloudDriveServiceGateway>(
  (ref) => defaultCloudDriveGateway,
);

/// 云盘状态管理器 Provider
final cloudDriveStateManagerProvider =
    StateNotifierProvider<CloudDriveStateManager, CloudDriveState>(
      (ref) => CloudDriveStateManager(
        logger: ref.watch(cloudDriveLoggerProvider),
        accountHandlerBuilder: ref.watch(accountHandlerBuilderProvider),
        folderHandlerBuilder: ref.watch(folderHandlerBuilderProvider),
        batchHandlerBuilder: ref.watch(batchHandlerBuilderProvider),
        pendingHandlerBuilder: ref.watch(pendingHandlerBuilderProvider),
      ),
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

  /// 创建文件夹
  Future<bool> createFolder({
    required String name,
    required String parentId,
  }) =>
      _stateManager.createFolder(name: name, parentId: parentId);

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

  /// 更新文件元数据（进度等）
  void updateFileMetadata(
    String fileId,
    Map<String, dynamic>? Function(Map<String, dynamic>?) updater,
  ) => _stateManager.updateFileMetadata(fileId, updater);

  /// 更新文件信息
  void updateFileInState(String fileId, String newName) =>
      _stateManager.handleEvent(UpdateFileInStateEvent(fileId, newName));

  /// 清除错误
  void clearError() => _stateManager.handleEvent(const ClearErrorEvent());

  /// 更新排序选项
  void updateSortOption(CloudDriveSortField field, bool ascending) =>
      _stateManager.handleEvent(UpdateSortOptionEvent(field, ascending));

  /// 更新视图模式
  void updateViewMode(CloudDriveViewMode mode) =>
      _stateManager.handleEvent(UpdateViewModeEvent(mode));
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
