import 'package:flutter/material.dart';
import 'cloud_drive_entities.dart';

/// 路径信息模型
class PathInfo {
  final String id;
  final String name;

  const PathInfo({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'PathInfo{id: $id, name: $name}';
}

/// 云盘账号信息模型
class CloudDriveAccountInfo {
  final String username;
  final String? phone;
  final String? photo;
  final int uk; // 用户唯一标识
  final bool isVip;
  final bool isSvip;
  final bool isScanVip;
  final int loginState;

  const CloudDriveAccountInfo({
    required this.username,
    this.phone,
    this.photo,
    required this.uk,
    this.isVip = false,
    this.isSvip = false,
    this.isScanVip = false,
    this.loginState = 0,
  });

  /// 从百度网盘API响应创建实例
  factory CloudDriveAccountInfo.fromBaiduResponse(
    Map<String, dynamic> userInfo,
  ) => CloudDriveAccountInfo(
    username: userInfo['username']?.toString() ?? '未知用户',
    phone: userInfo['phone']?.toString(),
    photo: userInfo['photo']?.toString(),
    uk: userInfo['uk'] as int? ?? 0,
    isVip: (userInfo['is_vip'] as int? ?? 0) == 1,
    isSvip: (userInfo['is_svip'] as int? ?? 0) == 1,
    isScanVip: (userInfo['is_scan_vip'] as int? ?? 0) == 1,
    loginState: userInfo['loginstate'] as int? ?? 0,
  );

  /// 获取会员状态描述
  String get vipStatusDescription {
    if (isSvip) return '超级会员';
    if (isVip) return '普通会员';
    return '普通用户';
  }

  /// 是否已登录
  bool get isLoggedIn => loginState == 1;

  @override
  String toString() =>
      'CloudDriveAccountInfo{username: $username, uk: $uk, vipStatus: $vipStatusDescription, isLoggedIn: $isLoggedIn}';
}

/// 云盘容量信息模型
class CloudDriveQuotaInfo {
  final int total; // 总容量（字节）
  final int used; // 已使用（字节）
  final int free; // 免费容量（字节）
  final bool expire; // 是否过期
  final int serverTime; // 服务器时间戳

  const CloudDriveQuotaInfo({
    required this.total,
    required this.used,
    this.free = 0,
    this.expire = false,
    required this.serverTime,
  });

  /// 从百度网盘API响应创建实例
  factory CloudDriveQuotaInfo.fromBaiduResponse(
    Map<String, dynamic> response,
  ) => CloudDriveQuotaInfo(
    total: response['total'] as int? ?? 0,
    used: response['used'] as int? ?? 0,
    free: response['free'] as int? ?? 0,
    expire: response['expire'] as bool? ?? false,
    serverTime:
        response['server_time'] as int? ??
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
  );

  /// 可用容量（字节）
  int get available => total - used;

  /// 使用率（百分比）
  double get usagePercentage => total > 0 ? (used / total) * 100 : 0.0;

  /// 格式化文件大小
  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// 格式化总容量
  String get formattedTotal => _formatSize(total);

  /// 格式化已使用容量
  String get formattedUsed => _formatSize(used);

  /// 格式化可用容量
  String get formattedAvailable => _formatSize(available);

  @override
  String toString() =>
      'CloudDriveQuotaInfo{total: $formattedTotal, used: $formattedUsed, available: $formattedAvailable, usage: ${usagePercentage.toStringAsFixed(1)}%}';
}

/// 云盘账号详情模型
class CloudDriveAccountDetails {
  final CloudDriveAccountInfo accountInfo;
  final CloudDriveQuotaInfo quotaInfo;

  const CloudDriveAccountDetails({
    required this.accountInfo,
    required this.quotaInfo,
  });

  @override
  String toString() =>
      'CloudDriveAccountDetails{accountInfo: $accountInfo, quotaInfo: $quotaInfo}';
}

/// 下载配置模型
class DownloadConfig {
  final String? fileName;
  final int? size;
  final Map<String, String> customHeaders;
  final Duration timeout;
  final bool enableResume;
  final int maxRetries;

  const DownloadConfig({
    this.fileName,
    this.size,
    this.customHeaders = const {},
    this.timeout = const Duration(minutes: 30),
    this.enableResume = true,
    this.maxRetries = 3,
  });

  /// 默认下载配置
  static const DownloadConfig defaultConfig = DownloadConfig(
    timeout: Duration(minutes: 30),
    enableResume: true,
    maxRetries: 3,
  );

  /// 创建自定义配置
  DownloadConfig copyWith({
    String? fileName,
    int? size,
    Map<String, String>? customHeaders,
    Duration? timeout,
    bool? enableResume,
    int? maxRetries,
  }) => DownloadConfig(
    fileName: fileName ?? this.fileName,
    size: size ?? this.size,
    customHeaders: customHeaders ?? this.customHeaders,
    timeout: timeout ?? this.timeout,
    enableResume: enableResume ?? this.enableResume,
    maxRetries: maxRetries ?? this.maxRetries,
  );
}

/// 批量操作配置模型
class BatchOperationConfig {
  final int maxConcurrent;
  final Duration delayBetweenOperations;
  final bool stopOnError;
  final Function(int, int)? onProgress;

  const BatchOperationConfig({
    this.maxConcurrent = 3,
    this.delayBetweenOperations = const Duration(milliseconds: 500),
    this.stopOnError = false,
    this.onProgress,
  });

  /// 默认批量操作配置
  static const BatchOperationConfig defaultConfig = BatchOperationConfig(
    maxConcurrent: 3,
    delayBetweenOperations: Duration(milliseconds: 500),
    stopOnError: false,
  );
}

/// 操作结果模型
class OperationResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? data;
  final Duration duration;

  const OperationResult({
    required this.success,
    this.error,
    this.data,
    required this.duration,
  });

  /// 成功结果
  factory OperationResult.success({
    Map<String, dynamic>? data,
    Duration? duration,
  }) => OperationResult(
    success: true,
    data: data,
    duration: duration ?? Duration.zero,
  );

  /// 失败结果
  factory OperationResult.failure({
    required String error,
    Duration? duration,
  }) => OperationResult(
    success: false,
    error: error,
    duration: duration ?? Duration.zero,
  );

  @override
  String toString() =>
      'OperationResult{success: $success, error: $error, duration: ${duration.inMilliseconds}ms}';
}

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
