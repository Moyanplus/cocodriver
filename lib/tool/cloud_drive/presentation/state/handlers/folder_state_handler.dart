import '../../../core/result.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../data/models/cloud_drive_dtos.dart'; // 导入 PathInfo
import '../../../base/cloud_drive_service_gateway.dart';
import '../../../data/cache/file_list_cache.dart'; // 导入缓存管理器
import '../../../infrastructure/logging/cloud_drive_logger_adapter.dart';
import '../../../utils/cloud_drive_error_utils.dart';
import '../cloud_drive_state_manager.dart';
import '../cloud_drive_state_model.dart'; // 导入 CloudDriveState
import '../../utils/operation_guard.dart';

/// 文件夹状态处理器
///
/// 负责处理文件夹导航、文件列表加载、路径管理等操作的状态管理。
class FolderStateHandler {
  final CloudDriveStateManager _stateManager;
  final FileListCacheManager _cacheManager = FileListCacheManager();
  final CloudDriveLoggerAdapter _logger;
  final CloudDriveServiceGateway _gateway;

  FolderStateHandler(
    this._stateManager, {
    CloudDriveLoggerAdapter? logger,
    CloudDriveServiceGateway? gateway,
  }) : _logger = logger ?? _stateManager.logger,
       _gateway = gateway ?? defaultCloudDriveGateway;

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
          final cachedFolders = List<CloudDriveFile>.from(cachedData.folders);
          final cachedFiles = List<CloudDriveFile>.from(cachedData.files);
          _sortLists(cachedFolders, cachedFiles);
          // 使用缓存数据
          _logger.info(
            '⚡ 使用缓存数据 (${cachedData.files.length} 文件, ${cachedData.folders.length} 文件夹, '
            '剩余 ${cachedData.remainingSeconds}s)',
          );

