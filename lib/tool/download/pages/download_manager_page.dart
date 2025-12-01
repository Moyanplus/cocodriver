import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/logging/log_manager.dart';
import '../../../core/services/base/debug_service.dart';
import '../services/download_config_service.dart';
import '../services/download_service.dart';
import '../providers/download_provider.dart';

class DownloadManagerPage extends ConsumerStatefulWidget {
  const DownloadManagerPage({super.key});

  @override
  ConsumerState<DownloadManagerPage> createState() =>
      _DownloadManagerPageState();
}

class _DownloadManagerPageState extends ConsumerState<DownloadManagerPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  // 服务实例
  final DownloadService _downloadService = DownloadService();
  final DownloadConfigService _configService = DownloadConfigService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
        DebugService.log('切换到标签页: $_currentTabIndex');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addDownload() async {
    LogManager().debug('➕ 开始创建新下载任务');

    // 加载配置
    final config = await _configService.loadConfig();
    LogManager().debug('配置加载完成');

    final urlController = TextEditingController();
    final fileNameController = TextEditingController();
    bool showAdvancedOptions = false;
    Map<String, String> customHeaders = Map.from(config.customHeaders);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('新建下载任务'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 基本选项
                        TextField(
                          controller: urlController,
                          decoration: const InputDecoration(
                            labelText: '下载链接',
                            hintText: '请输入文件下载链接',
                            prefixIcon: Icon(Icons.link),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: fileNameController,
                          decoration: const InputDecoration(
                            labelText: '保存文件名',
                            hintText: '请输入保存的文件名（可选）',
                            prefixIcon: Icon(Icons.file_copy),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 高级选项切换
                        Row(
                          children: [
                            Icon(
                              Icons.settings,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '高级选项',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: showAdvancedOptions,
                              onChanged: (value) {
                                setState(() {
                                  showAdvancedOptions = value;
                                });
                              },
                            ),
                          ],
                        ),

                        // 高级选项内容
                        if (showAdvancedOptions) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.cloud_sync,
                                      size: 16,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '自定义请求头',
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '使用默认请求头',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'url': urlController.text,
                          'fileName': fileNameController.text,
                          'customHeaders': customHeaders,
                        });
                      },
                      child: const Text('开始下载'),
                    ),
                  ],
                ),
          ),
    );

    if (result != null && result['url']!.isNotEmpty) {
      LogManager().debug('用户确认下载，开始创建任务');

      try {
        // 获取有效的下载目录
        final downloadDir = await _downloadService.getValidDownloadDirectory(
          config.downloadDirectory,
        );

        // 判断是否为外部存储目录
        final isExternalStorage = downloadDir.startsWith(
          '/storage/emulated/0/',
        );

        // 显示实际下载位置
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('文件将保存到: $downloadDir'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.blue,
            ),
          );
        }

        // 合并自定义请求头
        final finalCustomHeaders = <String, String>{};
        if (config.customHeaders.isNotEmpty) {
          finalCustomHeaders.addAll(config.customHeaders);
        }
        if (result['customHeaders'] != null &&
            (result['customHeaders'] as Map<String, String>).isNotEmpty) {
          finalCustomHeaders.addAll(
            result['customHeaders'] as Map<String, String>,
          );
        }

        final taskId = await _downloadService.createDownloadTask(
          url: result['url']!,
          fileName: result['fileName']!.isNotEmpty ? result['fileName']! : null,
          downloadDir: downloadDir,
          showNotification: config.showNotification,
          openFileFromNotification: config.openFileFromNotification,
          isExternalStorage: isExternalStorage,
          customHeaders:
              finalCustomHeaders.isNotEmpty ? finalCustomHeaders : null,
        );

        if (taskId != null) {
          // 直接刷新任务列表
          await ref.read(downloadProvider.notifier).refreshTasks();
          LogManager().debug('任务创建后立即刷新列表');
        }
      } catch (e) {
        LogManager().error('创建下载任务失败: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('创建下载任务失败: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  PreferredSizeWidget? buildAppBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: const Text('下载管理'),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: colorScheme.primary,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: '全部'),
          Tab(text: '下载中'),
          Tab(text: '已完成'),
          Tab(text: '已暂停'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _addDownload(),
          tooltip: '新建下载',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(downloadProvider);

    return Scaffold(
      appBar: buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDownloadList(downloadState, 0),
          _buildDownloadList(downloadState, 1),
          _buildDownloadList(downloadState, 2),
          _buildDownloadList(downloadState, 3),
        ],
      ),
    );
  }

  /// 为每个标签页构建独立的任务列表
  Widget _buildDownloadList(DownloadState provider, int tabIndex) {
    final filteredTasks = ref
        .read(downloadProvider.notifier)
        .getFilteredTasks(tabIndex);

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无下载任务',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return _buildTaskCard(task, provider);
      },
    );
  }

  /// 构建任务卡片
  Widget _buildTaskCard(DownloadTask task, DownloadState provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildTaskIcon(task),
        title: Text(
          task.filename ?? '未知文件',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: task.progress / 100,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 4),
            Text('${task.progress}% - ${_getStatusText(task.status)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.status == DownloadTaskStatus.running)
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: () => _pauseTask(task, provider),
                tooltip: '暂停',
              ),
            if (task.status == DownloadTaskStatus.paused)
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () => _resumeTask(task, provider),
                tooltip: '继续',
              ),
            if (task.status == DownloadTaskStatus.complete)
              IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => _openFile(task),
                tooltip: '打开',
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteTask(task, provider),
              tooltip: '删除',
            ),
          ],
        ),
        onTap: () => _showTaskDetails(task, provider),
      ),
    );
  }

  /// 构建任务图标（支持缩略图）
  Widget _buildTaskIcon(DownloadTask task) {
    return FutureBuilder<String?>(
      future: _downloadService.getTaskThumbnailUrl(task.taskId),
      builder: (context, snapshot) {
        final thumbnailUrl = snapshot.data;

        // 如果有缩略图URL，显示网络图片
        if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
          return CircleAvatar(
            child: ClipOval(
              child: Image.network(
                thumbnailUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // 图片加载失败时显示文件类型图标
                  return Icon(_getFileIcon(task.filename ?? ''));
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  // 加载中显示文件类型图标
                  return Icon(_getFileIcon(task.filename ?? ''));
                },
              ),
            ),
          );
        }

        // 否则显示文件类型图标
        return CircleAvatar(child: Icon(_getFileIcon(task.filename ?? '')));
      },
    );
  }

  /// 获取文件图标
  IconData _getFileIcon(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// 暂停任务
  Future<void> _pauseTask(DownloadTask task, DownloadState provider) async {
    LogManager().debug('暂停任务: ${task.taskId}');
    await ref.read(downloadProvider.notifier).pauseTask(task.taskId);
  }

  /// 恢复任务
  Future<void> _resumeTask(DownloadTask task, DownloadState provider) async {
    LogManager().debug('恢复任务: ${task.taskId}');
    await ref.read(downloadProvider.notifier).resumeTask(task.taskId);
  }

  /// 删除任务
  Future<void> _deleteTask(DownloadTask task, DownloadState provider) async {
    LogManager().debug('删除任务: ${task.taskId}');
    await ref.read(downloadProvider.notifier).deleteTask(task.taskId);
  }

  /// 打开文件
  Future<void> _openFile(DownloadTask task) async {
    try {
      LogManager().debug('打开文件: ${task.taskId}');

      if (task.status != DownloadTaskStatus.complete) {
        throw Exception('文件尚未下载完成');
      }

      final filePath = '${task.savedDir}/${task.filename}';
      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception('文件已被删除或移动');
      }

      final uri = Uri.file(file.absolute.path);
      final result = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!result) {
        throw Exception('无法打开文件');
      }
    } catch (e) {
      LogManager().error('打开文件失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('打开文件失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 显示任务详情
  void _showTaskDetails(DownloadTask task, DownloadState provider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('任务详情'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailItem('文件名', task.filename ?? '未知文件'),
                  const SizedBox(height: 12),
                  _buildDetailItem('下载链接', task.url, isUrl: true),
                  const SizedBox(height: 12),
                  _buildDetailItem('保存路径', task.savedDir),
                  const SizedBox(height: 12),
                  _buildDetailItem('任务状态', _getStatusText(task.status)),
                  const SizedBox(height: 12),
                  _buildDetailItem('下载进度', '${task.progress}%'),
                  const SizedBox(height: 12),
                  _buildDetailItem('任务ID', task.taskId),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
    );
  }

  /// 构建详情项
  Widget _buildDetailItem(String label, String value, {bool isUrl = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            value,
            style: TextStyle(
              fontSize: 12,
              color:
                  isUrl
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  /// 获取状态文本
  String _getStatusText(DownloadTaskStatus status) {
    switch (status) {
      case DownloadTaskStatus.undefined:
        return '未定义';
      case DownloadTaskStatus.enqueued:
        return '排队中';
      case DownloadTaskStatus.running:
        return '下载中';
      case DownloadTaskStatus.complete:
        return '已完成';
      case DownloadTaskStatus.failed:
        return '下载失败';
      case DownloadTaskStatus.canceled:
        return '已取消';
      case DownloadTaskStatus.paused:
        return '已暂停';
    }
  }
}
