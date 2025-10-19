import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/log_manager.dart';
import '../core/cloud_drive_initializer.dart';
import '../models/cloud_drive_models.dart';
import 'cloud_drive_state.dart';

/// 云盘主Provider - 管理整体状态和生命周期
class CloudDriveMainProvider extends StateNotifier<CloudDriveState> {
  CloudDriveMainProvider() : super(const CloudDriveState());

  /// 初始化云盘模块
  Future<void> initialize() async {
    try {
      LogManager().cloudDrive(
        '开始初始化云盘模块',
        className: 'CloudDriveMainProvider',
        methodName: 'initialize',
      );

      state = state.copyWith(isInitialized: false);

      // 初始化云盘模块
      await CloudDriveInitializer.initialize();

      state = state.copyWith(isInitialized: true);

      LogManager().cloudDrive(
        '云盘模块初始化成功',
        className: 'CloudDriveMainProvider',
        methodName: 'initialize',
      );
    } catch (e) {
      LogManager().error(
        '云盘模块初始化失败 - $e',
        className: 'CloudDriveMainProvider',
        methodName: 'initialize',
        exception: e,
      );
      rethrow;
    }
  }

  /// 重置云盘模块
  Future<void> reset() async {
    try {
      LogManager().cloudDrive(
        '开始重置云盘模块',
        className: 'CloudDriveMainProvider',
        methodName: 'reset',
      );

      // 重置云盘模块
      CloudDriveInitializer.reset();

      // 重置状态
      state = const CloudDriveState();

      LogManager().cloudDrive(
        '云盘模块重置成功',
        className: 'CloudDriveMainProvider',
        methodName: 'reset',
      );
    } catch (e) {
      LogManager().error(
        '云盘模块重置失败 - $e',
        className: 'CloudDriveMainProvider',
        methodName: 'reset',
        exception: e,
      );
      rethrow;
    }
  }

  /// 检查模块是否已初始化
  bool get isInitialized => CloudDriveInitializer.isInitialized;

  /// 设置账号列表
  void setAccounts(List<CloudDriveAccount> accounts) {
    state = state.copyWith(accounts: accounts);
  }

  /// 设置选中的账号
  void setSelectedAccount(CloudDriveAccount? account) {
    state = state.copyWith(selectedAccount: account);
  }

  /// 清除所有状态
  void clear() {
    state = const CloudDriveState();
  }

  /// 加载账号列表
  Future<void> loadAccounts() async {
    try {
      state = state.copyWith(isInitialized: false);
      // 这里可以添加加载账号的逻辑
      // 暂时使用空列表
      state = state.copyWith(accounts: [], isInitialized: true);
    } catch (e) {
      state = state.copyWith(isInitialized: false);
      rethrow;
    }
  }
}

/// 云盘主Provider实例
final cloudDriveMainProvider =
    StateNotifierProvider<CloudDriveMainProvider, CloudDriveState>(
      (ref) => CloudDriveMainProvider(),
    );
