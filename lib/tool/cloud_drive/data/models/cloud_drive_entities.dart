import 'package:flutter/material.dart';
import 'cloud_drive_configs.dart';
import 'cloud_drive_dtos.dart';
import '../../services/provider/cloud_drive_provider_registry.dart';
import '../../services/provider/cloud_drive_provider_descriptor.dart';

/// 云盘核心数据模型
///
/// 定义云盘相关的核心实体类、枚举和扩展，包括云盘类型、账号、文件等。

/// 云盘类型辅助类
class CloudDriveTypeHelper {
  /// 获取所有可用的云盘类型
  static List<CloudDriveType> get availableTypes {
    // 只依赖注册表，新增云盘需注册描述后才会出现在列表
    return CloudDriveProviderRegistry.descriptors
        .map((d) => d.type)
        .where((t) => t.isAvailable)
        .toList();
  }
}

/// 认证方式枚举
enum AuthType {
  /// Cookie认证
  cookie,

  /// Authorization Token认证
  authorization,

  /// WebView网页登录认证
  web,

  /// 二维码扫码认证
  qrCode,
}

/// 文件分类枚举
enum FileCategory {
  /// 图片
  image,

  /// 视频
  video,

  /// 音频
  audio,

  /// 文档
  document,

  /// 压缩包
  archive,

  /// 其他
  other,
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

  /// 中国移动云盘
  chinaMobile,
}

/// 云盘类型扩展
///
/// 为 CloudDriveType 枚举提供显示名称、图标、颜色等扩展功能。
extension CloudDriveTypeExtension on CloudDriveType {
  CloudDriveProviderDescriptor _requireDescriptor() {
    final descriptor = CloudDriveProviderRegistry.get(this);
    if (descriptor == null) {
      throw StateError('未在 CloudDriveProviderRegistry 注册 $this');
    }
    return descriptor;
  }

  String get displayName {
    final descriptor = _requireDescriptor();
    return descriptor.displayName ?? name;
  }

  IconData get iconData {
    final descriptor = _requireDescriptor();
    return descriptor.iconData ?? Icons.cloud_outlined;
  }

  Color get color {
    final descriptor = _requireDescriptor();
    return descriptor.color ?? Colors.blueGrey;
  }

  String get icon {
    final descriptor = _requireDescriptor();
    return descriptor.iconAsset ?? 'assets/icons/default_cloud.png';
  }

  AuthType get authType {
    final supported = supportedAuthTypes;
    return supported.isNotEmpty ? supported.first : AuthType.cookie;
  }

