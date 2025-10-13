import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/services/theme_service.dart';

/// 用户页面
class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          // 模拟刷新
          await Future.delayed(const Duration(seconds: 1));
        },
        child: _buildPageContent(),
      ),
    );
  }

  Widget _buildPageContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 用户头像和基本信息
          _buildUserProfile(),
          const SizedBox(height: 24),

          // 功能列表
          _buildFunctionList(),
          const SizedBox(height: 24),

          // 主题设置
          _buildThemeSettings(),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Flutter开发者',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '这是一个UI模板项目',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionList() {
    final functions = [
      {'title': '设置', 'icon': Icons.settings, 'color': Colors.blue},
      {'title': '关于', 'icon': Icons.info, 'color': Colors.green},
      {'title': '帮助', 'icon': Icons.help, 'color': Colors.orange},
      {'title': '反馈', 'icon': Icons.feedback, 'color': Colors.purple},
    ];

    return Card(
      child: Column(
        children:
            functions.map((function) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: (function['color'] as Color).withValues(
                    alpha: 0.1,
                  ),
                  child: Icon(
                    function['icon'] as IconData,
                    color: function['color'] as Color,
                  ),
                ),
                title: Text(function['title'] as String),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('点击了${function['title']}')),
                  );
                },
              );
            }).toList(),
      ),
    );
  }

  Widget _buildThemeSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '主题设置',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final currentTheme = ref.watch(currentThemeProvider);
                final themeNotifier = ref.read(themeProvider.notifier);

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      ThemeType.values.take(6).map((themeType) {
                        final themeInfo = ThemeService().getThemeInfo(
                          themeType,
                        );
                        final isSelected = currentTheme == themeType;

                        return GestureDetector(
                          onTap: () {
                            themeNotifier.setTheme(themeType);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? themeInfo.color.withValues(alpha: 0.2)
                                      : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  isSelected
                                      ? Border.all(
                                        color: themeInfo.color,
                                        width: 2,
                                      )
                                      : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  themeInfo.icon,
                                  size: 16,
                                  color: themeInfo.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  themeInfo.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isSelected
                                            ? themeInfo.color
                                            : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
