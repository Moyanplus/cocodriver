/// 更新功能的状态管理
///
/// 使用 Riverpod 管理更新检查、下载、安装等状态
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/update_models.dart';
import '../services/update_service.dart';

/// 更新服务 Provider
final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

/// 更新状态管理器
class UpdateNotifier extends StateNotifier<UpdateState> {
  final UpdateService _updateService;

  UpdateNotifier(this._updateService) : super(const UpdateStateInitial());

  /// 检查更新
  Future<void> checkForUpdate({
    bool forceUpdate = false,
    bool hasUpdate = true,
    bool showNoUpdateMessage = true,
  }) async {
    state = const UpdateStateChecking();

    try {
      final result = await _updateService.checkForUpdate(
        forceUpdate: forceUpdate,
        hasUpdate: hasUpdate,
      );

      if (result.error != null) {
        state = UpdateStateError(result.error!);
        return;
      }

      if (result.hasUpdate && result.updateInfo != null) {
        state = UpdateStateAvailable(result.updateInfo!);
      } else {
        state = UpdateStateNoUpdate(
          showMessage: showNoUpdateMessage,
          currentVersion: result.currentVersion,
        );
      }
    } catch (e) {
      debugPrint('检查更新异常: $e');
      state = UpdateStateError(e.toString());
    }
  }

  /// 开始下载
  void startDownload(UpdateInfo updateInfo) {
    state = UpdateStateDownloading(
      updateInfo: updateInfo,
      progress: DownloadProgress.empty,
    );

    _updateService
        .downloadUpdate(updateInfo)
        .listen(
          (progress) {
            // 只在下载中或完成时更新状态
            if (state is UpdateStateDownloading ||
                progress.status == DownloadStatus.completed) {
              state = UpdateStateDownloading(
                updateInfo: updateInfo,
                progress: progress,
              );

              // 下载完成，自动切换到准备安装状态
              if (progress.status == DownloadStatus.completed) {
                state = UpdateStateReadyToInstall(
                  updateInfo: updateInfo,
                  filePath: progress.filePath ?? '',
                );
              }
            }
          },
          onError: (error) {
            debugPrint('下载错误: $error');
            state = UpdateStateDownloadError(
              updateInfo: updateInfo,
              error: error.toString(),
            );
          },
        );
  }

  /// 取消下载
  void cancelDownload() {
    _updateService.cancelDownload();
    state = const UpdateStateInitial();
  }

  /// 安装更新
  Future<void> installUpdate(String filePath, UpdateInfo updateInfo) async {
    state = UpdateStateInstalling(updateInfo: updateInfo);

    try {
      // 验证文件
      final isValid = await _updateService.verifyUpdatePackage(
        filePath,
        updateInfo.md5,
      );

      if (!isValid) {
        state = UpdateStateInstallError(
          updateInfo: updateInfo,
          error: '文件验证失败，请重新下载',
        );
        return;
      }

      // 安装
      final success = await _updateService.installUpdate(filePath);

      if (success) {
        state = UpdateStateInstalled(updateInfo: updateInfo);
      } else {
        state = UpdateStateInstallError(
          updateInfo: updateInfo,
          error: '安装失败，请稍后重试',
        );
      }
    } catch (e) {
      debugPrint('安装异常: $e');
      state = UpdateStateInstallError(
        updateInfo: updateInfo,
        error: e.toString(),
      );
    }
  }

  /// 重置状态
  void reset() {
    state = const UpdateStateInitial();
  }

  /// 清理下载文件
  Future<void> cleanupDownloads() async {
    await _updateService.cleanupDownloadFiles();
  }
}

/// 更新状态 Provider
final updateProvider = StateNotifierProvider<UpdateNotifier, UpdateState>((
  ref,
) {
  final service = ref.watch(updateServiceProvider);
  return UpdateNotifier(service);
});

/// 更新状态
sealed class UpdateState {
  const UpdateState();

  /// 初始状态
  const factory UpdateState.initial() = UpdateStateInitial;

  /// 检查中
  const factory UpdateState.checking() = UpdateStateChecking;

  /// 有可用更新
  const factory UpdateState.available(UpdateInfo updateInfo) =
      UpdateStateAvailable;

  /// 没有更新
  const factory UpdateState.noUpdate({
    required bool showMessage,
    required VersionInfo currentVersion,
  }) = UpdateStateNoUpdate;

  /// 下载中
  const factory UpdateState.downloading({
    required UpdateInfo updateInfo,
    required DownloadProgress progress,
  }) = UpdateStateDownloading;

  /// 准备安装
  const factory UpdateState.readyToInstall({
    required UpdateInfo updateInfo,
    required String filePath,
  }) = UpdateStateReadyToInstall;

  /// 安装中
  const factory UpdateState.installing({required UpdateInfo updateInfo}) =
      UpdateStateInstalling;

  /// 已安装
  const factory UpdateState.installed({required UpdateInfo updateInfo}) =
      UpdateStateInstalled;

  /// 检查错误
  const factory UpdateState.error(String message) = UpdateStateError;

  /// 下载错误
  const factory UpdateState.downloadError({
    required UpdateInfo updateInfo,
    required String error,
  }) = UpdateStateDownloadError;

  /// 安装错误
  const factory UpdateState.installError({
    required UpdateInfo updateInfo,
    required String error,
  }) = UpdateStateInstallError;
}

// 状态实现类（公开以便在其他文件中使用）
class UpdateStateInitial extends UpdateState {
  const UpdateStateInitial();
}

class UpdateStateChecking extends UpdateState {
  const UpdateStateChecking();
}

class UpdateStateAvailable extends UpdateState {
  final UpdateInfo updateInfo;
  const UpdateStateAvailable(this.updateInfo);
}

class UpdateStateNoUpdate extends UpdateState {
  final bool showMessage;
  final VersionInfo currentVersion;
  const UpdateStateNoUpdate({
    required this.showMessage,
    required this.currentVersion,
  });
}

class UpdateStateDownloading extends UpdateState {
  final UpdateInfo updateInfo;
  final DownloadProgress progress;
  const UpdateStateDownloading({
    required this.updateInfo,
    required this.progress,
  });
}

class UpdateStateReadyToInstall extends UpdateState {
  final UpdateInfo updateInfo;
  final String filePath;
  const UpdateStateReadyToInstall({
    required this.updateInfo,
    required this.filePath,
  });
}

class UpdateStateInstalling extends UpdateState {
  final UpdateInfo updateInfo;
  const UpdateStateInstalling({required this.updateInfo});
}

class UpdateStateInstalled extends UpdateState {
  final UpdateInfo updateInfo;
  const UpdateStateInstalled({required this.updateInfo});
}

class UpdateStateError extends UpdateState {
  final String message;
  const UpdateStateError(this.message);
}

class UpdateStateDownloadError extends UpdateState {
  final UpdateInfo updateInfo;
  final String error;
  const UpdateStateDownloadError({
    required this.updateInfo,
    required this.error,
  });
}

class UpdateStateInstallError extends UpdateState {
  final UpdateInfo updateInfo;
  final String error;
  const UpdateStateInstallError({
    required this.updateInfo,
    required this.error,
  });
}
