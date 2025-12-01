import 'package:flutter_test/flutter_test.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/data/models/cloud_drive_entities.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/presentation/state/cloud_drive_state_manager.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/presentation/state/cloud_drive_state_model.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/presentation/state/handlers/account_state_handler.dart';
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
  group('AccountStateHandler', () {
    final account1 = CloudDriveAccount(
      id: 'acc1',
      name: 'Account1',
      type: CloudDriveType.lanzou,
      createdAt: DateTime.now(),
    );
    final account2 = CloudDriveAccount(
      id: 'acc2',
      name: 'Account2',
      type: CloudDriveType.baidu,
      createdAt: DateTime.now(),
    );

    test(
      'switchAccount updates current account and triggers refresh',
      () async {
        late _StubFolderHandler folderHandler;
        final manager = CloudDriveStateManager(
          logger: _TestLogger(),
          folderHandlerBuilder: (m) {
            folderHandler = _StubFolderHandler(m);
            return folderHandler;
          },
          accountHandlerBuilder:
              (m) => AccountStateHandler(m, logger: _TestLogger()),
        );

      manager.setState(
        CloudDriveState(
          accountState: AccountViewState(
            accounts: [account1, account2],
            currentAccount: account1,
          ),
          files: [CloudDriveFile(id: 'f', name: 'F', isFolder: false)],
        ),
      );

        await manager.accountHandler.switchAccount(1);

        final newState = manager.getCurrentState();
        expect(newState.currentAccount?.id, equals('acc2'));
        expect(newState.files, isEmpty);
        // 切换账号不再主动刷新文件夹，交由页面按需触发
        expect(folderHandler.loadCalls, isEmpty);
      },
    );

    test('switchAccount throws when index invalid', () async {
      final manager = CloudDriveStateManager(
        logger: _TestLogger(),
        folderHandlerBuilder: (m) => _StubFolderHandler(m),
        accountHandlerBuilder:
            (m) => AccountStateHandler(m, logger: _TestLogger()),
      );

      manager.setState(
        CloudDriveState(
          accountState: AccountViewState(
            accounts: [account1],
            currentAccount: account1,
          ),
        ),
      );

      await manager.accountHandler.switchAccount(5);
      expect(manager.getCurrentState().error, isNotNull);
    });
  });
}
