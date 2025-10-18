import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/base/debug_service.dart';
import '../base/cloud_drive_account_service.dart';
import '../models/cloud_drive_models.dart';
import 'cloud_drive_state.dart';

/// 云盘账号Provider
class CloudDriveAccountProvider extends StateNotifier<CloudDriveAccountState> {
  CloudDriveAccountProvider() : super(const CloudDriveAccountState());

  /// 加载所有账号
  Future<void> loadAccounts() async {
    try {
      DebugService.log(
        '👤 Provider: 开始加载账号列表',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );

      state = state.copyWith(isLoading: true, error: null);

      final accounts = await CloudDriveAccountService.loadAccounts();

      state = state.copyWith(accounts: accounts, isLoading: false, error: null);

      DebugService.log(
        '✅ Provider: 账号列表加载成功 - ${accounts.length} 个账号',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());

      DebugService.log(
        '❌ Provider: 账号列表加载失败 - $e',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );
    }
  }

  /// 切换账号
  void switchAccount(CloudDriveAccount account) {
    DebugService.log(
      '🔄 Provider: 切换账号 - ${account.name}',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.provider',
    );

    state = state.copyWith(selectedAccount: account);
  }

  /// 切换账号选择器显示状态
  void toggleAccountSelector() {
    final newState = !state.isAccountSelectorVisible;

    DebugService.log(
      '👤 Provider: ${newState ? "显示" : "隐藏"}账号选择器',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.provider',
    );

    state = state.copyWith(isAccountSelectorVisible: newState);
  }

  /// 添加账号
  Future<void> addAccount(CloudDriveAccount account) async {
    try {
      DebugService.log(
        '➕ Provider: 添加账号 - ${account.name}',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );

      await CloudDriveAccountService.addAccount(account);

      // 重新加载账号列表
      await loadAccounts();

      DebugService.log(
        '✅ Provider: 账号添加成功 - ${account.name}',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());

      DebugService.log(
        '❌ Provider: 账号添加失败 - $e',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );
    }
  }

  /// 删除账号
  Future<void> deleteAccount(String accountId) async {
    try {
      DebugService.log(
        '🗑️ Provider: 删除账号 - $accountId',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );

      await CloudDriveAccountService.deleteAccount(accountId);

      // 重新加载账号列表
      await loadAccounts();

      DebugService.log(
        '✅ Provider: 账号删除成功 - $accountId',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());

      DebugService.log(
        '❌ Provider: 账号删除失败 - $e',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.provider',
      );
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);

    DebugService.log(
      '✅ Provider: 清除错误状态',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.provider',
    );
  }
}

/// 账号Provider实例
final cloudDriveAccountProvider =
    StateNotifierProvider<CloudDriveAccountProvider, CloudDriveAccountState>(
      (ref) => CloudDriveAccountProvider(),
    );
