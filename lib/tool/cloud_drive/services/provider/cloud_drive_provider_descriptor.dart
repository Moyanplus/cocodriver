import '../../base/cloud_drive_operation_service.dart'
    show CloudDriveOperationStrategy;
import '../../config/cloud_drive_capabilities.dart';
import '../../data/models/cloud_drive_entities.dart';
import 'package:flutter/material.dart';

typedef StrategyFactory = CloudDriveOperationStrategy Function();

/// 云盘提供方描述，用于实现可插拔注册。
class CloudDriveProviderDescriptor {
  const CloudDriveProviderDescriptor({
    required this.type,
    required this.strategyFactory,
    required this.capabilities,
    this.displayName,
    this.iconData,
    this.iconAsset,
    this.color,
    this.supportedAuthTypes,
    this.description,
  });

  final CloudDriveType type;
  final StrategyFactory strategyFactory;
  final CloudDriveCapabilities capabilities;

  /// 供 UI 使用的元数据，不传则回退到 CloudDriveType 默认值。
  final String? displayName;
  final IconData? iconData;
  final String? iconAsset;
  final Color? color;
  final List<AuthType>? supportedAuthTypes;
  final String? description;
}