          _stateManager.updateState(
            (state) => state.copyWith(
              files: cachedFiles,
              folders: cachedFolders,
              isLoading: false,
              isFromCache: true, // 标记为来自缓存
              error: null,
              currentPage: 1,
              hasMoreData: _supportsPagination(account),
              isLoadingMore: false,
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

      final items = await _gateway.listFiles(
        account: account,
        folderId: folderId,
        page: 1,
        pageSize: 50,
      );
      final (newFolders, newFiles) = _splitFoldersAndFiles(items);
      _sortLists(newFolders, newFiles);

      _logger.info(
        '✅ 网络数据获取成功: ${newFiles.length} 文件, ${newFolders.length} 文件夹',
      );

      // 更新缓存
      _cacheManager.set(account.id, folderId, newFiles, newFolders);

      // 更新状态
      final supportsPaging = _supportsPagination(account);
      _stateManager.updateState(
        (state) => state.copyWith(
          files: newFiles,
          folders: newFolders,
          isLoading: false,
          isFromCache: false, // 标记为来自网络
          lastRefreshTime: DateTime.now(),
          error: null,
          currentPage: 1,
          hasMoreData: supportsPaging && _hasMoreData(newFolders, newFiles),
          isLoadingMore: false,
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
          files: const [],
          folders: const [],
          isLoading: true,
          isFromCache: false,
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
          folders: const [],
          files: const [],
          folderPath: newPath, // 截断后的路径链
          isLoading: true,
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
          sortField: currentState.sortField,
          isSortAscending: currentState.isSortAscending,
          viewMode: currentState.viewMode,
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
          folders: const [],
          files: const [],
          folderPath: newPath, // 更新后的路径链
          isLoading: true,
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
          sortField: currentState.sortField,
          isSortAscending: currentState.isSortAscending,
          viewMode: currentState.viewMode,
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
    if (!_supportsPagination(account)) {
      _logger.info('当前账号不支持分页加载');
      return;
    }
    if (!currentState.hasMoreData) {
      _logger.info('没有更多数据可加载');
      return;
    }
    if (currentState.isLoadingMore) {
      _logger.info('已有加载更多任务进行中');
      return;
    }

    _logger.info('加载更多内容');

    try {
      _stateManager.updateState(
        (state) => state.copyWith(isLoadingMore: true, error: null),
      );

      final folderId = currentState.currentFolder?.id ?? '/';
      final currentPage = currentState.currentPage;
      final items = await _gateway.listFiles(
        account: account,
        folderId: folderId,
        page: currentPage + 1,
        pageSize: 50,
      );
      final (newFolders, newFiles) = _splitFoldersAndFiles(items);

      if (newFolders.isEmpty && newFiles.isEmpty) {
        _stateManager.updateState(
          (state) => state.copyWith(isLoadingMore: false, hasMoreData: false),
        );
        _logger.info('无更多数据，结束分页');
        return;
      }

      final mergedFiles = _mergeWithoutDuplicates(currentState.files, newFiles);
      final mergedFolders = _mergeWithoutDuplicates(
        currentState.folders,
        newFolders,
      );
      _sortLists(mergedFolders, mergedFiles);

      _stateManager.updateState(
        (state) => state.copyWith(
          files: mergedFiles,
          folders: mergedFolders,
          currentPage: currentPage + 1,
          hasMoreData: _hasMoreData(newFolders, newFiles),
          isLoadingMore: false,
          error: null,
        ),
      );
      _cacheManager.set(account.id, folderId, mergedFiles, mergedFolders);

      _logger.info('加载更多内容成功: ${newFiles.length}个文件, ${newFolders.length}个文件夹');
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

  Future<void> updateSortOption(
    CloudDriveSortField field,
    bool ascending,
  ) async {
    _stateManager.updateState(
      (state) => state.copyWith(sortField: field, isSortAscending: ascending),
    );
    _applySortingToCurrentState();
    _logger.info('更新排序: $field, 升序: $ascending');
  }

  void _applySortingToCurrentState() {
    final currentState = _stateManager.getCurrentState();
    final folders = List<CloudDriveFile>.from(currentState.folders);
    final files = List<CloudDriveFile>.from(currentState.files);
    _sortLists(folders, files);
    _stateManager.updateState(
      (state) => state.copyWith(folders: folders, files: files),
    );
  }

  void _sortLists(List<CloudDriveFile> folders, List<CloudDriveFile> files) {
    final state = _stateManager.getCurrentState();
    int comparator(CloudDriveFile a, CloudDriveFile b) =>
        _compareFiles(a, b, state.sortField, state.isSortAscending);
    folders.sort(comparator);
    files.sort(comparator);
  }

  int _compareFiles(
    CloudDriveFile a,
    CloudDriveFile b,
    CloudDriveSortField field,
    bool ascending,
  ) {
    int result;
    switch (field) {
      case CloudDriveSortField.name:
        result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        break;
      case CloudDriveSortField.createdTime:
        result = _compareDateTime(
          _getCreatedTime(a) ?? a.updatedAt ?? a.createdAt,
          _getCreatedTime(b) ?? b.updatedAt ?? b.createdAt,
        );
        break;
      case CloudDriveSortField.modifiedTime:
        result = _compareDateTime(
          a.updatedAt ?? a.createdAt,
          b.updatedAt ?? b.createdAt,
        );
        break;
      case CloudDriveSortField.size:
        result = _compareInt(a.size ?? 0, b.size ?? 0);
        break;
      case CloudDriveSortField.downloadCount:
        result = _compareInt(a.downloadCount, b.downloadCount);
        break;
    }
    return ascending ? result : -result;
  }

  int _compareDateTime(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }

  int _compareInt(int a, int b) => a.compareTo(b);

  // TODO
  bool _supportsPagination(CloudDriveAccount? account) =>
      account?.type == CloudDriveType.lanzou;

  bool _hasMoreData(
    List<CloudDriveFile> folders,
    List<CloudDriveFile> files, {
    int pageSize = 50,
  }) {
    final account = _stateManager.getCurrentState().currentAccount;
    if (account?.type == CloudDriveType.lanzou) {
      return folders.isNotEmpty || files.isNotEmpty;
    }
    return (folders.length + files.length) >= pageSize;
  }

  List<CloudDriveFile> _mergeWithoutDuplicates(
    List<CloudDriveFile> existing,
    List<CloudDriveFile> incoming,
  ) {
    if (incoming.isEmpty) return existing;
    final result = List<CloudDriveFile>.from(existing);
    final existingIds = existing.map((e) => e.id).toSet();
    for (final item in incoming) {
      if (existingIds.add(item.id)) {
        result.add(item);
      }
    }
    return result;
  }

  DateTime? _getCreatedTime(CloudDriveFile file) {
    final meta = file.metadata;
    if (meta == null) return null;
    final keys = [
      'createdTime',
      'createTime',
      'created_at',
      'createdAt',
      'ctime',
    ];
    for (final key in keys) {
      if (meta.containsKey(key)) {
        final dt = _parseDateTime(meta[key]);
        if (dt != null) return dt;
      }
    }
    return null;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      // assume milliseconds since epoch if length > 10
      if (value > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) return parsed;
      final seconds = int.tryParse(trimmed);
      if (seconds != null) {
        if (trimmed.length > 11) {
          return DateTime.fromMillisecondsSinceEpoch(seconds);
        }
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }
    return null;
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
    final targetId = _normalizeFolderId(targetFolderId);
    final sourceId = _normalizeFolderId(file.folderId);
    if (targetId == sourceId) {
      throw const CloudDriveException(
        '文件已在目标文件夹中，请选择其他文件夹',
        CloudDriveErrorType.clientError,
        operation: '移动文件',
      );
    }

    try {
      _logger.info('移动文件: ${file.name} -> $targetFolderId');

      final success = await _gateway.moveFile(
        account: account,
        file: file,
        targetFolderId: targetId,
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
    final targetId = _normalizeFolderId(targetFolderId);
    final sourceId = _normalizeFolderId(file.folderId);
    if (targetId == sourceId) {
      throw const CloudDriveException(
        '文件已在当前文件夹中，请选择其他文件夹',
        CloudDriveErrorType.clientError,
        operation: '复制文件',
      );
    }

    try {
      _logger.info('复制文件: ${file.name} -> $targetFolderId');

      final success = await _gateway.copyFile(
        account: account,
        file: file,
        targetFolderId: targetId,
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

  /// 创建文件夹并刷新列表
  Future<bool> createFolder({
    required String name,
    required String parentId,
  }) async {
    final account = _stateManager.getCurrentState().currentAccount;
    if (account == null) {
      _logger.warning('没有当前账号，无法创建文件夹');
      return false;
    }

    final normalizedParent = parentId.isEmpty ? '/' : parentId;
    final tempId = 'temp_${DateTime.now().microsecondsSinceEpoch}';
    final tempFolder = CloudDriveFile(
      id: tempId,
      name: name,
      isFolder: true,
      folderId: normalizedParent,
      metadata: const {'temporary': true},
    );

    try {
      final result = await OperationGuard.run<CloudDriveFile?>(
        optimisticUpdate: () {
          _stateManager.updateState((state) {
            final folders = List<CloudDriveFile>.from(state.folders)
              ..insert(0, tempFolder);
            return state.copyWith(folders: folders);
          });
        },
        action: () async {
          return await _gateway.createFolder(
            account: account,
            name: name,
            parentId: normalizedParent,
          );
        },
        rollback: () {
          _stateManager.updateState((state) {
            final folders = List<CloudDriveFile>.from(state.folders)
              ..removeWhere((f) => f.id == tempId);
            return state.copyWith(folders: folders);
          });
        },
        rollbackWhen: (data) => data == null,
        onSuccess: (createdFolder) async {
          if (createdFolder != null) {
            _stateManager.updateState((state) {
              final folders =
                  List<CloudDriveFile>.from(state.folders)
                    ..removeWhere((f) => f.id == tempId)
                    ..insert(0, createdFolder);
              return state.copyWith(folders: folders);
            });
            final updated = _stateManager.getCurrentState();
            _cacheManager.set(
              account.id,
              normalizedParent,
              updated.files,
              updated.folders,
            );
          } else {
            invalidateCache(account.id, normalizedParent);
            await loadFolder(forceRefresh: true);
          }
        },
        onError: (error) {
          _logger.error('创建文件夹失败: $error');
        },
      );

      final success = result != null;
      if (!success) {
        _logger.warning('文件夹创建失败');
        throw const CloudDriveException(
          '文件夹创建失败',
          CloudDriveErrorType.clientError,
          operation: '创建文件夹',
        );
      }
      return true;
    } on CloudDriveException catch (e) {
      _logger.error('创建文件夹失败: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.error('创建文件夹失败: $e');
      rethrow;
    }
  }

  (List<CloudDriveFile> folders, List<CloudDriveFile> files)
  _splitFoldersAndFiles(List<CloudDriveFile> items) {
    final folders = <CloudDriveFile>[];
    final files = <CloudDriveFile>[];
    for (final item in items) {
      if (item.isFolder) {
        folders.add(item);
      } else {
        files.add(item);
      }
    }
    return (folders, files);
  }
}

String _normalizeFolderId(String? folderId) {
  if (folderId == null || folderId.isEmpty || folderId == '/') {
    return '/';
  }
  return folderId;
}
