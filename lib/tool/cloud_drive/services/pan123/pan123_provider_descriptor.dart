import '../../config/cloud_drive_capabilities.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../provider/cloud_drive_provider_descriptor.dart';
import 'pan123_operation_strategy.dart';

/// 123 云盘的可插拔描述符。
CloudDriveProviderDescriptor createPan123ProviderDescriptor() {
  return CloudDriveProviderDescriptor(
    type: CloudDriveType.pan123,
    strategyFactory: () => Pan123CloudDriveOperationStrategy(),
    capabilities: getCapabilities(CloudDriveType.pan123),
    displayName: CloudDriveType.pan123.displayName,
    iconData: CloudDriveType.pan123.iconData,
    iconAsset: CloudDriveType.pan123.icon,
    color: CloudDriveType.pan123.color,
    supportedAuthTypes: CloudDriveType.pan123.supportedAuthTypes,
    description: '123云盘，免费大容量',
  );
}
