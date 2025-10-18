import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/base/debug_service.dart';
import '../business/cloud_drive_business_service.dart';

/// 直链解析页面
class CloudDriveDirectLinkPage extends StatefulWidget {
  const CloudDriveDirectLinkPage({super.key});

  @override
  State<CloudDriveDirectLinkPage> createState() =>
      _CloudDriveDirectLinkPageState();
}

class _CloudDriveDirectLinkPageState extends State<CloudDriveDirectLinkPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Map<String, dynamic>? _result;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _parseDirectLink() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入分享链接'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      DebugService.log('🔗 开始解析直链: $url');

      final result = await CloudDriveBusinessService.parseAndDownloadFile(
        shareUrl: url,
        password:
            _passwordController.text.trim().isEmpty
                ? null
                : _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result.success && result.fileInfo != null) {
            _result = result.fileInfo;
            DebugService.log('✅ 解析成功: ${result.fileInfo}');
          } else {
            _error = result.message;
          }
        });
      }
    } catch (e) {
      DebugService.error('❌ 解析直链失败: $e', null);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _copyDirectLink() {
    if (_result != null && _result!['directLink'] != null) {
      Clipboard.setData(ClipboardData(text: _result!['directLink']));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('直链已复制到剪贴板'),
          backgroundColor: Colors.green,
        ),
      );
      DebugService.log('📋 直链已复制: ${_result!['directLink']}');
    }
  }

  void _copyAllInfo() {
    if (_result != null) {
      final info =
          '''
文件名: ${_result!['name']}
文件大小: ${_result!['size']}
直链: ${_result!['directLink']}
原始链接: ${_result!['originalUrl']}
      '''.trim();

      Clipboard.setData(ClipboardData(text: info));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('所有信息已复制到剪贴板'),
          backgroundColor: Colors.green,
        ),
      );
      DebugService.log('📋 所有信息已复制');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('直链解析'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 输入区域
          _buildInputSection(),
          const SizedBox(height: 24),

          // 解析按钮
          _buildParseButton(),
          const SizedBox(height: 24),

          // 结果显示
          if (_isLoading) _buildLoadingState(),
          if (_error != null) _buildErrorState(),
          if (_result != null) _buildResultSection(),
        ],
      ),
    ),
  );

  Widget _buildInputSection() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '输入信息',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 分享链接输入
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: '蓝奏云分享链接',
              hintText:
                  'https://www.lanzoue.com/xxx 或 https://www.lanzoux.com/xxx',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // 提取码输入
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: '提取码（可选）',
              hintText: '如果文件有密码保护，请输入提取码',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            maxLines: 1,
          ),
        ],
      ),
    ),
  );

  Widget _buildParseButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _isLoading ? null : _parseDirectLink,
      icon:
          _isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.search),
      label: Text(_isLoading ? '解析中...' : '开始解析'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );

  Widget _buildLoadingState() => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('正在解析直链...', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '请稍候，这可能需要几秒钟',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildErrorState() => Card(
    color: Theme.of(context).colorScheme.errorContainer,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                '解析失败',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    ),
  );

  Widget _buildResultSection() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                '解析成功',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _copyAllInfo,
                icon: const Icon(Icons.copy),
                tooltip: '复制所有信息',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 文件信息
          _buildInfoRow('文件名', _result!['name']),
          _buildInfoRow('文件大小', _result!['size']),
          const SizedBox(height: 16),

          // 直链
          Text(
            '直链地址',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _result!['directLink'],
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _copyDirectLink,
                  icon: const Icon(Icons.copy),
                  tooltip: '复制直链',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 原始链接
          Text(
            '原始链接',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: SelectableText(
              _result!['originalUrl'],
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}
