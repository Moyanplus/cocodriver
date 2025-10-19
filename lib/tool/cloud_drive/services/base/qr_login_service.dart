import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/qr_login_models.dart';
import '../../models/cloud_drive_models.dart';

/// 二维码登录服务抽象基类
/// 每个云盘服务需要实现此接口来提供具体的二维码登录功能
abstract class QRLoginService {
  /// 云盘类型
  CloudDriveType get cloudDriveType;

  /// 二维码登录配置
  QRLoginConfig get config;

  /// 生成二维码登录信息
  /// 返回包含二维码ID、内容等信息的QRLoginInfo对象
  Future<QRLoginInfo> generateQRCode();

  /// 查询二维码登录状态
  /// [qrId] 二维码ID
  /// 返回更新后的QRLoginInfo对象
  Future<QRLoginInfo> checkQRStatus(String qrId);

  /// 取消二维码登录
  /// [qrId] 二维码ID
  Future<void> cancelQRLogin(String qrId);

  /// 解析登录成功后的认证数据
  /// [loginInfo] 包含登录token的QRLoginInfo对象
  /// 返回可用于API调用的认证数据（如Cookie或Token）
  Future<String> parseAuthData(QRLoginInfo loginInfo);

  /// 获取二维码登录的显示名称
  String get displayName => '${cloudDriveType.displayName}二维码登录';

  /// 获取二维码登录的图标
  IconData get icon => Icons.qr_code;

  /// 获取二维码登录的颜色
  Color get color => cloudDriveType.color;
}

/// 二维码登录管理器
/// 负责管理二维码登录的整个生命周期
class QRLoginManager {
  static final Map<CloudDriveType, QRLoginService> _services = {};
  static final Map<String, StreamController<QRLoginInfo>> _statusStreams = {};

  /// 注册二维码登录服务
  static void registerService(QRLoginService service) {
    _services[service.cloudDriveType] = service;
  }

  /// 获取二维码登录服务
  static QRLoginService? getService(CloudDriveType type) {
    return _services[type];
  }

  /// 检查是否支持二维码登录
  static bool isSupported(CloudDriveType type) {
    return _services.containsKey(type);
  }

  /// 获取所有支持的云盘类型
  static List<CloudDriveType> getSupportedTypes() {
    return _services.keys.toList();
  }

  /// 开始二维码登录流程
  /// [type] 云盘类型
  /// 返回状态流，用于监听登录进度
  static Stream<QRLoginInfo> startQRLogin(CloudDriveType type) async* {
    final service = getService(type);
    if (service == null) {
      throw Exception('${type.displayName}不支持二维码登录');
    }

    StreamController<QRLoginInfo>? streamController;
    Timer? timer;

    try {
      // 生成二维码
      var loginInfo = await service.generateQRCode();
      streamController = StreamController<QRLoginInfo>();
      _statusStreams[loginInfo.qrId] = streamController;

      // 发送初始状态
      yield loginInfo;
      streamController.add(loginInfo);

      // 开始轮询状态
      int pollCount = 0;

      timer = Timer.periodic(Duration(seconds: loginInfo.pollInterval), (
        timer,
      ) async {
        try {
          pollCount++;

          // 检查是否超过最大轮询次数
          if (pollCount > loginInfo.maxPollCount) {
            loginInfo = loginInfo.copyWith(
              status: QRLoginStatus.expired,
              message: '二维码已过期，请重新生成',
            );
            streamController?.add(loginInfo);
            timer.cancel();
            return;
          }

          // 检查是否已过期
          if (loginInfo.isExpired) {
            loginInfo = loginInfo.copyWith(
              status: QRLoginStatus.expired,
              message: '二维码已过期',
            );
            streamController?.add(loginInfo);
            timer.cancel();
            return;
          }

          // 查询状态
          final updatedInfo = await service.checkQRStatus(loginInfo.qrId);
          loginInfo = updatedInfo;

          streamController?.add(loginInfo);

          // 如果登录成功或失败，停止轮询
          if (loginInfo.status == QRLoginStatus.success ||
              loginInfo.status == QRLoginStatus.failed ||
              loginInfo.status == QRLoginStatus.cancelled) {
            timer.cancel();
          }
        } catch (e) {
          // 轮询出错，继续下一次
          print('轮询状态出错: $e');
        }
      });

      // 监听流并yield数据
      await for (final info in streamController.stream) {
        yield info;
        if (info.status == QRLoginStatus.success ||
            info.status == QRLoginStatus.failed ||
            info.status == QRLoginStatus.cancelled ||
            info.status == QRLoginStatus.expired) {
          break;
        }
      }
    } catch (e) {
      // 发送错误状态
      if (streamController != null && !streamController.isClosed) {
        streamController.add(
          QRLoginInfo(
            qrId: '',
            qrContent: '',
            status: QRLoginStatus.failed,
            message: '登录失败: $e',
          ),
        );
      }
      rethrow;
    } finally {
      // 清理资源
      timer?.cancel();
      streamController?.close();
      if (streamController != null) {
        _statusStreams.removeWhere((key, value) => value == streamController);
      }
    }
  }

  /// 取消二维码登录
  static Future<void> cancelQRLogin(String qrId) async {
    final streamController = _statusStreams[qrId];
    if (streamController != null) {
      streamController.add(
        QRLoginInfo(
          qrId: qrId,
          qrContent: '',
          status: QRLoginStatus.cancelled,
          message: '用户取消登录',
        ),
      );
      streamController.close();
      _statusStreams.remove(qrId);
    }
  }

  /// 清理所有资源
  static void dispose() {
    for (final controller in _statusStreams.values) {
      controller.close();
    }
    _statusStreams.clear();
  }
}
