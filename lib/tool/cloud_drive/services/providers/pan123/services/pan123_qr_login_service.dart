import 'package:dio/dio.dart';
import '../../../../../../core/logging/log_manager.dart';
import '../../../../data/models/cloud_drive_dtos.dart';
import '../../../../data/models/cloud_drive_entities.dart';
import '../../../base/qr_login_service.dart';
import '../api/pan123_config.dart';

/// 123 云盘二维码登录服务
///
/// 接口说明：
/// - 生成二维码：POST https://login.123pan.com/api/user/qr-code/generate
///   响应示例：
///   {
///     "code": 0,
///     "message": "ok",
///     "data": { "uniID": "uuid", "url": "https://www.123pan.com/wx-app-login.html" }
///   }
/// - 查询状态：GET https://login.123pan.com/api/user/qr-code/result?uniID=xxx
///   loginStatus: 0=待扫码, 1=已扫码待确认(推测), 2=确认成功(推测), 3=拒绝/失败(推测), 4=过期
class Pan123QRLoginService extends QRLoginService {
  static const String _baseUrl = 'https://login.123pan.com';
  static const String _qrPageUrl = 'https://www.123pan.com/wx-app-login.html';

  @override
  CloudDriveType get cloudDriveType => CloudDriveType.pan123;

  @override
  QRLoginConfig get config => QRLoginConfig(
        generateEndpoint: '/api/user/qr-code/generate',
        statusEndpoint: '/api/user/qr-code/result',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain, */*',
          ...Pan123Config.defaultHeaders,
        },
        timeout: 15,
        pollInterval: 2,
        maxPollCount: 60, // 约两分钟超时
        qrExpireTime: 120,
      );

  Dio _createDio() => Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: Duration(seconds: config.timeout),
          receiveTimeout: Duration(seconds: config.timeout),
          sendTimeout: Duration(seconds: config.timeout),
          headers: config.headers,
          // 允许拿到 4xx/5xx 响应体以查看 code/message
          validateStatus: (code) => true,
        ),
      )..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              LogManager().cloudDrive(
                '123云盘二维码 - 请求: ${options.method} ${options.uri}',
              );
              if (options.data != null) {
                LogManager().cloudDrive('123云盘二维码 - 请求体: ${options.data}');
              }
              handler.next(options);
            },
            onResponse: (response, handler) {
              LogManager().cloudDrive(
                '123云盘二维码 - 响应: ${response.statusCode} ${response.data}',
              );
              handler.next(response);
            },
            onError: (error, handler) {
              LogManager().cloudDrive(
                '123云盘二维码 - 请求错误: ${error.message} (${error.response?.statusCode ?? 'no status'})',
              );
              handler.next(error);
            },
          ),
        );

  @override
  Future<QRLoginInfo> generateQRCode() async {
    final dio = _createDio();
    final response = await dio.get(config.generateEndpoint);

    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};
    if (response.statusCode != 200 && response.statusCode != 400) {
      // 400/404 等前置校验由 code 字段处理
      throw Exception(
        '二维码生成失败，状态码: ${response.statusCode}, 响应: ${response.data}',
      );
    }
    if (data['code'] != 0 || data['data'] is! Map<String, dynamic>) {
      throw Exception('二维码生成失败: ${data['message'] ?? '未知错误'}');
    }

    final payload = data['data'] as Map<String, dynamic>;
    final uniId = payload['uniID']?.toString();
    if (uniId == null || uniId.isEmpty) {
      throw Exception('二维码生成失败: 未返回 uniID');
    }

    final qrContent =
        '$_qrPageUrl?env=production&uniID=$uniId&source=123pan&type=login';
    final expiresAt =
        DateTime.now().add(Duration(seconds: config.qrExpireTime));

    return QRLoginInfo(
      qrId: uniId,
      qrContent: qrContent,
      expiresAt: expiresAt,
      pollInterval: config.pollInterval,
      maxPollCount: config.maxPollCount,
      status: QRLoginStatus.ready,
      message: '请使用 123 云盘 APP 扫码登录',
    );
  }

  @override
  Future<QRLoginInfo> checkQRStatus(String qrId) async {
    final dio = _createDio();
    final response = await dio.get(
      config.statusEndpoint,
      queryParameters: {'uniID': qrId},
    );

    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};
    final code = data['code'] as int? ?? response.statusCode ?? -1;
    final payload = data['data'] as Map<String, dynamic>? ?? {};
    final qrContent =
        '$_qrPageUrl?env=production&uniID=$qrId&source=123pan&type=login';

    // code == 200 表示直接返回 token 的成功响应
    if (code == 200) {
      final token = payload['token']?.toString();
      final refresh = payload['refresh_token']?.toString();
      return QRLoginInfo(
        qrId: qrId,
        qrContent: qrContent,
        status: QRLoginStatus.success,
        message: data['message']?.toString() ?? '登录成功',
        loginToken: token ?? refresh ?? qrId,
      );
    }

    if (response.statusCode != 200 && response.statusCode != 400) {
      throw Exception(
        '查询二维码状态失败，状态码: ${response.statusCode}, 响应: ${response.data}',
      );
    }
    if (code != 0) {
      throw Exception('查询二维码状态失败: ${data['message'] ?? '未知错误'}');
    }

    final status = payload['loginStatus'] as int? ?? 0;

    switch (status) {
      case 4:
        return QRLoginInfo(
          qrId: qrId,
          qrContent: qrContent,
          status: QRLoginStatus.expired,
          message: '二维码已过期',
        );
      case 2:
        return QRLoginInfo(
          qrId: qrId,
          qrContent: qrContent,
          status: QRLoginStatus.success,
          message: '登录成功',
          loginToken:
              payload['authToken']?.toString() ?? payload['token']?.toString(),
        );
      case 3:
        return QRLoginInfo(
          qrId: qrId,
          qrContent: qrContent,
          status: QRLoginStatus.failed,
          message: '登录被拒绝或失败',
        );
      case 1:
        return QRLoginInfo(
          qrId: qrId,
          qrContent: qrContent,
          status: QRLoginStatus.scanned,
          message: '已扫码，待确认',
        );
      case 0:
      default:
        return QRLoginInfo(
          qrId: qrId,
          qrContent: qrContent,
          status: QRLoginStatus.ready,
          message: '等待扫码',
        );
    }
  }

  @override
  Future<void> cancelQRLogin(String qrId) async {
    // 官方未提供取消接口，标记为用户取消即可。
    return;
  }

  @override
  Future<String> parseAuthData(QRLoginInfo loginInfo) async {
    // 123 云盘返回的 token 字段未明确，优先使用 loginToken，否则回退 uniID。
    return loginInfo.loginToken ?? loginInfo.qrId;
  }
}
