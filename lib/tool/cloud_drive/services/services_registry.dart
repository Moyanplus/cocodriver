import 'base/qr_login_service.dart';
import 'quark/quark_qr_login_service.dart';

/// 云盘服务注册中心
/// 负责注册各种云盘服务
class CloudDriveServicesRegistry {
  static bool _isInitialized = false;

  /// 初始化所有云盘服务
  static void initialize() {
    if (_isInitialized) {
      return;
    }

    // 注册二维码登录服务
    _registerQRLoginServices();

    _isInitialized = true;
  }

  /// 注册二维码登录服务
  static void _registerQRLoginServices() {
    // 注册夸克网盘二维码登录服务
    QRLoginManager.registerService(QuarkQRLoginService());
    print('✅ 夸克网盘二维码登录服务已注册');
  }

  /// 检查是否已初始化
  static bool get isInitialized => _isInitialized;
}
