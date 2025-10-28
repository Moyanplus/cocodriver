import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import 'cloud_drive_state_model.dart';
import 'handlers/account_state_handler.dart';
import 'handlers/folder_state_handler.dart';
import 'handlers/batch_operation_handler.dart';

/// 云盘状态管理器 - 重构后的简化版本
class CloudDriveStateManager extends StateNotifier<CloudDriveState> {
  CloudDriveStateManager() : super(const CloudDriveState()) {
    _initializeHandlers();
  }

  // 状态处理器
  late final AccountStateHandler accountHandler;
  late final FolderStateHandler folderHandler;
  late final BatchOperationHandler batchHandler;

  /// 初始化状态处理器
  ///
  /// 创建并初始化各种状态处理器实例
  /// 包括账号处理器、文件夹处理器和批量操作处理器
  void _initializeHandlers() {
    accountHandler = AccountStateHandler(this);
    folderHandler = FolderStateHandler(this);
    batchHandler = BatchOperationHandler(this);
  }

  /// 处理云盘事件
  ///
  /// 【核心方法】事件驱动的状态管理入口
  ///
  /// 【架构说明】
  /// 本项目使用事件驱动架构，所有状态变更都通过事件触发：
  /// 1. UI 层发送事件（如 GoBackEvent、EnterFolderEvent 等）
  /// 2. handleEvent 接收事件并分发到对应的处理器
  /// 3. 处理器修改状态（通过 _stateManager.state = ...）
  /// 4. UI 层自动响应状态变化（通过 ref.watch）
  ///
  /// 【处理器分类】
  /// - accountHandler: 账号相关操作（加载、切换、添加、删除等）
  /// - folderHandler: 文件夹导航（进入、返回、加载、刷新等）
  /// - batchHandler: 批量操作（选择、下载、分享、删除等）
  ///
  /// 【错误处理】
  /// - 所有异常都会被捕获并记录到日志
  /// - 错误信息会更新到 state.error，UI 可以显示错误提示
  ///
  /// [event] 要处理的云盘事件（如 GoBackEvent、EnterFolderEvent 等）
  Future<void> handleEvent(CloudDriveEvent event) async {
    LogManager().cloudDrive('🎯 处理事件: ${event.runtimeType}');

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
        case GoBackEvent(): // 【返回上级事件】由路径导航器的"返回上级"按钮触发
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
      LogManager().error('❌ 处理事件失败: ${event.runtimeType} - $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 清除当前错误状态
  ///
  /// 将状态中的错误信息设置为null
  void _clearError() {
    state = state.copyWith(error: null);
  }

  /// 获取当前状态信息
  ///
  /// 返回包含当前账号、文件夹、选中项目等信息的字符串
  /// 用于调试和状态展示
  ///
  /// 返回格式化的状态信息字符串
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

  /// 重置状态管理器
  ///
  /// 将状态重置为初始状态，清除所有数据
  /// 记录重置操作的日志
  void reset() {
    LogManager().cloudDrive('🔄 重置状态管理器');
    state = const CloudDriveState();
  }

  /// 检查是否有错误
  ///
  /// 返回当前状态是否包含错误信息
  bool get hasError => state.error != null;

  /// 检查是否正在加载
  ///
  /// 返回当前是否处于加载状态
  bool get isLoading => state.isLoading;

  /// 检查是否在批量模式
  ///
  /// 返回当前是否处于批量操作模式
  bool get isInBatchMode => state.isInBatchMode;

  /// 获取当前账号
  ///
  /// 返回当前选中的云盘账号，可能为null
  CloudDriveAccount? get currentAccount => state.currentAccount;

  /// 获取当前文件夹
  ///
  /// 返回当前所在的文件夹，可能为null（根目录）
  CloudDriveFile? get currentFolder => state.currentFolder;

  /// 获取文件列表
  ///
  /// 返回当前文件夹下的所有文件
  List<CloudDriveFile> get files => state.files;

  /// 获取文件夹列表
  ///
  /// 返回当前文件夹下的所有子文件夹
  List<CloudDriveFile> get folders => state.folders;

  /// 获取选中项目数量
  ///
  /// 返回当前批量模式下选中的项目数量
  int get selectedCount => batchHandler.getSelectedCount();

  /// 获取选中文件列表
  ///
  /// 返回当前批量模式下选中的所有文件
  List<CloudDriveFile> get selectedFiles => batchHandler.getSelectedFiles();

  /// 验证当前账号
  ///
  /// 验证当前选中的账号是否有效
  ///
  /// 返回验证结果，true表示账号有效
  Future<bool> validateCurrentAccount() async {
    return await accountHandler.validateCurrentAccount();
  }

  /// 刷新当前文件夹
  ///
  /// 重新加载当前文件夹的内容
  Future<void> refresh() async {
    await folderHandler.refresh();
  }

  /// 进入指定文件夹
  ///
  /// 导航到指定的文件夹并加载其内容
  ///
  /// [folder] 要进入的文件夹
  Future<void> enterFolder(CloudDriveFile folder) async {
    await folderHandler.enterFolder(folder);
  }

  /// 返回上级目录
  ///
  /// 从当前文件夹返回到上级文件夹
  Future<void> goBack() async {
    await folderHandler.goBack();
  }

  /// 切换项目选择状态
  ///
  /// 切换指定项目的选中/未选中状态
  ///
  /// [itemId] 要切换选择状态的项目ID
  void toggleSelection(String itemId) {
    batchHandler.toggleSelection(itemId);
  }

  /// 切换全选状态
  ///
  /// 切换所有项目的选中/未选中状态
  void toggleSelectAll() {
    batchHandler.toggleSelectAll();
  }

  /// 进入批量操作模式
  ///
  /// 从指定项目开始进入批量选择模式
  ///
  /// [itemId] 开始批量选择的项目ID
  void enterBatchMode(String itemId) {
    batchHandler.enterBatchMode(itemId);
  }

  /// 退出批量操作模式
  ///
  /// 退出批量选择模式，清除所有选择状态
  void exitBatchMode() {
    batchHandler.exitBatchMode();
  }

  /// 批量下载选中文件
  ///
  /// 下载当前批量模式下选中的所有文件
  Future<void> batchDownload() async {
    await batchHandler.batchDownload();
  }

  /// 批量分享选中文件
  ///
  /// 分享当前批量模式下选中的所有文件
  Future<void> batchShare() async {
    await batchHandler.batchShare();
  }

  /// 批量删除选中文件
  ///
  /// 删除当前批量模式下选中的所有文件
  Future<void> batchDelete() async {
    await batchHandler.batchDelete();
  }

  /// 添加云盘账号
  ///
  /// 添加新的云盘账号到账号列表
  ///
  /// [account] 要添加的云盘账号
  Future<void> addAccount(CloudDriveAccount account) async {
    await accountHandler.addAccount(account);
  }

  /// 删除云盘账号
  ///
  /// 从账号列表中删除指定的账号
  ///
  /// [accountId] 要删除的账号ID
  Future<void> deleteAccount(String accountId) async {
    await accountHandler.deleteAccount(accountId);
  }

  /// 更新云盘账号
  ///
  /// 更新指定账号的信息
  ///
  /// [account] 要更新的云盘账号
  Future<void> updateAccount(CloudDriveAccount account) async {
    await accountHandler.updateAccount(account);
  }

  /// 切换当前账号
  ///
  /// 切换到指定索引的账号
  ///
  /// [accountIndex] 要切换到的账号索引
  Future<void> switchAccount(int accountIndex) async {
    await accountHandler.switchAccount(accountIndex);
  }

  /// 加载账号列表
  ///
  /// 从存储中加载所有云盘账号
  Future<void> loadAccounts() async {
    await accountHandler.loadAccounts();
  }

  /// 加载文件夹内容
  ///
  /// 加载当前文件夹下的文件和子文件夹
  ///
  /// [forceRefresh] 是否强制刷新，忽略缓存
  Future<void> loadFolder({bool forceRefresh = false}) async {
    await folderHandler.loadFolder(forceRefresh: forceRefresh);
  }

  /// 加载更多内容
  ///
  /// 分页加载更多文件和文件夹
  Future<void> loadMore() async {
    await folderHandler.loadMore();
  }

  /// 执行待处理操作
  ///
  /// 执行之前保存的待处理操作
  ///
  /// 返回操作是否成功执行
  Future<bool> executePendingOperation() async {
    // TODO: 实现待处理操作逻辑
    return true;
  }

  /// 切换账号选择器显示状态
  ///
  /// 切换账号选择器的显示/隐藏状态
  void toggleAccountSelector() {
    state = state.copyWith(showAccountSelector: !state.showAccountSelector);
  }

  /// 设置待处理操作
  ///
  /// 设置待处理的操作信息
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
  ///
  /// 清除当前设置的待处理操作
  void _clearPendingOperation() {
    state = state.copyWith(
      pendingOperationFile: null,
      pendingOperationType: null,
    );
  }

  /// 添加文件到状态
  ///
  /// 将新文件添加到当前状态的文件列表中
  ///
  /// [file] 要添加的文件
  void _addFileToState(CloudDriveFile file) {
    final currentFiles = List<CloudDriveFile>.from(state.files);
    currentFiles.add(file);
    state = state.copyWith(files: currentFiles);
  }

  /// 从状态中移除文件
  ///
  /// 从当前状态的文件列表中移除指定文件
  ///
  /// [fileId] 要移除的文件ID
  void _removeFileFromState(String fileId) {
    final currentFiles =
        state.files.where((file) => file.id != fileId).toList();
    state = state.copyWith(files: currentFiles);
  }

  /// 从状态中移除文件夹
  ///
  /// 从当前状态的文件夹列表中移除指定文件夹
  ///
  /// [folderId] 要移除的文件夹ID
  void _removeFolderFromState(String folderId) {
    final currentFolders =
        state.folders.where((folder) => folder.id != folderId).toList();
    state = state.copyWith(folders: currentFolders);
  }

  /// 更新状态中的文件
  ///
  /// 更新当前状态中指定文件的信息
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
  /// 获取指定账号的详细信息，包括存储空间、会员状态等
  ///
  /// [account] 要获取详情的云盘账号
  /// 返回账号详情，如果获取失败则返回null
  Future<CloudDriveAccountDetails?> getAccountDetails(
    CloudDriveAccount account,
  ) async {
    try {
      return await accountHandler.getAccountDetails(account);
    } catch (e) {
      LogManager().error('❌ 获取账号详情失败: ${account.name} - $e');
      return null;
    }
  }
}
