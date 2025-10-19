import '../models/cloud_drive_models.dart';

/// 批量操作状态
class BatchOperationState {
  final bool isBatchMode;
  final Set<String> selectedItems;
  final bool isAllSelected;
  final bool showFloatingActionButton;
  final CloudDriveFile? pendingOperationFile;
  final String? pendingOperationType;

  const BatchOperationState({
    this.isBatchMode = false,
    this.selectedItems = const {},
    this.isAllSelected = false,
    this.showFloatingActionButton = false,
    this.pendingOperationFile,
    this.pendingOperationType,
  });

  BatchOperationState copyWith({
    bool? isBatchMode,
    Set<String>? selectedItems,
    bool? isAllSelected,
    bool? showFloatingActionButton,
    CloudDriveFile? pendingOperationFile,
    String? pendingOperationType,
  }) {
    return BatchOperationState(
      isBatchMode: isBatchMode ?? this.isBatchMode,
      selectedItems: selectedItems ?? this.selectedItems,
      isAllSelected: isAllSelected ?? this.isAllSelected,
      showFloatingActionButton:
          showFloatingActionButton ?? this.showFloatingActionButton,
      pendingOperationFile: pendingOperationFile ?? this.pendingOperationFile,
      pendingOperationType: pendingOperationType ?? this.pendingOperationType,
    );
  }

  /// 获取选中项目数量
  int get selectedCount => selectedItems.length;

  /// 检查是否有选中项目
  bool get hasSelectedItems => selectedItems.isNotEmpty;

  /// 检查是否全选
  bool get isAllSelectedComputed => selectedItems.length > 0 && isAllSelected;

  /// 获取选中的文件夹
  List<CloudDriveFile> getSelectedFolders(List<CloudDriveFile> folders) {
    return folders
        .where((folder) => selectedItems.contains(folder.id))
        .toList();
  }

  /// 获取选中的文件
  List<CloudDriveFile> getSelectedFiles(List<CloudDriveFile> files) {
    return files.where((file) => selectedItems.contains(file.id)).toList();
  }
}
