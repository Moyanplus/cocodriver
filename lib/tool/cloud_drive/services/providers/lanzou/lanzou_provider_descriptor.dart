import '../../../config/cloud_drive_capabilities.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../registry/cloud_drive_provider_descriptor.dart';
import '../../shared/default_account_normalizer.dart';
import 'lanzou_operation_strategy.dart';
import 'package:flutter/material.dart';

/// 蓝奏云盘的可插拔描述符。
CloudDriveProviderDescriptor createLanzouProviderDescriptor() {
  return CloudDriveProviderDescriptor(
    type: CloudDriveType.lanzou,
    strategyFactory: () => LanzouCloudDriveOperationStrategy(),
    capabilities: getDefaultCapabilitiesForType(CloudDriveType.lanzou),
    displayName: '蓝奏云',
    iconData: Icons.link,
    iconAsset: 'assets/icons/lanzou.png',
    color: Colors.orange,
    supportedAuthTypes: const [AuthType.web, AuthType.cookie],
    description: '蓝奏云，简单易用',
    accountNormalizer: DefaultAccountNormalizer(type: CloudDriveType.lanzou),
  );
}
