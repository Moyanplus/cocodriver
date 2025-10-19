import '../models/cloud_drive_models.dart';

/// 账号状态
class AccountState {
  final List<CloudDriveAccount> accounts;
  final int currentAccountIndex;
  final bool showAccountSelector;
  final bool isLoading;

  const AccountState({
    this.accounts = const [],
    this.currentAccountIndex = 0,
    this.showAccountSelector = false,
    this.isLoading = false,
  });

  AccountState copyWith({
    List<CloudDriveAccount>? accounts,
    int? currentAccountIndex,
    bool? showAccountSelector,
    bool? isLoading,
  }) {
    return AccountState(
      accounts: accounts ?? this.accounts,
      currentAccountIndex: currentAccountIndex ?? this.currentAccountIndex,
      showAccountSelector: showAccountSelector ?? this.showAccountSelector,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// 获取当前账号
  CloudDriveAccount? get currentAccount {
    if (accounts.isEmpty || currentAccountIndex >= accounts.length) {
      return null;
    }
    return accounts[currentAccountIndex];
  }

  /// 检查是否有账号
  bool get hasAccounts => accounts.isNotEmpty;

  /// 检查当前账号是否有效
  bool get hasValidCurrentAccount => currentAccount != null;
}
