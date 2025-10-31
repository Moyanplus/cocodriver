/// 应用更新模块的数据模型
///
/// 包含版本信息、更新信息、下载进度等模型定义

import 'package:json_annotation/json_annotation.dart';

part 'update_models.g.dart';

/// 版本信息
@JsonSerializable()
class VersionInfo {
  /// 版本号（例如：1.0.0）
  final String version;

  /// 版本代码（例如：1）
  final int versionCode;

  /// 版本名称（例如：v1.0.0）
  final String versionName;

  /// 构建号
  final String buildNumber;

  const VersionInfo({
    required this.version,
    required this.versionCode,
    required this.versionName,
    required this.buildNumber,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) =>
      _$VersionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VersionInfoToJson(this);

  /// 比较版本号
  /// 返回：1表示当前版本更新，0表示相同，-1表示当前版本更旧
  int compareTo(VersionInfo other) {
    return versionCode.compareTo(other.versionCode);
  }

  @override
  String toString() => versionName;
}

/// 更新类型
enum UpdateType {
  /// 强制更新
  force,

  /// 推荐更新
  recommend,

  /// 可选更新
  optional,
}

/// 更新信息
@JsonSerializable()
class UpdateInfo {
  /// 版本信息
  final VersionInfo version;

  /// 更新类型
  @JsonKey(unknownEnumValue: UpdateType.optional)
  final UpdateType updateType;

  /// 更新标题
  final String title;

  /// 更新描述
  final String description;

  /// 更新内容列表
  final List<String> features;

  /// 下载地址
  final String downloadUrl;

  /// 文件大小（字节）
  final int fileSize;

  /// MD5校验值
  final String? md5;

  /// 发布时间
  final DateTime releaseTime;

  /// 最小支持版本
  final String? minSupportedVersion;

  /// 是否静默下载
  final bool silentDownload;

  const UpdateInfo({
    required this.version,
    required this.updateType,
    required this.title,
    required this.description,
    required this.features,
    required this.downloadUrl,
    required this.fileSize,
    this.md5,
    required this.releaseTime,
    this.minSupportedVersion,
    this.silentDownload = false,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) =>
      _$UpdateInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateInfoToJson(this);

  /// 是否强制更新
  bool get isForceUpdate => updateType == UpdateType.force;

  /// 是否推荐更新
  bool get isRecommendUpdate => updateType == UpdateType.recommend;

  /// 格式化文件大小
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}

/// 下载状态
enum DownloadStatus {
  /// 未开始
  idle,

  /// 下载中
  downloading,

  /// 暂停
  paused,

  /// 完成
  completed,

  /// 失败
  failed,

  /// 取消
  cancelled,
}

/// 下载进度
class DownloadProgress {
  /// 已下载字节数
  final int downloadedBytes;

  /// 总字节数
  final int totalBytes;

  /// 下载速度（字节/秒）
  final double speed;

  /// 下载状态
  final DownloadStatus status;

  /// 错误信息
  final String? error;

  /// 本地文件路径
  final String? filePath;

  const DownloadProgress({
    required this.downloadedBytes,
    required this.totalBytes,
    required this.speed,
    required this.status,
    this.error,
    this.filePath,
  });

  /// 下载进度百分比（0-100）
  double get percentage {
    if (totalBytes <= 0) return 0.0;
    return (downloadedBytes / totalBytes * 100).clamp(0.0, 100.0);
  }

  /// 格式化速度
  String get speedFormatted {
    if (speed < 1024) {
      return '${speed.toStringAsFixed(2)} B/s';
    } else if (speed < 1024 * 1024) {
      return '${(speed / 1024).toStringAsFixed(2)} KB/s';
    } else {
      return '${(speed / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    }
  }

  /// 剩余时间（秒）
  int? get remainingTime {
    if (speed <= 0 || totalBytes <= 0) return null;
    final remaining = totalBytes - downloadedBytes;
    return (remaining / speed).ceil();
  }

  /// 格式化剩余时间
  String get remainingTimeFormatted {
    final time = remainingTime;
    if (time == null) return '未知';

    if (time < 60) {
      return '$time 秒';
    } else if (time < 3600) {
      return '${(time / 60).ceil()} 分钟';
    } else {
      return '${(time / 3600).ceil()} 小时';
    }
  }

  DownloadProgress copyWith({
    int? downloadedBytes,
    int? totalBytes,
    double? speed,
    DownloadStatus? status,
    String? error,
    String? filePath,
  }) {
    return DownloadProgress(
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      speed: speed ?? this.speed,
      status: status ?? this.status,
      error: error ?? this.error,
      filePath: filePath ?? this.filePath,
    );
  }

  /// 空状态
  static const empty = DownloadProgress(
    downloadedBytes: 0,
    totalBytes: 0,
    speed: 0,
    status: DownloadStatus.idle,
  );
}

/// 更新检查结果
class UpdateCheckResult {
  /// 是否有更新
  final bool hasUpdate;

  /// 更新信息
  final UpdateInfo? updateInfo;

  /// 当前版本
  final VersionInfo currentVersion;

  /// 错误信息
  final String? error;

  const UpdateCheckResult({
    required this.hasUpdate,
    this.updateInfo,
    required this.currentVersion,
    this.error,
  });

  /// 成功结果
  factory UpdateCheckResult.success({
    required bool hasUpdate,
    UpdateInfo? updateInfo,
    required VersionInfo currentVersion,
  }) {
    return UpdateCheckResult(
      hasUpdate: hasUpdate,
      updateInfo: updateInfo,
      currentVersion: currentVersion,
    );
  }

  /// 失败结果
  factory UpdateCheckResult.failure({
    required String error,
    required VersionInfo currentVersion,
  }) {
    return UpdateCheckResult(
      hasUpdate: false,
      currentVersion: currentVersion,
      error: error,
    );
  }
}
