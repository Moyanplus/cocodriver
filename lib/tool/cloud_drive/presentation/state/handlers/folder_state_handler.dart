import '../../../data/models/cloud_drive_entities.dart';
import '../../../data/models/cloud_drive_dtos.dart'; // 导入 PathInfo
import '../../../base/cloud_drive_file_service.dart';
import '../../../data/cache/file_list_cache.dart'; // 导入缓存管理器
import '../../../infrastructure/logging/cloud_drive_logger_adapter.dart';
import '../../../utils/cloud_drive_error_utils.dart';
import '../cloud_drive_state_manager.dart';
import '../cloud_drive_state_model.dart'; // 导入 CloudDriveState

/// 文件夹状态处理器
///
/// 负责处理文件夹导航、文件列表加载、路径管理等操作的状态管理。
class FolderStateHandler {
  final CloudDriveStateManager _stateManager;
  final FileListCacheManager _cacheManager = FileListCacheManager();
  final CloudDriveLoggerAdapter _logger;

  FolderStateHandler(this._stateManager) : _logger = _stateManager.logger;

  /// 加载文件夹内容，使用缓存机制提升性能
  ///
  /// [forceRefresh] 是否强制刷新，忽略缓存
  Future<void> loadFolder({bool forceRefresh = false}) async {
    final account = _stateManager.getCurrentState().currentAccount;
    if (account == null) {
      _logger.warning('没有当前账号，无法加载文件夹');
      return;
    }

    final folderId = _stateManager.getCurrentState().currentFolder?.id ?? '/';
    _logger.info(
      '📂 加载文件夹: ${_stateManager.getCurrentState().currentFolder?.name ?? '根目录'} (ID: $folderId)',
    );

    try {
      // 检查缓存
      if (!forceRefresh) {
        final cachedData = _cacheManager.get(account.id, folderId);
        if (cachedData != null) {
          // 使用缓存数据
          _logger.info(
            '⚡ 使用缓存数据 (${cachedData.files.length} 文件, ${cachedData.folders.length} 文件夹, '
            '剩余 ${cachedData.remainingSeconds}s)',
          );

          _stateManager.updateState(
            (state) => state.copyWith(
              files: List.from(cachedData.files),
              folders: List.from(cachedData.folders),
              isLoading: false,
              isFromCache: true, // 标记为来自缓存
              error: null,
            ),
          );

          return;
        }
      }

      // 从网络获取数据
      _stateManager.updateState(
        (state) => state.copyWith(isLoading: true, error: null),
      );

      _logger.info('🌐 从网络获取数据...');

      final result = await CloudDriveFileService.getFileList(
        account: account,
        folderId: folderId,
        forceRefresh: forceRefresh,
      );

      final newFiles = List<CloudDriveFile>.from(result['files'] ?? []);
      final newFolders = List<CloudDriveFile>.from(result['folders'] ?? []);

      _logger.info(
        '✅ 网络数据获取成功: ${newFiles.length} 文件, ${newFolders.length} 文件夹',
      );

      // 更新缓存
      _cacheManager.set(account.id, folderId, newFiles, newFolders);

      // 更新状态
      _stateManager.updateState(
        (state) => state.copyWith(
          files: newFiles,
          folders: newFolders,
          isLoading: false,
          isFromCache: false, // 标记为来自网络
          lastRefreshTime: DateTime.now(),
          error: null,
        ),
      );

      final updatedState = _stateManager.getCurrentState();
      _logger.info(
        '📌 状态更新完成 - 文件: ${updatedState.files.length}, 文件夹: ${updatedState.folders.length}',
      );
    } catch (e) {
      _logger.error('❌ 加载文件夹内容失败: $e');
      _stateManager.updateState(
        (state) => state.copyWith(
          isLoading: false,
          error: CloudDriveErrorUtils.format(e),
        ),
      );
    }
  }

  /// 使指定账号+文件夹的缓存失效。
  void invalidateCache(String accountId, String folderId) {
    _cacheManager.remove(accountId, folderId.isEmpty ? '/' : folderId);
  }

