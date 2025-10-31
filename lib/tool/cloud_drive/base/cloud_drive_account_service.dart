/// 云盘账号管理服务
///
/// 管理所有云盘账号的生命周期，提供账号的CRUD操作和本地持久化存储。

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// 核心模块导入
import '../../../../../core/logging/log_manager.dart';

// 云盘数据模型导入
import '../data/models/cloud_drive_entities.dart';

/// 云盘账号管理服务类
///
/// 负责云盘账号的增删改查和持久化存储
/// 使用SharedPreferences进行本地存储，支持账号的序列化和反序列化
class CloudDriveAccountService {
  // SharedPreferences存储键
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
        LogManager().cloudDrive(
          '从存储读取JSON',
          className: 'CloudDriveAccountService',
          methodName: 'loadAccounts',
          data: {'jsonLength': accountsJson.length},
        );

        final List<dynamic> accountsList = jsonDecode(accountsJson);
        final accounts =
            accountsList
                .map((json) => CloudDriveAccount.fromJson(json))
                .toList();

        // 调试：检查每个加载的账号的cookies情况
        for (final account in accounts) {
          LogManager().cloudDrive(
            '已加载账号: ${account.name}',
            className: 'CloudDriveAccountService',
            methodName: 'loadAccounts',
            data: {
              'accountId': account.id,
              'accountType': account.type.name,
              'isLoggedIn': account.isLoggedIn,
              'hasCookies':
                  account.cookies != null && account.cookies!.isNotEmpty,
              'cookiesLength': account.cookies?.length ?? 0,
              'hasAuthToken':
                  account.authorizationToken != null &&
                  account.authorizationToken!.isNotEmpty,
              'hasQrToken':
                  account.qrCodeToken != null &&
                  account.qrCodeToken!.isNotEmpty,
            },
          );
        }

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

      // 调试：检查每个账号的cookies情况
      for (final account in accounts) {
        LogManager().cloudDrive(
          '准备序列化账号: ${account.name}',
          className: 'CloudDriveAccountService',
          methodName: 'saveAccounts',
          data: {
            'accountId': account.id,
            'isLoggedIn': account.isLoggedIn,
            'hasCookies':
                account.cookies != null && account.cookies!.isNotEmpty,
            'cookiesLength': account.cookies?.length ?? 0,
          },
        );
      }

      final prefs = await SharedPreferences.getInstance();
      final accountsJson = jsonEncode(accounts.map((a) => a.toJson()).toList());

      // 调试：打印JSON长度
      LogManager().cloudDrive(
        'JSON序列化完成',
        className: 'CloudDriveAccountService',
        methodName: 'saveAccounts',
        data: {'jsonLength': accountsJson.length},
      );

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
        data: {
          'accountName': account.name,
          'accountType': account.type,
          'isLoggedIn': account.isLoggedIn,
          'hasCookies': account.cookies != null && account.cookies!.isNotEmpty,
          'cookiesLength': account.cookies?.length ?? 0,
        },
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

      // 验证保存后立即读取
      final savedAccounts = await loadAccounts();
      final savedAccount = savedAccounts.firstWhere((a) => a.id == account.id);
      LogManager().cloudDrive(
        '账号保存成功，验证读取: ${account.name}',
        className: 'CloudDriveAccountService',
        methodName: 'addAccount',
        data: {
          'accountName': savedAccount.name,
          'isLoggedIn': savedAccount.isLoggedIn,
          'hasCookies':
              savedAccount.cookies != null && savedAccount.cookies!.isNotEmpty,
          'cookiesLength': savedAccount.cookies?.length ?? 0,
        },
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
      LogManager().cloudDrive('保存账号driveId: ${account.name} -> $driveId');

      // 创建更新后的账号对象
      final updatedAccount = account.copyWith(driveId: driveId);

      // 更新账号
      await updateAccount(updatedAccount);

      LogManager().cloudDrive('账号driveId保存成功: ${account.name}');
    } catch (e) {
      LogManager().error('保存账号driveId失败');
      rethrow;
    }
  }

  /// 获取所有账号（别名方法）
  static Future<List<CloudDriveAccount>> getAllAccounts() async {
    return await loadAccounts();
  }
}
