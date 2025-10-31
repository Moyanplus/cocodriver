import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
// import '../../data/models/cloud_drive_dtos.dart'; // 未使用
import 'ali_base_service.dart';
import 'ali_cloud_drive_service.dart';
import 'ali_config.dart';

/// 阿里云盘文件操作服务
///
/// 专门处理文件操作，包括重命名、删除、移动等。
class AliFileOperationService {
  /// 重命名文件
  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    try {
      LogManager().cloudDrive('阿里云盘 - 重命名文件: ${file.name} -> $newName');

      // 首先获取drive_id
      final driveId = await AliCloudDriveService.getDriveId(account: account);
      if (driveId == null) {
        LogManager().cloudDrive('阿里云盘 - 无法获取drive_id，重命名失败');
        return false;
      }

      final dio = AliBaseService.createApiDio(account);
      final requestBody = AliConfig.buildRenameFileParams(
        driveId: driveId,
        fileId: file.id,
        newName: newName,
      );

      LogManager().cloudDrive('阿里云盘 - 重命名请求体: $requestBody');

      final response = await dio.post(
        AliConfig.getApiEndpoint('renameFile'),
        data: requestBody,
      );

      if (!AliBaseService.isHttpSuccess(response.statusCode)) {
        LogManager().cloudDrive('阿里云盘 - 重命名文件HTTP错误: ${response.statusCode}');
        return false;
      }

      final responseData = AliBaseService.getResponseData(response.data);
      if (responseData == null) {
        LogManager().cloudDrive('阿里云盘 - 重命名响应数据为空');
        return false;
      }

      // 检查响应中是否包含更新后的文件信息
      final updatedName = responseData['name'] as String?;
      final updatedAt = responseData['updated_at'] as String?;

      if (updatedName == newName) {
        LogManager().cloudDrive(
          '阿里云盘 - 文件重命名成功: ${file.name} -> $updatedName (更新时间: $updatedAt)',
        );
        return true;
      } else {
        LogManager().cloudDrive(
          '阿里云盘 - 重命名结果与预期不符: 预期=$newName, 实际=$updatedName',
        );
        return false;
      }
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 重命名文件异常: $e');
      return false;
    }
  }

  /// 移动文件
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String targetFolderId,
  }) async {
    try {
      LogManager().cloudDrive('阿里云盘 - 移动文件: ${file.name} -> $targetFolderId');

      // 首先获取drive_id
      final driveId = await AliCloudDriveService.getDriveId(account: account);
      if (driveId == null) {
        LogManager().cloudDrive('阿里云盘 - 无法获取drive_id，移动文件失败');
        return false;
      }

      final dio = AliBaseService.createApiDio(account);
      final requestBody = AliConfig.buildMoveFileParams(
        driveId: driveId,
        fileId: file.id,
        fileName: file.name,
        fileType: file.isFolder ? 'folder' : 'file',
        toParentFileId: targetFolderId,
      );

      LogManager().cloudDrive('阿里云盘 - 移动文件请求体: $requestBody');

      final response = await dio.post(
        AliConfig.getApiEndpoint('moveFile'),
        data: requestBody,
      );

      if (!AliBaseService.isHttpSuccess(response.statusCode)) {
        LogManager().cloudDrive('阿里云盘 - 移动文件HTTP错误: ${response.statusCode}');
        return false;
      }

      final responseData = AliBaseService.getResponseData(response.data);
      if (responseData == null) {
        LogManager().cloudDrive('阿里云盘 - 移动文件响应数据为空');
        return false;
      }

      // 解析批量API响应
      final responses = responseData['responses'] as List<dynamic>? ?? [];
      if (responses.isNotEmpty) {
        final firstResponse = responses[0] as Map<String, dynamic>? ?? {};
        final status = firstResponse['status'] as int?;
        final responseBody =
            firstResponse['body'] as Map<String, dynamic>? ?? {};

        if (status == 200) {
          final movedFileId = responseBody['file_id'] as String?;
          LogManager().cloudDrive(
            '阿里云盘 - 文件移动成功: ${file.name} (ID: $movedFileId) -> $targetFolderId',
          );
          return true;
        } else {
          LogManager().cloudDrive('阿里云盘 - 文件移动失败，响应状态: $status');
          return false;
        }
      } else {
        LogManager().cloudDrive('阿里云盘 - 移动文件响应为空');
        return false;
      }
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 移动文件异常: $e');
      return false;
    }
  }

  /// 创建文件夹
  static Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    try {
      LogManager().cloudDrive(
        '阿里云盘 - 创建文件夹: name=$folderName, parentFolderId=$parentFolderId',
      );

      // 首先获取drive_id
      final driveId = await AliCloudDriveService.getDriveId(account: account);
      if (driveId == null) {
        LogManager().cloudDrive('阿里云盘 - 无法获取drive_id，创建文件夹失败');
        return null;
      }

      final dio = AliBaseService.createApiDio(account);
      final requestBody = AliConfig.buildCreateFolderParams(
        name: folderName,
        parentFileId: parentFolderId,
        driveId: driveId,
      );

      LogManager().cloudDrive('阿里云盘 - 创建文件夹请求体: $requestBody');

      final response = await dio.post(
        AliConfig.getApiEndpoint('createFolder'),
        data: requestBody,
      );

      if (!AliBaseService.isHttpSuccess(response.statusCode)) {
        LogManager().cloudDrive('阿里云盘 - 创建文件夹HTTP错误: ${response.statusCode}');
        return null;
      }

      final responseData = AliBaseService.getResponseData(response.data);
      if (responseData == null) {
        LogManager().cloudDrive('阿里云盘 - 创建文件夹响应数据为空');
        return null;
      }

      // 解析响应数据创建CloudDriveFile对象
      final fileId = responseData['file_id'] as String?;
      final fileName = responseData['file_name'] as String?;
      final parentId = responseData['parent_file_id'] as String?;
      final type = responseData['type'] as String?;

      if (fileId == null || fileName == null) {
        LogManager().cloudDrive(
          '阿里云盘 - 创建文件夹响应缺少必要字段: file_id=$fileId, file_name=$fileName',
        );
        return null;
      }

      final createdFolder = CloudDriveFile(
        id: fileId,
        name: fileName,
        size: 0, // 文件夹没有大小
        modifiedTime: DateTime.now(),
        isFolder: type == 'folder',
        folderId: parentId,
      );

      LogManager().cloudDrive('阿里云盘 - 文件夹创建成功: $fileName (ID: $fileId)');

      return createdFolder;
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 创建文件夹异常: $e');
      return null;
    }
  }

  /// 获取文件下载链接
  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      LogManager().cloudDrive('阿里云盘 - 获取下载链接: ${file.name}');

      // 首先获取drive_id
      final driveId = await AliCloudDriveService.getDriveId(account: account);
      if (driveId == null) {
        LogManager().cloudDrive('阿里云盘 - 无法获取drive_id，获取下载链接失败');
        return null;
      }

      final dio = AliBaseService.createApiDio(account); // 使用api域名
      final requestBody = AliConfig.buildDownloadFileParams(
        driveId: driveId,
        fileId: file.id,
      );

      LogManager().cloudDrive('阿里云盘 - 获取下载链接请求体: $requestBody');

      final response = await dio.post(
        AliConfig.getApiEndpoint('downloadFile'),
        data: requestBody,
      );

      if (!AliBaseService.isHttpSuccess(response.statusCode)) {
        LogManager().cloudDrive('阿里云盘 - 获取下载链接HTTP错误: ${response.statusCode}');
        return null;
      }

      final responseData = AliBaseService.getResponseData(response.data);
      if (responseData == null) {
        LogManager().cloudDrive('阿里云盘 - 获取下载链接响应数据为空');
        return null;
      }

      // 获取下载URL
      final downloadUrl = responseData['url'] as String?;
      final expiration = responseData['expiration'] as String?;
      final size = responseData['size'] as int?;

      if (downloadUrl != null && downloadUrl.isNotEmpty) {
        LogManager().cloudDrive(
          '阿里云盘 - 下载链接获取成功: ${file.name} (大小: ${size != null ? AliConfig.formatFileSize(size) : '未知'}, 过期时间: $expiration)',
        );
        return downloadUrl;
      } else {
        LogManager().cloudDrive('阿里云盘 - 响应中未找到有效的下载链接');
        return null;
      }
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 获取下载链接异常: $e');
      return null;
    }
  }

  /// 删除文件
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      LogManager().cloudDrive('阿里云盘 - 删除文件: ${file.name}');

      // 首先获取drive_id
      final driveId = await AliCloudDriveService.getDriveId(account: account);
      if (driveId == null) {
        LogManager().cloudDrive('阿里云盘 - 无法获取drive_id，删除文件失败');
        return false;
      }

      final dio = AliBaseService.createApiDio(account);
      final requestBody = AliConfig.buildDeleteFileParams(
        driveId: driveId,
        fileId: file.id,
      );

      LogManager().cloudDrive('阿里云盘 - 删除文件请求体: $requestBody');

      final response = await dio.post(
        AliConfig.getApiEndpoint('deleteFile'),
        data: requestBody,
      );

      if (!AliBaseService.isHttpSuccess(response.statusCode)) {
        LogManager().cloudDrive('阿里云盘 - 删除文件HTTP错误: ${response.statusCode}');
        return false;
      }

      final responseData = AliBaseService.getResponseData(response.data);
      if (responseData == null) {
        LogManager().cloudDrive('阿里云盘 - 删除文件响应数据为空');
        return false;
      }

      // 检查批量操作响应
      final responses = responseData['responses'] as List<dynamic>?;
      if (responses == null || responses.isEmpty) {
        LogManager().cloudDrive('阿里云盘 - 删除文件响应中没有responses字段');
        return false;
      }

      // 检查第一个响应（因为我们只删除一个文件）
      final firstResponse = responses.first as Map<String, dynamic>;
      final status = firstResponse['status'] as int?;
      final id = firstResponse['id'] as String?;

      LogManager().cloudDrive('阿里云盘 - 删除文件响应: status=$status, id=$id');

      if (status == 204) {
        LogManager().cloudDrive('阿里云盘 - 删除文件成功: ${file.name}');
        return true;
      } else {
        LogManager().cloudDrive('阿里云盘 - 删除文件失败: status=$status');
        return false;
      }
    } catch (e) {
      LogManager().cloudDrive('阿里云盘 - 删除文件异常: $e');
      return false;
    }
  }
}
