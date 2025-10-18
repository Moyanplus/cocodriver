import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/base/debug_service.dart';
import '../core/cloud_drive_base_service.dart';
import '../core/cloud_drive_dependency_injection.dart';
import '../models/cloud_drive_models.dart';
import '../repositories/cloud_drive_repository.dart';
import 'cloud_drive_state.dart';

/// 文件列表Provider
class CloudDriveFileListProvider
    extends StateNotifier<CloudDriveFileListState> {
  CloudDriveFileListProvider() : super(const CloudDriveFileListState());

  /// 获取Repository实例
  CloudDriveRepositoryInterface get _repository =>
      CloudDriveDIProvider.repository;

  /// 获取文件列表
  Future<void> getFileList({
    required CloudDriveAccount account,
    String? folderId,
    int page = 1,
    int pageSize = 50,
    bool refresh = false,
  }) async {
    try {
      DebugService.log(
        '📁 Provider: 开始获取文件列表',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );

      // 如果是刷新，重置状态
      if (refresh) {
        state = state.copyWith(
          files: [],
          folders: [],
          isLoading: true,
          error: null,
          currentPage: 1,
          hasMore: false,
          totalCount: 0,
        );
      } else {
        // 否则设置加载状态
        state = state.copyWith(isLoading: true, error: null);
      }

      final request = FileListRequest(
        account: account,
        folderId: folderId,
        page: page,
        pageSize: pageSize,
      );

      final result = await _repository.getFileList(request);

      if (result.isSuccess) {
        // 如果是第一页或刷新，替换数据
        if (page == 1 || refresh) {
          state = state.copyWith(
            files: result.files,
            folders: result.folders,
            isLoading: false,
            hasMore: result.hasMore,
            totalCount: result.totalCount,
            currentPage: page,
            pageSize: pageSize,
            folderId: folderId,
            currentAccount: account,
            error: null,
          );
        } else {
          // 否则追加数据
          final newFiles = [...state.files, ...result.files];
          final newFolders = [...state.folders, ...result.folders];

          state = state.copyWith(
            files: newFiles,
            folders: newFolders,
            isLoading: false,
            hasMore: result.hasMore,
            totalCount: result.totalCount,
            currentPage: page,
            error: null,
          );
        }

        DebugService.log(
          '✅ Provider: 文件列表获取成功 - ${result.files.length} 个文件, ${result.folders.length} 个文件夹',
          category: DebugCategory.tools,
          subCategory: 'cloudDrive.provider',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error ?? '获取文件列表失败',
        );

        DebugService.log(
          '❌ Provider: 文件列表获取失败 - ${result.error}',
          category: DebugCategory.tools,
          subCategory: 'cloudDrive.provider',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());

      DebugService.log(
        '❌ Provider: 文件列表获取异常 - $e',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );
    }
  }

  /// 加载更多文件
  Future<void> loadMore() async {
    if (!state.canLoadMore) return;

    final nextPage = state.currentPage + 1;
    final account = state.currentAccount;

    if (account == null) {
      DebugService.log(
        '❌ Provider: 无法加载更多，当前账号为空',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );
      return;
    }

    await getFileList(
      account: account,
      folderId: state.folderId,
      page: nextPage,
      pageSize: state.pageSize,
    );
  }

  /// 刷新文件列表
  Future<void> refresh() async {
    final account = state.currentAccount;

    if (account == null) {
      DebugService.log(
        '❌ Provider: 无法刷新，当前账号为空',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );
      return;
    }

    await getFileList(
      account: account,
      folderId: state.folderId,
      refresh: true,
    );
  }

  /// 进入文件夹
  Future<void> enterFolder(String folderId, CloudDriveAccount account) async {
    DebugService.log(
      '📁 Provider: 进入文件夹 - $folderId',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.provider',
    );

    await getFileList(account: account, folderId: folderId, refresh: true);
  }

  /// 返回上级目录
  Future<void> goBack() async {
    final account = state.currentAccount;

    if (account == null) {
      DebugService.log(
        '❌ Provider: 无法返回上级目录，当前账号为空',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );
      return;
    }

    // 这里需要实现返回上级目录的逻辑
    // 暂时使用根目录
    final rootFolderId = account.type.webViewConfig.rootDir;

    DebugService.log(
      '📁 Provider: 返回上级目录 - $rootFolderId',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.provider',
    );

    await getFileList(account: account, folderId: rootFolderId, refresh: true);
  }

  /// 清空文件列表
  void clear() {
    state = const CloudDriveFileListState();

    DebugService.log(
      '🗑️ Provider: 清空文件列表',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.provider',
    );
  }

  /// 设置错误状态
  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);

    DebugService.log(
      '❌ Provider: 设置错误状态 - $error',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.provider',
    );
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);

    DebugService.log(
      '✅ Provider: 清除错误状态',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.provider',
    );
  }
}

/// 文件列表Provider实例
final cloudDriveFileListProvider =
    StateNotifierProvider<CloudDriveFileListProvider, CloudDriveFileListState>(
      (ref) => CloudDriveFileListProvider(),
    );
