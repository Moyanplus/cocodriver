import 'dart:io'; // Added for File

import 'package:dio/dio.dart';

import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import 'lanzou_base_service.dart';
import 'lanzou_config.dart';
import 'lanzou_direct_link_service.dart';
import 'lanzou_vei_service.dart';

/// 蓝奏云盘 API 服务
/// 专门处理蓝奏云盘的 API 调用
class LanzouCloudDriveService {
  /// 统一错误处理
  static void _handleError(
    String operation,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    LogManager().cloudDrive('❌ 蓝奏云盘 - $operation 失败: $error');
    if (stackTrace != null) {
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
    }
  }

  /// 统一日志记录
  static void _logInfo(String message, {Map<String, dynamic>? params}) {
    LogManager().cloudDrive(message);
  }

  /// 统一成功日志记录
  static void _logSuccess(String message, {Map<String, dynamic>? details}) {
    LogManager().cloudDrive('✅ 蓝奏云盘 - $message');
  }

  /// 统一错误日志记录
  static void _logError(String message, dynamic error) {
    LogManager().cloudDrive('❌ 蓝奏云盘 - $message: $error');
  }

  // 创建dio实例 - 使用统一的基础服务
  static Dio _createDio(CloudDriveAccount account) =>
      LanzouBaseService.createDio(account);

  /// 创建临时账号对象
  static CloudDriveAccount _createTempAccount(String cookies) =>
      CloudDriveAccount(
        id: 'temp',
        name: 'temp',
        type: CloudDriveType.lanzou,
        createdAt: DateTime.now(),
        cookies: cookies,
      );

  /// 从 Cookie 中提取 UID
  static String? extractUidFromCookies(String cookies) {
    try {
      LogManager().cloudDrive('🔍 蓝奏云 - 开始从 Cookie 中提取 UID');
      LogManager().cloudDrive('🍪 蓝奏云 - 原始 Cookie 长度: ${cookies.length}');
      LogManager().cloudDrive('🍪 蓝奏云 - Cookie 预览: $cookies');

      final cookieMap = <String, String>{};

      // 清理 Cookie 字符串
      String cleanCookies = cookies.replaceAll('"', '').trim();
      LogManager().cloudDrive('🧹 蓝奏云 - 清理后的 Cookie: $cleanCookies');

      for (final cookie in cleanCookies.split(';')) {
        final trimmedCookie = cookie.trim();
        if (trimmedCookie.isEmpty) continue;

        final parts = trimmedCookie.split('=');
        if (parts.length >= 2) {
          final name = parts[0].trim();
          final value = parts.sublist(1).join('=').trim(); // 处理值中可能包含 = 的情况
          cookieMap[name] = value;
          LogManager().cloudDrive('🍪 蓝奏云 - 解析 Cookie: $name = $value');
        }
      }

      final uid = cookieMap['ylogin'];
      LogManager().cloudDrive('🔍 蓝奏云 - 从 Cookie 中提取到 UID: $uid');

      if (uid == null || uid.isEmpty) {
        LogManager().cloudDrive('❌ 蓝奏云 - 未找到 ylogin Cookie');
        LogManager().cloudDrive(
          '🔑 蓝奏云 - 所有 Cookie 键: ${cookieMap.keys.toList()}',
        );
        LogManager().cloudDrive('🍪 蓝奏云 - 所有 Cookie 值: $cookieMap');
      } else {
        LogManager().cloudDrive('✅ 蓝奏云 - 成功提取 UID: $uid');
      }

      return uid;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 蓝奏云 - 提取 UID 失败: $e');
      LogManager().cloudDrive('📄 蓝奏云 - 错误堆栈: $stackTrace');
      return null;
    }
  }

