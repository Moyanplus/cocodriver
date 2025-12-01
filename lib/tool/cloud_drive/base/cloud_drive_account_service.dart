/// 云盘账号管理服务
///
/// 管理所有云盘账号的生命周期，提供账号的CRUD操作和本地持久化存储。
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// 核心模块导入
import '../../../../../core/logging/log_manager.dart';
import '../services/registry/cloud_drive_provider_registry.dart';
import '../services/registry/cloud_drive_provider_descriptor.dart';
import 'cloud_drive_account_normalizer.dart';

// 云盘数据模型导入
import '../data/models/cloud_drive_entities.dart';

/// 添加账号结果，标识是否替换了已有账号。
class AddAccountResult {
  const AddAccountResult({required this.account, required this.replaced});

  final CloudDriveAccount account;
  final bool replaced;
}

/// 账号存储抽象，便于测试/替换实现。
abstract class CloudDriveAccountStore {
  Future<List<Map<String, dynamic>>> load();
  Future<void> save(List<Map<String, dynamic>> accounts);
}

/// SharedPreferences 版账号存储
class SharedPrefsCloudDriveAccountStore implements CloudDriveAccountStore {
  static const String storageKey = 'cloud_drive_accounts';

  @override
  Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString(storageKey);
    if (accountsJson == null) return const [];
    final List<dynamic> decoded = jsonDecode(accountsJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> save(List<Map<String, dynamic>> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = jsonEncode(accounts);
    await prefs.setString(storageKey, accountsJson);
  }
}

/// 云盘账号管理服务类
///
/// 负责云盘账号的增删改查和持久化存储
/// 使用SharedPreferences进行本地存储，支持账号的序列化和反序列化
class CloudDriveAccountService {
  /// 是否输出详细调试日志（默认关闭，避免噪音）
  static const bool _verboseLogging = false;

  static CloudDriveAccountStore _store = SharedPrefsCloudDriveAccountStore();

  static List<CloudDriveAccount>? _cache;
  static const String _currentAccountKey = 'cloud_drive_current_account_id';

  static Future<CloudDriveAccount> _normalizeAccount(
    CloudDriveAccount account,
  ) async {
    final CloudDriveProviderDescriptor? descriptor =
        CloudDriveProviderRegistry.get(account.type);
    final normalizer = descriptor?.accountNormalizer;
    if (normalizer == null) return account;
    try {
      return await normalizer.normalize(account);
    } catch (e) {
      LogManager().warning(
        '账号归一化失败，使用原始ID',
        className: 'CloudDriveAccountService',
        methodName: '_normalizeAccount',
        data: {'error': e.toString(), 'type': account.type.name},
      );
      return account;
    }
  }

  /// 可注入的存储实现，便于测试/替换
  static void setStore(CloudDriveAccountStore store) {
    _store = store;
    _cache = null;
  }

  /// 加载所有账号
  static Future<List<CloudDriveAccount>> loadAccounts() async {
    try {
      if (_cache != null) {
        return List<CloudDriveAccount>.from(_cache!);
      }
      _debugLog('加载云盘账号');
      final accountsList = await _store.load();
      final accounts = accountsList
          .map(CloudDriveAccount.fromJson)
          .toList(growable: false);
      _cache = List<CloudDriveAccount>.from(accounts);

      // 调试：检查每个加载的账号的cookies情况
      _debugLogAccounts(accounts);

      _debugLog('成功加载账号', data: {'count': accounts.length});
      return List<CloudDriveAccount>.from(accounts);
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
      _debugLog('保存云盘账号', data: {'count': accounts.length});
      _debugLogAccounts(accounts, prefix: '准备序列化账号');

      final raw = accounts.map((a) => a.toJson()).toList(growable: false);
      _cache = List<CloudDriveAccount>.from(accounts);

      // 调试：打印JSON长度
      _debugLog('JSON序列化完成', data: {'jsonLength': raw.toString().length});

      await _store.save(raw);
      _debugLog('账号保存成功');
    } catch (e) {
      LogManager().error(
        '保存云盘账号失败',
        className: 'CloudDriveAccountService',
        methodName: 'saveAccounts',
        exception: e,
      );
    }
  }

