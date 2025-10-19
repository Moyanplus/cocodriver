import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/navigation/navigation_providers.dart';
import 'core/providers/localization_providers.dart';
import 'core/utils/memory_manager.dart';
import 'core/utils/performance_monitor.dart';
import 'core/di/injection_container.dart' as di;
import 'features/app/pages/main_screen_page.dart';
import 'features/settings/pages/settings_page.dart';
import 'features/settings/pages/theme_settings_page.dart';
import 'features/settings/pages/language_settings_page.dart';
import 'l10n/app_localizations.dart';
import 'test/pages/webview_test_page.dart';
import 'tool/cloud_drive/services/services_registry.dart';

void main() async {
  // 确保Flutter绑定系统已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化依赖注入
  await di.init();

  // 初始化云盘服务
  CloudDriveServicesRegistry.initialize();

  // 启动性能监控
  di.get<MemoryManager>().startMonitoring();
  // di.get<PerformanceMonitor>().startMonitoring(); // 暂时关闭性能监控日志

  runApp(const AppProviders(child: MyApp()));
}

/// 应用主入口
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    // 使用 Riverpod 获取主题数据和语言数据
    final themeData = ref.watch(themeDataProvider);
    final currentLocale = ref.watch(currentLocaleProvider);

    return ScreenUtilInit(
      // 设计稿尺寸（使用 iPhone 14 Pro 的尺寸作为基准）
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: '可可云盘',
          theme: themeData,
          locale: currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MainScreen(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/settings': (context) => const SettingsPage(),
            '/settings/theme': (context) => const ThemeSettingsPage(),
            '/settings/language': (context) => const LanguageSettingsPage(),
            // 测试页面路由（仅在debug模式可用）
            if (kDebugMode)
              '/test/webview': (context) => const WebViewTestPage(),
          },
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
