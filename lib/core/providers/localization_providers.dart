/// 本地化状态管理提供者
///
/// 使用Riverpod管理应用程序的多语言状态
/// 提供语言切换和本地化状态管理功能
///
/// 主要功能：
/// - 本地化状态管理
/// - 语言切换功能
/// - 支持的语言列表
/// - 语言设置持久化
/// - 状态通知机制
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/localization_service.dart';

/// 本地化状态类
///
/// 表示应用程序的本地化状态，包括当前语言和加载状态
class LocalizationState {
  /// 当前语言
  final Locale currentLocale;

  /// 是否正在加载
  final bool isLoading;

  LocalizationState({required this.currentLocale, this.isLoading = false});

  LocalizationState copyWith({Locale? currentLocale, bool? isLoading}) {
    return LocalizationState(
      currentLocale: currentLocale ?? this.currentLocale,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 本地化状态管理器
class LocalizationNotifier extends StateNotifier<LocalizationState> {
  final LocalizationService _localizationService;

  LocalizationNotifier(this._localizationService)
    : super(
        LocalizationState(currentLocale: _localizationService.currentLocale),
      ) {
    _loadLocale();
  }

  /// 加载保存的语言
  Future<void> _loadLocale() async {
    state = state.copyWith(isLoading: true);
    try {
      final locale = await _localizationService.loadLocale();
      state = state.copyWith(currentLocale: locale, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 设置语言
  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(isLoading: true);
    try {
      await _localizationService.setLocale(locale);
      state = state.copyWith(currentLocale: locale, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 重置为默认语言
  Future<void> resetToDefault() async {
    await setLocale(LocalizationService.defaultLocale);
  }

  /// 获取支持的语言列表
  List<Locale> get supportedLocales => LocalizationService.supportedLocales;

  /// 获取语言显示名称
  String getLanguageName(Locale locale) {
    return _localizationService.getLanguageName(locale);
  }

  /// 检查是否为中文
  bool get isChinese => _localizationService.isChinese;

  /// 检查是否为英文
  bool get isEnglish => _localizationService.isEnglish;
}

/// 本地化提供者
final localizationProvider =
    StateNotifierProvider<LocalizationNotifier, LocalizationState>((ref) {
      return LocalizationNotifier(LocalizationService());
    });

/// 当前语言提供者
final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(localizationProvider).currentLocale;
});

/// 本地化服务提供者
final localizationServiceProvider = Provider<LocalizationService>((ref) {
  return LocalizationService();
});

/// 支持的语言列表提供者
final supportedLocalesProvider = Provider<List<Locale>>((ref) {
  return LocalizationService.supportedLocales;
});

/// 语言切换提供者
final localizationNotifierProvider = Provider<LocalizationNotifier>((ref) {
  return ref.watch(localizationProvider.notifier);
});
