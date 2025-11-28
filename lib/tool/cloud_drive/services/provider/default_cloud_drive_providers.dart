import '../ali/ali_operation_strategy.dart';
import '../baidu/baidu_operation_strategy.dart';
import '../china_mobile/china_mobile_operation_strategy.dart';
import '../lanzou/lanzou_operation_strategy.dart';
import '../pan123/pan123_operation_strategy.dart';
import '../quark/strategy/quark_operation_strategy.dart';
import '../../data/models/cloud_drive_entities.dart';
import 'cloud_drive_provider_descriptor.dart';
import '../../config/cloud_drive_capabilities.dart';

/// 预置的云盘提供方描述列表，初始化时一次性注册。
final List<CloudDriveProviderDescriptor> defaultCloudDriveProviders = [
  CloudDriveProviderDescriptor(
    type: CloudDriveType.baidu,
    strategyFactory: () => BaiduCloudDriveOperationStrategy(),
    capabilities: getCapabilities(CloudDriveType.baidu),
    displayName: CloudDriveType.baidu.displayName,
    iconData: CloudDriveType.baidu.iconData,
    iconAsset: CloudDriveType.baidu.icon,
    color: CloudDriveType.baidu.color,
    supportedAuthTypes: CloudDriveType.baidu.supportedAuthTypes,
    description: _describe(CloudDriveType.baidu),
  ),
  CloudDriveProviderDescriptor(
    type: CloudDriveType.lanzou,
    strategyFactory: () => LanzouCloudDriveOperationStrategy(),
    capabilities: getCapabilities(CloudDriveType.lanzou),
    displayName: CloudDriveType.lanzou.displayName,
    iconData: CloudDriveType.lanzou.iconData,
    iconAsset: CloudDriveType.lanzou.icon,
    color: CloudDriveType.lanzou.color,
    supportedAuthTypes: CloudDriveType.lanzou.supportedAuthTypes,
    description: _describe(CloudDriveType.lanzou),
  ),
  CloudDriveProviderDescriptor(
    type: CloudDriveType.pan123,
    strategyFactory: () => Pan123CloudDriveOperationStrategy(),
    capabilities: getCapabilities(CloudDriveType.pan123),
    displayName: CloudDriveType.pan123.displayName,
    iconData: CloudDriveType.pan123.iconData,
    iconAsset: CloudDriveType.pan123.icon,
    color: CloudDriveType.pan123.color,
    supportedAuthTypes: CloudDriveType.pan123.supportedAuthTypes,
    description: _describe(CloudDriveType.pan123),
  ),
  CloudDriveProviderDescriptor(
    type: CloudDriveType.ali,
    strategyFactory: () => AliCloudDriveOperationStrategy(),
    capabilities: getCapabilities(CloudDriveType.ali),
    displayName: CloudDriveType.ali.displayName,
    iconData: CloudDriveType.ali.iconData,
    iconAsset: CloudDriveType.ali.icon,
    color: CloudDriveType.ali.color,
    supportedAuthTypes: CloudDriveType.ali.supportedAuthTypes,
    description: _describe(CloudDriveType.ali),
  ),
  CloudDriveProviderDescriptor(
    type: CloudDriveType.quark,
    strategyFactory: () => QuarkCloudDriveOperationStrategy(),
    capabilities: getCapabilities(CloudDriveType.quark),
    displayName: CloudDriveType.quark.displayName,
    iconData: CloudDriveType.quark.iconData,
    iconAsset: CloudDriveType.quark.icon,
    color: CloudDriveType.quark.color,
    supportedAuthTypes: CloudDriveType.quark.supportedAuthTypes,
    description: _describe(CloudDriveType.quark),
  ),
  CloudDriveProviderDescriptor(
    type: CloudDriveType.chinaMobile,
    strategyFactory: () => ChinaMobileCloudDriveOperationStrategy(),
    capabilities: getCapabilities(CloudDriveType.chinaMobile),
    displayName: CloudDriveType.chinaMobile.displayName,
    iconData: CloudDriveType.chinaMobile.iconData,
    iconAsset: CloudDriveType.chinaMobile.icon,
    color: CloudDriveType.chinaMobile.color,
    supportedAuthTypes: CloudDriveType.chinaMobile.supportedAuthTypes,
    description: _describe(CloudDriveType.chinaMobile),
  ),
];

String _describe(CloudDriveType type) {
  switch (type) {
    case CloudDriveType.baidu:
      return '百度网盘，支持大文件存储';
    case CloudDriveType.lanzou:
      return '蓝奏云，简单易用';
    case CloudDriveType.pan123:
      return '123云盘，免费大容量';
    case CloudDriveType.ali:
      return '阿里云盘，高速下载';
    case CloudDriveType.quark:
      return '夸克云盘，智能分类';
    case CloudDriveType.chinaMobile:
      return '中国移动云盘，运营商级别';
  }
}
