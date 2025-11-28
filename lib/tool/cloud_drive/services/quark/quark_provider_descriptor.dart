import '../../config/cloud_drive_capabilities.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../provider/cloud_drive_provider_descriptor.dart';
import 'strategy/quark_operation_strategy.dart';
import 'services/quark_qr_login_service.dart';

/// 夸克云盘的可插拔描述符。
CloudDriveProviderDescriptor createQuarkProviderDescriptor() {
  return CloudDriveProviderDescriptor(
    type: CloudDriveType.quark,
    strategyFactory: () => QuarkCloudDriveOperationStrategy(),
    capabilities: getCapabilities(CloudDriveType.quark),
    displayName: CloudDriveType.quark.displayName,
    iconData: CloudDriveType.quark.iconData,
    iconAsset: CloudDriveType.quark.icon,
    color: CloudDriveType.quark.color,
    supportedAuthTypes: CloudDriveType.quark.supportedAuthTypes,
    description: '夸克云盘，智能分类',
    qrLoginService: QuarkQRLoginService(),
  );
}
