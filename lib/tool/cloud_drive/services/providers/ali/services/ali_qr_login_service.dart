import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../data/models/cloud_drive_dtos.dart';
import '../../../../data/models/cloud_drive_entities.dart';
import '../../../../../../core/logging/log_manager.dart';
import '../../../base/cloud_drive_api_logger.dart';
import '../../../base/qr_login_service.dart';
import '../api/ali_config.dart';

/// 阿里云盘二维码登录服务。
///
/// 接口：
/// - 生成二维码：GET https://passport.aliyundrive.com/newlogin/qrcode/generate.do
/// - 轮询状态：GET https://passport.aliyundrive.com/newlogin/qrcode/query.do
class AliQRLoginService extends QRLoginService {
  static const _baseUrl = 'https://passport.aliyundrive.com';

  // 保存生成时返回的参数，供轮询使用。
  final Map<String, Map<String, String>> _sessionStore = {};

  @override
  CloudDriveType get cloudDriveType => CloudDriveType.ali;

  @override
  QRLoginConfig get config => QRLoginConfig(
        generateEndpoint: '/newlogin/qrcode/generate.do',
        statusEndpoint: '/newlogin/qrcode/query.do',
        headers: {
          ...AliConfig.defaultHeaders,
          'Accept': 'application/json, text/plain, */*',
          'Origin': 'https://passport.aliyundrive.com',
          'Referer': 'https://auth.aliyundrive.com/',
        },
        timeout: 20,
        pollInterval: 2,
        maxPollCount: 120, // 约4分钟
        qrExpireTime: 300,
      );

