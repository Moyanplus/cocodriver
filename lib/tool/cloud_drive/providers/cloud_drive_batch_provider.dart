import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base/debug_service.dart';

/// 批量操作状态管理
class CloudDriveBatchState {
  final bool isBatchMode;
  final Set<String> selectedItems;
  final bool isAllSelected;
  final String? currentBatchOperation;
  final double batchProgress;
  final int totalItems;
  final int completedItems;
  final int failedItems;
  final List<String> failedItemIds;
  final bool isBatchProcessing;
  final String? batchError;
  final Map<String, String> itemStatus; // itemId -> status

  const CloudDriveBatchState({
    this.isBatchMode = false,
    this.selectedItems = const {},
    this.isAllSelected = false,
    this.currentBatchOperation,
    this.batchProgress = 0.0,
    this.totalItems = 0,
    this.completedItems = 0,
    this.failedItems = 0,
    this.failedItemIds = const [],
    this.isBatchProcessing = false,
    this.batchError,
    this.itemStatus = const {},
  });

  CloudDriveBatchState copyWith({
    bool? isBatchMode,
    Set<String>? selectedItems,
    bool? isAllSelected,
    String? currentBatchOperation,
    double? batchProgress,
    int? totalItems,
    int? completedItems,
    int? failedItems,
    List<String>? failedItemIds,
    bool? isBatchProcessing,
    String? batchError,
    Map<String, String>? itemStatus,
  }) => CloudDriveBatchState(
    isBatchMode: isBatchMode ?? this.isBatchMode,
    selectedItems: selectedItems ?? this.selectedItems,
    isAllSelected: isAllSelected ?? this.isAllSelected,
    currentBatchOperation: currentBatchOperation ?? this.currentBatchOperation,
    batchProgress: batchProgress ?? this.batchProgress,
    totalItems: totalItems ?? this.totalItems,
    completedItems: completedItems ?? this.completedItems,
    failedItems: failedItems ?? this.failedItems,
    failedItemIds: failedItemIds ?? this.failedItemIds,
    isBatchProcessing: isBatchProcessing ?? this.isBatchProcessing,
    batchError: batchError ?? this.batchError,
    itemStatus: itemStatus ?? this.itemStatus,
  );

  /// 选中的项目数量
  int get selectedCount => selectedItems.length;

  /// 是否有选中的项目
  bool get hasSelectedItems => selectedItems.isNotEmpty;

  /// 成功完成的项目数量
  int get successItems => completedItems - failedItems;

  /// 操作成功率
  double get successRate {
    return totalItems > 0 ? successItems / totalItems : 0.0;
  }

  /// 是否所有项目都已完成
  bool get isCompleted => completedItems >= totalItems;

  /// 是否所有项目都成功
  bool get isAllSuccess => failedItems == 0 && isCompleted;

  /// 是否有失败的项目
  bool get hasFailedItems => failedItems > 0;
}

/// 批量操作Provider
class CloudDriveBatchProvider extends StateNotifier<CloudDriveBatchState> {
  CloudDriveBatchProvider() : super(const CloudDriveBatchState());

  /// 进入批量模式
  void enterBatchMode() {
    state = state.copyWith(isBatchMode: true);

    DebugService.log(
      '🔄 进入批量模式',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.batch',
    );
  }

  /// 退出批量模式
  void exitBatchMode() {
    state = state.copyWith(
      isBatchMode: false,
      selectedItems: {},
      isAllSelected: false,
      currentBatchOperation: null,
      batchProgress: 0.0,
      totalItems: 0,
      completedItems: 0,
      failedItems: 0,
      failedItemIds: [],
      isBatchProcessing: false,
      batchError: null,
      itemStatus: {},
    );

    DebugService.log(
      '🔄 退出批量模式',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.batch',
    );
  }

  /// 选择项目
  void selectItem(String itemId) {
    final newSelectedItems = Set<String>.from(state.selectedItems);
    newSelectedItems.add(itemId);

    state = state.copyWith(
      selectedItems: newSelectedItems,
      isAllSelected: false,
    );

    DebugService.log(
      '✅ 选择项目: $itemId (共${newSelectedItems.length}个)',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.batch',
    );
  }

  /// 取消选择项目
  void deselectItem(String itemId) {
    final newSelectedItems = Set<String>.from(state.selectedItems);
    newSelectedItems.remove(itemId);

    state = state.copyWith(
      selectedItems: newSelectedItems,
      isAllSelected: false,
    );

    DebugService.log(
      '❌ 取消选择项目: $itemId (剩余${newSelectedItems.length}个)',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.batch',
    );
  }

