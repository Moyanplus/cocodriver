import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/providers/app_providers.dart';
import 'core/providers/theme_provider.dart';
import 'presentation/pages/main_screen_page.dart';
import 'features/settings/pages/settings_page.dart';
import 'features/settings/pages/theme_settings_page.dart';

void main() {
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
    // 使用 Riverpod 获取主题数据
    final themeData = ref.watch(themeDataProvider);

    return ScreenUtilInit(
      // 设计稿尺寸（使用 iPhone 14 Pro 的尺寸作为基准）
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Flutter UI模板',
          theme: themeData,
          locale: const Locale('zh'),
          supportedLocales: const [Locale('zh'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MainScreen(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/settings': (context) => const SettingsPage(),
            '/settings/theme': (context) => const ThemeSettingsPage(),
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
