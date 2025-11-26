import '../state/cloud_drive_state_model.dart';

enum CloudDriveBrowserBodyType {
  noAccount,
  selectAccount,
  content,
}

/// 负责决定 CloudDriveBrowserPage 展示什么内容的 ViewModel。
class CloudDriveBrowserViewModel {
  const CloudDriveBrowserViewModel();

  CloudDriveBrowserBodyType resolveBody(CloudDriveState state) {
    if (state.accounts.isEmpty && !state.isLoading) {
      return CloudDriveBrowserBodyType.noAccount;
    }
    if (state.currentAccount == null && state.accounts.isNotEmpty) {
      return CloudDriveBrowserBodyType.selectAccount;
    }
    return CloudDriveBrowserBodyType.content;
  }
}
