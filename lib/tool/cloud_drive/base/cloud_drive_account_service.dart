import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/logging/log_manager.dart';
import '../models/cloud_drive_models.dart';

/// 云盘账号管理服务
/// 负责账号的增删改查和持久化存储
class CloudDriveAccountService {
  static const String _storageKey = 'cloud_drive_accounts';

  /// 加载所有账号
  static Future<List<CloudDriveAccount>> loadAccounts() async {
    try {
      LogManager().cloudDrive(
        '加载云盘账号',
        className: 'CloudDriveAccountService',
        methodName: 'loadAccounts',
      );
      final prefs = await SharedPreferences.getInstance();
      final accountsJson = prefs.getString(_storageKey);

      if (accountsJson != null) {
        final List<dynamic> accountsList = jsonDecode(accountsJson);
        final accounts =
            accountsList
                .map((json) => CloudDriveAccount.fromJson(json))
                .toList();
        LogManager().cloudDrive(
          '成功加载 ${accounts.length} 个账号',
          className: 'CloudDriveAccountService',
          methodName: 'loadAccounts',
          data: {'count': accounts.length},
        );
        return accounts;
      }
      return [];
    } catch (e) {
      LogManager().error(
        '加载云盘账号失败',
        className: 'CloudDriveAccountService',
        methodName: 'loadAccounts',
        exception: e,
      );
      return [];
    }
  }

  /// 保存所有账号
  static Future<void> saveAccounts(List<CloudDriveAccount> accounts) async {
    try {
      LogManager().cloudDrive(
        '保存云盘账号: ${accounts.length} 个',
        className: 'CloudDriveAccountService',
        methodName: 'saveAccounts',
        data: {'count': accounts.length},
      );
      final prefs = await SharedPreferences.getInstance();
      final accountsJson = jsonEncode(accounts.map((a) => a.toJson()).toList());
      await prefs.setString(_storageKey, accountsJson);
      LogManager().cloudDrive(
        '账号保存成功',
        className: 'CloudDriveAccountService',
        methodName: 'saveAccounts',
      );
    } catch (e) {
      LogManager().error(
        '保存云盘账号失败',
        className: 'CloudDriveAccountService',
        methodName: 'saveAccounts',
        exception: e,
      );
    }
  }

  /// 添加账号
  static Future<void> addAccount(CloudDriveAccount account) async {
    try {
      LogManager().cloudDrive(
        '开始保存账号到本地存储: ${account.name}',
        className: 'CloudDriveAccountService',
        methodName: 'addAccount',
        data: {'accountName': account.name, 'accountType': account.type},
      );
      final accounts = await loadAccounts();
      LogManager().cloudDrive(
        '当前已有账号数量: ${accounts.length}',
        className: 'CloudDriveAccountService',
        methodName: 'addAccount',
        data: {'currentCount': accounts.length},
      );

      accounts.add(account);
      await saveAccounts(accounts);
      LogManager().cloudDrive(
        '账号保存成功: ${account.name}',
        className: 'CloudDriveAccountService',
        methodName: 'addAccount',
        data: {'accountName': account.name},
      );
    } catch (e) {
      LogManager().error(
        '保存账号失败',
        className: 'CloudDriveAccountService',
        methodName: 'addAccount',
        data: {'accountName': account.name},
        exception: e,
      );
      rethrow;
    }
  }

  /// 更新账号
  static Future<void> updateAccount(CloudDriveAccount updatedAccount) async {
    try {
      final accounts = await loadAccounts();
      final index = accounts.indexWhere((a) => a.id == updatedAccount.id);
      if (index != -1) {
        accounts[index] = updatedAccount;
        await saveAccounts(accounts);
        LogManager().cloudDrive(
          '更新账号成功: ${updatedAccount.name}',
          className: 'CloudDriveAccountService',
          methodName: 'updateAccount',
          data: {
            'accountName': updatedAccount.name,
            'accountId': updatedAccount.id,
          },
        );
      }
    } catch (e) {
      LogManager().error(
        '更新账号失败',
        className: 'CloudDriveAccountService',
        methodName: 'updateAccount',
        data: {'accountId': updatedAccount.id},
        exception: e,
      );
      rethrow;
    }
  }

  /// 删除账号
  static Future<void> deleteAccount(String accountId) async {
    try {
      final accounts = await loadAccounts();
      accounts.removeWhere((a) => a.id == accountId);
      await saveAccounts(accounts);
      LogManager().cloudDrive(
        '删除账号成功: $accountId',
        className: 'CloudDriveAccountService',
        methodName: 'deleteAccount',
        data: {'accountId': accountId},
      );
    } catch (e) {
      LogManager().error(
        '删除账号失败',
        className: 'CloudDriveAccountService',
        methodName: 'deleteAccount',
        data: {'accountId': accountId},
        exception: e,
      );
      rethrow;
    }
  }

  /// 根据ID查找账号
  static Future<CloudDriveAccount?> findAccountById(String accountId) async {
    try {
      final accounts = await loadAccounts();
      return accounts.firstWhere((a) => a.id == accountId);
    } catch (e) {
      LogManager().error(
        '查找账号失败',
        className: 'CloudDriveAccountService',
        methodName: 'findAccountById',
        data: {'accountId': accountId},
        exception: e,
      );
      return null;
    }
  }

  /// 检查账号是否存在
  static Future<bool> accountExists(String accountId) async {
    final account = await findAccountById(accountId);
    return account != null;
  }

  /// 保存账号的driveId
  static Future<void> saveDriveId(
    CloudDriveAccount account,
    String driveId,
  ) async {
    try {
      LogManager().cloudDrive('💾 保存账号driveId: ${account.name} -> $driveId');

      // 创建更新后的账号对象
      final updatedAccount = account.copyWith(driveId: driveId);

      // 更新账号
      await updateAccount(updatedAccount);

      LogManager().cloudDrive('✅ 账号driveId保存成功: ${account.name}');
    } catch (e) {
      LogManager().error('❌ 保存账号driveId失败');
      rethrow;
    }
  }
}
