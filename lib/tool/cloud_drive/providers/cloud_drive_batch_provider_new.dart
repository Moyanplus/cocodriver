import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/log_manager.dart';
import '../data/models/cloud_drive_entities.dart';
import '../data/models/cloud_drive_dtos.dart';
import '../base/cloud_drive_file_service.dart';
import '../base/cloud_drive_operation_service.dart';
import '../presentation/state/cloud_drive_state_model.dart';

/// 批量操作状态管理器
class BatchOperationNotifier extends StateNotifier<CloudDriveState> {
  BatchOperationNotifier() : super(const CloudDriveState());

  /// 进入批量模式
  void enterBatchMode(String itemId) {
    state = state.copyWith(
      isBatchMode: true,
      selectedItems: {itemId},
      isAllSelected: false,
    );
  }

  /// 退出批量模式
  void exitBatchMode() {
    state = state.copyWith(
      isBatchMode: false,
      selectedItems: {},
      isAllSelected: false,
      showFloatingActionButton: false,
      pendingOperationFile: null,
      pendingOperationType: null,
    );
  }

  /// 切换选择状态
  void toggleSelection(String itemId, int totalItems) {
    final newSelectedItems = Set<String>.from(state.selectedItems);

    if (newSelectedItems.contains(itemId)) {
      newSelectedItems.remove(itemId);
    } else {
      newSelectedItems.add(itemId);
    }

    // 如果没有选中项，自动关闭批量模式
    if (newSelectedItems.isEmpty) {
      state = state.copyWith(
        selectedItems: newSelectedItems,
        isBatchMode: false,
        isAllSelected: false,
      );
    } else {
      state = state.copyWith(
        selectedItems: newSelectedItems,
        isAllSelected: newSelectedItems.length == totalItems,
      );
    }
  }

  /// 切换全选状态
  void toggleSelectAll(List<String> allItemIds) {
    if (state.isAllSelected) {
      // 取消全选并退出批量模式
      state = state.copyWith(
        selectedItems: {},
        isAllSelected: false,
        isBatchMode: false,
      );
    } else {
      // 全选所有项目
      state = state.copyWith(
        selectedItems: allItemIds.toSet(),
        isAllSelected: true,
      );
    }
  }

  /// 批量下载
  Future<void> batchDownload({
    required CloudDriveAccount account,
    required List<CloudDriveFile> selectedFiles,
    required List<CloudDriveFile> selectedFolders,
  }) async {
    if (selectedFiles.isEmpty) return;

    try {
      await CloudDriveFileService.batchDownloadFiles(
        account: account,
        files: selectedFiles,
        folders: selectedFolders,
      );

      // 下载完成后退出批量模式
      exitBatchMode();
    } catch (e) {
      LogManager().error('批量下载失败: $e');
      rethrow;
    }
  }

  /// 批量分享
  Future<void> batchShare({
    required CloudDriveAccount account,
    required List<CloudDriveFile> selectedFiles,
    required List<CloudDriveFile> selectedFolders,
  }) async {
    // TODO: 实现批量分享逻辑
    exitBatchMode();
  }

  /// 设置待操作文件（复制/移动）
  void setPendingOperation(CloudDriveFile file, String operationType) {
    LogManager().cloudDrive('🎯 设置待操作文件: ${file.name} ($operationType)');

    state = state.copyWith(
      pendingOperationFile: file,
      pendingOperationType: operationType,
      showFloatingActionButton: true,
    );
  }

  /// 清除待操作文件
  void clearPendingOperation() {
    LogManager().cloudDrive('🧹 清除待操作文件');

    state = state.copyWith(
      pendingOperationFile: null,
      pendingOperationType: null,
      showFloatingActionButton: false,
    );
  }

  /// 执行待操作（复制/移动到当前目录）
  Future<bool> executePendingOperation({
    required CloudDriveAccount account,
    required List<PathInfo> currentPath,
  }) async {
    final file = state.pendingOperationFile;
    final operationType = state.pendingOperationType;

    LogManager().cloudDrive('🚀 executePendingOperation 开始执行');
    LogManager().cloudDrive(
      '📄 文件信息: ${file?.name ?? 'null'} (ID: ${file?.id ?? 'null'})',
    );
    LogManager().cloudDrive('🔧 操作类型: ${operationType ?? 'null'}');

    if (file == null || operationType == null) {
      LogManager().cloudDrive('❌ 待操作信息不完整');
      return false;
    }

    LogManager().cloudDrive('✅ 参数验证通过');

    // 获取当前目录路径或ID - 使用策略模式解耦
    final targetFolderId =
        CloudDriveOperationService.convertPathToTargetFolderId(
          cloudDriveType: account.type,
          folderPath: currentPath,
        );

    LogManager().cloudDrive('📁 目标文件夹ID: $targetFolderId');

    try {
      bool success = false;

      if (operationType == 'copy') {
        LogManager().cloudDrive('📋 开始执行复制操作');
        success = await CloudDriveOperationService.copyFile(
          account: account,
          file: file,
          destPath: targetFolderId,
        );
        LogManager().cloudDrive('📋 复制操作结果: $success');
      } else if (operationType == 'move') {
        LogManager().cloudDrive('📋 开始执行移动操作');
        success = await CloudDriveOperationService.moveFile(
          account: account,
          file: file,
          targetFolderId: targetFolderId,
        );
        LogManager().cloudDrive('📋 移动操作结果: $success');
      } else {
        LogManager().cloudDrive('❌ 未知的操作类型: $operationType');
        return false;
      }

      if (success) {
        LogManager().cloudDrive('✅ 操作执行成功');
        LogManager().cloudDrive('🧹 开始清除待操作状态');
        // 清除待操作状态
        clearPendingOperation();
        LogManager().cloudDrive('✅ 状态更新完成，无需重新加载目录');
        return true;
      } else {
        LogManager().cloudDrive('❌ 操作执行失败');
        return false;
      }
    } catch (e) {
      LogManager().error('❌ 执行操作异常');
      return false;
    } finally {
      LogManager().cloudDrive('🚀 executePendingOperation 执行结束');
    }
  }
}

/// 批量操作Provider
final batchOperationProvider =
    StateNotifierProvider<BatchOperationNotifier, CloudDriveState>(
      (ref) => BatchOperationNotifier(),
    );
