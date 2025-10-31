import '../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import 'baidu_base_service.dart';

/// 百度网盘账号服务
///
/// 提供百度网盘账号相关功能，包括 Cookie 验证、账号信息获取等。
class BaiduAccountService {
  static const String _baseUrl = 'https://pan.baidu.com/api';

  /// 验证Cookie
  static Future<bool> validateCookies(CloudDriveAccount account) async {
    try {
      final dio = BaiduBaseService.createDio(account);

      final response = await dio.get('$_baseUrl/userinfo');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errno'] == 0) {
          _logSuccess('Cookie验证成功');
          return true;
        } else {
          final errorMsg = _getErrorMessage(data['errno']);
          _logError('Cookie验证失败', errorMsg);
          return false;
        }
      } else {
        _logError('Cookie验证失败', 'HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logError('Cookie验证异常', e);
      return false;
    }
  }

  /// 获取账号详情
  static Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    try {
      final dio = BaiduBaseService.createDio(account);

      // 获取用户信息
      final userResponse = await dio.get('$_baseUrl/userinfo');
      if (userResponse.statusCode != 200 || userResponse.data['errno'] != 0) {
        _logError('获取用户信息失败', 'HTTP ${userResponse.statusCode}');
        return null;
      }

      final userData = userResponse.data;
      final accountInfo = CloudDriveAccountInfo(
        username: userData['baidu_name'] ?? '未知用户',
        uk: userData['uk'] ?? 0,
        isVip: userData['vip_type'] != null && userData['vip_type'] > 0,
        isSvip: userData['vip_type'] == 2,
        loginState: 1,
      );

      // 获取容量信息
      final quotaResponse = await dio.get('$_baseUrl/quota');
      CloudDriveQuotaInfo? quotaInfo;

      if (quotaResponse.statusCode == 200 && quotaResponse.data['errno'] == 0) {
        final quotaData = quotaResponse.data;
        quotaInfo = CloudDriveQuotaInfo(
          total: quotaData['total'] ?? 0,
          used: quotaData['used'] ?? 0,
          free: quotaData['free'] ?? 0,
          expire: false,
          serverTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
      }

      final accountDetails = CloudDriveAccountDetails(
        id: account.id,
        name: account.name,
        accountInfo: accountInfo,
        quotaInfo: quotaInfo,
      );

      _logSuccess('获取账号详情成功');
      return accountDetails;
    } catch (e) {
      _logError('获取账号详情异常', e);
      return null;
    }
  }

  /// 获取用户信息
  static Future<Map<String, dynamic>?> getUserInfo({
    required CloudDriveAccount account,
  }) async {
    try {
      final dio = BaiduBaseService.createDio(account);

      final response = await dio.get('$_baseUrl/userinfo');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errno'] == 0) {
          _logSuccess('获取用户信息成功');
          return data;
        } else {
          final errorMsg = _getErrorMessage(data['errno']);
          _logError('获取用户信息失败', errorMsg);
          return null;
        }
      } else {
        _logError('获取用户信息失败', 'HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logError('获取用户信息异常', e);
      return null;
    }
  }

  /// 获取容量信息
  static Future<Map<String, dynamic>?> getQuotaInfo({
    required CloudDriveAccount account,
  }) async {
    try {
      final dio = BaiduBaseService.createDio(account);

      final response = await dio.get('$_baseUrl/quota');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errno'] == 0) {
          _logSuccess('获取容量信息成功');
          return data;
        } else {
          final errorMsg = _getErrorMessage(data['errno']);
          _logError('获取容量信息失败', errorMsg);
          return null;
        }
      } else {
        _logError('获取容量信息失败', 'HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logError('获取容量信息异常', e);
      return null;
    }
  }

  /// 获取错误消息
  static String _getErrorMessage(int errno) {
    switch (errno) {
      case 0:
        return '成功';
      case -1:
        return '系统错误';
      case -2:
        return '参数错误';
      case -3:
        return '网络错误';
      case -4:
        return '权限不足';
      case -5:
        return '文件不存在';
      case -6:
        return '文件已存在';
      case -7:
        return '存储空间不足';
      case -8:
        return '操作失败';
      case -9:
        return '登录已过期';
      default:
        return '未知错误($errno)';
    }
  }

  /// 统一成功日志记录
  static void _logSuccess(String message) {
    LogManager().cloudDrive('百度网盘账号 - $message');
  }

  /// 统一错误日志记录
  static void _logError(String message, dynamic error) {
    LogManager().cloudDrive('百度网盘账号 - $message: $error');
  }
}
