import '../data/models/cloud_drive_entities.dart';

/// 账号归一化器：用于根据云盘的官方唯一标识生成稳定的账号ID，并可顺便补充昵称等信息。
abstract class CloudDriveAccountNormalizer {
  Future<CloudDriveAccount> normalize(CloudDriveAccount account);
}
