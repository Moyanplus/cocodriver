import 'package:flutter/material.dart';

/// 云盘助手本地化类
class CloudDriveLocalizations {
  final Locale locale;

  CloudDriveLocalizations(this.locale);

  static CloudDriveLocalizations of(BuildContext context) {
    return Localizations.of<CloudDriveLocalizations>(
      context,
      CloudDriveLocalizations,
    )!;
  }

  static const LocalizationsDelegate<CloudDriveLocalizations> delegate =
      _CloudDriveLocalizationsDelegate();

  // 通用文本
  String get appName => _getText('app_name');
  String get ok => _getText('ok');
  String get cancel => _getText('cancel');
  String get confirm => _getText('confirm');
  String get save => _getText('save');
  String get delete => _getText('delete');
  String get edit => _getText('edit');
  String get add => _getText('add');
  String get remove => _getText('remove');
  String get refresh => _getText('refresh');
  String get retry => _getText('retry');
  String get loading => _getText('loading');
  String get error => _getText('error');
  String get success => _getText('success');
  String get warning => _getText('warning');
  String get info => _getText('info');

  // 云盘助手页面
  String get cloudDriveAssistant => _getText('cloud_drive_assistant');
  String get addAccount => _getText('add_account');
  String get directLink => _getText('direct_link');
  String get fileUpload => _getText('file_upload');
  String get settings => _getText('settings');
  String get quickActions => _getText('quick_actions');

  // 账号管理
  String get accountManagement => _getText('account_management');
  String get selectAccount => _getText('select_account');
  String get hideAccountSelector => _getText('hide_account_selector');
  String get showAccountSelector => _getText('show_account_selector');
  String get accountName => _getText('account_name');
  String get accountType => _getText('account_type');
  String get lastLogin => _getText('last_login');
  String get accountStatus => _getText('account_status');
  String get accountValid => _getText('account_valid');
  String get accountInvalid => _getText('account_invalid');

  // 文件操作
  String get fileOperations => _getText('file_operations');
  String get download => _getText('download');
  String get upload => _getText('upload');
  String get rename => _getText('rename');
  String get move => _getText('move');
  String get copy => _getText('copy');
  String get share => _getText('share');
  String get preview => _getText('preview');
  String get fileList => _getText('file_list');
  String get folderList => _getText('folder_list');
  String get createFolder => _getText('create_folder');
  String get fileName => _getText('file_name');
  String get fileSize => _getText('file_size');
  String get fileType => _getText('file_type');
  String get modifiedTime => _getText('modified_time');
  String get filePath => _getText('file_path');

  // 批量操作
  String get batchOperations => _getText('batch_operations');
  String get selectAll => _getText('select_all');
  String get deselectAll => _getText('deselect_all');
  String get batchDownload => _getText('batch_download');
  String get batchDelete => _getText('batch_delete');
  String get batchMove => _getText('batch_move');
  String get batchCopy => _getText('batch_copy');
  String get selectedItems => _getText('selected_items');

  // 云盘类型
  String get baiduCloud => _getText('baidu_cloud');
  String get aliCloud => _getText('ali_cloud');
  String get lanzouCloud => _getText('lanzou_cloud');
  String get pan123Cloud => _getText('pan123_cloud');
  String get quarkCloud => _getText('quark_cloud');
  String get unknownCloud => _getText('unknown_cloud');

  // 状态信息
  String get connected => _getText('connected');
  String get disconnected => _getText('disconnected');
  String get connecting => _getText('connecting');
  String get disconnecting => _getText('disconnecting');
  String get online => _getText('online');
  String get offline => _getText('offline');

  // 错误信息
  String get networkError => _getText('network_error');
  String get connectionTimeout => _getText('connection_timeout');
  String get serverError => _getText('server_error');
  String get authenticationError => _getText('authentication_error');
  String get fileNotFound => _getText('file_not_found');
  String get permissionDenied => _getText('permission_denied');
  String get storageFull => _getText('storage_full');
  String get invalidFile => _getText('invalid_file');
  String get operationFailed => _getText('operation_failed');
  String get unknownError => _getText('unknown_error');

