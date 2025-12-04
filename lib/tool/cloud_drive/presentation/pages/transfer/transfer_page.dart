import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../download/providers/download_provider.dart';
import '../../../../download/services/download_service.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../providers/cloud_drive_provider.dart';
import '../../../services/providers/pan123/repository/pan123_repository.dart';
import '../../../services/providers/baidu/baidu_operation_strategy.dart';
import '../../../services/providers/ali/strategy/ali_operation_strategy.dart';
import '../../../base/cloud_drive_service_gateway.dart';
import '../../widgets/browser/cloud_drive_file_item.dart';

const _sectionPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
const _itemSpacing = SizedBox(height: 6);

final _gateway = defaultCloudDriveGateway;

class _ShareItem {
  final String title;
  final String? link;
  final String? password;
  final DateTime? createdAt;
  final bool expired;
  final String source;
  final String? extra;
  final String? shareKey;
  final int? downloadCount;
  final int? saveCount;

  _ShareItem({
    required this.title,
    this.link,
    this.password,
    this.createdAt,
    this.expired = false,
    required this.source,
    this.extra,
    this.shareKey,
    this.downloadCount,
    this.saveCount,
  });
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) return null;
  final normalized = value.replaceFirst('T', ' ').replaceFirst('Z', '');
  return DateTime.tryParse(normalized)?.toLocal();
}

final _recycleProvider = FutureProvider.autoDispose<List<CloudDriveFile>>((
  ref,
) async {
  final state = ref.watch(cloudDriveProvider);
  final account = state.currentAccount;
  if (account == null) return const <CloudDriveFile>[];

  return _loadRecycle(account);
});

final _shareProvider = FutureProvider.autoDispose<List<_ShareItem>>((
  ref,
) async {
  final state = ref.watch(cloudDriveProvider);
  final account = state.currentAccount;
  if (account == null) return const <_ShareItem>[];

  return _loadShares(account);
});

Future<List<_ShareItem>> _loadShares(CloudDriveAccount account) async {
  final ops = _gateway.getSupportedOperations(account);
  if (!(ops['share_records'] ?? false)) return const [];

  final strategy = _gateway.strategyFor(account);

  if (strategy is BaiduCloudDriveOperationStrategy) {
    final records = await strategy.listShareRecords(account: account);
    return records
        .map(
          (r) => _ShareItem(
            title:
                r.name ?? r.typicalPath ?? (r.shortUrl ?? r.shortLink ?? '分享'),
            link: r.shortLink ?? r.shortUrl,
            password: r.password,
            createdAt: r.createdAt,
            expired: r.status != 0,
            source: '百度网盘',
            extra: r.typicalPath,
            shareKey: r.shareId.toString(),
          ),
        )
        .toList();
  }

  if (strategy is AliCloudDriveOperationStrategy) {
    final records = await strategy.listShareRecords(account: account);
    return records
        .map(
          (r) => _ShareItem(
            title: r.shareName ?? r.firstFile?.name ?? r.shareUrl ?? '分享',
            link: r.shareUrl,
            password: r.sharePwd,
            createdAt: r.createdAt ?? r.updatedAt,
            expired: r.expired,
            source: '阿里云盘',
            extra: r.firstFile?.name ?? r.description,
            shareKey: r.shareId,
            downloadCount: r.downloadCount,
            saveCount: r.saveCount,
          ),
        )
        .toList();
  }

  if (account.type == CloudDriveType.pan123) {
    final repo = Pan123Repository();
    final res = await repo.listShares(
      account: account,
      isPaid: false,
      limit: 20,
      next: '0',
    );
    return res.items
        .map(
          (i) => _ShareItem(
            title: i.shareName,
            link: i.shareUrl,
            password: i.sharePwd,
            createdAt: _parseDate(i.createAt) ?? _parseDate(i.updateAt),
            expired: i.expired,
            source: '123云盘',
            extra: '下载 ${i.downloadCount ?? 0} 保存 ${i.saveCount ?? 0}',
            shareKey: i.shareKey,
            downloadCount: i.downloadCount,
            saveCount: i.saveCount,
          ),
        )
        .toList();
  }

  return const [];
}

Future<List<CloudDriveFile>> _loadRecycle(CloudDriveAccount account) async {
  final strategy = _gateway.strategyFor(account);
  if (strategy != null &&
      (strategy.getSupportedOperations()['recycle'] ?? false)) {
    if (strategy is BaiduCloudDriveOperationStrategy) {
      return strategy.listRecycle(account: account);
    }
    if (strategy is AliCloudDriveOperationStrategy) {
      return strategy.listRecycle(account: account);
    }
  }
  if (account.type == CloudDriveType.pan123) {
    return Pan123Repository().listRecycle(account: account);
  }
  return const <CloudDriveFile>[];
}

