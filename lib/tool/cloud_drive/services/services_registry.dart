/// 云盘服务注册中心
///
/// 负责注册和管理各种云盘服务，包括二维码登录、文件操作等服务
/// 使用单例模式确保服务注册的唯一性和一致性
///
/// 主要功能：
/// - 云盘服务注册管理
/// - 二维码登录服务注册
/// - 服务初始化状态管理
/// - 支持多种云盘平台（夸克、百度、阿里等）
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年

import 'base/qr_login_service.dart';
import 'quark/services/quark_qr_login_service.dart';

/// 云盘服务注册中心类
///
/// 负责注册和管理各种云盘服务，包括二维码登录、文件操作等服务
/// 使用单例模式确保服务注册的唯一性和一致性
///
/// 主要功能：
/// - 云盘服务注册管理
/// - 二维码登录服务注册
/// - 服务初始化状态管理
/// - 支持多种云盘平台（夸克、百度、阿里等）
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年
class CloudDriveServicesRegistry {
  /// 私有静态变量，用于跟踪初始化状态
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
    print('夸克网盘二维码登录服务已注册');
  }

  /// 检查是否已初始化
  static bool get isInitialized => _isInitialized;
}
