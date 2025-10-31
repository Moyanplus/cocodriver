import '../base/cloud_drive_operation_service.dart';
import '../data/models/cloud_drive_entities.dart';
import 'ali/ali_operation_strategy.dart';
import 'baidu/baidu_operation_strategy.dart';
import 'china_mobile/china_mobile_operation_strategy.dart';
import 'lanzou/lanzou_operation_strategy.dart';
import 'pan123/pan123_operation_strategy.dart';
import 'quark/strategy/quark_operation_strategy.dart';

/// 策略注册器
///
/// 集中管理所有云盘操作策略的注册和获取，实现策略与调用方的解耦。
class StrategyRegistry {
  static final Map<CloudDriveType, CloudDriveOperationStrategy> _strategies =
      {};

  /// 注册策略
  static void register(
    CloudDriveType type,
    CloudDriveOperationStrategy strategy,
  ) {
    _strategies[type] = strategy;
  }

  /// 获取策略
  static CloudDriveOperationStrategy? getStrategy(CloudDriveType type) {
    return _strategies[type];
  }

  /// 获取所有已注册的策略类型
  static List<CloudDriveType> getRegisteredTypes() {
    return _strategies.keys.toList();
  }

  /// 检查策略是否已注册
  static bool isRegistered(CloudDriveType type) {
    return _strategies.containsKey(type);
  }

  /// 初始化并注册所有策略
  static void initialize() {
    register(CloudDriveType.baidu, BaiduCloudDriveOperationStrategy());
    register(CloudDriveType.lanzou, LanzouCloudDriveOperationStrategy());
    register(CloudDriveType.pan123, Pan123CloudDriveOperationStrategy());
    register(CloudDriveType.ali, AliCloudDriveOperationStrategy());
    register(CloudDriveType.quark, QuarkCloudDriveOperationStrategy());
    register(
      CloudDriveType.chinaMobile,
      ChinaMobileCloudDriveOperationStrategy(),
    );
  }

  /// 清空所有策略（用于测试）
  static void clear() {
    _strategies.clear();
  }
}
