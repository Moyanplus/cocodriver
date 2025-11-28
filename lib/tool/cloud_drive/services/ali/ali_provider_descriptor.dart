import '../../config/cloud_drive_capabilities.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../provider/cloud_drive_provider_descriptor.dart';
import 'ali_operation_strategy.dart';

/// 阿里云盘的可插拔描述符。
CloudDriveProviderDescriptor createAliProviderDescriptor() {
  return CloudDriveProviderDescriptor(
    type: CloudDriveType.ali,
    strategyFactory: () => AliCloudDriveOperationStrategy(),
    capabilities: getCapabilities(CloudDriveType.ali),
    displayName: CloudDriveType.ali.displayName,
    iconData: CloudDriveType.ali.iconData,
    iconAsset: CloudDriveType.ali.icon,
    color: CloudDriveType.ali.color,
    supportedAuthTypes: CloudDriveType.ali.supportedAuthTypes,
    description: '阿里云盘，高速下载',
  );
}
