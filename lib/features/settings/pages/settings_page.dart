import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/adaptive_utils.dart';
import 'language_settings_page.dart';
import '../../../tool/app_update/app_update.dart';
import '../../../tool/log_viewer/pages/log_viewer_page.dart';

/// 设置页面Widget
///
/// 应用程序的设置界面组件，使用Riverpod进行状态管理
/// 提供各种配置选项和设置功能
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _buildPageContent(l10n),
    );
  }

  Widget _buildPageContent(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 外观设置
          _buildSection(
            title: l10n.appearanceSettings,
            icon: PhosphorIcons.palette(),
            children: [
              _buildSettingsTile(
                icon: PhosphorIcons.palette(),
                title: l10n.themeManagement,
                subtitle: l10n.themeManagementDesc,
                onTap: () {
                  Navigator.of(context).pushNamed('/settings/theme');
                },
              ),
              _buildSettingsTile(
                icon: PhosphorIcons.textAa(),
                title: l10n.fontSize,
                subtitle: l10n.fontSizeDesc,
                onTap: () {
                  _showFontSizeDialog(l10n);
                },
              ),
              _buildSettingsTile(
                icon: PhosphorIcons.translate(),
                title: l10n.language,
                subtitle: l10n.languageDesc,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LanguageSettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // 功能设置
          _buildSection(
            title: l10n.functionSettings,
            icon: PhosphorIcons.gear(),
            children: [
              _buildSettingsTile(
                icon: PhosphorIcons.bell(),
                title: l10n.notificationSettings,
                subtitle: l10n.notificationSettingsDesc,
                onTap: () {
                  _showNotificationSettings(l10n);
                },
              ),
              _buildSettingsTile(
                icon: PhosphorIcons.lock(),
                title: l10n.privacySettings,
                subtitle: l10n.privacySettingsDesc,
                onTap: () {
                  _showPrivacySettings(l10n);
                },
              ),
              _buildSettingsTile(
                icon: PhosphorIcons.download(),
                title: l10n.downloadSettings,
                subtitle: l10n.downloadSettingsDesc,
                onTap: () {
                  _showDownloadSettings(l10n);
                },
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // 关于设置
          _buildSection(
            title: l10n.about,
            icon: PhosphorIcons.info(),
            children: [
              _buildSettingsTile(
                icon: PhosphorIcons.info(),
                title: l10n.aboutApp,
                subtitle: l10n.aboutAppDesc,
                onTap: () {
                  _showAboutDialog(l10n);
                },
              ),
              _buildSettingsTile(
                icon: Icons.system_update,
                title: '检查更新',
                subtitle: '检查应用是否有新版本',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdateDetailPage(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                icon: PhosphorIcons.question(),
                title: l10n.helpSupport,
                subtitle: l10n.helpSupportDesc,
                onTap: () {
                  _showHelpDialog(l10n);
                },
              ),
              _buildSettingsTile(
                icon: PhosphorIcons.chatCircle(),
                title: l10n.feedback,
                subtitle: l10n.feedbackDesc,
                onTap: () {
                  _showFeedbackDialog(l10n);
                },
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // 高级设置
          _buildSection(
            title: l10n.advanced,
            icon: PhosphorIcons.wrench(),
            children: [
              _buildSettingsTile(
                icon: PhosphorIcons.fileText(),
                title: '日志查看器',
                subtitle: '查看、导出和管理应用日志',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LogViewerPage(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                icon: PhosphorIcons.trash(),
                title: l10n.clearCache,
                subtitle: l10n.clearCacheDesc,
                onTap: () {
                  _showClearCacheDialog(l10n);
                },
              ),
              _buildSettingsTile(
                icon: PhosphorIcons.arrowClockwise(),
                title: l10n.resetSettings,
                subtitle: l10n.resetSettingsDesc,
                onTap: () {
                  _showResetSettingsDialog(l10n);
                },
              ),
            ],
          ),

          SizedBox(height: 80.h),
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
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: ResponsiveUtils.getIconSize(20),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(16),
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getCardRadius(),
            ),
            side: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(children: _buildChildrenWithDividers(children)),
        ),
      ],
    );
  }

  /// 在子组件之间添加分隔线
  List<Widget> _buildChildrenWithDividers(List<Widget> children) {
    if (children.isEmpty) return children;

    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      // 如果不是最后一个元素，添加分隔线
      if (i < children.length - 1) {
        result.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: 56.w, // 对齐icon后面的内容
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        );
      }
    }
    return result;
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: AdaptiveUtils.adaptiveListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: ResponsiveUtils.getIconSize(20),
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: ResponsiveUtils.getResponsiveFontSize(15),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: ResponsiveUtils.getResponsiveFontSize(13),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: ResponsiveUtils.getIconSize(16),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        onTap: onTap,
      ),
    );
  }

  void _showFontSizeDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.fontSize),
            content: Text(l10n.featureInDevelopment(l10n.fontSize)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.ok),
              ),
            ],
          ),
    );
  }

  void _showNotificationSettings(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.notificationSettings),
            content: Text(l10n.featureInDevelopment(l10n.notificationSettings)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.ok),
              ),
            ],
          ),
    );
  }

  void _showPrivacySettings(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.privacySettings),
            content: Text(l10n.featureInDevelopment(l10n.privacySettings)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.ok),
              ),
            ],
          ),
    );
  }

  void _showDownloadSettings(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.downloadSettings),
            content: Text(l10n.featureInDevelopment(l10n.downloadSettings)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.ok),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog(AppLocalizations l10n) {
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: '1.0.0',
      applicationIcon: Icon(PhosphorIcons.squaresFour(), size: 48),
      children: [
        Text(l10n.appDescription),
        const SizedBox(height: 16),
        Text(l10n.features),
        Text(l10n.featureThemes),
        Text(l10n.featureResponsive),
        Text(l10n.featureNavigation),
        Text(l10n.featureComponents),
        const SizedBox(height: 16),
        Text(l10n.copyright),
      ],
    );
  }

  void _showHelpDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.helpSupport),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.commonQuestions),
                const SizedBox(height: 8),
                Text(l10n.questionTheme),
                Text(l10n.answerTheme),
                const SizedBox(height: 8),
                Text(l10n.questionCustomize),
                Text(l10n.answerCustomize),
                const SizedBox(height: 8),
                Text(l10n.moreHelp),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.ok),
              ),
            ],
          ),
    );
  }

  void _showFeedbackDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.feedback),
            content: Text(l10n.feedbackContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.ok),
              ),
            ],
          ),
    );
  }

  void _showClearCacheDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.clearCache),
            content: Text(l10n.clearCacheConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.cacheCleared)));
                },
                child: Text(l10n.ok),
              ),
            ],
          ),
    );
  }

  void _showResetSettingsDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.resetSettings),
            content: Text(l10n.resetSettingsConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.settingsReset)));
                },
                child: Text(l10n.ok),
              ),
            ],
          ),
    );
  }
}
