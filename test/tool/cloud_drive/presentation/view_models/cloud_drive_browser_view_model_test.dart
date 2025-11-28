import 'package:flutter_test/flutter_test.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/presentation/state/cloud_drive_state_model.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/presentation/view_models/cloud_drive_browser_view_model.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/data/models/cloud_drive_entities.dart';

void main() {
  group('CloudDriveBrowserViewModel', () {
    const viewModel = CloudDriveBrowserViewModel();

    test('returns noAccount when account list is empty', () {
      const state = CloudDriveState(accounts: [], isLoading: false);
      expect(
        viewModel.resolveBody(state),
        CloudDriveBrowserBodyType.noAccount,
      );
    });

    test('returns selectAccount when accounts exist but none selected', () {
      final account = CloudDriveAccount(
        id: '1',
        name: 'A',
        type: CloudDriveType.lanzou,
        createdAt: DateTime.now(),
      );
      final state = CloudDriveState(
        accounts: [account],
        currentAccount: null,
      );
      expect(
        viewModel.resolveBody(state),
        CloudDriveBrowserBodyType.selectAccount,
      );
    });

    test('returns content when current account is set', () {
      final account = CloudDriveAccount(
        id: '1',
        name: 'A',
        type: CloudDriveType.lanzou,
        createdAt: DateTime.now(),
      );
      final state = CloudDriveState(accounts: [account], currentAccount: account);
      expect(
        viewModel.resolveBody(state),
        CloudDriveBrowserBodyType.content,
      );
    });
  });
}