/// 传输页：包含上传/下载/分享/回收站四个标签
class TransferPage extends ConsumerWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.black87,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: '上传'),
              Tab(text: '下载'),
              Tab(text: '分享'),
              Tab(text: '垃圾站'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: const [
                _TransferPlaceholder(title: '上传任务'),
                _DownloadTab(),
                _ShareTab(),
                _RecycleTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferPlaceholder extends StatelessWidget {
  const _TransferPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title（待接入数据）',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

/// 下载任务列表（复用现有 DownloadService + downloadProvider）
class _DownloadTab extends ConsumerStatefulWidget {
  const _DownloadTab();

  @override
  ConsumerState<_DownloadTab> createState() => _DownloadTabState();
}

class _DownloadTabState extends ConsumerState<_DownloadTab> {
  final _downloadService = DownloadService();

  @override
  void initState() {
    super.initState();
    _initListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 页面每次重新可见时主动刷新一次任务，避免回调丢失造成列表滞后。
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(downloadProvider.notifier).refreshTasks(),
    );
  }

  Future<void> _initListener() async {
    await _downloadService.initializeDownloadListener();
    _downloadService.registerCallback(_onDownloadChanged);
    // 初始化时刷新一次
    await ref.read(downloadProvider.notifier).refreshTasks();
  }

  @override
  void dispose() {
    _downloadService.unregisterCallback(_onDownloadChanged);
    super.dispose();
  }

  void _onDownloadChanged(
    String taskId,
    DownloadTaskStatus status,
    int progress,
  ) {
    // 监听到变化后刷新任务列表
    ref.read(downloadProvider.notifier).refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(downloadProvider);
    final tasks = downloadState.tasks;

    if (tasks.isEmpty) {
      return const _InfoState(message: '暂无下载任务');
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(downloadProvider.notifier).refreshTasks(),
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _DownloadTile(
            task: task,
            onPause:
                () =>
                    ref.read(downloadProvider.notifier).pauseTask(task.taskId),
            onResume:
                () =>
                    ref.read(downloadProvider.notifier).resumeTask(task.taskId),
            onDelete:
                () =>
                    ref.read(downloadProvider.notifier).deleteTask(task.taskId),
          );
        },
      ),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  const _DownloadTile({
    required this.task,
    required this.onPause,
    required this.onResume,
    required this.onDelete,
  });

  final DownloadTask task;
  final Future<bool> Function() onPause;
  final Future<bool> Function() onResume;
  final Future<bool> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final status = task.status;
    final isRunning =
        status == DownloadTaskStatus.running ||
        status == DownloadTaskStatus.enqueued;
    final isPaused = status == DownloadTaskStatus.paused;
    final isComplete = status == DownloadTaskStatus.complete;
    final isFailed = status == DownloadTaskStatus.failed;
    final statusLabel = () {
      switch (status) {
        case DownloadTaskStatus.running:
          return '下载中';
        case DownloadTaskStatus.enqueued:
          return '排队中';
        case DownloadTaskStatus.complete:
          return '已完成';
        case DownloadTaskStatus.failed:
          return '失败';
        case DownloadTaskStatus.paused:
          return '已暂停';
        case DownloadTaskStatus.canceled:
          return '已取消';
        default:
          return status.toString();
      }
    }();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(task.filename ?? '未命名文件'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: task.progress <= 0 ? null : task.progress / 100,
            ),
            const SizedBox(height: 4),
            Text(
              '$statusLabel • ${task.progress}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (task.savedDir != null && task.savedDir!.isNotEmpty)
              Text(
                task.savedDir!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            if (isFailed)
              Text(
                '下载失败，可尝试重新开始',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.redAccent),
              ),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            if (isRunning)
              IconButton(
                icon: const Icon(Icons.pause),
                tooltip: '暂停',
                onPressed: onPause,
              ),
            if (isPaused || isFailed)
              IconButton(
                icon: const Icon(Icons.play_arrow),
                tooltip: '继续',
                onPressed: onResume,
              ),
            if (isComplete) const Icon(Icons.check_circle, color: Colors.green),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '删除任务',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoState extends StatelessWidget {
  const _InfoState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// 回收站 tab（按当前账号能力调用）
class _RecycleTab extends ConsumerWidget {
  const _RecycleTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudDriveProvider);
    final account = state.currentAccount;

    if (account == null) {
      return const _InfoState(message: '请选择账号后查看回收站');
    }

    final ops = defaultCloudDriveGateway.getSupportedOperations(account);
    if (!(ops['recycle'] ?? false)) {
      return const _InfoState(message: '当前云盘未支持回收站');
    }

    final recycleAsync = ref.watch(_recycleProvider);

    return recycleAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, __) => _ErrorState(
            message: '加载失败：$e',
            onRetry: () => ref.invalidate(_recycleProvider),
          ),
      data: (files) {
        if (files.isEmpty) {
          return const _InfoState(message: '回收站暂无文件');
        }
        final theme = Theme.of(context);
        return RefreshIndicator(
          onRefresh: () => ref.refresh(_recycleProvider.future),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: files.length,
            separatorBuilder: (_, __) => const SizedBox(height: 2),
            itemBuilder: (context, index) {
              final file = files[index];
              return CloudDriveFileItem(
                file: file,
                account: account,
                onTap: null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restore),
                      color: theme.colorScheme.primary,
                      tooltip: '还原（待实现）',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('还原功能待接入 API')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever),
                      color: theme.colorScheme.error,
                      tooltip: '彻底删除（待实现）',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('彻底删除功能待接入 API')),
                        );
                      },
                    ),
                  ],
                ),
                isFolder: file.isFolder,
                isSelected: false,
                isBatchMode: false,
                onLongPress: null,
              );
            },
          ),
        );
      },
    );
  }
}

