import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../data/models/cloud_drive_dtos.dart';
import '../../../../data/models/cloud_drive_entities.dart';
import '../../../base/cloud_drive_api_logger.dart';
import '../../../base/qr_login_service.dart';
import '../baidu_config.dart';
import '../utils/baidu_login_utils.dart';

/// 百度网盘二维码登录服务
///
/// 流程：
/// 1) GET /v2/api/getqrcode 获取 sign 与二维码地址
/// 2) 轮询 /channel/unicast?channel_id=sign 获取扫码状态
/// 3) 当返回 status=0 且包含 v 字段时，调用 /v3/login/main/qrbdusslogin 交换 BDUSS/STOKEN
///
/// 注意：接口为 JSONP，需要去掉回调包装后再解析 JSON。
class BaiduQRLoginService extends QRLoginService {
  static const String _baseUrl = 'https://passport.baidu.com';

  /// 存储会话信息（Cookie、gid 等），key 为 sign/channel_id。
  final Map<String, Map<String, String>> _sessionStore = {};

  @override
  CloudDriveType get cloudDriveType => CloudDriveType.baidu;

  @override
  QRLoginConfig get config => QRLoginConfig(
    generateEndpoint: '/v2/api/getqrcode',
    statusEndpoint: '/channel/unicast',
    headers: {
      ...BaiduConfig.defaultHeaders,
      ...(BaiduConfig.qrLoginConfig['headers'] as Map<String, String>),
    },
    timeout: BaiduConfig.qrLoginConfig['timeout'] as int,
    pollInterval: BaiduConfig.qrLoginConfig['pollInterval'] as int,
    maxPollCount: BaiduConfig.qrLoginConfig['maxPollCount'] as int,
    qrExpireTime: BaiduConfig.qrLoginConfig['qrExpireTime'] as int,
  );

