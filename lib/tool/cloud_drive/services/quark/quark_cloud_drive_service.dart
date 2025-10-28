import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import 'quark_base_service.dart';
import 'quark_config.dart';
import 'quark_auth_service.dart';

/// 夸克云盘服务
class QuarkCloudDriveService {
  /// 获取文件列表
  static Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? parentFileId,
    int page = 1,
    int pageSize = 50,
  }) async {
    LogManager().cloudDrive('📁 获取文件列表开始');

    try {
      final dio = await QuarkBaseService.createDioWithAuth(account);
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

      LogManager().cloudDrive('🌐 请求URL: ${url.toString()}');

      final uri = url.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );

      LogManager().cloudDrive('🔗 完整请求URL: ${uri.toString()}');

      final response = await dio.getUri(uri);

      LogManager().cloudDrive('📡 响应状态: ${response.statusCode}');

      final responseData = response.data as Map<String, dynamic>;

      LogManager().cloudDrive('📄 响应数据: ${responseData.toString()}');

      // 检查响应状态
      if (responseData['code'] != 0) {
        LogManager().cloudDrive('API返回错误');
        return [];
      }

      final data = responseData['data'] as Map<String, dynamic>?;
      if (data == null) {
        LogManager().cloudDrive('⚠️ 响应中没有data字段');
        return [];
      }

      final fileList = data['file_list'] as List<dynamic>? ?? [];
      final folderList = data['folder_list'] as List<dynamic>? ?? [];

      LogManager().cloudDrive('📄 解析到的文件列表数量: ${fileList.length}');
      LogManager().cloudDrive('📁 解析到的文件夹列表数量: ${folderList.length}');

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
            LogManager().cloudDrive('✅ 文件解析成功: ${file.name} (ID: ${file.id})');
          }
        } catch (e) {
          LogManager().cloudDrive('解析文件失败');
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
            LogManager().cloudDrive(
              '✅ 文件夹解析成功: ${folder.name} (ID: ${folder.id})',
            );
          }
        } catch (e) {
          LogManager().cloudDrive('解析文件夹失败');
        }
      }

      LogManager().cloudDrive('成功获取 ${files.length} 个文件/文件夹');

      return files;
    } catch (e) {
      LogManager().cloudDrive('获取文件列表失败');
      return [];
    }
  }

  /// 解析文件数据
  static CloudDriveFile? _parseFileData(
    Map<String, dynamic> fileData,
    String parentId,
  ) {
    try {
      LogManager().cloudDrive('🔍 开始解析文件数据: $fileData');

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

      LogManager().cloudDrive(
        '📋 解析结果: ID=$fid, 名称=$name, 大小=$size, 文件类型=$fileType, 分类=$category, 是否文件夹=$isFolder',
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
          LogManager().cloudDrive('🕒 解析时间戳(毫秒): $updateTime -> $updatedAt');
        } else if (updateTime is String) {
          updatedAt = DateTime.tryParse(updateTime);
          LogManager().cloudDrive('🕒 解析时间戳(字符串): $updateTime -> $updatedAt');
        }
      } else {
        LogManager().cloudDrive('⚠️ 没有找到时间戳信息');
      }

      // 格式化文件大小
      String formattedSize = '0 B';
      if (!isFolder && size.isNotEmpty && size != '0') {
        final sizeInt = int.tryParse(size) ?? 0;
        if (sizeInt > 0) {
          formattedSize = QuarkConfig.formatFileSize(sizeInt);
          LogManager().cloudDrive('📊 格式化文件大小: $size -> $formattedSize');
        }
      }

      // 格式化时间 - 使用友好的格式而不是ISO格式
      String? formattedTime;
      if (updatedAt != null) {
        formattedTime = QuarkConfig.formatDateTime(updatedAt);
        LogManager().cloudDrive('⏰ 格式化时间: $updatedAt -> $formattedTime');
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

      LogManager().cloudDrive(
        '✅ 文件解析完成: ${file.name} (ID: ${file.id}, 文件夹: ${file.isFolder})',
      );

      return file;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('解析文件数据失败');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
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
    LogManager().cloudDrive('🔗 夸克云盘 - 创建分享链接开始');
    LogManager().cloudDrive('📄 文件ID列表: $fileIds');
    LogManager().cloudDrive('📝 分享标题: ${title ?? '未设置'}');
    LogManager().cloudDrive('🔐 提取码: ${passcode ?? '无'}');
    LogManager().cloudDrive('⏰ 过期类型: $expiredType');

    try {
      final dio = await QuarkBaseService.createDioWithAuth(account);
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

      LogManager().cloudDrive('📤 请求体: $requestBody');

      final response = await dio.postUri(url, data: requestBody);

      LogManager().cloudDrive('📡 响应状态码: ${response.statusCode}');

      if (response.statusCode != 200) {
        LogManager().cloudDrive('❌ 分享请求失败，状态码: ${response.statusCode}');
        LogManager().cloudDrive('📄 错误响应: ${response.data}');
        throw Exception('创建分享链接失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      LogManager().cloudDrive('📄 分享响应数据: $responseData');

      if (responseData['code'] != 0) {
        LogManager().cloudDrive('❌ API返回错误: ${responseData['message']}');
        throw Exception('创建分享链接失败: ${responseData['message']}');
      }

      // 解析分享结果
      final taskResp = responseData['data']['task_resp'];
      final taskData = taskResp['data'];

      final shareId = taskData['share_id'];
      final eventId = taskData['event_id'];
      final status = taskData['status'];

      LogManager().cloudDrive('✅ 分享创建成功');
      LogManager().cloudDrive('🆔 分享ID: $shareId');
      LogManager().cloudDrive('🆔 事件ID: $eventId');
      LogManager().cloudDrive('📊 状态: $status');

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

      LogManager().cloudDrive('🔗 分享链接: $shareUrl');

      return result;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 夸克云盘 - 创建分享链接异常: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
      rethrow;
    }
  }

  /// 获取分享链接信息
  static Future<Map<String, dynamic>?> getShareInfo({
    required CloudDriveAccount account,
    required String shareId,
  }) async {
    LogManager().cloudDrive('🔍 夸克云盘 - 获取分享信息开始');
    LogManager().cloudDrive('🆔 分享ID: $shareId');

    try {
      final dio = await QuarkBaseService.createDioWithAuth(account);
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
      LogManager().cloudDrive('🔗 请求URL: $uri');

      final response = await dio.getUri(uri);

      LogManager().cloudDrive('📡 响应状态码: ${response.statusCode}');

      if (response.statusCode != 200) {
        LogManager().cloudDrive('❌ 获取分享信息失败，状态码: ${response.statusCode}');
        throw Exception('获取分享信息失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      LogManager().cloudDrive('📄 分享信息响应: $responseData');

      if (responseData['code'] != 0) {
        LogManager().cloudDrive('❌ API返回错误: ${responseData['message']}');
        throw Exception('获取分享信息失败: ${responseData['message']}');
      }

      return responseData['data'];
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 夸克云盘 - 获取分享信息异常: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
      rethrow;
    }
  }

  /// 创建文件夹
  static Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    LogManager().cloudDrive('📁 夸克云盘 - 创建文件夹开始');
    LogManager().cloudDrive('📝 文件夹名称: $folderName');
    LogManager().cloudDrive('📂 父文件夹ID: ${parentFolderId ?? '根目录'}');

    try {
      final dio = await QuarkBaseService.createDioWithAuth(account);
      final url = Uri.parse(
        '${QuarkConfig.baseUrl}${QuarkConfig.getApiEndpoint('createFolder')}',
      );

      // 添加必要的查询参数（与getFileList保持一致）
      final queryParams = QuarkConfig.buildCreateFolderParams();

      final uri = url.replace(queryParameters: queryParams);
      LogManager().cloudDrive('🔗 请求URL: $uri');

      // 构建请求体
      final requestBody = {
        'pdir_fid': QuarkConfig.getFolderId(parentFolderId), // 父文件夹ID，默认为根目录
        'file_name': folderName,
        'dir_path': '',
        'dir_init_lock': false,
      };

      LogManager().cloudDrive('📤 请求体: ${jsonEncode(requestBody)}');

      final response = await dio.postUri(uri, data: requestBody);

      LogManager().cloudDrive('📡 响应状态码: ${response.statusCode}');

      if (response.statusCode != 200) {
        LogManager().cloudDrive('❌ 创建文件夹请求失败，状态码: ${response.statusCode}');
        LogManager().cloudDrive('📄 错误响应: ${response.data}');
        throw Exception('创建文件夹失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      LogManager().cloudDrive('📄 创建文件夹响应数据: $responseData');

      if (responseData['code'] != 0) {
        LogManager().cloudDrive('❌ API返回错误: ${responseData['message']}');
        throw Exception('创建文件夹失败: ${responseData['message']}');
      }

      // 解析创建结果
      final data = responseData['data'];
      final finish = data['finish'] as bool?;
      final fid = data['fid'] as String?;

      LogManager().cloudDrive('✅ 文件夹创建成功');
      LogManager().cloudDrive('🆔 文件夹ID: $fid');
      LogManager().cloudDrive('✅ 是否完成: $finish');

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

        LogManager().cloudDrive(
          '📁 创建文件夹对象: ${folder.name} (ID: ${folder.id})',
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
        LogManager().cloudDrive('⚠️ 文件夹创建成功但未返回文件夹ID');

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
      LogManager().cloudDrive('❌ 夸克云盘 - 创建文件夹异常: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
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
    LogManager().cloudDrive('🔗 夸克云盘 - 获取下载链接开始');
    LogManager().cloudDrive('📄 文件信息: $fileName (ID: $fileId)');
    LogManager().cloudDrive('📊 文件大小: ${size ?? '未知'}');

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

      LogManager().cloudDrive('🔗 请求URL: $uri');
      LogManager().cloudDrive('📤 请求体: $requestBody');

      final response = await dio.postUri(uri, data: requestBody);

      if (response.statusCode != QuarkConfig.responseStatus['httpSuccess']) {
        throw Exception('获取下载链接失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      LogManager().cloudDrive(
        '📥 夸克云盘 - 下载响应: ${responseData.toString().length > 500 ? '${responseData.toString().substring(0, 500)}...' : responseData}',
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
        LogManager().cloudDrive('❌ 夸克云盘 - 下载响应数据为空');
        return null;
      }

      // 获取第一个文件的下载链接
      final fileData = dataList.first as Map<String, dynamic>;
      final downloadUrl = fileData['download_url'] as String?;

      if (downloadUrl != null && downloadUrl.isNotEmpty) {
        LogManager().cloudDrive(
          '✅ 夸克云盘 - 下载链接获取成功: ${downloadUrl.substring(0, downloadUrl.length > 100 ? 100 : downloadUrl.length)}...',
        );
        return downloadUrl;
      } else {
        LogManager().cloudDrive('❌ 夸克云盘 - 响应中未找到下载链接');
        return null;
      }
    } catch (e) {
      LogManager().cloudDrive('❌ 夸克云盘 - 获取下载链接失败: $e');
      rethrow;
    }
  }

  /// 移动文件
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required String fileId,
    required String targetParentFileId,
  }) async {
    LogManager().cloudDrive('🚚 夸克云盘 - 移动文件开始');
    LogManager().cloudDrive('📄 文件ID: $fileId');
    LogManager().cloudDrive('📁 目标文件夹ID: $targetParentFileId');
    LogManager().cloudDrive(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
    );
    LogManager().cloudDrive('🔑 认证方式: ${account.type.authType}');
    LogManager().cloudDrive('🔐 认证头: ${account.authHeaders}');

    try {
      LogManager().cloudDrive('🚀 准备调用夸克云盘文件移动API');
      LogManager().cloudDrive('📝 需要实现的API: 夸克云盘文件移动接口');
      LogManager().cloudDrive(
        '📋 请求参数: fileId=$fileId, targetParentFileId=$targetParentFileId',
      );

      // TODO: 实现夸克云盘文件移动
      LogManager().cloudDrive('⚠️ 夸克云盘 - 文件移动功能暂未实现');

      return false;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 夸克云盘 - 移动文件异常: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
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
    LogManager().cloudDrive('🗑️ 夸克云盘 - 删除文件开始');
    LogManager().cloudDrive('📄 文件信息: $fileName (ID: $fileId)');
    LogManager().cloudDrive('📊 文件类型: ${type ?? '未知'}');
    LogManager().cloudDrive('📊 文件大小: ${size ?? '未知'}');
    LogManager().cloudDrive('📁 父文件夹ID: ${parentFileId ?? '未知'}');
    LogManager().cloudDrive(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
    );
    LogManager().cloudDrive('🔑 认证方式: ${account.type.authType}');
    LogManager().cloudDrive('🔐 认证头: ${account.authHeaders}');

    try {
      LogManager().cloudDrive('🚀 准备调用夸克云盘文件删除API');
      LogManager().cloudDrive('📝 需要实现的API: 夸克云盘文件删除接口');
      LogManager().cloudDrive(
        '📋 请求参数: fileId=$fileId, fileName=$fileName, type=$type, size=$size, parentFileId=$parentFileId',
      );

      // TODO: 实现夸克云盘文件删除
      LogManager().cloudDrive('⚠️ 夸克云盘 - 文件删除功能暂未实现');

      return false;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 夸克云盘 - 删除文件异常: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
      return false;
    }
  }

  /// 重命名文件
  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required String fileId,
    required String newFileName,
  }) async {
    LogManager().cloudDrive('✏️ 夸克云盘 - 重命名文件开始');
    LogManager().cloudDrive('📄 文件ID: $fileId');
    LogManager().cloudDrive('🔄 新文件名: $newFileName');
    LogManager().cloudDrive(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
    );
    LogManager().cloudDrive('🔑 认证方式: ${account.type.authType}');
    LogManager().cloudDrive('🔐 认证头: ${account.authHeaders}');

    try {
      LogManager().cloudDrive('🚀 准备调用夸克云盘文件重命名API');
      LogManager().cloudDrive('📝 需要实现的API: 夸克云盘文件重命名接口');
      LogManager().cloudDrive(
        '📋 请求参数: fileId=$fileId, newFileName=$newFileName',
      );

      // TODO: 实现夸克云盘文件重命名
      LogManager().cloudDrive('⚠️ 夸克云盘 - 文件重命名功能暂未实现');

      return false;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 夸克云盘 - 重命名文件异常: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
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
    LogManager().cloudDrive('📋 夸克云盘 - 复制文件开始');
    LogManager().cloudDrive('📄 文件信息: $fileName (ID: $fileId)');
    LogManager().cloudDrive('📁 目标文件夹ID: $targetFileId');
    LogManager().cloudDrive('📊 文件类型: ${type ?? '未知'}');
    LogManager().cloudDrive('📊 文件大小: ${size ?? '未知'}');
    LogManager().cloudDrive('📁 父文件夹ID: ${parentFileId ?? '未知'}');
    LogManager().cloudDrive(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
    );
    LogManager().cloudDrive('🔑 认证方式: ${account.type.authType}');
    LogManager().cloudDrive('🔐 认证头: ${account.authHeaders}');

    try {
      LogManager().cloudDrive('🚀 准备调用夸克云盘文件复制API');
      LogManager().cloudDrive('📝 需要实现的API: 夸克云盘文件复制接口');
      LogManager().cloudDrive(
        '📋 请求参数: fileId=$fileId, targetFileId=$targetFileId, fileName=$fileName, type=$type, size=$size, parentFileId=$parentFileId',
      );

      // TODO: 实现夸克云盘文件复制
      LogManager().cloudDrive('⚠️ 夸克云盘 - 文件复制功能暂未实现');

      return false;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 夸克云盘 - 复制文件异常: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
      return false;
    }
  }

  /// 获取账号个人信息
  static Future<CloudDriveAccountInfo?> getAccountInfo({
    required CloudDriveAccount account,
  }) async {
    LogManager().cloudDrive('👤 夸克云盘 - 获取账号个人信息开始');

    try {
      // 创建专门用于pan.quark.cn的dio实例，使用刷新后的认证头
      final authHeaders = await QuarkAuthService.buildAuthHeaders(account);
      final dio = Dio(
        BaseOptions(
          baseUrl: QuarkConfig.panUrl,
          connectTimeout: QuarkConfig.connectTimeout,
          receiveTimeout: QuarkConfig.receiveTimeout,
          headers: authHeaders,
        ),
      );

      // 添加请求拦截器
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            LogManager().cloudDrive(
              '📡 发送请求: ${options.method} ${options.uri}',
            );
            LogManager().cloudDrive('📋 请求头: ${options.headers}');
            handler.next(options);
          },
          onResponse: (response, handler) {
            LogManager().cloudDrive('📡 收到响应: ${response.statusCode}');
            LogManager().cloudDrive('📄 响应数据: ${response.data}');
            handler.next(response);
          },
          onError: (error, handler) {
            LogManager().cloudDrive('❌ 请求错误: ${error.message}');
            if (error.response != null) {
              LogManager().cloudDrive('📄 错误响应: ${error.response?.data}');
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

        LogManager().cloudDrive('✅ 夸克云盘 - 账号个人信息获取成功');

        return CloudDriveAccountInfo(
          username: data['nickname'] ?? '',
          phone: data['mobilekps'] != null ? '已绑定' : null,
          photo: data['avatarUri'],
          uk: 0, // 夸克云盘没有uk概念，设为0
        );
      } else {
        LogManager().cloudDrive('❌ 夸克云盘 - 账号个人信息获取失败: 响应状态不正确');
        return null;
      }
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 夸克云盘 - 获取账号个人信息异常: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
      return null;
    }
  }

  /// 获取账号容量信息
  static Future<CloudDriveQuotaInfo?> getMemberInfo({
    required CloudDriveAccount account,
  }) async {
    LogManager().cloudDrive('💾 夸克云盘 - 获取账号容量信息开始');

    try {
      final dio = await QuarkBaseService.createDioWithAuth(account);
      final endpoint = QuarkConfig.getApiEndpoint('getMember');
      final params = QuarkConfig.buildMemberParams();

      final response = await dio.get(endpoint, queryParameters: params);

      if (response.data['status'] == 200 && response.data['code'] == 0) {
        final data = response.data['data'];

        LogManager().cloudDrive('✅ 夸克云盘 - 账号容量信息获取成功');

        final totalCapacity = data['total_capacity'] ?? 0;
        final useCapacity = data['use_capacity'] ?? 0;

        return CloudDriveQuotaInfo(
          total: totalCapacity,
          used: useCapacity,
          serverTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
      } else {
        LogManager().cloudDrive('❌ 夸克云盘 - 账号容量信息获取失败: 响应状态不正确');
        return null;
      }
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 夸克云盘 - 获取账号容量信息异常: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
      return null;
    }
  }

  /// 获取完整账号详情
  static Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    LogManager().cloudDrive('📋 夸克云盘 - 获取完整账号详情开始');
    LogManager().cloudDrive(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
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
        LogManager().cloudDrive(
          '❌ 获取账号详情失败: 用户信息=${accountInfo != null ? '成功' : '失败'}, 容量信息=${quotaInfo != null ? '成功' : '失败'}',
        );
        return null;
      }

      // 从会员信息中获取会员类型和状态
      final memberDio = await QuarkBaseService.createDioWithAuth(account);
      final memberResponse = await memberDio.get(
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
        id: updatedAccountInfo.username,
        name: updatedAccountInfo.username,
        accountInfo: updatedAccountInfo,
        quotaInfo: quotaInfo,
      );

      LogManager().cloudDrive('✅ 夸克云盘 - 完整账号详情获取成功');
      LogManager().cloudDrive('📊 账号详情: ${accountDetails.toString()}');

      return accountDetails;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 夸克云盘 - 获取完整账号详情异常: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
      return null;
    }
  }
}
