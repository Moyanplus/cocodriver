import '../../../../../core/logging/log_manager.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../base/cloud_drive_operation_service.dart';
import '../cloud_drive_state_manager.dart';

/// 批量操作状态处理器
///
/// 负责处理批量选择、批量下载、批量分享、批量删除等操作的状态管理。
class BatchOperationHandler {
  final CloudDriveStateManager _stateManager;

  BatchOperationHandler(this._stateManager);

  /// 进入批量操作模式
  ///
  /// [itemId] 开始批量选择的项目ID
  void enterBatchMode(String itemId) {
    LogManager().cloudDrive('进入批量模式: $itemId');

    _stateManager.updateState(
      (state) => state.copyWith(
        isInBatchMode: true,
        selectedItems: {itemId},
        error: null,
      ),
    );

    LogManager().cloudDrive('进入批量模式成功');
  }

  /// 退出批量操作模式，清除所有选择状态
  void exitBatchMode() {
    LogManager().cloudDrive('退出批量模式');

    _stateManager.updateState(
      (state) =>
          state.copyWith(isInBatchMode: false, selectedItems: {}, error: null),
    );

    LogManager().cloudDrive('退出批量模式成功');
  }

  /// 切换项目选择状态
  ///
  /// [itemId] 要切换选择状态的项目ID
  void toggleSelection(String itemId) {
    LogManager().cloudDrive('切换选择状态: $itemId');

    final currentState = _stateManager.getCurrentState();
    final selectedItems = Set<String>.from(currentState.selectedItems);
    if (selectedItems.contains(itemId)) {
      selectedItems.remove(itemId);
    } else {
      selectedItems.add(itemId);
    }

    _stateManager.updateState(
      (state) => state.copyWith(selectedItems: selectedItems, error: null),
    );

    LogManager().cloudDrive(
      '选择状态切换成功: $itemId -> ${selectedItems.contains(itemId)}',
    );
  }

  /// 切换全选状态
  void toggleSelectAll() {
    LogManager().cloudDrive('切换全选状态');

    final currentState = _stateManager.getCurrentState();
    final allItems = <String>[];
    allItems.addAll(currentState.files.map((f) => f.id));
    allItems.addAll(currentState.folders.map((f) => f.id));

    final selectedItems = Set<String>.from(currentState.selectedItems);
    final allSelected = allItems.every((id) => selectedItems.contains(id));

    if (allSelected) {
      // 取消全选
      for (final id in allItems) {
        selectedItems.remove(id);
      }
    } else {
      // 全选
      selectedItems.addAll(allItems);
    }

    _stateManager.updateState(
      (state) => state.copyWith(selectedItems: selectedItems, error: null),
    );

    LogManager().cloudDrive('全选状态切换成功: ${!allSelected}');
  }

