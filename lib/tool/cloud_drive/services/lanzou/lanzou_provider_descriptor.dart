import '../../config/cloud_drive_capabilities.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../provider/cloud_drive_provider_descriptor.dart';
import 'lanzou_operation_strategy.dart';

/// 蓝奏云盘的可插拔描述符。
CloudDriveProviderDescriptor createLanzouProviderDescriptor() {
  return CloudDriveProviderDescriptor(
    type: CloudDriveType.lanzou,
    strategyFactory: () => LanzouCloudDriveOperationStrategy(),
    capabilities: getCapabilities(CloudDriveType.lanzou),
    displayName: CloudDriveType.lanzou.displayName,
    iconData: CloudDriveType.lanzou.iconData,
    iconAsset: CloudDriveType.lanzou.icon,
    color: CloudDriveType.lanzou.color,
    supportedAuthTypes: CloudDriveType.lanzou.supportedAuthTypes,
    description: '蓝奏云，简单易用',
  );
}
