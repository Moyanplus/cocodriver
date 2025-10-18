import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/services/base/debug_service.dart';
import '../../base/cloud_drive_operation_service.dart';
import '../../models/cloud_drive_models.dart';
import 'baidu_cloud_drive_service.dart';
import 'baidu_config.dart';

/// 百度网盘操作策略
class BaiduCloudDriveOperationStrategy implements CloudDriveOperationStrategy {
  @override
  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    DebugService.log(
      '🔗 百度网盘 - 获取下载链接开始',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📄 百度网盘 - 文件信息: ${file.name} (ID: ${file.id})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '👤 百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      final downloadUrl = await BaiduCloudDriveService.getDownloadUrl(
        account: account,
        file: file,
      );

      if (downloadUrl != null) {
        final preview =
            downloadUrl.length > 50
                ? '${downloadUrl.substring(0, 50)}...'
                : downloadUrl;
        DebugService.log(
          '✅ 百度网盘 - 下载链接获取成功: $preview',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 百度网盘 - 下载链接获取失败: 返回null',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      }

      return downloadUrl;
    } catch (e) {
      DebugService.error(
        '❌ 百度网盘 - 获取下载链接异常',
        e,
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      rethrow;
    }
  }

  /// 高速下载 - 使用第三方解析服务获取直接下载链接
  @override
  Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    DebugService.log(
      '🚀 百度网盘 - 开始高速下载解析',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📄 百度网盘 - 文件信息: ${file.name} (ID: ${file.id})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '🔗 百度网盘 - 分享链接: $shareUrl',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '🔑 百度网盘 - 提取密码: $password',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '👤 百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      // 第一步：获取文件列表
      final fileListResponse = await Dio().post(
        'https://mf.dp.wpurl.cc/api/v1/user/parse/get_file_list',
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
            'Content-Type': 'application/json',
            'Accept': 'application/json, text/plain, */*',
            'Origin': 'https://mf.dp.wpurl.cc',
            'Referer': 'https://mf.dp.wpurl.cc/user/parse',
          },
        ),
        data: json.encode({
          'url': shareUrl,
          'surl': _extractBaiduSurl(shareUrl),
          'pwd': password,
          'dir': '/',
          'parse_password': '3594',
          'rand1': _generateRandomString(32),
          'rand2': _generateRandomString(32),
          'rand3': _generateRandomString(32),
        }),
      );

      DebugService.log(
        '📡 百度网盘 - 文件列表响应状态码: ${fileListResponse.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📡 百度网盘 - 文件列表响应内容: ${fileListResponse.data}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (fileListResponse.statusCode != 200) {
        throw Exception('获取文件列表失败，状态码: ${fileListResponse.statusCode}');
      }

      final fileListData = json.decode(fileListResponse.data);
      if (fileListData['code'] != 200) {
        throw Exception('获取文件列表失败: ${fileListData['message']}');
      }

      final rawFileList = fileListData['data']['list'] as List<dynamic>? ?? [];
      final fileList =
          rawFileList.map((file) => file as Map<String, dynamic>).toList();

      if (fileList.isEmpty) {
        throw Exception('网盘链接中没有找到文件');
      }

      // 查找匹配的文件
      final targetFile = fileList.firstWhere(
        (f) =>
            f['server_filename'] == file.name ||
            f['fs_id'].toString() == file.id,
        orElse: () => throw Exception('未找到匹配的文件: ${file.name}'),
      );