  Dio _createDio({String? cookies}) => Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: Duration(seconds: config.timeout),
          receiveTimeout: Duration(seconds: config.timeout),
          sendTimeout: Duration(seconds: config.timeout),
          headers: {
            ...config.headers,
            if (cookies != null && cookies.isNotEmpty) 'Cookie': cookies,
          },
          validateStatus: (code) => true,
        ),
      )..interceptors.add(
          CloudDriveLoggingInterceptor(
            logger: CloudDriveApiLogger(
              provider: '阿里云盘二维码',
              verbose: false,
            ),
          ),
        );

  Map<String, String> _defaultQuery([Map<String, String>? session]) => {
        'appName': 'aliyun_drive',
        'fromSite': '52',
        'appEntrance': 'web_default',
        'isMobile': 'false',
        'lang': 'zh_CN',
        'mainPage': 'false',
        'returnUrl': '',
        'bizParams':
            'taobaoBizLoginFrom=web_default&renderRefer=https%3A%2F%2Fauth.aliyundrive.com%2F',
        'umidTag': 'SERVER',
        if (session != null && session['deviceId'] != null)
          'deviceId': session['deviceId']!,
        if (session != null && session['_csrf_token'] != null)
          '_csrf_token': session['_csrf_token']!,
        if (session != null && session['umidToken'] != null)
          'umidToken': session['umidToken']!,
        if (session != null && session['hsiz'] != null) 'hsiz': session['hsiz']!,
      };

  @override
  Future<QRLoginInfo> generateQRCode() async {
    final dio = _createDio();
    final response = await dio.get(
      config.generateEndpoint,
      queryParameters: _defaultQuery(),
    );

    if (response.statusCode != 200) {
      throw Exception('二维码生成失败: HTTP ${response.statusCode}');
    }
    final map = response.data as Map<String, dynamic>? ?? {};
    final content = map['content'] as Map<String, dynamic>? ?? {};
    final data = content['data'] as Map<String, dynamic>? ?? {};
    final codeContent = data['codeContent']?.toString();
    final ck = data['ck']?.toString();
    final t = data['t']?.toString();
    if (codeContent == null || ck == null || t == null) {
      throw Exception('二维码生成失败: 响应缺少必要字段');
    }

    String? cookies;
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      cookies = setCookie.join('; ');
    }

    final session = <String, String>{
      'ck': ck,
      't': t,
      if (cookies != null) 'cookie': cookies,
    };

    // 解析关键 cookie（如 csrf/umid），用于后续查询。
    void tryStore(String key) {
      final match = RegExp('$key=([^;]+)', caseSensitive: false)
          .firstMatch(cookies ?? '');
      if (match != null) {
        session[key] = match.group(1)!;
      }
    }

    tryStore('_csrf_token');
    tryStore('umidToken');
    tryStore('hsiz');
    tryStore('cna');
    tryStore('XSRF-TOKEN');
    tryStore('tfstk');
    tryStore('deviceId');

    session['qrContent'] = codeContent;
    _sessionStore[ck] = session;

    final expiresAt =
        DateTime.now().add(Duration(seconds: config.qrExpireTime));

    return QRLoginInfo(
      qrId: ck, // 使用 ck 作为轮询 key
      qrContent: codeContent,
      expiresAt: expiresAt,
      pollInterval: config.pollInterval,
      maxPollCount: config.maxPollCount,
      status: QRLoginStatus.ready,
      message: '请使用阿里云盘 APP 扫码登录',
      userInfo: {'ck': ck, 't': t},
    );
  }

  @override
  Future<QRLoginInfo> checkQRStatus(String qrId) async {
    final session = _sessionStore[qrId];
    if (session == null) {
      return QRLoginInfo(
        qrId: qrId,
        qrContent: '',
        status: QRLoginStatus.failed,
        message: '会话已丢失，请重新生成二维码',
      );
    }
    final dio = _createDio();
    final body = {
      ..._defaultQuery(session),
      't': session['t'] ?? '',
      'ck': session['ck'] ?? '',
      'navlanguage': 'zh-CN',
      'navUserAgent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'navPlatform': 'MacIntel',
      'isIframe': 'true',
      'documentReferer': 'https://auth.aliyundrive.com/',
      'defaultView': 'qrcode',
      'pageTraceId': DateTime.now().microsecondsSinceEpoch.toString(),
    };

    final response = await dio.post(
      config.statusEndpoint,
      data: body,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('查询二维码状态失败: HTTP ${response.statusCode}');
    }

    final map = response.data as Map<String, dynamic>? ?? {};
    final content = map['content'] as Map<String, dynamic>? ?? {};
    final data = content['data'] as Map<String, dynamic>? ?? {};
    final status = data['qrCodeStatus']?.toString().toUpperCase() ?? '';
    final resultCode = data['resultCode'] as int? ?? -1;
    // bizExt 是 base64-url 编码的 JSON，部分返回会省略 padding，需要先补全。
    final bizExtRaw = data['bizExt']?.toString();
    final bizExt = _decodeBizExt(bizExtRaw);
    LogManager().cloudDrive(
      '阿里云盘二维码 - bizExt raw len=${bizExtRaw?.length ?? 0}, decoded keys=${bizExt.keys.toList()}',
    );

    QRLoginStatus qrStatus = QRLoginStatus.waiting;
    String msg = '等待扫码';
    if (status == 'EXPIRED') {
      qrStatus = QRLoginStatus.expired;
      msg = '二维码已过期';
    } else if (status == 'CANCELED') {
      qrStatus = QRLoginStatus.cancelled;
      msg = '已取消';
    } else if (status == 'SCANED' || status == 'SCANNED') {
      qrStatus = QRLoginStatus.scanned;
      msg = '已扫码，请在手机确认';
    } else if (status == 'CONFIRMED' || status == 'SUCCESS') {
      qrStatus = QRLoginStatus.success;
      msg = '登录成功';
    } else if (resultCode != 100) {
      qrStatus = QRLoginStatus.failed;
      msg = '登录失败: code=$resultCode';
    }

    String? cookies;
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      cookies = setCookie.join('; ');
    }

    String? accessToken;
    String? refreshToken;
    if (bizExt.isNotEmpty) {
      final pdsResult =
          bizExt['pds_login_result'] as Map<String, dynamic>? ?? {};
      accessToken = pdsResult['accessToken']?.toString() ??
          bizExt['accessToken']?.toString();
      refreshToken = pdsResult['refreshToken']?.toString() ??
          bizExt['refreshToken']?.toString();
    }
    LogManager().cloudDrive(
      '阿里云盘二维码 - 轮询结果: status=$status, resultCode=$resultCode, '
      'accessTokenLen=${accessToken?.length ?? 0}, refreshTokenLen=${refreshToken?.length ?? 0}, '
      'bizExtEmpty=${bizExt.isEmpty}',
    );

    final info = QRLoginInfo(
      qrId: qrId,
      qrContent: session['qrContent'] ?? session['ck'] ?? '',
      status: qrStatus,
      message: msg,
      // 仅将 accessToken 作为 loginToken，用于 Authorization；其他凭证放到 userInfo。
      loginToken: accessToken,
      userInfo: {
        ...session,
        'qrCodeStatus': status,
        'resultCode': resultCode,
        'bizExt': bizExt,
        if (refreshToken != null) 'refreshToken': refreshToken,
        if (cookies != null) 'cookie': cookies,
      },
    );
    _logStatus(
      status: qrStatus,
      resultCode: resultCode,
      accessToken: accessToken,
      refreshToken: refreshToken,
      cookies: cookies,
    );
    return info;
  }

  @override
  Future<void> cancelQRLogin(String qrId) async {
    _sessionStore.remove(qrId);
  }

  @override
  Future<String> parseAuthData(QRLoginInfo loginInfo) async {
    // 优先使用登录返回的 accessToken，缺失则视为失败。
    if (loginInfo.loginToken == null || loginInfo.loginToken!.isEmpty) {
      LogManager().cloudDrive(
        '阿里云盘二维码 - 未获取到 accessToken，userInfo=${loginInfo.userInfo}',
      );
      throw Exception('未获取到 accessToken，请重试扫码');
    }
    final tokenPreview = loginInfo.loginToken!.length > 12
        ? '${loginInfo.loginToken!.substring(0, 6)}...${loginInfo.loginToken!.substring(loginInfo.loginToken!.length - 6)}'
        : loginInfo.loginToken!;
    LogManager().cloudDrive(
      '阿里云盘二维码 - 解析登录成功，token长度=${loginInfo.loginToken!.length}, preview=$tokenPreview',
    );
    final info = loginInfo.userInfo ?? {};
    LogManager().cloudDrive(
      '阿里云盘二维码 - 附带信息: status=${loginInfo.status.name}, resultCode=${info['resultCode']}, hasRefreshToken=${info['refreshToken'] != null}, cookieLen=${(info['cookie']?.toString().length) ?? 0}',
    );
    return loginInfo.loginToken!;
  }

  void _logStatus({
    required QRLoginStatus status,
    required int resultCode,
    required String? accessToken,
    required String? refreshToken,
    required String? cookies,
  }) {
    LogManager().cloudDrive(
      '阿里云盘二维码 - 状态: $status, resultCode=$resultCode, '
      'accessTokenLen=${accessToken?.length ?? 0}, refreshTokenLen=${refreshToken?.length ?? 0}, '
      'cookieLen=${cookies?.length ?? 0}',
    );
  }


  Map<String, dynamic> _decodeBizExt(String? bizExt) {
    if (bizExt == null || bizExt.isEmpty) return const {};
    Map<String, dynamic>? tryDecode(String source, {bool urlDecode = false}) {
      try {
        var payload = source;
        if (urlDecode) payload = Uri.decodeComponent(payload);
        payload = payload.replaceAll('-', '+').replaceAll('_', '/');
        payload = payload.replaceAll(RegExp(r'[\r\n\s]'), '');
        while (payload.length % 4 != 0) {
          payload += '=';
        }
        final decoded = utf8.decode(base64.decode(payload));
        final map = jsonDecode(decoded);
        if (map is Map<String, dynamic>) return map;
      } catch (_) {}
      return null;
    }

    try {
      // 1) 直接 base64 解码
      final direct = tryDecode(bizExt);
      if (direct != null) return direct;

      // 2) 尝试先 URL 解码再 base64
      final urlResult = tryDecode(bizExt, urlDecode: true);
      if (urlResult != null) return urlResult;

      // 3) 尝试直接当 JSON
      final asJson = jsonDecode(bizExt);
      if (asJson is Map<String, dynamic>) return asJson;

      throw Exception('decode failed');
    } catch (e) {
      final preview =
          bizExt.length > 120 ? '${bizExt.substring(0, 120)}...' : bizExt;
      LogManager().cloudDrive('阿里云盘二维码 - 解析 bizExt 失败: $e, preview=$preview');
    }
    return const {};
  }
}