  /// 进入指定文件夹并加载其内容
  ///
  /// 将新文件夹添加到路径链末尾，更新状态后加载文件夹内容。
  ///
  /// [folder] 要进入的文件夹对象
  Future<void> enterFolder(CloudDriveFile folder) async {
    // 确保传入的是文件夹而非文件
    if (!folder.isDirectory) {
      _logger.warning('尝试进入非文件夹: ${folder.name}');
      return;
    }

    _logger.info('进入文件夹: ${folder.name}');

    try {
      final currentState = _stateManager.getCurrentState();
      final currentPath = List<PathInfo>.from(currentState.folderPath);
      currentPath.add(PathInfo(id: folder.id, name: folder.name));

      _logger.info('📍 更新路径: ${currentPath.map((p) => p.name).join(' > ')}');

      // 更新状态
      _stateManager.updateState(
        (state) => state.copyWith(
          currentFolder: folder, // 更新当前文件夹
          folderPath: currentPath, // 更新路径链（已添加新文件夹）
          selectedItems: {}, // 清空选中项
          isInBatchMode: false, // 退出批量模式
          error: null, // 清空错误信息
        ),
      );

      // 加载新文件夹的内容
      await loadFolder(forceRefresh: false);

      _logger.info('进入文件夹成功: ${folder.name}');
    } catch (e) {
      _logger.error('进入文件夹失败: $e');
      _stateManager.updateState(
        (state) => state.copyWith(error: CloudDriveErrorUtils.format(e)),
      );
    }
  }

  /// 跳转到路径中的指定位置（用于面包屑导航）
  ///
  /// 截取路径链到指定索引，更新状态后加载目标文件夹内容。
  ///
  /// [pathIndex] 路径链中的索引位置（从0开始）
  Future<void> navigateToPathIndex(int pathIndex) async {
    final currentState = _stateManager.getCurrentState();
    final currentPath = currentState.folderPath;

    // 检查索引是否有效
    if (pathIndex < 0 || pathIndex >= currentPath.length) {
      _logger.warning('无效的路径索引: $pathIndex');
      return;
    }

    _logger.info('跳转到路径索引: $pathIndex');

    try {
      final newPath = currentPath.sublist(0, pathIndex + 1);

      // 确定目标文件夹
      CloudDriveFile? targetFolder;
      if (newPath.isEmpty) {
        targetFolder = null;
      } else {
        final targetPathInfo = newPath.last;
        targetFolder = CloudDriveFile(
          id: targetPathInfo.id,
          name: targetPathInfo.name,
          isFolder: true,
        );
      }

      _logger.info(
        '📍 跳转到: ${newPath.isEmpty ? '根目录' : newPath.map((p) => p.name).join(' > ')}',
      );

      // 更新状态
      final currentState = _stateManager.getCurrentState();
      _stateManager.setState(
        CloudDriveState(
          accounts: currentState.accounts,
          currentAccount: currentState.currentAccount,
          currentFolder: targetFolder, // 目标文件夹
          folders: currentState.folders,
          files: currentState.files,
          folderPath: newPath, // 截断后的路径链
          isLoading: currentState.isLoading,
          isRefreshing: currentState.isRefreshing,
          error: null, // 清空错误信息
          isBatchMode: currentState.isBatchMode,
          isInBatchMode: false, // 退出批量模式
          selectedItems: {}, // 清空选中项
          isAllSelected: false,
          currentPage: currentState.currentPage,
          hasMoreData: currentState.hasMoreData,
          isLoadingMore: currentState.isLoadingMore,
          isFromCache: currentState.isFromCache,
          lastRefreshTime: currentState.lastRefreshTime,
          showAccountSelector: currentState.showAccountSelector,
          pendingOperationFile: currentState.pendingOperationFile,
          pendingOperationType: currentState.pendingOperationType,
          showFloatingActionButton: currentState.showFloatingActionButton,
        ),
      );

      // 加载目标文件夹的内容
      await loadFolder(forceRefresh: false);

      _logger.info('跳转成功');
    } catch (e) {
      _logger.error('跳转失败: $e');
      _stateManager.updateState(
        (state) => state.copyWith(error: CloudDriveErrorUtils.format(e)),
      );
    }
  }