  // 性能监控
  String get performanceMonitor => _getText('performance_monitor');
  String get systemInfo => _getText('system_info');
  String get memoryUsage => _getText('memory_usage');
  String get cpuUsage => _getText('cpu_usage');
  String get diskUsage => _getText('disk_usage');
  String get networkStats => _getText('network_stats');
  String get apiCalls => _getText('api_calls');
  String get fileOperationsText => _getText('file_operations');
  String get uiRendering => _getText('ui_rendering');
  String get totalOperations => _getText('total_operations');
  String get averageDuration => _getText('average_duration');
  String get minDuration => _getText('min_duration');
  String get maxDuration => _getText('max_duration');
  String get medianDuration => _getText('median_duration');
  String get errorRate => _getText('error_rate');
  String get lastUpdated => _getText('last_updated');

  // 错误恢复
  String get errorRecovery => _getText('error_recovery');
  String get retryAttempt => _getText('retry_attempt');
  String get retryFailed => _getText('retry_failed');
  String get retrySuccess => _getText('retry_success');
  String get fallbackMode => _getText('fallback_mode');
  String get circuitBreakerOpen => _getText('circuit_breaker_open');
  String get operationTimeout => _getText('operation_timeout');

  // 设置页面
  String get generalSettings => _getText('general_settings');
  String get languageSettings => _getText('language_settings');
  String get themeSettings => _getText('theme_settings');
  String get performanceSettings => _getText('performance_settings');
  String get cacheSettings => _getText('cache_settings');
  String get securitySettings => _getText('security_settings');
  String get about => _getText('about');
  String get version => _getText('version');
  String get buildNumber => _getText('build_number');

  // 语言选项
  String get chinese => _getText('chinese');
  String get english => _getText('english');
  String get japanese => _getText('japanese');
  String get korean => _getText('korean');

  // 主题选项
  String get lightTheme => _getText('light_theme');
  String get darkTheme => _getText('dark_theme');
  String get systemTheme => _getText('system_theme');

  // 时间格式
  String get justNow => _getText('just_now');
  String get minutesAgo => _getText('minutes_ago');
  String get hoursAgo => _getText('hours_ago');
  String get daysAgo => _getText('days_ago');
  String get weeksAgo => _getText('weeks_ago');
  String get monthsAgo => _getText('months_ago');
  String get yearsAgo => _getText('years_ago');

  // 文件大小单位
  String get bytes => _getText('bytes');
  String get kilobytes => _getText('kilobytes');
  String get megabytes => _getText('megabytes');
  String get gigabytes => _getText('gigabytes');
  String get terabytes => _getText('terabytes');

  // 获取本地化文本
  String _getText(String key) {
    final texts = _getTexts();
    return texts[key] ?? key;
  }

  Map<String, String> _getTexts() {
    switch (locale.languageCode) {
      case 'zh':
        return _chineseTexts;
      case 'en':
        return _englishTexts;
      case 'ja':
        return _japaneseTexts;
      case 'ko':
        return _koreanTexts;
      default:
        return _englishTexts;
    }
  }

