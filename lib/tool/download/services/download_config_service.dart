import 'dart:io';
import 'dart:convert'; // Added for jsonDecode

import '../../../core/services/base/debug_service.dart';
import 'download_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 下载配置模型
class DownloadConfig {
  final String downloadDirectory; // ✅ 已实现并使用
  final int maxConcurrentDownloads; // TODO: 未实现 - flutter_downloader 有自己的并发控制机制
  final bool downloadOnWifiOnly; // TODO: 未实现 - 需要添加网络类型检查逻辑
  final bool downloadOnMobileNetwork; // TODO: 未实现 - 需要添加网络类型检查逻辑
  final bool showNotification; // ✅ 已实现并使用
  final bool openFileFromNotification; // ✅ 已实现并使用
  final bool autoRetry; // ⚠️ 部分实现 - 配置已保存但重试逻辑需要完善
  final int retryCount; // ⚠️ 部分实现 - 配置已保存但重试逻辑需要完善
  final int retryDelay; // ⚠️ 部分实现 - 配置已保存但重试逻辑需要完善
  final bool enableResume; // TODO: 未实现 - flutter_downloader 自动处理续传
  final int downloadTimeout; // ⚠️ 部分实现 - 需要确认 flutter_downloader 是否支持
  final bool enableSpeedLimit; // ⚠️ 部分实现 - 需要确认 flutter_downloader 是否支持速度限制
  final int speedLimit; // ⚠️ 部分实现 - 需要确认 flutter_downloader 是否支持速度限制
  final Map<String, String> customHeaders; // ✅ 新增 - 支持自定义请求头

  DownloadConfig({
    required this.downloadDirectory,
    required this.maxConcurrentDownloads,
    required this.downloadOnWifiOnly,
    required this.downloadOnMobileNetwork,
    required this.showNotification,
    required this.openFileFromNotification,
    required this.autoRetry,
    required this.retryCount,
    required this.retryDelay,
    required this.enableResume,
    required this.downloadTimeout,
    required this.enableSpeedLimit,
    required this.speedLimit,
    this.customHeaders = const {}, // 默认为空
  });

  /// 从JSON创建配置
  factory DownloadConfig.fromJson(Map<String, dynamic> json) {
    return DownloadConfig(
      downloadDirectory: json['download_directory'] ?? '',
      maxConcurrentDownloads: json['max_concurrent_downloads'] ?? 3,
      downloadOnWifiOnly: json['download_on_wifi_only'] ?? true,
      downloadOnMobileNetwork: json['download_on_mobile_network'] ?? false,
      showNotification: json['show_notification'] ?? true,
      openFileFromNotification: json['open_file_from_notification'] ?? true,
      autoRetry: json['auto_retry'] ?? true,
      retryCount: json['retry_count'] ?? 3,
      retryDelay: json['retry_delay'] ?? 5,
      enableResume: json['enable_resume'] ?? true,
      downloadTimeout: json['download_timeout'] ?? 30,
      enableSpeedLimit: json['enable_speed_limit'] ?? false,
      speedLimit: json['speed_limit'] ?? 1024 * 1024,
      customHeaders: _parseCustomHeaders(json['custom_headers']),
    );
  }

