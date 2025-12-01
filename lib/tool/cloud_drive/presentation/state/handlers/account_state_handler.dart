import 'dart:async';

import '../../../base/cloud_drive_account_service.dart';
import '../../../base/cloud_drive_operation_service.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../core/result.dart';
import '../../../infrastructure/logging/cloud_drive_logger_adapter.dart';
import '../cloud_drive_state_manager.dart';
import '../account_validation_service.dart';

/// 账号管理状态处理器
///
/// 负责处理账号的加载、切换、添加、删除、更新等操作的状态管理。
class AccountStateHandler {
  final CloudDriveStateManager _stateManager;
  final CloudDriveLoggerAdapter _logger;
  final AccountValidationService _validationService;

  AccountStateHandler(
    this._stateManager, {
    CloudDriveLoggerAdapter? logger,
    AccountValidationService? validationService,
  })  : _logger = logger ?? _stateManager.logger,
        _validationService =
            validationService ?? AccountValidationService(logger ?? _stateManager.logger);

  /// 加载账号列表
  Future<void> loadAccounts() async {
    _logger.info('加载账号列表');

    try {
      _stateManager.updateState(
        (state) => state.copyWith(isLoading: true, error: null),
      );

      final accounts = await CloudDriveAccountService.getAllAccounts();

      _stateManager.updateState(
        (state) => state.copyWith(
          accounts: accounts,
          accountDetails: {},
          isLoading: false,
          error: null,
        ),
      );

      // 恢复持久化的当前账号
      final savedCurrentId =
          await CloudDriveAccountService.getCurrentAccountId();
      if (savedCurrentId != null && accounts.isNotEmpty) {
        CloudDriveAccount? savedAccount;
        for (final acc in accounts) {
          if (acc.id == savedCurrentId) {
            savedAccount = acc;
            break;
          }
        }
        savedAccount ??= accounts.first;
        _stateManager.updateState(
          (state) => state.copyWith(currentAccount: savedAccount),
        );
      }

      // 预填充持久化的认证状态
      final persistedDetails = <String, CloudDriveAccountDetails>{};
      for (final acc in accounts) {
        if (acc.lastAuthValid != null) {
          persistedDetails[acc.id] = CloudDriveAccountDetails(
            id: acc.id,
            name: acc.name,
            isValid: acc.lastAuthValid!,
          );
        }
      }
      if (persistedDetails.isNotEmpty) {
        _stateManager.updateState(
          (state) => state.copyWith(
            accountDetails: {
              ...state.accountDetails,
              ...persistedDetails,
            },
          ),
        );
      }

      _logger.info('账号列表加载成功: ${accounts.length}个账号');
    } catch (e) {
      _logger.error('加载账号列表失败: $e');
      _stateManager.updateState(
        (state) => state.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  /// 统一的认证失效处理：标记失效、清理凭证、更新持久化，并提示。
  Future<void> _handleAuthFailure(
    CloudDriveAccount account,
    String message, {
    String? errorMessage,
  }) async {
    final cleared = account.copyWith(
      clearAuthorizationToken: true,
      clearCookies: true,
      clearQrCodeToken: true,
      lastAuthValid: false,
      lastAuthTime: DateTime.now(),
      lastAuthError: errorMessage ?? message,
    );

    await CloudDriveAccountService.updateAccount(cleared);
    await CloudDriveAccountService.updateAuthState(
      account.id,
      isValid: false,
      message: errorMessage ?? message,
    );

    final stateNow = _stateManager.getCurrentState();
    final updatedAccounts = stateNow.accounts
        .map((a) => a.id == account.id ? cleared : a)
        .toList();
    final updatedDetails = Map<String, CloudDriveAccountDetails>.from(
      stateNow.accountDetails,
    )..[account.id] = CloudDriveAccountDetails(
        id: account.id,
        name: account.name,
        isValid: false,
      );

    _stateManager.updateState(
      (state) => state.copyWith(
        accounts: updatedAccounts,
        accountDetails: updatedDetails,
        currentAccount:
            state.currentAccount?.id == account.id ? null : state.currentAccount,
        error: message,
      ),
    );
  }

  /// 切换当前账号，切换成功后自动加载根目录内容
  ///
  /// [accountIndex] 要切换到的账号索引
  Future<void> switchAccount(int accountIndex) async {
    _logger.info('切换账号: $accountIndex');

    try {
      final previousState = _stateManager.getCurrentState();
      if (accountIndex < 0 || accountIndex >= previousState.accounts.length) {
        throw Exception('账号索引无效: $accountIndex');
      }

      final account = previousState.accounts[accountIndex];
      // 先切换，再校验；校验失败则回滚
      _stateManager.updateState(
        (state) => state.copyWith(
          currentAccount: account,
          currentFolder: null,
          files: [],
          folders: [],
          selectedItems: {},
          isInBatchMode: false,
          error: null,
        ),
      );

      if (account.isLoggedIn) {
        final details = await _fetchAndStoreAccountDetails(account);
        if (details != null && details.isValid == false) {
          _logger.warning('账号切换失败，认证失效: ${account.name}');
          _stateManager.setState(
            previousState.copyWith(
              accountDetails: _stateManager.getCurrentState().accountDetails,
              error: '账号已失效，请重新登录：${account.name}',
            ),
          );
          return;
        }
        await CloudDriveAccountService.saveCurrentAccountId(account.id);
      }

      // 不在此处自动加载文件列表，避免侧边栏切换账号时频繁触发文件接口。
      // 进入文件页时再按需加载。

      _logger.info('账号切换成功: ${account.name}');
    } catch (e) {
      _logger.error('切换账号失败: $e');
      _stateManager.updateState((state) => state.copyWith(error: e.toString()));
    }
  }

  /// 添加新的云盘账号
  ///
  /// [account] 要添加的云盘账号
  Future<AddAccountResult> addAccount(CloudDriveAccount account) async {
    _logger.info('添加账号: ${account.name}');

    try {
      final result = await CloudDriveAccountService.addAccount(account);

      // 重新加载账号列表
      await loadAccounts();

      _logger.info('账号添加成功: ${account.name}');
      return result;
    } catch (e) {
      _logger.error('添加账号失败: $e');
      _stateManager.updateState((state) => state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  /// 删除指定的云盘账号
  ///
  /// 如果删除的是当前账号，会重置当前账号状态。
  ///
  /// [accountId] 要删除的账号ID
  Future<void> deleteAccount(String accountId) async {
    _logger.info('删除账号: $accountId');

    try {
      final currentState = _stateManager.getCurrentState();
      final currentAccount = currentState.currentAccount;
      final isCurrentAccount =
          currentAccount != null && currentAccount.id == accountId;

      // 删除账号
      await CloudDriveAccountService.deleteAccount(accountId);

      // 重新加载账号列表
      await loadAccounts();

      // 如果删除的是当前账号，需要重新设置当前账号
      if (isCurrentAccount) {
        final updatedState = _stateManager.getCurrentState();
        if (updatedState.accounts.isNotEmpty) {
          // 切换到第一个账号
          await switchAccount(0);
        } else {
          // 没有账号了，清空当前账号和文件列表
          _stateManager.updateState(
            (state) => state.copyWith(
              currentAccount: null,
              currentFolder: null,
              files: [],
              folders: [],
              selectedItems: {},
              isInBatchMode: false,
            ),
          );
        }
      }

      _logger.info('账号删除成功: $accountId');
    } catch (e) {
      _logger.error('删除账号失败: $e');
      _stateManager.updateState((state) => state.copyWith(error: e.toString()));
    }
  }

  /// 更新云盘账号信息
  ///
  /// [account] 要更新的云盘账号
  Future<void> updateAccount(CloudDriveAccount account) async {
    _logger.info('更新账号: ${account.name}');

    try {
      await CloudDriveAccountService.updateAccount(account);

      // 重新加载账号列表
      await loadAccounts();

      // 如果更新的是当前账号，更新当前账号信息
      final currentState = _stateManager.getCurrentState();
      if (currentState.currentAccount?.id == account.id) {
        _stateManager.updateState(
          (state) => state.copyWith(currentAccount: account),
        );
      }

      _logger.info('账号更新成功: ${account.name}');
    } catch (e) {
      _logger.error('更新账号失败: $e');
      _stateManager.updateState((state) => state.copyWith(error: e.toString()));
    }
  }

  /// 验证当前账号的有效性
  Future<bool> validateCurrentAccount() async {
    final account = _stateManager.getCurrentState().currentAccount;
    if (account == null) return false;

    try {
      _logger.info('验证账号: ${account.name}');

      // 这里可以调用具体的验证逻辑
      // 例如：await CloudDriveOperationService.validateAccount(account);

      return true;
    } catch (e) {
      _logger.error('账号验证失败: $e');
      return false;
    }
  }

  /// 获取账号详情（昵称/容量等），由各云盘策略适配到通用模型
  Future<CloudDriveAccountDetails?> getAccountDetails(
    CloudDriveAccount account,
  ) async {
    try {
      _logger.info('获取账号详情: ${account.name}');
      final strategy = CloudDriveOperationService.getStrategy(account.type);
      if (strategy == null) {
        _logger.warning('未找到策略，无法获取账号详情: ${account.type}');
        return null;
      }
      return await strategy.getAccountDetails(account: account);
    } catch (e, stack) {
      _logger.error('获取账号详情失败: $e\n$stack');
      return null;
    }
  }

  /// 刷新并写入账号详情，返回获取的详情
  Future<CloudDriveAccountDetails?> refreshAccountDetails(
    CloudDriveAccount account,
  ) =>
      _fetchAndStoreAccountDetails(account);

  /// 更新账号的Cookie信息
  ///
  /// [accountId] 要更新Cookie的账号ID
  /// [newCookies] 新的Cookie字符串
  Future<void> updateAccountCookies(String accountId, String newCookies) async {
    _logger.info('更新账号Cookie: $accountId');

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

      final currentState = _stateManager.getCurrentState();
      _stateManager.updateState(
        (state) => state.copyWith(
          accounts:
              accounts
                  .map((a) => a.id == accountId ? updatedAccount : a)
                  .toList(),
          currentAccount:
              currentState.currentAccount?.id == accountId
                  ? updatedAccount
                  : currentState.currentAccount,
        ),
      );

      _logger.info('账号Cookie更新成功');
    } catch (e) {
      _logger.error('更新账号Cookie失败: $e');
      _stateManager.updateState((state) => state.copyWith(error: e.toString()));
    }
  }

  Future<void> _refreshAccountDetails(List<CloudDriveAccount> accounts) async {
    for (final account in accounts) {
      await _fetchAndStoreAccountDetails(account);
    }
  }

  Future<CloudDriveAccountDetails?> _fetchAndStoreAccountDetails(
    CloudDriveAccount account,
  ) async {
    try {
      _setValidating(account.id, true);
      final details = await getAccountDetails(account);
      if (details != null) {
        _stateManager.updateState((state) {
          final updated = Map<String, CloudDriveAccountDetails>.from(
            state.accountDetails,
          );
          updated[account.id] = details;
          final newValidating = Set<String>.from(
            state.accountState.validatingAccountIds,
          )..remove(account.id);
          return state.copyWith(
            accountDetails: updated,
            accountState:
                state.accountState.copyWith(validatingAccountIds: newValidating),
          );
        });
        await CloudDriveAccountService.updateAuthState(
          account.id,
          isValid: details.isValid,
          message: null,
        );
        if (details.isValid == false) {
          await _handleAuthFailure(account, '账号已失效，请重新登录：${account.name}');
        }
      }
      return details;
    } on CloudDriveException catch (e, stack) {
      _logger.error('获取账号详情失败: $e\n$stack');
      if (e.type == CloudDriveErrorType.authentication) {
        await _handleAuthFailure(
          account,
          '账号已失效，请重新登录：${account.name}',
          errorMessage: e.message,
        );
        return CloudDriveAccountDetails(
          id: account.id,
          name: account.name,
          isValid: false,
        );
      }
      return null;
    } catch (e, stack) {
      _logger.error('获取账号详情失败: $e\n$stack');
      return null;
    } finally {
      _setValidating(account.id, false);
    }
  }

  Future<void> _validateAndStoreAccount(CloudDriveAccount account) async {
    _setValidating(account.id, true);
    final details = await _validationService.fetchDetails(account);
    if (details == null) return;
    _stateManager.updateState((state) {
      final updated = Map<String, CloudDriveAccountDetails>.from(
        state.accountDetails,
      );
      updated[account.id] = details;
      final newValidating = Set<String>.from(
        state.accountState.validatingAccountIds,
      )..remove(account.id);
      return state.copyWith(
        accountDetails: updated,
        accountState:
            state.accountState.copyWith(validatingAccountIds: newValidating),
      );
    });
    if (!details.isValid) {
      _stateManager.updateState(
        (state) => state.copyWith(
          error: '账号已失效，请重新登录或更新凭证',
          showAccountSelector: true,
        ),
      );
    }
    _setValidating(account.id, false);
  }

  void _setValidating(String accountId, bool isValidating) {
    _stateManager.updateState((state) {
      final next = Set<String>.from(state.accountState.validatingAccountIds);
      if (isValidating) {
        next.add(accountId);
      } else {
        next.remove(accountId);
      }
      return state.copyWith(
        accountState: state.accountState.copyWith(
          validatingAccountIds: next,
        ),
      );
    });
  }
}