  /// 返回上级目录
  ///
  /// 从路径链中移除最后一个节点，更新状态后加载父文件夹内容。
  /// 如果已在根目录则直接返回不做任何操作。
  Future<void> goBack() async {
    // 获取当前文件夹和路径链
    final currentState = _stateManager.getCurrentState();
    final currentFolder = currentState.currentFolder;
    final currentPath = currentState.folderPath;

    // 检查是否已在根目录
    if (currentFolder == null || currentPath.isEmpty) {
      _logger.warning('已在根目录，无法返回');
      return;
    }

    _logger.info('返回上级目录');

    try {
      final newPath = List<PathInfo>.from(currentPath);
      newPath.removeLast();

      // 确定父文件夹
      CloudDriveFile? parentFolder;
      if (newPath.isEmpty) {
        parentFolder = null;
      } else {
        final parentPathInfo = newPath.last;
        parentFolder = CloudDriveFile(
          id: parentPathInfo.id,
          name: parentPathInfo.name,
          isFolder: true,
        );
      }

      _logger.info(
        '📍 更新路径: ${newPath.isEmpty ? '根目录' : newPath.map((p) => p.name).join(' > ')}',
      );

      // 更新状态（使用 setState 因为 copyWith 无法正确处理 null 值）
      final currentState = _stateManager.getCurrentState();
      _stateManager.setState(
        CloudDriveState(
          accounts: currentState.accounts,
          currentAccount: currentState.currentAccount,
          currentFolder: parentFolder, // 可能为 null（根目录）或父文件夹
          folders: currentState.folders,
          files: currentState.files,
          folderPath: newPath, // 更新后的路径链
          isLoading: currentState.isLoading,
          isRefreshing: currentState.isRefreshing,
          error: null, // 清空错误信息
          isBatchMode: currentState.isBatchMode,
          isInBatchMode: false, // 退出批量模式
          selectedItems: {}, // 清空选中项
          isAllSelected: false,
          currentPage: currentState.currentPage,
          hasMoreData: currentState.hasMoreData,
          isLoadingMore: currentState.isLoadingMore,
          isFromCache: currentState.isFromCache,
          lastRefreshTime: currentState.lastRefreshTime,
          showAccountSelector: currentState.showAccountSelector,
          pendingOperationFile: currentState.pendingOperationFile,
          pendingOperationType: currentState.pendingOperationType,
          showFloatingActionButton: currentState.showFloatingActionButton,
        ),
      );

      // 加载父文件夹的内容
      await loadFolder(forceRefresh: false);

      _logger.info('返回上级目录成功');
    } catch (e) {
      _logger.error('返回上级目录失败: $e');
      _stateManager.updateState(
        (state) => state.copyWith(error: CloudDriveErrorUtils.format(e)),
      );
    }
  }

  /// 加载更多内容（分页）
  Future<void> loadMore() async {
    final currentState = _stateManager.getCurrentState();
    final account = currentState.currentAccount;
    if (account == null) {
      _logger.warning('没有当前账号，无法加载更多');
      return;
    }

    _logger.info('加载更多内容');

    try {
      final currentState = _stateManager.getCurrentState();
      _stateManager.updateState(
        (state) => state.copyWith(isLoadingMore: true, error: null),
      );

      final folderId = currentState.currentFolder?.id ?? '/';
      final currentPage = currentState.currentPage;
      final result = await CloudDriveFileService.getFileList(
        account: account,
        folderId: folderId,
        page: currentPage + 1,
        pageSize: 50,
      );

      final newFiles = result['files'] ?? [];
      final newFolders = result['folders'] ?? [];

      _stateManager.updateState(
        (state) => state.copyWith(
          files: [...currentState.files, ...newFiles],
          folders: [...currentState.folders, ...newFolders],
          currentPage: currentPage + 1,
          hasMoreData: newFiles.length >= 50, // 假设如果返回的文件数等于页面大小，还有更多数据
          isLoadingMore: false,
          error: null,
        ),
      );

      _logger.info(
        '加载更多内容成功: ${newFiles.length}个文件, ${newFolders.length}个文件夹',
      );
    } catch (e) {
      _logger.error('加载更多内容失败: $e');
      _stateManager.updateState(
        (state) => state.copyWith(
          isLoadingMore: false,
          error: CloudDriveErrorUtils.format(e),
        ),
      );
    }
  }

  /// 刷新当前文件夹，忽略缓存重新获取数据
  Future<void> refresh() async {
    _logger.info('刷新当前文件夹');
    await loadFolder(forceRefresh: true);
  }

  /// 移动文件到目标文件夹
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    try {
      _logger.info('移动文件: ${file.name} -> $targetFolderId');

      final success = await CloudDriveFileService.moveFile(
        account: account,
        file: file,
        targetFolderId: targetFolderId,
      );

      if (success) {
        _logger.info('文件移动成功: ${file.name}');
      } else {
        _logger.warning('文件移动失败');
      }

      return success;
    } catch (e) {
      _logger.error('移动文件失败: $e');
      return false;
    }
  }

  /// 复制文件到目标文件夹
  Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    try {
      _logger.info('复制文件: ${file.name} -> $targetFolderId');

      final success = await CloudDriveFileService.copyFile(
        account: account,
        file: file,
        destPath: targetFolderId ?? '',
      );

      if (success) {
        _logger.info('文件复制成功: ${file.name}');
      } else {
        _logger.warning('文件复制失败');
      }

      return success;
    } catch (e) {
      _logger.error('复制文件失败: $e');
      return false;
    }
  }
}