  /// 执行 API 请求的通用方法
  static Future<Map<String, dynamic>> _executeRequest({
    required CloudDriveAccount account,
    required Map<String, dynamic> data,
    required Map<String, String> headers,
  }) async {
    try {
      _logInfo('🌐 开始执行 API 请求');
      _logInfo('🌐 API URL: ${LanzouConfig.apiUrl}');
      _logInfo('🌐 请求数据: $data');

      final dio = _createDio(account);
      final response = await dio.post(
        LanzouConfig.apiUrl,
        data: FormData.fromMap(data),
        options: Options(
          headers: headers,
          followRedirects: LanzouConfig.followRedirects,
          maxRedirects: LanzouConfig.maxRedirects,
        ),
      );

      _logSuccess('API 请求成功');
      _logInfo('📡 响应状态码: ${response.statusCode}');

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        _logInfo('📊 响应数据类型: Map');
        _logInfo('📊 响应数据键: ${responseData.keys.toList()}');
        return responseData;
      } else {
        _logError('响应数据类型异常', '类型: ${response.data.runtimeType}');
        return {'zt': 0, 'info': '响应数据格式错误'};
      }
    } catch (e, stackTrace) {
      _handleError('API 请求', e, stackTrace);
      rethrow;
    }
  }

  /// 创建请求头
  static Map<String, String> _createHeaders(String cookies, String uid) {
    LogManager().cloudDrive('🔧 蓝奏云 - 创建请求头');
    LogManager().cloudDrive('👤 蓝奏云 - UID: $uid');
    LogManager().cloudDrive('🔧 蓝奏云 - Cookie 长度: ${cookies.length}');

    final headers = Map<String, String>.from(LanzouConfig.defaultHeaders);
    headers['Cookie'] = cookies;
    headers['Referer'] = '${LanzouConfig.baseUrl}/';
    headers['Origin'] = LanzouConfig.baseUrl;
    headers['X-Requested-With'] = 'XMLHttpRequest';

    LogManager().cloudDrive('🔧 蓝奏云 - 请求头创建完成');
    LogManager().cloudDrive('🔧 蓝奏云 - 请求头键: ${headers.keys.toList()}');

    return headers;
  }

  /// 获取文件列表
  static Future<List<CloudDriveFile>> getFiles({
    required String cookies,
    required String uid,
    String folderId = '-1',
  }) async {
    try {
      _logInfo('📁 获取文件列表: 文件夹ID=$folderId');

      // 初始化vei参数
      final vei = await LanzouVeiService.initializeVeiParameter(
        uid,
        cookies: cookies,
      );
      if (vei == null) {
        _logError('无法获取vei参数，使用默认值', 'vei参数获取失败');
      }

      // 使用配置中的任务ID和正确的文件夹ID
      final data = {
        'task': LanzouConfig.getTaskId('getFiles'),
        'folder_id': LanzouConfig.getFolderId(folderId),
        'vei': LanzouConfig.getVeiParameter(),
      };

      _logInfo('📡 文件请求数据: $data');

      final headers = _createHeaders(cookies, uid);

      final responseData = await _executeRequest(
        account: _createTempAccount(cookies),
        data: data,
        headers: headers,
      );

      if (responseData['zt'] == 1) {
        final List<dynamic> fileList = responseData['text'] ?? [];
        final List<CloudDriveFile> files = [];

        for (final file in fileList) {
          try {
            final id = file['id']?.toString() ?? '';
            final name = file['name']?.toString() ?? '';
            final size = int.tryParse(file['size']?.toString() ?? '0') ?? 0;
            final time = file['time']?.toString();

            final cloudFile = CloudDriveFile(
              id: id,
              name: name,
              size: size,
              modifiedTime: time != null ? DateTime.tryParse(time) : null,
              isFolder: false,
            );
            _logInfo('✅ 文件解析成功: ${cloudFile.name} (ID: ${cloudFile.id})');
            files.add(cloudFile);
          } catch (e) {
            _logError('失败的文件数据', file);
          }
        }

        _logSuccess('成功获取 ${files.length} 个文件');
        return files;
      } else {
        _logError('获取文件列表失败', '响应状态: zt=${responseData['zt']}');
        throw Exception('获取文件列表失败: ${responseData['info']}');
      }
    } catch (e) {
      _handleError('获取文件列表', e, null);
      rethrow;
    }
  }

  /// 获取文件夹列表
  static Future<List<CloudDriveFile>> getFolders({
    required String cookies,
    required String uid,
    String folderId = '-1',
  }) async {
    try {
      _logInfo('📁 获取文件夹列表: 文件夹ID=$folderId');

      // 初始化vei参数
      final vei = await LanzouVeiService.initializeVeiParameter(
        uid,
        cookies: cookies,
      );
      if (vei == null) {
        _logError('无法获取vei参数，使用默认值', 'vei参数获取失败');
      }

      // 使用配置中的任务ID和正确的文件夹ID
      final data = {
        'task': LanzouConfig.getTaskId('getFolders'),
        'folder_id': LanzouConfig.getFolderId(folderId),
        'vei': LanzouConfig.getVeiParameter(),
      };

      _logInfo('📡 文件夹请求数据: $data');

      final headers = _createHeaders(cookies, uid);

      final responseData = await _executeRequest(
        account: _createTempAccount(cookies),
        data: data,
        headers: headers,
      );

      if (responseData['zt'] == 1) {
        final List<dynamic> folderList = responseData['text'] ?? [];
        final List<CloudDriveFile> folders = [];

        for (final folder in folderList) {
          try {
            final id = folder['id']?.toString() ?? '';
            final name = folder['name']?.toString() ?? '';
            final time = folder['time']?.toString();

            final cloudFolder = CloudDriveFile(
              id: id,
              name: name,
              modifiedTime: time != null ? DateTime.tryParse(time) : null,
              isFolder: true,
            );
            _logInfo('✅ 文件夹解析成功: ${cloudFolder.name} (ID: ${cloudFolder.id})');
            folders.add(cloudFolder);
          } catch (e) {
            _logError('失败的文件夹数据', folder);
          }
        }

        _logSuccess('成功获取 ${folders.length} 个文件夹');
        return folders;
      } else {
        _logError('获取文件夹列表失败', '响应状态: zt=${responseData['zt']}');
        throw Exception('获取文件夹列表失败: ${responseData['info']}');
      }
    } catch (e) {
      _handleError('获取文件夹列表', e, null);
      rethrow;
    }
  }

  /// 验证 Cookie 有效性
  static Future<bool> validateCookies(String cookies, String uid) async {
    try {
      _logInfo('🔍 验证 Cookie 有效性');

      final data = {
        'task': LanzouConfig.getTaskId('validateCookies'),
        'folder_id': '-1',
        'pg': '1',
        'vei': LanzouConfig.getVeiParameter(),
      };

      final headers = _createHeaders(cookies, uid);

      final responseData = await _executeRequest(
        account: _createTempAccount(cookies),
        data: data,
        headers: headers,
      );

      final isValid = responseData['zt'] == 1;
      _logInfo('🔍 Cookie 验证结果: ${isValid ? '有效' : '无效'}');

      if (!isValid) {
        _logError('Cookie 验证失败', responseData['info']);
      }

      return isValid;
    } catch (e) {
      _logError('Cookie 验证异常', e);
      return false;
    }
  }

  /// 获取文件详情
  static Future<Map<String, dynamic>?> getFileDetail({
    required String cookies,
    required String uid,
    required String fileId,
  }) async {
    try {
      _logInfo('📄 获取文件详情: file_id=$fileId');

      final data = {
        'task': LanzouConfig.getTaskId('getFileDetail'),
        'file_id': fileId,
      };

      final headers = _createHeaders(cookies, uid);

      final responseData = await _executeRequest(
        account: _createTempAccount(cookies),
        data: data,
        headers: headers,
      );

      if (responseData['zt'] == 1) {
        final fileInfo = responseData['info'] as Map<String, dynamic>?;
        _logSuccess('成功获取文件详情');
        _logInfo('📄 文件详情: $fileInfo');
        return fileInfo;
      } else {
        _logError('获取文件详情失败', responseData['info']);
        return null;
      }
    } catch (e) {
      _logError('获取文件详情异常', e);
      return null;
    }
  }

  /// 解析蓝奏云直链
  static Future<Map<String, dynamic>?> parseDirectLink({
    required String shareUrl,
    String? password,
  }) async => await LanzouDirectLinkService.parseDirectLink(
    shareUrl: shareUrl,
    password: password,
  );

  /// 上传文件到蓝奏云
  static Future<Map<String, dynamic>> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String folderId = '-1',
  }) async {
    try {
      _logInfo('📤 开始上传文件: $fileName');
      _logInfo('📁 目标文件夹: $folderId');
      _logInfo('📂 文件路径: $filePath');

      // 获取文件信息
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }

      final fileSize = await file.length();
      final fileExtension = fileName.split('.').last.toLowerCase();
      final mimeType = LanzouConfig.getMimeType(fileExtension);

      _logInfo('📊 文件信息: 大小=${fileSize}字节, 类型=$mimeType');

      // 构建请求头
      if (account.cookies == null || account.cookies!.isEmpty) {
        throw Exception('账号未登录，无法上传文件');
      }

      final uid = extractUidFromCookies(account.cookies!);
      if (uid == null) {
        throw Exception('无法从Cookie中提取UID，请重新登录');
      }

      final headers = _createHeaders(account.cookies!, uid);
      headers['Content-Type'] = 'multipart/form-data';

      // 构建FormData
      final formData = FormData.fromMap({
        'task': LanzouConfig.getTaskId('uploadFile'),
        'vie': '2',
        've': '2',
        'id': 'WU_FILE_1',
        'name': fileName,
        'type': mimeType,
        'lastModifiedDate': DateTime.now().toIso8601String(),
        'size': fileSize.toString(),
        'folder_id_bb_n': folderId,
        'upload_file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      _logInfo('🌐 发送上传请求到: ${LanzouConfig.uploadUrl}');

      // 发送请求
      final response = await _createDio(account).post(
        LanzouConfig.uploadUrl,
        data: formData,
        options: Options(
          headers: headers,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      _logInfo('📥 上传响应状态: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('上传请求失败: ${response.statusCode}');
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['zt'] == 1) {
          _logSuccess('文件上传成功: ${data['info']}');
          return {
            'success': true,
            'message': data['info'],
            'file': data['text']?[0],
          };
        } else {
          final errorMsg = data['info'] ?? '上传失败';
          _logError('文件上传失败', errorMsg);
          throw Exception(errorMsg);
        }
      } else {
        throw Exception('响应格式错误');
      }
    } catch (e) {
      _logError('文件上传异常', e);
      rethrow;
    }
  }

  /// 移动文件
  /// [account] 蓝奏云账号信息
  /// [file] 要移动的文件
  /// [targetFolderId] 目标文件夹ID（可选，默认为根目录-1）
  /// 返回移动是否成功
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    try {
      _logInfo('🚚 开始移动文件');
      _logInfo('📄 文件: ${file.name} (ID: ${file.id})');
      _logInfo('📁 目标文件夹ID: ${targetFolderId ?? '-1'}');

      // 从Cookie中提取UID
      final uid = extractUidFromCookies(account.cookies ?? '');
      if (uid == null || uid.isEmpty) {
        _logError('无法从Cookie中提取UID', 'UID提取失败');
        return false;
      }

      _logInfo('🔍 提取到UID: $uid');

      // 创建请求头
      final headers = _createHeaders(account.cookies ?? '', uid);

      // 准备请求数据
      final data = {
        'task': LanzouConfig.getTaskId('moveFile'), // 移动文件任务
        'folder_id': LanzouConfig.getFolderId(targetFolderId), // 目标文件夹ID，默认为根目录
        'file_id': file.id, // 要移动的文件ID
      };

      _logInfo('📡 移动文件请求数据: $data');

      // 执行请求
      final response = await _executeRequest(
        account: account,
        data: data,
        headers: headers,
      );

      _logInfo('📡 移动文件响应: $response');

      // 检查响应状态
      final zt = response['zt'];
      final info = response['info'];
      final text = response['text'];

      _logInfo('🔍 响应状态: zt=$zt, info=$info, text=$text');

      if (zt == 1) {
        _logSuccess('文件移动成功');
        return true;
      } else {
        _logError('文件移动失败', info);
        return false;
      }
    } catch (e) {
      _logError('移动文件异常', e);
      return false;
    }
  }
}
