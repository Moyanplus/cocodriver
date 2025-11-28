import '../data/models/cloud_drive_entities.dart';

/// 云盘能力与配额配置，集中管理各云盘的操作上限与默认能力。
class CloudDriveCapabilities {
  const CloudDriveCapabilities({
    required this.maxUploadSize,
    int? maxDownloadSize,
    required this.maxShareFileSize,
    required this.maxExpireDays,
    required this.maxBatchSizes,
  }) : maxDownloadSize = maxDownloadSize ?? maxUploadSize;

  /// 单文件上传大小上限（字节）
  final int maxUploadSize;

  /// 可分享的单文件大小上限（字节）
  final int maxShareFileSize;

  /// 单文件下载大小上限（字节）
  final int maxDownloadSize;

  /// 分享链接最大有效天数
  final int maxExpireDays;

  /// 批量操作的默认上限，key 为操作名（如 delete/copy）
  final Map<String, int> maxBatchSizes;

  int getBatchLimit(String operation) =>
      maxBatchSizes[operation] ?? maxBatchSizes['*'] ?? 50;
}

/// 统一的能力表，支持动态注册（每个云盘目录自行注册）。
final Map<CloudDriveType, CloudDriveCapabilities> _capabilityMap = {};

/// 预置能力，未注册时使用。
final Map<CloudDriveType, CloudDriveCapabilities> _defaultCapabilities = {
  CloudDriveType.baidu: CloudDriveCapabilities(
    maxUploadSize: 2 * 1024 * 1024 * 1024, // 2GB
    maxShareFileSize: 2 * 1024 * 1024 * 1024,
    maxExpireDays: 7,
    maxBatchSizes: {
      'delete': 100,
      '*': 50,
    },
  ),
  CloudDriveType.lanzou: CloudDriveCapabilities(
    maxUploadSize: 100 * 1024 * 1024, // 100MB
    maxShareFileSize: 100 * 1024 * 1024,
    maxExpireDays: 30,
    maxBatchSizes: {
      'delete': 10,
      'copy': 10,
      'move': 10,
      '*': 10,
    },
  ),
  CloudDriveType.pan123: CloudDriveCapabilities(
    maxUploadSize: 5 * 1024 * 1024 * 1024, // 5GB
    maxShareFileSize: 5 * 1024 * 1024 * 1024,
    maxExpireDays: 7,
    maxBatchSizes: {'*': 50},
  ),
  CloudDriveType.ali: CloudDriveCapabilities(
    maxUploadSize: 20 * 1024 * 1024 * 1024, // 20GB
    maxShareFileSize: 20 * 1024 * 1024 * 1024,
    maxExpireDays: 7,
    maxBatchSizes: {
      'delete': 100,
      '*': 50,
    },
  ),
  CloudDriveType.quark: CloudDriveCapabilities(
    maxUploadSize: 5 * 1024 * 1024 * 1024, // 5GB
    maxShareFileSize: 5 * 1024 * 1024 * 1024,
    maxExpireDays: 7,
    maxBatchSizes: {'*': 50},
  ),
  CloudDriveType.chinaMobile: CloudDriveCapabilities(
    maxUploadSize: 5 * 1024 * 1024 * 1024, // 5GB
    maxShareFileSize: 5 * 1024 * 1024 * 1024,
    maxExpireDays: 7,
    maxBatchSizes: {'*': 50},
  ),
};

/// 注册能力，供各云盘目录在初始化时调用。
void registerCapabilities(CloudDriveType type, CloudDriveCapabilities spec) {
  _capabilityMap[type] = spec;
}

/// 获取能力，优先取注册值，其次默认值。
CloudDriveCapabilities getCapabilities(CloudDriveType type) =>
    _capabilityMap[type] ?? _defaultCapabilities[type] ?? _defaultCapabilities.values.first;
