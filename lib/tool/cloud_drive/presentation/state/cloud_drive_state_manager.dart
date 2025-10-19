import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import '../../base/cloud_drive_account_service.dart';
import '../../base/cloud_drive_file_service.dart';
import '../../base/cloud_drive_operation_service.dart';
import '../../core/result.dart';
import 'cloud_drive_state_model.dart';

/// 云盘状态管理器 - 简化的状态管理
class CloudDriveStateManager extends StateNotifier<CloudDriveState> {
  CloudDriveStateManager() : super(const CloudDriveState());

  /// 处理事件
  Future<void> handleEvent(CloudDriveEvent event) async {
    LogManager().cloudDrive('🎯 处理事件: ${event.runtimeType}');

    try {
      switch (event) {
        case LoadAccountsEvent():
          await _loadAccounts();
        case SwitchAccountEvent():
          await _switchAccount(event.accountIndex);
        case LoadFolderEvent():
          await _loadFolder(event.forceRefresh);
        case EnterFolderEvent():
          await _enterFolder(event.folder);
        case GoBackEvent():
          await _goBack();
        case EnterBatchModeEvent():
          _enterBatchMode(event.itemId);
        case ExitBatchModeEvent():
          _exitBatchMode();
        case ToggleSelectionEvent():
          _toggleSelection(event.itemId);
        case ToggleSelectAllEvent():
          _toggleSelectAll();
        case BatchDownloadEvent():
          await _batchDownload();
        case BatchShareEvent():
          await _batchShare();
        case LoadMoreEvent():
          await _loadMore();
        case AddAccountEvent():
          await _addAccount(event.account);
        case DeleteAccountEvent():
          await _deleteAccount(event.accountId);
        case UpdateAccountEvent():
          await _updateAccount(event.account);
        case UpdateAccountCookieEvent():
          _updateAccountCookie(event.accountId, event.newCookies);
        case ToggleAccountSelectorEvent():
          _toggleAccountSelector();
        case SetPendingOperationEvent():
          _setPendingOperation(event.file, event.operationType);
        case ClearPendingOperationEvent():
          _clearPendingOperation();
        case ExecutePendingOperationEvent():
          await _executePendingOperation();
        case AddFileToStateEvent():
          _addFileToState(event.file, event.operationType);
        case RemoveFileFromStateEvent():
          _removeFileFromState(event.fileId);
        case RemoveFolderFromStateEvent():
          _removeFolderFromState(event.folderId);
        case UpdateFileInStateEvent():
          _updateFileInState(event.fileId, event.newName);
        case ClearErrorEvent():
          _clearError();
      }
    } catch (e) {
      LogManager().error('❌ 处理事件失败: ${event.runtimeType}');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 加载账号列表
  Future<void> _loadAccounts() async {
    LogManager().cloudDrive('📋 加载账号列表');

    state = state.copyWith(isLoading: true, error: null);

    final result = await ResultUtils.fromAsync(
      () => CloudDriveAccountService.loadAccounts(),
      operationName: '加载账号列表',
    );

    if (result.isSuccess) {
      final accounts = result.data!;
      state = state.copyWith(
        accounts: accounts,
        isLoading: false,
        currentAccount: accounts.isNotEmpty ? accounts.first : null,
      );
      LogManager().cloudDrive('✅ 账号列表加载成功: ${accounts.length} 个账号');
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
      LogManager().error('❌ 账号列表加载失败: ${result.error}');
    }
  }

  /// 切换账号
  Future<void> _switchAccount(int index) async {
    if (index < 0 || index >= state.accounts.length) return;

    LogManager().cloudDrive('🔄 切换账号: $index');

    state = state.copyWith(
      currentAccount: state.accounts[index],
      folderPath: [],
      folders: [],
      files: [],
      currentPage: 1,
      hasMoreData: true,
    );

    await _loadFolder(false);
  }

  /// 加载当前文件夹
  Future<void> _loadFolder(bool forceRefresh) async {
    final account = state.currentAccount;
    if (account == null) {
      LogManager().cloudDrive('❌ 当前账号为空');
      return;
    }

    LogManager().cloudDrive('📂 加载文件夹: ${forceRefresh ? '强制刷新' : '正常加载'}');

    if (!forceRefresh) {
      // 尝试从缓存获取数据
      final cacheKey = _generateCacheKey(account.id, state.folderPath);
      final cachedData = _getCachedData(cacheKey);

      if (cachedData != null) {
        LogManager().cloudDrive('📦 显示缓存数据');
        state = state.copyWith(
          folders: cachedData['folders'] ?? [],
          files: cachedData['files'] ?? [],
          isLoading: false,
          isFromCache: true,
          error: null,
        );

        // 后台刷新
        state = state.copyWith(isRefreshing: true);
      } else {
        state = state.copyWith(isLoading: true);
      }
    } else {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
        hasMoreData: true,
        isRefreshing: false,
        isFromCache: false,
      );
    }

    // 获取最新数据
    final result = await ResultUtils.fromAsync(
      () => CloudDriveFileService.getFileList(
        account: account,
        folderId: _getTargetFolderId(account.type, state.folderPath),
        page: forceRefresh ? 1 : state.currentPage,
      ),
      operationName: '获取文件列表',
    );

    if (result.isSuccess) {
      final data = result.data!;
      final newFolders = data['folders'] ?? [];
      final newFiles = data['files'] ?? [];
      final hasMore = (newFolders.length + newFiles.length) >= 50;

      // 更新缓存
      _cacheData(_generateCacheKey(account.id, state.folderPath), data);

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

      LogManager().cloudDrive(
        '✅ 文件夹加载完成: ${newFolders.length} 个文件夹, ${newFiles.length} 个文件',
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: result.error,
      );
      LogManager().error('❌ 文件夹加载失败: ${result.error}');
    }
  }

  /// 进入文件夹
  Future<void> _enterFolder(CloudDriveFile folder) async {
    LogManager().cloudDrive('🚀 进入文件夹: ${folder.name}');

    final account = state.currentAccount;
    if (account == null) {
      LogManager().cloudDrive('❌ 当前账号为空');
      return;
    }

    final newPath = [
      ...state.folderPath,
      PathInfo(id: folder.id, name: folder.name),
    ];

    state = state.copyWith(
      folderPath: newPath,
      folders: [],
      files: [],
      currentPage: 1,
      hasMoreData: true,
      isLoading: true,
      error: null,
    );

    await _loadFolder(false);
  }

  /// 返回上级
  Future<void> _goBack() async {
    if (state.folderPath.isEmpty) {
      LogManager().cloudDrive('⚠️ 已在根目录，无法返回');
      return;
    }

    LogManager().cloudDrive('🔙 返回上级');

    final newPath = state.folderPath.sublist(0, state.folderPath.length - 1);
    state = state.copyWith(
      folderPath: newPath,
      folders: [],
      files: [],
      currentPage: 1,
      hasMoreData: true,
    );

    await _loadFolder(false);
  }

  /// 进入批量模式
  void _enterBatchMode(String itemId) {
    state = state.copyWith(
      isBatchMode: true,
      selectedItems: {itemId},
      isAllSelected: false,
    );
  }

  /// 退出批量模式
  void _exitBatchMode() {
    state = state.copyWith(
      isBatchMode: false,
      selectedItems: {},
      isAllSelected: false,
    );
  }

  /// 切换选择状态
  void _toggleSelection(String itemId) {
    final newSelectedItems = Set<String>.from(state.selectedItems);

    if (newSelectedItems.contains(itemId)) {
      newSelectedItems.remove(itemId);
    } else {
      newSelectedItems.add(itemId);
    }

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
  void _toggleSelectAll() {
    if (state.isAllSelected) {
      state = state.copyWith(
        selectedItems: {},
        isAllSelected: false,
        isBatchMode: false,
      );
    } else {
      final allIds = state.allItems.map((item) => item.id).toSet();
      state = state.copyWith(selectedItems: allIds, isAllSelected: true);
    }
  }

  /// 批量下载
  Future<void> _batchDownload() async {
    final account = state.currentAccount;
    if (account == null || state.selectedItems.isEmpty) return;

    LogManager().cloudDrive('📥 批量下载: ${state.selectedItems.length} 个项目');

    final result = await ResultUtils.fromAsync(
      () => CloudDriveFileService.batchDownloadFiles(
        account: account,
        files: state.selectedFiles,
        folders: state.selectedFolders,
      ),
      operationName: '批量下载',
    );

    if (result.isSuccess) {
      _exitBatchMode();
      LogManager().cloudDrive('✅ 批量下载完成');
    } else {
      state = state.copyWith(error: result.error);
      LogManager().error('❌ 批量下载失败: ${result.error}');
    }
  }

  /// 批量分享
  Future<void> _batchShare() async {
    // TODO: 实现批量分享逻辑
    _exitBatchMode();
  }

  /// 加载更多
  Future<void> _loadMore() async {
    if (!state.hasMoreData || state.isLoadingMore) return;
    await _loadFolder(false);
  }

  /// 添加账号
  Future<void> _addAccount(CloudDriveAccount account) async {
    LogManager().cloudDrive('➕ 添加账号: ${account.name}');

    final result = await ResultUtils.fromAsync(
      () => CloudDriveAccountService.addAccount(account),
      operationName: '添加账号',
    );

    if (result.isSuccess) {
      await _loadAccounts();
      LogManager().cloudDrive('✅ 账号添加成功');
    } else {
      state = state.copyWith(error: result.error);
      LogManager().error('❌ 账号添加失败: ${result.error}');
      throw Exception(result.error);
    }
  }

  /// 删除账号
  Future<void> _deleteAccount(String accountId) async {
    LogManager().cloudDrive('🗑️ 删除账号: $accountId');

    final result = await ResultUtils.fromAsync(
      () => CloudDriveAccountService.deleteAccount(accountId),
      operationName: '删除账号',
    );

    if (result.isSuccess) {
      await _loadAccounts();
      LogManager().cloudDrive('✅ 账号删除成功');
    } else {
      state = state.copyWith(error: result.error);
      LogManager().error('❌ 账号删除失败: ${result.error}');
      throw Exception(result.error);
    }
  }

  /// 更新账号
  Future<void> _updateAccount(CloudDriveAccount account) async {
    LogManager().cloudDrive('✏️ 更新账号: ${account.name}');

    final result = await ResultUtils.fromAsync(
      () => CloudDriveAccountService.updateAccount(account),
      operationName: '更新账号',
    );

    if (result.isSuccess) {
      await _loadAccounts();
      LogManager().cloudDrive('✅ 账号更新成功');
    } else {
      state = state.copyWith(error: result.error);
      LogManager().error('❌ 账号更新失败: ${result.error}');
      throw Exception(result.error);
    }
  }

  /// 更新账号Cookie
  void _updateAccountCookie(String accountId, String newCookies) {
    final accounts =
        state.accounts.map((account) {
          if (account.id == accountId) {
            return account.copyWith(cookies: newCookies);
          }
          return account;
        }).toList();

    state = state.copyWith(accounts: accounts);
    CloudDriveAccountService.saveAccounts(accounts);
  }

  /// 切换账号选择器
  void _toggleAccountSelector() {
    state = state.copyWith(showAccountSelector: !state.showAccountSelector);
  }

  /// 设置待操作文件
  void _setPendingOperation(CloudDriveFile file, String operationType) {
    state = state.copyWith(
      pendingOperationFile: file,
      pendingOperationType: operationType,
      showFloatingActionButton: true,
    );
  }

  /// 清除待操作文件
  void _clearPendingOperation() {
    state = state.copyWith(
      pendingOperationFile: null,
      pendingOperationType: null,
      showFloatingActionButton: false,
    );
  }

  /// 执行待操作
  Future<void> _executePendingOperation() async {
    final file = state.pendingOperationFile;
    final operationType = state.pendingOperationType;
    final account = state.currentAccount;

    if (file == null || operationType == null || account == null) {
      LogManager().cloudDrive('❌ 待操作信息不完整');
      return;
    }

    LogManager().cloudDrive('🚀 执行待操作: ${file.name} ($operationType)');

    final targetFolderId =
        CloudDriveOperationService.convertPathToTargetFolderId(
          cloudDriveType: account.type,
          folderPath: state.folderPath,
        );

    final result = await ResultUtils.fromAsync(() async {
      if (operationType == 'copy') {
        return await CloudDriveOperationService.copyFile(
          account: account,
          file: file,
          destPath: targetFolderId,
        );
      } else if (operationType == 'move') {
        return await CloudDriveOperationService.moveFile(
          account: account,
          file: file,
          targetFolderId: targetFolderId,
        );
      }
      return false;
    }, operationName: '执行待操作');

    if (result.isSuccess && result.data == true) {
      _addFileToState(file, operationType);
      _clearPendingOperation();
      LogManager().cloudDrive('✅ 待操作执行成功');
    } else {
      LogManager().error('❌ 待操作执行失败: ${result.error}');
    }
  }

  /// 添加文件到状态
  void _addFileToState(CloudDriveFile file, String? operationType) {
    LogManager().cloudDrive('➕ 添加文件到状态: ${file.name}');

    final account = state.currentAccount;
    if (account == null) return;

    final currentPath = CloudDriveOperationService.convertPathToTargetFolderId(
      cloudDriveType: account.type,
      folderPath: state.folderPath,
    );

    final updatedFile =
        CloudDriveOperationService.updateFilePathForTargetDirectory(
          cloudDriveType: account.type,
          file: file,
          targetPath: currentPath,
        );

    if (updatedFile.isFolder) {
      final updatedFolders = [...state.folders, updatedFile];
      state = state.copyWith(folders: updatedFolders);
    } else {
      final updatedFiles = [...state.files, updatedFile];
      state = state.copyWith(files: updatedFiles);
    }
  }

  /// 从状态移除文件
  void _removeFileFromState(String fileId) {
    LogManager().cloudDrive('🗑️ 从状态移除文件: $fileId');

    final updatedFiles =
        state.files.where((file) => file.id != fileId).toList();
    final updatedFolders =
        state.folders.where((folder) => folder.id != fileId).toList();

    state = state.copyWith(files: updatedFiles, folders: updatedFolders);
  }

  /// 从状态移除文件夹
  void _removeFolderFromState(String folderId) {
    LogManager().cloudDrive('🗑️ 从状态移除文件夹: $folderId');

    final updatedFolders =
        state.folders.where((folder) => folder.id != folderId).toList();
    state = state.copyWith(folders: updatedFolders);
  }

  /// 更新文件信息
  void _updateFileInState(String fileId, String newName) {
    LogManager().cloudDrive('✏️ 更新文件信息: $fileId -> $newName');

    final updatedFiles =
        state.files.map((file) {
          if (file.id == fileId) {
            return file.copyWith(name: newName);
          }
          return file;
        }).toList();

    final updatedFolders =
        state.folders.map((folder) {
          if (folder.id == fileId) {
            return folder.copyWith(name: newName);
          }
          return folder;
        }).toList();

    state = state.copyWith(files: updatedFiles, folders: updatedFolders);
  }

  /// 清除错误
  void _clearError() {
    state = state.copyWith(error: null);
  }

  // ========== 私有辅助方法 ==========

  /// 生成缓存键
  String _generateCacheKey(String accountId, List<PathInfo> folderPath) {
    final pathString = folderPath.map((path) => path.id).join('/');
    return '${accountId}_$pathString';
  }

  /// 获取缓存数据
  Map<String, dynamic>? _getCachedData(String cacheKey) {
    // TODO: 实现缓存逻辑
    return null;
  }

  /// 缓存数据
  void _cacheData(String cacheKey, Map<String, dynamic> data) {
    // TODO: 实现缓存逻辑
  }

  /// 获取目标文件夹ID
  String _getTargetFolderId(CloudDriveType type, List<PathInfo> folderPath) {
    return CloudDriveOperationService.convertPathToTargetFolderId(
      cloudDriveType: type,
      folderPath: folderPath,
    );
  }

  /// 执行待处理的操作
  Future<bool> executePendingOperation() async {
    try {
      // TODO: 实现具体的待处理操作逻辑
      LogManager().cloudDrive('🔄 执行待处理操作');

      // 模拟操作执行
      await Future.delayed(Duration(milliseconds: 500));

      LogManager().cloudDrive('✅ 待处理操作执行完成');
      return true;
    } catch (e) {
      LogManager().error('❌ 执行待处理操作失败: $e');
      return false;
    }
  }

  // ==================== 公共方法 ====================

  /// 加载账号列表
  Future<void> loadAccounts() async {
    await _loadAccounts();
  }

  /// 添加账号
  Future<void> addAccount(CloudDriveAccount account) async {
    await _addAccount(account);
  }

  /// 切换账号
  Future<void> switchAccount(int index) async {
    await _switchAccount(index);
  }

  /// 切换账号选择器显示状态
  void toggleAccountSelector() {
    _toggleAccountSelector();
  }

  /// 进入文件夹
  Future<void> enterFolder(CloudDriveFile folder) async {
    await handleEvent(EnterFolderEvent(folder));
  }

  /// 返回上一级
  Future<void> goBack() async {
    await _goBack();
  }

  /// 加载更多
  Future<void> loadMore() async {
    await _loadMore();
  }

  /// 加载当前文件夹
  Future<void> loadCurrentFolder({bool forceRefresh = false}) async {
    await _loadFolder(forceRefresh);
  }

  /// 切换选择状态
  void toggleSelection(String itemId) {
    _toggleSelection(itemId);
  }

  /// 进入批量模式
  void enterBatchMode(String itemId) {
    _enterBatchMode(itemId);
  }

  /// 切换全选状态
  void toggleSelectAll() {
    _toggleSelectAll();
  }

  /// 批量下载
  Future<void> batchDownload() async {
    await _batchDownload();
  }

  /// 批量分享
  Future<void> batchShare() async {
    await _batchShare();
  }
}
