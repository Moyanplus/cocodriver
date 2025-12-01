import '../../../config/cloud_drive_capabilities.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../registry/cloud_drive_provider_descriptor.dart';
import '../../shared/default_account_normalizer.dart';
import 'china_mobile_operation_strategy.dart';
import 'package:flutter/material.dart';

/// 中国移动云盘的可插拔描述符。
CloudDriveProviderDescriptor createChinaMobileProviderDescriptor() {
  return CloudDriveProviderDescriptor(
    type: CloudDriveType.chinaMobile,
    strategyFactory: () => ChinaMobileCloudDriveOperationStrategy(),
    capabilities: getDefaultCapabilitiesForType(CloudDriveType.chinaMobile),
    displayName: '中国移动云盘',
    iconData: Icons.phone_android,
    iconAsset: 'assets/icons/china_mobile.png',
    color: Colors.blueGrey,
    supportedAuthTypes: const [AuthType.authorization, AuthType.qrCode],
    description: '中国移动云盘，运营商级别',
    accountNormalizer:
        DefaultAccountNormalizer(type: CloudDriveType.chinaMobile),
  );
}