  // 中文文本
  static const Map<String, String> _chineseTexts = {
    'app_name': '云盘助手',
    'ok': '确定',
    'cancel': '取消',
    'confirm': '确认',
    'save': '保存',
    'delete': '删除',
    'edit': '编辑',
    'add': '添加',
    'remove': '移除',
    'refresh': '刷新',
    'retry': '重试',
    'loading': '加载中...',
    'error': '错误',
    'success': '成功',
    'warning': '警告',
    'info': '信息',
    'cloud_drive_assistant': '云盘助手',
    'add_account': '添加账号',
    'direct_link': '直链解析',
    'file_upload': '文件上传',
    'settings': '设置',
    'quick_actions': '快速操作',
    'account_management': '账号管理',
    'select_account': '选择账号',
    'hide_account_selector': '隐藏账号选择器',
    'show_account_selector': '显示账号选择器',
    'account_name': '账号名称',
    'account_type': '账号类型',
    'last_login': '最后登录',
    'account_status': '账号状态',
    'account_valid': '账号有效',
    'account_invalid': '账号无效',
    'file_operations': '文件操作',
    'download': '下载',
    'upload': '上传',
    'rename': '重命名',
    'move': '移动',
    'copy': '复制',
    'share': '分享',
    'preview': '预览',
    'file_list': '文件列表',
    'folder_list': '文件夹列表',
    'create_folder': '创建文件夹',
    'file_name': '文件名',
    'file_size': '文件大小',
    'file_type': '文件类型',
    'modified_time': '修改时间',
    'file_path': '文件路径',
    'batch_operations': '批量操作',
    'select_all': '全选',
    'deselect_all': '取消全选',
    'batch_download': '批量下载',
    'batch_delete': '批量删除',
    'batch_move': '批量移动',
    'batch_copy': '批量复制',
    'selected_items': '已选择项目',
    'baidu_cloud': '百度网盘',
    'ali_cloud': '阿里云盘',
    'lanzou_cloud': '蓝奏云盘',
    'pan123_cloud': '123云盘',
    'quark_cloud': '夸克网盘',
    'unknown_cloud': '未知云盘',
    'connected': '已连接',
    'disconnected': '已断开',
    'connecting': '连接中...',
    'disconnecting': '断开中...',
    'online': '在线',
    'offline': '离线',
    'network_error': '网络错误',
    'connection_timeout': '连接超时',
    'server_error': '服务器错误',
    'authentication_error': '认证错误',
    'file_not_found': '文件未找到',
    'permission_denied': '权限不足',
    'storage_full': '存储空间不足',
    'invalid_file': '无效文件',
    'operation_failed': '操作失败',
    'unknown_error': '未知错误',
    'performance_monitor': '性能监控',
    'system_info': '系统信息',
    'memory_usage': '内存使用',
    'cpu_usage': 'CPU使用率',
    'disk_usage': '磁盘使用率',
    'network_stats': '网络统计',
    'api_calls': 'API调用',
    'ui_rendering': 'UI渲染',
    'total_operations': '总操作数',
    'average_duration': '平均耗时',
    'min_duration': '最小耗时',
    'max_duration': '最大耗时',
    'median_duration': '中位耗时',
    'error_rate': '错误率',
    'last_updated': '最后更新',
    'error_recovery': '错误恢复',
    'retry_attempt': '重试尝试',
    'retry_failed': '重试失败',
    'retry_success': '重试成功',
    'fallback_mode': '降级模式',
    'circuit_breaker_open': '熔断器打开',
    'operation_timeout': '操作超时',
    'general_settings': '通用设置',
    'language_settings': '语言设置',
    'theme_settings': '主题设置',
    'performance_settings': '性能设置',
    'cache_settings': '缓存设置',
    'security_settings': '安全设置',
    'about': '关于',
    'version': '版本',
    'build_number': '构建号',
    'chinese': '中文',
    'english': 'English',
    'japanese': '日本語',
    'korean': '한국어',
    'light_theme': '浅色主题',
    'dark_theme': '深色主题',
    'system_theme': '跟随系统',
    'just_now': '刚刚',
    'minutes_ago': '分钟前',
    'hours_ago': '小时前',
    'days_ago': '天前',
    'weeks_ago': '周前',
    'months_ago': '月前',
    'years_ago': '年前',
    'bytes': '字节',
    'kilobytes': 'KB',
    'megabytes': 'MB',
    'gigabytes': 'GB',
    'terabytes': 'TB',
  };

