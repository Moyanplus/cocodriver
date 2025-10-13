import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/adaptive_utils.dart';
import 'language_settings_page.dart';

/// 设置页面
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
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
        Row(
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
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: ResponsiveUtils.getResponsiveFontSize(16),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getCardRadius(),
            ),
          ),
          child: Column(children: children),
        ),
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
    return AdaptiveUtils.adaptiveListTile(
      leading: CircleAvatar(
        radius: ResponsiveUtils.getIconSize(16),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: ResponsiveUtils.getIconSize(16),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: ResponsiveUtils.getResponsiveFontSize(14)),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: ResponsiveUtils.getResponsiveFontSize(12)),
      ),
      trailing:
          trailing ??
          Icon(Icons.arrow_forward_ios, size: ResponsiveUtils.getIconSize(16)),
      onTap: onTap,
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
