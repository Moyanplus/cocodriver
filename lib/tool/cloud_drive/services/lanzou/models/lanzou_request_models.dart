import '../api/lanzou_request_builder.dart';

/// 请求蓝奏云接口时的标准请求对象集合。
class LanzouFolderRequest {
  const LanzouFolderRequest({
    required this.folderId,
    required this.taskKey,
  });

  final String folderId;
  final String taskKey;

  Map<String, dynamic> build(String vei) =>
      LanzouRequestBuilder().task(taskKey).folder(folderId).vei(vei).build();
}

class LanzouFileDetailRequest {
  const LanzouFileDetailRequest({required this.fileId});

  final String fileId;

  Map<String, dynamic> build() =>
      LanzouRequestBuilder().task('getFileDetail').file(fileId).build();
}

class LanzouValidateCookiesRequest {
  const LanzouValidateCookiesRequest();

  Map<String, dynamic> build(String vei) =>
      LanzouRequestBuilder().task('validateCookies').folder('-1').vei(vei).build();
}

class LanzouMoveFileRequest {
  const LanzouMoveFileRequest({
    required this.fileId,
    this.targetFolderId,
  });

  final String fileId;
  final String? targetFolderId;

  Map<String, dynamic> build() =>
      LanzouRequestBuilder()
          .task('moveFile')
          .folder(targetFolderId)
          .file(fileId)
          .build();
}
