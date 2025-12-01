import 'package:flutter_test/flutter_test.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/data/models/cloud_drive_entities.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/presentation/state/cloud_drive_state_manager.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/presentation/state/cloud_drive_state_model.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/presentation/state/handlers/folder_state_handler.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/infrastructure/logging/cloud_drive_logger_adapter.dart';

class _TestLogger implements CloudDriveLoggerAdapter {
  final List<String> infoLogs = [];
  final List<String> warningLogs = [];
  final List<String> errorLogs = [];

  @override
  void error(String message) => errorLogs.add(message);

  @override
  void info(String message) => infoLogs.add(message);

  @override
  void warning(String message) => warningLogs.add(message);
}

class _FakeFolderHandler extends FolderStateHandler {
  _FakeFolderHandler(super.manager);

  bool moveShouldSucceed = true;
  bool copyShouldSucceed = true;
  final List<bool> loadCalls = [];
  final List<Map<String, String>> cacheInvalidations = [];

  @override
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async => moveShouldSucceed;

  @override
  Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async => copyShouldSucceed;

  @override
  Future<void> loadFolder({bool forceRefresh = false}) async {
    loadCalls.add(forceRefresh);
  }

  @override
  void invalidateCache(String accountId, String folderId) {
    cacheInvalidations.add({'accountId': accountId, 'folderId': folderId});
  }
}

void main() {
  group('PendingOperationHandler', () {
    final account = CloudDriveAccount(
      id: 'acc1',
      name: 'TestAccount',
      type: CloudDriveType.lanzou,
      createdAt: DateTime.now(),
    );

    final rootFolder = CloudDriveFile(id: '/', name: 'root', isFolder: true);
    final file = CloudDriveFile(
      id: 'file1',
      name: 'file.zip',
      isFolder: false,
      folderId: '/source',
    );

    test('move performs optimistic update and invalidates caches', () async {
      final testLogger = _TestLogger();
      late _FakeFolderHandler fakeHandler;
      final manager = CloudDriveStateManager(
        logger: testLogger,
        folderHandlerBuilder: (m) {
          fakeHandler = _FakeFolderHandler(m);
          return fakeHandler;
        },
      );

      manager.setState(
        CloudDriveState(
          accountState: AccountViewState(
            accounts: [account],
            currentAccount: account,
          ),
          currentFolder: rootFolder,
          files: [file],
        ),
      );

      manager.pendingHandler.setPendingOperation(file, 'move');
      final success = await manager.executePendingOperation();
      await Future.delayed(Duration.zero);

      expect(success, isTrue);
      final files = manager.getCurrentState().files;
      expect(files.length, 1);
      expect(files.first.folderId, '/');
      expect(fakeHandler.cacheInvalidations.length, 2);
      expect(fakeHandler.loadCalls.contains(true), isTrue);
    });

    test('copy appends new file locally and invalidates caches', () async {
      final testLogger = _TestLogger();
      late _FakeFolderHandler fakeHandler;
      final manager = CloudDriveStateManager(
        logger: testLogger,
        folderHandlerBuilder: (m) {
          fakeHandler = _FakeFolderHandler(m);
          return fakeHandler;
        },
      );

      manager.setState(
        CloudDriveState(
          accountState: AccountViewState(
            accounts: [account],
            currentAccount: account,
          ),
          currentFolder: rootFolder,
          files: [file],
        ),
      );

      manager.pendingHandler.setPendingOperation(file, 'copy');
      final success = await manager.executePendingOperation();
      await Future.delayed(Duration.zero);

      expect(success, isTrue);
      final files = manager.getCurrentState().files;
      expect(files.length, 2);
      expect(files.last.folderId, '/');
      expect(fakeHandler.cacheInvalidations.length, 2);
    });
  });
}
