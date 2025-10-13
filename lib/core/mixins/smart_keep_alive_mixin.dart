import 'package:flutter/material.dart';

/// 智能KeepAlive混入
/// 根据页面使用频率动态管理KeepAlive状态
mixin SmartKeepAliveClientMixin<T extends StatefulWidget> on State<T> {
  static final Map<Type, int> _accessCount = {};
  static final Map<Type, DateTime> _lastAccess = {};
  static final Map<Type, bool> _isActive = {};
  static const int _maxKeepAlivePages = 2;
  static const Duration _accessTimeout = Duration(minutes: 5);
  static const Duration _inactiveTimeout = Duration(minutes: 10);

  bool get wantKeepAlive {
    final now = DateTime.now();
    final lastAccess = _lastAccess[widget.runtimeType];

    // 如果超过非活跃超时时间，标记为非活跃
    if (lastAccess != null && now.difference(lastAccess) > _inactiveTimeout) {
      _isActive[widget.runtimeType] = false;
      return false;
    }

    // 如果超过访问超时时间，重置访问计数
    if (lastAccess != null && now.difference(lastAccess) > _accessTimeout) {
      _accessCount[widget.runtimeType] = 0;
    }

    final count = _accessCount[widget.runtimeType] ?? 0;
    final activePages = _getActivePages();

    // 如果访问次数大于0且活跃页面数量未达到上限，则保持活跃
    final shouldKeepAlive =
        count > 0 && activePages.length < _maxKeepAlivePages;
    _isActive[widget.runtimeType] = shouldKeepAlive;

    return shouldKeepAlive;
  }

  @override
  void initState() {
    super.initState();
    _markAccess();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _markAccess();
  }

  /// 标记页面访问
  void _markAccess() {
    final now = DateTime.now();
    _accessCount[widget.runtimeType] =
        (_accessCount[widget.runtimeType] ?? 0) + 1;
    _lastAccess[widget.runtimeType] = now;
  }

  /// 获取当前活跃的页面类型
  List<Type> _getActivePages() {
    final now = DateTime.now();
    return _lastAccess.entries
        .where(
          (entry) =>
              _accessCount[entry.key] != null &&
              _accessCount[entry.key]! > 0 &&
              (_isActive[entry.key] ?? false) &&
              now.difference(entry.value) <= _inactiveTimeout,
        )
        .map((entry) => entry.key)
        .toList();
  }

  /// 清除指定页面的KeepAlive状态
  static void clearKeepAlive(Type pageType) {
    _accessCount[pageType] = 0;
    _lastAccess.remove(pageType);
    _isActive[pageType] = false;
  }

  /// 清除所有KeepAlive状态
  static void clearAllKeepAlive() {
    _accessCount.clear();
    _lastAccess.clear();
    _isActive.clear();
  }

  /// 强制激活指定页面
  static void forceActivate(Type pageType) {
    _accessCount[pageType] = 999; // 设置高访问次数
    _lastAccess[pageType] = DateTime.now();
    _isActive[pageType] = true;
  }

  /// 强制停用指定页面
  static void forceDeactivate(Type pageType) {
    _isActive[pageType] = false;
  }

  /// 获取当前KeepAlive统计信息
  static Map<String, dynamic> getKeepAliveStats() {
    final now = DateTime.now();
    final activePages = <String, Map<String, dynamic>>{};

    for (final entry in _accessCount.entries) {
      final pageType = entry.key.toString();
      final count = entry.value;
      final lastAccess = _lastAccess[entry.key];

      if (count > 0 && lastAccess != null) {
        final timeSinceAccess = now.difference(lastAccess);
        activePages[pageType] = {
          'accessCount': count,
          'lastAccess': lastAccess,
          'timeSinceAccess': timeSinceAccess,
          'isActive': timeSinceAccess <= _accessTimeout,
        };
      }
    }

    return {
      'activePages': activePages,
      'maxKeepAlivePages': _maxKeepAlivePages,
      'accessTimeout': _accessTimeout,
      'inactiveTimeout': _inactiveTimeout,
      'totalPages': _accessCount.length,
    };
  }
}
