import '../../../../../core/logging/log_manager.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../data/models/cloud_drive_dtos.dart'; // 导入 PathInfo
import '../../../base/cloud_drive_file_service.dart';
import '../../../data/cache/file_list_cache.dart'; // 导入缓存管理器
import '../cloud_drive_state_manager.dart';
import '../cloud_drive_state_model.dart'; // 导入 CloudDriveState

/// 文件夹状态处理器
class FolderStateHandler {
  final CloudDriveStateManager _stateManager;
  final FileListCacheManager _cacheManager = FileListCacheManager();

  FolderStateHandler(this._stateManager);

  /// 加载文件夹内容
  ///
  /// 加载当前文件夹下的所有文件和子文件夹
  /// 【优化】使用缓存机制，避免频繁网络请求
  ///
  /// [forceRefresh] 是否强制刷新，忽略缓存
  Future<void> loadFolder({bool forceRefresh = false}) async {
    final account = _stateManager.state.currentAccount;
    if (account == null) {
      LogManager().cloudDrive('没有当前账号，无法加载文件夹');
      return;
    }

    final folderId = _stateManager.state.currentFolder?.id ?? '/';
    LogManager().cloudDrive(
      '📂 加载文件夹: ${_stateManager.state.currentFolder?.name ?? '根目录'} (ID: $folderId)',
    );

    try {
      // ========== 步骤1：检查缓存 ==========
      if (!forceRefresh) {
        final cachedData = _cacheManager.get(account.id, folderId);
        if (cachedData != null) {
          // 缓存命中！直接使用缓存数据
          LogManager().cloudDrive(
            '⚡ 使用缓存数据 (${cachedData.files.length} 文件, ${cachedData.folders.length} 文件夹, '
            '剩余 ${cachedData.remainingSeconds}s)',
          );

          _stateManager.state = _stateManager.state.copyWith(
            files: List.from(cachedData.files),
            folders: List.from(cachedData.folders),
            isLoading: false,
            isFromCache: true, // 标记为来自缓存
            error: null,
          );

          return; // 直接返回，不进行网络请求
        }
      }

      // ========== 步骤2：缓存未命中或强制刷新，从网络获取 ==========
      _stateManager.state = _stateManager.state.copyWith(
        isLoading: true,
        error: null,
      );

      LogManager().cloudDrive('🌐 从网络获取数据...');

      final result = await CloudDriveFileService.getFileList(
        account: account,
        folderId: folderId,
        forceRefresh: forceRefresh,
      );

      // 强制创建新的列表引用
      final newFiles = List<CloudDriveFile>.from(result['files'] ?? []);
      final newFolders = List<CloudDriveFile>.from(result['folders'] ?? []);

      LogManager().cloudDrive(
        '✅ 网络数据获取成功: ${newFiles.length} 文件, ${newFolders.length} 文件夹',
      );

      // ========== 步骤3：更新缓存 ==========
      _cacheManager.set(account.id, folderId, newFiles, newFolders);

      // ========== 步骤4：更新状态 ==========
      _stateManager.state = _stateManager.state.copyWith(
        files: newFiles,
        folders: newFolders,
        isLoading: false,
        isFromCache: false, // 标记为来自网络
        lastRefreshTime: DateTime.now(),
        error: null,
      );

      LogManager().cloudDrive(
        '📌 状态更新完成 - 文件: ${_stateManager.state.files.length}, 文件夹: ${_stateManager.state.folders.length}',
      );
    } catch (e) {
      LogManager().error('❌ 加载文件夹内容失败: $e');
      _stateManager.state = _stateManager.state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 进入指定文件夹
  ///
  /// 【核心功能】导航到指定的文件夹并加载其内容
  ///
  /// 工作原理：
  /// 1. 验证目标是否为文件夹（isDirectory == true）
  /// 2. 将新文件夹添加到路径链 folderPath 的末尾
  /// 3. 更新状态：currentFolder 和 folderPath
  /// 4. 加载新文件夹的内容（文件和子文件夹列表）
  /// 5. 清空选中项和退出批量模式
  ///
  /// 例如：
  /// - 当前路径：根目录 > 文档（folderPath = [文档]）
  /// - 点击 "工作" 文件夹后：根目录 > 文档 > 工作（folderPath = [文档, 工作]）
  /// - currentFolder 变为 "工作" 文件夹
  ///
  /// 【重要】路径链 folderPath 用于：
  /// - 路径导航器显示面包屑导航（例如：根目录 > 文档 > 工作）
  /// - 返回上级功能的路径追踪
  ///
  /// [folder] 要进入的文件夹对象
  Future<void> enterFolder(CloudDriveFile folder) async {
    // ========== 边界检查：确保传入的是文件夹而非文件 ==========
    if (!folder.isDirectory) {
      LogManager().cloudDrive('尝试进入非文件夹: ${folder.name}');
      return;
    }

    LogManager().cloudDrive('进入文件夹: ${folder.name}');

    try {
      // ========== 步骤1：更新路径链，添加新文件夹到末尾 ==========
      // 复制当前的路径链
      final currentPath = List<PathInfo>.from(_stateManager.state.folderPath);
      // 将新文件夹添加到路径链的末尾
      currentPath.add(PathInfo(id: folder.id, name: folder.name));

      // 打印日志：显示完整的路径链
      LogManager().cloudDrive(
        '📍 更新路径: ${currentPath.map((p) => p.name).join(' > ')}',
      );

      // ========== 步骤2：更新状态 ==========
      _stateManager.state = _stateManager.state.copyWith(
        currentFolder: folder, // 更新当前文件夹
        folderPath: currentPath, // 更新路径链（已添加新文件夹）
        selectedItems: {}, // 清空选中项
        isInBatchMode: false, // 退出批量模式
        error: null, // 清空错误信息
      );

      // ========== 步骤3：加载新文件夹的内容 ==========
      // 【优化】优先使用缓存，提升响应速度
      await loadFolder(forceRefresh: false);

      LogManager().cloudDrive('进入文件夹成功: ${folder.name}');
    } catch (e) {
      LogManager().error('进入文件夹失败: $e');
      _stateManager.state = _stateManager.state.copyWith(error: e.toString());
    }
  }

  /// 跳转到路径中的指定位置
  ///
  /// 【核心功能】点击面包屑导航中的某个节点时，跳转到该层级并截断后面的路径
  ///
  /// 工作原理：
  /// 1. 截取路径链到指定的索引位置（包含该索引）
  /// 2. 根据新路径确定目标文件夹：
  ///    - 如果新路径为空 → 跳转到根目录（targetFolder = null）
  ///    - 如果新路径不为空 → 目标文件夹是新路径中的最后一个节点
  /// 3. 更新状态：currentFolder 和 folderPath
  /// 4. 重新加载目标文件夹的内容
  ///
  /// 例如：
  /// - 当前路径：根目录 > 文档 > 工作 > 2024（folderPath = [文档, 工作, 2024]，索引：0, 1, 2）
  /// - 点击"工作"（index=1）后：根目录 > 文档 > 工作（folderPath = [文档, 工作]）
  /// - 点击"文档"（index=0）后：根目录 > 文档（folderPath = [文档]）
  ///
  /// [pathIndex] 路径链中的索引位置（从0开始）
  Future<void> navigateToPathIndex(int pathIndex) async {
    final currentPath = _stateManager.state.folderPath;

    // ========== 边界检查：索引是否有效 ==========
    if (pathIndex < 0 || pathIndex >= currentPath.length) {
      LogManager().cloudDrive('无效的路径索引: $pathIndex');
      return;
    }

    LogManager().cloudDrive('跳转到路径索引: $pathIndex');

    try {
      // ========== 步骤1：截取路径到指定索引（包含该索引） ==========
      // 例如：路径 [A, B, C, D]，index=1 → 新路径 [A, B]
      final newPath = currentPath.sublist(0, pathIndex + 1);

      // ========== 步骤2：确定目标文件夹 ==========
      CloudDriveFile? targetFolder;
      if (newPath.isEmpty) {
        // 情况1：新路径为空，说明要跳转到根目录
        targetFolder = null;
      } else {
        // 情况2：新路径不为空，目标文件夹是新路径中的最后一个
        final targetPathInfo = newPath.last;
        targetFolder = CloudDriveFile(
          id: targetPathInfo.id,
          name: targetPathInfo.name,
          isFolder: true,
        );
      }

      // 打印日志：显示新的路径
      LogManager().cloudDrive(
        '📍 跳转到: ${newPath.isEmpty ? '根目录' : newPath.map((p) => p.name).join(' > ')}',
      );

      // ========== 步骤3：更新状态 ==========
      _stateManager.state = CloudDriveState(
        accounts: _stateManager.state.accounts,
        currentAccount: _stateManager.state.currentAccount,
        currentFolder: targetFolder, // 目标文件夹
        folders: _stateManager.state.folders,
        files: _stateManager.state.files,
        folderPath: newPath, // 截断后的路径链
        isLoading: _stateManager.state.isLoading,
        isRefreshing: _stateManager.state.isRefreshing,
        error: null, // 清空错误信息
        isBatchMode: _stateManager.state.isBatchMode,
        isInBatchMode: false, // 退出批量模式
        selectedItems: {}, // 清空选中项
        isAllSelected: false,
        currentPage: _stateManager.state.currentPage,
        hasMoreData: _stateManager.state.hasMoreData,
        isLoadingMore: _stateManager.state.isLoadingMore,
        isFromCache: _stateManager.state.isFromCache,
        lastRefreshTime: _stateManager.state.lastRefreshTime,
        showAccountSelector: _stateManager.state.showAccountSelector,
        pendingOperationFile: _stateManager.state.pendingOperationFile,
        pendingOperationType: _stateManager.state.pendingOperationType,
        showFloatingActionButton: _stateManager.state.showFloatingActionButton,
      );

      // ========== 步骤4：加载目标文件夹的内容 ==========
      // 【优化】优先使用缓存
      await loadFolder(forceRefresh: false);

      LogManager().cloudDrive('跳转成功');
    } catch (e) {
      LogManager().error('跳转失败: $e');
      _stateManager.state = _stateManager.state.copyWith(error: e.toString());
    }
  }

  /// 返回上级目录
  ///
  /// 【核心功能】从当前文件夹返回到上级文件夹
  ///
  /// 工作原理：
  /// 1. 检查当前是否在根目录（currentFolder == null 或 folderPath.isEmpty）
  /// 2. 从路径链 folderPath 中移除最后一个节点（当前文件夹）
  /// 3. 根据新的路径链确定父文件夹：
  ///    - 如果新路径为空 → 返回根目录（parentFolder = null）
  ///    - 如果新路径不为空 → 父文件夹是路径链中的最后一个节点
  /// 4. 更新状态：currentFolder 和 folderPath
  /// 5. 重新加载父文件夹的内容
  ///
  /// 例如：
  /// - 当前路径：根目录 > 文档 > 工作 > 2024（folderPath = [文档, 工作, 2024]）
  /// - 点击返回后：根目录 > 文档 > 工作（folderPath = [文档, 工作]）
  /// - currentFolder 变为 "工作" 文件夹
  ///
  /// 【注意】如果已在根目录则无法返回，会直接返回不做任何操作
  Future<void> goBack() async {
    // 获取当前文件夹和路径链
    final currentFolder = _stateManager.state.currentFolder;
    final currentPath = _stateManager.state.folderPath;

    // ========== 边界检查：如果已在根目录，无法继续返回 ==========
    // currentFolder == null 表示已在根目录
    // currentPath.isEmpty 也表示已在根目录（路径链为空）
    if (currentFolder == null || currentPath.isEmpty) {
      LogManager().cloudDrive('已在根目录，无法返回');
      return;
    }

    LogManager().cloudDrive('返回上级目录');

    try {
      // ========== 步骤1：从路径链中移除最后一个节点 ==========
      // 复制一份路径链，避免直接修改状态
      final newPath = List<PathInfo>.from(currentPath);
      // 移除当前文件夹（路径链的最后一个元素）
      newPath.removeLast();

      // ========== 步骤2：确定父文件夹 ==========
      CloudDriveFile? parentFolder;
      if (newPath.isEmpty) {
        // 情况1：新路径为空，说明要返回根目录
        // 根目录的 currentFolder 为 null
        parentFolder = null;
      } else {
        // 情况2：新路径不为空，父文件夹是路径链中的最后一个
        // 例如：路径链 [文档, 工作]，父文件夹就是 "工作"
        final parentPathInfo = newPath.last;
        parentFolder = CloudDriveFile(
          id: parentPathInfo.id,
          name: parentPathInfo.name,
          isFolder: true,
        );
      }

      // 打印日志：显示新的路径
      LogManager().cloudDrive(
        '📍 更新路径: ${newPath.isEmpty ? '根目录' : newPath.map((p) => p.name).join(' > ')}',
      );

      // ========== 步骤3：更新状态 ==========
      // 注意：由于 copyWith 无法正确处理 null 值，我们需要直接创建新状态
      _stateManager.state = CloudDriveState(
        accounts: _stateManager.state.accounts,
        currentAccount: _stateManager.state.currentAccount,
        currentFolder: parentFolder, // 可能为 null（根目录）或父文件夹
        folders: _stateManager.state.folders,
        files: _stateManager.state.files,
        folderPath: newPath, // 更新后的路径链
        isLoading: _stateManager.state.isLoading,
        isRefreshing: _stateManager.state.isRefreshing,
        error: null, // 清空错误信息
        isBatchMode: _stateManager.state.isBatchMode,
        isInBatchMode: false, // 退出批量模式
        selectedItems: {}, // 清空选中项
        isAllSelected: false,
        currentPage: _stateManager.state.currentPage,
        hasMoreData: _stateManager.state.hasMoreData,
        isLoadingMore: _stateManager.state.isLoadingMore,
        isFromCache: _stateManager.state.isFromCache,
        lastRefreshTime: _stateManager.state.lastRefreshTime,
        showAccountSelector: _stateManager.state.showAccountSelector,
        pendingOperationFile: _stateManager.state.pendingOperationFile,
        pendingOperationType: _stateManager.state.pendingOperationType,
        showFloatingActionButton: _stateManager.state.showFloatingActionButton,
      );

      // ========== 步骤4：加载父文件夹的内容 ==========
      // 【优化】优先使用缓存，返回上级目录响应更快
      await loadFolder(forceRefresh: false);

      LogManager().cloudDrive('返回上级目录成功');
    } catch (e) {
      LogManager().error('返回上级目录失败: $e');
      _stateManager.state = _stateManager.state.copyWith(error: e.toString());
    }
  }

  /// 加载更多内容
  ///
  /// 分页加载更多文件和文件夹
  /// 将新内容追加到现有列表中
  Future<void> loadMore() async {
    final account = _stateManager.state.currentAccount;
    if (account == null) {
      LogManager().cloudDrive('没有当前账号，无法加载更多');
      return;
    }

    LogManager().cloudDrive('加载更多内容');

    try {
      _stateManager.state = _stateManager.state.copyWith(
        isLoadingMore: true,
        error: null,
      );

      final folderId = _stateManager.state.currentFolder?.id ?? '/';
      final currentPage = _stateManager.state.currentPage;
      final result = await CloudDriveFileService.getFileList(
        account: account,
        folderId: folderId,
        page: currentPage + 1,
        pageSize: 50,
      );

      final newFiles = result['files'] ?? [];
      final newFolders = result['folders'] ?? [];

      _stateManager.state = _stateManager.state.copyWith(
        files: [..._stateManager.state.files, ...newFiles],
        folders: [..._stateManager.state.folders, ...newFolders],
        currentPage: currentPage + 1,
        hasMoreData: newFiles.length >= 50, // 假设如果返回的文件数等于页面大小，还有更多数据
        isLoadingMore: false,
        error: null,
      );

      LogManager().cloudDrive(
        '加载更多内容成功: ${newFiles.length}个文件, ${newFolders.length}个文件夹',
      );
    } catch (e) {
      LogManager().error('加载更多内容失败: $e');
      _stateManager.state = _stateManager.state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// 刷新当前文件夹
  ///
  /// 强制刷新当前文件夹的内容
  /// 忽略缓存，重新从服务器获取数据
  Future<void> refresh() async {
    LogManager().cloudDrive('刷新当前文件夹');
    await loadFolder(forceRefresh: true);
  }

  /// 移动文件到目标文件夹
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    try {
      LogManager().cloudDrive('移动文件: ${file.name} -> $targetFolderId');

      final success = await CloudDriveFileService.moveFile(
        account: account,
        file: file,
        targetFolderId: targetFolderId,
      );

      if (success) {
        LogManager().cloudDrive('文件移动成功: ${file.name}');
      } else {
        LogManager().cloudDrive('文件移动失败');
      }

      return success;
    } catch (e) {
      LogManager().error('移动文件失败: $e');
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
      LogManager().cloudDrive('复制文件: ${file.name} -> $targetFolderId');

      final success = await CloudDriveFileService.copyFile(
        account: account,
        file: file,
        destPath: targetFolderId ?? '',
      );

      if (success) {
        LogManager().cloudDrive('文件复制成功: ${file.name}');
      } else {
        LogManager().cloudDrive('文件复制失败');
      }

      return success;
    } catch (e) {
      LogManager().error('复制文件失败: $e');
      return false;
    }
  }
}
