import '../../../../data/models/cloud_drive_entities.dart';
import '../models/quark_models.dart';
import 'quark_operations.dart';

/// 夸克云盘 API Client
///
/// 统一封装文件列表、文件操作、分享、下载等调用。
class QuarkApiClient {
  Future<QuarkApiResult<QuarkFileListResponse>> listFiles({
    required CloudDriveAccount account,
    required QuarkFileListRequest request,
  }) {
    return QuarkOperations.listFiles(account: account, request: request);
  }

  Future<QuarkApiResult<QuarkFileOperationResponse>> operate({
    required CloudDriveAccount account,
    required QuarkFileOperationRequest request,
  }) {
    return QuarkOperations.operate(account: account, request: request);
  }

  Future<QuarkApiResult<QuarkCreateFolderResponse>> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) {
    return QuarkOperations.createFolder(
      account: account,
      folderName: folderName,
      parentFolderId: parentFolderId,
    );
  }

  Future<QuarkApiResult<QuarkShareResponse>> createShare({
    required CloudDriveAccount account,
    required QuarkShareRequest request,
  }) {
    return QuarkOperations.createShare(account: account, request: request);
  }

  Future<QuarkApiResult<String>> getDownloadUrl({
    required CloudDriveAccount account,
    required String fileId,
    required String fileName,
    int? size,
  }) {
    return QuarkOperations.getDownloadUrl(
      account: account,
      fileId: fileId,
      fileName: fileName,
      size: size,
    );
  }
}
