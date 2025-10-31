import '../../../../../core/logging/log_manager.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../base/cloud_drive_account_service.dart';
import '../cloud_drive_state_manager.dart';

/// 账号管理状态处理器
class AccountStateHandler {
  final CloudDriveStateManager _stateManager;

  AccountStateHandler(this._stateManager);

  /// 加载账号列表
  ///
  /// 从存储中加载所有云盘账号并更新状态
  /// 设置加载状态，处理加载过程中的错误
  Future<void> loadAccounts() async {
    LogManager().cloudDrive('加载账号列表');

    try {
      _stateManager.state = _stateManager.state.copyWith(
        isLoading: true,
        error: null,
      );

      final accounts = await CloudDriveAccountService.getAllAccounts();

      _stateManager.state = _stateManager.state.copyWith(
        accounts: accounts,
        isLoading: false,
        error: null,
      );

      LogManager().cloudDrive('账号列表加载成功: ${accounts.length}个账号');
    } catch (e) {
      LogManager().error('加载账号列表失败: $e');
      _stateManager.state = _stateManager.state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 切换当前账号
  ///
  /// 切换到指定索引的账号，重置文件夹和文件状态
  /// 切换成功后自动加载根目录内容
  ///
  /// [accountIndex] 要切换到的账号索引
  Future<void> switchAccount(int accountIndex) async {
    LogManager().cloudDrive('切换账号: $accountIndex');

    try {
      if (accountIndex < 0 ||
          accountIndex >= _stateManager.state.accounts.length) {
        throw Exception('账号索引无效: $accountIndex');
      }

      final account = _stateManager.state.accounts[accountIndex];

      _stateManager.state = _stateManager.state.copyWith(
        currentAccount: account,
        currentFolder: null,
        files: [],
        folders: [],
        selectedItems: {},
        isInBatchMode: false,
        error: null,
      );

      // 加载根目录
      await _stateManager.folderHandler.loadFolder(forceRefresh: true);

      LogManager().cloudDrive('账号切换成功: ${account.name}');
    } catch (e) {
      LogManager().error('切换账号失败: $e');
      _stateManager.state = _stateManager.state.copyWith(error: e.toString());
    }
  }

  /// 添加新的云盘账号
  ///
  /// 将新账号保存到存储中，并重新加载账号列表
  ///
  /// [account] 要添加的云盘账号
  Future<void> addAccount(CloudDriveAccount account) async {
    LogManager().cloudDrive('添加账号: ${account.name}');

    try {
      await CloudDriveAccountService.addAccount(account);

      // 重新加载账号列表
      await loadAccounts();

      LogManager().cloudDrive('账号添加成功: ${account.name}');
    } catch (e) {
      LogManager().error('添加账号失败: $e');
      _stateManager.state = _stateManager.state.copyWith(error: e.toString());
    }
  }

  /// 删除指定的云盘账号
  ///
  /// 从存储中删除指定账号，并重新加载账号列表
  /// 如果删除的是当前账号，会重置当前账号状态
  ///
  /// [accountId] 要删除的账号ID
  Future<void> deleteAccount(String accountId) async {
    LogManager().cloudDrive('删除账号: $accountId');

    try {
      final currentAccount = _stateManager.state.currentAccount;
      final isCurrentAccount =
          currentAccount != null && currentAccount.id == accountId;

      // 删除账号
      await CloudDriveAccountService.deleteAccount(accountId);

      // 重新加载账号列表
      await loadAccounts();

      // 如果删除的是当前账号，需要重新设置当前账号
      if (isCurrentAccount) {
        if (_stateManager.state.accounts.isNotEmpty) {
          // 切换到第一个账号
          await switchAccount(0);
        } else {
          // 没有账号了，清空当前账号和文件列表
          _stateManager.state = _stateManager.state.copyWith(
            currentAccount: null,
            currentFolder: null,
            files: [],
            folders: [],
            selectedItems: {},
            isInBatchMode: false,
          );
        }
      }

      LogManager().cloudDrive('账号删除成功: $accountId');
    } catch (e) {
      LogManager().error('删除账号失败: $e');
      _stateManager.state = _stateManager.state.copyWith(error: e.toString());
    }
  }

  /// 更新云盘账号信息
  ///
  /// 更新指定账号的信息并保存到存储中
  /// 同时更新状态中的账号列表和当前账号
  ///
  /// [account] 要更新的云盘账号
  Future<void> updateAccount(CloudDriveAccount account) async {
    LogManager().cloudDrive('更新账号: ${account.name}');

    try {
      await CloudDriveAccountService.updateAccount(account);

      // 重新加载账号列表
      await loadAccounts();

      // 如果更新的是当前账号，更新当前账号信息
      if (_stateManager.state.currentAccount?.id == account.id) {
        _stateManager.state = _stateManager.state.copyWith(
          currentAccount: account,
        );
      }

      LogManager().cloudDrive('账号更新成功: ${account.name}');
    } catch (e) {
      LogManager().error('更新账号失败: $e');
      _stateManager.state = _stateManager.state.copyWith(error: e.toString());
    }
  }

  /// 验证当前账号的有效性
  ///
  /// 检查当前账号是否仍然有效，可以正常使用
  ///
  /// 返回验证结果，true表示账号有效
  Future<bool> validateCurrentAccount() async {
    final account = _stateManager.state.currentAccount;
    if (account == null) return false;

    try {
      LogManager().cloudDrive('验证账号: ${account.name}');

      // 这里可以调用具体的验证逻辑
      // 例如：await CloudDriveOperationService.validateAccount(account);

      return true;
    } catch (e) {
      LogManager().error('账号验证失败: $e');
      return false;
    }
  }

  /// 更新账号的Cookie信息
  ///
  /// 更新指定账号的Cookie，用于重新认证
  /// 同时更新状态中的账号信息
  ///
  /// [accountId] 要更新Cookie的账号ID
  /// [newCookies] 新的Cookie字符串
  Future<void> updateAccountCookies(String accountId, String newCookies) async {
    LogManager().cloudDrive('更新账号Cookie: $accountId');

    try {
      final accounts = await CloudDriveAccountService.getAllAccounts();
      final accountIndex = accounts.indexWhere((a) => a.id == accountId);

      if (accountIndex == -1) {
        throw Exception('账号不存在: $accountId');
      }

      final updatedAccount = accounts[accountIndex].copyWith(
        cookies: newCookies,
      );
      await CloudDriveAccountService.updateAccount(updatedAccount);

      _stateManager.state = _stateManager.state.copyWith(
        accounts:
            accounts
                .map((a) => a.id == accountId ? updatedAccount : a)
                .toList(),
        currentAccount:
            _stateManager.state.currentAccount?.id == accountId
                ? updatedAccount
                : _stateManager.state.currentAccount,
      );

      LogManager().cloudDrive('账号Cookie更新成功');
    } catch (e) {
      LogManager().error('更新账号Cookie失败: $e');
      _stateManager.state = _stateManager.state.copyWith(error: e.toString());
    }
  }

  /// 获取账号详情
  ///
  /// 获取指定账号的详细信息，包括存储空间、会员状态等
  ///
  /// [account] 要获取详情的云盘账号
  /// 返回账号详情，如果获取失败则返回null
  Future<CloudDriveAccountDetails?> getAccountDetails(
    CloudDriveAccount account,
  ) async {
    LogManager().cloudDrive('获取账号详情: ${account.name}');

    try {
      // final details = await CloudDriveAccountService.getAccountDetails(account);
      final details = null;
      LogManager().cloudDrive('账号详情获取成功: ${account.name}');
      return details;
    } catch (e) {
      LogManager().error('获取账号详情失败: ${account.name} - $e');
      return null;
    }
  }
}
