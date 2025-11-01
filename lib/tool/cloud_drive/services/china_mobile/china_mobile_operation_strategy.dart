import 'dart:convert';

import '../../../../../core/logging/log_manager.dart';
import '../../base/cloud_drive_operation_service.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import 'core/china_mobile_config.dart';
import 'services/china_mobile_download_service.dart';
import 'services/china_mobile_file_list_service.dart';
import 'services/china_mobile_file_operation_service.dart';
import 'services/china_mobile_search_service.dart';
import 'package:dio/dio.dart';

/// 中国移动云盘操作策略
///
/// 实现 CloudDriveOperationStrategy 接口，提供中国移动云盘特定的操作实现。
/// 参考 alist-main/drivers/139 的实现。
class ChinaMobileCloudDriveOperationStrategy
    implements CloudDriveOperationStrategy {
  @override
  Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? path,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      LogManager().cloudDrive('中国移动云盘 - 获取文件列表: folderId=$folderId');

      final files = await ChinaMobileFileListService.getFileList(
        account: account,
        parentFileId: folderId ?? ChinaMobileConfig.rootFolderId,
        pageSize: pageSize,
      );

      LogManager().cloudDrive('中国移动云盘 - 文件列表获取完成: ${files.length} 个文件');

      return files;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('中国移动云盘 - 获取文件列表异常: $e');
      LogManager().cloudDrive('错误堆栈: $stackTrace');
      return [];
    }
  }

  @override
  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    try {
      LogManager().cloudDrive('中国移动云盘 - 获取账号详情开始');

      // 从 Authorization Token 中解析用户信息
      String? username;
      if (account.authorizationToken != null &&
          account.authorizationToken!.isNotEmpty) {
        username = _extractUsernameFromAuthToken(account.authorizationToken!);
      }

      // 创建账号信息对象
      final accountInfo = CloudDriveAccountInfo(
        username: username ?? account.name,
        uk: 0,
        isVip: false,
        isSvip: false,
        loginState: 1,
      );

      // 中国移动云盘没有容量信息，返回null
      final accountDetails = CloudDriveAccountDetails(
        id: account.id,
        name: account.name,
        accountInfo: accountInfo,
        quotaInfo: null,
      );

      LogManager().cloudDrive('中国移动云盘 - 账号详情获取成功: ${accountInfo.username}');
      return accountDetails;
    } catch (e) {
      LogManager().cloudDrive('中国移动云盘 - 获取账号详情异常: $e');
      return null;
    }
  }

  /// 从 Authorization Token 中提取用户名
  ///
  /// 中国移动云盘的 Authorization token 是 base64 编码的字符串
  /// 格式: base64(userType:account:token|expiration|...|...)
  String? _extractUsernameFromAuthToken(String authToken) {
    try {
      // 解码 base64
      final decoded = base64Decode(authToken);
      final decodedStr = utf8.decode(decoded);

      // 解析账号信息
      final splits = decodedStr.split(':');
      if (splits.length >= 2) {
        // 返回账号字段
        return splits[1];
      }
    } catch (e) {
      LogManager().cloudDrive('中国移动云盘 - 从Token中提取用户名失败: $e');
    }
    return null;
  }

  @override
  Future<List<CloudDriveFile>> searchFiles({
    required CloudDriveAccount account,
    required String keyword,
    String? folderId,
    int page = 1,
    int pageSize = 50,
    String? fileType,
  }) async {
    try {
      LogManager().cloudDrive('中国移动云盘 - 搜索文件: $keyword');

      final files = await ChinaMobileSearchService.searchFile(
        account: account,
        keyword: keyword,
        parentFileId: folderId,
      );

      // 如果指定了文件类型，进行筛选
      List<CloudDriveFile> filteredFiles = files;
      if (fileType != null) {
        if (fileType == 'file') {
          filteredFiles = files.where((f) => !f.isFolder).toList();
        } else if (fileType == 'folder') {
          filteredFiles = files.where((f) => f.isFolder).toList();
        }
      }

      LogManager().cloudDrive('中国移动云盘 - 搜索完成: 找到 ${filteredFiles.length} 个文件');

      return filteredFiles;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('中国移动云盘 - 搜索文件异常: $e');
      LogManager().cloudDrive('错误堆栈: $stackTrace');
      return [];
    }
  }

  @override
  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      LogManager().cloudDrive('中国移动云盘 - 获取下载链接: ${file.name}');

      final downloadUrl = await ChinaMobileDownloadService.getDownloadUrl(
        account: account,
        file: file,
      );

      if (downloadUrl != null) {
        LogManager().cloudDrive('中国移动云盘 - 下载链接获取成功');
      } else {
        LogManager().cloudDrive('中国移动云盘 - 下载链接获取失败');
      }

      return downloadUrl;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('中国移动云盘 - 获取下载链接异常: $e');
      LogManager().cloudDrive('错误堆栈: $stackTrace');
      return null;
    }
  }

  @override
  Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    try {
      LogManager().cloudDrive('中国移动云盘 - 高速下载: ${file.name}');

      // TODO: 实现中国移动云盘高速下载
      return null;
    } catch (e) {
      LogManager().error('中国移动云盘高速下载失败: $e');
      return null;
    }
  }

  @override
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    try {
      LogManager().cloudDrive('中国移动云盘 - 生成分享链接');

      // TODO: 实现中国移动云盘分享链接生成
      return null;
    } catch (e) {
      LogManager().error('中国移动云盘生成分享链接失败: $e');
      return null;
    }
  }

  @override
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    try {
      LogManager().cloudDrive('中国移动云盘 - 移动文件: ${file.name}');

      final success = await ChinaMobileFileOperationService.moveFile(
        account: account,
        file: file,
        targetFolderId: targetFolderId ?? ChinaMobileConfig.rootFolderId,
      );

      return success;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('中国移动云盘 - 移动文件异常: $e');
      LogManager().cloudDrive('错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      LogManager().cloudDrive('中国移动云盘 - 删除文件: ${file.name}');

      final success = await ChinaMobileFileOperationService.deleteFile(
        account: account,
        file: file,
      );

      return success;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('中国移动云盘 - 删除文件异常: $e');
      LogManager().cloudDrive('错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    try {
      LogManager().cloudDrive('中国移动云盘 - 重命名文件: ${file.name} -> $newName');

      final success = await ChinaMobileFileOperationService.renameFile(
        account: account,
        file: file,
        newName: newName,
      );

      return success;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('中国移动云盘 - 重命名文件异常: $e');
      LogManager().cloudDrive('错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String destPath,
    String? newName,
  }) async {
    try {
      LogManager().cloudDrive('中国移动云盘 - 复制文件: ${file.name} -> $destPath');

      final success = await ChinaMobileFileOperationService.copyFile(
        account: account,
        file: file,
        targetFolderId: destPath,
      );

      return success;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('中国移动云盘 - 复制文件异常: $e');
      LogManager().cloudDrive('错误堆栈: $stackTrace');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    try {
      LogManager().cloudDrive('中国移动云盘 - 创建文件夹: $folderName');

      // TODO: 实现中国移动云盘创建文件夹功能
      return null;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('中国移动云盘 - 创建文件夹异常: $e');
      LogManager().cloudDrive('错误堆栈: $stackTrace');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String? folderId,
  }) async {
    LogManager().cloudDrive('中国移动云盘 - 上传文件开始');
    LogManager().cloudDrive('文件路径: $filePath');
    LogManager().cloudDrive('文件名: $fileName');
    LogManager().cloudDrive(
      '文件夹ID: ${folderId ?? ChinaMobileConfig.rootFolderId}',
    );

    try {
      // TODO: 实现中国移动云盘上传功能
      LogManager().cloudDrive('中国移动云盘 - 上传功能暂未实现');
      return {'success': false, 'message': '中国移动云盘上传功能暂未实现'};
    } catch (e, stackTrace) {
      LogManager().cloudDrive('中国移动云盘 - 上传文件异常: $e');
      LogManager().cloudDrive('错误堆栈: $stackTrace');
      return {'success': false, 'message': e.toString()};
    }
  }

  @override
  Map<String, bool> getSupportedOperations() => {
    'download': true,
    'share': false,
    'move': true,
    'delete': true,
    'rename': true,
    'copy': true,
    'createFolder': false,
  };

  @override
  Map<String, dynamic> getOperationUIConfig() => {
    'showDownloadButton': true,
    'showShareButton': false,
    'showMoveButton': true,
    'showDeleteButton': true,
    'showRenameButton': true,
    'showCopyButton': true,
  };

  @override
  String convertPathToTargetFolderId(List<PathInfo> folderPath) {
    if (folderPath.isEmpty) {
      return ChinaMobileConfig.rootFolderId;
    }
    return folderPath.last.id;
  }

  @override
  CloudDriveFile updateFilePathForTargetDirectory(
    CloudDriveFile file,
    String targetPath,
  ) {
    // 中国移动云盘暂时返回原文件，不需要路径更新
    return file;
  }

  @override
  Future<CloudDriveAccount?> refreshAuth({
    required CloudDriveAccount account,
  }) async {
    try {
      LogManager().cloudDrive('中国移动云盘 - 刷新鉴权开始');
      LogManager().cloudDrive(
        '中国移动云盘 - 账号信息: ${account.name} (${account.type.displayName})',
      );

      // 参考 alist-main/drivers/139/util.go 中的 refreshToken 实现
      // 如果使用 authorizationToken（base64编码），需要解析并刷新
      if (account.authorizationToken != null &&
          account.authorizationToken!.isNotEmpty) {
        return await _refreshAuthorizationToken(account);
      }

      // 如果使用 cookies，尝试验证有效性
      if (account.cookies != null && account.cookies!.isNotEmpty) {
        // 通过尝试获取文件列表来验证 cookies 是否有效
        try {
          final files = await getFileList(
            account: account,
            folderId: ChinaMobileConfig.rootFolderId,
            page: 1,
            pageSize: 1,
          );
          if (files.isNotEmpty) {
            // Cookies 仍然有效，无需刷新
            LogManager().cloudDrive('中国移动云盘 - Cookies仍然有效，无需刷新');
            return account;
          }
        } catch (e) {
          LogManager().cloudDrive('中国移动云盘 - Cookies验证失败: $e');
        }
      }

      // 认证已失效，需要重新登录
      LogManager().warning('中国移动云盘 - 鉴权已失效，需要重新登录');
      return null;
    } catch (e, stackTrace) {
      LogManager().error('中国移动云盘 - 刷新鉴权失败: $e');
      LogManager().error('错误堆栈: $stackTrace');
      return null;
    }
  }

  /// 刷新 Authorization Token
  ///
  /// 参考 alist-main/drivers/139/util.go 中的 refreshToken 实现
  /// Authorization 格式: base64(userType:account:token|expiration|...|...)
  Future<CloudDriveAccount?> _refreshAuthorizationToken(
    CloudDriveAccount account,
  ) async {
    try {
      final authorization = account.authorizationToken!;

      // 1. 解码 base64
      String decodedStr;
      try {
        final decoded = base64Decode(authorization);
        decodedStr = utf8.decode(decoded);
      } catch (e) {
        LogManager().error('中国移动云盘 - Authorization解码失败: $e');
        return null;
      }

      // 2. 解析账号和token信息
      final splits = decodedStr.split(':');
      if (splits.length < 3) {
        LogManager().error('中国移动云盘 - Authorization格式无效: splits < 3');
        return null;
      }

      final userType = splits[0];
      final accountName = splits[1];
      final tokenParts = splits[2].split('|');

      if (tokenParts.length < 4) {
        LogManager().error('中国移动云盘 - Token格式无效: tokenParts < 4');
        return null;
      }

      final token = tokenParts[0];
      final expirationStr = tokenParts[3];

      // 3. 检查过期时间
      int? expiration;
      try {
        expiration = int.parse(expirationStr);
      } catch (e) {
        LogManager().error('中国移动云盘 - 过期时间解析失败: $e');
        return null;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final expirationMs = expiration - now;

      // 如果有效期大于15天，无需刷新
      const fifteenDaysMs = 1000 * 60 * 60 * 24 * 15;
      if (expirationMs > fifteenDaysMs) {
        LogManager().cloudDrive('中国移动云盘 - Token有效期大于15天，无需刷新');
        return account;
      }

      // 如果已过期，无法刷新
      if (expirationMs < 0) {
        LogManager().error('中国移动云盘 - Token已过期，无法刷新');
        return null;
      }

      // 4. 调用刷新API
      final refreshUrl =
          'https://aas.caiyun.feixin.10086.cn:443/tellin/authTokenRefresh.do';

      final reqBody =
          '<root><token>$token</token><account>$accountName</account><clienttype>656</clienttype></root>';

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final response = await dio.post(
        refreshUrl,
        data: reqBody,
        options: Options(
          headers: {'Content-Type': 'application/xml'},
          responseType: ResponseType.plain,
        ),
      );

      // 5. 解析响应（XML格式）
      // 响应格式: <root><return>0</return><token>...</token><expiretime>...</expiretime><accessToken>...</accessToken><desc>...</desc></root>
      final responseXml = response.data.toString();
      if (!responseXml.contains('<return>0</return>')) {
        final descMatch = RegExp(r'<desc>(.*?)</desc>').firstMatch(responseXml);
        final desc = descMatch?.group(1) ?? '未知错误';
        LogManager().error('中国移动云盘 - Token刷新失败: $desc');
        return null;
      }

      // 提取新token
      final tokenMatch = RegExp(
        r'<token>(.*?)</token>',
      ).firstMatch(responseXml);
      if (tokenMatch == null) {
        LogManager().error('中国移动云盘 - 无法从响应中提取新token');
        return null;
      }

      final newToken = tokenMatch.group(1)!;

      // 6. 构建新的 Authorization（保持原有的 token 结构，只替换 token 部分）
      final newTokenParts = List<String>.from(tokenParts);
      newTokenParts[0] = newToken;
      final newTokenStr = newTokenParts.join('|');
      final newAuthorization = base64Encode(
        utf8.encode('$userType:$accountName:$newTokenStr'),
      );

      // 7. 返回更新后的账号对象
      final refreshedAccount = CloudDriveAccount(
        id: account.id,
        name: account.name,
        type: account.type,
        cookies: account.cookies,
        authorizationToken: newAuthorization,
        qrCodeToken: account.qrCodeToken,
        avatarUrl: account.avatarUrl,
        driveId: account.driveId,
        createdAt: account.createdAt,
        lastLoginAt: DateTime.now(),
      );

      LogManager().cloudDrive('中国移动云盘 - Token刷新成功');
      return refreshedAccount;
    } catch (e, stackTrace) {
      LogManager().error('中国移动云盘 - 刷新Authorization Token失败: $e');
      LogManager().error('错误堆栈: $stackTrace');
      return null;
    }
  }
}
