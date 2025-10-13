import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// 应用标题
  ///
  /// In zh, this message translates to:
  /// **'Flutter UI模板'**
  String get appTitle;

  /// 欢迎标题
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用Flutter UI模板'**
  String get welcomeTitle;

  /// 欢迎副标题
  ///
  /// In zh, this message translates to:
  /// **'这是一个基于可可世界设计的UI模板'**
  String get welcomeSubtitle;

  /// 首页标签
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get home;

  /// 分类标签
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get category;

  /// 个人资料标签
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get profile;

  /// 设置页面标题
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// 主题系统功能卡片标题
  ///
  /// In zh, this message translates to:
  /// **'主题系统'**
  String get themeSystem;

  /// 主题系统功能卡片描述
  ///
  /// In zh, this message translates to:
  /// **'多种精美主题'**
  String get themeSystemDesc;

  /// 导航系统功能卡片标题
  ///
  /// In zh, this message translates to:
  /// **'导航系统'**
  String get navigationSystem;

  /// 导航系统功能卡片描述
  ///
  /// In zh, this message translates to:
  /// **'流畅的页面切换'**
  String get navigationSystemDesc;

  /// 组件库功能卡片标题
  ///
  /// In zh, this message translates to:
  /// **'组件库'**
  String get componentLibrary;

  /// 组件库功能卡片描述
  ///
  /// In zh, this message translates to:
  /// **'丰富的UI组件'**
  String get componentLibraryDesc;

  /// 设置页面功能卡片标题
  ///
  /// In zh, this message translates to:
  /// **'设置页面'**
  String get settingsPage;

  /// 设置页面功能卡片描述
  ///
  /// In zh, this message translates to:
  /// **'个性化配置'**
  String get settingsPageDesc;

  /// 外观设置分组标题
  ///
  /// In zh, this message translates to:
  /// **'外观设置'**
  String get appearanceSettings;

  /// 主题管理设置项
  ///
  /// In zh, this message translates to:
  /// **'主题管理'**
  String get themeManagement;

  /// 主题管理设置项描述
  ///
  /// In zh, this message translates to:
  /// **'选择您喜欢的主题'**
  String get themeManagementDesc;

  /// 字体大小设置项
  ///
  /// In zh, this message translates to:
  /// **'字体大小'**
  String get fontSize;

  /// 字体大小设置项描述
  ///
  /// In zh, this message translates to:
  /// **'调整应用字体大小'**
  String get fontSizeDesc;

  /// 功能设置分组标题
  ///
  /// In zh, this message translates to:
  /// **'功能设置'**
  String get functionSettings;

  /// 通知设置项
  ///
  /// In zh, this message translates to:
  /// **'通知设置'**
  String get notificationSettings;

  /// 通知设置项描述
  ///
  /// In zh, this message translates to:
  /// **'管理应用通知'**
  String get notificationSettingsDesc;

  /// 隐私设置项
  ///
  /// In zh, this message translates to:
  /// **'隐私设置'**
  String get privacySettings;

  /// 隐私设置项描述
  ///
  /// In zh, this message translates to:
  /// **'管理隐私和安全'**
  String get privacySettingsDesc;

  /// 下载设置项
  ///
  /// In zh, this message translates to:
  /// **'下载设置'**
  String get downloadSettings;

  /// 下载设置项描述
  ///
  /// In zh, this message translates to:
  /// **'配置下载选项'**
  String get downloadSettingsDesc;

  /// 关于分组标题
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// 关于应用设置项
  ///
  /// In zh, this message translates to:
  /// **'关于应用'**
  String get aboutApp;

  /// 关于应用设置项描述
  ///
  /// In zh, this message translates to:
  /// **'查看应用信息'**
  String get aboutAppDesc;

  /// 帮助与支持设置项
  ///
  /// In zh, this message translates to:
  /// **'帮助与支持'**
  String get helpSupport;

  /// 帮助与支持设置项描述
  ///
  /// In zh, this message translates to:
  /// **'获取帮助和支持'**
  String get helpSupportDesc;

  /// 意见反馈设置项
  ///
  /// In zh, this message translates to:
  /// **'意见反馈'**
  String get feedback;

  /// 意见反馈设置项描述
  ///
  /// In zh, this message translates to:
  /// **'提交反馈和建议'**
  String get feedbackDesc;

  /// 高级设置分组标题
  ///
  /// In zh, this message translates to:
  /// **'高级'**
  String get advanced;

  /// 清除缓存设置项
  ///
  /// In zh, this message translates to:
  /// **'清除缓存'**
  String get clearCache;

  /// 清除缓存设置项描述
  ///
  /// In zh, this message translates to:
  /// **'清理应用缓存数据'**
  String get clearCacheDesc;

  /// 重置设置项
  ///
  /// In zh, this message translates to:
  /// **'重置设置'**
  String get resetSettings;

  /// 重置设置项描述
  ///
  /// In zh, this message translates to:
  /// **'恢复默认设置'**
  String get resetSettingsDesc;

  /// 确定按钮
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get ok;

  /// 取消按钮
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// 语言设置项
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// 语言设置项描述
  ///
  /// In zh, this message translates to:
  /// **'选择应用显示语言'**
  String get languageDesc;

  /// 中文语言选项
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get chinese;

  /// 英文语言选项
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get english;

  /// 通知功能提示
  ///
  /// In zh, this message translates to:
  /// **'通知功能'**
  String get notificationFeature;

  /// 功能点击提示
  ///
  /// In zh, this message translates to:
  /// **'点击了{feature}'**
  String clickedFeature(String feature);

  /// 功能开发中提示
  ///
  /// In zh, this message translates to:
  /// **'{feature}功能正在开发中...'**
  String featureInDevelopment(String feature);

  /// 缓存清除成功提示
  ///
  /// In zh, this message translates to:
  /// **'缓存已清除'**
  String get cacheCleared;

  /// 设置重置成功提示
  ///
  /// In zh, this message translates to:
  /// **'设置已重置'**
  String get settingsReset;

  /// 清除缓存确认对话框内容
  ///
  /// In zh, this message translates to:
  /// **'确定要清除应用缓存吗？这将删除所有临时数据。'**
  String get clearCacheConfirm;

  /// 重置设置确认对话框内容
  ///
  /// In zh, this message translates to:
  /// **'确定要重置所有设置吗？这将恢复应用的默认配置。'**
  String get resetSettingsConfirm;

  /// 应用描述
  ///
  /// In zh, this message translates to:
  /// **'这是一个基于可可世界设计的Flutter UI模板项目。'**
  String get appDescription;

  /// 特性列表标题
  ///
  /// In zh, this message translates to:
  /// **'特性：'**
  String get features;

  /// 主题特性
  ///
  /// In zh, this message translates to:
  /// **'• 多种精美主题'**
  String get featureThemes;

  /// 响应式特性
  ///
  /// In zh, this message translates to:
  /// **'• 响应式设计'**
  String get featureResponsive;

  /// 导航特性
  ///
  /// In zh, this message translates to:
  /// **'• 流畅的导航'**
  String get featureNavigation;

  /// 组件库特性
  ///
  /// In zh, this message translates to:
  /// **'• 丰富的组件库'**
  String get featureComponents;

  /// 版权信息
  ///
  /// In zh, this message translates to:
  /// **'© 2024 Flutter UI模板'**
  String get copyright;

  /// 常见问题标题
  ///
  /// In zh, this message translates to:
  /// **'常见问题：'**
  String get commonQuestions;

  /// 主题问题
  ///
  /// In zh, this message translates to:
  /// **'Q: 如何更换主题？'**
  String get questionTheme;

  /// 主题问题答案
  ///
  /// In zh, this message translates to:
  /// **'A: 进入设置 > 主题管理，选择您喜欢的主题。'**
  String get answerTheme;

  /// 自定义问题
  ///
  /// In zh, this message translates to:
  /// **'Q: 如何自定义界面？'**
  String get questionCustomize;

  /// 自定义问题答案
  ///
  /// In zh, this message translates to:
  /// **'A: 您可以修改源代码中的主题配置和组件样式。'**
  String get answerCustomize;

  /// 更多帮助提示
  ///
  /// In zh, this message translates to:
  /// **'如需更多帮助，请查看项目文档或提交Issue。'**
  String get moreHelp;

  /// 反馈对话框内容
  ///
  /// In zh, this message translates to:
  /// **'感谢您的使用！\n\n如有问题或建议，请通过以下方式联系我们：\n\n• 提交Issue到项目仓库\n• 发送邮件反馈\n• 参与社区讨论\n\n您的反馈对我们很重要！'**
  String get feedbackContent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
