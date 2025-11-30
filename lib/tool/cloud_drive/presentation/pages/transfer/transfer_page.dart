import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/cloud_drive_entities.dart';
import '../../providers/cloud_drive_provider.dart';
import '../../../services/providers/pan123/repository/pan123_repository.dart';
import '../../../services/providers/pan123/models/responses/pan123_share_list_response.dart';

const _sectionPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
const _itemSpacing = SizedBox(height: 6);

final _pan123RecycleProvider =
    FutureProvider.autoDispose<List<CloudDriveFile>>((ref) async {
  final state = ref.watch(cloudDriveProvider);
  final account = state.currentAccount;

  if (account == null || account.type != CloudDriveType.pan123) {
    return const <CloudDriveFile>[];
  }

  final repo = Pan123Repository();
  return repo.listRecycle(account: account);
});

final _pan123ShareProvider =
    FutureProvider.autoDispose<List<Pan123ShareItem>>((ref) async {
  final state = ref.watch(cloudDriveProvider);
  final account = state.currentAccount;

  if (account == null || account.type != CloudDriveType.pan123) {
    return const <Pan123ShareItem>[];
  }

  final repo = Pan123Repository();
  final res = await repo.listShares(
    account: account,
    isPaid: false, // 仅使用免费分享接口
    limit: 20,
    next: '0',
  );
  return res.items;
});

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
                _TransferPlaceholder(title: '下载任务'),
                _Pan123ShareTab(),
                _Pan123RecycleTab(),
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

/// 123云盘回收站 tab
class _Pan123RecycleTab extends ConsumerWidget {
  const _Pan123RecycleTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudDriveProvider);
    final account = state.currentAccount;

    if (account == null) {
      return const _InfoState(message: '请选择账号后查看回收站');
    }
    if (account.type != CloudDriveType.pan123) {
      return const _InfoState(message: '当前仅支持 123 云盘回收站');
    }

    final recycleAsync = ref.watch(_pan123RecycleProvider);

    return recycleAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => _ErrorState(
        message: '加载失败：$e',
        onRetry: () => ref.invalidate(_pan123RecycleProvider),
      ),
      data: (files) {
        return RefreshIndicator(
          onRefresh: () => ref.refresh(_pan123RecycleProvider.future),
          child: files.isEmpty
              ? const _InfoState(message: '回收站暂无文件')
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: _sectionPadding,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    final widget = _ListRow(
                      leading: Icon(
                        file.isFolder
                            ? Icons.folder_outlined
                            : Icons.insert_drive_file_outlined,
                        color: file.isFolder
                            ? Colors.orange.shade600
                            : Colors.blueGrey,
                      ),
                      title: file.name,
                      subtitle: _buildSubtitle(file),
                      trailing: const Icon(
                        Icons.restore_from_trash,
                        color: Colors.blueGrey,
                      ),
                    );
                    if (index == files.length - 1) return widget;
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

  String _buildSubtitle(CloudDriveFile file) {
    final parts = <String>[];
    if (file.size != null) parts.add(_formatSize(file.size!));
    if (file.updatedAt != null) {
      parts.add(DateFormat('yyyy-MM-dd HH:mm').format(file.updatedAt!));
    }
    return parts.isEmpty ? '无更多信息' : parts.join(' · ');
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${units[unitIndex]}';
  }
}

/// 123云盘分享列表 tab（仅免费分享）
class _Pan123ShareTab extends ConsumerWidget {
  const _Pan123ShareTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudDriveProvider);
    final account = state.currentAccount;

    if (account == null) {
      return const _InfoState(message: '请选择账号后查看分享列表');
    }
    if (account.type != CloudDriveType.pan123) {
      return const _InfoState(message: '当前仅支持 123 云盘分享列表');
    }

    final shareAsync = ref.watch(_pan123ShareProvider);

    return shareAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => _ErrorState(
        message: '加载失败：$e',
        onRetry: () => ref.invalidate(_pan123ShareProvider),
      ),
      data: (items) {
        return RefreshIndicator(
          onRefresh: () => ref.refresh(_pan123ShareProvider.future),
          child: items.isEmpty
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
                      title: item.shareName,
                      subtitle: _buildShareSubtitle(item),
                      onTap: () {}, // 仅用于保留水波纹反馈
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatDate(item.updateAt ?? item.createAt),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.blueGrey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '下载 ${item.downloadCount ?? 0}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
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
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: expired ? Colors.grey : Colors.green.shade700,
                                ),
                          ),
                          Text(
                            'Key ${item.shareKey}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.blueGrey),
                          ),
                          if (item.sharePwd.isNotEmpty)
                            Text(
                              '密码 ${item.sharePwd}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
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

  String _buildShareSubtitle(Pan123ShareItem item) {
    final parts = <String>[];
    final exp = _formatDate(item.expiration);
    if (exp.isNotEmpty) {
      parts.add('到期: $exp');
    }
    parts.add('状态: ${item.expired ? '已过期' : '有效'}');
    parts.add('下载 ${item.downloadCount ?? 0} / 保存 ${item.saveCount ?? 0}');
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
            style:
                theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style:
                      theme.textTheme.bodySmall?.copyWith(color: Colors.blueGrey),
                ),
                if (extra != null) ...[
                  const SizedBox(height: 4),
                  extra!,
                ],
              ],
            ),
          ),
          trailing: trailing,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          visualDensity: const VisualDensity(vertical: -2, horizontal: -1),
          minLeadingWidth: 24,
        ),
      ),
    );
  }
}

String _formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';
  final normalized = dateStr.replaceFirst('T', ' ').replaceFirst('Z', '');
  final parsed = DateTime.tryParse(normalized)?.toLocal();
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
