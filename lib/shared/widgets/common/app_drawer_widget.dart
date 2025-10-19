import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/theme_models.dart';
import '../../../core/navigation/navigation_providers.dart';
import '../../../core/providers/cloud_drive_type_provider.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/adaptive_utils.dart';
import '../../../tool/cloud_drive/data/models/cloud_drive_entities.dart';

/// 应用侧边栏
class AppDrawerWidget extends ConsumerStatefulWidget {
  const AppDrawerWidget({super.key});

  @override
  ConsumerState<AppDrawerWidget> createState() => _AppDrawerWidgetState();
}

class _AppDrawerWidgetState extends ConsumerState<AppDrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // 顶部用户信息区域
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20.h,
              bottom: 20.h,
              left: 20.w,
              right: 20.w,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                // 头像
                _buildAvatar(context),
                SizedBox(height: 16.h),
                // 用户信息
                _buildUserInfo(context),
              ],
            ),
          ),
          // 云盘类型选择器
          _buildCloudDriveTypeSelector(context, ref),

          // 测试页面区域（仅在debug模式显示）
          if (kDebugMode) _buildTestPagesSection(context, ref),

          // 菜单项
          Expanded(child: _buildMenuItems(context, ref)),
          // 底部区域
          _buildFooter(context, ref),
        ],
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 3.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: ResponsiveUtils.getIconSize(50),
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Text(
          'F',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(30),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  /// 构建用户信息
  Widget _buildUserInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          'Flutter开发者',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: ResponsiveUtils.getResponsiveFontSize(16),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'UI模板项目',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: ResponsiveUtils.getResponsiveFontSize(12),
          ),
        ),
      ],
    );
  }

  /// 构建云盘类型选择器
  Widget _buildCloudDriveTypeSelector(BuildContext context, WidgetRef ref) {
    final cloudDriveTypeState = ref.watch(cloudDriveTypeProvider);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和开关
          Row(
            children: [
              Icon(
                PhosphorIcons.cloud(),
                size: ResponsiveUtils.getIconSize(20),
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                '云盘类型',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Switch(
                value: cloudDriveTypeState.isFilterEnabled,
                onChanged: (value) {
                  ref.read(cloudDriveTypeProvider.notifier).toggleFilter();
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),

          // 云盘类型选择器
          if (cloudDriveTypeState.isFilterEnabled) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children:
                  cloudDriveTypeState.availableTypes.map((type) {
                    final isSelected = cloudDriveTypeState.selectedType == type;
                    return GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          ref
                              .read(cloudDriveTypeProvider.notifier)
                              .clearSelection();
                        } else {
                          ref
                              .read(cloudDriveTypeProvider.notifier)
                              .selectType(type);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? type.color.withValues(alpha: 0.2)
                                  : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color:
                                isSelected
                                    ? type.color
                                    : Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              type.iconData,
                              size: ResponsiveUtils.getIconSize(16),
                              color:
                                  isSelected
                                      ? type.color
                                      : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              type.displayName,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    isSelected
                                        ? type.color
                                        : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建菜单项
  Widget _buildMenuItems(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // 主题管理
        _buildMenuItem(
          context,
          icon: PhosphorIcons.palette(),
          title: '主题管理',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/settings/theme');
          },
        ),

        // 设置
        _buildMenuItem(
          context,
          icon: PhosphorIcons.gear(),
          title: '设置',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/settings');
          },
        ),

        // 关于
        _buildMenuItem(
          context,
          icon: PhosphorIcons.info(),
          title: '关于',
          onTap: () {
            Navigator.pop(context);
            showAboutDialog(
              context: context,
              applicationName: 'Flutter UI模板',
              applicationVersion: '1.0.0',
              applicationIcon: Icon(PhosphorIcons.squaresFour(), size: 48),
              children: const [
                Text('这是一个基于可可世界设计的Flutter UI模板项目。'),
                SizedBox(height: 16),
                Text('© 2024 Flutter UI模板'),
              ],
            );
          },
        ),

        // 帮助
        _buildMenuItem(
          context,
          icon: PhosphorIcons.question(),
          title: '帮助',
          onTap: () {
            Navigator.pop(context);
            _showHelpDialog(context);
          },
        ),

        // 反馈
        _buildMenuItem(
          context,
          icon: PhosphorIcons.chatCircle(),
          title: '反馈',
          onTap: () {
            Navigator.pop(context);
            _showFeedbackDialog(context);
          },
        ),
      ],
    );
  }

  /// 构建菜单项
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Widget? trailing,
  }) => AdaptiveUtils.adaptiveListTile(
    leading: Icon(
      icon,
      color:
          isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
      size: ResponsiveUtils.getIconSize(24),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
        fontSize: ResponsiveUtils.getResponsiveFontSize(14),
      ),
    ),
    trailing: trailing,
    onTap: onTap,
  );

  /// 构建底部
  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(all: 16),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.info(),
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            size: ResponsiveUtils.getIconSize(16),
          ),
          SizedBox(width: 8.w),
          Text(
            '版本 1.0.0',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: ResponsiveUtils.getResponsiveFontSize(12),
            ),
          ),
          const Spacer(),
          Consumer(
            builder: (context, ref, child) {
              final currentTheme = ref.watch(currentThemeProvider);
              return IconButton(
                icon: Icon(
                  currentTheme == ThemeType.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                  size: ResponsiveUtils.getIconSize(20),
                ),
                onPressed: () async {
                  // 切换主题：浅色 <-> 深色
                  final ThemeType newTheme =
                      currentTheme == ThemeType.dark
                          ? ThemeType.light
                          : ThemeType.dark;

                  await ref.read(themeProvider.notifier).setTheme(newTheme);

                  // 显示切换提示
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '已切换到${newTheme == ThemeType.light ? '浅色' : '深色'}主题',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                tooltip: '切换主题模式',
              );
            },
          ),
        ],
      ),
    );
  }

  /// 显示帮助对话框
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('帮助'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('这是一个Flutter UI模板项目，包含以下功能：'),
                SizedBox(height: 8),
                Text('• 多种主题选择'),
                Text('• 响应式设计'),
                Text('• 流畅的导航'),
                Text('• 丰富的组件库'),
                SizedBox(height: 8),
                Text('您可以根据需要自定义和扩展功能。'),
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

  /// 显示反馈对话框
  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('反馈'),
            content: const Text(
              '感谢您的使用！如有问题或建议，请通过以下方式联系我们：\n\n• 提交Issue到项目仓库\n• 发送邮件反馈\n• 参与社区讨论',
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

  /// 构建测试页面区域
  Widget _buildTestPagesSection(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                PhosphorIcons.bug(),
                size: ResponsiveUtils.getIconSize(20),
                color: Colors.orange,
              ),
              SizedBox(width: 8.w),
              Text(
                '测试页面',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 测试页面按钮
          _buildTestChip(
            context,
            icon: PhosphorIcons.globe(),
            label: 'WebView测试',
            color: Colors.blue,
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/test/webview');
            },
          ),
        ],
      ),
    );
  }

  /// 构建测试chip
  Widget _buildTestChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: ResponsiveUtils.getIconSize(16), color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
