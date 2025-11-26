part of cloud_drive_state_manager;

class PendingOperationHandler {
  PendingOperationHandler(this._manager);

  final CloudDriveStateManager _manager;

  CloudDriveState get _state => _manager.state;
  CloudDriveLoggerAdapter get _logger => _manager._logger;
  FolderStateHandler get _folderHandler => _manager.folderHandler;

  Future<bool> executePendingOperation() async {
    final pendingFile = _state.pendingOperationFile;
    final operationType = _state.pendingOperationType;
    final currentAccount = _state.currentAccount;
    final currentFolderId = _state.currentFolder?.id;

    if (pendingFile == null ||
        operationType == null ||
        currentAccount == null) {
      _logger.error('执行待操作失败: 缺少必要参数');
      clearPendingOperation();
      return false;
    }

    try {
      if (operationType == 'move') {
        _logger.info('执行移动操作: ${pendingFile.name} -> $currentFolderId');
        final success = await _folderHandler.moveFile(
          account: currentAccount,
          file: pendingFile,
          targetFolderId: currentFolderId,
        );

        if (success && currentFolderId != null) {
          final movedFile = pendingFile.copyWith(folderId: currentFolderId);
          removeFileFromState(pendingFile.id);
          addFileToState(movedFile);
          _invalidateCaches(
            accountId: currentAccount.id,
            sourceFolderId: pendingFile.folderId ?? '/',
            targetFolderId: currentFolderId,
          );
          unawaited(_folderHandler.loadFolder(forceRefresh: true));
        }

        clearPendingOperation();
        return success;
      } else if (operationType == 'copy') {
        _logger.info('执行复制操作: ${pendingFile.name} -> $currentFolderId');
        final success = await _folderHandler.copyFile(
          account: currentAccount,
          file: pendingFile,
          targetFolderId: currentFolderId,
        );

        if (success && currentFolderId != null) {
          final copiedFile = pendingFile.copyWith(
            id: '${pendingFile.id}_${DateTime.now().microsecondsSinceEpoch}',
            folderId: currentFolderId,
          );
          addFileToState(copiedFile);
          _invalidateCaches(
            accountId: currentAccount.id,
            sourceFolderId: pendingFile.folderId ?? '/',
            targetFolderId: currentFolderId,
          );
          unawaited(_folderHandler.loadFolder(forceRefresh: true));
        }

        clearPendingOperation();
        return success;
      }

      clearPendingOperation();
      return false;
    } catch (e) {
      _logger.error('执行待操作失败: $e');
      clearPendingOperation();
      return false;
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
    );
  }

  void addFileToState(CloudDriveFile file) {
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
