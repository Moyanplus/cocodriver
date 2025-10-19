import 'package:flutter/material.dart';
import 'cloud_drive_configs.dart';

/// 认证方式枚举
enum AuthType {
  /// Cookie认证
  cookie,

  /// Authorization Bearer Token认证
  authorization,

  /// 二维码扫码认证
  qrCode,
}

/// 云盘类型枚举
enum CloudDriveType {
  /// 百度网盘
  baidu,

  /// 蓝奏云
  lanzou,

  /// 123云盘
  pan123,

  /// 阿里云盘
  ali,

  /// 夸克云盘
  quark,
}

/// 云盘类型扩展
extension CloudDriveTypeExtension on CloudDriveType {
  String get displayName {
    switch (this) {
      case CloudDriveType.baidu:
        return '百度网盘';
      case CloudDriveType.lanzou:
        return '蓝奏云';
      case CloudDriveType.pan123:
        return '123云盘';
      case CloudDriveType.ali:
        return '阿里云盘';
      case CloudDriveType.quark:
        return '夸克云盘';
    }
  }

  IconData get iconData {
    switch (this) {
      case CloudDriveType.baidu:
        return Icons.cloud;
      case CloudDriveType.lanzou:
        return Icons.link;
      case CloudDriveType.pan123:
        return Icons.storage;
      case CloudDriveType.ali:
        return Icons.cloud_done;
      case CloudDriveType.quark:
        return Icons.cloud_queue;
    }
  }

  Color get color {
    switch (this) {
      case CloudDriveType.baidu:
        return Colors.blue;
      case CloudDriveType.lanzou:
        return Colors.orange;
      case CloudDriveType.pan123:
        return Colors.green;
      case CloudDriveType.ali:
        return Colors.red;
      case CloudDriveType.quark:
        return Colors.purple;
    }
  }

  String get icon {
    switch (this) {
      case CloudDriveType.baidu:
        return 'assets/icons/baidu.png';
      case CloudDriveType.lanzou:
        return 'assets/icons/lanzou.png';
      case CloudDriveType.pan123:
        return 'assets/icons/pan123.png';
      case CloudDriveType.ali:
        return 'assets/icons/ali.png';
      case CloudDriveType.quark:
        return 'assets/icons/quark.png';
    }
  }

  AuthType get authType {
    switch (this) {
      case CloudDriveType.ali:
        return AuthType.authorization;
      case CloudDriveType.baidu:
      case CloudDriveType.lanzou:
      case CloudDriveType.pan123:
      case CloudDriveType.quark:
        return AuthType.cookie;
    }
  }

  /// 获取支持的认证方式列表
  List<AuthType> get supportedAuthTypes {
    switch (this) {
      case CloudDriveType.ali:
        return [AuthType.authorization, AuthType.qrCode];
      case CloudDriveType.baidu:
        return [AuthType.cookie, AuthType.qrCode];
      case CloudDriveType.lanzou:
        return [AuthType.cookie];
      case CloudDriveType.pan123:
        return [AuthType.cookie, AuthType.qrCode];
      case CloudDriveType.quark:
        return [AuthType.cookie, AuthType.qrCode];
    }
  }

  CloudDriveWebViewConfig get webViewConfig {
    switch (this) {
      case CloudDriveType.baidu:
        return CloudDriveWebViewConfig(
          initialUrl: 'https://pan.baidu.com/',
          userAgentType: UserAgentType.pcChrome,
          rootDir: '/',
          tokenConfig: TokenConfig.baiduDriveConfig,
          loginDetectionConfig: LoginDetectionConfig.baiduConfig,
          cookieProcessingConfig: CookieProcessingConfig.defaultConfig,
          requestInterceptConfig: RequestInterceptConfig.cookieBasedConfig,
        );
      case CloudDriveType.lanzou:
        return CloudDriveWebViewConfig(
          initialUrl: 'https://www.lanzou.com/',
          userAgentType: UserAgentType.pcChrome,
          rootDir: '/',
          loginDetectionConfig: LoginDetectionConfig.lanzouConfig,
          cookieProcessingConfig: CookieProcessingConfig.lanzouConfig,
          requestInterceptConfig: RequestInterceptConfig.cookieBasedConfig,
        );
      case CloudDriveType.pan123:
        return CloudDriveWebViewConfig(
          initialUrl: 'https://www.123pan.com/',
          userAgentType: UserAgentType.pcChrome,
          rootDir: '/',
          loginDetectionConfig: LoginDetectionConfig.pan123Config,
          cookieProcessingConfig: CookieProcessingConfig.pan123Config,
          requestInterceptConfig: RequestInterceptConfig.cookieBasedConfig,
        );
      case CloudDriveType.ali:
        return CloudDriveWebViewConfig(
          initialUrl: 'https://www.aliyundrive.com/sign/in',
          userAgentType: UserAgentType.pcChrome,
          rootDir: 'root',
          tokenConfig: TokenConfig.aliDriveConfig,
          loginDetectionConfig: LoginDetectionConfig.aliConfig,
          cookieProcessingConfig: CookieProcessingConfig.defaultConfig,
          requestInterceptConfig: RequestInterceptConfig.tokenBasedConfig,
        );
      case CloudDriveType.quark:
        return CloudDriveWebViewConfig(
          initialUrl: 'https://pan.quark.cn/',
          userAgentType: UserAgentType.pcChrome,
          rootDir: '/',
          loginDetectionConfig: LoginDetectionConfig.quarkConfig,
          cookieProcessingConfig: CookieProcessingConfig.quarkConfig,
          requestInterceptConfig: RequestInterceptConfig.cookieBasedConfig,
        );
    }
  }
}