  Dio _createDio({String? cookie}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: Duration(seconds: config.timeout),
        receiveTimeout: Duration(seconds: config.timeout),
        sendTimeout: Duration(seconds: config.timeout),
        headers: {
          ...config.headers,
          if (cookie != null && cookie.isNotEmpty) 'Cookie': cookie,
        },
        responseType: ResponseType.plain,
        followRedirects: true,
        validateStatus: (_) => true,
      ),
    );

    CloudDriveLoggingInterceptor.attach(
      dio,
      provider: '百度网盘二维码',
      verbose: false,
    );
    return dio;
  }

  @override
  Future<QRLoginInfo> generateQRCode() async {
    final dio = _createDio();
    final gid = BaiduLoginUtils.generateGid();
    final callback = 'tangram_guid_${DateTime.now().millisecondsSinceEpoch}';
    final tt = DateTime.now().millisecondsSinceEpoch.toString();

    final response = await dio.get(
      config.generateEndpoint,
      queryParameters: {
        'lp': 'pc',
        'qrloginfrom': 'pc',
        'gid': gid,
        'callback': callback,
        'apiver': 'v3',
        'tt': tt,
        'tpl': 'netdisk',
        'logPage': 'traceId:pc_loginv5_$tt,logPage:loginv5',
        '_': tt,
      },
    );

    final data = BaiduLoginUtils.parseJsonp(response.data?.toString() ?? '{}');
    final sign = data['sign']?.toString();
    var img =
        data['imgurl']?.toString() ??
        data['imgurlmm']?.toString() ??
        data['imgurlmgurl']?.toString();

    if (sign == null || sign.isEmpty || img == null || img.isEmpty) {
      throw Exception('二维码生成失败，返回数据缺少 sign 或 imgurl');
    }

    if (img.startsWith('//')) {
      img = 'https:$img';
    } else if (!img.startsWith('http')) {
      img = 'https://$img';
    }

    final setCookie = response.headers['set-cookie'];
    final cookie =
        setCookie != null && setCookie.isNotEmpty
            ? BaiduLoginUtils.mergeSetCookie(setCookie)
            : '';

    _sessionStore[sign] = {
      'gid': gid,
      'sign': sign,
      'img': img,
      if (cookie.isNotEmpty) 'cookie': cookie,
    };

    return QRLoginInfo(
      qrId: sign,
      // 不再把图片 URL 编码成二维码，直接展示图片
      qrContent: sign,
      qrImageUrl: img,
      expiresAt: DateTime.now().add(Duration(seconds: config.qrExpireTime)),
      pollInterval: config.pollInterval,
      maxPollCount: config.maxPollCount,
      status: QRLoginStatus.ready,
      message: '请使用百度网盘 APP 扫码登录',
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

    final dio = _createDio(cookie: session['cookie']);
    final tt = DateTime.now().millisecondsSinceEpoch.toString();
    final callback = 'tangram_guid_$tt';
    final response = await dio.get(
      config.statusEndpoint,
      queryParameters: {
        'channel_id': qrId,
        'gid': session['gid'] ?? '',
        'tpl': 'netdisk',
        '_sdkFrom': '1',
        'callback': callback,
        'apiver': 'v3',
        'tt': tt,
        '_': tt,
      },
    );

    final data = BaiduLoginUtils.parseJsonp(response.data?.toString() ?? '{}');
    final errno = int.tryParse(data['errno']?.toString() ?? '') ?? -1;
    final channelRaw = data['channel_v']?.toString();
    Map<String, dynamic> channel = {};
    if (channelRaw != null && channelRaw.isNotEmpty) {
      try {
        channel = jsonDecode(channelRaw) as Map<String, dynamic>;
      } catch (_) {
        // ignore parse error
      }
    }

    // errno: 1=未扫码/等待，0=有状态返回，其他=异常
    if (errno == 1) {
      return QRLoginInfo(
        qrId: qrId,
        qrContent: session['img'] ?? session['sign'] ?? qrId,
        status: QRLoginStatus.waiting,
        message: '等待扫码',
      );
    }
    if (errno != 0) {
      return QRLoginInfo(
        qrId: qrId,
        qrContent: session['img'] ?? session['sign'] ?? qrId,
        status: QRLoginStatus.failed,
        message: '登录失败: errno=$errno',
      );
    }

    final status = channel['status'] as int? ?? -1;
    final v = channel['v']?.toString();
    QRLoginStatus qrStatus = QRLoginStatus.waiting;
    String msg = '等待扫码';

    switch (status) {
      case 0: // 扫码确认成功
        qrStatus = QRLoginStatus.success;
        msg = '登录成功';
        break;
      case 1: // 已扫码，等待确认
        qrStatus = QRLoginStatus.scanned;
        msg = '已扫码，等待确认';
        break;
      case 2: // 过期
        qrStatus = QRLoginStatus.expired;
        msg = '二维码已过期';
        break;
      case 3: // 取消/拒绝
        qrStatus = QRLoginStatus.cancelled;
        msg = '已取消或拒绝';
        break;
      default:
        qrStatus = QRLoginStatus.waiting;
        msg = '等待扫码';
    }

    String? cookies;
    if (qrStatus == QRLoginStatus.success && v != null && v.isNotEmpty) {
      cookies = await _exchangeBDUSS(vCode: v, session: session);
      if (cookies != null && cookies.isNotEmpty) {
        _sessionStore[qrId]?['cookie'] = cookies;
      }
    }

    return QRLoginInfo(
      qrId: qrId,
      qrContent: session['img'] ?? session['sign'] ?? qrId,
      status: qrStatus,
      message: msg,
      loginToken: cookies,
      userInfo: {
        'errno': errno,
        'status': status,
        if (v != null) 'v': v,
        if (cookies != null) 'cookie': cookies,
      },
    );
  }

  @override
  Future<void> cancelQRLogin(String qrId) async {
    _sessionStore.remove(qrId);
  }

  @override
  Future<String> parseAuthData(QRLoginInfo loginInfo) async {
    if (loginInfo.loginToken != null && loginInfo.loginToken!.isNotEmpty) {
      return loginInfo.loginToken!;
    }
    final cookies = loginInfo.userInfo?['cookie']?.toString();
    if (cookies != null && cookies.isNotEmpty) return cookies;
    throw Exception('未获取到登录 Cookie，请重新扫码');
  }

  Future<String?> _exchangeBDUSS({
    required String vCode,
    required Map<String, String> session,
  }) async {
    final dio = _createDio(cookie: session['cookie']);
    final now = DateTime.now();
    final tt = now.millisecondsSinceEpoch.toString();
    final timeSeconds = (now.millisecondsSinceEpoch ~/ 1000).toString();
    final callback = 'bd__cbs__${tt.substring(tt.length - 6)}';
    final response = await dio.get(
      '/v3/login/main/qrbdusslogin',
      queryParameters: {
        // 接口参数与网页一致：bduss=channel返回的v
        'bduss': vCode,
        'apiver': 'v3',
        'tt': tt,
        'tpl': 'netdisk',
        'u': 'https://pan.baidu.com/disk/home',
        'gid': session['gid'] ?? '',
        'loginVersion': 'v5',
        'qrcode': '1',
        'loginType': '3',
        'logLogin': 'pc',
        'alg': 'v3',
        'time': timeSeconds,
        'callback': callback,
      },
      options: Options(followRedirects: false, validateStatus: (_) => true),
    );

    final setCookie = response.headers['set-cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      final cookie = BaiduLoginUtils.mergeSetCookie(setCookie);
      if (cookie.contains('BDUSS') || cookie.contains('STOKEN')) {
        return cookie;
      }
    }

    // 部分情况下不会直接下发 BDUSS，这里尝试读取响应体中的 bduss 字段。
    final data = BaiduLoginUtils.parseJsonp(response.data?.toString() ?? '{}');
    final bduss = data['bduss']?.toString();
    final ptoken = data['ptoken']?.toString();
    final stoken = data['stoken']?.toString();

    final manualCookie = <String>[];
    if (bduss != null && bduss.isNotEmpty) manualCookie.add('BDUSS=$bduss');
    if (ptoken != null && ptoken.isNotEmpty) manualCookie.add('PTOKEN=$ptoken');
    if (stoken != null && stoken.isNotEmpty) manualCookie.add('STOKEN=$stoken');
    return manualCookie.isEmpty ? null : manualCookie.join('; ');
  }
}
