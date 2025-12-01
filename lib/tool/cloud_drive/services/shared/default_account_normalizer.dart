import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../data/models/cloud_drive_entities.dart';
import '../../base/cloud_drive_account_normalizer.dart';

/// 通用账号归一化器：基于可用的唯一字段生成稳定ID，避免重复添加。
class DefaultAccountNormalizer implements CloudDriveAccountNormalizer {
  DefaultAccountNormalizer({required this.type});

  final CloudDriveType type;

  @override
  Future<CloudDriveAccount> normalize(CloudDriveAccount account) async {
    // 仅处理对应类型
    if (account.type != type) return account;

    final candidate =
        account.driveId ??
        account.authorizationToken ??
        account.qrCodeToken ??
        account.cookies;

    if (candidate == null || candidate.isEmpty) return account;

    final digest = md5.convert(utf8.encode(candidate)).toString();
    final short = digest.substring(0, 12);
    final newId = '${account.type.name}_$short';

    // 若已是稳定ID则直接返回
    if (newId == account.id) return account;

    return account.copyWith(id: newId);
  }
}