  /// 解析自定义请求头
  static Map<String, String> _parseCustomHeaders(dynamic headersData) {
    if (headersData == null) return const {};

    if (headersData is Map) {
      return headersData.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    if (headersData is String) {
      try {
        final Map<String, dynamic> parsed = jsonDecode(headersData);
        return parsed.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      } catch (e) {
        DebugService.error('❌ 解析自定义请求头失败: $e', null);
        return const {};
      }
    }

    return const {};
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'download_directory': downloadDirectory,
    'max_concurrent_downloads': maxConcurrentDownloads,
    'download_on_wifi_only': downloadOnWifiOnly,
    'download_on_mobile_network': downloadOnMobileNetwork,
    'show_notification': showNotification,
    'open_file_from_notification': openFileFromNotification,
    'auto_retry': autoRetry,
    'retry_count': retryCount,
    'retry_delay': retryDelay,
    'enable_resume': enableResume,
    'download_timeout': downloadTimeout,
    'enable_speed_limit': enableSpeedLimit,
    'speed_limit': speedLimit,
    'custom_headers': customHeaders,
  };

  /// 复制并更新配置
  DownloadConfig copyWith({
    String? downloadDirectory,
    int? maxConcurrentDownloads,
    bool? downloadOnWifiOnly,
    bool? downloadOnMobileNetwork,
    bool? showNotification,
    bool? openFileFromNotification,
    bool? autoRetry,
    int? retryCount,
    int? retryDelay,
    bool? enableResume,
    int? downloadTimeout,
    bool? enableSpeedLimit,
    int? speedLimit,
    Map<String, String>? customHeaders,
  }) => DownloadConfig(
    downloadDirectory: downloadDirectory ?? this.downloadDirectory,
    maxConcurrentDownloads:
        maxConcurrentDownloads ?? this.maxConcurrentDownloads,
    downloadOnWifiOnly: downloadOnWifiOnly ?? this.downloadOnWifiOnly,
    downloadOnMobileNetwork:
        downloadOnMobileNetwork ?? this.downloadOnMobileNetwork,
    showNotification: showNotification ?? this.showNotification,
    openFileFromNotification:
        openFileFromNotification ?? this.openFileFromNotification,
    autoRetry: autoRetry ?? this.autoRetry,
    retryCount: retryCount ?? this.retryCount,
    retryDelay: retryDelay ?? this.retryDelay,
    enableResume: enableResume ?? this.enableResume,
    downloadTimeout: downloadTimeout ?? this.downloadTimeout,
    enableSpeedLimit: enableSpeedLimit ?? this.enableSpeedLimit,
    speedLimit: speedLimit ?? this.speedLimit,
    customHeaders: customHeaders ?? this.customHeaders,
  );
}

/// 下载配置服务类 - 负责配置的加载和保存
class DownloadConfigService {
  static final DownloadConfigService _instance =
      DownloadConfigService._internal();
  factory DownloadConfigService() => _instance;
  DownloadConfigService._internal();

  /// 加载配置
  Future<DownloadConfig> loadConfig() async {
    try {
      DebugService.log('📋 开始加载下载配置');

      final prefs = await SharedPreferences.getInstance();

      // 获取保存的下载目录，如果没有保存过则使用默认目录
      String? savedDirectory = prefs.getString('download_directory');
      String downloadDirectory;

      if (savedDirectory == null || savedDirectory.isEmpty) {
        // 如果没有保存过目录，使用默认目录
        downloadDirectory = await _initializeDefaultDirectory();
        DebugService.log('📁 使用默认下载目录: $downloadDirectory');
      } else {
        downloadDirectory = savedDirectory;
        DebugService.log('📁 使用保存的下载目录: $downloadDirectory');
      }

      final config = DownloadConfig(
        downloadDirectory: downloadDirectory,
        maxConcurrentDownloads: prefs.getInt('max_concurrent_downloads') ?? 3,
        downloadOnWifiOnly: prefs.getBool('download_on_wifi_only') ?? true,
        downloadOnMobileNetwork:
            prefs.getBool('download_on_mobile_network') ?? false,
        showNotification: prefs.getBool('show_notification') ?? true,
        openFileFromNotification:
            prefs.getBool('open_file_from_notification') ?? true,
        autoRetry: prefs.getBool('auto_retry') ?? true,
        retryCount: prefs.getInt('retry_count') ?? 3,
        retryDelay: prefs.getInt('retry_delay') ?? 5,
        enableResume: prefs.getBool('enable_resume') ?? true,
        downloadTimeout: prefs.getInt('download_timeout') ?? 30,
        enableSpeedLimit: prefs.getBool('enable_speed_limit') ?? false,
        speedLimit: prefs.getInt('speed_limit') ?? 1024 * 1024,
        customHeaders: _parseCustomHeaders(prefs.getString('custom_headers')),
      );

      DebugService.success('✅ 配置加载完成');
      return config;
    } catch (e) {
      DebugService.error('❌ 加载配置失败', e);
      return await _getDefaultConfig();
    }
  }

  /// 保存配置
  Future<bool> saveConfig(DownloadConfig config) async {
    try {
      DebugService.log('💾 开始保存下载配置');

      final prefs = await SharedPreferences.getInstance();
      final json = config.toJson();

      // 保存所有配置项
      await prefs.setString('download_directory', json['download_directory']);
      await prefs.setInt(
        'max_concurrent_downloads',
        json['max_concurrent_downloads'],
      );
      await prefs.setBool(
        'download_on_wifi_only',
        json['download_on_wifi_only'],
      );
      await prefs.setBool(
        'download_on_mobile_network',
        json['download_on_mobile_network'],
      );
      await prefs.setBool('show_notification', json['show_notification']);
      await prefs.setBool(
        'open_file_from_notification',
        json['open_file_from_notification'],
      );
      await prefs.setBool('auto_retry', json['auto_retry']);
      await prefs.setInt('retry_count', json['retry_count']);
      await prefs.setInt('retry_delay', json['retry_delay']);
      await prefs.setBool('enable_resume', json['enable_resume']);
      await prefs.setInt('download_timeout', json['download_timeout']);
      await prefs.setBool('enable_speed_limit', json['enable_speed_limit']);
      await prefs.setInt('speed_limit', json['speed_limit']);
      await prefs.setString(
        'custom_headers',
        jsonEncode(config.customHeaders), // 直接使用 config.customHeaders
      );

      DebugService.success('✅ 配置保存完成');
      return true;
    } catch (e) {
      DebugService.error('❌ 保存配置失败', e);
      return false;
    }
  }

