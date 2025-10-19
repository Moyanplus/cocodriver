// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Coco Cloud Drive';

  @override
  String get welcomeTitle => 'Welcome to Coco Cloud Drive';

  @override
  String get welcomeSubtitle =>
      'Unified cloud drive management supporting Baidu, Aliyun, Quark and more';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get themeSystem => 'Multi-Cloud Support';

  @override
  String get themeSystemDesc => 'Support Baidu, Aliyun and more';

  @override
  String get navigationSystem => 'File Management';

  @override
  String get navigationSystemDesc => 'Upload, download, share files';

  @override
  String get componentLibrary => 'Batch Operations';

  @override
  String get componentLibraryDesc => 'Batch upload, download, move';

  @override
  String get settingsPage => 'Secure Storage';

  @override
  String get settingsPageDesc => 'Encrypted storage, privacy protection';

  @override
  String get appearanceSettings => 'Appearance Settings';

  @override
  String get themeManagement => 'Theme Management';

  @override
  String get themeManagementDesc => 'Choose your favorite theme';

  @override
  String get fontSize => 'Font Size';

  @override
  String get fontSizeDesc => 'Adjust application font size';

  @override
  String get functionSettings => 'Function Settings';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationSettingsDesc => 'Manage application notifications';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get privacySettingsDesc => 'Manage privacy and security';

  @override
  String get downloadSettings => 'Download Settings';

  @override
  String get downloadSettingsDesc => 'Configure download options';

  @override
  String get about => 'About';

  @override
  String get aboutApp => 'About App';

  @override
  String get aboutAppDesc => 'View application information';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get helpSupportDesc => 'Get help and support';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackDesc => 'Submit feedback and suggestions';

  @override
  String get advanced => 'Advanced';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheDesc => 'Clean application cache data';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsDesc => 'Restore default settings';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get language => 'Language';

  @override
  String get languageDesc => 'Choose application display language';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get notificationFeature => 'Notification Feature';

  @override
  String clickedFeature(String feature) {
    return 'Clicked $feature';
  }

  @override
  String featureInDevelopment(String feature) {
    return '$feature feature is under development...';
  }

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get settingsReset => 'Settings reset';

  @override
  String get clearCacheConfirm =>
      'Are you sure you want to clear the application cache? This will delete all temporary data.';

  @override
  String get resetSettingsConfirm =>
      'Are you sure you want to reset all settings? This will restore the application\'s default configuration.';

  @override
  String get appDescription =>
      'Coco Cloud Drive is a third-party aggregated cloud drive client that supports unified management of multiple mainstream cloud drive services.';

  @override
  String get features => 'Features:';

  @override
  String get featureThemes => '• Unified multi-cloud management';

  @override
  String get featureResponsive => '• High-speed download and upload';

  @override
  String get featureNavigation => '• File sharing features';

  @override
  String get featureComponents => '• Secure encrypted storage';

  @override
  String get copyright => '© 2024 Coco Cloud Drive';

  @override
  String get commonQuestions => 'Common Questions:';

  @override
  String get questionTheme => 'Q: How to change theme?';

  @override
  String get answerTheme =>
      'A: Go to Settings > Theme Management, choose your favorite theme.';

  @override
  String get questionCustomize => 'Q: How to customize interface?';

  @override
  String get answerCustomize =>
      'A: You can modify theme configuration and component styles in the source code.';

  @override
  String get moreHelp =>
      'For more help, please check the project documentation or submit an Issue.';

  @override
  String get feedbackContent =>
      'Thank you for using our app!\n\nIf you have any questions or suggestions, please contact us through the following ways:\n\n• Submit an Issue to the project repository\n• Send email feedback\n• Participate in community discussions\n\nYour feedback is important to us!';
}
