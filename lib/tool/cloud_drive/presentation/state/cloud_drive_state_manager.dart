import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import 'cloud_drive_state_model.dart';
import 'handlers/account_state_handler.dart';
import 'handlers/folder_state_handler.dart';
import 'handlers/batch_operation_handler.dart';

/// 云盘状态管理器
///
/// 使用 StateNotifier 管理云盘应用的状态，通过 Handler 模式分离不同模块的状态处理逻辑。
class CloudDriveStateManager extends StateNotifier<CloudDriveState> {
  CloudDriveStateManager() : super(const CloudDriveState()) {
    _initializeHandlers();
  }

  // 状态处理器
  late final AccountStateHandler accountHandler;
  late final FolderStateHandler folderHandler;
  late final BatchOperationHandler batchHandler;

  /// 初始化状态处理器
  void _initializeHandlers() {
    accountHandler = AccountStateHandler(this);
    folderHandler = FolderStateHandler(this);
    batchHandler = BatchOperationHandler(this);
  }

  /// 更新状态
  ///
  /// [updater] 状态更新函数，接收当前状态并返回新状态
  void updateState(CloudDriveState Function(CloudDriveState) updater) {
    state = updater(state);
  }

  /// 更新状态（直接设置）
  ///
  /// [newState] 新的状态对象
  void setState(CloudDriveState newState) {
    state = newState;
  }

  /// 获取当前状态
  CloudDriveState getCurrentState() => state;