  // 英文文本
  static const Map<String, String> _englishTexts = {
    'app_name': 'Cloud Drive Assistant',
    'ok': 'OK',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'remove': 'Remove',
    'refresh': 'Refresh',
    'retry': 'Retry',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'warning': 'Warning',
    'info': 'Info',
    'cloud_drive_assistant': 'Cloud Drive Assistant',
    'add_account': 'Add Account',
    'direct_link': 'Direct Link',
    'file_upload': 'File Upload',
    'settings': 'Settings',
    'quick_actions': 'Quick Actions',
    'account_management': 'Account Management',
    'select_account': 'Select Account',
    'hide_account_selector': 'Hide Account Selector',
    'show_account_selector': 'Show Account Selector',
    'account_name': 'Account Name',
    'account_type': 'Account Type',
    'last_login': 'Last Login',
    'account_status': 'Account Status',
    'account_valid': 'Account Valid',
    'account_invalid': 'Account Invalid',
    'file_operations': 'File Operations',
    'download': 'Download',
    'upload': 'Upload',
    'rename': 'Rename',
    'move': 'Move',
    'copy': 'Copy',
    'share': 'Share',
    'preview': 'Preview',
    'file_list': 'File List',
    'folder_list': 'Folder List',
    'create_folder': 'Create Folder',
    'file_name': 'File Name',
    'file_size': 'File Size',
    'file_type': 'File Type',
    'modified_time': 'Modified Time',
    'file_path': 'File Path',
    'batch_operations': 'Batch Operations',
    'select_all': 'Select All',
    'deselect_all': 'Deselect All',
    'batch_download': 'Batch Download',
    'batch_delete': 'Batch Delete',
    'batch_move': 'Batch Move',
    'batch_copy': 'Batch Copy',
    'selected_items': 'Selected Items',
    'baidu_cloud': 'Baidu Cloud',
    'ali_cloud': 'Ali Cloud',
    'lanzou_cloud': 'Lanzou Cloud',
    'pan123_cloud': '123 Cloud',
    'quark_cloud': 'Quark Cloud',
    'unknown_cloud': 'Unknown Cloud',
    'connected': 'Connected',
    'disconnected': 'Disconnected',
    'connecting': 'Connecting...',
    'disconnecting': 'Disconnecting...',
    'online': 'Online',
    'offline': 'Offline',
    'network_error': 'Network Error',
    'connection_timeout': 'Connection Timeout',
    'server_error': 'Server Error',
    'authentication_error': 'Authentication Error',
    'file_not_found': 'File Not Found',
    'permission_denied': 'Permission Denied',
    'storage_full': 'Storage Full',
    'invalid_file': 'Invalid File',
    'operation_failed': 'Operation Failed',
    'unknown_error': 'Unknown Error',
    'performance_monitor': 'Performance Monitor',
    'system_info': 'System Info',
    'memory_usage': 'Memory Usage',
    'cpu_usage': 'CPU Usage',
    'disk_usage': 'Disk Usage',
    'network_stats': 'Network Stats',
    'api_calls': 'API Calls',
    'ui_rendering': 'UI Rendering',
    'total_operations': 'Total Operations',
    'average_duration': 'Average Duration',
    'min_duration': 'Min Duration',
    'max_duration': 'Max Duration',
    'median_duration': 'Median Duration',
    'error_rate': 'Error Rate',
    'last_updated': 'Last Updated',
    'error_recovery': 'Error Recovery',
    'retry_attempt': 'Retry Attempt',
    'retry_failed': 'Retry Failed',
    'retry_success': 'Retry Success',
    'fallback_mode': 'Fallback Mode',
    'circuit_breaker_open': 'Circuit Breaker Open',
    'operation_timeout': 'Operation Timeout',
    'general_settings': 'General Settings',
    'language_settings': 'Language Settings',
    'theme_settings': 'Theme Settings',
    'performance_settings': 'Performance Settings',
    'cache_settings': 'Cache Settings',
    'security_settings': 'Security Settings',
    'about': 'About',
    'version': 'Version',
    'build_number': 'Build Number',
    'chinese': '中文',
    'english': 'English',
    'japanese': '日本語',
    'korean': '한국어',
    'light_theme': 'Light Theme',
    'dark_theme': 'Dark Theme',
    'system_theme': 'System Theme',
    'just_now': 'Just now',
    'minutes_ago': 'minutes ago',
    'hours_ago': 'hours ago',
    'days_ago': 'days ago',
    'weeks_ago': 'weeks ago',
    'months_ago': 'months ago',
    'years_ago': 'years ago',
    'bytes': 'B',
    'kilobytes': 'KB',
    'megabytes': 'MB',
    'gigabytes': 'GB',
    'terabytes': 'TB',
  };