  /// 获取支持的认证方式列表
  ///
  /// Authorization 和 Cookie 是互斥的，只会返回其中一个
  List<AuthType> get supportedAuthTypes {
    final descriptor = _requireDescriptor();
    if (descriptor.supportedAuthTypes == null ||
        descriptor.supportedAuthTypes!.isEmpty) {
      throw StateError('$this 未声明 supportedAuthTypes，请在描述中补充。');
    }
    return descriptor.supportedAuthTypes!;
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
      case CloudDriveType.chinaMobile:
        return CloudDriveWebViewConfig(
          initialUrl: 'https://yun.139.com/',
          userAgentType: UserAgentType.pcChrome,
          rootDir: '/',
          loginDetectionConfig: LoginDetectionConfig.chinaMobileConfig,
          cookieProcessingConfig: CookieProcessingConfig.chinaMobileConfig,
          requestInterceptConfig: RequestInterceptConfig.cookieBasedConfig,
        );
    }
  }

  /// 获取云盘配置
  CloudDriveConfig get config {
    switch (this) {
      case CloudDriveType.baidu:
        return CloudDriveConfig.baidu;
      case CloudDriveType.ali:
        return CloudDriveConfig.aliyun;
      case CloudDriveType.lanzou:
        return CloudDriveConfig.lanzou;
      case CloudDriveType.pan123:
        return CloudDriveConfig.pan123;
      case CloudDriveType.quark:
        return CloudDriveConfig.quark;
      case CloudDriveType.chinaMobile:
        return CloudDriveConfig.chinaMobile;
    }
  }

  /// 检查是否可用
  bool get isAvailable => config.isAvailable;
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
  ///
  /// 根据实际保存的认证信息来判断，而不是依赖 type.authType
  /// 只要有任何一种认证信息存在，就认为已登录
  bool get isLoggedIn {
    return (cookies != null && cookies!.isNotEmpty) ||
        (authorizationToken != null && authorizationToken!.isNotEmpty) ||
        (qrCodeToken != null && qrCodeToken!.isNotEmpty);
  }

  /// 获取实际使用的认证方式
  AuthType? get actualAuthType {
    if (cookies != null && cookies!.isNotEmpty) {
      return AuthType.cookie;
    } else if (authorizationToken != null && authorizationToken!.isNotEmpty) {
      return AuthType.authorization;
    } else if (qrCodeToken != null && qrCodeToken!.isNotEmpty) {
      return AuthType.qrCode;
    }
    return null;
  }

  /// 获取认证头信息
  ///
  /// 根据实际保存的认证信息返回对应的请求头
  Map<String, String> get authHeaders {
    // 优先使用实际的认证信息
    if (cookies != null && cookies!.isNotEmpty) {
      return {'Cookie': cookies!};
    } else if (authorizationToken != null && authorizationToken!.isNotEmpty) {
      // 从配置中获取 Authorization 前缀
      final prefix = type.config.authorizationPrefix;
      return {'Authorization': '$prefix $authorizationToken'};
    } else if (qrCodeToken != null && qrCodeToken!.isNotEmpty) {
      // 从配置中获取 Authorization 前缀
      final prefix = type.config.authorizationPrefix;
      return {'Authorization': '$prefix $qrCodeToken'};
    }
    return {};
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
  ///
  /// 使用命名参数来更新账号信息
  /// 注意：为了支持清空字段（设置为null），需要显式传递 null 值
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
    bool clearCookies = false,
    bool clearAuthorizationToken = false,
    bool clearQrCodeToken = false,
  }) => CloudDriveAccount(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    cookies: clearCookies ? null : (cookies ?? this.cookies),
    authorizationToken:
        clearAuthorizationToken
            ? null
            : (authorizationToken ?? this.authorizationToken),
    qrCodeToken: clearQrCodeToken ? null : (qrCodeToken ?? this.qrCodeToken),
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
/// 通用文件实体。
///
/// 除统一字段外，还可以把各云盘的原始字段放进 [metadata]，
/// 例如蓝奏的 `downloads`、`isLock` 等，方便页面按需展示。
class CloudDriveFile {
  /// 云盘生成的唯一标识
  final String id;

  /// 文件/文件夹名称
  final String name;

  /// 是否为文件夹
  final bool isFolder;

  /// 文件大小（字节），文件夹通常为空
  final int? size;

  /// 最后修改时间
  final DateTime? modifiedTime;

  /// 所属文件夹 ID（可能为根目录 `/`）
  final String? folderId;

  /// 相对路径（部分云盘会返回）
  final String? path;

  /// 下载链接（当场获取或缓存）
  final String? downloadUrl;

  /// 缩略图 URL
  final String? thumbnailUrl;

  /// 大图/高清缩略图 URL
  final String? bigThumbnailUrl;

  /// 预览链接（可用于在线播放/预览）
  final String? previewUrl;

  /// 云盘特定的扩展字段（如蓝奏 raw 字段、百度标签等）。
  final Map<String, dynamic>? metadata;

  /// 统一的文件分类标签（图片/视频/压缩等）
  final FileCategory? category;

  /// 下载量（-1 表示该云盘未提供）
  final int downloadCount;

  /// 分享次数（-1 表示该云盘未提供）
  final int shareCount;

  const CloudDriveFile({
    required this.id,
    required this.name,
    required this.isFolder,
    this.size,
    this.modifiedTime,
    this.folderId,
    this.path,
    this.downloadUrl,
    this.thumbnailUrl,
    this.bigThumbnailUrl,
    this.previewUrl,
    this.metadata,
    this.category,
    this.downloadCount = -1,
    this.shareCount = -1,
  });

  /// 是否为目录
  bool get isDirectory => isFolder;

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
    path: json['path']?.toString(),
    downloadUrl: json['downloadUrl']?.toString(),
    thumbnailUrl: json['thumbnailUrl']?.toString(),
    metadata: json['metadata'] as Map<String, dynamic>?,
    category:
        json['category'] != null
            ? FileCategory.values.firstWhere(
              (e) => e.name == json['category']?.toString(),
              orElse: () => FileCategory.other,
            )
            : null,
    downloadCount: json['downloadCount'] as int? ?? -1,
    shareCount: json['shareCount'] as int? ?? -1,
  );

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isFolder': isFolder,
    'size': size,
    'modifiedTime': modifiedTime?.toIso8601String(),
    'folderId': folderId,
    'path': path,
    'downloadUrl': downloadUrl,
    'thumbnailUrl': thumbnailUrl,
    'bigThumbnailUrl': bigThumbnailUrl,
    'previewUrl': previewUrl,
    'metadata': metadata,
    'category': category?.name,
    'downloadCount': downloadCount,
    'shareCount': shareCount,
  };

  /// 复制并更新
  CloudDriveFile copyWith({
    String? id,
    String? name,
    bool? isFolder,
    int? size,
    DateTime? modifiedTime,
    String? folderId,
    String? path,
    String? downloadUrl,
    String? thumbnailUrl,
    String? bigThumbnailUrl,
    String? previewUrl,
    Map<String, dynamic>? metadata,
    FileCategory? category,
    int? downloadCount,
    int? shareCount,
  }) => CloudDriveFile(
    id: id ?? this.id,
    name: name ?? this.name,
    isFolder: isFolder ?? this.isFolder,
    size: size ?? this.size,
    modifiedTime: modifiedTime ?? this.modifiedTime,
    folderId: folderId ?? this.folderId,
    path: path ?? this.path,
    downloadUrl: downloadUrl ?? this.downloadUrl,
    thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    bigThumbnailUrl: bigThumbnailUrl ?? this.bigThumbnailUrl,
    previewUrl: previewUrl ?? this.previewUrl,
    metadata: metadata ?? this.metadata,
    category: category ?? this.category,
    downloadCount: downloadCount ?? this.downloadCount,
    shareCount: shareCount ?? this.shareCount,
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

/// 云盘账号详情
class CloudDriveAccountDetails {
  final String id;
  final String name;
  final String? avatarUrl;
  final int? totalSpace;
  final int? usedSpace;
  final int? freeSpace;
  final DateTime? lastLoginAt;
  final bool isValid;
  final CloudDriveAccountInfo? accountInfo;
  final CloudDriveQuotaInfo? quotaInfo;

  const CloudDriveAccountDetails({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.totalSpace,
    this.usedSpace,
    this.freeSpace,
    this.lastLoginAt,
    this.isValid = true,
    this.accountInfo,
    this.quotaInfo,
  });

  @override
  String toString() =>
      'CloudDriveAccountDetails{id: $id, name: $name, isValid: $isValid}';
}
