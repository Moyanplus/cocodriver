import '../models/cloud_drive_models.dart';

/// 文件列表状态
class FileListState {
  final List<CloudDriveFile> folders;
  final List<CloudDriveFile> files;
  final List<PathInfo> folderPath;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool isFromCache;
  final DateTime? lastRefreshTime;
  final String? error;
  final int currentPage;
  final bool hasMoreData;

  const FileListState({
    this.folders = const [],
    this.files = const [],
    this.folderPath = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.isFromCache = false,
    this.lastRefreshTime,
    this.error,
    this.currentPage = 1,
    this.hasMoreData = true,
  });

  FileListState copyWith({
    List<CloudDriveFile>? folders,
    List<CloudDriveFile>? files,
    List<PathInfo>? folderPath,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? isFromCache,
    DateTime? lastRefreshTime,
    String? error,
    int? currentPage,
    bool? hasMoreData,
  }) {
    return FileListState(
      folders: folders ?? this.folders,
      files: files ?? this.files,
      folderPath: folderPath ?? this.folderPath,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
      lastRefreshTime: lastRefreshTime ?? this.lastRefreshTime,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }

  /// 获取所有项目（文件夹+文件）
  List<CloudDriveFile> get allItems => [...folders, ...files];

  /// 检查是否有数据
  bool get hasData => folders.isNotEmpty || files.isNotEmpty;

  /// 检查是否为空
  bool get isEmpty => folders.isEmpty && files.isEmpty;

  /// 获取总数量
  int get totalCount => folders.length + files.length;
}
