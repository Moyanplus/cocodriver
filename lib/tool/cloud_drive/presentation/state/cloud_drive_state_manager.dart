library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../base/cloud_drive_service_gateway.dart';
import '../../core/result.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../infrastructure/logging/cloud_drive_logger_adapter.dart';
import 'cloud_drive_state_model.dart';
import 'handlers/account_state_handler.dart';
import 'handlers/folder_state_handler.dart';
import 'handlers/batch_operation_handler.dart';
import '../utils/operation_guard.dart';
import 'account_validation_service.dart';
part 'handlers/pending_operation_handler.dart';

/// 云盘状态管理器
///
/// 使用 StateNotifier 管理云盘应用的状态，通过 Handler 模式分离不同模块的状态处理逻辑。
class CloudDriveStateManager extends StateNotifier<CloudDriveState> {
  CloudDriveStateManager({
    CloudDriveLoggerAdapter? logger,
    AccountStateHandler Function(CloudDriveStateManager)? accountHandlerBuilder,
    FolderStateHandler Function(CloudDriveStateManager)? folderHandlerBuilder,
    BatchOperationHandler Function(CloudDriveStateManager)? batchHandlerBuilder,
    PendingOperationHandler Function(CloudDriveStateManager)?
    pendingHandlerBuilder,
  }) : _logger = logger ?? DefaultCloudDriveLoggerAdapter(),
       super(const CloudDriveState()) {
    accountHandler =
        accountHandlerBuilder?.call(this) ??
        AccountStateHandler(
          this,
          validationService: AccountValidationService(logger ?? DefaultCloudDriveLoggerAdapter()),
        );
    folderHandler =
        folderHandlerBuilder?.call(this) ?? FolderStateHandler(this);
    batchHandler =
        batchHandlerBuilder?.call(this) ?? BatchOperationHandler(this);
    pendingHandler =
        pendingHandlerBuilder?.call(this) ?? PendingOperationHandler(this);
  }

  final CloudDriveLoggerAdapter _logger;
  CloudDriveLoggerAdapter get logger => _logger;

  // 状态处理器
  late final AccountStateHandler accountHandler;
  late final FolderStateHandler folderHandler;
  late final BatchOperationHandler batchHandler;
  late final PendingOperationHandler pendingHandler;

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
    _logger.info('重置状态管理器');
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

  /// 更新账号 Cookie
  Future<void> updateAccountCookie(String accountId, String newCookies) async {
    await accountHandler.updateAccountCookies(accountId, newCookies);
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
  Future<bool> executePendingOperation() async =>
      pendingHandler.executePendingOperation();

  /// 切换账号选择器显示状态
  void toggleAccountSelector() {
    final next =
        state.accountState.copyWith(
          showAccountSelector: !state.showAccountSelector,
        );
    state = state.copyWith(accountState: next);
  }

  /// 创建文件夹
  Future<bool> createFolder({
    required String name,
    required String parentId,
  }) async {
    return folderHandler.createFolder(name: name, parentId: parentId);
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
      _logger.error('获取账号详情失败: ${account.name} - $e');
      return null;
    }
  }

  /// 更新文件元数据
  void updateFileMetadata(
    String fileId,
    Map<String, dynamic>? Function(Map<String, dynamic>?) updater,
  ) {
    pendingHandler.updateFileMetadata(fileId, updater);
  }

  /// 设置待操作文件
  void setPendingOperation(CloudDriveFile file, String operationType) {
    pendingHandler.setPendingOperation(file, operationType);
  }

  /// 清除待操作文件
  void clearPendingOperation() {
    pendingHandler.clearPendingOperation();
  }

  /// 添加文件到状态
  void addFileToState(CloudDriveFile file) {
    pendingHandler.addFileToState(file);
  }

  /// 从状态移除文件
  void removeFileFromState(String fileId) {
    pendingHandler.removeFileFromState(fileId);
  }

  /// 从状态移除文件夹
  void removeFolderFromState(String folderId) {
    pendingHandler.removeFolderFromState(folderId);
  }

  /// 更新文件信息
  void updateFileInState(String fileId, String newName) {
    pendingHandler.updateFileInState(fileId, newName);
  }

  /// 更新排序选项
  void updateSortOption(CloudDriveSortField field, bool ascending) async {
    await folderHandler.updateSortOption(field, ascending);
  }

  /// 更新视图模式
  void updateViewMode(CloudDriveViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}