      DebugService.log(
        '✅ 百度网盘 - 找到匹配文件: ${targetFile['server_filename']}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      // 第二步：获取下载链接
      final downloadResponse = await Dio().post(
        'https://mf.dp.wpurl.cc/api/v1/user/parse/get_download_links',
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
            'Content-Type': 'application/json',
            'Accept': 'application/json, text/plain, */*',
            'Origin': 'https://mf.dp.wpurl.cc',
            'Referer': 'https://mf.dp.wpurl.cc/user/parse',
          },
        ),
        data: json.encode({
          'randsk': fileListData['data']['randsk'],
          'uk': fileListData['data']['uk'],
          'shareid': fileListData['data']['shareid'],
          'fs_id': [targetFile['fs_id']],
          'surl': _extractBaiduSurl(shareUrl),
          'dir': '/',
          'pwd': password,
          'token': 'guest',
          'parse_password': '3594',
          'vcode_str': '',
          'vcode_input': '',
          'rand1': _generateRandomString(32),
          'rand2': _generateRandomString(32),
          'rand3': _generateRandomString(32),
        }),
      );

      DebugService.log(
        '📡 百度网盘 - 下载链接响应状态码: ${downloadResponse.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📡 百度网盘 - 下载链接响应内容: ${downloadResponse.data}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (downloadResponse.statusCode != 200) {
        throw Exception('获取下载链接失败，状态码: ${downloadResponse.statusCode}');
      }

      final downloadData = json.decode(downloadResponse.data);
      if (downloadData['code'] != 200) {
        throw Exception('获取下载链接失败: ${downloadData['message']}');
      }

      // 提取下载链接
      final downloadUrls = <String>[];
      if (downloadData['data'] != null && downloadData['data'].isNotEmpty) {
        final fileInfo = downloadData['data'][0];
        final urls = fileInfo['urls'] as List<dynamic>? ?? [];
        downloadUrls.addAll(urls.map((url) => url.toString()));
      }

      DebugService.log(
        '✅ 百度网盘 - 高速下载链接获取成功，共 ${downloadUrls.length} 个链接',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return downloadUrls;
    } catch (e) {
      DebugService.error(
        '❌ 百度网盘 - 高速下载解析失败',
        e,
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      rethrow;
    }
  }

  /// 提取百度网盘链接的surl
  String _extractBaiduSurl(String url) {
    final pattern = RegExp(r'https://pan\.baidu\.com/s/([a-zA-Z0-9_-]+)');
    final match = pattern.firstMatch(url);
    return match?.group(1) ?? '';
  }

  /// 生成随机字符串
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      length,
      (index) => chars[DateTime.now().millisecondsSinceEpoch % chars.length],
    ).join();
  }

  @override
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    DebugService.log(
      '🔗 百度网盘 - 生成分享链接开始',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📄 百度网盘 - 文件数量: ${files.length}',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '🔑 百度网盘 - 提取码: ${password ?? '无'}',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '⏰ 百度网盘 - 有效期: ${expireDays ?? 1}天',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '👤 百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      final fileIds = files.map((f) => f.id).toList();
      DebugService.log(
        '📋 百度网盘 - 文件ID列表: $fileIds',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      final shareLink = await BaiduCloudDriveService.createShareLink(
        account: account,
        fileIds: fileIds,
        pwd: password ?? '',
        period: expireDays ?? 1,
      );

      if (shareLink != null) {
        final preview =
            shareLink.length > 50
                ? '${shareLink.substring(0, 50)}...'
                : shareLink;
        DebugService.log(
          '✅ 百度网盘 - 分享链接生成成功: $preview',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 百度网盘 - 分享链接生成失败: 返回null',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      }

      return shareLink;
    } catch (e) {
      DebugService.error(
        '❌ 百度网盘 - 生成分享链接异常',
        e,
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      rethrow;
    }
  }

  @override
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    DebugService.log(
      '🔗 百度网盘 - 移动文件开始',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📄 百度网盘 - 文件信息: ${file.name} (ID: ${file.id})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📁 百度网盘 - 目标文件夹ID: ${targetFolderId ?? '根目录'}',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '👤 百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      // 获取文件的完整路径
      String filePath;
      if (file.isFolder) {
        // 文件夹使用id（已经是完整路径）
        filePath = file.id;
      } else {
        // 文件使用folderId（完整路径）
        filePath = file.folderId ?? file.id;
      }

      DebugService.log(
        '📁 百度网盘 - 文件路径: $filePath',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      final success = await BaiduCloudDriveService.moveFile(
        account: account,
        file: file,
        targetFolderId: targetFolderId,
      );

      if (success) {
        DebugService.log(
          '✅ 百度网盘 - 文件移动成功',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 百度网盘 - 文件移动失败',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      }

      return success;
    } catch (e) {
      DebugService.error(
        '❌ 百度网盘 - 移动文件异常',
        e,
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      rethrow;
    }
  }

  @override
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    DebugService.log(
      '🔗 百度网盘 - 删除文件开始',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📄 百度网盘 - 文件信息: ${file.name} (ID: ${file.id})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '👤 百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      final success = await BaiduCloudDriveService.deleteFile(
        account: account,
        file: file,
      );

      if (success) {
        DebugService.log(
          '✅ 百度网盘 - 文件删除成功',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 百度网盘 - 文件删除失败',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      }

      return success;
    } catch (e) {
      DebugService.error(
        '❌ 百度网盘 - 删除文件异常',
        e,
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      rethrow;
    }
  }

  @override
  Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    DebugService.log(
      '🔗 百度网盘 - 重命名文件开始',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📄 百度网盘 - 文件信息: ${file.name} (ID: ${file.id})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '🔄 百度网盘 - 新文件名: $newName',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '👤 百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      final success = await BaiduCloudDriveService.renameFile(
        account: account,
        file: file,
        newName: newName,
      );

      if (success) {
        DebugService.log(
          '✅ 百度网盘 - 文件重命名成功',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 百度网盘 - 文件重命名失败',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      }

      return success;
    } catch (e) {
      DebugService.error(
        '❌ 百度网盘 - 重命名文件异常',
        e,
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      rethrow;
    }
  }

  @override
  Map<String, bool> getSupportedOperations() {
    DebugService.log(
      '🔧 百度网盘 - 获取支持的操作',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    final operations = {
      'download': true,
      'share': true,
      'share_with_password': true,
      'share_with_expire': true,
      'move': true,
      'delete': true,
      'copy': true,
      'rename': true,
      'createFolder': true, // 已实现
    };
    DebugService.log(
      '📋 百度网盘 - 支持的操作: $operations',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    return operations;
  }

  @override
  Map<String, dynamic> getOperationUIConfig() {
    DebugService.log(
      '🎨 百度网盘 - 获取UI配置',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    final config = {
      'share_password_hint': '提取码（必填，默认0000）',
      'share_expire_options': [
        {'label': '1天', 'value': 1},
        {'label': '7天', 'value': 7},
        {'label': '30天', 'value': 30},
        {'label': '永久', 'value': 0},
      ],
    };
    DebugService.log(
      '📋 百度网盘 - UI配置: $config',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    return config;
  }

  @override
  Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String destPath,
    String? newName,
  }) async {
    DebugService.log(
      '🔗 百度网盘 - 复制文件开始',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📄 百度网盘 - 文件信息: ${file.name} (ID: ${file.id})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📁 百度网盘 - 目标路径: $destPath',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '👤 百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      final success = await BaiduCloudDriveService.copyFile(
        account: account,
        file: file,
        destPath: destPath,
        newName: newName,
      );

      if (success) {
        DebugService.log(
          '✅ 百度网盘 - 文件复制成功',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 百度网盘 - 文件复制失败',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      }

      return success;
    } catch (e) {
      DebugService.error(
        '❌ 百度网盘 - 复制文件异常',
        e,
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    DebugService.log(
      '📁 百度网盘 - 创建文件夹开始',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📁 百度网盘 - 文件夹名称: $folderName',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📁 百度网盘 - 父文件夹ID: $parentFolderId',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      final folder = await BaiduCloudDriveService.createFolder(
        account: account,
        folderName: folderName,
        parentPath: parentFolderId ?? '/',
      );

      if (folder != null) {
        DebugService.log(
          '✅ 百度网盘 - 文件夹创建成功: ${folder.name}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );

        return {'success': true, 'folder': folder, 'message': '文件夹创建成功'};
      } else {
        DebugService.log(
          '❌ 百度网盘 - 文件夹创建失败',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );

        return {'success': false, 'message': '文件夹创建失败'};
      }
    } catch (e) {
      DebugService.error(
        '❌ 百度网盘 - 创建文件夹异常',
        e,
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      return {'success': false, 'message': '文件夹创建异常: $e'};
    }
  }

  @override
  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    DebugService.log(
      '📋 百度网盘 - 获取账号详情开始',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '👤 百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      final accountDetails = await BaiduCloudDriveService.getAccountDetails(
        account: account,
      );

      if (accountDetails != null) {
        DebugService.log(
          '✅ 百度网盘 - 账号详情获取成功',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        DebugService.log(
          '📊 用户名: ${accountDetails.accountInfo.username}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        DebugService.log(
          '📊 会员状态: ${accountDetails.accountInfo.vipStatusDescription}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        DebugService.log(
          '📊 存储使用情况: ${accountDetails.quotaInfo.formattedUsed} / ${accountDetails.quotaInfo.formattedTotal} (${accountDetails.quotaInfo.usagePercentage.toStringAsFixed(1)}%)',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 百度网盘 - 账号详情获取失败: 返回null',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      }

      return accountDetails;
    } catch (e) {
      DebugService.error(
        '❌ 百度网盘 - 获取账号详情异常',
        e,
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return null;
    }
  }

  @override
  String convertPathToTargetFolderId(List<PathInfo> folderPath) {
    if (folderPath.isEmpty) {
      return '/';
    }
    // 百度网盘的path.id已经是完整路径（如 /来自：　　），直接使用最后一个
    return folderPath.last.id;
  }

  @override
  CloudDriveFile updateFilePathForTargetDirectory(
    CloudDriveFile file,
    String targetPath,
  ) {
    DebugService.log(
      '🔄 百度网盘 - 更新文件路径为目标目录',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📄 原文件: ${file.name} (ID: ${file.id})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📁 目标路径: $targetPath',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    if (file.isFolder) {
      // 文件夹：id是完整路径
      final newId =
          targetPath.endsWith('/')
              ? '$targetPath${file.name}'
              : '$targetPath/${file.name}';
      final updatedFile = file.copyWith(id: newId, folderId: targetPath);

      DebugService.log(
        '📁 文件夹路径更新: ${file.id} -> ${updatedFile.id}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      return updatedFile;
    } else {
      // 文件：folderId是当前目录路径
      final updatedFile = file.copyWith(folderId: targetPath);

      DebugService.log(
        '📄 文件路径更新: folderId ${file.folderId} -> ${updatedFile.folderId}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      return updatedFile;
    }
  }

  @override
  Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? path,
    String? folderId,
  }) async {
    try {
      DebugService.log(
        '📁 百度网盘 - 获取文件列表: path=$path, folderId=$folderId',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      // 使用百度网盘服务获取文件列表
      final result = await BaiduCloudDriveService.getFileList(
        account: account,
        folderId: folderId ?? '/',
      );

      // 合并文件和文件夹列表
      final allFiles = <CloudDriveFile>[];
      allFiles.addAll(result['folders'] ?? []);
      allFiles.addAll(result['files'] ?? []);

      DebugService.log(
        '✅ 百度网盘 - 文件列表获取完成: ${allFiles.length} 个文件',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      return allFiles;
    } catch (e) {
      DebugService.log(
        '❌ 百度网盘 - 获取文件列表异常: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return [];
    }
  }
}
