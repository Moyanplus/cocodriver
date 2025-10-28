// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '可可云盘';

  @override
  String get welcomeTitle => '欢迎使用可可云盘';

  @override
  String get welcomeSubtitle => '聚合云盘管理，支持百度网盘、阿里云盘、夸克云盘等';

  @override
  String get home => '首页';

  @override
  String get profile => '我的';

  @override
  String get files => '文件';

  @override
  String get settings => '设置';

  @override
  String get themeSystem => '多云盘支持';

  @override
  String get themeSystemDesc => '支持百度网盘、阿里云盘等';

  @override
  String get navigationSystem => '文件管理';

  @override
  String get navigationSystemDesc => '上传、下载、分享文件';

  @override
  String get componentLibrary => '批量操作';

  @override
  String get componentLibraryDesc => '批量上传、下载、移动';

  @override
  String get settingsPage => '安全存储';

  @override
  String get settingsPageDesc => '加密存储，保护隐私';

  @override
  String get appearanceSettings => '外观设置';

  @override
  String get themeManagement => '主题管理';

  @override
  String get themeManagementDesc => '选择您喜欢的主题';

  @override
  String get fontSize => '字体大小';

  @override
  String get fontSizeDesc => '调整应用字体大小';

  @override
  String get functionSettings => '功能设置';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get notificationSettingsDesc => '管理应用通知';

  @override
  String get privacySettings => '隐私设置';

  @override
  String get privacySettingsDesc => '管理隐私和安全';

  @override
  String get downloadSettings => '下载设置';

  @override
  String get downloadSettingsDesc => '配置下载选项';

  @override
  String get about => '关于';

  @override
  String get aboutApp => '关于应用';

  @override
  String get aboutAppDesc => '查看应用信息';

  @override
  String get helpSupport => '帮助与支持';

  @override
  String get helpSupportDesc => '获取帮助和支持';

  @override
  String get feedback => '意见反馈';

  @override
  String get feedbackDesc => '提交反馈和建议';

  @override
  String get advanced => '高级';

  @override
  String get clearCache => '清除缓存';

  @override
  String get clearCacheDesc => '清理应用缓存数据';

  @override
  String get resetSettings => '重置设置';

  @override
  String get resetSettingsDesc => '恢复默认设置';

  @override
  String get ok => '确定';

  @override
  String get cancel => '取消';

  @override
  String get language => '语言';

  @override
  String get languageDesc => '选择应用显示语言';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get notificationFeature => '通知功能';

  @override
  String clickedFeature(String feature) {
    return '点击了$feature';
  }

  @override
  String featureInDevelopment(String feature) {
    return '$feature功能正在开发中...';
  }

  @override
  String get cacheCleared => '缓存已清除';

  @override
  String get settingsReset => '设置已重置';

  @override
  String get clearCacheConfirm => '确定要清除应用缓存吗？这将删除所有临时数据。';

  @override
  String get resetSettingsConfirm => '确定要重置所有设置吗？这将恢复应用的默认配置。';

  @override
  String get appDescription => '这是一个基于可可世界设计的Flutter UI模板项目。';

  @override
  String get features => '特性：';

  @override
  String get featureThemes => '• 多种精美主题';

  @override
  String get featureResponsive => '• 响应式设计';

  @override
  String get featureNavigation => '• 流畅的导航';

  @override
  String get featureComponents => '• 丰富的组件库';

  @override
  String get copyright => '© 2024 Flutter UI模板';

  @override
  String get commonQuestions => '常见问题：';

  @override
  String get questionTheme => 'Q: 如何更换主题？';

  @override
  String get answerTheme => 'A: 进入设置 > 主题管理，选择您喜欢的主题。';

  @override
  String get questionCustomize => 'Q: 如何自定义界面？';

  @override
  String get answerCustomize => 'A: 您可以修改源代码中的主题配置和组件样式。';

  @override
  String get moreHelp => '如需更多帮助，请查看项目文档或提交Issue。';

  @override
  String get feedbackContent =>
      '感谢您的使用！\n\n如有问题或建议，请通过以下方式联系我们：\n\n• 提交Issue到项目仓库\n• 发送邮件反馈\n• 参与社区讨论\n\n您的反馈对我们很重要！';
}
