import '../../../core/services/base/debug_service.dart';
import '../../models/cloud_drive_models.dart';
import 'pan123_base_service.dart';
import 'pan123_config.dart';

/// 123云盘文件操作服务
/// 专门处理文件重命名、移动、复制、删除等操作
class Pan123FileOperationService {
  /// 统一错误处理
  static void _handleError(
    String operation,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    DebugService.log(
      '❌ 123云盘 - $operation 失败: $error',
      category: DebugCategory.tools,
      subCategory: Pan123Config.logSubCategory,
    );
    if (stackTrace != null) {
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );
    }
  }

  /// 统一日志记录
  static void _logInfo(String message, {Map<String, dynamic>? params}) {
    DebugService.log(
      message,
      category: DebugCategory.tools,
      subCategory: Pan123Config.logSubCategory,
    );
  }

  /// 统一成功日志记录
  static void _logSuccess(String message, {Map<String, dynamic>? details}) {
    DebugService.log(
      '✅ 123云盘 - $message',
      category: DebugCategory.tools,
      subCategory: Pan123Config.logSubCategory,
    );
  }

  /// 统一错误日志记录
  static void _logError(String message, dynamic error) {
    DebugService.log(
      '❌ 123云盘 - $message: $error',
      category: DebugCategory.tools,
      subCategory: Pan123Config.logSubCategory,
    );
  }

  /// 重命名文件
  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required String fileId,
    required String newFileName,
  }) async {
    try {
      _logInfo(
        '✏️ 123云盘 - 开始重命名文件',
        params: {'fileId': fileId, 'newFileName': newFileName},
      );

      // 验证账号登录状态
      if (!account.isLoggedIn) {
        _logError('账号未登录，请先登录', '账号状态检查失败');
        return false;
      }

      // 使用配置中的API端点
      final url = Uri.parse(
        Pan123Config.getApiUrl(Pan123Config.endpoints['rename']!),
      );

      // 构建请求参数
      final params = <String, dynamic>{
        'driveId': 0,
        'fileId': int.tryParse(fileId) ?? 0,
        'fileName': newFileName,
        'duplicate': 1, // 允许重名
        'event': 'fileRename',
        'operatePlace': 'bottom',
        'RequestSource': null,
      };

      _logInfo(
        '🌐 123云盘 - 请求URL: ${url.toString()}',
        params: {'url': url.toString()},
      );

      // 发送请求
      final dio = Pan123BaseService.createDio(account);
      final response = await dio.post(url.toString(), data: params);

      _logInfo(
        '📡 123云盘 - 响应状态: ${response.statusCode}',
        params: {'statusCode': response.statusCode},
      );

      final responseData = response.data as Map<String, dynamic>;

      // 处理API响应
      final processedResponse = Pan123BaseService.handleApiResponse(
        responseData,
      );

      if (processedResponse['code'] == 0) {
        _logSuccess(
          '文件重命名成功: $newFileName',
          details: {'newFileName': newFileName},
        );
        return true;
      } else {
        _logError('文件重命名失败', processedResponse['message'] ?? '未知错误');
        return false;
      }
    } catch (e) {
      _handleError('重命名文件', e, null);
      return false;
    }
  }

  /// 移动文件
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required String fileId,
    required String targetParentFileId,
  }) async {
    try {
      DebugService.log(
        '🚚 123云盘 - 开始移动文件',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );
      DebugService.log(
        '📋 123云盘 - 请求参数: fileId=$fileId, targetParentFileId=$targetParentFileId',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );

      // 验证账号登录状态
      if (!account.isLoggedIn) {
        DebugService.log(
          '❌ 123云盘 - 账号未登录，请先登录',
          category: DebugCategory.tools,
          subCategory: Pan123Config.logSubCategory,
        );
        return false;
      }

      // 使用配置中的API端点
      final url = Uri.parse(
        Pan123Config.getApiUrl(Pan123Config.endpoints['move']!),
      );

      // 解析目标文件夹ID
      int targetParentId;
      if (targetParentFileId == '/' || targetParentFileId.isEmpty) {
        targetParentId = 0; // 根目录
      } else {
        String cleanTargetId = targetParentFileId;
        if (cleanTargetId.startsWith('/')) {
          cleanTargetId = cleanTargetId.substring(1);
        }
        targetParentId = int.tryParse(cleanTargetId) ?? 0;
      }

      // 构建请求参数
      final params = <String, dynamic>{
        'fileIdList': [
          {'FileId': int.tryParse(fileId) ?? 0},
        ],
        'parentFileId': targetParentId,
        'event': 'fileMove',
        'operatePlace': 'bottom',
        'RequestSource': null,
      };

      DebugService.log(
        '🌐 123云盘 - 请求URL: $url',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );

      // 发送请求
      final dio = Pan123BaseService.createDio(account);
      final response = await dio.post(url.toString(), data: params);

      DebugService.log(
        '📡 123云盘 - 响应状态: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );

      final responseData = response.data as Map<String, dynamic>;

      // 处理API响应
      final processedResponse = Pan123BaseService.handleApiResponse(
        responseData,
      );

      if (processedResponse['code'] == 0) {
        DebugService.log(
          '✅ 123云盘 - 文件移动成功: $fileId -> $targetParentFileId',
          category: DebugCategory.tools,
          subCategory: Pan123Config.logSubCategory,
        );
        return true;
      } else {
        DebugService.log(
          '❌ 123云盘 - 文件移动失败',
          category: DebugCategory.tools,
          subCategory: Pan123Config.logSubCategory,
        );
        return false;
      }
    } catch (e) {
      DebugService.log(
        '❌ 123云盘 - 移动文件失败: $e',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );
      return false;
    }
  }

  /// 复制文件
  static Future<bool> copyFile({
    required CloudDriveAccount account,
    required String fileId,
    required String targetFileId,
    String? fileName,
    int? size,
    String? etag,
    int? type,
    String? parentFileId,
  }) async {
    try {
      DebugService.log(
        '📋 123云盘 - 开始复制文件',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );
      DebugService.log(
        '📋 123云盘 - 请求参数: fileId=$fileId, targetFileId=$targetFileId',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );

      // 验证账号登录状态
      if (!account.isLoggedIn) {
        DebugService.log(
          '❌ 123云盘 - 账号未登录，请先登录',
          category: DebugCategory.tools,
          subCategory: Pan123Config.logSubCategory,
        );
        return false;
      }

      // 使用配置中的API端点
      final url = Uri.parse(
        Pan123Config.getApiUrl(Pan123Config.endpoints['copy']!),
      );

      // 构建请求参数
      final params = <String, dynamic>{
        'fileList': [
          {
            'fileId': int.tryParse(fileId) ?? 0,
            'size': size ?? 0,
            'etag': etag ?? '',
            'type': type ?? 0,
            'parentFileId': int.tryParse(parentFileId ?? '0') ?? 0,
            'fileName': fileName ?? '',
            'driveId': 0,
          },
        ],
        'targetFileId': int.tryParse(targetFileId) ?? 0,
      };

      DebugService.log(
        '🌐 123云盘 - 请求URL: $url',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );

      // 发送请求
      final dio = Pan123BaseService.createDio(account);
      final response = await dio.post(url.toString(), data: params);

      DebugService.log(
        '📡 123云盘 - 响应状态: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );

      final responseData = response.data as Map<String, dynamic>;

      // 处理API响应
      final processedResponse = Pan123BaseService.handleApiResponse(
        responseData,
      );

      if (processedResponse['code'] == 0) {
        DebugService.log(
          '✅ 123云盘 - 文件复制成功: $fileId -> $targetFileId',
          category: DebugCategory.tools,
          subCategory: Pan123Config.logSubCategory,
        );
        return true;
      } else {
        DebugService.log(
          '❌ 123云盘 - 文件复制失败',
          category: DebugCategory.tools,
          subCategory: Pan123Config.logSubCategory,
        );
        return false;
      }
    } catch (e) {
      DebugService.log(
        '❌ 123云盘 - 复制文件失败: $e',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );
      return false;
    }
  }

  /// 删除文件
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required String fileId,
    String? fileName,
    int? type,
    int? size,
    String? s3keyFlag,
    String? etag,
    String? parentFileId,
  }) async {
    try {
      DebugService.log(
        '🗑️ 123云盘 - 开始删除文件',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );
      DebugService.log(
        '📋 123云盘 - 请求参数: fileId=$fileId, fileName=$fileName',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );

      // 验证账号登录状态
      if (!account.isLoggedIn) {
        DebugService.log(
          '❌ 123云盘 - 账号未登录，请先登录',
          category: DebugCategory.tools,
          subCategory: Pan123Config.logSubCategory,
        );
        return false;
      }

      // 使用配置中的API端点
      final url = Uri.parse(
        Pan123Config.getApiUrl(Pan123Config.endpoints['recycle']!),
      );

      // 构建请求参数
      final params = <String, dynamic>{
        'driveId': 0,
        'fileTrashInfoList': [
          {
            'FileId': int.tryParse(fileId) ?? 0,
            'FileName': fileName ?? '',
            'Type': type ?? 0,
            'Size': size ?? 0,
            'ContentType': '0',
            'S3KeyFlag': s3keyFlag ?? '',
            'CreateAt': DateTime.now().toIso8601String(),
            'UpdateAt': DateTime.now().toIso8601String(),
            'Hidden': false,
            'Etag': etag ?? '',
            'Status': 0,
            'ParentFileId': int.tryParse(parentFileId ?? '0') ?? 0,
            'Category': 6,
            'PunishFlag': 0,
            'ParentName': '',
            'DownloadUrl': '',
            'AbnormalAlert': 1,
            'Trashed': false,
            'TrashedExpire': '1970-01-01 08:00:00',
            'TrashedAt': DateTime.now().toString(),
            'StorageNode': 'm94',
            'DirectLink': 2,
            'AbsPath': '/$fileId',
            'PinYin': '',
            'BusinessType': 0,
            'Thumbnail': '',
            'Operable': false,
            'StarredStatus': 1,
            'HighLight': '',
            'EnableAppeal': 0,
            'ToolTip': '',
            'RefuseReason': 0,
            'DirectTranscodeStatus': 4,
            'PreviewType': 1,
            'IsLock': false,
            'keys': 3,
            'checked': false,
          },
        ],
        'operation': true,
        'event': 'intoRecycle',
        'operatePlace': 'bottom',
        'RequestSource': null,
        'safeBox': false,
      };

      DebugService.log(
        '🌐 123云盘 - 请求URL: $url',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );

      // 发送请求
      final dio = Pan123BaseService.createDio(account);
      final response = await dio.post(url.toString(), data: params);

      DebugService.log(
        '📡 123云盘 - 响应状态: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );

      final responseData = response.data as Map<String, dynamic>;

      // 处理API响应
      final processedResponse = Pan123BaseService.handleApiResponse(
        responseData,
      );

      if (processedResponse['code'] == 0) {
        DebugService.log(
          '✅ 123云盘 - 文件删除成功: $fileId',
          category: DebugCategory.tools,
          subCategory: Pan123Config.logSubCategory,
        );
        return true;
      } else {
        DebugService.log(
          '❌ 123云盘 - 文件删除失败',
          category: DebugCategory.tools,
          subCategory: Pan123Config.logSubCategory,
        );
        return false;
      }
    } catch (e) {
      DebugService.log(
        '❌ 123云盘 - 删除文件失败: $e',
        category: DebugCategory.tools,
        subCategory: Pan123Config.logSubCategory,
      );
      return false;
    }
  }
}
