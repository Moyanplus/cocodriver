import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/services/theme_service.dart';

/// 主题设置页面
class ThemeSettingsPage extends ConsumerStatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  ConsumerState<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends ConsumerState<ThemeSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题管理'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final currentTheme = ref.watch(currentThemeProvider);
              return IconButton(
                icon: Icon(
                  currentTheme == ThemeType.dark
                      ? PhosphorIcons.sun()
                      : PhosphorIcons.moon(),
                ),
                onPressed: () {
                  // 直接切换黑夜/白天模式
                  ThemeType newTheme;
                  if (currentTheme == ThemeType.dark) {
                    newTheme = ThemeType.light;
                  } else {
                    newTheme = ThemeType.dark;
                  }

                  ref.read(themeProvider.notifier).setTheme(newTheme);

                  // 显示成功提示
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              PhosphorIcons.checkCircle(),
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '已切换到${ThemeService().getThemeInfo(newTheme).name}',
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: _buildPageContent(),
    );
  }

  Widget _buildPageContent() {
    return Consumer(
      builder: (context, ref, child) {
        final currentTheme = ref.watch(currentThemeProvider);
        final themeService = ThemeService();

        return Column(
          children: [
            // 当前主题预览
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          PhosphorIcons.palette(),
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '当前主题',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '查看和应用主题设置',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 主题内容
                  Row(
                    children: [
                      // 主题图标
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: themeService
                              .getThemeInfo(currentTheme)
                              .color
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: themeService
                                .getThemeInfo(currentTheme)
                                .color
                                .withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getPhosphorIconForTheme(currentTheme),
                            color:
                                themeService.getThemeInfo(currentTheme).color,
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 主题信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 主题名称
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: themeService
                                    .getThemeInfo(currentTheme)
                                    .color
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: themeService
                                      .getThemeInfo(currentTheme)
                                      .color
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                themeService.getThemeInfo(currentTheme).name,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      themeService
                                          .getThemeInfo(currentTheme)
                                          .color,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // 主题描述
                            Text(
                              themeService
                                  .getThemeInfo(currentTheme)
                                  .description,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 主题特性
                            Row(
                              children: [
                                Icon(
                                  PhosphorIcons.checkCircle(),
                                  size: 16,
                                  color:
                                      themeService
                                          .getThemeInfo(currentTheme)
                                          .color,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '已激活',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color:
                                        themeService
                                            .getThemeInfo(currentTheme)
                                            .color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  PhosphorIcons.eye(),
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '实时预览',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 主题列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ThemeType.values.length,
                itemBuilder: (context, index) {
                  final themeType = ThemeType.values[index];
                  final themeInfo = themeService.getThemeInfo(themeType);
                  final isSelected = themeType == currentTheme;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border:
                          isSelected
                              ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                              : null,
                      color:
                          isSelected
                              ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.05)
                              : Colors.transparent,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        splashColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        highlightColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        onTap: () {
                          _selectTheme(themeType);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // 主题图标
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: themeInfo.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getPhosphorIconForTheme(themeType),
                                  color: themeInfo.color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // 主题信息
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      themeInfo.name,
                                      style: TextStyle(
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      themeInfo.description,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 选中状态
                              if (isSelected)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// 根据主题类型获取对应的 Phosphor 图标
  IconData _getPhosphorIconForTheme(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.system:
        return PhosphorIcons.gear();
      case ThemeType.light:
        return PhosphorIcons.sun();
      case ThemeType.dark:
        return PhosphorIcons.moon();
      case ThemeType.hawaiianNight:
        return PhosphorIcons.tree();
      case ThemeType.yuanShanQingDai:
        return PhosphorIcons.mountains();
      case ThemeType.seaSaltCheese:
        return PhosphorIcons.waves();
      case ThemeType.crabapple:
        return PhosphorIcons.flower();
      case ThemeType.icelandSunrise:
        return PhosphorIcons.snowflake();
      case ThemeType.lavender:
        return PhosphorIcons.leaf();
      case ThemeType.forgetMeNot:
        return PhosphorIcons.heart();
      case ThemeType.daisy:
        return PhosphorIcons.flowerLotus();
      case ThemeType.freshOrange:
        return PhosphorIcons.orange();
      case ThemeType.cherryBlossom:
        return PhosphorIcons.tree();
      case ThemeType.rainbowBlue:
        return PhosphorIcons.rainbow();
      case ThemeType.springGreen:
        return PhosphorIcons.plant();
      case ThemeType.midsummer:
        return PhosphorIcons.sunHorizon();
      case ThemeType.coolAutumn:
        return PhosphorIcons.leaf();
      case ThemeType.clearWinter:
        return PhosphorIcons.snowflake();
    }
  }

  /// 选择主题
  void _selectTheme(ThemeType themeType) async {
    await ref.read(themeProvider.notifier).setTheme(themeType);

    // 显示成功提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(PhosphorIcons.checkCircle(), color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('已切换到${ThemeService().getThemeInfo(themeType).name}'),
            ],
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
