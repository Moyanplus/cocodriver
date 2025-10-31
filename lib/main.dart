/// 可可云盘应用主入口文件
///
/// 这是一个第三方聚合云盘客户端，支持百度网盘、阿里云盘、夸克云盘、蓝奏云盘等
/// 主要功能包括文件管理、上传下载、多平台适配等
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

// 核心模块导入
import 'core/navigation/navigation_providers.dart';
import 'core/providers/localization_providers.dart';
import 'core/utils/memory_manager.dart';
import 'core/utils/performance_monitor.dart';
import 'core/di/injection_container.dart' as di;

// 功能模块导入
import 'features/app/pages/main_screen_page.dart';
import 'features/settings/pages/settings_page.dart';
import 'features/settings/pages/theme_settings_page.dart';
import 'features/settings/pages/language_settings_page.dart';

// 国际化支持
import 'l10n/app_localizations.dart';

// 测试页面（仅在debug模式使用）
import 'test/pages/webview_test_page.dart';

// 云盘服务注册
import 'tool/cloud_drive/services/services_registry.dart';

// 下载管理器
import 'tool/download/pages/download_manager_page.dart';

/// 应用程序主入口函数
///
/// 负责初始化应用程序的核心组件和服务
/// 包括依赖注入、云盘服务、性能监控等
void main() async {
  // 确保Flutter绑定系统已初始化
  // 这是使用Flutter异步功能的前提条件
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化下载器插件
  // 必须在使用下载功能之前初始化
  await FlutterDownloader.initialize(
    debug: kDebugMode, // 在调试模式下启用日志
    ignoreSsl: false, // 不忽略SSL证书验证
  );

  // 初始化依赖注入容器
  // 注册所有需要的服务和依赖
  await di.init();

  // 初始化云盘服务注册表
  // 注册各种云盘服务（百度、阿里、夸克等）
  CloudDriveServicesRegistry.initialize();

  // 启动内存监控服务
  // 监控应用内存使用情况，防止内存泄漏
  di.get<MemoryManager>().startMonitoring();

  // 启动性能监控服务（暂时关闭以减少日志输出）
  // di.get<PerformanceMonitor>().startMonitoring();

  // 启动应用程序
  runApp(const AppProviders(child: MyApp()));
}

/// 应用程序主Widget
///
/// 使用Riverpod进行状态管理，负责配置应用程序的全局设置
/// 包括主题、国际化、路由等核心配置
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

/// MyApp的状态管理类
///
/// 负责监听主题和语言变化，构建应用程序的UI结构
class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    // 使用 Riverpod 监听主题数据和语言数据的变化
    final themeData = ref.watch(themeDataProvider);
    final currentLocale = ref.watch(currentLocaleProvider);

    return ScreenUtilInit(
      // 设计稿尺寸（使用 iPhone 14 Pro 的尺寸作为基准）
      // 用于屏幕适配，确保在不同设备上显示一致
      designSize: const Size(393, 852),
      minTextAdapt: true, // 允许文字大小自适应
      splitScreenMode: true, // 支持分屏模式
      builder: (context, child) {
        return MaterialApp(
          title: '可可云盘',
          theme: themeData, // 应用主题
          locale: currentLocale, // 当前语言设置
          supportedLocales: AppLocalizations.supportedLocales, // 支持的语言列表
          localizationsDelegates: const [
            AppLocalizations.delegate, // 应用自定义本地化
            GlobalMaterialLocalizations.delegate, // Material Design本地化
            GlobalWidgetsLocalizations.delegate, // Flutter Widget本地化
            GlobalCupertinoLocalizations.delegate, // Cupertino本地化
          ],
          home: const MainScreen(), // 主页面
          debugShowCheckedModeBanner: false, // 隐藏debug横幅
          routes: {
            // 设置页面路由
            '/settings': (context) => const SettingsPage(),
            '/settings/theme': (context) => const ThemeSettingsPage(),
            '/settings/language': (context) => const LanguageSettingsPage(),
            // 下载管理器路由
            '/download/manager': (context) => const DownloadManagerPage(),
            // 测试页面路由（仅在debug模式可用）
            if (kDebugMode) '/test/webview': (context) => WebViewTestPage(),
          },
          // 全局UI配置：禁用系统字体缩放
          builder:
              (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              ),
        );
      },
    );
  }
}
