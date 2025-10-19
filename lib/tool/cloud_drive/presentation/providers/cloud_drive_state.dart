import '../../data/models/cloud_drive_entities.dart';

/// 云盘文件列表状态
class CloudDriveFileListState {
  final List<CloudDriveFile> files;
  final List<CloudDriveFile> folders;
  final bool isLoading;
  final bool hasMore;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final String? error;
  final String? folderId;
  final CloudDriveAccount? currentAccount;

  const CloudDriveFileListState({
    this.files = const [],
    this.folders = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.totalCount = 0,
    this.currentPage = 1,
    this.pageSize = 50,
    this.error,
    this.folderId,
    this.currentAccount,
  });

  /// 是否为空
  bool get isEmpty => files.isEmpty && folders.isEmpty;

  /// 是否有错误
  bool get hasError => error != null;

  /// 总文件数
  int get totalFiles => files.length + folders.length;

  /// 是否可以加载更多
  bool get canLoadMore => hasMore && !isLoading;

  /// 复制并更新
  CloudDriveFileListState copyWith({
    List<CloudDriveFile>? files,
    List<CloudDriveFile>? folders,
    bool? isLoading,
    bool? hasMore,
    int? totalCount,
    int? currentPage,
    int? pageSize,
    String? error,
    String? folderId,
    CloudDriveAccount? currentAccount,
  }) => CloudDriveFileListState(
    files: files ?? this.files,
    folders: folders ?? this.folders,
    isLoading: isLoading ?? this.isLoading,
    hasMore: hasMore ?? this.hasMore,
    totalCount: totalCount ?? this.totalCount,
    currentPage: currentPage ?? this.currentPage,
    pageSize: pageSize ?? this.pageSize,
    error: error ?? this.error,
    folderId: folderId ?? this.folderId,
    currentAccount: currentAccount ?? this.currentAccount,
  );
}

/// 云盘文件详情状态
class CloudDriveFileDetailState {
  final CloudDriveFile? file;
  final Map<String, dynamic>? metadata;
  final bool isLoading;
  final String? error;

  const CloudDriveFileDetailState({
    this.file,
    this.metadata,
    this.isLoading = false,
    this.error,
  });

  /// 是否为空
  bool get isEmpty => file == null;

  /// 是否有错误
  bool get hasError => error != null;

  /// 是否加载完成
  bool get isLoaded => file != null && !isLoading;

  /// 复制并更新
  CloudDriveFileDetailState copyWith({
    CloudDriveFile? file,
    Map<String, dynamic>? metadata,
    bool? isLoading,
    String? error,
  }) => CloudDriveFileDetailState(
    file: file ?? this.file,
    metadata: metadata ?? this.metadata,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );
}

/// 云盘搜索状态
class CloudDriveSearchState {
  final List<CloudDriveFile> searchResults;
  final String keyword;
  final bool isSearching;
  final bool hasMore;
  final int currentPage;
  final int pageSize;
  final String? error;
  final String? folderId;

  const CloudDriveSearchState({
    this.searchResults = const [],
    this.keyword = '',
    this.isSearching = false,
    this.hasMore = false,
    this.currentPage = 1,
    this.pageSize = 50,
    this.error,
    this.folderId,
  });

  /// 是否为空
  bool get isEmpty => searchResults.isEmpty;

  /// 是否有错误
  bool get hasError => error != null;

  /// 是否有搜索关键词
  bool get hasKeyword => keyword.isNotEmpty;

  /// 是否可以加载更多
  bool get canLoadMore => hasMore && !isSearching;

  /// 复制并更新
  CloudDriveSearchState copyWith({
    List<CloudDriveFile>? searchResults,
    String? keyword,
    bool? isSearching,
    bool? hasMore,
    int? currentPage,
    int? pageSize,
    String? error,
    String? folderId,
  }) => CloudDriveSearchState(
    searchResults: searchResults ?? this.searchResults,
    keyword: keyword ?? this.keyword,
    isSearching: isSearching ?? this.isSearching,
    hasMore: hasMore ?? this.hasMore,
    currentPage: currentPage ?? this.currentPage,
    pageSize: pageSize ?? this.pageSize,
    error: error ?? this.error,
    folderId: folderId ?? this.folderId,
  );
}

/// 云盘最近文件状态
class CloudDriveRecentFilesState {
  final List<CloudDriveFile> recentFiles;
  final bool isLoading;
  final int limit;
  final String? error;

  const CloudDriveRecentFilesState({
    this.recentFiles = const [],
    this.isLoading = false,
    this.limit = 20,
    this.error,
  });

  /// 是否为空
  bool get isEmpty => recentFiles.isEmpty;

  /// 是否有错误
  bool get hasError => error != null;

