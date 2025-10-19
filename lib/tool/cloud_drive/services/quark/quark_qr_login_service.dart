import 'package:dio/dio.dart';
import '../../../../core/logging/log_manager.dart';
import '../../models/cloud_drive_models.dart';
import '../../models/qr_login_models.dart';
import '../base/qr_login_service.dart';
import 'quark_base_service.dart';

/// 夸克网盘二维码登录服务
class QuarkQRLoginService extends QRLoginService {
  @override
  CloudDriveType get cloudDriveType => CloudDriveType.quark;

  @override
  QRLoginConfig get config => const QRLoginConfig(
    generateEndpoint: '/cas/ajax/getTokenForQrcodeLogin',
    statusEndpoint: '/cas/ajax/getServiceTicketByQrcodeToken',
    headers: {
      'Content-Type': 'application/json',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    },
    timeout: 30,
    pollInterval: 2,
    maxPollCount: 150,
    qrExpireTime: 300,
  );

  @override
  Future<QRLoginInfo> generateQRCode() async {
    LogManager().cloudDrive('🔄 夸克网盘 - 开始生成二维码');

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://uop.quark.cn',
          connectTimeout: Duration(seconds: config.timeout),
          receiveTimeout: Duration(seconds: config.timeout),
          headers: config.headers,
        ),
      );

      LogManager().cloudDrive(
        '🔗 生成二维码URL: https://uop.quark.cn${config.generateEndpoint}',
      );

      final response = await dio.get(
        config.generateEndpoint,
        options: Options(
          headers: config.headers,
          sendTimeout: Duration(seconds: config.timeout),
          receiveTimeout: Duration(seconds: config.timeout),
        ),
      );

      if (!QuarkBaseService.isHttpSuccess(response.statusCode)) {
        throw Exception('生成二维码失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      LogManager().cloudDrive('📡 生成二维码响应: $responseData');

      // 解析响应数据
      if (responseData is Map<String, dynamic>) {
        final status = responseData['status'] as int?;
        if (status != 2000000) {
          final message = responseData['message'] as String? ?? '生成二维码失败';
          throw Exception('生成二维码失败: $message');
        }

        final data = responseData['data'] as Map<String, dynamic>?;
        if (data == null) {
          throw Exception('响应数据格式错误');
        }

        final members = data['members'] as Map<String, dynamic>?;
        if (members == null) {
          throw Exception('响应数据格式错误：缺少members字段');
        }

        final token = members['token'] as String? ?? '';
        if (token.isEmpty) {
          throw Exception('未获取到token');
        }

        // 构建二维码内容URL
        final qrContent =
            'https://su.quark.cn/4_eMHBJ?token=$token&client_id=532&ssb=weblogin&uc_param_str=&uc_biz_str=S:custom|OPT:SAREA@0|OPT:IMMERSIVE@1|OPT:BACK_BTN_STYLE@0';

        // 使用token作为qrId
        final qrId = token;
        final expiresAt = DateTime.now().add(
          Duration(seconds: config.qrExpireTime),
        );

        final loginInfo = QRLoginInfo(
          qrId: qrId,
          qrContent: qrContent,
          expiresAt: expiresAt,
          pollInterval: config.pollInterval,
          maxPollCount: config.maxPollCount,
          status: QRLoginStatus.ready,
          message: '请使用夸克网盘APP扫描二维码',
        );

        LogManager().cloudDrive('✅ 夸克网盘 - 二维码生成成功');
        LogManager().cloudDrive('📱 二维码Token: $token');
        LogManager().cloudDrive('⏰ 过期时间: $expiresAt');

        return loginInfo;
      } else {
        throw Exception('响应数据格式错误');
      }
    } catch (e) {
      LogManager().cloudDrive('❌ 夸克网盘 - 生成二维码失败: $e');
      rethrow;
    }
  }

  @override
  Future<QRLoginInfo> checkQRStatus(String qrId) async {
    LogManager().cloudDrive('🔍 夸克网盘 - 查询二维码状态: $qrId');

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://uop.quark.cn',
          connectTimeout: Duration(seconds: config.timeout),
          receiveTimeout: Duration(seconds: config.timeout),
          headers: config.headers,
        ),
      );

      // 构建请求参数
      final requestData = {
        'client_id': '532',
        'v': '1.2',
        'token': qrId,
        'request_id': _generateRequestId(),
      };

      final url = Uri.parse('https://uop.quark.cn${config.statusEndpoint}');
      final uri = url.replace(
        queryParameters: requestData.map((k, v) => MapEntry(k, v.toString())),
      );

      LogManager().cloudDrive('🔗 查询状态URL: $uri');

      final response = await dio.getUri(
        uri,
        options: Options(
          headers: config.headers,
          sendTimeout: Duration(seconds: config.timeout),
          receiveTimeout: Duration(seconds: config.timeout),
        ),
      );

      if (!QuarkBaseService.isHttpSuccess(response.statusCode)) {
        throw Exception('查询状态失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      LogManager().cloudDrive('📡 查询状态响应: $responseData');

      // 解析响应数据
      if (responseData is Map<String, dynamic>) {
        final status = responseData['status'] as int?;

        // 如果返回为空或者status为2000000，表示登录成功
        if (status == 2000000 || responseData.isEmpty) {
          // 从响应中提取service_ticket
          String? serviceTicket;
          final data = responseData['data'] as Map<String, dynamic>?;
          if (data != null) {
            final members = data['members'] as Map<String, dynamic>?;
            if (members != null) {
              serviceTicket = members['service_ticket'] as String?;
              LogManager().cloudDrive('🎫 提取到service_ticket: $serviceTicket');
            }
          }

          final loginInfo = QRLoginInfo(
            qrId: qrId,
            qrContent:
                'https://su.quark.cn/4_eMHBJ?token=$qrId&client_id=532&ssb=weblogin&uc_param_str=&uc_biz_str=S:custom|OPT:SAREA@0|OPT:IMMERSIVE@1|OPT:BACK_BTN_STYLE@0', // 保持二维码内容
            status: QRLoginStatus.success,
            message: '登录成功',
            loginToken:
                serviceTicket ??
                qrId, // 使用service_ticket作为loginToken，如果没有则使用原token
          );

          LogManager().cloudDrive('📊 夸克网盘 - 登录成功');
          return loginInfo;
        } else {
          // 其他状态码表示还在等待或失败
          final message = responseData['message'] as String? ?? '等待扫码';

          final loginInfo = QRLoginInfo(
            qrId: qrId,
            qrContent:
                'https://su.quark.cn/4_eMHBJ?token=$qrId&client_id=532&ssb=weblogin&uc_param_str=&uc_biz_str=S:custom|OPT:SAREA@0|OPT:IMMERSIVE@1|OPT:BACK_BTN_STYLE@0', // 保持二维码内容
            status: QRLoginStatus.ready,
            message: message,
          );

          LogManager().cloudDrive('📊 夸克网盘 - 状态查询结果: $message');
          return loginInfo;
        }
      } else {
        // 如果响应为空，表示登录成功
        final loginInfo = QRLoginInfo(
          qrId: qrId,
          qrContent:
              'https://su.quark.cn/4_eMHBJ?token=$qrId&client_id=532&ssb=weblogin&uc_param_str=&uc_biz_str=S:custom|OPT:SAREA@0|OPT:IMMERSIVE@1|OPT:BACK_BTN_STYLE@0', // 保持二维码内容
          status: QRLoginStatus.success,
          message: '登录成功',
          loginToken: qrId, // 空响应时使用原token
        );

        LogManager().cloudDrive('📊 夸克网盘 - 登录成功（空响应）');
        return loginInfo;
      }
    } catch (e) {
      LogManager().cloudDrive('❌ 夸克网盘 - 查询状态失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelQRLogin(String qrId) async {
    LogManager().cloudDrive('🚫 夸克网盘 - 取消二维码登录: $qrId');
    // 夸克网盘二维码登录取消操作不需要特殊处理
    // 只需要记录日志即可
    LogManager().cloudDrive('✅ 夸克网盘 - 取消登录操作完成');
  }

  @override
  Future<String> parseAuthData(QRLoginInfo loginInfo) async {
    LogManager().cloudDrive('🔐 夸克网盘 - 解析认证数据');

    if (loginInfo.loginToken == null || loginInfo.loginToken!.isEmpty) {
      throw Exception('登录token为空');
    }

    try {
      // 使用登录token获取账号信息，从中提取Cookie
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://pan.quark.cn',
          connectTimeout: Duration(seconds: config.timeout),
          receiveTimeout: Duration(seconds: config.timeout),
          headers: config.headers,
        ),
      );

      // 构建请求参数
      final requestData = {'st': loginInfo.loginToken!, 'lw': 'scan'};

      final url = Uri.parse('https://pan.quark.cn/account/info');
      final uri = url.replace(
        queryParameters: requestData.map((k, v) => MapEntry(k, v.toString())),
      );

      LogManager().cloudDrive('🔗 获取账号信息URL: $uri');

      final response = await dio.getUri(
        uri,
        options: Options(
          headers: config.headers,
          sendTimeout: Duration(seconds: config.timeout),
          receiveTimeout: Duration(seconds: config.timeout),
        ),
      );

      if (!QuarkBaseService.isHttpSuccess(response.statusCode)) {
        throw Exception('获取账号信息失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      LogManager().cloudDrive('📡 获取账号信息响应: $responseData');

      // 从响应头中提取Cookie
      final cookies = response.headers['set-cookie'];
      if (cookies == null || cookies.isEmpty) {
        throw Exception('未获取到Cookie信息');
      }

      // 提取__pus cookie（最重要的）
      String? pusCookie;
      for (final cookie in cookies) {
        if (cookie.startsWith('__pus=')) {
          pusCookie = cookie.split(';')[0]; // 只取cookie值部分
          break;
        }
      }

      if (pusCookie == null || pusCookie.isEmpty) {
        throw Exception('未获取到__pus Cookie');
      }

      // 构建完整的Cookie字符串
      final cookieString = cookies.join('; ');

      LogManager().cloudDrive('✅ 夸克网盘 - 认证数据解析成功');
      LogManager().cloudDrive('🍪 __pus Cookie: $pusCookie');
      LogManager().cloudDrive('🍪 完整Cookie长度: ${cookieString.length}');

      return cookieString;
    } catch (e) {
      LogManager().cloudDrive('❌ 夸克网盘 - 解析认证数据失败: $e');
      rethrow;
    }
  }

  /// 生成请求ID
  String _generateRequestId() {
    return 'fe1e0586-c493-4504-b2ca-f6b5426197a9'; // 使用固定的request_id
  }
}
