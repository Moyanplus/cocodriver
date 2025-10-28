/// 主题设置页面Widget
///
/// 提供应用程序主题管理功能，包括主题切换、主题预览等
/// 使用Riverpod进行状态管理，支持多种主题类型的切换
///
/// 主要功能：
/// - 主题列表展示
/// - 主题切换功能
/// - 主题预览
/// - 付费主题标识
/// - 响应式布局
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 核心模块导入
import '../../../core/theme/theme_models.dart';
import '../../../core/navigation/navigation_providers.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/adaptive_utils.dart';

/// 主题设置页面Widget
///
/// 提供应用程序主题管理功能，包括主题切换、主题预览等
/// 使用Riverpod进行状态管理，支持多种主题类型的切换
class ThemeSettingsPage extends ConsumerStatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  ConsumerState<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

/// ThemeSettingsPage的状态管理类
///
/// 负责监听主题变化，构建主题设置页面的UI结构
/// 包括主题列表、主题切换、主题预览等功能
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
              margin: ResponsiveUtils.getResponsivePadding(all: 16),
              padding: ResponsiveUtils.getResponsivePadding(all: 20),
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
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getCardRadius(),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
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
                        padding: ResponsiveUtils.getResponsivePadding(all: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          PhosphorIcons.palette(),
                          color: Theme.of(context).colorScheme.primary,
                          size: ResponsiveUtils.getIconSize(20),
                        ),
                      ),
                      SizedBox(width: 12.w),
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
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  16,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '查看和应用主题设置',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // 主题内容
                  Row(
                    children: [
                      // 主题图标
                      Container(
                        width: 100.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          color: themeService
                              .getThemeInfo(currentTheme)
                              .color
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: themeService
                                .getThemeInfo(currentTheme)
                                .color
                                .withValues(alpha: 0.2),
                            width: 1.w,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getPhosphorIconForTheme(currentTheme),
                            color:
                                themeService.getThemeInfo(currentTheme).color,
                            size: ResponsiveUtils.getIconSize(48),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // 主题信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 主题名称
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: themeService
                                    .getThemeInfo(currentTheme)
                                    .color
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: themeService
                                      .getThemeInfo(currentTheme)
                                      .color
                                      .withValues(alpha: 0.3),
                                  width: 1.w,
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
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(14),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
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
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  14,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            // 主题特性
                            Row(
                              children: [
                                Icon(
                                  PhosphorIcons.checkCircle(),
                                  size: ResponsiveUtils.getIconSize(16),
                                  color:
                                      themeService
                                          .getThemeInfo(currentTheme)
                                          .color,
                                ),
                                SizedBox(width: 6.w),
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
                                    fontSize:
                                        ResponsiveUtils.getResponsiveFontSize(
                                          12,
                                        ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Icon(
                                  PhosphorIcons.eye(),
                                  size: ResponsiveUtils.getIconSize(16),
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  '实时预览',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                    fontSize:
                                        ResponsiveUtils.getResponsiveFontSize(
                                          12,
                                        ),
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
                padding: ResponsiveUtils.getResponsivePadding(horizontal: 16),
                itemCount: ThemeType.values.length,
                itemBuilder: (context, index) {
                  final themeType = ThemeType.values[index];
                  final themeInfo = themeService.getThemeInfo(themeType);
                  final isSelected = themeType == currentTheme;

                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getCardRadius(),
                      ),
                      border:
                          isSelected
                              ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2.w,
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
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getCardRadius(),
                        ),
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
                          padding: ResponsiveUtils.getResponsivePadding(
                            all: 16,
                          ),
                          child: Row(
                            children: [
                              // 主题图标
                              Container(
                                padding: ResponsiveUtils.getResponsivePadding(
                                  all: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: themeInfo.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  _getPhosphorIconForTheme(themeType),
                                  color: themeInfo.color,
                                  size: ResponsiveUtils.getIconSize(24),
                                ),
                              ),
                              SizedBox(width: 16.w),
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
                                        fontSize:
                                            ResponsiveUtils.getResponsiveFontSize(
                                              16,
                                            ),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      themeInfo.description,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.7),
                                        fontSize:
                                            ResponsiveUtils.getResponsiveFontSize(
                                              14,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 选中状态
                              if (isSelected)
                                Container(
                                  width: 24.w,
                                  height: 24.h,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: ResponsiveUtils.getIconSize(16),
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
