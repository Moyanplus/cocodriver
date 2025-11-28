import '../../config/cloud_drive_capabilities.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../provider/cloud_drive_provider_descriptor.dart';
import 'baidu_operation_strategy.dart';

/// 百度网盘的可插拔描述符。
CloudDriveProviderDescriptor createBaiduProviderDescriptor() {
  return CloudDriveProviderDescriptor(
    type: CloudDriveType.baidu,
    strategyFactory: () => BaiduCloudDriveOperationStrategy(),
    capabilities: getCapabilities(CloudDriveType.baidu),
    displayName: CloudDriveType.baidu.displayName,
    iconData: CloudDriveType.baidu.iconData,
    iconAsset: CloudDriveType.baidu.icon,
    color: CloudDriveType.baidu.color,
    supportedAuthTypes: CloudDriveType.baidu.supportedAuthTypes,
    description: '百度网盘，支持大文件存储',
  );
}