  /// 处理云盘事件，将事件分发到对应的处理器
  ///
  /// [event] 要处理的云盘事件
  Future<void> handleEvent(CloudDriveEvent event) async {
    LogManager().cloudDrive('处理事件: ${event.runtimeType}');

    try {
      switch (event) {
        case LoadAccountsEvent():
          await accountHandler.loadAccounts();
        case SwitchAccountEvent():
          await accountHandler.switchAccount(event.accountIndex);
        case LoadFolderEvent():
          await folderHandler.loadFolder(forceRefresh: event.forceRefresh);
        case EnterFolderEvent():
          await folderHandler.enterFolder(event.folder);
        case GoBackEvent():
          await folderHandler.goBack();
        case EnterBatchModeEvent():
          batchHandler.enterBatchMode(event.itemId);
        case ExitBatchModeEvent():
          batchHandler.exitBatchMode();
        case ToggleSelectionEvent():
          batchHandler.toggleSelection(event.itemId);
        case ToggleSelectAllEvent():
          batchHandler.toggleSelectAll();
        case BatchDownloadEvent():
          await batchHandler.batchDownload();
        case BatchShareEvent():
          await batchHandler.batchShare();
        case LoadMoreEvent():
          await folderHandler.loadMore();
        case AddAccountEvent():
          await accountHandler.addAccount(event.account);
        case DeleteAccountEvent():
          await accountHandler.deleteAccount(event.accountId);
        case UpdateAccountEvent():
          await accountHandler.updateAccount(event.account);
        case UpdateAccountCookieEvent():
          await accountHandler.updateAccountCookies(
            event.accountId,
            event.newCookies,
          );
        case RefreshEvent():
          await folderHandler.refresh();
        case ClearErrorEvent():
          _clearError();
        case BatchDeleteEvent():
          await batchHandler.batchDelete();
        case ToggleAccountSelectorEvent():
          toggleAccountSelector();
        case SetPendingOperationEvent():
          _setPendingOperation(event.file, event.operationType);
        case ClearPendingOperationEvent():
          _clearPendingOperation();
        case ExecutePendingOperationEvent():
          await executePendingOperation();
        case AddFileToStateEvent():
          _addFileToState(event.file);
        case RemoveFileFromStateEvent():
          _removeFileFromState(event.fileId);
        case RemoveFolderFromStateEvent():
          _removeFolderFromState(event.folderId);
        case UpdateFileInStateEvent():
          _updateFileInState(event.fileId, event.newName);
      }
    } catch (e) {
      LogManager().error('处理事件失败: ${event.runtimeType} - $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 清除当前错误状态
  void _clearError() {
    state = state.copyWith(error: null);
  }

  /// 获取当前状态信息（用于调试）
  String getStateInfo() {
    final account = state.currentAccount;
    final folder = state.currentFolder;
    final selectedCount = batchHandler.getSelectedCount();

    return '''
当前账号: ${account?.name ?? '无'}
当前文件夹: ${folder?.name ?? '根目录'}
选中项目: $selectedCount
批量模式: ${state.isInBatchMode ? '是' : '否'}
加载状态: ${state.isLoading ? '加载中' : '空闲'}
''';
  }

  /// 重置状态管理器，清除所有数据
  void reset() {
    LogManager().cloudDrive('重置状态管理器');
    state = const CloudDriveState();
  }

  /// 检查是否有错误
  bool get hasError => state.error != null;

  /// 检查是否正在加载
  bool get isLoading => state.isLoading;

  /// 检查是否在批量模式
  bool get isInBatchMode => state.isInBatchMode;

  /// 获取当前账号
  CloudDriveAccount? get currentAccount => state.currentAccount;

  /// 获取当前文件夹
  CloudDriveFile? get currentFolder => state.currentFolder;

  /// 获取文件列表
  List<CloudDriveFile> get files => state.files;

  /// 获取文件夹列表
  List<CloudDriveFile> get folders => state.folders;

  /// 获取选中项目数量
  int get selectedCount => batchHandler.getSelectedCount();

  /// 获取选中文件列表
  List<CloudDriveFile> get selectedFiles => batchHandler.getSelectedFiles();

  /// 验证当前账号
  Future<bool> validateCurrentAccount() async {
    return await accountHandler.validateCurrentAccount();
  }

  /// 刷新当前文件夹
  Future<void> refresh() async {
    await folderHandler.refresh();
  }

  /// 进入指定文件夹
  ///
  /// [folder] 要进入的文件夹
  Future<void> enterFolder(CloudDriveFile folder) async {
    await folderHandler.enterFolder(folder);
  }

  /// 返回上级目录
  Future<void> goBack() async {
    await folderHandler.goBack();
  }

  /// 跳转到路径中的指定位置（用于面包屑导航）
  ///
  /// [pathIndex] 路径链中的索引位置（从0开始）
  Future<void> navigateToPathIndex(int pathIndex) async {
    await folderHandler.navigateToPathIndex(pathIndex);
  }

  /// 切换项目选择状态
  ///
  /// [itemId] 要切换选择状态的项目ID
  void toggleSelection(String itemId) {
    batchHandler.toggleSelection(itemId);
  }

  /// 切换全选状态
  void toggleSelectAll() {
    batchHandler.toggleSelectAll();
  }

  /// 进入批量操作模式
  ///
  /// [itemId] 开始批量选择的项目ID
  void enterBatchMode(String itemId) {
    batchHandler.enterBatchMode(itemId);
  }

  /// 退出批量操作模式
  void exitBatchMode() {
    batchHandler.exitBatchMode();
  }

  /// 批量下载选中文件
  Future<void> batchDownload() async {
    await batchHandler.batchDownload();
  }

  /// 批量分享选中文件
  Future<void> batchShare() async {
    await batchHandler.batchShare();
  }

  /// 批量删除选中文件
  Future<void> batchDelete() async {
    await batchHandler.batchDelete();
  }

  /// 添加云盘账号
  ///
  /// [account] 要添加的云盘账号
  Future<void> addAccount(CloudDriveAccount account) async {
    await accountHandler.addAccount(account);
  }

  /// 删除云盘账号
  ///
  /// [accountId] 要删除的账号ID
  Future<void> deleteAccount(String accountId) async {
    await accountHandler.deleteAccount(accountId);
  }

  /// 更新云盘账号
  ///
  /// [account] 要更新的云盘账号
  Future<void> updateAccount(CloudDriveAccount account) async {
    await accountHandler.updateAccount(account);
  }

  /// 切换当前账号
  ///
  /// [accountIndex] 要切换到的账号索引
  Future<void> switchAccount(int accountIndex) async {
    await accountHandler.switchAccount(accountIndex);
  }

  /// 加载账号列表
  Future<void> loadAccounts() async {
    await accountHandler.loadAccounts();
  }

  /// 加载文件夹内容
  ///
  /// [forceRefresh] 是否强制刷新，忽略缓存
  Future<void> loadFolder({bool forceRefresh = false}) async {
    await folderHandler.loadFolder(forceRefresh: forceRefresh);
  }

  /// 加载更多内容（分页）
  Future<void> loadMore() async {
    await folderHandler.loadMore();
  }

  /// 执行待处理操作
  Future<bool> executePendingOperation() async {
    final pendingFile = state.pendingOperationFile;
    final operationType = state.pendingOperationType;
    final currentAccount = state.currentAccount;
    final currentFolderId = state.currentFolder?.id;

    if (pendingFile == null ||
        operationType == null ||
        currentAccount == null) {
      LogManager().error('执行待操作失败: 缺少必要参数');
      _clearPendingOperation();
      return false;
    }

    try {
      if (operationType == 'move') {
        // 执行移动操作
        LogManager().cloudDrive(
          '执行移动操作: ${pendingFile.name} -> $currentFolderId',
        );
        final success = await folderHandler.moveFile(
          account: currentAccount,
          file: pendingFile,
          targetFolderId: currentFolderId,
        );

        if (success) {
          // 移动成功后，延迟200ms再刷新列表（确保服务器端操作完成）
          await Future.delayed(const Duration(milliseconds: 200));
          await folderHandler.loadFolder(forceRefresh: true);
        }

        _clearPendingOperation();
        return success;
      } else if (operationType == 'copy') {
        // 执行复制操作
        LogManager().cloudDrive(
          '执行复制操作: ${pendingFile.name} -> $currentFolderId',
        );
        final success = await folderHandler.copyFile(
          account: currentAccount,
          file: pendingFile,
          targetFolderId: currentFolderId,
        );

        if (success) {
          // 复制成功后，延迟200ms再刷新列表（确保服务器端操作完成）
          await Future.delayed(const Duration(milliseconds: 200));
          await folderHandler.loadFolder(forceRefresh: true);
        }

        _clearPendingOperation();
        return success;
      }

      _clearPendingOperation();
      return false;
    } catch (e) {
      LogManager().error('执行待操作失败: $e');
      _clearPendingOperation();
      return false;
    }
  }

  /// 切换账号选择器显示状态
  void toggleAccountSelector() {
    state = state.copyWith(showAccountSelector: !state.showAccountSelector);
  }

  /// 设置待处理操作
  ///
  /// [file] 要操作的文件
  /// [operationType] 操作类型
  void _setPendingOperation(CloudDriveFile file, String operationType) {
    state = state.copyWith(
      pendingOperationFile: file,
      pendingOperationType: operationType,
    );
  }

  /// 清除待处理操作
  void _clearPendingOperation() {
    state = CloudDriveState(
      accounts: state.accounts,
      currentAccount: state.currentAccount,
      currentFolder: state.currentFolder,
      folders: state.folders,
      files: state.files,
      folderPath: state.folderPath,
      isLoading: state.isLoading,
      isRefreshing: state.isRefreshing,
      error: state.error,
      isBatchMode: state.isBatchMode,
      isInBatchMode: state.isInBatchMode,
      selectedItems: state.selectedItems,
      isAllSelected: state.isAllSelected,
      currentPage: state.currentPage,
      hasMoreData: state.hasMoreData,
      isLoadingMore: state.isLoadingMore,
      isFromCache: state.isFromCache,
      lastRefreshTime: state.lastRefreshTime,
      showAccountSelector: state.showAccountSelector,
      pendingOperationFile: null, // 清空待操作文件
      pendingOperationType: null, // 清空待操作类型
      showFloatingActionButton: state.showFloatingActionButton,
    );
  }

  /// 添加文件到状态
  ///
  /// [file] 要添加的文件
  void _addFileToState(CloudDriveFile file) {
    final currentFiles = List<CloudDriveFile>.from(state.files);
    currentFiles.add(file);
    state = state.copyWith(files: currentFiles);
  }

  /// 从状态中移除文件
  ///
  /// [fileId] 要移除的文件ID
  void _removeFileFromState(String fileId) {
    final currentFiles =
        state.files.where((file) => file.id != fileId).toList();
    state = state.copyWith(files: currentFiles);
  }

  /// 从状态中移除文件夹
  ///
  /// [folderId] 要移除的文件夹ID
  void _removeFolderFromState(String folderId) {
    final currentFolders =
        state.folders.where((folder) => folder.id != folderId).toList();
    state = state.copyWith(folders: currentFolders);
  }

  /// 更新状态中的文件
  ///
  /// [fileId] 要更新的文件ID
  /// [newName] 新的文件名
  void _updateFileInState(String fileId, String newName) {
    final currentFiles =
        state.files
            .map((f) => f.id == fileId ? f.copyWith(name: newName) : f)
            .toList();
    state = state.copyWith(files: currentFiles);
  }

  /// 获取账号详情
  ///
  /// [account] 要获取详情的云盘账号
  Future<CloudDriveAccountDetails?> getAccountDetails(
    CloudDriveAccount account,
  ) async {
    try {
      return await accountHandler.getAccountDetails(account);
    } catch (e) {
      LogManager().error('获取账号详情失败: ${account.name} - $e');
      return null;
    }
  }
}
