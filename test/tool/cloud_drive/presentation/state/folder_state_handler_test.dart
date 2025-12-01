import 'package:flutter_test/flutter_test.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/data/models/cloud_drive_entities.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/data/models/cloud_drive_dtos.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/presentation/state/cloud_drive_state_manager.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/presentation/state/cloud_drive_state_model.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/presentation/state/handlers/folder_state_handler.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/infrastructure/logging/cloud_drive_logger_adapter.dart';

class _TestLogger implements CloudDriveLoggerAdapter {
  @override
  void error(String message) {}

  @override
  void info(String message) {}

  @override
  void warning(String message) {}
}

class _StubFolderHandler extends FolderStateHandler {
  _StubFolderHandler(super.manager) : super(logger: _TestLogger());

  final List<bool> loadCalls = [];

  @override
  Future<void> loadFolder({bool forceRefresh = false}) async {
    loadCalls.add(forceRefresh);
  }
}

void main() {
  group('FolderStateHandler', () {
    final account = CloudDriveAccount(
      id: 'acc1',
      name: 'TestAccount',
      type: CloudDriveType.lanzou,
      createdAt: DateTime.now(),
    );
    final childFolder = CloudDriveFile(
      id: 'child',
      name: 'Child',
      isFolder: true,
    );

    test('enterFolder updates path and clears batch state', () async {
      late _StubFolderHandler handler;
      final manager = CloudDriveStateManager(
        logger: _TestLogger(),
        folderHandlerBuilder: (m) {
          handler = _StubFolderHandler(m);
          return handler;
        },
      );

      manager.setState(
        CloudDriveState(
          accountState: AccountViewState(
            accounts: [account],
            currentAccount: account,
          ),
          currentFolder: null,
          folderPath: [],
          selectedItems: {'x'},
          isInBatchMode: true,
        ),
      );

      await manager.folderHandler.enterFolder(childFolder);

      final newState = manager.getCurrentState();
      expect(newState.currentFolder?.id, equals('child'));
      expect(newState.folderPath.map((e) => e.id), contains('child'));
      expect(newState.selectedItems, isEmpty);
      expect(newState.isInBatchMode, isFalse);
      expect(handler.loadCalls, equals([false]));
    });

    test('goBack pops folder path when possible', () async {
      late _StubFolderHandler handler;
      final manager = CloudDriveStateManager(
        logger: _TestLogger(),
        folderHandlerBuilder: (m) {
          handler = _StubFolderHandler(m);
          return handler;
        },
      );

      final parentFolder = CloudDriveFile(
        id: 'parent',
        name: 'Parent',
        isFolder: true,
      );
      manager.setState(
        CloudDriveState(
          accountState: AccountViewState(
            accounts: [account],
            currentAccount: account,
          ),
          currentFolder: parentFolder,
          folderPath: [PathInfo(id: parentFolder.id, name: parentFolder.name)],
        ),
      );

      await manager.folderHandler.goBack();
      final newState = manager.getCurrentState();
      expect(newState.currentFolder, isNull);
      expect(newState.folderPath, isEmpty);
      expect(handler.loadCalls, equals([false]));
    });
  });
}