  /// 获取默认配置
  Future<DownloadConfig> _getDefaultConfig() async {
    DebugService.log('📋 使用默认配置');
    final defaultDirectory = await _initializeDefaultDirectory();

    return DownloadConfig(
      downloadDirectory: defaultDirectory,
      maxConcurrentDownloads: 3,
      downloadOnWifiOnly: true,
      downloadOnMobileNetwork: false,
      showNotification: true,
      openFileFromNotification: true,
      autoRetry: true,
      retryCount: 3,
      retryDelay: 5,
      enableResume: true,
      downloadTimeout: 30,
      enableSpeedLimit: false,
      speedLimit: 1024 * 1024,
      customHeaders: const {},
    );
  }

  /// 解析自定义请求头
  Map<String, String> _parseCustomHeaders(String? headersData) {
    if (headersData == null || headersData.isEmpty) return const {};

    try {
      final Map<String, dynamic> parsed = jsonDecode(headersData);
      return parsed.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (e) {
      DebugService.error('❌ 解析自定义请求头失败: $e', null);
      return const {};
    }
  }

  /// 初始化默认目录
  Future<String> _initializeDefaultDirectory() async {
    try {
      // 优先使用外部存储目录
      const defaultDir = '/storage/emulated/0/Download/coco';

      // 检查外部存储是否可用
      try {
        final dir = Directory(defaultDir);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        // 测试写入权限
        final testFile = File('$defaultDir/test_write.tmp');
        await testFile.writeAsString('test');
        await testFile.delete();

        DebugService.log('✅ 外部存储目录可用: $defaultDir');
        return defaultDir;
      } catch (e) {
        DebugService.log('⚠️ 外部存储不可用，使用内部存储');
      }

      // 如果外部存储不可用，使用应用内部存储
      final appDir = await getApplicationDocumentsDirectory();
      final internalDir = '${appDir.path}/downloads';

      final dir = Directory(internalDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      DebugService.log('✅ 使用内部存储目录: $internalDir');
      return internalDir;
    } catch (e) {
      DebugService.error('❌ 初始化默认目录失败', e);
      return '/storage/emulated/0/Download/coco';
    }
  }

  /// 格式化速度限制显示
  String formatSpeedLimit(int bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '$bytesPerSecond B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  /// 检查网络条件
  Future<bool> checkNetworkConditions(DownloadConfig config) async {
    // 这里应该使用 connectivity_plus 包来检查网络类型
    // 为了简化，暂时返回 true
    return true;
  }

  /// 获取有效的保存路径（供其他功能使用）
  static Future<String> getValidSavePath() async {
    try {
      DebugService.log('🔍 获取有效的保存路径');

      // 获取下载配置
      final configService = DownloadConfigService();
      final config = await configService.loadConfig();

      // 使用下载服务验证路径
      final downloadService = DownloadService();
      final validPath = await downloadService.getValidDownloadDirectory(
        config.downloadDirectory,
      );

      DebugService.log('✅ 有效保存路径: $validPath');
      return validPath;
    } catch (e) {
      DebugService.error('❌ 获取保存路径失败', e);
      // 回退到应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      return '${appDir.path}/downloads';
    }
  }

  /// 获取保存路径的显示名称
  static Future<String> getSavePathDisplayName() async {
    try {
      final savePath = await getValidSavePath();

      // 如果是外部存储路径，显示友好的名称
      if (savePath.startsWith('/storage/emulated/0/Download/')) {
        final pathParts = savePath.split('/');
        if (pathParts.length > 5) {
          final subDir = pathParts.sublist(5).join('/');
          return 'Download/$subDir';
        }
        return 'Download';
      } else if (savePath.startsWith('/storage/emulated/0/')) {
        return '外部存储';
      } else {
        return '应用内部存储';
      }
    } catch (e) {
      return '应用内部存储';
    }
  }
}
