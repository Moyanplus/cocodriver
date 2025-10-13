import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:platform/platform.dart';

/// 平台检测工具类
/// 提供统一的平台检测和设备信息获取方法
class PlatformUtils {
  PlatformUtils._();

  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static final Platform _platform = const LocalPlatform();

  // ==================== 平台检测 ====================

  /// 是否为Android平台
  static bool get isAndroid => _platform.isAndroid;

  /// 是否为iOS平台
  static bool get isIOS => _platform.isIOS;

  /// 是否为Web平台
  static bool get isWeb => kIsWeb;

  /// 是否为Windows平台
  static bool get isWindows => _platform.isWindows;

  /// 是否为macOS平台
  static bool get isMacOS => _platform.isMacOS;

  /// 是否为Linux平台
  static bool get isLinux => _platform.isLinux;

  /// 是否为桌面平台
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  /// 是否为移动平台
  static bool get isMobile => isAndroid || isIOS;

  /// 是否为移动端或Web端
  static bool get isMobileOrWeb => isMobile || isWeb;

  // ==================== 设备信息 ====================

  /// 获取设备信息
  static Future<BaseDeviceInfo> getDeviceInfo() async {
    if (isWeb) {
      return await _deviceInfo.webBrowserInfo;
    } else if (isAndroid) {
      return await _deviceInfo.androidInfo;
    } else if (isIOS) {
      return await _deviceInfo.iosInfo;
    } else if (isWindows) {
      return await _deviceInfo.windowsInfo;
    } else if (isMacOS) {
      return await _deviceInfo.macOsInfo;
    } else if (isLinux) {
      return await _deviceInfo.linuxInfo;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// 获取设备名称
  static Future<String> getDeviceName() async {
    final deviceInfo = await getDeviceInfo();
    if (deviceInfo is AndroidDeviceInfo) {
      return deviceInfo.model;
    } else if (deviceInfo is IosDeviceInfo) {
      return deviceInfo.name;
    } else if (deviceInfo is WebBrowserInfo) {
      return deviceInfo.browserName.name;
    } else if (deviceInfo is WindowsDeviceInfo) {
      return deviceInfo.computerName;
    } else if (deviceInfo is MacOsDeviceInfo) {
      return deviceInfo.computerName;
    } else if (deviceInfo is LinuxDeviceInfo) {
      return deviceInfo.name;
    }
    return 'Unknown Device';
  }

  /// 获取系统版本
  static Future<String> getSystemVersion() async {
    final deviceInfo = await getDeviceInfo();
    if (deviceInfo is AndroidDeviceInfo) {
      return 'Android ${deviceInfo.version.release}';
    } else if (deviceInfo is IosDeviceInfo) {
      return 'iOS ${deviceInfo.systemVersion}';
    } else if (deviceInfo is WebBrowserInfo) {
      return '${deviceInfo.browserName.name} ${deviceInfo.appVersion}';
    } else if (deviceInfo is WindowsDeviceInfo) {
      return 'Windows ${deviceInfo.displayVersion}';
    } else if (deviceInfo is MacOsDeviceInfo) {
      return 'macOS ${deviceInfo.majorVersion}.${deviceInfo.minorVersion}';
    } else if (deviceInfo is LinuxDeviceInfo) {
      return 'Linux ${deviceInfo.version}';
    }
    return 'Unknown Version';
  }

  // ==================== 平台特定配置 ====================

  /// 获取平台特定的主题数据
  static ThemeData getPlatformTheme({
    required ThemeData lightTheme,
    required ThemeData darkTheme,
    required bool isDarkMode,
  }) {
    final baseTheme = isDarkMode ? darkTheme : lightTheme;

    if (isIOS) {
      return baseTheme.copyWith(
        platform: TargetPlatform.iOS,
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
      );
    } else if (isAndroid) {
      return baseTheme.copyWith(platform: TargetPlatform.android);
    } else if (isWeb) {
      return baseTheme.copyWith(platform: TargetPlatform.fuchsia);
    }

    return baseTheme;
  }

  /// 获取平台特定的导航栏高度
  static double getNavigationBarHeight(BuildContext context) {
    if (isIOS) {
      return 83.0; // iOS导航栏高度
    } else if (isAndroid) {
      return 56.0; // Android导航栏高度
    } else if (isWeb) {
      return 60.0; // Web导航栏高度
    } else if (isDesktop) {
      return 48.0; // 桌面导航栏高度
    }
    return 56.0;
  }

  /// 获取平台特定的底部安全区域
  static double getBottomSafeArea(BuildContext context) {
    if (isIOS) {
      return MediaQuery.of(context).padding.bottom;
    } else if (isAndroid) {
      return MediaQuery.of(context).padding.bottom;
    }
    return 0.0;
  }

  /// 获取平台特定的状态栏高度
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  // ==================== 平台特定行为 ====================

  /// 是否支持Material Design
  static bool get supportsMaterialDesign => isAndroid || isWeb || isDesktop;

  /// 是否支持Cupertino Design
  static bool get supportsCupertinoDesign => isIOS;

  /// 是否支持手势导航
  static bool get supportsGestureNavigation => isMobile;

  /// 是否支持键盘快捷键
  static bool get supportsKeyboardShortcuts => isDesktop;

  /// 是否支持鼠标悬停
  static bool get supportsHover => isDesktop || isWeb;

  // ==================== 平台特定样式 ====================

  /// 获取平台特定的圆角半径
  static double getPlatformBorderRadius() {
    if (isIOS) {
      return 8.0;
    } else if (isAndroid) {
      return 4.0;
    } else if (isWeb) {
      return 6.0;
    } else if (isDesktop) {
      return 4.0;
    }
    return 4.0;
  }

  /// 获取平台特定的阴影
  static List<BoxShadow> getPlatformShadow() {
    if (isIOS) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (isAndroid) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (isWeb) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return [];
  }

  /// 获取平台特定的动画曲线
  static Curve getPlatformAnimationCurve() {
    if (isIOS) {
      return Curves.easeInOutCubic;
    } else if (isAndroid) {
      return Curves.fastOutSlowIn;
    }
    return Curves.easeInOut;
  }

  /// 获取平台特定的动画持续时间
  static Duration getPlatformAnimationDuration() {
    if (isIOS) {
      return const Duration(milliseconds: 300);
    } else if (isAndroid) {
      return const Duration(milliseconds: 250);
    }
    return const Duration(milliseconds: 300);
  }
}
