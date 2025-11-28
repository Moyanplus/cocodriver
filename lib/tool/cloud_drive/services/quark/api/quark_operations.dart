import '../../../data/models/cloud_drive_entities.dart';
import '../models/quark_api_result.dart';
import '../models/quark_models.dart';
import '../models/requests/quark_file_list_request.dart';
import '../models/requests/quark_file_operation_request.dart';
import '../models/requests/quark_share_request.dart';
import 'quark_download_service.dart';
import 'quark_file_list_service.dart';
import 'quark_file_operation_service.dart';
import 'quark_share_service.dart';

/// 夸克云盘统一操作封装。
class QuarkOperations {
  static Future<QuarkApiResult<QuarkFileListResponse>> listFiles({
    required CloudDriveAccount account,
    required QuarkFileListRequest request,
  }) {
    return QuarkFileListService.getFileListWithDTO(
      account: account,
      request: request,
    );
  }

  static Future<QuarkApiResult<QuarkOperationResponse>> operate({
    required CloudDriveAccount account,
    required QuarkFileOperationRequest request,
  }) {
    return QuarkFileOperationService.executeOperation(
      account: account,
      request: request,
    );
  }

  static Future<QuarkApiResult<QuarkFileOperationResult>> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) {
    return QuarkFileOperationService.createFolder(
      account: account,
      folderName: folderName,
      parentFolderId: parentFolderId,
    );
  }

  static Future<QuarkApiResult<QuarkShareResponse>> createShare({
    required CloudDriveAccount account,
    required QuarkShareRequest request,
  }) {
    return QuarkShareService.createShareLink(
      account: account,
      request: request,
    );
  }

  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required String fileId,
    required String fileName,
    int? size,
  }) {
    return QuarkDownloadService.getDownloadUrl(
      account: account,
      fileId: fileId,
      fileName: fileName,
      size: size,
    );
  }
}