/// 分享列表 tab（按当前账号能力调用）
class _ShareTab extends ConsumerWidget {
  const _ShareTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudDriveProvider);
    final account = state.currentAccount;

    if (account == null) {
      return const _InfoState(message: '请选择账号后查看分享列表');
    }

    final ops = defaultCloudDriveGateway.getSupportedOperations(account);
    if (!(ops['share_records'] ?? false)) {
      return const _InfoState(message: '当前云盘未支持分享列表');
    }

    final shareAsync = ref.watch(_shareProvider);

    return shareAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, __) => _ErrorState(
            message: '加载失败：$e',
            onRetry: () => ref.invalidate(_shareProvider),
          ),
      data: (items) {
        return RefreshIndicator(
          onRefresh: () => ref.refresh(_shareProvider.future),
          child:
              items.isEmpty
                  ? const _InfoState(message: '暂无分享记录')
                  : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: _sectionPadding,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final expired = item.expired;
                      final widget = _ListRow(
                        leading: Icon(
                          Icons.link_outlined,
                          color: expired ? Colors.grey : Colors.blueGrey,
                        ),
                        title: item.title,
                        subtitle: _buildShareSubtitle(item),
                        onTap: () {}, // 仅用于保留水波纹反馈
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatDate(item.createdAt),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.blueGrey),
                            ),
                            const SizedBox(height: 4),
                            if (item.downloadCount != null)
                              Text(
                                '下载 ${item.downloadCount}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.blueGrey),
                              ),
                          ],
                        ),
                        extra: Wrap(
                          spacing: 8,
                          runSpacing: 2,
                          children: [
                            Text(
                              expired ? '已过期' : '有效',
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                color:
                                    expired
                                        ? Colors.grey
                                        : Colors.green.shade700,
                              ),
                            ),
                            if (item.shareKey != null &&
                                item.shareKey!.isNotEmpty)
                              Text(
                                'Key ${item.shareKey}',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.blueGrey),
                              ),
                            if ((item.password ?? '').isNotEmpty)
                              Text(
                                '密码 ${item.password}',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.orange.shade700),
                              ),
                          ],
                        ),
                      );
                      if (index == items.length - 1) return widget;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [_itemSpacing],
                      ).insertBefore(widget);
                    },
                  ),
        );
      },
    );
  }

  String _buildShareSubtitle(_ShareItem item) {
    final parts = <String>[];
    parts.add('状态: ${item.expired ? '已过期' : '有效'}');
    if (item.downloadCount != null || item.saveCount != null) {
      parts.add(
        '下载 ${item.downloadCount ?? 0}'
        '${item.saveCount != null ? ' / 保存 ${item.saveCount}' : ''}',
      );
    }
    if (item.extra != null && item.extra!.isNotEmpty) {
      parts.add(item.extra!);
    }
    return parts.join(' · ');
  }
}

/// 通用列表行，保持与文件列表一致的间距与排版
class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.extra,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? extra;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(10);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap ?? () {},
        child: ListTile(
          leading: leading,
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.blueGrey,
                  ),
                ),
                if (extra != null) ...[const SizedBox(height: 4), extra!],
              ],
            ),
          ),
          trailing: trailing,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          visualDensity: const VisualDensity(vertical: -2, horizontal: -1),
          minLeadingWidth: 24,
        ),
      ),
    );
  }
}

String _formatDate(dynamic value) {
  DateTime? parsed;
  if (value is DateTime) {
    parsed = value;
  } else if (value is String) {
    final normalized = value.replaceFirst('T', ' ').replaceFirst('Z', '');
    parsed = DateTime.tryParse(normalized)?.toLocal();
  }
  if (parsed == null) return '';
  return DateFormat('yy/MM/dd HH:mm').format(parsed);
}

extension on Widget {
  Widget insertBefore(Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [child, this],
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
