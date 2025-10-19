import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/log_manager.dart';
import '../models/cloud_drive_models.dart';
import '../base/cloud_drive_account_service.dart';
import '../services/baidu/baidu_cloud_drive_service.dart';
import 'cloud_drive_account_state.dart';

/// 账号状态管理器
class AccountNotifier extends StateNotifier<AccountState> {
  AccountNotifier() : super(const AccountState());

  /// 加载账号列表
  Future<void> loadAccounts() async {
    try {
      state = state.copyWith(isLoading: true);
      final accounts = await CloudDriveAccountService.loadAccounts();
      state = state.copyWith(
        accounts: accounts,
        isLoading: false,
        currentAccountIndex: accounts.isNotEmpty ? 0 : -1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      LogManager().error('加载账号列表失败: $e');
    }
  }

  /// 切换账号
  Future<void> switchAccount(int index) async {
    if (index < 0 || index >= state.accounts.length) return;

    state = state.copyWith(currentAccountIndex: index);
  }

  /// 添加账号
  Future<void> addAccount(CloudDriveAccount account) async {
    try {
      LogManager().cloudDrive(
        '➕ 开始添加账号: ${account.name} (${account.type.displayName})',
      );

      await CloudDriveAccountService.addAccount(account);
      LogManager().cloudDrive('✅ 账号已保存到本地存储');

      // 执行云盘特定的初始化逻辑
      await _performAccountInitialization(account);

      await loadAccounts(); // 重新加载账号列表
      LogManager().cloudDrive('✅ 账号列表已重新加载');
    } catch (e) {
      LogManager().cloudDrive('❌ 添加账号失败: $e');
      rethrow;
    }
  }

  /// 删除账号
  Future<void> deleteAccount(String accountId) async {
    try {
      await CloudDriveAccountService.deleteAccount(accountId);
      await loadAccounts(); // 重新加载账号列表
    } catch (e) {
      LogManager().error('删除账号失败: $e');
      rethrow;
    }
  }

  /// 更新账号
  Future<void> updateAccount(CloudDriveAccount account) async {
    try {
      await CloudDriveAccountService.updateAccount(account);
      await loadAccounts(); // 重新加载账号列表
    } catch (e) {
      LogManager().error('更新账号失败: $e');
      rethrow;
    }
  }

  /// 更新账号Cookie
  void updateAccountCookie(String accountId, String newCookies) {
    final accounts =
        state.accounts.map((account) {
          if (account.id == accountId) {
            final updatedAccount = account.copyWith(cookies: newCookies);

            // 清除百度网盘参数缓存
            if (account.type == CloudDriveType.baidu) {
              BaiduCloudDriveService.clearParamCache(accountId);
            }

            return updatedAccount;
          }
          return account;
        }).toList();

    state = state.copyWith(accounts: accounts);
    CloudDriveAccountService.saveAccounts(accounts);
  }

  /// 切换账号选择器显示状态
  void toggleAccountSelector() {
    state = state.copyWith(showAccountSelector: !state.showAccountSelector);
  }

  /// 执行账号特定的初始化逻辑
  Future<void> _performAccountInitialization(CloudDriveAccount account) async {
    try {
      LogManager().cloudDrive('🔧 开始执行账号初始化: ${account.type.displayName}');

      switch (account.type) {
        case CloudDriveType.baidu:
          // 百度网盘：自动获取API参数
          try {
            LogManager().cloudDrive('🔄 百度网盘 - 开始获取API参数');
            await BaiduCloudDriveService.getBaiduParams(account);
            LogManager().cloudDrive('✅ 百度网盘 - API参数获取成功');
          } catch (e) {
            LogManager().cloudDrive('⚠️ 百度网盘 - API参数获取失败: $e');
            // 参数获取失败不影响账号添加，只记录警告
          }
          break;
        case CloudDriveType.quark:
          // 夸克云盘：可以添加特定的初始化逻辑
          LogManager().cloudDrive('🔧 夸克云盘 - 无需特殊初始化');
          break;
        case CloudDriveType.lanzou:
        case CloudDriveType.pan123:
        case CloudDriveType.ali:
          // 其他云盘：暂无特殊初始化需求
          LogManager().cloudDrive('🔧 ${account.type.displayName} - 无需特殊初始化');
          break;
      }

      LogManager().cloudDrive('✅ 账号初始化完成: ${account.type.displayName}');
    } catch (e) {
      LogManager().cloudDrive('⚠️ 账号初始化过程中发生异常: $e');
      // 初始化失败不影响账号添加
    }
  }
}

/// 账号Provider
final accountProvider = StateNotifierProvider<AccountNotifier, AccountState>(
  (ref) => AccountNotifier(),
);
