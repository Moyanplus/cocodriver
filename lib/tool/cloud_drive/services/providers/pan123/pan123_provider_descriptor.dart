import '../../../config/cloud_drive_capabilities.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../registry/cloud_drive_provider_descriptor.dart';
import 'strategy/pan123_operation_strategy.dart';
import 'package:flutter/material.dart';
import 'services/pan123_qr_login_service.dart';

/// 123 云盘的可插拔描述符。
/// 负责向注册表提供策略、能力、登录方式等信息。
CloudDriveProviderDescriptor createPan123ProviderDescriptor() {
  return CloudDriveProviderDescriptor(
    type: CloudDriveType.pan123,
    strategyFactory: () => Pan123CloudDriveOperationStrategy(),
    capabilities: getDefaultCapabilitiesForType(CloudDriveType.pan123),
    displayName: '123云盘',
    iconData: Icons.storage,
    iconAsset: 'assets/icons/pan123.png',
    color: Colors.green,
    supportedAuthTypes: const [AuthType.cookie, AuthType.qrCode],
    qrLoginService: Pan123QRLoginService(),
    qrLoginAuthType: AuthType.authorization,
    description: '123云盘，免费大容量',
  );
}
