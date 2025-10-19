import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/log_manager.dart';
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

    LogManager().cloudDrive(
      '🔄 开始操作: $operation',
      
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

    LogManager().cloudDrive(
      '✅ 操作完成',
      
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

    LogManager().cloudDrive(
      '❌ 操作失败: $error',
      
    );
  }

  /// 设置待操作文件
  void setPendingOperation(CloudDriveFile file, String operationType) {
    state = state.copyWith(
      pendingOperationFile: file,
      pendingOperationType: operationType,
    );

    LogManager().cloudDrive(
      '📋 设置待操作文件: ${file.name} - $operationType',
      
    );
  }

  /// 清除待操作文件
  void clearPendingOperation() {
    state = state.copyWith(
      pendingOperationFile: null,
      pendingOperationType: null,
    );

    LogManager().cloudDrive(
      '🗑️ 清除待操作文件',
      
    );
  }

  /// 切换批量模式
  void toggleBatchMode() {
    state = state.copyWith(isBatchMode: !state.isBatchMode);

    if (!state.isBatchMode) {
      // 退出批量模式时清空选择
      state = state.copyWith(selectedFiles: []);
    }

    LogManager().cloudDrive(
      '🔄 切换批量模式: ${state.isBatchMode}',
      
    );
  }

  /// 选择文件
  void selectFile(CloudDriveFile file) {
    if (!state.selectedFiles.contains(file)) {
      final newSelectedFiles = [...state.selectedFiles, file];
      state = state.copyWith(selectedFiles: newSelectedFiles);

      LogManager().cloudDrive(
        '✅ 选择文件: ${file.name} (共${newSelectedFiles.length}个)',
        
      );
    }
  }

  /// 取消选择文件
  void deselectFile(CloudDriveFile file) {
    final newSelectedFiles =
        state.selectedFiles.where((f) => f != file).toList();
    state = state.copyWith(selectedFiles: newSelectedFiles);

    LogManager().cloudDrive(
      '❌ 取消选择文件: ${file.name} (剩余${newSelectedFiles.length}个)',
      
    );
  }

  /// 全选文件
  void selectAllFiles(List<CloudDriveFile> allFiles) {
    state = state.copyWith(selectedFiles: allFiles);

    LogManager().cloudDrive(
      '✅ 全选文件: ${allFiles.length}个',
      
    );
  }

  /// 取消全选
  void deselectAllFiles() {
    state = state.copyWith(selectedFiles: []);

    LogManager().cloudDrive(
      '❌ 取消全选',
      
    );
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 重置状态
  void reset() {
    state = const CloudDriveOperationState();

    LogManager().cloudDrive(
      '🔄 重置操作状态',
      
    );
  }
}

/// 文件操作Provider实例
final cloudDriveOperationProvider = StateNotifierProvider<
  CloudDriveOperationProvider,
  CloudDriveOperationState
>((ref) => CloudDriveOperationProvider());
