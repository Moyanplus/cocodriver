import '../../../config/cloud_drive_capabilities.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../registry/cloud_drive_provider_descriptor.dart';
import '../../shared/default_account_normalizer.dart';
import 'baidu_operation_strategy.dart';
import 'services/baidu_qr_login_service.dart';
import 'package:flutter/material.dart';

/// 百度网盘的可插拔描述符。
CloudDriveProviderDescriptor createBaiduProviderDescriptor() {
  return CloudDriveProviderDescriptor(
    type: CloudDriveType.baidu,
    strategyFactory: () => BaiduCloudDriveOperationStrategy(),
    capabilities: getDefaultCapabilitiesForType(CloudDriveType.baidu),
    displayName: '百度网盘',
    iconData: Icons.cloud,
    iconAsset: 'assets/icons/baidu.png',
    color: Colors.blue,
    supportedAuthTypes: const [AuthType.cookie, AuthType.qrCode],
    qrLoginService: BaiduQRLoginService(),
    qrLoginAuthType: AuthType.cookie,
    description: '百度网盘，支持大文件存储',
    accountNormalizer: DefaultAccountNormalizer(type: CloudDriveType.baidu),
  );
}
