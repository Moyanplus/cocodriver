import 'package:flutter/material.dart';

/// 二维码登录状态枚举
enum QRLoginStatus {
  /// 等待生成二维码
  waiting,

  /// 二维码已生成，等待扫码
  ready,

  /// 已扫码，等待确认
  scanned,

  /// 登录成功
  success,

  /// 登录失败
  failed,

  /// 二维码已过期
  expired,

  /// 用户取消
  cancelled,
}

/// 二维码登录状态扩展
extension QRLoginStatusExtension on QRLoginStatus {
  String get displayName {
    switch (this) {
      case QRLoginStatus.waiting:
        return '正在生成二维码...';
      case QRLoginStatus.ready:
        return '请使用手机扫描二维码';
      case QRLoginStatus.scanned:
        return '请在手机上确认登录';
      case QRLoginStatus.success:
        return '登录成功';
      case QRLoginStatus.failed:
        return '登录失败';
      case QRLoginStatus.expired:
        return '二维码已过期';
      case QRLoginStatus.cancelled:
        return '已取消登录';
    }
  }

  Color get color {
    switch (this) {
      case QRLoginStatus.waiting:
        return Colors.orange;
      case QRLoginStatus.ready:
        return Colors.blue;
      case QRLoginStatus.scanned:
        return Colors.purple;
      case QRLoginStatus.success:
        return Colors.green;
      case QRLoginStatus.failed:
        return Colors.red;
      case QRLoginStatus.expired:
        return Colors.grey;
      case QRLoginStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case QRLoginStatus.waiting:
        return Icons.hourglass_empty;
      case QRLoginStatus.ready:
        return Icons.qr_code;
      case QRLoginStatus.scanned:
        return Icons.phone_android;
      case QRLoginStatus.success:
        return Icons.check_circle;
      case QRLoginStatus.failed:
        return Icons.error;
      case QRLoginStatus.expired:
        return Icons.schedule;
      case QRLoginStatus.cancelled:
        return Icons.cancel;
    }
  }
}

/// 二维码登录信息模型
class QRLoginInfo {
  /// 二维码ID
  final String qrId;

  /// 二维码内容
  final String qrContent;

  /// 二维码图片URL（可选）
  final String? qrImageUrl;

  /// 二维码过期时间
  final DateTime? expiresAt;

  /// 轮询间隔（秒）
  final int pollInterval;

  /// 最大轮询次数
  final int maxPollCount;

  /// 当前状态
  final QRLoginStatus status;

  /// 状态消息
  final String? message;

  /// 登录token（成功时）
  final String? loginToken;

  /// 用户信息（成功时）
  final Map<String, dynamic>? userInfo;

  const QRLoginInfo({
    required this.qrId,
    required this.qrContent,
    this.qrImageUrl,
    this.expiresAt,
    this.pollInterval = 2,
    this.maxPollCount = 150, // 5分钟
    this.status = QRLoginStatus.waiting,
    this.message,
    this.loginToken,
    this.userInfo,
  });

  /// 复制并更新
  QRLoginInfo copyWith({
    String? qrId,
    String? qrContent,
    String? qrImageUrl,
    DateTime? expiresAt,
    int? pollInterval,
    int? maxPollCount,
    QRLoginStatus? status,
    String? message,
    String? loginToken,
    Map<String, dynamic>? userInfo,
  }) => QRLoginInfo(
    qrId: qrId ?? this.qrId,
    qrContent: qrContent ?? this.qrContent,
    qrImageUrl: qrImageUrl ?? this.qrImageUrl,
    expiresAt: expiresAt ?? this.expiresAt,
    pollInterval: pollInterval ?? this.pollInterval,
    maxPollCount: maxPollCount ?? this.maxPollCount,
    status: status ?? this.status,
    message: message ?? this.message,
    loginToken: loginToken ?? this.loginToken,
    userInfo: userInfo ?? this.userInfo,
  );

  /// 检查是否已过期
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 获取剩余时间（秒）
  int get remainingSeconds {
    if (expiresAt == null) return -1;
    final remaining = expiresAt!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// 从JSON创建实例
  factory QRLoginInfo.fromJson(Map<String, dynamic> json) => QRLoginInfo(
    qrId: json['qrId']?.toString() ?? '',
    qrContent: json['qrContent']?.toString() ?? '',
    qrImageUrl: json['qrImageUrl']?.toString(),
    expiresAt:
        json['expiresAt'] != null
            ? DateTime.tryParse(json['expiresAt'].toString())
            : null,
    pollInterval: json['pollInterval'] as int? ?? 2,
    maxPollCount: json['maxPollCount'] as int? ?? 150,
    status: QRLoginStatus.values.firstWhere(
      (e) => e.name == json['status']?.toString(),
      orElse: () => QRLoginStatus.waiting,
    ),
    message: json['message']?.toString(),
    loginToken: json['loginToken']?.toString(),
    userInfo: json['userInfo'] as Map<String, dynamic>?,
  );

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'qrId': qrId,
    'qrContent': qrContent,
    'qrImageUrl': qrImageUrl,
    'expiresAt': expiresAt?.toIso8601String(),
    'pollInterval': pollInterval,
    'maxPollCount': maxPollCount,
    'status': status.name,
    'message': message,
    'loginToken': loginToken,
    'userInfo': userInfo,
  };
}

/// 二维码登录配置
class QRLoginConfig {
  /// 二维码生成API端点
  final String generateEndpoint;

  /// 状态查询API端点
  final String statusEndpoint;

  /// 请求头配置
  final Map<String, String> headers;

  /// 超时时间（秒）
  final int timeout;

  /// 轮询间隔（秒）
  final int pollInterval;

  /// 最大轮询次数
  final int maxPollCount;

  /// 二维码过期时间（秒）
  final int qrExpireTime;

  const QRLoginConfig({
    required this.generateEndpoint,
    required this.statusEndpoint,
    this.headers = const {},
    this.timeout = 30,
    this.pollInterval = 2,
    this.maxPollCount = 150,
    this.qrExpireTime = 300, // 5分钟
  });
}
