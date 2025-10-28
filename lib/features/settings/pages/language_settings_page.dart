/// 语言设置页面Widget
///
/// 提供应用程序语言管理功能，包括语言切换、语言列表展示等
/// 使用Riverpod进行状态管理，支持多语言切换
///
/// 主要功能：
/// - 支持的语言列表展示
/// - 当前语言标识
/// - 语言切换功能
/// - 语言设置持久化
/// - 响应式布局
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../l10n/app_localizations.dart';

// 核心模块导入
import '../../../core/providers/localization_providers.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/adaptive_utils.dart';

/// 语言设置页面Widget
///
/// 提供应用程序语言管理功能，包括语言切换、语言列表展示等
/// 使用Riverpod进行状态管理，支持多语言切换
class LanguageSettingsPage extends ConsumerStatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  ConsumerState<LanguageSettingsPage> createState() =>
      _LanguageSettingsPageState();
}

/// LanguageSettingsPage的状态管理类
///
/// 负责监听语言变化，构建语言设置页面的UI结构
/// 包括语言列表、当前语言标识、语言切换等功能
class _LanguageSettingsPageState extends ConsumerState<LanguageSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(currentLocaleProvider);
    final supportedLocales = ref.watch(supportedLocalesProvider);
    final localizationNotifier = ref.watch(localizationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _buildPageContent(
        l10n,
        currentLocale,
        supportedLocales,
        localizationNotifier,
      ),
    );
  }

  Widget _buildPageContent(
    AppLocalizations l10n,
    Locale currentLocale,
    List<Locale> supportedLocales,
    LocalizationNotifier localizationNotifier,
  ) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 语言选择说明
          Container(
            padding: ResponsiveUtils.getResponsivePadding(all: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getCardRadius(),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.info(),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: ResponsiveUtils.getIconSize(20),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    l10n.languageDesc,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // 语言选项列表
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getCardRadius(),
              ),
            ),
            child: Column(
              children:
                  supportedLocales.map((locale) {
                    final isSelected =
                        locale.languageCode == currentLocale.languageCode;
                    final languageName = localizationNotifier.getLanguageName(
                      locale,
                    );

                    return AdaptiveUtils.adaptiveListTile(
                      leading: CircleAvatar(
                        radius: ResponsiveUtils.getIconSize(16),
                        backgroundColor:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          isSelected
                              ? PhosphorIcons.check()
                              : PhosphorIcons.circle(),
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                          size: ResponsiveUtils.getIconSize(16),
                        ),
                      ),
                      title: Text(
                        languageName,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(16),
                        ),
                      ),
                      subtitle: Text(
                        _getLanguageSubtitle(locale, l10n),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: ResponsiveUtils.getResponsiveFontSize(12),
                        ),
                      ),
                      trailing:
                          isSelected
                              ? Icon(
                                PhosphorIcons.check(),
                                color: Theme.of(context).colorScheme.primary,
                                size: ResponsiveUtils.getIconSize(20),
                              )
                              : null,
                      onTap: () {
                        if (!isSelected) {
                          localizationNotifier.setLocale(locale);
                        }
                      },
                    );
                  }).toList(),
            ),
          ),

          SizedBox(height: 24.h),

          // 重置按钮
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showResetDialog(l10n, localizationNotifier);
              },
              icon: Icon(
                PhosphorIcons.arrowClockwise(),
                size: ResponsiveUtils.getIconSize(20),
              ),
              label: Text(
                '重置为默认语言',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(14),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getCardRadius(),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  String _getLanguageSubtitle(Locale locale, AppLocalizations l10n) {
    switch (locale.languageCode) {
      case 'zh':
        return '简体中文';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  void _showResetDialog(
    AppLocalizations l10n,
    LocalizationNotifier localizationNotifier,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('重置语言'),
            content: Text('确定要重置为默认语言（中文）吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  localizationNotifier.resetToDefault();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('语言已重置为默认设置')));
                },
                child: Text(l10n.ok),
              ),
            ],
          ),
    );
  }
}