  /// 批量下载选中文件
  Future<void> batchDownload() async {
    final currentState = _stateManager.getCurrentState();
    final account = currentState.currentAccount;
    if (account == null) {
      LogManager().cloudDrive('没有当前账号，无法批量下载');
      return;
    }

    final selectedItems = currentState.selectedItems;
    final selectedIds = selectedItems.toList();

    if (selectedIds.isEmpty) {
      LogManager().cloudDrive('没有选中任何项目');
      return;
    }

    LogManager().cloudDrive('开始批量下载: ${selectedIds.length}个项目');

    try {
      _stateManager.updateState(
        (state) => state.copyWith(isLoading: true, error: null),
      );

      // 获取选中的文件
      final selectedFiles = <CloudDriveFile>[];
      selectedFiles.addAll(
        currentState.files.where((f) => selectedIds.contains(f.id)),
      );
      selectedFiles.addAll(
        currentState.folders.where((f) => selectedIds.contains(f.id)),
      );

      // 执行批量下载
      for (final file in selectedFiles) {
        try {
          await CloudDriveOperationService.downloadFile(
            account: account,
            file: file,
          );
          LogManager().cloudDrive('下载成功: ${file.name}');
        } catch (e) {
          LogManager().error('下载失败: ${file.name} - $e');
        }
      }

      _stateManager.updateState(
        (state) => state.copyWith(isLoading: false, error: null),
      );

      LogManager().cloudDrive('批量下载完成');
    } catch (e) {
      LogManager().error('批量下载失败: $e');
      _stateManager.updateState(
        (state) => state.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  /// 批量分享选中文件
  Future<void> batchShare() async {
    final currentState = _stateManager.getCurrentState();
    final account = currentState.currentAccount;
    if (account == null) {
      LogManager().cloudDrive('没有当前账号，无法批量分享');
      return;
    }

    final selectedItems = currentState.selectedItems;
    final selectedIds = selectedItems.toList();

    if (selectedIds.isEmpty) {
      LogManager().cloudDrive('没有选中任何项目');
      return;
    }

    LogManager().cloudDrive('开始批量分享: ${selectedIds.length}个项目');

    try {
      _stateManager.updateState(
        (state) => state.copyWith(isLoading: true, error: null),
      );

      // 获取选中的文件
      final selectedFiles = <CloudDriveFile>[];
      selectedFiles.addAll(
        currentState.files.where((f) => selectedIds.contains(f.id)),
      );
      selectedFiles.addAll(
        currentState.folders.where((f) => selectedIds.contains(f.id)),
      );

      // 执行批量分享
      try {
        await CloudDriveOperationService.createShareLink(
          account: account,
          files: selectedFiles,
        );
        LogManager().cloudDrive('批量分享成功: ${selectedFiles.length}个文件');
      } catch (e) {
        LogManager().error('批量分享失败: $e');
      }

      _stateManager.updateState(
        (state) => state.copyWith(isLoading: false, error: null),
      );

      LogManager().cloudDrive('批量分享完成');
    } catch (e) {
      LogManager().error('批量分享失败: $e');
      _stateManager.updateState(
        (state) => state.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  /// 批量删除选中文件，完成后刷新文件夹内容并退出批量模式
  Future<void> batchDelete() async {
    final currentState = _stateManager.getCurrentState();
    final account = currentState.currentAccount;
    if (account == null) {
      LogManager().cloudDrive('没有当前账号，无法批量删除');
      return;
    }

    final selectedItems = currentState.selectedItems;
    final selectedIds = selectedItems.toList();

    if (selectedIds.isEmpty) {
      LogManager().cloudDrive('没有选中任何项目');
      return;
    }

    LogManager().cloudDrive('开始批量删除: ${selectedIds.length}个项目');

    try {
      _stateManager.updateState(
        (state) => state.copyWith(isLoading: true, error: null),
      );

      // 获取选中的文件
      final selectedFiles = <CloudDriveFile>[];
      selectedFiles.addAll(
        currentState.files.where((f) => selectedIds.contains(f.id)),
      );
      selectedFiles.addAll(
        currentState.folders.where((f) => selectedIds.contains(f.id)),
      );

      // 执行批量删除
      for (final file in selectedFiles) {
        try {
          await CloudDriveOperationService.deleteFile(
            account: account,
            file: file,
          );
          LogManager().cloudDrive('删除成功: ${file.name}');
        } catch (e) {
          LogManager().error('删除失败: ${file.name} - $e');
        }
      }

      // 刷新文件夹内容
      await _stateManager.folderHandler.refresh();

      _stateManager.updateState(
        (state) => state.copyWith(
          isLoading: false,
          selectedItems: {},
          isInBatchMode: false,
          error: null,
        ),
      );

      LogManager().cloudDrive('批量删除完成');
    } catch (e) {
      LogManager().error('批量删除失败: $e');
      _stateManager.updateState(
        (state) => state.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  /// 获取选中项目数量
  int getSelectedCount() {
    return _stateManager.getCurrentState().selectedItems.length;
  }

  /// 获取选中文件列表
  List<CloudDriveFile> getSelectedFiles() {
    final currentState = _stateManager.getCurrentState();
    final selectedIds = currentState.selectedItems.toList();

    final selectedFiles = <CloudDriveFile>[];
    selectedFiles.addAll(
      currentState.files.where((f) => selectedIds.contains(f.id)),
    );
    selectedFiles.addAll(
      currentState.folders.where((f) => selectedIds.contains(f.id)),
    );

    return selectedFiles;
  }
}
