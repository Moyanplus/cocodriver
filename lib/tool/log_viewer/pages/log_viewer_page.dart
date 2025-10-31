import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/logging/log_manager.dart';
import '../../../core/logging/log_category.dart';

/// 日志查看器页面
class LogViewerPage extends StatefulWidget {
  const LogViewerPage({super.key});

  @override
  State<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage> {
  final LogManager _logManager = LogManager();
  final TextEditingController _searchController = TextEditingController();

  List<String> _logs = [];
  List<String> _filteredLogs = [];
  LogCategory? _selectedCategory;
  bool _isLoading = true;
  String _searchText = '';
  Map<String, int> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _loadStatistics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs =
          _selectedCategory == null
              ? await _logManager.getAllLogs()
              : await _logManager.getLogsByCategory(_selectedCategory!);

      setState(() {
        _logs = logs;
        _filterLogs();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载日志失败: $e')));
      }
    }
  }

  Future<void> _loadStatistics() async {
    final stats = await _logManager.getLogStatistics();
    setState(() => _statistics = stats);
  }

  void _filterLogs() {
    if (_searchText.isEmpty) {
      _filteredLogs = _logs;
    } else {
      _filteredLogs =
          _logs
              .where(
                (log) => log.toLowerCase().contains(_searchText.toLowerCase()),
              )
              .toList();
    }
  }

  Future<void> _exportLogs() async {
    try {
      final filePath = await _logManager.exportLogs();
      if (filePath != null && mounted) {
        // 分享文件
        await Share.shareXFiles([XFile(filePath)], subject: '应用日志导出');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('导出失败: $e')));
      }
    }
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('清空日志'),
            content: const Text('确定要清空所有日志吗？此操作不可恢复。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('确定'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _logManager.clearLogs();
      await _loadLogs();
      await _loadStatistics();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('日志已清空')));
      }
    }
  }

  void _copyLog(String log) {
    Clipboard.setData(ClipboardData(text: log));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
  }

  void _copyAllLogs() {
    final allText = _filteredLogs.join('\n');
    Clipboard.setData(ClipboardData(text: allText));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已复制 ${_filteredLogs.length} 条日志')));
  }

  Color _getLogLevelColor(String log) {
    if (log.contains('[error]') || log.contains('[ERROR]')) {
      return Colors.red.shade100;
    } else if (log.contains('[warning]') || log.contains('[WARNING]')) {
      return Colors.orange.shade100;
    } else if (log.contains('[debug]') || log.contains('[DEBUG]')) {
      return Colors.blue.shade100;
    }
    return Colors.transparent;
  }

  IconData _getLogLevelIcon(String log) {
    if (log.contains('[error]') || log.contains('[ERROR]')) {
      return Icons.error;
    } else if (log.contains('[warning]') || log.contains('[WARNING]')) {
      return Icons.warning;
    } else if (log.contains('[debug]') || log.contains('[DEBUG]')) {
      return Icons.bug_report;
    }
    return Icons.info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日志查看器'),
        actions: [
          // 统计按钮
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showStatistics,
            tooltip: '统计信息',
          ),
          // 复制所有
          IconButton(
            icon: const Icon(Icons.copy_all),
            onPressed: _filteredLogs.isEmpty ? null : _copyAllLogs,
            tooltip: '复制所有日志',
          ),
          // 导出
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportLogs,
            tooltip: '导出日志',
          ),
          // 清空
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearLogs,
            tooltip: '清空日志',
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索和过滤栏
          _buildFilterBar(),
          // 日志列表
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildLogList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          // 搜索框
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索日志...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchText.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchText = '';
                            _filterLogs();
                          });
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchText = value;
                _filterLogs();
              });
            },
          ),
          const SizedBox(height: 8),
          // 分类过滤
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('全部', null),
                ...LogCategory.values.map(
                  (category) =>
                      _buildCategoryChip(category.displayName, category),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, LogCategory? category) {
    final isSelected = _selectedCategory == category;
    final count =
        category == null
            ? _logs.length
            : _statistics[category.displayName] ?? 0;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
          _loadLogs();
        },
      ),
    );
  }

  Widget _buildLogList() {
    if (_filteredLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchText.isEmpty ? '暂无日志' : '未找到匹配的日志',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredLogs.length,
      itemBuilder: (context, index) {
        final log = _filteredLogs[index];
        return _buildLogItem(log, index);
      },
    );
  }

  Widget _buildLogItem(String log, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: _getLogLevelColor(log),
      child: ListTile(
        leading: Icon(_getLogLevelIcon(log), size: 20),
        title: Text(
          log,
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
        ),
        dense: true,
        onTap: () => _showLogDetail(log),
        onLongPress: () => _copyLog(log),
        trailing: IconButton(
          icon: const Icon(Icons.copy, size: 18),
          onPressed: () => _copyLog(log),
        ),
      ),
    );
  }

  void _showLogDetail(String log) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('日志详情'),
            content: SingleChildScrollView(
              child: SelectableText(
                log,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => _copyLog(log),
                child: const Text('复制'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
    );
  }

  void _showStatistics() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('日志统计'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('总日志数: ${_logs.length}'),
                  const Divider(),
                  ..._statistics.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text(
                            '${entry.value}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
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
}
