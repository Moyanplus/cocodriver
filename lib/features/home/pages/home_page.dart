import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/mixins/smart_keep_alive_mixin.dart';
import '../../../core/utils/responsive_utils.dart';

/// 首页
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

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

        // 功能卡片
        SliverPadding(
          padding: ResponsiveUtils.getResponsivePadding(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveUtils.getGridColumns(),
              crossAxisSpacing: ResponsiveUtils.getSpacing(),
              mainAxisSpacing: ResponsiveUtils.getSpacing(),
              childAspectRatio: ResponsiveUtils.isMobile ? 1.5 : 1.8,
            ),
            delegate: SliverChildListDelegate([
              _buildFeatureCard(
                icon: Icons.cloud,
                title: l10n.themeSystem,
                subtitle: l10n.themeSystemDesc,
                color: Colors.blue,
                l10n: l10n,
              ),
              _buildFeatureCard(
                icon: Icons.folder,
                title: l10n.navigationSystem,
                subtitle: l10n.navigationSystemDesc,
                color: Colors.green,
                l10n: l10n,
              ),
              _buildFeatureCard(
                icon: Icons.playlist_add_check,
                title: l10n.componentLibrary,
                subtitle: l10n.componentLibraryDesc,
                color: Colors.orange,
                l10n: l10n,
              ),
              _buildFeatureCard(
                icon: Icons.security,
                title: l10n.settingsPage,
                subtitle: l10n.settingsPageDesc,
                color: Colors.purple,
                l10n: l10n,
              ),
            ]),
          ),
        ),

        // 底部间距
        SliverToBoxAdapter(child: SizedBox(height: 80.h)),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required AppLocalizations l10n,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.getCardRadius()),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(ResponsiveUtils.getCardRadius()),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.clickedFeature(title))));
        },
        child: Container(
          padding: ResponsiveUtils.getResponsivePadding(all: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getCardRadius(),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: ResponsiveUtils.getIconSize(28), color: color),
              SizedBox(height: 6.h),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(14),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 2.h),
              Flexible(
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: ResponsiveUtils.getResponsiveFontSize(12),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