  // 日文文本
  static const Map<String, String> _japaneseTexts = {
    'app_name': 'クラウドドライブアシスタント',
    'ok': 'OK',
    'cancel': 'キャンセル',
    'confirm': '確認',
    'save': '保存',
    'delete': '削除',
    'edit': '編集',
    'add': '追加',
    'remove': '削除',
    'refresh': '更新',
    'retry': '再試行',
    'loading': '読み込み中...',
    'error': 'エラー',
    'success': '成功',
    'warning': '警告',
    'info': '情報',
    'cloud_drive_assistant': 'クラウドドライブアシスタント',
    'add_account': 'アカウント追加',
    'direct_link': 'ダイレクトリンク',
    'file_upload': 'ファイルアップロード',
    'settings': '設定',
    'quick_actions': 'クイックアクション',
    'account_management': 'アカウント管理',
    'select_account': 'アカウント選択',
    'hide_account_selector': 'アカウントセレクターを隠す',
    'show_account_selector': 'アカウントセレクターを表示',
    'account_name': 'アカウント名',
    'account_type': 'アカウントタイプ',
    'last_login': '最終ログイン',
    'account_status': 'アカウントステータス',
    'account_valid': 'アカウント有効',
    'account_invalid': 'アカウント無効',
    'file_operations': 'ファイル操作',
    'download': 'ダウンロード',
    'upload': 'アップロード',
    'rename': '名前変更',
    'move': '移動',
    'copy': 'コピー',
    'share': '共有',
    'preview': 'プレビュー',
    'file_list': 'ファイルリスト',
    'folder_list': 'フォルダリスト',
    'create_folder': 'フォルダ作成',
    'file_name': 'ファイル名',
    'file_size': 'ファイルサイズ',
    'file_type': 'ファイルタイプ',
    'modified_time': '変更時間',
    'file_path': 'ファイルパス',
    'batch_operations': '一括操作',
    'select_all': 'すべて選択',
    'deselect_all': '選択解除',
    'batch_download': '一括ダウンロード',
    'batch_delete': '一括削除',
    'batch_move': '一括移動',
    'batch_copy': '一括コピー',
    'selected_items': '選択項目',
    'baidu_cloud': '百度クラウド',
    'ali_cloud': 'アリクラウド',
    'lanzou_cloud': '藍奏クラウド',
    'pan123_cloud': '123クラウド',
    'quark_cloud': 'クォーククラウド',
    'unknown_cloud': '不明なクラウド',
    'connected': '接続済み',
    'disconnected': '切断済み',
    'connecting': '接続中...',
    'disconnecting': '切断中...',
    'online': 'オンライン',
    'offline': 'オフライン',
    'network_error': 'ネットワークエラー',
    'connection_timeout': '接続タイムアウト',
    'server_error': 'サーバーエラー',
    'authentication_error': '認証エラー',
    'file_not_found': 'ファイルが見つかりません',
    'permission_denied': '権限がありません',
    'storage_full': 'ストレージが満杯です',
    'invalid_file': '無効なファイル',
    'operation_failed': '操作に失敗しました',
    'unknown_error': '不明なエラー',
    'performance_monitor': 'パフォーマンスモニター',
    'system_info': 'システム情報',
    'memory_usage': 'メモリ使用量',
    'cpu_usage': 'CPU使用率',
    'disk_usage': 'ディスク使用率',
    'network_stats': 'ネットワーク統計',
    'api_calls': 'API呼び出し',
    'ui_rendering': 'UIレンダリング',
    'total_operations': '総操作数',
    'average_duration': '平均時間',
    'min_duration': '最小時間',
    'max_duration': '最大時間',
    'median_duration': '中央値時間',
    'error_rate': 'エラー率',
    'last_updated': '最終更新',
    'error_recovery': 'エラー回復',
    'retry_attempt': '再試行',
    'retry_failed': '再試行失敗',
    'retry_success': '再試行成功',
    'fallback_mode': 'フォールバックモード',
    'circuit_breaker_open': 'サーキットブレーカー開放',
    'operation_timeout': '操作タイムアウト',
    'general_settings': '一般設定',
    'language_settings': '言語設定',
    'theme_settings': 'テーマ設定',
    'performance_settings': 'パフォーマンス設定',
    'cache_settings': 'キャッシュ設定',
    'security_settings': 'セキュリティ設定',
    'about': 'について',
    'version': 'バージョン',
    'build_number': 'ビルド番号',
    'chinese': '中文',
    'english': 'English',
    'japanese': '日本語',
    'korean': '한국어',
    'light_theme': 'ライトテーマ',
    'dark_theme': 'ダークテーマ',
    'system_theme': 'システムテーマ',
    'just_now': 'たった今',
    'minutes_ago': '分前',
    'hours_ago': '時間前',
    'days_ago': '日前',
    'weeks_ago': '週前',
    'months_ago': '月前',
    'years_ago': '年前',
    'bytes': 'バイト',
    'kilobytes': 'KB',
    'megabytes': 'MB',
    'gigabytes': 'GB',
    'terabytes': 'TB',
  };

