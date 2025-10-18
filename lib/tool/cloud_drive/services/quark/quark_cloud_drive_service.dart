import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/services/base/debug_service.dart';
import '../../models/cloud_drive_models.dart';
import 'quark_base_service.dart';
import 'quark_config.dart';

/// 夸克云盘服务
class QuarkCloudDriveService {


  // 创建dio实例 - 使用统一的基础服务
  static Dio _createDio(CloudDriveAccount account) =>
      QuarkBaseService.createDio(account);

  /// 获取文件列表
  static Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? parentFileId,
    int page = 1,
    int pageSize = 50,
  }) async {
    DebugService.log(
      '📁 获取文件列表开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      final dio = _createDio(account);
      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('getFileList')}',
      );

      // 构建查询参数
      final queryParams = {
        'parent_id': parentFileId ?? QuarkConfig.rootFolderId,
        'start': ((page - 1) * pageSize).toString(),
        'limit': pageSize.toString(),
        'order': 'name',
        'desc': 'false',
        'force': '0',
        'web': '1',
      };

      DebugService.log(
        '🌐 请求URL: ${url.toString()}',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      final uri = url.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );

      DebugService.log(
        '🔗 完整请求URL: ${uri.toString()}',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      final response = await dio.getUri(uri);

      DebugService.log(
        '📡 响应状态: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      final responseData = response.data as Map<String, dynamic>;

      DebugService.log(
        '📄 响应数据: ${responseData.toString().substring(0, responseData.toString().length > 200 ? 200 : responseData.toString().length)}...',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      // 检查响应状态
      if (responseData['code'] != 0) {
        DebugService.log(
          'API返回错误',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return [];
      }

      final data = responseData['data'] as Map<String, dynamic>?;
      if (data == null) {
        DebugService.log(
          '⚠️ 响应中没有data字段',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return [];
      }

      final fileList = data['file_list'] as List<dynamic>? ?? [];
      final folderList = data['folder_list'] as List<dynamic>? ?? [];

      DebugService.log(
        '📄 解析到的文件列表数量: ${fileList.length}',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📁 解析到的文件夹列表数量: ${folderList.length}',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      final List<CloudDriveFile> files = [];

      // 处理文件列表
      for (final fileData in fileList) {
        try {
          final file = _parseFileData(
            fileData,
            parentFileId ?? QuarkConfig.rootFolderId,
          );
          if (file != null) {
            files.add(file);
            DebugService.log(
              '✅ 文件解析成功: ${file.name} (ID: ${file.id})',
              category: DebugCategory.tools,
              subCategory: QuarkConfig.logSubCategory,
            );
          }
        } catch (e) {
          DebugService.log(
            '解析文件失败',
            category: DebugCategory.tools,
            subCategory: QuarkConfig.logSubCategory,
          );
        }
      }

      // 处理文件夹列表
      for (final folderData in folderList) {
        try {
          final folder = _parseFileData(
            folderData,
            parentFileId ?? QuarkConfig.rootFolderId,
          );
          if (folder != null) {
            files.add(folder);
            DebugService.log(
              '✅ 文件夹解析成功: ${folder.name} (ID: ${folder.id})',
              category: DebugCategory.tools,
              subCategory: QuarkConfig.logSubCategory,
            );
          }
        } catch (e) {
          DebugService.log(
            '解析文件夹失败',
            category: DebugCategory.tools,
            subCategory: QuarkConfig.logSubCategory,
          );
        }
      }

      DebugService.log(
        '成功获取 ${files.length} 个文件/文件夹',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      return files;
    } catch (e) {
      DebugService.log(
        '获取文件列表失败',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return [];
    }
  }

  /// 解析文件数据
  static CloudDriveFile? _parseFileData(
    Map<String, dynamic> fileData,
    String parentId,
  ) {
    try {
      DebugService.log(
        '🔍 开始解析文件数据: $fileData',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      // 夸克云盘的文件数据结构
      final fid = fileData['fid']?.toString() ?? '';
      final name =
          fileData['file_name']?.toString() ??
          fileData['name']?.toString() ??
          '';
      final size = fileData['size']?.toString() ?? '0';

      // 处理file_type和category，它们可能是数字或字符串类型
      final fileTypeRaw = fileData['file_type'];
      final categoryRaw = fileData['category'];

      final fileType = fileTypeRaw?.toString() ?? '0';
      final category = categoryRaw?.toString() ?? '0';

      // 判断是否为文件夹：file_type为0且category为0表示文件夹
      // 注意：file_type和category可能是数字类型
      final isFolder =
          (fileTypeRaw == QuarkConfig.fileTypes['folder'] || fileType == '0') &&
          (categoryRaw == QuarkConfig.fileTypes['folder'] || category == '0');

      DebugService.log(
        '📋 解析结果: ID=$fid, 名称=$name, 大小=$size, 文件类型=$fileType, 分类=$category, 是否文件夹=$isFolder',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      // 解析时间戳
      DateTime? updatedAt;
      final updateTime =
          fileData['l_updated_at'] ??
          fileData['updated_at'] ??
          fileData['utime'];
      if (updateTime != null) {
        if (updateTime is int) {
          // 夸克云盘的时间戳是毫秒级的
          updatedAt = DateTime.fromMillisecondsSinceEpoch(updateTime);
          DebugService.log(
            '🕒 解析时间戳(毫秒): $updateTime -> $updatedAt',
            category: DebugCategory.tools,
            subCategory: QuarkConfig.logSubCategory,
          );
        } else if (updateTime is String) {
          updatedAt = DateTime.tryParse(updateTime);
          DebugService.log(
            '🕒 解析时间戳(字符串): $updateTime -> $updatedAt',
            category: DebugCategory.tools,
            subCategory: QuarkConfig.logSubCategory,
          );
        }
      } else {
        DebugService.log(
          '⚠️ 没有找到时间戳信息',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
      }

      // 格式化文件大小
      String formattedSize = '0 B';
      if (!isFolder && size.isNotEmpty && size != '0') {
        final sizeInt = int.tryParse(size) ?? 0;
        if (sizeInt > 0) {
          formattedSize = QuarkConfig.formatFileSize(sizeInt);
          DebugService.log(
            '📊 格式化文件大小: $size -> $formattedSize',
            category: DebugCategory.tools,
            subCategory: QuarkConfig.logSubCategory,
          );
        }
      }

      // 格式化时间 - 使用友好的格式而不是ISO格式
      String? formattedTime;
      if (updatedAt != null) {
        formattedTime = QuarkConfig.formatDateTime(updatedAt);
        DebugService.log(
          '⏰ 格式化时间: $updatedAt -> $formattedTime',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
      }

      final file = CloudDriveFile(
        id: fid,
        name: name,
        size: int.tryParse(formattedSize) ?? 0,
        modifiedTime:
            formattedTime != null ? DateTime.tryParse(formattedTime) : null,
        isFolder: isFolder,
        folderId: parentId,
      );

      DebugService.log(
        '✅ 文件解析完成: ${file.name} (ID: ${file.id}, 文件夹: ${file.isFolder})',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      return file;
    } catch (e, stackTrace) {
      DebugService.log(
        '解析文件数据失败',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return null;
    }
  }

  /// 创建分享链接
  static Future<Map<String, dynamic>?> createShareLink({
    required CloudDriveAccount account,
    required List<String> fileIds,
    String? title,
    String? passcode,
    int expiredType = 1, // 1:永久, 2:1天, 3:7天, 4:30天
  }) async {
    DebugService.log(
      '🔗 夸克云盘 - 创建分享链接开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📄 文件ID列表: $fileIds',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📝 分享标题: ${title ?? '未设置'}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '🔐 提取码: ${passcode ?? '无'}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '⏰ 过期类型: $expiredType',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      final dio = _createDio(account);
      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('createShare')}',
      );

      // 构建请求体
      final requestBody = {
        'fid_list': fileIds,
        'title': title ?? '分享文件',
        'url_type': 2, // 分享链接类型
        'expired_type': expiredType,
      };

      // 如果设置了提取码，添加到请求体
      if (passcode != null && passcode.isNotEmpty) {
        requestBody['passcode'] = passcode;
      }

      DebugService.log(
        '📤 请求体: $requestBody',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      final response = await dio.postUri(url, data: requestBody);

      DebugService.log(
        '📡 响应状态码: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      if (response.statusCode != 200) {
        DebugService.log(
          '❌ 分享请求失败，状态码: ${response.statusCode}',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        DebugService.log(
          '📄 错误响应: ${response.data}',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        throw Exception('创建分享链接失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      DebugService.log(
        '📄 分享响应数据: $responseData',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      if (responseData['code'] != 0) {
        DebugService.log(
          '❌ API返回错误: ${responseData['message']}',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        throw Exception('创建分享链接失败: ${responseData['message']}');
      }

      // 解析分享结果
      final taskResp = responseData['data']['task_resp'];
      final taskData = taskResp['data'];

      final shareId = taskData['share_id'];
      final eventId = taskData['event_id'];
      final status = taskData['status'];

      DebugService.log(
        '✅ 分享创建成功',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '🆔 分享ID: $shareId',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '🆔 事件ID: $eventId',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📊 状态: $status',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      // 构建分享链接
      final shareUrl = QuarkConfig.buildShareUrl(shareId);

      final result = {
        'success': true,
        'share_id': shareId,
        'event_id': eventId,
        'share_url': shareUrl,
        'passcode': passcode,
        'expired_type': expiredType,
        'title': title ?? '分享文件',
      };

      DebugService.log(
        '🔗 分享链接: $shareUrl',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      return result;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 创建分享链接异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      rethrow;
    }
  }

  /// 获取分享链接信息
  static Future<Map<String, dynamic>?> getShareInfo({
    required CloudDriveAccount account,
    required String shareId,
  }) async {
    DebugService.log(
      '🔍 夸克云盘 - 获取分享信息开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '🆔 分享ID: $shareId',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      final dio = _createDio(account);
      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('getShareInfo')}',
      );
      final queryParams = {
        'pr': 'ucpro',
        'fr': 'pc',
        'uc_param_str': '',
        'share_id': shareId,
      };

      final uri = url.replace(queryParameters: queryParams);
      DebugService.log(
        '🔗 请求URL: $uri',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      final response = await dio.getUri(uri);

      DebugService.log(
        '📡 响应状态码: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      if (response.statusCode != 200) {
        DebugService.log(
          '❌ 获取分享信息失败，状态码: ${response.statusCode}',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        throw Exception('获取分享信息失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      DebugService.log(
        '📄 分享信息响应: $responseData',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      if (responseData['code'] != 0) {
        DebugService.log(
          '❌ API返回错误: ${responseData['message']}',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        throw Exception('获取分享信息失败: ${responseData['message']}');
      }

      return responseData['data'];
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 获取分享信息异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      rethrow;
    }
  }

  /// 创建文件夹
  static Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    DebugService.log(
      '📁 夸克云盘 - 创建文件夹开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📝 文件夹名称: $folderName',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📂 父文件夹ID: ${parentFolderId ?? '根目录'}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      final dio = _createDio(account);
      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('createFolder')}',
      );

      // 添加必要的查询参数（与getFileList保持一致）
      final queryParams = QuarkConfig.buildCreateFolderParams();

      final uri = url.replace(queryParameters: queryParams);
      DebugService.log(
        '🔗 请求URL: $uri',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      // 构建请求体
      final requestBody = {
        'pdir_fid': QuarkConfig.getFolderId(parentFolderId), // 父文件夹ID，默认为根目录
        'file_name': folderName,
        'dir_path': '',
        'dir_init_lock': false,
      };

      DebugService.log(
        '📤 请求体: ${jsonEncode(requestBody)}',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      final response = await dio.postUri(uri, data: requestBody);

      DebugService.log(
        '📡 响应状态码: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      if (response.statusCode != 200) {
        DebugService.log(
          '❌ 创建文件夹请求失败，状态码: ${response.statusCode}',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        DebugService.log(
          '📄 错误响应: ${response.data}',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        throw Exception('创建文件夹失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      DebugService.log(
        '📄 创建文件夹响应数据: $responseData',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      if (responseData['code'] != 0) {
        DebugService.log(
          '❌ API返回错误: ${responseData['message']}',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        throw Exception('创建文件夹失败: ${responseData['message']}');
      }

      // 解析创建结果
      final data = responseData['data'];
      final finish = data['finish'] as bool?;
      final fid = data['fid'] as String?;

      DebugService.log(
        '✅ 文件夹创建成功',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '🆔 文件夹ID: $fid',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '✅ 是否完成: $finish',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      // 创建CloudDriveFile对象
      if (fid != null) {
        final folder = CloudDriveFile(
          id: fid,
          name: folderName,
          size: 0, // 文件夹大小固定为0
          modifiedTime: DateTime.now(),
          isFolder: true,
          folderId: QuarkConfig.getFolderId(parentFolderId),
        );

        DebugService.log(
          '📁 创建文件夹对象: ${folder.name} (ID: ${folder.id})',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );

        final result = {
          'success': true,
          'folderId': fid,
          'folderName': folderName,
          'parentFolderId': QuarkConfig.getFolderId(parentFolderId),
          'finish': finish ?? false,
          'folder': folder, // 添加CloudDriveFile对象
        };

        return result;
      } else {
        DebugService.log(
          '⚠️ 文件夹创建成功但未返回文件夹ID',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );

        final result = {
          'success': true,
          'folderId': null,
          'folderName': folderName,
          'parentFolderId': QuarkConfig.getFolderId(parentFolderId),
          'finish': finish ?? false,
        };

        return result;
      }
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 创建文件夹异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      rethrow;
    }
  }

  /// 获取下载链接
  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required String fileId,
    required String fileName,
    int? size,
  }) async {
    DebugService.log(
      '🔗 夸克云盘 - 获取下载链接开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📄 文件信息: $fileName (ID: $fileId)',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📊 文件大小: ${size ?? '未知'}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      final dio = await QuarkBaseService.createDioWithAuth(account);
      final queryParams = QuarkConfig.buildFileOperationParams();
      final requestBody = QuarkConfig.buildDownloadFileBody(fileIds: [fileId]);

      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('getDownloadUrl')}',
      );
      final uri = url.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );

      DebugService.log(
        '🔗 请求URL: $uri',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📤 请求体: $requestBody',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      final response = await dio.postUri(uri, data: requestBody);

      if (response.statusCode != QuarkConfig.responseStatus['httpSuccess']) {
        throw Exception('获取下载链接失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      DebugService.log(
        '📥 夸克云盘 - 下载响应: ${responseData.toString().length > 500 ? '${responseData.toString().substring(0, 500)}...' : responseData}',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      if (responseData[QuarkConfig.responseFields['code']] !=
          QuarkConfig.responseStatus['apiSuccess']) {
        final message =
            responseData[QuarkConfig.responseFields['message']] ?? '获取下载链接失败';
        throw Exception('获取下载链接失败: $message');
      }

      final dataList =
          responseData[QuarkConfig.responseFields['data']] as List?;
      if (dataList == null || dataList.isEmpty) {
        DebugService.log(
          '❌ 夸克云盘 - 下载响应数据为空',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return null;
      }

      // 获取第一个文件的下载链接
      final fileData = dataList.first as Map<String, dynamic>;
      final downloadUrl = fileData['download_url'] as String?;

      if (downloadUrl != null && downloadUrl.isNotEmpty) {
        DebugService.log(
          '✅ 夸克云盘 - 下载链接获取成功: ${downloadUrl.substring(0, downloadUrl.length > 100 ? 100 : downloadUrl.length)}...',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return downloadUrl;
      } else {
        DebugService.log(
          '❌ 夸克云盘 - 响应中未找到下载链接',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return null;
      }
    } catch (e) {
      DebugService.log(
        '❌ 夸克云盘 - 获取下载链接失败: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      rethrow;
    }
  }

  /// 移动文件
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required String fileId,
    required String targetParentFileId,
  }) async {
    DebugService.log(
      '🚚 夸克云盘 - 移动文件开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📄 文件ID: $fileId',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📁 目标文件夹ID: $targetParentFileId',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '🔑 认证方式: ${account.type.authType}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '🔐 认证头: ${account.authHeaders}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      DebugService.log(
        '🚀 准备调用夸克云盘文件移动API',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📝 需要实现的API: 夸克云盘文件移动接口',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📋 请求参数: fileId=$fileId, targetParentFileId=$targetParentFileId',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      // TODO: 实现夸克云盘文件移动
      DebugService.log(
        '⚠️ 夸克云盘 - 文件移动功能暂未实现',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      return false;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 移动文件异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return false;
    }
  }

  /// 删除文件
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required String fileId,
    required String fileName,
    int? type,
    int? size,
    String? parentFileId,
  }) async {
    DebugService.log(
      '🗑️ 夸克云盘 - 删除文件开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📄 文件信息: $fileName (ID: $fileId)',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📊 文件类型: ${type ?? '未知'}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📊 文件大小: ${size ?? '未知'}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📁 父文件夹ID: ${parentFileId ?? '未知'}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '🔑 认证方式: ${account.type.authType}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '🔐 认证头: ${account.authHeaders}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      DebugService.log(
        '🚀 准备调用夸克云盘文件删除API',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📝 需要实现的API: 夸克云盘文件删除接口',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📋 请求参数: fileId=$fileId, fileName=$fileName, type=$type, size=$size, parentFileId=$parentFileId',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      // TODO: 实现夸克云盘文件删除
      DebugService.log(
        '⚠️ 夸克云盘 - 文件删除功能暂未实现',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      return false;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 删除文件异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return false;
    }
  }

  /// 重命名文件
  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required String fileId,
    required String newFileName,
  }) async {
    DebugService.log(
      '✏️ 夸克云盘 - 重命名文件开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📄 文件ID: $fileId',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '🔄 新文件名: $newFileName',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '🔑 认证方式: ${account.type.authType}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '🔐 认证头: ${account.authHeaders}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      DebugService.log(
        '🚀 准备调用夸克云盘文件重命名API',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📝 需要实现的API: 夸克云盘文件重命名接口',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📋 请求参数: fileId=$fileId, newFileName=$newFileName',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      // TODO: 实现夸克云盘文件重命名
      DebugService.log(
        '⚠️ 夸克云盘 - 文件重命名功能暂未实现',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      return false;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 重命名文件异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return false;
    }
  }

  /// 复制文件
  static Future<bool> copyFile({
    required CloudDriveAccount account,
    required String fileId,
    required String targetFileId,
    required String fileName,
    int? size,
    int? type,
    String? parentFileId,
  }) async {
    DebugService.log(
      '📋 夸克云盘 - 复制文件开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📄 文件信息: $fileName (ID: $fileId)',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📁 目标文件夹ID: $targetFileId',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📊 文件类型: ${type ?? '未知'}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📊 文件大小: ${size ?? '未知'}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '📁 父文件夹ID: ${parentFileId ?? '未知'}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '🔑 认证方式: ${account.type.authType}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '🔐 认证头: ${account.authHeaders}',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      DebugService.log(
        '🚀 准备调用夸克云盘文件复制API',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📝 需要实现的API: 夸克云盘文件复制接口',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📋 请求参数: fileId=$fileId, targetFileId=$targetFileId, fileName=$fileName, type=$type, size=$size, parentFileId=$parentFileId',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      // TODO: 实现夸克云盘文件复制
      DebugService.log(
        '⚠️ 夸克云盘 - 文件复制功能暂未实现',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      return false;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 复制文件异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return false;
    }
  }

  /// 获取账号个人信息
  static Future<CloudDriveAccountInfo?> getAccountInfo({
    required CloudDriveAccount account,
  }) async {
    DebugService.log(
      '👤 夸克云盘 - 获取账号个人信息开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      // 创建专门用于pan.quark.cn的dio实例
      final dio = Dio(
        BaseOptions(
          baseUrl: QuarkConfig.panUrl,
          connectTimeout: QuarkConfig.connectTimeout,
          receiveTimeout: QuarkConfig.receiveTimeout,
          headers: {...QuarkConfig.defaultHeaders, ...account.authHeaders},
        ),
      );

      // 添加请求拦截器
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            DebugService.log(
              '📡 发送请求: ${options.method} ${options.uri}',
              category: DebugCategory.tools,
              subCategory: QuarkConfig.logSubCategory,
            );
            DebugService.log(
              '📋 请求头: ${options.headers}',
              category: DebugCategory.tools,
              subCategory: QuarkConfig.logSubCategory,
            );
            handler.next(options);
          },
          onResponse: (response, handler) {
            DebugService.log(
              '📡 收到响应: ${response.statusCode}',
              category: DebugCategory.tools,
              subCategory: QuarkConfig.logSubCategory,
            );
            DebugService.log(
              '📄 响应数据: ${response.data}',
              category: DebugCategory.tools,
              subCategory: QuarkConfig.logSubCategory,
            );
            handler.next(response);
          },
          onError: (error, handler) {
            DebugService.log(
              '❌ 请求错误: ${error.message}',
              category: DebugCategory.tools,
              subCategory: QuarkConfig.logSubCategory,
            );
            if (error.response != null) {
              DebugService.log(
                '📄 错误响应: ${error.response?.data}',
                category: DebugCategory.tools,
                subCategory: QuarkConfig.logSubCategory,
              );
            }
            handler.next(error);
          },
        ),
      );

      final endpoint = QuarkConfig.getPanApiEndpoint('getAccountInfo');
      final params = QuarkConfig.buildAccountInfoParams();

      final response = await dio.get(endpoint, queryParameters: params);

      if (response.data['success'] == true && response.data['code'] == 'OK') {
        final data = response.data['data'];

        DebugService.log(
          '✅ 夸克云盘 - 账号个人信息获取成功',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );

        return CloudDriveAccountInfo(
          username: data['nickname'] ?? '',
          phone: data['mobilekps'] != null ? '已绑定' : null,
          photo: data['avatarUri'],
          uk: 0, // 夸克云盘没有uk概念，设为0
        );
      } else {
        DebugService.log(
          '❌ 夸克云盘 - 账号个人信息获取失败: 响应状态不正确',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return null;
      }
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 获取账号个人信息异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return null;
    }
  }

  /// 获取账号容量信息
  static Future<CloudDriveQuotaInfo?> getMemberInfo({
    required CloudDriveAccount account,
  }) async {
    DebugService.log(
      '💾 夸克云盘 - 获取账号容量信息开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      final dio = _createDio(account);
      final endpoint = QuarkConfig.getApiEndpoint('getMember');
      final params = QuarkConfig.buildMemberParams();

      final response = await dio.get(endpoint, queryParameters: params);

      if (response.data['status'] == 200 && response.data['code'] == 0) {
        final data = response.data['data'];

        DebugService.log(
          '✅ 夸克云盘 - 账号容量信息获取成功',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );

        final totalCapacity = data['total_capacity'] ?? 0;
        final useCapacity = data['use_capacity'] ?? 0;

        return CloudDriveQuotaInfo(
          total: totalCapacity,
          used: useCapacity,
          serverTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
      } else {
        DebugService.log(
          '❌ 夸克云盘 - 账号容量信息获取失败: 响应状态不正确',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return null;
      }
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 获取账号容量信息异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return null;
    }
  }

  /// 获取完整账号详情
  static Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    DebugService.log(
      '📋 夸克云盘 - 获取完整账号详情开始',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );
    DebugService.log(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: QuarkConfig.logSubCategory,
    );

    try {
      // 并发获取用户信息和容量信息
      final results = await Future.wait([
        getAccountInfo(account: account),
        getMemberInfo(account: account),
      ]);

      final accountInfo = results[0] as CloudDriveAccountInfo?;
      final quotaInfo = results[1] as CloudDriveQuotaInfo?;

      if (accountInfo == null || quotaInfo == null) {
        DebugService.log(
          '❌ 获取账号详情失败: 用户信息=${accountInfo != null ? '成功' : '失败'}, 容量信息=${quotaInfo != null ? '成功' : '失败'}',
          category: DebugCategory.tools,
          subCategory: QuarkConfig.logSubCategory,
        );
        return null;
      }

      // 从会员信息中获取会员类型和状态
      final memberResponse = await _createDio(account).get(
        QuarkConfig.getApiEndpoint('getMember'),
        queryParameters: QuarkConfig.buildMemberParams(),
      );

      String vipType = '普通用户';

      if (memberResponse.data['status'] == 200 &&
          memberResponse.data['code'] == 0) {
        final memberData = memberResponse.data['data'];
        final memberType = memberData['member_type'] ?? '';

        switch (memberType) {
          case 'EXP_SVIP':
            vipType = '超级会员(体验)';
            break;
          case 'SVIP':
            vipType = '超级会员';
            break;
          case 'VIP':
            vipType = '会员';
            break;
          default:
            vipType = '普通用户';
        }
      }

      // 更新账号信息的会员状态
      final updatedAccountInfo = CloudDriveAccountInfo(
        username: accountInfo.username,
        phone: accountInfo.phone,
        photo: accountInfo.photo,
        uk: accountInfo.uk,
        isVip: vipType == '会员' || vipType == '超级会员' || vipType == '超级会员(体验)',
        isSvip: vipType == '超级会员' || vipType == '超级会员(体验)',
        loginState: 1, // 已登录状态
      );

      final accountDetails = CloudDriveAccountDetails(
        accountInfo: updatedAccountInfo,
        quotaInfo: quotaInfo,
      );

      DebugService.log(
        '✅ 夸克云盘 - 完整账号详情获取成功',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📊 账号详情: ${accountDetails.toString()}',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );

      return accountDetails;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 夸克云盘 - 获取完整账号详情异常: $e',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: QuarkConfig.logSubCategory,
      );
      return null;
    }
  }
}
