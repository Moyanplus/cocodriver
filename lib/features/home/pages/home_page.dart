import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/mixins/smart_keep_alive_mixin.dart';
import '../../../core/utils/responsive_utils.dart';

/// 首页Widget
///
/// 应用程序的首页组件，使用Riverpod进行状态管理
/// 展示主要功能和内容，支持下拉刷新
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

/// HomePage的状态管理类
///
/// 使用SmartKeepAliveClientMixin实现智能保活
/// 负责构建首页的UI结构和处理用户交互
class _HomePageState extends ConsumerState<HomePage>
    with SmartKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          // 模拟刷新
          await Future.delayed(const Duration(seconds: 1));
        },
        child: _buildPageContent(l10n),
      ),
    );
  }

  Widget _buildPageContent(AppLocalizations l10n) {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        // 欢迎标题
        SliverToBoxAdapter(
          child: Container(
            padding: ResponsiveUtils.getResponsivePadding(
              horizontal: 16,
              vertical: 16,
            ).copyWith(bottom: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(24),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.welcomeSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: ResponsiveUtils.getResponsiveFontSize(14),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 底部间距
        SliverToBoxAdapter(child: SizedBox(height: 80.h)),
      ],
    );
  }
}
