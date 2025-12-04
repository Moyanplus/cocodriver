import '../../../config/cloud_drive_capabilities.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../registry/cloud_drive_provider_descriptor.dart';
import '../../shared/default_account_normalizer.dart';
import 'strategy/ali_operation_strategy.dart';
import 'services/ali_qr_login_service.dart';
import 'package:flutter/material.dart';

/// 阿里云盘的可插拔描述符。
CloudDriveProviderDescriptor createAliProviderDescriptor() {
  return CloudDriveProviderDescriptor(
    type: CloudDriveType.ali,
    strategyFactory: () => AliCloudDriveOperationStrategy(),
    capabilities: getDefaultCapabilitiesForType(CloudDriveType.ali),
    displayName: '阿里云盘',
    iconData: Icons.cloud_done,
    iconAsset: 'assets/icons/ali.png',
    color: Colors.red,
    // 统一改为 Authorization 为主，支持二维码与 Web 登录。
    supportedAuthTypes: const [AuthType.authorization, AuthType.qrCode, AuthType.web],
    qrLoginService: AliQRLoginService(),
    qrLoginAuthType: AuthType.authorization,
    mediaHeadersBuilder: (account) => {
      'Origin': 'https://www.aliyundrive.com',
      'Referer': 'https://www.aliyundrive.com/',
      'x-canary': 'client=web,app=adrive,version=v4.3.1',
      'x-device-id': account.primaryAuthType == AuthType.authorization
          ? 'web'
          : '',
    },
    description: '阿里云盘，高速下载',
    accountNormalizer: DefaultAccountNormalizer(type: CloudDriveType.ali),
  );
}