/// 云盘账号模型
class CloudDriveAccount {
  final String id;
  final String name;
  final CloudDriveType type;
  final String? cookies;
  final String? authorizationToken;
  final String? qrCodeToken; // 二维码登录token
  final String? avatarUrl;
  final String? driveId;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const CloudDriveAccount({
    required this.id,
    required this.name,
    required this.type,
    this.cookies,
    this.authorizationToken,
    this.qrCodeToken,
    this.avatarUrl,
    this.driveId,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// 检查是否已登录
  bool get isLoggedIn {
    switch (type.authType) {
      case AuthType.cookie:
        return cookies != null && cookies!.isNotEmpty;
      case AuthType.authorization:
        return authorizationToken != null && authorizationToken!.isNotEmpty;
      case AuthType.qrCode:
        return qrCodeToken != null && qrCodeToken!.isNotEmpty;
    }
  }

  /// 获取认证头信息
  Map<String, String> get authHeaders {
    switch (type.authType) {
      case AuthType.cookie:
        return cookies != null && cookies!.isNotEmpty
            ? {'Cookie': cookies!}
            : {};
      case AuthType.authorization:
        return authorizationToken != null && authorizationToken!.isNotEmpty
            ? {'Authorization': 'Bearer $authorizationToken'}
            : {};
      case AuthType.qrCode:
        return qrCodeToken != null && qrCodeToken!.isNotEmpty
            ? {'Authorization': 'Bearer $qrCodeToken'}
            : {};
    }
  }

  /// 从JSON创建实例
  factory CloudDriveAccount.fromJson(Map<String, dynamic> json) =>
      CloudDriveAccount(
        id:
            json['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: json['name']?.toString() ?? '未知账号',
        type: CloudDriveType.values.firstWhere(
          (e) => e.name == json['type']?.toString(),
          orElse: () => CloudDriveType.baidu,
        ),
        cookies: json['cookies']?.toString(),
        authorizationToken: json['authorizationToken']?.toString(),
        qrCodeToken: json['qrCodeToken']?.toString(),
        avatarUrl: json['avatarUrl']?.toString(),
        driveId: json['driveId']?.toString(),
        createdAt:
            json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt'].toString()) ??
                    DateTime.now()
                : DateTime.now(),
        lastLoginAt:
            json['lastLoginAt'] != null
                ? DateTime.tryParse(json['lastLoginAt'].toString())
                : null,
      );

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'cookies': cookies,
    'authorizationToken': authorizationToken,
    'qrCodeToken': qrCodeToken,
    'avatarUrl': avatarUrl,
    'driveId': driveId,
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
  };

  /// 复制并更新
  CloudDriveAccount copyWith({
    String? id,
    String? name,
    CloudDriveType? type,
    String? cookies,
    String? authorizationToken,
    String? qrCodeToken,
    String? avatarUrl,
    String? driveId,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) => CloudDriveAccount(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    cookies: cookies ?? this.cookies,
    authorizationToken: authorizationToken ?? this.authorizationToken,
    qrCodeToken: qrCodeToken ?? this.qrCodeToken,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    driveId: driveId ?? this.driveId,
    createdAt: createdAt ?? this.createdAt,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudDriveAccount &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CloudDriveAccount{id: $id, name: $name, type: $type}';
}

/// 云盘文件模型
class CloudDriveFile {
  final String id;
  final String name;
  final bool isFolder;
  final int? size;
  final DateTime? modifiedTime;
  final String? folderId;
  final String? downloadUrl;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;

  const CloudDriveFile({
    required this.id,
    required this.name,
    required this.isFolder,
    this.size,
    this.modifiedTime,
    this.folderId,
    this.downloadUrl,
    this.thumbnailUrl,
    this.metadata,
  });

  /// 格式化文件大小
  String get formattedSize {
    if (size == null || size == 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double fileSize = size!.toDouble();

    while (fileSize >= 1024 && unitIndex < units.length - 1) {
      fileSize /= 1024;
      unitIndex++;
    }

    return '${fileSize.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// 获取文件图标
  IconData get icon {
    if (isFolder) return Icons.folder;

    final extension = name.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
        return Icons.audio_file;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// 从JSON创建实例
  factory CloudDriveFile.fromJson(Map<String, dynamic> json) => CloudDriveFile(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    isFolder: json['isFolder'] as bool? ?? false,
    size: json['size'] as int?,
    modifiedTime:
        json['modifiedTime'] != null
            ? DateTime.tryParse(json['modifiedTime'].toString())
            : null,
    folderId: json['folderId']?.toString(),
    downloadUrl: json['downloadUrl']?.toString(),
    thumbnailUrl: json['thumbnailUrl']?.toString(),
    metadata: json['metadata'] as Map<String, dynamic>?,
  );

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isFolder': isFolder,
    'size': size,
    'modifiedTime': modifiedTime?.toIso8601String(),
    'folderId': folderId,
    'downloadUrl': downloadUrl,
    'thumbnailUrl': thumbnailUrl,
    'metadata': metadata,
  };

  /// 复制并更新
  CloudDriveFile copyWith({
    String? id,
    String? name,
    bool? isFolder,
    int? size,
    DateTime? modifiedTime,
    String? folderId,
    String? downloadUrl,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
  }) => CloudDriveFile(
    id: id ?? this.id,
    name: name ?? this.name,
    isFolder: isFolder ?? this.isFolder,
    size: size ?? this.size,
    modifiedTime: modifiedTime ?? this.modifiedTime,
    folderId: folderId ?? this.folderId,
    downloadUrl: downloadUrl ?? this.downloadUrl,
    thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    metadata: metadata ?? this.metadata,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudDriveFile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CloudDriveFile{id: $id, name: $name, isFolder: $isFolder}';
}
