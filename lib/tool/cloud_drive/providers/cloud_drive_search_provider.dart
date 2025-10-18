import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base/debug_service.dart';
import '../models/cloud_drive_models.dart';
import '../repositories/cloud_drive_repository.dart';
import 'cloud_drive_state.dart';

/// 搜索Provider
class CloudDriveSearchProvider extends StateNotifier<CloudDriveSearchState> {
  final CloudDriveRepository _repository;

  CloudDriveSearchProvider(this._repository)
    : super(const CloudDriveSearchState());

  /// 搜索文件
  Future<void> searchFiles({
    required CloudDriveAccount account,
    required String keyword,
    String? folderId,
    int page = 1,
    int pageSize = 50,
    bool refresh = false,
  }) async {
    try {
      DebugService.log(
        '🔍 Provider: 开始搜索文件',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );

      // 如果是刷新，重置状态
      if (refresh) {
        state = state.copyWith(
          searchResults: [],
          isSearching: true,
          error: null,
          currentPage: 1,
          hasMore: false,
        );
      } else {
        // 否则设置搜索状态
        state = state.copyWith(isSearching: true, error: null);
      }

      final result = await _repository.searchFiles(
        account: account,
        keyword: keyword,
        folderId: folderId,
        page: page,
        pageSize: pageSize,
      );

      if (result.isSuccess) {
        // 如果是第一页或刷新，替换数据
        if (page == 1 || refresh) {
          state = state.copyWith(
            searchResults: result.files,
            keyword: keyword,
            isSearching: false,
            hasMore: result.hasMore,
            currentPage: page,
            pageSize: pageSize,
            folderId: folderId,
            error: null,
          );
        } else {
          // 否则追加数据
          final newResults = [...state.searchResults, ...result.files];

          state = state.copyWith(
            searchResults: newResults,
            isSearching: false,
            hasMore: result.hasMore,
            currentPage: page,
            error: null,
          );
        }

        DebugService.log(
          '✅ Provider: 搜索成功 - ${result.files.length} 个结果',
          category: DebugCategory.tools,
          subCategory: 'cloudDrive.provider',
        );
      } else {
        state = state.copyWith(
          isSearching: false,
          error: result.error ?? '搜索失败',
        );

        DebugService.log(
          '❌ Provider: 搜索失败 - ${result.error}',
          category: DebugCategory.tools,
          subCategory: 'cloudDrive.provider',
        );
      }
    } catch (e) {
      state = state.copyWith(isSearching: false, error: e.toString());

      DebugService.log(
        '❌ Provider: 搜索异常 - $e',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );
    }
  }

  /// 加载更多搜索结果
  Future<void> loadMore(CloudDriveAccount account) async {
    if (!state.canLoadMore) return;

    final nextPage = state.currentPage + 1;

    await searchFiles(
      account: account,
      keyword: state.keyword,
      folderId: state.folderId,
      page: nextPage,
      pageSize: state.pageSize,
    );
  }

  /// 刷新搜索结果
  Future<void> refresh(CloudDriveAccount account) async {
    await searchFiles(
      account: account,
      keyword: state.keyword,
      folderId: state.folderId,
      refresh: true,
    );
  }

  /// 清空搜索结果
  void clear() {
    state = const CloudDriveSearchState();

    DebugService.log(
      '🗑️ Provider: 清空搜索结果',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.provider',
    );
  }

  /// 设置搜索关键词
  void setKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);

    DebugService.log(
      '🔍 Provider: 设置搜索关键词 - $keyword',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.provider',
    );
  }

  /// 设置错误状态
  void setError(String error) {
    state = state.copyWith(error: error, isSearching: false);

    DebugService.log(
      '❌ Provider: 设置搜索错误状态 - $error',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.provider',
    );
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);

    DebugService.log(
      '✅ Provider: 清除搜索错误状态',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.provider',
    );
  }
}

/// 搜索Provider实例
final cloudDriveSearchProvider =
    StateNotifierProvider<CloudDriveSearchProvider, CloudDriveSearchState>(
      (ref) => CloudDriveSearchProvider(CloudDriveRepository.instance),
    );
