import 'package:dio/dio.dart';

import '../../../core/services/base/debug_service.dart';
import '../../models/cloud_drive_models.dart';
import 'baidu_base_service.dart';
import 'baidu_config.dart';
import 'baidu_file_operation_service.dart';
import 'baidu_param_service.dart';

/// 百度网盘主服务
/// 提供百度网盘的核心功能
class BaiduCloudDriveService {
  static const String _baseUrl = 'https://pan.baidu.com/api';

  // 创建dio实例 - 使用统一的基础服务
  static Dio _createDio(CloudDriveAccount account) =>
      BaiduBaseService.createDio(account);

  /// 统一错误处理
  static void _handleError(
    String operation,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    DebugService.log(
      '❌ 百度网盘 - $operation 失败: $error',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    if (stackTrace != null) {
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
    }
  }

  /// 统一日志记录
  static void _logInfo(String message) {
    DebugService.log(
      message,
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
  }

  /// 统一成功日志记录
  static void _logSuccess(String message) {
    DebugService.log(
      '✅ 百度网盘 - $message',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
  }

  /// 统一错误日志记录
  static void _logError(String message, dynamic error) {
    DebugService.log(
      '❌ 百度网盘 - $message: $error',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
  }

  /// 获取文件列表
  static Future<Map<String, List<CloudDriveFile>>> getFileList({
    required CloudDriveAccount account,
    String folderId = '/',
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      _logInfo('📁 获取文件列表: 文件夹ID=$folderId, 页码=$page');

      // 验证账号登录状态
      if (!account.isLoggedIn) {
        _logError('账号未登录，请先登录百度云盘', '未登录状态');
        return {'files': [], 'folders': []};
      }

      // 处理路径格式：百度网盘API需要完整的嵌套路径
      String processedFolderId = folderId;
      if (folderId != '-1') {
        // 如果传入的是文件夹名而不是完整路径，需要构建完整路径
        if (!folderId.startsWith('/')) {
          // 这里需要从当前路径构建完整路径
          // 暂时使用传入的folderId，实际应该从folderPath构建
          processedFolderId = '/$folderId';
        }
        _logInfo('🔧 路径处理: $folderId -> $processedFolderId');
      }

      // 构建请求URL
      final url = Uri.parse('$_baseUrl/list');
      final queryParams = {
        'clienttype': '0',
        'app_id': '250528',
        'web': '1',
        'dp-logid': DateTime.now().millisecondsSinceEpoch.toString(),
        'order': 'time',
        'desc': '1',
        'num': pageSize.toString(),
        'page': page.toString(),
        'dir': processedFolderId, // 使用处理后的路径
      };

      _logInfo('🔍 请求参数: dir=$processedFolderId');
      _logInfo(
        '🌐 发送请求: ${url.toString()}?${Uri(queryParameters: queryParams).query}',
      );

      // 发送请求
      final dio = _createDio(account);
      final response = await dio.getUri(
        url.replace(queryParameters: queryParams),
      );

      _logInfo('📡 收到响应: ${response.statusCode}');

      if (response.statusCode != 200) {
        _logError('请求失败', '状态码: ${response.statusCode}');
        return {'files': [], 'folders': []};
      }

      final responseData = response.data;
      _logInfo(
        '📄 响应数据: ${responseData.toString().substring(0, responseData.toString().length > 200 ? 200 : responseData.toString().length)}...',
      );

      // 检查错误码
      if (responseData['errno'] != 0) {
        final errorMsg = _getErrorMessage(responseData['errno']);
        _logError('API错误', '$errorMsg (errno: ${responseData['errno']})');
        return {'files': [], 'folders': []};
      }

      // 解析文件列表
      final List<dynamic> fileList = responseData['list'] ?? [];
      final List<CloudDriveFile> folders = [];
      final List<CloudDriveFile> files = [];

      for (final fileData in fileList) {
        final file = _parseFileData(fileData);
        if (file.isFolder) {
          folders.add(file);
        } else {
          files.add(file);
        }
      }

      _logSuccess('解析完成: ${folders.length} 个文件夹, ${files.length} 个文件');

      return {'folders': folders, 'files': files};
    } catch (e) {
      _handleError('获取文件列表', e, null);
      return {'files': [], 'folders': []};
    }
  }

  /// 解析文件数据
  static CloudDriveFile _parseFileData(Map<String, dynamic> fileData) {
    final isDir = fileData['isdir'] == 1;
    final serverFilename = fileData['server_filename'] ?? '';
    final fsId = fileData['fs_id']?.toString() ?? '';
    final size = fileData['size'] ?? 0;
    final localMtime = fileData['local_mtime'] ?? 0;
    final serverMtime = fileData['server_mtime'] ?? 0;
    final path = fileData['path'] ?? '';

    // 转换时间戳
    final modifiedTime = _formatTimestamp(
      serverMtime > 0 ? serverMtime : localMtime,
    );

    // 格式化文件大小
    final sizeText = isDir ? '' : _formatFileSize(size);

    // 处理ID：文件夹使用path，文件使用fs_id
    final fileId = isDir ? path : fsId;

    // 添加调试日志
    DebugService.log(
      '📄 解析文件: $serverFilename (${isDir ? '文件夹' : '文件'}), ID: $fileId, fs_id: $fsId, path: $path, 大小: $size -> $sizeText, 时间: $modifiedTime',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    return CloudDriveFile(
      id: fileId, // 统一使用处理后的ID
      name: serverFilename,
      isFolder: isDir,
      size: size, // 使用原始size值
      modifiedTime: DateTime.fromMillisecondsSinceEpoch(
        (serverMtime > 0 ? serverMtime : localMtime) * 1000,
      ), // 转换为DateTime
      folderId: path, // 保持原始path用于后续处理
    );
  }

  /// 格式化时间戳
  static String _formatTimestamp(int timestamp) {
    if (timestamp == 0) return '未知时间';

    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    // 返回具体的日期时间格式
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute';
  }

  /// 格式化文件大小
  static String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// 获取错误信息
  static String _getErrorMessage(int errno) {
    switch (errno) {
      case -6:
        return 'Cookie已失效，需要重新登录';
      case -7:
        return '路径不存在或权限不足';
      case -8:
        return '账号异常，禁止分享';
      case -9:
        return '文件或目录不存在';
      case -12:
        return '权限不足';
      case -21:
        return '参数错误';
      case -62:
        return '请求过于频繁';
      case -70:
        return '用户未登录';
      case -99:
        return '系统错误';
      case -101:
        return '文件不存在';
      case -102:
        return '文件已被删除';
      case -103:
        return '文件已被移动';
      case -104:
        return '文件已被重命名';
      case -105:
        return '文件已被复制';
      case -106:
        return '文件已被分享';
      case -107:
        return '文件已被下载';
      case -108:
        return '文件已被上传';
      case -109:
        return '文件已被修改';
      case -110:
        return '文件已被删除';
      case 2:
        return '参数错误或请求格式不正确';
      default:
        return '未知错误 (errno: $errno)';
    }
  }

  /// 验证Cookie有效性
  static Future<bool> validateCookies(CloudDriveAccount account) async {
    try {
      DebugService.log(
        '🔍 验证百度云盘Cookie有效性',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      // 如果能获取到文件列表，说明Cookie有效
      return true;
    } catch (e) {
      DebugService.log(
        '❌ Cookie验证失败: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return false;
    }
  }

  /// 获取文件下载链接
  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    try {
      DebugService.log(
        '🔗 获取百度云盘文件下载链接: ${file.name} (${file.id})',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (!account.isLoggedIn) {
        DebugService.log(
          '❌ 账号未登录',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        throw Exception('账号未登录');
      }

      // 获取百度云盘参数
      final params = await BaiduParamService.getBaiduParams(account);

      final url = Uri.parse('$_baseUrl/download');
      final queryParams = {
        'clienttype': '0',
        'app_id': '250528',
        'web': '1',
        'dp-logid': DateTime.now().millisecondsSinceEpoch.toString(),
        'fidlist': '[${file.id}]',
        'type': 'dlink',
        'vip': '0',
        'sign': params['sign'] ?? '',
        'timestamp':
            params['timestamp']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
      };

      DebugService.log(
        '🌐 下载请求URL: $url',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📋 下载请求参数: $queryParams',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      final dio = _createDio(account);
      final response = await dio.getUri(
        url.replace(queryParameters: queryParams),
      );

      DebugService.log(
        '📡 下载响应状态码: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📄 下载响应体: ${response.data}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (response.statusCode != 200) {
        DebugService.log(
          '❌ 请求失败: ${response.statusCode}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        throw Exception('请求失败: ${response.statusCode}');
      }

      final responseData = response.data;

      if (responseData['errno'] != 0) {
        DebugService.log(
          '❌ 获取下载链接失败: ${_getErrorMessage(responseData['errno'])}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        throw Exception('获取下载链接失败: ${_getErrorMessage(responseData['errno'])}');
      }

      final List<dynamic> downloadList = responseData['dlink'] ?? [];
      if (downloadList.isNotEmpty) {
        final downloadInfo = downloadList.first;
        return downloadInfo['dlink'] as String?;
      }

      return null;
    } catch (e) {
      DebugService.log(
        '❌ 获取下载链接失败: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      rethrow;
    }
  }

  /// 生成分享链接
  static Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<String> fileIds,
    String pwd = '',
    int period = 1, // 1=1天, 7=7天, 30=30天, 365=365天, 0=永久
  }) async {
    DebugService.log(
      '🔗 百度网盘 - 开始生成分享链接',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📋 文件ID列表: $fileIds',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '🔑 用户输入提取码: ${pwd.isEmpty ? '无' : pwd}',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '🔑 实际使用提取码: ${pwd.isEmpty ? '0000' : pwd}',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '⏰ 有效期: $period 天',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '👤 账号: ${account.name}',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    // 获取百度网盘参数
    final baiduParams = await BaiduParamService.getBaiduParams(account);
    final bdstoken = baiduParams['bdstoken'] as String?;

    if (bdstoken == null) {
      DebugService.log(
        '❌ 无法获取bdstoken',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return null;
    }

    final url = Uri.parse('https://pan.baidu.com/share/pset');

    final body = {
      'channel': 'chunlei',
      'clienttype': '0',
      'app_id': '250528',
      'web': '1',
      'is_knowledge': '0',
      'public': '0',
      'period': period.toString(),
      'pwd': pwd.isEmpty ? '0000' : pwd, // 提取码为空时默认使用0000
      'eflag_disable': 'true',
      'linkOrQrcode': 'link',
      'channel_list': '[]',
      'schannel': pwd.isEmpty ? '4' : '4', // 有提取码时使用schannel=4
      'fid_list': '[${fileIds.join(',')}]',
      'bdstoken': bdstoken,
    };

    DebugService.log(
      '🌐 请求URL: $url',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '📦 请求体: $body',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      final dio = _createDio(account);
      final response = await dio.postUri(url, data: body);

      DebugService.log(
        '📡 响应状态码: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📄 响应头: ${response.headers}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📄 响应体: ${response.data}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (response.statusCode != 200) {
        DebugService.log(
          '❌ HTTP请求失败: ${response.statusCode}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        throw Exception('HTTP请求失败: ${response.statusCode}');
      }

      final data = response.data;
      DebugService.log(
        '📋 解析后的响应数据: $data',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (data['errno'] != 0) {
        DebugService.log(
          '❌ API错误: ${_getErrorMessage(data['errno'])} (errno: ${data['errno']})',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        DebugService.log(
          '📋 完整错误信息: ${data['show_msg'] ?? '无详细信息'}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        throw Exception(_getErrorMessage(data['errno']));
      }

      if (data['link'] != null) {
        final link = data['link'] as String;
        DebugService.log(
          '✅ 分享链接生成成功: $link',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return link;
      } else {
        DebugService.log(
          '❌ 响应中没有link字段',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        DebugService.log(
          '📋 完整响应: $data',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return null;
      }
    } catch (e) {
      DebugService.log(
        '❌ 百度网盘分享请求异常: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      rethrow;
    }
  }

  /// 获取文件详情
  static Future<Map<String, dynamic>?> getFileDetail({
    required CloudDriveAccount account,
    required String fileId,
  }) async {
    try {
      DebugService.log(
        '📋 获取百度云盘文件详情: $fileId',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (!account.isLoggedIn) {
        DebugService.log(
          '❌ 账号未登录',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        throw Exception('账号未登录');
      }

      final url = Uri.parse('$_baseUrl/filemetas');
      final queryParams = {
        'clienttype': '0',
        'app_id': '250528',
        'web': '1',
        'dp-logid': DateTime.now().millisecondsSinceEpoch.toString(),
        'fsids': '[$fileId]',
        'dlink': '1',
      };

      DebugService.log(
        '🌐 文件详情请求URL: $url',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📋 文件详情请求参数: $queryParams',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      final dio = _createDio(account);
      final response = await dio.getUri(
        url.replace(queryParameters: queryParams),
      );

      DebugService.log(
        '📡 文件详情响应状态码: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📄 文件详情响应体: ${response.data}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (response.statusCode != 200) {
        DebugService.log(
          '❌ 请求失败: ${response.statusCode}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        throw Exception('请求失败: ${response.statusCode}');
      }

      final responseData = response.data;
      DebugService.log(
        '📋 文件详情响应数据: $responseData',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (responseData['errno'] != 0) {
        DebugService.log(
          '❌ 文件详情API错误: ${_getErrorMessage(responseData['errno'])} (errno: ${responseData['errno']})',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        throw Exception('获取文件详情失败: ${_getErrorMessage(responseData['errno'])}');
      }

      // 百度网盘API返回的是info字段，不是list字段
      final List<dynamic> fileList = responseData['info'] ?? [];
      DebugService.log(
        '📋 文件详情列表长度: ${fileList.length}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (fileList.isNotEmpty) {
        final fileDetail = fileList.first as Map<String, dynamic>;
        DebugService.log(
          '✅ 获取文件详情成功: $fileDetail',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return fileDetail;
      }

      DebugService.log(
        '❌ 文件详情列表为空',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return null;
    } catch (e) {
      DebugService.log(
        '❌ 获取文件详情失败: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      rethrow;
    }
  }

  // 文件操作委托给专门的服务
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    // 获取文件的完整路径
    String filePath;
    if (file.isFolder) {
      // 文件夹使用id（已经是完整路径）
      filePath = file.id;
    } else {
      // 文件使用folderId（完整路径）
      filePath = file.folderId ?? file.id;
    }

    return await BaiduFileOperationService.deleteFile(
      account: account,
      filePath: filePath,
    );
  }

  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    // 获取文件的完整路径
    String filePath;
    if (file.isFolder) {
      // 文件夹使用id（已经是完整路径）
      filePath = file.id;
    } else {
      // 文件使用folderId（完整路径）
      filePath = file.folderId ?? file.id;
    }

    return await BaiduFileOperationService.moveFile(
      account: account,
      filePath: filePath,
      targetPath: targetFolderId ?? '/',
    );
  }

  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    // 获取文件的完整路径
    String filePath;
    if (file.isFolder) {
      // 文件夹使用id（已经是完整路径）
      filePath = file.id;
    } else {
      // 文件使用folderId（完整路径）
      filePath = file.folderId ?? file.id;
    }

    return await BaiduFileOperationService.renameFile(
      account: account,
      filePath: filePath,
      newFileName: newName,
    );
  }

  static Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String destPath,
    String? newName,
  }) async {
    // 获取文件的完整路径
    String filePath;
    if (file.isFolder) {
      // 文件夹使用id（已经是完整路径）
      filePath = file.id;
    } else {
      // 文件使用folderId（完整路径）
      filePath = file.folderId ?? file.id;
    }

    return await BaiduFileOperationService.copyFile(
      account: account,
      filePath: filePath,
      targetPath: destPath,
    );
  }

  // 参数管理委托给专门的服务
  static Future<Map<String, dynamic>> getBaiduParams(
    CloudDriveAccount account,
  ) async => await BaiduParamService.getBaiduParams(account);

  static void clearParamCache(String accountId) {
    BaiduParamService.clearCacheForAccount(accountId);
  }

  static void clearAllParamCache() {
    BaiduParamService.clearCache();
  }

  /// 获取账号容量信息
  static Future<CloudDriveQuotaInfo?> getAccountQuota({
    required CloudDriveAccount account,
  }) async {
    DebugService.log(
      '📊 百度网盘 - 获取账号容量信息开始',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      final dio = _createDio(account);
      final url = Uri.parse(
        BaiduConfig.getApiUrl(BaiduConfig.endpoints['accountQuota']!),
      );
      final queryParams = BaiduConfig.buildQuotaParams();

      final uri = url.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );

      DebugService.log(
        '🔗 请求URL: $uri',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      final response = await dio.getUri(uri);

      DebugService.log(
        '📡 响应状态码: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (response.statusCode != 200) {
        DebugService.log(
          '❌ 获取容量信息失败，状态码: ${response.statusCode}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        throw Exception('获取容量信息失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      DebugService.log(
        '📄 容量信息响应: $responseData',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (responseData['errno'] != 0) {
        final errorMsg = BaiduConfig.getErrorMessage(responseData['errno']);
        DebugService.log(
          '❌ API返回错误: $errorMsg (errno: ${responseData['errno']})',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        throw Exception('获取容量信息失败: $errorMsg');
      }

      final quotaInfo = CloudDriveQuotaInfo.fromBaiduResponse(responseData);

      DebugService.log(
        '✅ 百度网盘 - 容量信息获取成功: ${quotaInfo.toString()}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      return quotaInfo;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 百度网盘 - 获取容量信息异常: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return null;
    }
  }

  /// 获取账号用户信息
  static Future<CloudDriveAccountInfo?> getAccountUserInfo({
    required CloudDriveAccount account,
  }) async {
    DebugService.log(
      '👤 百度网盘 - 获取用户信息开始',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      final dio = _createDio(account);
      final url = Uri.parse(
        BaiduConfig.baseUrl + BaiduConfig.endpoints['accountUserInfo']!,
      );
      final queryParams = BaiduConfig.buildUserInfoParams();

      final uri = url.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );

      DebugService.log(
        '🔗 请求URL: $uri',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      final response = await dio.getUri(uri);

      DebugService.log(
        '📡 响应状态码: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (response.statusCode != 200) {
        DebugService.log(
          '❌ 获取用户信息失败，状态码: ${response.statusCode}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        throw Exception('获取用户信息失败，状态码: ${response.statusCode}');
      }

      final responseData = response.data;
      DebugService.log(
        '📄 用户信息响应: $responseData',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (responseData['error_code'] != 0) {
        final errorMsg = responseData['error_msg'] ?? '未知错误';
        DebugService.log(
          '❌ API返回错误: $errorMsg (error_code: ${responseData['error_code']})',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        throw Exception('获取用户信息失败: $errorMsg');
      }

      final userInfo = responseData['user_info'];
      if (userInfo == null) {
        DebugService.log(
          '❌ 响应中没有用户信息数据',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        throw Exception('响应中没有用户信息数据');
      }

      final accountInfo = CloudDriveAccountInfo.fromBaiduResponse(userInfo);

      DebugService.log(
        '✅ 百度网盘 - 用户信息获取成功: ${accountInfo.toString()}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      return accountInfo;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 百度网盘 - 获取用户信息异常: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return null;
    }
  }

  /// 获取完整的账号详情信息（包含用户信息和容量信息）
  static Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    DebugService.log(
      '📋 百度网盘 - 获取完整账号详情开始',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
    DebugService.log(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      // 并发获取用户信息和容量信息
      final results = await Future.wait([
        getAccountUserInfo(account: account),
        getAccountQuota(account: account),
      ]);

      final accountInfo = results[0] as CloudDriveAccountInfo?;
      final quotaInfo = results[1] as CloudDriveQuotaInfo?;

      if (accountInfo == null || quotaInfo == null) {
        DebugService.log(
          '❌ 获取账号详情失败: 用户信息=${accountInfo != null ? '成功' : '失败'}, 容量信息=${quotaInfo != null ? '成功' : '失败'}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return null;
      }

      final accountDetails = CloudDriveAccountDetails(
        accountInfo: accountInfo,
        quotaInfo: quotaInfo,
      );

      DebugService.log(
        '✅ 百度网盘 - 完整账号详情获取成功',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📊 账号详情: ${accountDetails.toString()}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      return accountDetails;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 百度网盘 - 获取完整账号详情异常: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return null;
    }
  }

  /// 新建文件夹
  static Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    required String parentPath,
  }) async {
    try {
      DebugService.log(
        '📁 百度网盘 - 开始新建文件夹: $folderName, 父路径: $parentPath',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      // 获取bdstoken
      final bdstoken = await BaiduParamService.getBdstoken(account);

      // 构建URL参数
      final urlParams = BaiduConfig.buildCreateFolderUrlParams(
        bdstoken: bdstoken,
      );

      // 构建请求体
      final requestBodyMap = BaiduConfig.buildCreateFolderBody(
        folderName: folderName,
        parentPath: parentPath,
      );

      // 将Map转换为FormData以确保正确的表单编码
      final formData = FormData.fromMap(requestBodyMap);

      final baseUrl = BaiduConfig.getApiUrl(
        BaiduConfig.endpoints['createFolder']!,
      );
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: urlParams.map((k, v) => MapEntry(k, v.toString())),
      );

      DebugService.log(
        '🔗 请求URL: $uri',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📤 请求体: ${requestBodyMap.entries.map((e) => '${e.key}=${e.value}').join('&')}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      // 发送请求
      final dio = _createDio(account);
      final response = await dio.postUri(uri, data: formData);

      DebugService.log(
        '📡 新建文件夹响应: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📄 响应数据: ${response.data}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final errno = data['errno'] as int?;

        if (errno == 0) {
          // 成功创建文件夹，构建CloudDriveFile对象
          final folderPath = data['path'] as String? ?? '';
          final mtime = data['mtime'] as int?;

          final folder = CloudDriveFile(
            id: folderPath,
            name: folderName,
            size: 0, // 文件夹大小为0
            modifiedTime:
                mtime != null
                    ? DateTime.fromMillisecondsSinceEpoch(mtime * 1000)
                    : DateTime.now(), // 转换为DateTime
            isFolder: true,
            folderId: parentPath,
          );

          DebugService.log(
            '✅ 文件夹创建成功: $folderName',
            category: DebugCategory.tools,
            subCategory: BaiduConfig.logSubCategory,
          );

          return folder;
        } else {
          final errorMsg = BaiduConfig.getErrorMessage(errno ?? -1);
          DebugService.log(
            '❌ 文件夹创建失败: $errorMsg (errno: $errno)',
            category: DebugCategory.tools,
            subCategory: BaiduConfig.logSubCategory,
          );
          return null;
        }
      } else {
        DebugService.log(
          '❌ 文件夹创建请求失败: ${response.statusCode}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return null;
      }
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 新建文件夹异常: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return null;
    }
  }

  /// 测试账号详情功能
  static Future<void> testAccountDetails({
    required CloudDriveAccount account,
  }) async {
    DebugService.log(
      '🧪 百度网盘 - 测试账号详情功能开始',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      // 测试用户信息获取
      DebugService.log(
        '🔍 测试用户信息获取...',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      final userInfo = await getAccountUserInfo(account: account);
      if (userInfo != null) {
        DebugService.log(
          '✅ 用户信息获取成功: ${userInfo.username} (${userInfo.vipStatusDescription})',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 用户信息获取失败',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      }

      // 测试容量信息获取
      DebugService.log(
        '🔍 测试容量信息获取...',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      final quotaInfo = await getAccountQuota(account: account);
      if (quotaInfo != null) {
        DebugService.log(
          '✅ 容量信息获取成功: ${quotaInfo.formattedUsed}/${quotaInfo.formattedTotal} (${quotaInfo.usagePercentage.toStringAsFixed(1)}%)',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 容量信息获取失败',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      }

      // 测试完整账号详情获取
      DebugService.log(
        '🔍 测试完整账号详情获取...',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      final accountDetails = await getAccountDetails(account: account);
      if (accountDetails != null) {
        DebugService.log(
          '✅ 完整账号详情获取成功',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        DebugService.log(
          '📊 详细信息: 用户=${accountDetails.accountInfo.username}, 存储=${accountDetails.quotaInfo.usagePercentage.toStringAsFixed(1)}%',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      } else {
        DebugService.log(
          '❌ 完整账号详情获取失败',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
      }

      DebugService.log(
        '🧪 百度网盘 - 账号详情功能测试完成',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 百度网盘 - 账号详情功能测试异常: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
    }
  }
}
