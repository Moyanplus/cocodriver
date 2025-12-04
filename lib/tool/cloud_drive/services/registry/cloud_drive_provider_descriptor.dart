import '../../base/cloud_drive_operation_service.dart'
    show CloudDriveOperationStrategy;
import '../../base/cloud_drive_account_normalizer.dart';
import '../../config/cloud_drive_capabilities.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../base/qr_login_service.dart';
import 'package:flutter/material.dart';

typedef StrategyFactory = CloudDriveOperationStrategy Function();
typedef MediaHeadersBuilder = Map<String, String> Function(
  CloudDriveAccount account,
);

/// 云盘提供方描述，用于实现可插拔注册。
class CloudDriveProviderDescriptor {
  const CloudDriveProviderDescriptor({
    this.id,
    required this.type,
    required this.strategyFactory,
    required this.capabilities,
    this.displayName,
    this.iconData,
    this.iconAsset,
    this.color,
    this.supportedAuthTypes,
    this.description,
    this.qrLoginService,
    this.qrLoginAuthType,
    this.accountNormalizer,
    this.mediaHeadersBuilder,
  });

  final CloudDriveType type;
  final StrategyFactory strategyFactory;
  final CloudDriveCapabilities capabilities;

  /// 供 UI 使用的元数据，不传则回退到 CloudDriveType 默认值。
  /// 可选的唯一 ID，若未提供则使用 type.name
  final String? id;
  final String? displayName;
  final IconData? iconData;
  final String? iconAsset;
  final Color? color;
  final List<AuthType>? supportedAuthTypes;
  final String? description;

  /// 可选：对应云盘的二维码登录服务。
  final QRLoginService? qrLoginService;

  /// 二维码登录返回的认证类型（用于保存到 cookies 或 Authorization）。
  /// 不配置则默认写入 qrCodeToken 使用 Authorization 头。
  final AuthType? qrLoginAuthType;

  /// 可选：账号归一化器，用于生成稳定 ID/昵称 等。
  final CloudDriveAccountNormalizer? accountNormalizer;

  /// 可选：媒体（缩略图/预览图）请求附加头构造器，避免 UI 层硬编码。
  final MediaHeadersBuilder? mediaHeadersBuilder;
}
