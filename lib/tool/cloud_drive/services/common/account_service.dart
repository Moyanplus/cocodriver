// import '../../../../../core/logging/log_manager.dart'; // 未使用
import '../../data/models/cloud_drive_entities.dart';
import '../../base/cloud_drive_account_service.dart';
import '../../core/result.dart';
import 'cloud_drive_service_base.dart';
import '../provider/cloud_drive_provider_registry.dart';

/// 账号服务
///
/// 处理账号相关的操作，包括账号的加载、保存、添加、更新、删除等。
class AccountService extends CloudDriveServiceBase {
  AccountService(CloudDriveType type) : super(type);

  /// 加载所有账号
  Future<Result<List<CloudDriveAccount>>> loadAccounts() async {
    logOperation('加载账号列表');

    return await ResultUtils.fromAsync(() async {
      final accounts = await CloudDriveAccountService.loadAccounts();
      logSuccess('加载账号列表', details: '${accounts.length} 个账号');
      return accounts;
    }, operationName: '加载账号列表');
  }

  /// 保存所有账号
  Future<Result<void>> saveAccounts(List<CloudDriveAccount> accounts) async {
    logOperation('保存账号列表', params: {'count': accounts.length});

    return await ResultUtils.fromAsync(() async {
      await CloudDriveAccountService.saveAccounts(accounts);
      logSuccess('保存账号列表', details: '${accounts.length} 个账号');
    }, operationName: '保存账号列表');
  }

  /// 添加账号
  Future<Result<void>> addAccount(CloudDriveAccount account) async {
    logOperation(
      '添加账号',
      params: {
        'accountName': account.name,
        'accountType': account.type.displayName,
      },
    );

    return await ResultUtils.fromAsync(() async {
      await CloudDriveAccountService.addAccount(account);
      logSuccess('添加账号', details: account.name);
    }, operationName: '添加账号');
  }

  /// 更新账号
  Future<Result<void>> updateAccount(CloudDriveAccount account) async {
    logOperation(
      '更新账号',
      params: {'accountId': account.id, 'accountName': account.name},
    );

    return await ResultUtils.fromAsync(() async {
      await CloudDriveAccountService.updateAccount(account);
      logSuccess('更新账号', details: account.name);
    }, operationName: '更新账号');
  }

  /// 删除账号
  Future<Result<void>> deleteAccount(String accountId) async {
    logOperation('删除账号', params: {'accountId': accountId});

    return await ResultUtils.fromAsync(() async {
      await CloudDriveAccountService.deleteAccount(accountId);
      logSuccess('删除账号', details: accountId);
    }, operationName: '删除账号');
  }

  /// 根据ID查找账号
  Future<Result<CloudDriveAccount?>> findAccountById(String accountId) async {
    logOperation('查找账号', params: {'accountId': accountId});

    return await ResultUtils.fromAsync(() async {
      final account = await CloudDriveAccountService.findAccountById(accountId);
      if (account != null) {
        logSuccess('查找账号', details: account.name);
      } else {
        logWarning('查找账号', '账号不存在');
      }
      return account;
    }, operationName: '查找账号');
  }

  /// 检查账号是否存在
  Future<Result<bool>> accountExists(String accountId) async {
    logOperation('检查账号是否存在', params: {'accountId': accountId});

    return await ResultUtils.fromAsync(() async {
      final exists = await CloudDriveAccountService.accountExists(accountId);
      logSuccess('检查账号是否存在', details: exists ? '存在' : '不存在');
      return exists;
    }, operationName: '检查账号是否存在');
  }

  /// 保存账号的driveId
  Future<Result<void>> saveDriveId(
    CloudDriveAccount account,
    String driveId,
  ) async {
    logOperation(
      '保存账号driveId',
      params: {'accountName': account.name, 'driveId': driveId},
    );

    return await ResultUtils.fromAsync(() async {
      await CloudDriveAccountService.saveDriveId(account, driveId);
      logSuccess('保存账号driveId', details: '${account.name} -> $driveId');
    }, operationName: '保存账号driveId');
  }

  /// 验证账号登录状态
  Result<bool> validateAccount(CloudDriveAccount account) {
    final descriptor = CloudDriveProviderRegistry.get(account.type);
    if (descriptor == null) {
      throw StateError('未注册云盘描述: ${account.type}');
    }
    logOperation(
      '验证账号登录状态',
      params: {
        'accountName': account.name,
        'accountType': descriptor.displayName ?? account.type.name,
      },
    );

    if (!account.isLoggedIn) {
      logWarning('验证账号登录状态', '账号未登录');
      return const Failure('账号未登录');
    }

    // 根据实际的认证方式验证（而不是云盘类型的默认认证方式）
    final actualAuth = account.actualAuthType;
    if (actualAuth == null) {
      logWarning('验证账号登录状态', '无法确定认证方式');
      return const Failure('无法确定认证方式');
    }

    switch (actualAuth) {
      case AuthType.cookie:
        if (account.cookies == null || account.cookies!.isEmpty) {
          logWarning('验证账号登录状态', 'Cookie为空');
          return const Failure('Cookie为空');
        }
        break;
      case AuthType.authorization:
        if (account.authorizationToken == null ||
            account.authorizationToken!.isEmpty) {
          logWarning('验证账号登录状态', 'Authorization Token为空');
          return const Failure('Authorization Token为空');
        }
        break;
      case AuthType.web:
        if (account.authorizationToken == null ||
            account.authorizationToken!.isEmpty) {
          logWarning('验证账号登录状态', 'Authorization Token为空');
          return const Failure('Authorization Token为空');
        }
        break;
      case AuthType.qrCode:
        if (account.qrCodeToken == null || account.qrCodeToken!.isEmpty) {
          logWarning('验证账号登录状态', 'QR Code Token为空');
          return const Failure('QR Code Token为空');
        }
        break;
    }

    logSuccess('验证账号登录状态', details: '状态有效');
    return const Success(true);
  }

  /// 获取账号统计信息
  Map<String, dynamic> getAccountStats(List<CloudDriveAccount> accounts) {
    final stats = <String, int>{
      'total': accounts.length,
      'loggedIn': 0,
      'loggedOut': 0,
    };

    for (final account in accounts) {
      final id = (CloudDriveProviderRegistry.get(account.type)?.id) ??
          account.type.name;
      stats[id] = (stats[id] ?? 0) + 1;

      if (account.isLoggedIn) {
        stats['loggedIn'] = (stats['loggedIn'] ?? 0) + 1;
      } else {
        stats['loggedOut'] = (stats['loggedOut'] ?? 0) + 1;
      }
    }

    return stats;
  }

  /// 获取指定类型的账号
  List<CloudDriveAccount> getAccountsByType(
    List<CloudDriveAccount> accounts,
    CloudDriveType type,
  ) {
    return accounts.where((account) => account.type == type).toList();
  }

  /// 获取已登录的账号
  List<CloudDriveAccount> getLoggedInAccounts(
    List<CloudDriveAccount> accounts,
  ) {
    return accounts.where((account) => account.isLoggedIn).toList();
  }

  /// 获取未登录的账号
  List<CloudDriveAccount> getLoggedOutAccounts(
    List<CloudDriveAccount> accounts,
  ) {
    return accounts.where((account) => !account.isLoggedIn).toList();
  }
}