  /// 复制并更新
  CloudDriveRecentFilesState copyWith({
    List<CloudDriveFile>? recentFiles,
    bool? isLoading,
    int? limit,
    String? error,
  }) => CloudDriveRecentFilesState(
    recentFiles: recentFiles ?? this.recentFiles,
    isLoading: isLoading ?? this.isLoading,
    limit: limit ?? this.limit,
    error: error ?? this.error,
  );
}

/// 云盘文件预览状态
class CloudDriveFilePreviewState {
  final CloudDriveFile? file;
  final Map<String, dynamic>? previewData;
  final bool isLoading;
  final bool isSupported;
  final String? error;

  const CloudDriveFilePreviewState({
    this.file,
    this.previewData,
    this.isLoading = false,
    this.isSupported = false,
    this.error,
  });

  /// 是否为空
  bool get isEmpty => file == null;

  /// 是否有错误
  bool get hasError => error != null;

  /// 是否加载完成
  bool get isLoaded => previewData != null && !isLoading;

  /// 复制并更新
  CloudDriveFilePreviewState copyWith({
    CloudDriveFile? file,
    Map<String, dynamic>? previewData,
    bool? isLoading,
    bool? isSupported,
    String? error,
  }) => CloudDriveFilePreviewState(
    file: file ?? this.file,
    previewData: previewData ?? this.previewData,
    isLoading: isLoading ?? this.isLoading,
    isSupported: isSupported ?? this.isSupported,
    error: error ?? this.error,
  );
}

/// 云盘整体状态
class CloudDriveState {
  final CloudDriveFileListState fileList;
  final CloudDriveFileDetailState fileDetail;
  final CloudDriveSearchState search;
  final CloudDriveRecentFilesState recentFiles;
  final CloudDriveFilePreviewState filePreview;
  final List<CloudDriveAccount> accounts;
  final CloudDriveAccount? selectedAccount;
  final bool isInitialized;

  const CloudDriveState({
    this.fileList = const CloudDriveFileListState(),
    this.fileDetail = const CloudDriveFileDetailState(),
    this.search = const CloudDriveSearchState(),
    this.recentFiles = const CloudDriveRecentFilesState(),
    this.filePreview = const CloudDriveFilePreviewState(),
    this.accounts = const [],
    this.selectedAccount,
    this.isInitialized = false,
  });

  /// 是否有选中的账号
  bool get hasSelectedAccount => selectedAccount != null;

  /// 是否有账号
  bool get hasAccounts => accounts.isNotEmpty;

  /// 是否已初始化
  bool get isReady => isInitialized && hasSelectedAccount;

  /// 是否有任何错误
  bool get hasAnyError =>
      fileList.hasError ||
      fileDetail.hasError ||
      search.hasError ||
      recentFiles.hasError ||
      filePreview.hasError;

  /// 是否正在加载
  bool get isLoading =>
      fileList.isLoading ||
      fileDetail.isLoading ||
      search.isSearching ||
      recentFiles.isLoading ||
      filePreview.isLoading;

  /// 复制并更新
  CloudDriveState copyWith({
    CloudDriveFileListState? fileList,
    CloudDriveFileDetailState? fileDetail,
    CloudDriveSearchState? search,
    CloudDriveRecentFilesState? recentFiles,
    CloudDriveFilePreviewState? filePreview,
    List<CloudDriveAccount>? accounts,
    CloudDriveAccount? selectedAccount,
    bool? isInitialized,
  }) => CloudDriveState(
    fileList: fileList ?? this.fileList,
    fileDetail: fileDetail ?? this.fileDetail,
    search: search ?? this.search,
    recentFiles: recentFiles ?? this.recentFiles,
    filePreview: filePreview ?? this.filePreview,
    accounts: accounts ?? this.accounts,
    selectedAccount: selectedAccount ?? this.selectedAccount,
    isInitialized: isInitialized ?? this.isInitialized,
  );
}

/// 云盘账号状态
class CloudDriveAccountState {
  final List<CloudDriveAccount> accounts;
  final CloudDriveAccount? selectedAccount;
  final bool isLoading;
  final String? error;
  final bool isAccountSelectorVisible;

  const CloudDriveAccountState({
    this.accounts = const [],
    this.selectedAccount,
    this.isLoading = false,
    this.error,
    this.isAccountSelectorVisible = false,
  });

  /// 是否有账号
  bool get hasAccounts => accounts.isNotEmpty;

  /// 是否有选中的账号
  bool get hasSelectedAccount => selectedAccount != null;

  /// 是否有错误
  bool get hasError => error != null;

  /// 复制并更新
  CloudDriveAccountState copyWith({
    List<CloudDriveAccount>? accounts,
    CloudDriveAccount? selectedAccount,
    bool? isLoading,
    String? error,
    bool? isAccountSelectorVisible,
  }) => CloudDriveAccountState(
    accounts: accounts ?? this.accounts,
    selectedAccount: selectedAccount ?? this.selectedAccount,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
    isAccountSelectorVisible:
        isAccountSelectorVisible ?? this.isAccountSelectorVisible,
  );
}
