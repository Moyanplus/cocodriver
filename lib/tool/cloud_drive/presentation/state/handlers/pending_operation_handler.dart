part of '../cloud_drive_state_manager.dart';

class PendingOperationHandler {
  PendingOperationHandler(this._manager, {CloudDriveServiceGateway? gateway});

  final CloudDriveStateManager _manager;

  CloudDriveState get _state => _manager.state;
  CloudDriveLoggerAdapter get _logger => _manager.logger;
  FolderStateHandler get _folderHandler => _manager.folderHandler;

  Future<bool> executePendingOperation() async {
    final pendingFile = _state.pendingOperationFile;
    final operationType = _state.pendingOperationType;
    final currentAccount = _state.currentAccount;
    final currentFolderId = _state.currentFolder?.id;
    final sourceFolderId = pendingFile?.folderId ?? '/';

    if (pendingFile == null ||
        operationType == null ||
        currentAccount == null) {
      _logger.error('执行待操作失败: 缺少必要参数');
      return false;
    }

    try {
      bool success = false;

      if (operationType == 'move') {
        _logger.info('执行移动操作: ${pendingFile.name} -> $currentFolderId');
        final isSameFolder =
            (pendingFile.folderId ?? '/') == (currentFolderId ?? '/');
        CloudDriveFile? optimisticFile;

        success = await OperationGuard.run<bool>(
          optimisticUpdate: () {
            if (isSameFolder) {
              _removeItemFromState(pendingFile);
            }
            if (currentFolderId != null) {
              optimisticFile = pendingFile.copyWith(folderId: currentFolderId);
              addFileToState(optimisticFile!);
            }
          },
          rollback: () {
            if (optimisticFile != null) {
              _removeItemFromState(optimisticFile!);
            }
            if (isSameFolder) {
              addFileToState(pendingFile);
            }
          },
          action:
              () => _folderHandler.moveFile(
                account: currentAccount,
                file: pendingFile,
                targetFolderId: currentFolderId,
              ),
          rollbackWhen: (result) => !result,
        );

        if (success && currentFolderId != null) {
          _invalidateCaches(
            accountId: currentAccount.id,
            sourceFolderId: sourceFolderId,
            targetFolderId: currentFolderId,
          );
          unawaited(_folderHandler.loadFolder(forceRefresh: true));
        }
      } else if (operationType == 'copy') {
        _logger.info('执行复制操作: ${pendingFile.name} -> $currentFolderId');
        CloudDriveFile? optimisticFile;

        success = await OperationGuard.run<bool>(
          optimisticUpdate: () {
            optimisticFile = pendingFile.copyWith(
              id: '${pendingFile.id}_${DateTime.now().microsecondsSinceEpoch}',
              folderId: currentFolderId,
            );
            addFileToState(optimisticFile!);
          },
          rollback: () {
            if (optimisticFile != null) {
              _removeItemFromState(optimisticFile!);
            }
          },
          action:
              () => _folderHandler.copyFile(
                account: currentAccount,
                file: pendingFile,
                targetFolderId: currentFolderId,
              ),
          rollbackWhen: (result) => !result,
        );

        if (success && currentFolderId != null) {
          _invalidateCaches(
            accountId: currentAccount.id,
            sourceFolderId: sourceFolderId,
            targetFolderId: currentFolderId,
          );
          unawaited(_folderHandler.loadFolder(forceRefresh: true));
        }
      }

      return success;
    } on CloudDriveException catch (e) {
      _logger.error('执行待操作失败: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.error('执行待操作失败: $e');
      return false;
    } finally {
      clearPendingOperation();
    }
  }

  void setPendingOperation(CloudDriveFile file, String operationType) {
    _manager.state = _manager.state.copyWith(
      pendingOperationFile: file,
      pendingOperationType: operationType,
    );
  }

  void clearPendingOperation() {
    final current = _manager.state;
    _manager.state = CloudDriveState(
      accounts: current.accounts,
      currentAccount: current.currentAccount,
      currentFolder: current.currentFolder,
      folders: current.folders,
      files: current.files,
      folderPath: current.folderPath,
      isLoading: current.isLoading,
      isRefreshing: current.isRefreshing,
      error: current.error,
      isBatchMode: current.isBatchMode,
      isInBatchMode: current.isInBatchMode,
      selectedItems: current.selectedItems,
      isAllSelected: current.isAllSelected,
      currentPage: current.currentPage,
      hasMoreData: current.hasMoreData,
      isLoadingMore: current.isLoadingMore,
      isFromCache: current.isFromCache,
      lastRefreshTime: current.lastRefreshTime,
      showAccountSelector: current.showAccountSelector,
      pendingOperationFile: null,
      pendingOperationType: null,
      showFloatingActionButton: current.showFloatingActionButton,
      sortField: current.sortField,
      isSortAscending: current.isSortAscending,
      viewMode: current.viewMode,
    );
  }

  void addFileToState(CloudDriveFile file) {
    if (file.isFolder) {
      final currentFolders = List<CloudDriveFile>.from(_state.folders)
        ..add(file);
      _manager.state = _state.copyWith(folders: currentFolders);
      return;
    }

    final currentFiles = List<CloudDriveFile>.from(_state.files)..add(file);
    _manager.state = _state.copyWith(files: currentFiles);
  }

  void removeFileFromState(String fileId) {
    final currentFiles =
        _state.files.where((file) => file.id != fileId).toList();
    _manager.state = _state.copyWith(files: currentFiles);
  }

  void removeFolderFromState(String folderId) {
    final currentFolders =
        _state.folders.where((folder) => folder.id != folderId).toList();
    _manager.state = _state.copyWith(folders: currentFolders);
  }

  void updateFileMetadata(
    String fileId,
    Map<String, dynamic>? Function(Map<String, dynamic>?) updater,
  ) {
    final updatedFiles =
        _state.files
            .map(
              (file) =>
                  file.id == fileId
                      ? file.copyWith(metadata: updater(file.metadata))
                      : file,
            )
            .toList();
    _manager.state = _state.copyWith(files: updatedFiles);
  }

  void _removeItemFromState(CloudDriveFile file) {
    if (file.isFolder) {
      removeFolderFromState(file.id);
    } else {
      removeFileFromState(file.id);
    }
  }

  void updateFileInState(String fileId, String newName) {
    final currentFiles =
        _state.files
            .map((f) => f.id == fileId ? f.copyWith(name: newName) : f)
            .toList();
    _manager.state = _state.copyWith(files: currentFiles);
  }

  void _invalidateCaches({
    required String accountId,
    required String sourceFolderId,
    required String targetFolderId,
  }) {
    _folderHandler.invalidateCache(accountId, sourceFolderId);
    _folderHandler.invalidateCache(accountId, targetFolderId);
  }
}
