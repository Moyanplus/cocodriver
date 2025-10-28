import 'package:dio/dio.dart';
import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import '../base/qr_login_service.dart';
import 'quark_base_service.dart';
import 'quark_config.dart';

/// 夸克网盘二维码登录服务
class QuarkQRLoginService extends QRLoginService {
  @override
  CloudDriveType get cloudDriveType => CloudDriveType.quark;

  @override
  QRLoginConfig get config => QRLoginConfig(
    generateEndpoint: QuarkConfig.getUopApiEndpoint('generateQRToken'),
    statusEndpoint: QuarkConfig.getUopApiEndpoint('checkQRStatus'),
    headers: {
      'Content-Type': 'application/json',
      ...QuarkConfig.defaultHeaders,
    },
    timeout: QuarkConfig.qrLoginConfig['timeout'] as int,
    pollInterval: QuarkConfig.qrLoginConfig['pollInterval'] as int,
    maxPollCount: QuarkConfig.qrLoginConfig['maxPollCount'] as int,
    qrExpireTime: QuarkConfig.qrLoginConfig['qrExpireTime'] as int,
  );

  @override
  Future<QRLoginInfo> generateQRCode() async {
    LogManager().cloudDrive('🔄 夸克网盘 - 开始生成二维码');

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: QuarkConfig.uopUrl,
          connectTimeout: Duration(seconds: config.timeout),
          receiveTimeout: Duration(seconds: config.timeout),
          headers: config.headers,
        ),
      );

      LogManager().cloudDrive(
        '🔗 生成二维码URL: ${QuarkConfig.uopUrl}${config.generateEndpoint}',
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
      if (responseData is! Map<String, dynamic>) {
        throw Exception('响应数据格式错误：不是有效的JSON对象');
      }

      final status = responseData['status'] as int?;
      if (!QuarkConfig.isQRLoginSuccess(status)) {
        final message = responseData['message'] as String? ?? '生成二维码失败';
        throw Exception('生成二维码失败: $message (状态码: $status)');
      }

      final data = responseData['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('响应数据格式错误：缺少data字段');
      }

      final members = data['members'] as Map<String, dynamic>?;
      if (members == null) {
        throw Exception('响应数据格式错误：缺少members字段');
      }

      final token = members['token'] as String? ?? '';
      if (token.isEmpty) {
        throw Exception('未获取到token');
      }

      // 使用QuarkConfig构建二维码内容URL
      final qrContent = QuarkConfig.buildQRContentUrl(token);

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
          baseUrl: QuarkConfig.uopUrl,
          connectTimeout: Duration(seconds: config.timeout),
          receiveTimeout: Duration(seconds: config.timeout),
          headers: config.headers,
        ),
      );

      // 使用QuarkConfig构建请求参数
      final requestData = QuarkConfig.buildQRStatusQueryParams(qrId);

      final url = Uri.parse('${QuarkConfig.uopUrl}${config.statusEndpoint}');
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

      // 保持二维码内容URL
      final qrContent = QuarkConfig.buildQRContentUrl(qrId);

      // 解析响应数据
      if (responseData is Map<String, dynamic>) {
        final status = responseData['status'] as int?;

        // 检查是否登录成功
        if (QuarkConfig.isQRLoginSuccess(status)) {
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
            qrContent: qrContent,
            status: QRLoginStatus.success,
            message: '登录成功',
            loginToken: serviceTicket ?? qrId, // 优先使用service_ticket
          );

          LogManager().cloudDrive('📊 夸克网盘 - 登录成功');
          return loginInfo;
        } else if (responseData.isEmpty) {
          // 空响应也表示登录成功
          final loginInfo = QRLoginInfo(
            qrId: qrId,
            qrContent: qrContent,
            status: QRLoginStatus.success,
            message: '登录成功',
            loginToken: qrId,
          );

          LogManager().cloudDrive('📊 夸克网盘 - 登录成功（空响应）');
          return loginInfo;
        } else {
          // 其他状态码表示还在等待或失败
          final message = responseData['message'] as String? ?? '等待扫码';

          final loginInfo = QRLoginInfo(
            qrId: qrId,
            qrContent: qrContent,
            status: QRLoginStatus.ready,
            message: message,
          );

          LogManager().cloudDrive('📊 夸克网盘 - 状态查询结果: $message');
          return loginInfo;
        }
      } else {
        // 非Map类型的空响应，表示登录成功
        final loginInfo = QRLoginInfo(
          qrId: qrId,
          qrContent: qrContent,
          status: QRLoginStatus.success,
          message: '登录成功',
          loginToken: qrId,
        );

        LogManager().cloudDrive('📊 夸克网盘 - 登录成功（非Map响应）');
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
          baseUrl: QuarkConfig.panUrl,
          connectTimeout: Duration(seconds: config.timeout),
          receiveTimeout: Duration(seconds: config.timeout),
          headers: config.headers,
        ),
      );

      // 使用QuarkConfig构建请求参数
      final requestData = QuarkConfig.buildQRAccountInfoParams(
        loginInfo.loginToken!,
      );

      final accountInfoEndpoint = QuarkConfig.getPanApiEndpoint(
        'getAccountInfo',
      );
      final url = Uri.parse('${QuarkConfig.panUrl}$accountInfoEndpoint');
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
      final setCookieHeaders = response.headers['set-cookie'];
      if (setCookieHeaders == null || setCookieHeaders.isEmpty) {
        throw Exception('未获取到Cookie信息');
      }

      // 使用QuarkConfig的方法提取Cookie
      final cookieString = QuarkConfig.extractCookiesFromHeaders(
        setCookieHeaders,
      );

      if (cookieString.isEmpty) {
        throw Exception('Cookie解析结果为空');
      }

      // 验证是否包含关键的__pus cookie
      if (!cookieString.contains('__pus=')) {
        LogManager().cloudDrive('⚠️ 警告：Cookie中未找到__pus字段');
      }

      LogManager().cloudDrive('✅ 夸克网盘 - 认证数据解析成功');
      LogManager().cloudDrive('🍪 Cookie长度: ${cookieString.length}');
      LogManager().cloudDrive(
        '🍪 Cookie前100字符: ${cookieString.substring(0, cookieString.length > 100 ? 100 : cookieString.length)}',
      );

      return cookieString;
    } catch (e) {
      LogManager().cloudDrive('❌ 夸克网盘 - 解析认证数据失败: $e');
      rethrow;
    }
  }
}
