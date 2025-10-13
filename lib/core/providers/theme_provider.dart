import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/theme_service.dart';

/// 主题状态
class ThemeState {
  final ThemeType currentTheme;
  final ThemeData themeData;

  ThemeState({required this.currentTheme, required this.themeData});

  ThemeState copyWith({ThemeType? currentTheme, ThemeData? themeData}) {
    return ThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      themeData: themeData ?? this.themeData,
    );
  }
}

/// 主题提供者
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
    : super(
        ThemeState(
          currentTheme: ThemeType.system,
          themeData: ThemeService().getTheme(ThemeType.system),
        ),
      ) {
    _loadTheme();
  }

  /// 加载保存的主题
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = prefs.getString('selected_theme');

      if (themeName != null) {
        final themeType = ThemeType.values.firstWhere(
          (type) => type.name == themeName,
          orElse: () => ThemeType.system,
        );
        _setTheme(themeType);
      }
    } catch (e) {
      // 加载主题失败，使用默认主题
    }
  }

  /// 设置主题
  Future<void> setTheme(ThemeType themeType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_theme', themeType.name);
      _setTheme(themeType);
    } catch (e) {
      // 保存主题失败，继续使用当前主题
    }
  }

  /// 内部设置主题
  void _setTheme(ThemeType themeType) {
    final themeService = ThemeService();
    themeService.setTheme(themeType);
    final themeData = themeService.getTheme(themeType);

    state = state.copyWith(currentTheme: themeType, themeData: themeData);
  }
}

/// 主题提供者
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

/// 当前主题数据提供者
final themeDataProvider = Provider<ThemeData>((ref) {
  return ref.watch(themeProvider).themeData;
});

/// 当前主题类型提供者
final currentThemeProvider = Provider<ThemeType>((ref) {
  return ref.watch(themeProvider).currentTheme;
});
