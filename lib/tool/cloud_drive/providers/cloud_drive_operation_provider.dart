import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/base/debug_service.dart';
import '../models/cloud_drive_models.dart';

/// 文件操作状态
class CloudDriveOperationState {
  final bool isOperating;
  final String? currentOperation;
  final double progress;
  final String? error;
  final CloudDriveFile? pendingOperationFile;
  final String? pendingOperationType;
  final List<CloudDriveFile> selectedFiles;
  final bool isBatchMode;

  const CloudDriveOperationState({
    this.isOperating = false,
    this.currentOperation,
    this.progress = 0.0,
    this.error,
    this.pendingOperationFile,
    this.pendingOperationType,
    this.selectedFiles = const [],
    this.isBatchMode = false,
  });

  CloudDriveOperationState copyWith({
    bool? isOperating,
    String? currentOperation,
    double? progress,
    String? error,
    CloudDriveFile? pendingOperationFile,
    String? pendingOperationType,
    List<CloudDriveFile>? selectedFiles,
    bool? isBatchMode,
  }) => CloudDriveOperationState(
    isOperating: isOperating ?? this.isOperating,
    currentOperation: currentOperation ?? this.currentOperation,
    progress: progress ?? this.progress,
    error: error ?? this.error,
    pendingOperationFile: pendingOperationFile ?? this.pendingOperationFile,
    pendingOperationType: pendingOperationType ?? this.pendingOperationType,
    selectedFiles: selectedFiles ?? this.selectedFiles,
    isBatchMode: isBatchMode ?? this.isBatchMode,
  );

  /// 是否有选中的文件
  bool get hasSelectedFiles => selectedFiles.isNotEmpty;

  /// 选中的文件数量
  int get selectedCount => selectedFiles.length;

  /// 是否有待操作的文件
  bool get hasPendingOperation => pendingOperationFile != null;
}

/// 文件操作Provider
class CloudDriveOperationProvider
    extends StateNotifier<CloudDriveOperationState> {
  CloudDriveOperationProvider() : super(const CloudDriveOperationState());

  /// 开始操作
  void startOperation(String operation) {
    state = state.copyWith(
      isOperating: true,
      currentOperation: operation,
      progress: 0.0,
      error: null,
    );

    DebugService.log(
      '🔄 开始操作: $operation',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.operation',
    );
  }

  /// 更新进度
  void updateProgress(double progress) {
    state = state.copyWith(progress: progress);
  }

  /// 完成操作
  void completeOperation() {
    state = state.copyWith(
      isOperating: false,
      currentOperation: null,
      progress: 1.0,
      error: null,
    );

    DebugService.log(
      '✅ 操作完成',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.operation',
    );
  }

  /// 操作失败
  void operationFailed(String error) {
    state = state.copyWith(
      isOperating: false,
      currentOperation: null,
      progress: 0.0,
      error: error,
    );

    DebugService.log(
      '❌ 操作失败: $error',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.operation',
    );
  }

  /// 设置待操作文件
  void setPendingOperation(CloudDriveFile file, String operationType) {
    state = state.copyWith(
      pendingOperationFile: file,
      pendingOperationType: operationType,
    );

    DebugService.log(
      '📋 设置待操作文件: ${file.name} - $operationType',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.operation',
    );
  }

  /// 清除待操作文件
  void clearPendingOperation() {
    state = state.copyWith(
      pendingOperationFile: null,
      pendingOperationType: null,
    );

    DebugService.log(
      '🗑️ 清除待操作文件',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.operation',
    );
  }

  /// 切换批量模式
  void toggleBatchMode() {
    state = state.copyWith(isBatchMode: !state.isBatchMode);

    if (!state.isBatchMode) {
      // 退出批量模式时清空选择
      state = state.copyWith(selectedFiles: []);
    }

    DebugService.log(
      '🔄 切换批量模式: ${state.isBatchMode}',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.operation',
    );
  }

  /// 选择文件
  void selectFile(CloudDriveFile file) {
    if (!state.selectedFiles.contains(file)) {
      final newSelectedFiles = [...state.selectedFiles, file];
      state = state.copyWith(selectedFiles: newSelectedFiles);

      DebugService.log(
        '✅ 选择文件: ${file.name} (共${newSelectedFiles.length}个)',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.operation',
      );
    }
  }

  /// 取消选择文件
  void deselectFile(CloudDriveFile file) {
    final newSelectedFiles =
        state.selectedFiles.where((f) => f != file).toList();
    state = state.copyWith(selectedFiles: newSelectedFiles);

    DebugService.log(
      '❌ 取消选择文件: ${file.name} (剩余${newSelectedFiles.length}个)',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.operation',
    );
  }

  /// 全选文件
  void selectAllFiles(List<CloudDriveFile> allFiles) {
    state = state.copyWith(selectedFiles: allFiles);

    DebugService.log(
      '✅ 全选文件: ${allFiles.length}个',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.operation',
    );
  }

  /// 取消全选
  void deselectAllFiles() {
    state = state.copyWith(selectedFiles: []);

    DebugService.log(
      '❌ 取消全选',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.operation',
    );
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 重置状态
  void reset() {
    state = const CloudDriveOperationState();

    DebugService.log(
      '🔄 重置操作状态',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.operation',
    );
  }
}

/// 文件操作Provider实例
final cloudDriveOperationProvider = StateNotifierProvider<
  CloudDriveOperationProvider,
  CloudDriveOperationState
>((ref) => CloudDriveOperationProvider());
