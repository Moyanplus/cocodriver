import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import '../services/download_service.dart';

/// 下载状态
class DownloadState {
  final List<DownloadTask> tasks;
  final String sortBy;
  final bool sortDescending;

  DownloadState({
    required this.tasks,
    this.sortBy = 'time',
    this.sortDescending = true,
  });

  DownloadState copyWith({
    List<DownloadTask>? tasks,
    String? sortBy,
    bool? sortDescending,
  }) {
    return DownloadState(
      tasks: tasks ?? this.tasks,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }
}

/// 下载Provider
class DownloadNotifier extends StateNotifier<DownloadState> {
  final DownloadService _downloadService = DownloadService();

  DownloadNotifier() : super(DownloadState(tasks: [])) {
    // 初始化时加载任务
    refreshTasks();
  }

  /// 刷新任务列表
  Future<void> refreshTasks() async {
    final tasks = await _downloadService.loadTasks() ?? [];
    state = state.copyWith(tasks: tasks);
  }

  /// 根据标签页筛选任务
  List<DownloadTask> getFilteredTasks(int tabIndex) {
    final allTasks = state.tasks;

    switch (tabIndex) {
      case 0: // 全部
        return allTasks;
      case 1: // 下载中
        return allTasks
            .where(
              (task) =>
                  task.status == DownloadTaskStatus.running ||
                  task.status == DownloadTaskStatus.enqueued,
            )
            .toList();
      case 2: // 已完成
        return allTasks
            .where((task) => task.status == DownloadTaskStatus.complete)
            .toList();
      case 3: // 已暂停
        return allTasks
            .where((task) => task.status == DownloadTaskStatus.paused)
            .toList();
      default:
        return allTasks;
    }
  }

  /// 暂停任务
  Future<bool> pauseTask(String taskId) async {
    await FlutterDownloader.pause(taskId: taskId);
    await refreshTasks();
    return true;
  }

  /// 恢复任务
  Future<bool> resumeTask(String taskId) async {
    await FlutterDownloader.resume(taskId: taskId);
    await refreshTasks();
    return true;
  }

  /// 删除任务
  Future<bool> deleteTask(String taskId) async {
    await FlutterDownloader.remove(taskId: taskId);
    await refreshTasks();
    return true;
  }

  /// 获取任务时长
  String getTaskDuration(String taskId) {
    // 简化实现，返回固定值
    return '00:00';
  }

  /// 设置排序方式
  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  /// 切换排序方向
  void toggleSortDirection() {
    state = state.copyWith(sortDescending: !state.sortDescending);
  }
}

/// 下载Provider实例
final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadState>(
  (ref) {
    return DownloadNotifier();
  },
);
