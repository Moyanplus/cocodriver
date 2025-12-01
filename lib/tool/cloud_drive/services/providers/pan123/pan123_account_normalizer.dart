import '../../../base/cloud_drive_account_normalizer.dart';
import '../../../data/models/cloud_drive_entities.dart';
import 'repository/pan123_repository.dart';

/// 使用 123 云盘 UID 生成稳定账号ID，避免重复添加。
class Pan123AccountNormalizer implements CloudDriveAccountNormalizer {
  Pan123AccountNormalizer({Pan123Repository? repository})
    : _repository = repository ?? Pan123Repository();

  final Pan123Repository _repository;

  @override
  Future<CloudDriveAccount> normalize(CloudDriveAccount account) async {
    if (account.type != CloudDriveType.pan123) return account;

    try {
      final info = await _repository.getUserInfo(account: account);
      final uid = info.uid;
      if (uid <= 0) return account;

      final newId = '${CloudDriveType.pan123.name}_$uid';
      final newName =
          info.nickname.isNotEmpty ? info.nickname : account.name;

      return account.copyWith(
        id: newId,
        name: newName,
        driveId: uid.toString(),
      );
    } catch (_) {
      // 获取失败保持原值，避免阻塞添加。
      return account;
    }
  }
}