  // 韩文文本
  static const Map<String, String> _koreanTexts = {
    'app_name': '클라우드 드라이브 어시스턴트',
    'ok': '확인',
    'cancel': '취소',
    'confirm': '확인',
    'save': '저장',
    'delete': '삭제',
    'edit': '편집',
    'add': '추가',
    'remove': '제거',
    'refresh': '새로고침',
    'retry': '재시도',
    'loading': '로딩 중...',
    'error': '오류',
    'success': '성공',
    'warning': '경고',
    'info': '정보',
    'cloud_drive_assistant': '클라우드 드라이브 어시스턴트',
    'add_account': '계정 추가',
    'direct_link': '직접 링크',
    'file_upload': '파일 업로드',
    'settings': '설정',
    'quick_actions': '빠른 작업',
    'account_management': '계정 관리',
    'select_account': '계정 선택',
    'hide_account_selector': '계정 선택기 숨기기',
    'show_account_selector': '계정 선택기 표시',
    'account_name': '계정 이름',
    'account_type': '계정 유형',
    'last_login': '마지막 로그인',
    'account_status': '계정 상태',
    'account_valid': '계정 유효',
    'account_invalid': '계정 무효',
    'file_operations': '파일 작업',
    'download': '다운로드',
    'upload': '업로드',
    'rename': '이름 바꾸기',
    'move': '이동',
    'copy': '복사',
    'share': '공유',
    'preview': '미리보기',
    'file_list': '파일 목록',
    'folder_list': '폴더 목록',
    'create_folder': '폴더 만들기',
    'file_name': '파일 이름',
    'file_size': '파일 크기',
    'file_type': '파일 유형',
    'modified_time': '수정 시간',
    'file_path': '파일 경로',
    'batch_operations': '일괄 작업',
    'select_all': '모두 선택',
    'deselect_all': '선택 해제',
    'batch_download': '일괄 다운로드',
    'batch_delete': '일괄 삭제',
    'batch_move': '일괄 이동',
    'batch_copy': '일괄 복사',
    'selected_items': '선택된 항목',
    'baidu_cloud': '바이두 클라우드',
    'ali_cloud': '알리 클라우드',
    'lanzou_cloud': '란조우 클라우드',
    'pan123_cloud': '123 클라우드',
    'quark_cloud': '쿼크 클라우드',
    'unknown_cloud': '알 수 없는 클라우드',
    'connected': '연결됨',
    'disconnected': '연결 끊김',
    'connecting': '연결 중...',
    'disconnecting': '연결 해제 중...',
    'online': '온라인',
    'offline': '오프라인',
    'network_error': '네트워크 오류',
    'connection_timeout': '연결 시간 초과',
    'server_error': '서버 오류',
    'authentication_error': '인증 오류',
    'file_not_found': '파일을 찾을 수 없음',
    'permission_denied': '권한이 없음',
    'storage_full': '저장 공간 부족',
    'invalid_file': '잘못된 파일',
    'operation_failed': '작업 실패',
    'unknown_error': '알 수 없는 오류',
    'performance_monitor': '성능 모니터',
    'system_info': '시스템 정보',
    'memory_usage': '메모리 사용량',
    'cpu_usage': 'CPU 사용률',
    'disk_usage': '디스크 사용률',
    'network_stats': '네트워크 통계',
    'api_calls': 'API 호출',
    'ui_rendering': 'UI 렌더링',
    'total_operations': '총 작업 수',
    'average_duration': '평균 시간',
    'min_duration': '최소 시간',
    'max_duration': '최대 시간',
    'median_duration': '중간값 시간',
    'error_rate': '오류율',
    'last_updated': '마지막 업데이트',
    'error_recovery': '오류 복구',
    'retry_attempt': '재시도',
    'retry_failed': '재시도 실패',
    'retry_success': '재시도 성공',
    'fallback_mode': '폴백 모드',
    'circuit_breaker_open': '회로 차단기 열림',
    'operation_timeout': '작업 시간 초과',
    'general_settings': '일반 설정',
    'language_settings': '언어 설정',
    'theme_settings': '테마 설정',
    'performance_settings': '성능 설정',
    'cache_settings': '캐시 설정',
    'security_settings': '보안 설정',
    'about': '정보',
    'version': '버전',
    'build_number': '빌드 번호',
    'chinese': '中文',
    'english': 'English',
    'japanese': '日本語',
    'korean': '한국어',
    'light_theme': '라이트 테마',
    'dark_theme': '다크 테마',
    'system_theme': '시스템 테마',
    'just_now': '방금 전',
    'minutes_ago': '분 전',
    'hours_ago': '시간 전',
    'days_ago': '일 전',
    'weeks_ago': '주 전',
    'months_ago': '개월 전',
    'years_ago': '년 전',
    'bytes': '바이트',
    'kilobytes': 'KB',
    'megabytes': 'MB',
    'gigabytes': 'GB',
    'terabytes': 'TB',
  };
}

/// 本地化委托
class _CloudDriveLocalizationsDelegate
    extends LocalizationsDelegate<CloudDriveLocalizations> {
  const _CloudDriveLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en', 'ja', 'ko'].contains(locale.languageCode);
  }

  @override
  Future<CloudDriveLocalizations> load(Locale locale) async {
    return CloudDriveLocalizations(locale);
  }

  @override
  bool shouldReload(_CloudDriveLocalizationsDelegate old) => false;
}
