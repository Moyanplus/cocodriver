import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/log_manager.dart';
import '../models/cloud_drive_models.dart';
import '../base/cloud_drive_file_service.dart';
import '../base/cloud_drive_cache_service.dart';
import '../base/cloud_drive_operation_service.dart';
import 'cloud_drive_file_list_state.dart';

/// 文件列表状态管理器
class FileListNotifier extends StateNotifier<FileListState> {
  FileListNotifier() : super(const FileListState());

  /// 加载文件列表
  Future<void> loadFileList({
    required CloudDriveAccount account,
    String? folderId,
    bool forceRefresh = false,
  }) async {
    LogManager().cloudDrive('📂 文件列表提供者 - 开始加载文件列表');
    LogManager().cloudDrive('🔄 强制刷新: $forceRefresh');
    LogManager().cloudDrive('📂 文件夹ID: $folderId');
    LogManager().cloudDrive(
      '👤 当前账号: ${account.name} (${account.type.displayName})',
    );

    // 生成缓存键
    final cacheKey = CloudDriveCacheService.generateCacheKey(
      account.id,
      state.folderPath,
    );
    LogManager().cloudDrive('🔑 缓存键: $cacheKey');

    try {
      // 如果不是强制刷新，先尝试显示缓存数据
      if (!forceRefresh) {
        LogManager().cloudDrive('🔍 文件列表提供者 - 尝试获取缓存数据');
        final cachedData = CloudDriveCacheService.getCachedData(
          cacheKey,
          const Duration(minutes: 5), // 缓存5分钟
        );

        if (cachedData != null) {
          LogManager().cloudDrive('📦 显示缓存数据: $cacheKey');
          LogManager().cloudDrive(
            '📁 缓存文件夹数量: ${cachedData['folders']?.length ?? 0}',
          );
          LogManager().cloudDrive(
            '📄 缓存文件数量: ${cachedData['files']?.length ?? 0}',
          );

          state = state.copyWith(
            folders: cachedData['folders'] ?? [],
            files: cachedData['files'] ?? [],
            isLoading: false,
            isFromCache: true,
            error: null,
          );

          // 如果有缓存数据，后台静默刷新
          LogManager().cloudDrive('🔄 文件列表提供者 - 开始后台刷新');
          state = state.copyWith(isRefreshing: true);
        } else {
          // 没有缓存数据，显示加载状态
          LogManager().cloudDrive('📡 文件列表提供者 - 无缓存数据，显示加载状态');
          state = state.copyWith(isLoading: true);
        }
      } else {
        // 强制刷新，显示加载状态
        LogManager().cloudDrive('🔄 文件列表提供者 - 强制刷新，显示加载状态');
        state = state.copyWith(
          isLoading: true,
          error: null,
          currentPage: 1,
          hasMoreData: true,
          isRefreshing: false,
          isFromCache: false,
        );
      }

      // 获取最新数据
      LogManager().cloudDrive('📡 文件列表提供者 - 开始调用文件列表API');
      final result = await CloudDriveFileService.getFileList(
        account: account,
        folderId: folderId,
        page: forceRefresh ? 1 : state.currentPage,
      );

      LogManager().cloudDrive('✅ 文件列表提供者 - 文件列表API调用成功');
      LogManager().cloudDrive('📁 返回文件夹数量: ${result['folders']?.length ?? 0}');
      LogManager().cloudDrive('📄 返回文件数量: ${result['files']?.length ?? 0}');

      // 更新缓存
      CloudDriveCacheService.cacheData(cacheKey, result);
      LogManager().cloudDrive('💾 更新缓存: $cacheKey');

      // 更新状态
      final newFolders = result['folders'] ?? [];
      final newFiles = result['files'] ?? [];
      final hasMore = (newFolders.length + newFiles.length) >= 50;

      LogManager().cloudDrive('📊 是否还有更多数据: $hasMore');

      state = state.copyWith(
        folders: newFolders,
        files: newFiles,
        isLoading: false,
        isRefreshing: false,
        isFromCache: false,
        lastRefreshTime: DateTime.now(),
        error: null,
        currentPage: forceRefresh ? 1 : state.currentPage + 1,
        hasMoreData: hasMore,
      );

      LogManager().cloudDrive(
        '✅ 数据加载完成: ${newFolders.length} 个文件夹, ${newFiles.length} 个文件',
      );
    } catch (e) {
      LogManager().cloudDrive('❌ 加载文件列表失败: $e');
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  /// 进入文件夹
  Future<void> enterFolder({
    required CloudDriveAccount account,
    required CloudDriveFile folder,
  }) async {
    LogManager().cloudDrive('🚀 文件列表提供者 - 开始进入文件夹');
    LogManager().cloudDrive('📁 文件夹名称: ${folder.name}');
    LogManager().cloudDrive('🆔 文件夹ID: ${folder.id}');
    LogManager().cloudDrive('📂 当前路径: ${state.folderPath}');

    // 构建新路径
    List<PathInfo> newPath;
    if (account.type == CloudDriveType.pan123 ||
        account.type == CloudDriveType.quark) {
      // 123云盘和夸克云盘：保存文件夹ID和名称
      newPath = [
        ...state.folderPath,
        PathInfo(id: folder.id, name: folder.name),
      ];
    } else {
      // 其他云盘：使用文件夹名称和ID
      newPath = [
        ...state.folderPath,
        PathInfo(id: folder.id, name: folder.name),
      ];
    }

    LogManager().cloudDrive('🔍 进入文件夹: ${folder.name}, 路径: ${folder.id}');

    try {
      LogManager().cloudDrive('🔄 文件列表提供者 - 更新状态为加载中');
      state = state.copyWith(
        folderPath: newPath,
        folders: [],
        files: [],
        currentPage: 1,
        hasMoreData: true,
        isLoading: true,
        error: null,
      );

      // 使用策略模式获取目标文件夹ID
      final folderId = CloudDriveOperationService.convertPathToTargetFolderId(
        cloudDriveType: account.type,
        folderPath: newPath,
      );

      LogManager().cloudDrive('🔧 策略模式路径构建结果: $folderId');

      // 加载新文件夹内容
      await loadFileList(
        account: account,
        folderId: folderId,
        forceRefresh: true,
      );

      LogManager().cloudDrive('✅ 文件列表提供者 - 进入文件夹完成');
    } catch (e) {
      LogManager().cloudDrive('❌ 文件列表提供者 - 进入文件夹失败: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 返回上级
  Future<void> goBack({required CloudDriveAccount account}) async {
    LogManager().cloudDrive('🔙 文件列表提供者 - 开始返回上级');
    LogManager().cloudDrive('📂 当前路径: ${state.folderPath}');
    LogManager().cloudDrive('📂 路径长度: ${state.folderPath.length}');

    if (state.folderPath.isEmpty) {
      LogManager().cloudDrive('⚠️ 文件列表提供者 - 已在根目录，无法返回');
      return;
    }

    final newPath = state.folderPath.sublist(0, state.folderPath.length - 1);
    LogManager().cloudDrive('📂 新路径: $newPath');

    LogManager().cloudDrive('🔄 文件列表提供者 - 更新状态');
    state = state.copyWith(
      folderPath: newPath,
      folders: [],
      files: [],
      currentPage: 1,
      hasMoreData: true,
    );

    // 使用策略模式获取目标文件夹ID
    final folderId = CloudDriveOperationService.convertPathToTargetFolderId(
      cloudDriveType: account.type,
      folderPath: newPath,
    );

    LogManager().cloudDrive('📡 文件列表提供者 - 开始加载当前文件夹');
    await loadFileList(
      account: account,
      folderId: folderId,
      forceRefresh: true,
    );
    LogManager().cloudDrive('✅ 文件列表提供者 - 返回上级完成');
  }

  /// 加载更多数据
  Future<void> loadMore({required CloudDriveAccount account}) async {
    if (!state.hasMoreData || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      // 使用策略模式获取目标文件夹ID
      final folderId = CloudDriveOperationService.convertPathToTargetFolderId(
        cloudDriveType: account.type,
        folderPath: state.folderPath,
      );

      await loadFileList(
        account: account,
        folderId: folderId,
        forceRefresh: false,
      );
    } finally {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// 添加文件到状态（复制/移动成功后调用）
  void addFileToState(CloudDriveFile file, {String? operationType}) {
    LogManager().cloudDrive(
      '➕ 添加文件到状态: ${file.name} (${file.isFolder ? '文件夹' : '文件'})',
    );

    if (file.isFolder) {
      // 添加到文件夹列表
      final updatedFolders = [...state.folders, file];
      state = state.copyWith(folders: updatedFolders);
      LogManager().cloudDrive('✅ 文件夹已添加到状态，总文件夹数: ${updatedFolders.length}');
    } else {
      // 添加到文件列表
      final updatedFiles = [...state.files, file];
      state = state.copyWith(files: updatedFiles);
      LogManager().cloudDrive('✅ 文件已添加到状态，总文件数: ${updatedFiles.length}');
    }
  }

  /// 从本地状态中移除文件（删除成功后调用）
  void removeFileFromState(String fileId) {
    LogManager().cloudDrive('🗑️ 从状态中移除文件: $fileId');

    final updatedFiles =
        state.files.where((file) => file.id != fileId).toList();
    final updatedFolders =
        state.folders.where((folder) => folder.id != fileId).toList();

    state = state.copyWith(files: updatedFiles, folders: updatedFolders);

    LogManager().cloudDrive(
      '✅ 文件已从状态中移除，剩余文件数: ${updatedFiles.length}，文件夹数: ${updatedFolders.length}',
    );
  }

  /// 更新文件信息（重命名成功后调用）
  void updateFileInState(String fileId, String newName) {
    LogManager().cloudDrive('✏️ 更新文件信息: $fileId -> $newName');

    // 更新文件列表
    final updatedFiles =
        state.files.map((file) {
          if (file.id == fileId) {
            return file.copyWith(name: newName);
          }
          return file;
        }).toList();

    // 更新文件夹列表
    final updatedFolders =
        state.folders.map((folder) {
          if (folder.id == fileId) {
            return folder.copyWith(name: newName);
          }
          return folder;
        }).toList();

    state = state.copyWith(files: updatedFiles, folders: updatedFolders);

    LogManager().cloudDrive('✅ 文件信息已更新');
  }

  /// 清空状态
  void clearState() {
    state = const FileListState();
  }
}

/// 文件列表Provider
final fileListProvider = StateNotifierProvider<FileListNotifier, FileListState>(
  (ref) => FileListNotifier(),
);
