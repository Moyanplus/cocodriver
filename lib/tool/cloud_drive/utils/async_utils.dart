import 'dart:async';
import 'dart:io';

/// 异步辅助：延迟/防抖/节流/网络检测。
class AsyncUtils {
  AsyncUtils._();

  static Future<bool> checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<void> delay(Duration duration) async {
    await Future.delayed(duration);
  }

  static Timer? _debounceTimer;
  static void debounce(Duration delay, void Function() callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  static DateTime? _lastThrottleTime;
  static bool throttle(Duration interval, void Function() callback) {
    final now = DateTime.now();
    if (_lastThrottleTime == null ||
        now.difference(_lastThrottleTime!) >= interval) {
      _lastThrottleTime = now;
      callback();
      return true;
    }
    return false;
  }
}
