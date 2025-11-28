import '../../config/cloud_drive_capabilities.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../provider/cloud_drive_provider_descriptor.dart';
import 'strategy/quark_operation_strategy.dart';
import 'services/quark_qr_login_service.dart';
import 'package:flutter/material.dart';

/// 夸克云盘的可插拔描述符。
CloudDriveProviderDescriptor createQuarkProviderDescriptor() {
  return CloudDriveProviderDescriptor(
    type: CloudDriveType.quark,
    strategyFactory: () => QuarkCloudDriveOperationStrategy(),
    capabilities: getCapabilities(CloudDriveType.quark),
    displayName: '夸克云盘',
    iconData: Icons.cloud_queue,
    iconAsset: 'assets/icons/quark.png',
    color: Colors.purple,
    supportedAuthTypes: const [AuthType.cookie, AuthType.qrCode],
    description: '夸克云盘，智能分类',
    qrLoginService: QuarkQRLoginService(),
  );
}