  /// 全选项目
  void selectAllItems(List<String> allItemIds) {
    state = state.copyWith(
      selectedItems: Set<String>.from(allItemIds),
      isAllSelected: true,
    );

    DebugService.log(
      '✅ 全选项目: ${allItemIds.length}个',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.batch',
    );
  }

  /// 取消全选
  void deselectAllItems() {
    state = state.copyWith(selectedItems: {}, isAllSelected: false);

    DebugService.log(
      '❌ 取消全选',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.batch',
    );
  }

  /// 开始批量操作
  void startBatchOperation(String operation, List<String> itemIds) {
    state = state.copyWith(
      currentBatchOperation: operation,
      batchProgress: 0.0,
      totalItems: itemIds.length,
      completedItems: 0,
      failedItems: 0,
      failedItemIds: [],
      isBatchProcessing: true,
      batchError: null,
      itemStatus: {},
    );

    DebugService.log(
      '🔄 开始批量操作: $operation (${itemIds.length}个项目)',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.batch',
    );
  }

  /// 更新批量操作进度
  void updateBatchProgress(double progress, int completed) {
    state = state.copyWith(batchProgress: progress, completedItems: completed);

    DebugService.log(
      '📊 更新批量进度: ${(progress * 100).toStringAsFixed(1)}% ($completed/${state.totalItems})',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.batch',
    );
  }

  /// 更新项目状态
  void updateItemStatus(String itemId, String status) {
    final newItemStatus = Map<String, String>.from(state.itemStatus);
    newItemStatus[itemId] = status;

    state = state.copyWith(itemStatus: newItemStatus);

    DebugService.log(
      '📋 更新项目状态: $itemId -> $status',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.batch',
    );
  }

  /// 标记项目成功
  void markItemSuccess(String itemId) {
    updateItemStatus(itemId, 'success');

    DebugService.log(
      '✅ 项目成功: $itemId',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.batch',
    );
  }

  /// 标记项目失败
  void markItemFailed(String itemId, String error) {
    final newFailedItemIds = [...state.failedItemIds, itemId];
    final newFailedItems = state.failedItems + 1;

    state = state.copyWith(
      failedItems: newFailedItems,
      failedItemIds: newFailedItemIds,
      batchError: error,
    );

    updateItemStatus(itemId, 'failed');

    DebugService.log(
      '❌ 项目失败: $itemId - $error',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.batch',
    );
  }

  /// 完成批量操作
  void completeBatchOperation() {
    state = state.copyWith(
      isBatchProcessing: false,
      currentBatchOperation: null,
      batchProgress: 1.0,
    );

    DebugService.log(
      '✅ 批量操作完成: 成功${state.successItems}个, 失败${state.failedItems}个',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.batch',
    );
  }

  /// 取消批量操作
  void cancelBatchOperation() {
    state = state.copyWith(
      isBatchProcessing: false,
      currentBatchOperation: null,
      batchProgress: 0.0,
      batchError: '操作已取消',
    );

    DebugService.log(
      '🚫 取消批量操作',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.batch',
    );
  }

  /// 重试失败的项目
  void retryFailedItems() {
    if (state.failedItemIds.isNotEmpty) {
      state = state.copyWith(
        failedItems: 0,
        failedItemIds: [],
        batchError: null,
        completedItems: state.successItems,
        totalItems: state.failedItemIds.length,
      );

      DebugService.log(
        '🔄 重试失败项目: ${state.failedItemIds.length}个',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.batch',
      );
    }
  }

  /// 获取项目状态
  String getItemStatus(String itemId) {
    return state.itemStatus[itemId] ?? 'pending';
  }

  /// 获取批量操作统计
  Map<String, dynamic> getBatchStats() {
    return {
      'totalItems': state.totalItems,
      'completedItems': state.completedItems,
      'successItems': state.successItems,
      'failedItems': state.failedItems,
      'successRate': state.successRate,
      'progress': state.batchProgress,
      'isCompleted': state.isCompleted,
      'isAllSuccess': state.isAllSuccess,
      'hasFailedItems': state.hasFailedItems,
    };
  }

  /// 重置批量状态
  void reset() {
    state = const CloudDriveBatchState();

    DebugService.log(
      '🔄 重置批量状态',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.batch',
    );
  }
}

/// 批量操作Provider实例
final cloudDriveBatchProvider =
    StateNotifierProvider<CloudDriveBatchProvider, CloudDriveBatchState>(
      (ref) => CloudDriveBatchProvider(),
    );
