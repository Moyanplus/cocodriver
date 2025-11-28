import '../../config/cloud_drive_capabilities.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../provider/cloud_drive_provider_descriptor.dart';
import 'ali_operation_strategy.dart';
import 'package:flutter/material.dart';

/// 阿里云盘的可插拔描述符。
CloudDriveProviderDescriptor createAliProviderDescriptor() {
  return CloudDriveProviderDescriptor(
    type: CloudDriveType.ali,
    strategyFactory: () => AliCloudDriveOperationStrategy(),
    capabilities: getCapabilities(CloudDriveType.ali),
    displayName: '阿里云盘',
    iconData: Icons.cloud_done,
    iconAsset: 'assets/icons/ali.png',
    color: Colors.red,
    supportedAuthTypes: const [AuthType.web, AuthType.qrCode],
    description: '阿里云盘，高速下载',
  );
}
