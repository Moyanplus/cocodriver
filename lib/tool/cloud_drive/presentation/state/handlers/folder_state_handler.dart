import '../../../../../core/logging/log_manager.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../data/models/cloud_drive_dtos.dart'; // 导入 PathInfo
import '../../../base/cloud_drive_file_service.dart';
import '../cloud_drive_state_manager.dart';

/// 文件夹状态处理器
class FolderStateHandler {
  final CloudDriveStateManager _stateManager;

  FolderStateHandler(this._stateManager);

  /// 加载文件夹内容
  ///
  /// 加载当前文件夹下的所有文件和子文件夹
  /// 设置加载状态，处理加载过程中的错误
  ///
  /// [forceRefresh] 是否强制刷新，忽略缓存
  Future<void> loadFolder({bool forceRefresh = false}) async {
    final account = _stateManager.state.currentAccount;
    if (account == null) {
      LogManager().cloudDrive('⚠️ 没有当前账号，无法加载文件夹');
      return;
    }

    LogManager().cloudDrive(
      '🔄 加载文件夹内容: ${_stateManager.state.currentFolder?.name ?? '根目录'}',
    );

    try {
      _stateManager.state = _stateManager.state.copyWith(
        isLoading: true,
        error: null,
      );

      final folderId = _stateManager.state.currentFolder?.id ?? '/';
      final result = await CloudDriveFileService.getFileList(
        account: account,
        folderId: folderId,
        forceRefresh: forceRefresh,
      );

      _stateManager.state = _stateManager.state.copyWith(
        files: result['files'] ?? [],
        folders: result['folders'] ?? [],
        isLoading: false,
        error: null,
      );

      LogManager().cloudDrive(
        '✅ 文件夹内容加载成功: ${result['files']?.length ?? 0}个文件, ${result['folders']?.length ?? 0}个文件夹',
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
      LogManager().cloudDrive('⚠️ 尝试进入非文件夹: ${folder.name}');
      return;
    }

    LogManager().cloudDrive('🔄 进入文件夹: ${folder.name}');

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
      // forceRefresh: true 强制刷新，确保显示最新内容
      await loadFolder(forceRefresh: true);

      LogManager().cloudDrive('✅ 进入文件夹成功: ${folder.name}');
    } catch (e) {
      LogManager().error('❌ 进入文件夹失败: $e');
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
      LogManager().cloudDrive('⚠️ 已在根目录，无法返回');
      return;
    }

    LogManager().cloudDrive('🔄 返回上级目录');

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
      _stateManager.state = _stateManager.state.copyWith(
        currentFolder: parentFolder, // 更新当前文件夹为父文件夹
        folderPath: newPath, // 更新路径链（已移除最后一个节点）
        selectedItems: {}, // 清空选中项
        isInBatchMode: false, // 退出批量模式
        error: null, // 清空错误信息
      );

      // ========== 步骤4：加载父文件夹的内容 ==========
      // forceRefresh: true 强制刷新，确保显示最新内容
      await loadFolder(forceRefresh: true);

      LogManager().cloudDrive('✅ 返回上级目录成功');
    } catch (e) {
      LogManager().error('❌ 返回上级目录失败: $e');
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
      LogManager().cloudDrive('⚠️ 没有当前账号，无法加载更多');
      return;
    }

    LogManager().cloudDrive('🔄 加载更多内容');

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
        '✅ 加载更多内容成功: ${newFiles.length}个文件, ${newFolders.length}个文件夹',
      );
    } catch (e) {
      LogManager().error('❌ 加载更多内容失败: $e');
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
    LogManager().cloudDrive('🔄 刷新当前文件夹');
    await loadFolder(forceRefresh: true);
  }
}
