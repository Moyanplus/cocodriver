import '../../config/cloud_drive_capabilities.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../provider/cloud_drive_provider_descriptor.dart';
import 'china_mobile_operation_strategy.dart';

/// 中国移动云盘的可插拔描述符。
CloudDriveProviderDescriptor createChinaMobileProviderDescriptor() {
  return CloudDriveProviderDescriptor(
    type: CloudDriveType.chinaMobile,
    strategyFactory: () => ChinaMobileCloudDriveOperationStrategy(),
    capabilities: getCapabilities(CloudDriveType.chinaMobile),
    displayName: CloudDriveType.chinaMobile.displayName,
    iconData: CloudDriveType.chinaMobile.iconData,
    iconAsset: CloudDriveType.chinaMobile.icon,
    color: CloudDriveType.chinaMobile.color,
    supportedAuthTypes: CloudDriveType.chinaMobile.supportedAuthTypes,
    description: '中国移动云盘，运营商级别',
  );
}
