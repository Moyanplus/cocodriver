import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/logging/cloud_drive_logger_adapter.dart';
import '../state/cloud_drive_state_manager.dart';
import '../state/cloud_drive_state_model.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import '../../utils/file_type_utils.dart';
import '../state/handlers/account_state_handler.dart';
import '../state/handlers/folder_state_handler.dart';
import '../state/handlers/batch_operation_handler.dart';
import '../../base/cloud_drive_service_gateway.dart';

typedef _HandlerBuilder<T> = T Function(CloudDriveStateManager manager);

final cloudDriveLoggerProvider = Provider<CloudDriveLoggerAdapter>(
  (ref) => DefaultCloudDriveLoggerAdapter(),
);

final accountHandlerBuilderProvider =
    Provider<_HandlerBuilder<AccountStateHandler>>((ref) {
      final logger = ref.watch(cloudDriveLoggerProvider);
      return (manager) => AccountStateHandler(manager, logger: logger);
    });

final folderHandlerBuilderProvider =
    Provider<_HandlerBuilder<FolderStateHandler>>((ref) {
      final logger = ref.watch(cloudDriveLoggerProvider);
      final gateway = ref.watch(cloudDriveGatewayProvider);
      return (manager) => FolderStateHandler(
        manager,
        logger: logger,
        gateway: gateway,
      );
    });

final batchHandlerBuilderProvider =
    Provider<_HandlerBuilder<BatchOperationHandler>>((ref) {
      final logger = ref.watch(cloudDriveLoggerProvider);
      final gateway = ref.watch(cloudDriveGatewayProvider);
      return (manager) => BatchOperationHandler(
        manager,
        logger: logger,
        gateway: gateway,
      );
    });

final pendingHandlerBuilderProvider =
    Provider<_HandlerBuilder<PendingOperationHandler>>((ref) {
      final gateway = ref.watch(cloudDriveGatewayProvider);
      return (manager) => PendingOperationHandler(manager, gateway: gateway);
    });

/// 云盘服务网关 Provider（可在测试/特定环境替换）
final cloudDriveGatewayProvider = Provider<CloudDriveServiceGateway>(
  (ref) => defaultCloudDriveGateway,
);

/// 云盘状态管理器 Provider
final cloudDriveStateManagerProvider =
    StateNotifierProvider<CloudDriveStateManager, CloudDriveState>(
      (ref) => CloudDriveStateManager(
        logger: ref.watch(cloudDriveLoggerProvider),
        accountHandlerBuilder: ref.watch(accountHandlerBuilderProvider),
        folderHandlerBuilder: ref.watch(folderHandlerBuilderProvider),
        batchHandlerBuilder: ref.watch(batchHandlerBuilderProvider),
        pendingHandlerBuilder: ref.watch(pendingHandlerBuilderProvider),
      ),
    );

/// 云盘状态 Provider - 简化访问
final cloudDriveProvider = cloudDriveStateManagerProvider;

/// 云盘事件处理器 Provider
final cloudDriveEventHandlerProvider =
    Provider<CloudDriveStateManager>((ref) {
      return ref.read(cloudDriveStateManagerProvider.notifier);
    });

/// 文件类型图标缓存 Provider
final fileTypeIconProvider = Provider.family<IconData, String>(
  (ref, fileName) => FileTypeUtils.getFileTypeIcon(fileName),
);

/// 文件类型颜色缓存 Provider
final fileTypeColorProvider = Provider.family<Color, String>(
  (ref, fileName) => FileTypeUtils.getFileTypeColor(fileName),
);

/// 文件类型信息缓存 Provider
final fileTypeInfoProvider = Provider.family<FileTypeInfo, String>(
  (ref, fileName) => FileTypeUtils.getFileTypeInfo(fileName),
);

/// 当前账号 Provider
final currentAccountProvider = Provider<CloudDriveAccount?>(
  (ref) => ref.watch(cloudDriveProvider).currentAccount,
);

/// 当前文件夹内容 Provider
final currentFolderContentProvider =
    Provider<Map<String, List<CloudDriveFile>>>((ref) {
      final state = ref.watch(cloudDriveProvider);
      return {'folders': state.folders, 'files': state.files};
    });

/// 文件统计信息 Provider
final fileStatsProvider = Provider<Map<String, int>>(
  (ref) => ref.watch(cloudDriveProvider).fileStats,
);

/// 批量模式状态 Provider
final batchModeProvider = Provider<bool>(
  (ref) => ref.watch(cloudDriveProvider).isBatchMode,
);

/// 选中项目 Provider
final selectedItemsProvider = Provider<Set<String>>(
  (ref) => ref.watch(cloudDriveProvider).selectedItems,
);

/// 选中文件 Provider
final selectedFilesProvider = Provider<List<CloudDriveFile>>(
  (ref) => ref.watch(cloudDriveProvider).selectedFiles,
);

/// 选中文件夹 Provider
final selectedFoldersProvider = Provider<List<CloudDriveFile>>(
  (ref) => ref.watch(cloudDriveProvider).selectedFolders,
);

/// 加载状态 Provider
final loadingStateProvider = Provider<Map<String, bool>>((ref) {
  final state = ref.watch(cloudDriveProvider);
  return {
    'isLoading': state.isLoading,
    'isRefreshing': state.isRefreshing,
    'isLoadingMore': state.isLoadingMore,
    'isBusy': state.isBusy,
  };
});

/// 错误状态 Provider
final errorStateProvider = Provider<String?>(
  (ref) => ref.watch(cloudDriveProvider).error,
);

/// 路径导航 Provider
final pathNavigationProvider = Provider<List<PathInfo>>(
  (ref) => ref.watch(cloudDriveProvider).folderPath,
);

/// 待操作文件 Provider
final pendingOperationProvider = Provider<Map<String, dynamic>?>((ref) {
  final state = ref.watch(cloudDriveProvider);
  if (state.pendingOperationFile == null) return null;

  return {
    'file': state.pendingOperationFile,
    'operationType': state.pendingOperationType,
    'showFloatingActionButton': state.showFloatingActionButton,
  };
});

/// 账号选择器状态 Provider
final accountSelectorProvider = Provider<bool>(
  (ref) => ref.watch(cloudDriveProvider).showAccountSelector,
);

/// 缓存状态 Provider
final cacheStateProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(cloudDriveProvider);
  return {
    'isFromCache': state.isFromCache,
    'lastRefreshTime': state.lastRefreshTime,
  };
});

/// 分页状态 Provider
final paginationProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(cloudDriveProvider);
  return {'currentPage': state.currentPage, 'hasMoreData': state.hasMoreData};
});
