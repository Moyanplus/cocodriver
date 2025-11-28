import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../../core/logging/log_manager.dart';
import '../../base/cloud_drive_operation_service.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import 'baidu_cloud_drive_service.dart';
import 'baidu_repository.dart';
// import 'baidu_config.dart'; // 未使用

/// 百度网盘操作策略
///
/// 实现 CloudDriveOperationStrategy 接口，提供百度网盘特定的操作实现。
class BaiduCloudDriveOperationStrategy implements CloudDriveOperationStrategy {
  BaiduCloudDriveOperationStrategy();

  final BaiduRepository _repository = BaiduRepository();
  /// 获取文件下载链接
  ///
  /// [account] 百度网盘账号信息
  /// [file] 要下载的文件
  @override
  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    LogManager().cloudDrive('百度网盘 - 获取下载链接开始');
    LogManager().cloudDrive('百度网盘 - 文件信息: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive(
      '百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
    );

    try {
      final downloadUrl = await _repository.getDirectLink(
        account: account,
        file: file,
      );

      if (downloadUrl != null) {
        final preview =
            downloadUrl.length > 50
                ? '${downloadUrl.substring(0, 50)}...'
                : downloadUrl;
        LogManager().cloudDrive('百度网盘 - 下载链接获取成功: $preview');
      } else {
        LogManager().cloudDrive('百度网盘 - 下载链接获取失败: 返回null');
      }

      return downloadUrl;
    } catch (e) {
      LogManager().error('百度网盘 - 获取下载链接异常');
      rethrow;
    }
  }

  /// 获取高速下载链接
  ///
  /// 使用第三方解析服务获取百度网盘文件的直接下载链接
  /// 支持分享链接和提取密码的解析
  ///
  /// [account] 百度网盘账号信息
  /// [file] 要下载的文件
  /// [shareUrl] 分享链接
  /// [password] 提取密码
  /// 返回下载链接列表，如果解析失败则返回null
  @override
  Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    LogManager().cloudDrive('百度网盘 - 开始高速下载解析');
    LogManager().cloudDrive('百度网盘 - 文件信息: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive('百度网盘 - 分享链接: $shareUrl');
    LogManager().cloudDrive('🔑 百度网盘 - 提取密码: $password');
    LogManager().cloudDrive(
      '百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
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

      LogManager().cloudDrive(
        '百度网盘 - 文件列表响应状态码: ${fileListResponse.statusCode}',
      );
      LogManager().cloudDrive('百度网盘 - 文件列表响应内容: ${fileListResponse.data}');

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

      LogManager().cloudDrive(
        '百度网盘 - 找到匹配文件: ${targetFile['server_filename']}',
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

      LogManager().cloudDrive(
        '百度网盘 - 下载链接响应状态码: ${downloadResponse.statusCode}',
      );
      LogManager().cloudDrive('百度网盘 - 下载链接响应内容: ${downloadResponse.data}');

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

      LogManager().cloudDrive('百度网盘 - 高速下载链接获取成功，共 ${downloadUrls.length} 个链接');
      return downloadUrls;
    } catch (e) {
      LogManager().error('百度网盘 - 高速下载解析失败');
      rethrow;
    }
  }

  /// 提取百度网盘链接的surl
  ///
  /// 从百度网盘分享链接中提取surl参数
  ///
  /// [url] 百度网盘分享链接
  /// 返回提取的surl字符串
  String _extractBaiduSurl(String url) {
    final pattern = RegExp(r'https://pan\.baidu\.com/s/([a-zA-Z0-9_-]+)');
    final match = pattern.firstMatch(url);
    return match?.group(1) ?? '';
  }

  /// 生成随机字符串
  ///
  /// 生成指定长度的随机字符串，用于API请求参数
  ///
  /// [length] 字符串长度
  /// 返回生成的随机字符串
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      length,
      (index) => chars[DateTime.now().millisecondsSinceEpoch % chars.length],
    ).join();
  }

  /// 创建分享链接
  ///
  /// 为指定的文件创建百度网盘分享链接
  ///
  /// [account] 百度网盘账号信息
  /// [files] 要分享的文件列表
  /// [password] 分享密码（可选）
  /// [expireDays] 有效期天数（可选）
  /// 返回分享链接，如果创建失败则返回null
  @override
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    LogManager().cloudDrive('百度网盘 - 生成分享链接开始');
    LogManager().cloudDrive('百度网盘 - 文件数量: ${files.length}');
    LogManager().cloudDrive('🔑 百度网盘 - 提取码: ${password ?? '无'}');
    LogManager().cloudDrive('百度网盘 - 有效期: ${expireDays ?? 1}天');
    LogManager().cloudDrive(
      '百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
    );

    try {
      final fileIds = files.map((f) => f.id).toList();
      LogManager().cloudDrive('百度网盘 - 文件ID列表: $fileIds');

      final shareLink = await _repository.createShareLink(
        account: account,
        files: files,
        password: password,
        expireDays: expireDays,
      );

      if (shareLink != null) {
        final preview =
            shareLink.length > 50
                ? '${shareLink.substring(0, 50)}...'
                : shareLink;
        LogManager().cloudDrive('百度网盘 - 分享链接生成成功: $preview');
      } else {
        LogManager().cloudDrive('百度网盘 - 分享链接生成失败: 返回null');
      }

      return shareLink;
    } catch (e) {
      LogManager().error('百度网盘 - 生成分享链接异常');
      rethrow;
    }
  }

  /// 移动文件
  ///
  /// 将文件移动到指定的目标文件夹
  ///
  /// [account] 百度网盘账号信息
  /// [file] 要移动的文件
  /// [targetFolderId] 目标文件夹ID（可选，默认为根目录）
  /// 返回操作是否成功
  @override
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    LogManager().cloudDrive('百度网盘 - 移动文件开始');
    LogManager().cloudDrive('百度网盘 - 文件信息: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive('百度网盘 - 目标文件夹ID: ${targetFolderId ?? '根目录'}');
    LogManager().cloudDrive(
      '百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
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

      LogManager().cloudDrive('百度网盘 - 文件路径: $filePath');

      final success = await _repository.move(
        account: account,
        file: file,
        targetFolderId: targetFolderId ?? '/',
      );

      if (success) {
        LogManager().cloudDrive('百度网盘 - 文件移动成功');
      } else {
        LogManager().cloudDrive('百度网盘 - 文件移动失败');
      }

      return success;
    } catch (e) {
      LogManager().error('百度网盘 - 移动文件异常');
      rethrow;
    }
  }

  /// 删除文件
  ///
  /// 删除指定的文件或文件夹
  ///
  /// [account] 百度网盘账号信息
  /// [file] 要删除的文件
  /// 返回操作是否成功
  @override
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    LogManager().cloudDrive('百度网盘 - 删除文件开始');
    LogManager().cloudDrive('百度网盘 - 文件信息: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive(
      '百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
    );

    try {
      final success = await _repository.delete(account: account, file: file);

      if (success) {
        LogManager().cloudDrive('百度网盘 - 文件删除成功');
      } else {
        LogManager().cloudDrive('百度网盘 - 文件删除失败');
      }

      return success;
    } catch (e) {
      LogManager().error('百度网盘 - 删除文件异常');
      rethrow;
    }
  }

  /// 重命名文件
  ///
  /// 重命名指定的文件或文件夹
  ///
  /// [account] 百度网盘账号信息
  /// [file] 要重命名的文件
  /// [newName] 新的文件名
  /// 返回操作是否成功
  @override
  Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    LogManager().cloudDrive('百度网盘 - 重命名文件开始');
    LogManager().cloudDrive('百度网盘 - 文件信息: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive('百度网盘 - 新文件名: $newName');
    LogManager().cloudDrive(
      '百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
    );

    try {
      final success = await _repository.rename(
        account: account,
        file: file,
        newName: newName,
      );

      if (success) {
        LogManager().cloudDrive('百度网盘 - 文件重命名成功');
      } else {
        LogManager().cloudDrive('百度网盘 - 文件重命名失败');
      }

      return success;
    } catch (e) {
      LogManager().error('百度网盘 - 重命名文件异常');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String? folderId,
    UploadProgressCallback? onProgress,
  }) async {
    LogManager().cloudDrive('百度网盘 - 上传文件开始');
    LogManager().cloudDrive('文件路径: $filePath');
    LogManager().cloudDrive('文件名: $fileName');
    LogManager().cloudDrive('文件夹ID: ${folderId ?? '根目录'}');

    try {
      // TODO: 实现百度网盘上传功能
      LogManager().cloudDrive('百度网盘 - 上传功能暂未实现');
      return {'success': false, 'message': '百度网盘上传功能暂未实现'};
    } catch (e, stackTrace) {
      LogManager().cloudDrive('百度网盘 - 上传文件异常: $e');
      LogManager().cloudDrive('百度网盘 - 错误堆栈: $stackTrace');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// 获取支持的操作
  ///
  /// 返回百度网盘支持的所有操作类型
  ///
  /// 返回操作类型和是否支持的映射
  @override
  Map<String, bool> getSupportedOperations() {
    LogManager().cloudDrive('百度网盘 - 获取支持的操作');
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
    LogManager().cloudDrive('百度网盘 - 支持的操作: $operations');
    return operations;
  }

  /// 获取操作UI配置
  ///
  /// 返回百度网盘操作相关的UI配置信息
  ///
  /// 返回UI配置映射
  @override
  Map<String, dynamic> getOperationUIConfig() {
    LogManager().cloudDrive('百度网盘 - 获取UI配置');
    final config = {
      'share_password_hint': '提取码（必填，默认0000）',
      'share_expire_options': [
        {'label': '1天', 'value': 1},
        {'label': '7天', 'value': 7},
        {'label': '30天', 'value': 30},
        {'label': '永久', 'value': 0},
      ],
    };
    LogManager().cloudDrive('百度网盘 - UI配置: $config');
    return config;
  }

  /// 复制文件
  ///
  /// 将文件复制到指定的目标路径
  ///
  /// [account] 百度网盘账号信息
  /// [file] 要复制的文件
  /// [destPath] 目标路径
  /// [newName] 新文件名（可选）
  /// 返回操作是否成功
  @override
  Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String destPath,
    String? newName,
  }) async {
    LogManager().cloudDrive('百度网盘 - 复制文件开始');
    LogManager().cloudDrive('百度网盘 - 文件信息: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive('百度网盘 - 目标路径: $destPath');
    LogManager().cloudDrive(
      '百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
    );

    try {
      final success = await _repository.copy(
        account: account,
        file: file,
        targetFolderId: destPath,
      );

      if (success) {
        LogManager().cloudDrive('百度网盘 - 文件复制成功');
      } else {
        LogManager().cloudDrive('百度网盘 - 文件复制失败');
      }

      return success;
    } catch (e) {
      LogManager().error('百度网盘 - 复制文件异常');
      rethrow;
    }
  }

  /// 创建文件夹
  ///
  /// 在指定位置创建新的文件夹
  ///
  /// [account] 百度网盘账号信息
  /// [folderName] 文件夹名称
  /// [parentFolderId] 父文件夹ID（可选）
  /// 返回创建的文件夹信息，如果创建失败则返回null
  @override
  Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    LogManager().cloudDrive('百度网盘 - 创建文件夹开始');
    LogManager().cloudDrive('百度网盘 - 文件夹名称: $folderName');
    LogManager().cloudDrive('百度网盘 - 父文件夹ID: $parentFolderId');

    try {
      final created = await _repository.createFolder(
        account: account,
        name: folderName,
        parentId: parentFolderId,
      );

      if (created != null) {
        LogManager().cloudDrive('百度网盘 - 文件夹创建成功: $folderName');

        return {'success': true, 'message': '文件夹创建成功'};
      } else {
        LogManager().cloudDrive('百度网盘 - 文件夹创建失败');

        return {'success': false, 'message': '文件夹创建失败'};
      }
    } catch (e) {
      LogManager().error('百度网盘 - 创建文件夹异常');

      return {'success': false, 'message': '文件夹创建异常: $e'};
    }
  }

  /// 获取账号详情
  ///
  /// 获取百度网盘账号的详细信息，包括用户信息、存储使用情况等
  ///
  /// [account] 百度网盘账号信息
  /// 返回账号详情，如果获取失败则返回null
  @override
  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    LogManager().cloudDrive('百度网盘 - 获取账号详情开始');
    LogManager().cloudDrive(
      '百度网盘 - 账号信息: ${account.name} (${account.type.displayName})',
    );

    try {
      final accountDetails = await BaiduCloudDriveService.getAccountDetails(
        account: account,
      );

      if (accountDetails != null) {
        LogManager().cloudDrive('百度网盘 - 账号详情获取成功');
        LogManager().cloudDrive(
          '用户名: ${accountDetails.accountInfo?.username ?? '未知用户'}',
        );
        LogManager().cloudDrive(
          '会员状态: ${accountDetails.accountInfo?.vipStatusDescription ?? '未知状态'}',
        );
        LogManager().cloudDrive(
          '存储使用情况: ${accountDetails.quotaInfo?.formattedUsed ?? '0B'} / ${accountDetails.quotaInfo?.formattedTotal ?? '0B'} (${accountDetails.quotaInfo?.usagePercentage.toStringAsFixed(1) ?? '0.0'}%)',
        );
      } else {
        LogManager().cloudDrive('百度网盘 - 账号详情获取失败: 返回null');
      }

      return accountDetails;
    } catch (e) {
      LogManager().error('百度网盘 - 获取账号详情异常');
      return null;
    }
  }

  /// 转换路径为目标文件夹ID
  ///
  /// 将路径信息列表转换为百度网盘的目标文件夹ID
  ///
  /// [folderPath] 路径信息列表
  /// 返回目标文件夹ID
  @override
  String convertPathToTargetFolderId(List<PathInfo> folderPath) {
    if (folderPath.isEmpty) {
      return '/';
    }
    // 百度网盘的path.id已经是完整路径（如 /来自：　　），直接使用最后一个
    return folderPath.last.id;
  }

  /// 更新文件路径为目标目录
  ///
  /// 更新文件对象，使其指向目标目录
  ///
  /// [file] 要更新的文件
  /// [targetPath] 目标路径
  /// 返回更新后的文件对象
  @override
  CloudDriveFile updateFilePathForTargetDirectory(
    CloudDriveFile file,
    String targetPath,
  ) {
    LogManager().cloudDrive('百度网盘 - 更新文件路径为目标目录');
    LogManager().cloudDrive('原文件: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive('目标路径: $targetPath');

    if (file.isFolder) {
      // 文件夹：id是完整路径
      final newId =
          targetPath.endsWith('/')
              ? '$targetPath${file.name}'
              : '$targetPath/${file.name}';
      final updatedFile = file.copyWith(id: newId, folderId: targetPath);

      LogManager().cloudDrive('文件夹路径更新: ${file.id} -> ${updatedFile.id}');

      return updatedFile;
    } else {
      // 文件：folderId是当前目录路径
      final updatedFile = file.copyWith(folderId: targetPath);

      LogManager().cloudDrive(
        '文件路径更新: folderId ${file.folderId} -> ${updatedFile.folderId}',
      );

      return updatedFile;
    }
  }

  /// 获取文件列表
  ///
  /// 获取指定文件夹下的文件和文件夹列表
  ///
  /// [account] 百度网盘账号信息
  /// [path] 路径（可选）
  /// [folderId] 文件夹ID（可选）
  /// [page] 页码（默认1）
  /// [pageSize] 每页大小（默认50）
  /// 返回文件列表
  @override
  Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? path,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      LogManager().cloudDrive('百度网盘 - 获取文件列表: path=$path, folderId=$folderId');

      // 使用百度网盘服务获取文件列表
      final result = await BaiduCloudDriveService.getFileList(
        account: account,
        folderId: folderId ?? '/',
        page: page,
        pageSize: pageSize,
      );

      // 合并文件和文件夹列表
      final allFiles = <CloudDriveFile>[];
      allFiles.addAll(result['folders'] ?? []);
      allFiles.addAll(result['files'] ?? []);

      LogManager().cloudDrive('百度网盘 - 文件列表获取完成: ${allFiles.length} 个文件');

      return allFiles;
    } catch (e) {
      LogManager().cloudDrive('百度网盘 - 获取文件列表异常: $e');
      return [];
    }
  }

  /// 搜索文件
  ///
  /// [account] 百度网盘账号信息
  /// [keyword] 搜索关键词
  /// [folderId] 可选，在指定文件夹内搜索
  /// [page] 页码，默认第1页
  /// [pageSize] 每页数量，默认50
  /// [fileType] 可选，文件类型筛选
  /// 返回符合条件的文件列表
  @override
  Future<List<CloudDriveFile>> searchFiles({
    required CloudDriveAccount account,
    required String keyword,
    String? folderId,
    int page = 1,
    int pageSize = 50,
    String? fileType,
  }) async {
    LogManager().cloudDrive('百度网盘 - 搜索文件功能暂未实现');
    return [];
  }

  /// 刷新鉴权信息
  ///
  /// [account] 百度网盘账号信息
  /// 返回刷新后的账号信息，如果刷新失败返回null
  @override
  Future<CloudDriveAccount?> refreshAuth({
    required CloudDriveAccount account,
  }) async {
    LogManager().cloudDrive('百度网盘 - 刷新鉴权信息功能暂未实现');
    return null;
  }
}
