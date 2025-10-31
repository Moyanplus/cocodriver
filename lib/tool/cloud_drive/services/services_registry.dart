import 'base/qr_login_service.dart';
import 'quark/services/quark_qr_login_service.dart';
import 'strategy_registry.dart';

/// 云盘服务注册中心
///
/// 负责注册和管理各种云盘服务，包括策略注册、二维码登录服务等。
class CloudDriveServicesRegistry {
  static bool _isInitialized = false;

  /// 初始化所有云盘服务
  static void initialize() {
    if (_isInitialized) {
      return;
    }

    // 注册操作策略
    StrategyRegistry.initialize();

    // 注册二维码登录服务
    _registerQRLoginServices();

    _isInitialized = true;
  }

  /// 注册二维码登录服务（内部方法）
  static void _registerQRLoginServices() {
    // 注册夸克网盘二维码登录服务
    QRLoginManager.registerService(QuarkQRLoginService());
    print('夸克网盘二维码登录服务已注册');
  }

  /// 检查是否已初始化
  static bool get isInitialized => _isInitialized;
}