  /// 添加账号，返回是否替换了已有账号
  static Future<AddAccountResult> addAccount(CloudDriveAccount account) async {
    try {
      account = await _normalizeAccount(account);
      _debugLog(
        '开始保存账号到本地存储',
        data: {
          'accountName': account.name,
          'accountType': account.type,
          'isLoggedIn': account.isLoggedIn,
        },
      );
      final accounts = await loadAccounts();
      _debugLog('当前已有账号数量', data: {'currentCount': accounts.length});

      final existingIndex = accounts.indexWhere((a) => a.id == account.id);
      final replaced = existingIndex >= 0;
      if (replaced) {
        accounts[existingIndex] = account;
        _debugLog('检测到相同ID账号，已替换', data: {'id': account.id});
      } else {
        accounts.add(account);
      }
      await saveAccounts(accounts);

      // 验证保存后立即读取
      final savedAccounts = await loadAccounts();
      final savedAccount = savedAccounts.firstWhere((a) => a.id == account.id);
      _debugLog(
        '账号保存成功，验证读取',
        data: {
          'accountName': savedAccount.name,
          'isLoggedIn': savedAccount.isLoggedIn,
        },
      );
      return AddAccountResult(account: account, replaced: replaced);
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

  /// 保存当前账号ID（null 表示清除）
  static Future<void> saveCurrentAccountId(String? accountId) async {
    final prefs = await SharedPreferences.getInstance();
    if (accountId == null) {
      await prefs.remove(_currentAccountKey);
    } else {
      await prefs.setString(_currentAccountKey, accountId);
    }
  }

  /// 读取当前账号ID
  static Future<String?> getCurrentAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentAccountKey);
  }

  /// 更新账号
  static Future<void> updateAccount(CloudDriveAccount updatedAccount) async {
    try {
      final accounts = await loadAccounts();
      final index = accounts.indexWhere((a) => a.id == updatedAccount.id);
      if (index != -1) {
        accounts[index] = updatedAccount;
        await saveAccounts(accounts);
        _debugLog(
          '更新账号成功',
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

  /// 更新账号的认证状态（持久化）。
  static Future<void> updateAuthState(
    String accountId, {
    required bool isValid,
    String? message,
  }) async {
    final accounts = await loadAccounts();
    final index = accounts.indexWhere((a) => a.id == accountId);
    if (index == -1) return;

    final now = DateTime.now();
    final updated = accounts[index].copyWith(
      lastAuthValid: isValid,
      lastAuthTime: now,
      lastAuthError: isValid ? null : message,
      clearLastAuthError: isValid,
    );
    accounts[index] = updated;
    await saveAccounts(accounts);
    _debugLog(
      '更新账号认证状态',
      data: {
        'accountId': accountId,
        'isValid': isValid,
        'message': message,
      },
    );
  }

  /// 删除账号
  static Future<void> deleteAccount(String accountId) async {
    try {
      final accounts = await loadAccounts();
      accounts.removeWhere((a) => a.id == accountId);
      await saveAccounts(accounts);
      _debugLog('删除账号成功', data: {'accountId': accountId});
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

  static void _debugLog(String message, {Map<String, dynamic>? data}) {
    if (!_verboseLogging) return;
    LogManager().cloudDrive(
      message,
      className: 'CloudDriveAccountService',
      data: data,
    );
  }

  static void _debugLogAccounts(
    List<CloudDriveAccount> accounts, {
    String prefix = '已加载账号',
  }) {
    if (!_verboseLogging) return;
    for (final account in accounts) {
      LogManager().cloudDrive(
        '$prefix: ${account.name}',
        className: 'CloudDriveAccountService',
        data: {
          'accountId': account.id,
          'accountType': account.type.name,
          'isLoggedIn': account.isLoggedIn,
          'authType': account.primaryAuthType?.name,
          'authValueLength': account.primaryAuthValue?.length ?? 0,
        },
      );
    }
  }
}
