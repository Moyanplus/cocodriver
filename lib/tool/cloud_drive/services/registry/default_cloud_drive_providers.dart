import '../providers/ali/ali_provider_descriptor.dart';
import '../providers/baidu/baidu_provider_descriptor.dart';
import '../providers/china_mobile/china_mobile_provider_descriptor.dart';
import '../providers/lanzou/lanzou_provider_descriptor.dart';
import '../providers/pan123/pan123_provider_descriptor.dart';
import '../providers/quark/quark_provider_descriptor.dart';
import 'cloud_drive_provider_descriptor.dart';

/// 预置的云盘提供方描述列表，初始化时一次性注册。
final List<CloudDriveProviderDescriptor> defaultCloudDriveProviders = [
  createBaiduProviderDescriptor(),
  createLanzouProviderDescriptor(),
  createPan123ProviderDescriptor(),
  createAliProviderDescriptor(),
  createQuarkProviderDescriptor(),
  createChinaMobileProviderDescriptor(),
];
