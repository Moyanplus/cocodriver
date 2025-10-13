import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// 设置页面
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _buildPageContent(),
    );
  }

  Widget _buildPageContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 外观设置
          _buildSection(
            title: '外观设置',
            icon: PhosphorIcons.palette(),
            children: [
              _buildSettingsTile(
                icon: PhosphorIcons.palette(),
                title: '主题管理',
                subtitle: '选择您喜欢的主题',
                onTap: () {
                  Navigator.of(context).pushNamed('/settings/theme');
                },
              ),
              _buildSettingsTile(
                icon: PhosphorIcons.textAa(),
                title: '字体大小',
                subtitle: '调整应用字体大小',
                onTap: () {
                  _showFontSizeDialog();
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 功能设置
          _buildSection(
            title: '功能设置',
            icon: PhosphorIcons.gear(),
            children: [
              _buildSettingsTile(
                icon: PhosphorIcons.bell(),
                title: '通知设置',
                subtitle: '管理应用通知',
                onTap: () {
                  _showNotificationSettings();
                },
              ),
              _buildSettingsTile(
                icon: PhosphorIcons.lock(),
                title: '隐私设置',
                subtitle: '管理隐私和安全',
                onTap: () {
                  _showPrivacySettings();
                },
              ),
              _buildSettingsTile(
                icon: PhosphorIcons.download(),
                title: '下载设置',
                subtitle: '配置下载选项',
                onTap: () {
                  _showDownloadSettings();
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 关于设置
          _buildSection(
            title: '关于',
            icon: PhosphorIcons.info(),
            children: [
              _buildSettingsTile(
                icon: PhosphorIcons.info(),
                title: '关于应用',
                subtitle: '查看应用信息',
                onTap: () {
                  _showAboutDialog();
                },
              ),
              _buildSettingsTile(
                icon: PhosphorIcons.question(),
                title: '帮助与支持',
                subtitle: '获取帮助和支持',
                onTap: () {
                  _showHelpDialog();
                },
              ),
              _buildSettingsTile(
                icon: PhosphorIcons.chatCircle(),
                title: '意见反馈',
                subtitle: '提交反馈和建议',
                onTap: () {
                  _showFeedbackDialog();
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 高级设置
          _buildSection(
            title: '高级',
            icon: PhosphorIcons.wrench(),
            children: [
              _buildSettingsTile(
                icon: PhosphorIcons.trash(),
                title: '清除缓存',
                subtitle: '清理应用缓存数据',
                onTap: () {
                  _showClearCacheDialog();
                },
              ),
              _buildSettingsTile(
                icon: PhosphorIcons.arrowClockwise(),
                title: '重置设置',
                subtitle: '恢复默认设置',
                onTap: () {
                  _showResetSettingsDialog();
                },
              ),
            ],
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('字体大小'),
        content: const Text('字体大小设置功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知设置'),
        content: const Text('通知设置功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私设置'),
        content: const Text('隐私设置功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showDownloadSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('下载设置'),
        content: const Text('下载设置功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Flutter UI模板',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(PhosphorIcons.squaresFour(), size: 48),
      children: const [
        Text('这是一个基于可可世界设计的Flutter UI模板项目。'),
        SizedBox(height: 16),
        Text('特性：'),
        Text('• 多种精美主题'),
        Text('• 响应式设计'),
        Text('• 流畅的导航'),
        Text('• 丰富的组件库'),
        SizedBox(height: 16),
        Text('© 2024 Flutter UI模板'),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('帮助与支持'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('常见问题：'),
            SizedBox(height: 8),
            Text('Q: 如何更换主题？'),
            Text('A: 进入设置 > 主题管理，选择您喜欢的主题。'),
            SizedBox(height: 8),
            Text('Q: 如何自定义界面？'),
            Text('A: 您可以修改源代码中的主题配置和组件样式。'),
            SizedBox(height: 8),
            Text('如需更多帮助，请查看项目文档或提交Issue。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('意见反馈'),
        content: const Text(
          '感谢您的使用！\n\n如有问题或建议，请通过以下方式联系我们：\n\n• 提交Issue到项目仓库\n• 发送邮件反馈\n• 参与社区讨论\n\n您的反馈对我们很重要！',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除应用缓存吗？这将删除所有临时数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('缓存已清除')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置设置'),
        content: const Text('确定要重置所有设置吗？这将恢复应用的默认配置。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('设置已重置')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
