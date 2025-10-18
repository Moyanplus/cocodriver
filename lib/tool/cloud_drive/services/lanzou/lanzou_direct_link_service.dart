import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../core/services/base/debug_service.dart';
import 'lanzou_config.dart';

/// 蓝奏云直链解析服务
/// 专门负责蓝奏云分享链接的解析和直链获取
class LanzouDirectLinkService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: LanzouConfig.connectTimeout,
      receiveTimeout: LanzouConfig.receiveTimeout,
      sendTimeout: LanzouConfig.sendTimeout,
      headers: LanzouConfig.directLinkHeaders,
    ),
  );

  /// 解析蓝奏云直链
  static Future<Map<String, dynamic>?> parseDirectLink({
    required String shareUrl,
    String? password,
  }) async {
    try {
      DebugService.log('🔗 开始解析蓝奏云直链: $shareUrl');
      if (password != null) {
        DebugService.log('🔑 使用密码: $password');
      }

      // 1. 格式化URL
      final formattedUrl = _formatUrl(shareUrl);
      DebugService.log('🔗 格式化后URL: $formattedUrl');

      // 2. 获取页面内容
      final content = await _getPageContent(formattedUrl);
      if (content == null) {
        throw Exception('无法获取页面内容');
      }

      // 3. 检查文件是否被删除
      if (_isFileDeleted(content)) {
        throw Exception('文件取消分享了');
      }

      // 4. 提取文件信息
      final fileInfo = _extractFileInfo(content);
      if (fileInfo == null) {
        throw Exception('解析失败');
      }

      DebugService.log('📄 文件信息: $fileInfo');

      // 5. 判断是否需要密码
      final needsPassword = content.contains('function down_p(){');
      DebugService.log('🔐 是否需要密码: $needsPassword');

      String apiResponse;
      if (needsPassword) {
        // 需要密码的情况
        if (password == null || password.isEmpty) {
          throw Exception('请输入分享密码');
        }

        apiResponse = await _handlePasswordProtected(
          content,
          formattedUrl,
          password,
        );
      } else {
        // 不需要密码的情况
        apiResponse = await _handlePublicFile(content, formattedUrl);
      }

      // 6. 获取下载链接
      final downloadUrl = await _getDownloadUrl(apiResponse);
      if (downloadUrl == null) {
        throw Exception('获取下载链接失败');
      }

      return {
        'name': fileInfo['name'],
        'size': fileInfo['size'],
        'time': fileInfo['time'],
        'directLink': downloadUrl,
        'originalUrl': shareUrl,
      };
    } catch (e) {
      DebugService.error('❌ 解析直链失败: $e', null);
      return null;
    }
  }

  /// 格式化URL
  static String _formatUrl(String url) {
    DebugService.log('🔗 原始URL: $url');

    // 如果URL已经是完整的分享链接，直接返回
    if (url.contains('lanzou') && !url.contains('/')) {
      // 这种情况可能是域名，需要用户提供完整的分享链接
      DebugService.log('⚠️ URL格式不正确，需要完整的分享链接');
      return url;
    }

    // 处理包含.com/的链接
    if (url.contains('.com/')) {
      final parts = url.split('.com/');
      if (parts.length > 1) {
        final formattedUrl = '${LanzouConfig.lanzoupUrl}/${parts[1]}';
        DebugService.log('🔗 格式化后URL: $formattedUrl');
        return formattedUrl;
      }
    }

    // 处理包含文件ID的链接（如 https://moyans.lanzouo.com/iYLhv2utkyqh）
    if (url.contains('lanzou') && url.contains('/')) {
      final uri = Uri.parse(url);
      final path = uri.path;
      if (path.isNotEmpty && path != '/') {
        final fileId = path.startsWith('/') ? path.substring(1) : path;
        final formattedUrl = '${LanzouConfig.lanzoupUrl}/$fileId';
        DebugService.log('🔗 格式化后URL: $formattedUrl');
        return formattedUrl;
      }
    }

    DebugService.log('🔗 无需格式化，使用原URL: $url');
    return url;
  }

  /// 获取页面内容
  static Future<String?> _getPageContent(String url) async {
    try {
      DebugService.log('🔗 获取页面内容: $url');

      final response = await _dio.get(
        url,
        options: Options(
          headers: LanzouConfig.directLinkHeaders,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final content = response.data;
        DebugService.log('📄 页面内容长度: ${content.length}');

        // 显示页面内容预览
        if (content.length < 1000) {
          DebugService.log('📄 完整页面内容: $content');
        } else {
          DebugService.log('📄 页面内容预览: ${content.substring(0, 500)}...');
        }

        // 检查页面是否包含关键信息
        DebugService.log(
          '🔍 页面包含 "function down_p()": ${content.contains('function down_p()')}',
        );
        DebugService.log('🔍 页面包含 "iframe": ${content.contains('iframe')}');
        DebugService.log('🔍 页面包含 "文件取消分享了": ${content.contains('文件取消分享了')}');
        DebugService.log('🔍 页面包含 "蓝奏": ${content.contains('蓝奏')}');
        DebugService.log('🔍 页面包含 "分享": ${content.contains('分享')}');

        return content;
      } else {
        DebugService.error('❌ 页面请求失败: ${response.statusCode}', null);
        return null;
      }
    } catch (e) {
      DebugService.error('❌ 获取页面内容失败: $e', null);
      return null;
    }
  }

  /// 检查文件是否被删除
  static bool _isFileDeleted(String content) => content.contains('文件取消分享了');

  /// 提取文件信息
  static Map<String, String>? _extractFileInfo(String content) {
    try {
      // 提取文件大小
      final sizeMatch = RegExp(r'文件大小：(.*?)"').firstMatch(content);
      final size = sizeMatch?.group(1)?.trim() ?? '';

      // 提取上传时间
      String? time;
      final timeMatch1 = RegExp(r'n_file_infos">(.*?)<').firstMatch(content);
      if (timeMatch1 != null) {
        time = timeMatch1.group(1)?.trim();
      } else {
        final timeMatch2 = RegExp(r'上传时间：</span>(.*?)<').firstMatch(content);
        time = timeMatch2?.group(1)?.trim();
      }

      // 提取文件名
      final name = _extractFileName(content);

      if (name.isEmpty) {
        return null;
      }

      return {'name': name, 'size': size, 'time': time ?? ''};
    } catch (e) {
      DebugService.error('❌ 提取文件信息失败: $e', null);
      return null;
    }
  }

  /// 提取文件名
  static String _extractFileName(String content) {
    // 尝试多种模式提取文件名
    final patterns = [
      RegExp(r'<div class="n_box_3fn".*?>(.*?)</div>'),
      RegExp(r'<title>(.*?) -'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(content);
      if (match != null) {
        final name = match.group(1)?.trim();
        if (name != null && name.isNotEmpty) {
          return name;
        }
      }
    }

    return '';
  }

  /// 处理需要密码的文件
  static Future<String> _handlePasswordProtected(
    String content,
    String url,
    String password,
  ) async {
    DebugService.log('🔐 处理需要密码的文件');

    // 提取sign参数
    String sign = '';
    final signMatch1 = RegExp(r"v3c = '(.*?)';").firstMatch(content);
    if (signMatch1 != null) {
      sign = signMatch1.group(1) ?? '';
    }

    if (sign.length < 82) {
      final signMatches = RegExp(r"sign':'(.*?)'").allMatches(content);
      if (signMatches.length > 1) {
        sign = signMatches.elementAt(1).group(1) ?? '';
      }
    }

    DebugService.log('🔑 提取到sign: $sign');

    // 提取ajaxm.php链接
    final ajaxmMatch = RegExp(r'ajaxm\.php\?file=(\d+)').firstMatch(content);
    final ajaxmPath = ajaxmMatch?.group(0) ?? '';

    DebugService.log('🔗 ajaxm路径: $ajaxmPath');

    // 发送POST请求
    final postData = {
      'action': 'downprocess',
      'sign': sign,
      'p': password,
      'kd': '1',
    };

    final apiUrl = '${LanzouConfig.lanzouxUrl}/$ajaxmPath';
    DebugService.log('📡 发送POST请求到: $apiUrl');

    final response = await _dio.post(
      apiUrl,
      data: postData,
      options: Options(
        headers: {
          ...LanzouConfig.directLinkHeaders,
          'Referer': url,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    );

    DebugService.log('📡 POST响应: ${response.data}');
    return jsonEncode(response.data);
  }

  /// 处理公开文件
  static Future<String> _handlePublicFile(String content, String url) async {
    DebugService.log('🔓 处理公开文件');

    // 提取iframe链接
    final iframeMatch = RegExp(r'<iframe.*?src="/(.*?)"').firstMatch(content);
    final iframePath = iframeMatch?.group(1) ?? '';

    final iframeUrl = '${LanzouConfig.lanzoupUrl}/$iframePath';
    DebugService.log('🔗 iframe链接: $iframeUrl');

    // 获取iframe内容
    final iframeResponse = await _dio.get(
      iframeUrl,
      options: Options(headers: LanzouConfig.directLinkHeaders),
    );

    final iframeContent = iframeResponse.data;
    DebugService.log('📄 iframe内容长度: ${iframeContent.length}');

    // 提取sign参数
    final signMatch = RegExp(r"wp_sign = '(.*?)'").firstMatch(iframeContent);
    final sign = signMatch?.group(1) ?? '';
    DebugService.log('🔑 提取到sign: $sign');

    // 提取ajaxm.php链接
    final ajaxmMatches = RegExp(
      r'ajaxm\.php\?file=(\d+)',
    ).allMatches(iframeContent);
    String ajaxmPath = '';
    if (ajaxmMatches.isNotEmpty) {
      if (ajaxmMatches.length > 1) {
        ajaxmPath =
            ajaxmMatches.elementAt(1).group(0) ??
            ajaxmMatches.elementAt(0).group(0) ??
            '';
      } else {
        ajaxmPath = ajaxmMatches.elementAt(0).group(0) ?? '';
      }
    }

    DebugService.log('🔗 ajaxm路径: $ajaxmPath');

    // 发送POST请求
    final postData = {
      'action': 'downprocess',
      'signs': '?ctdf',
      'sign': sign,
      'kd': '1',
    };

    final apiUrl = '${LanzouConfig.lanzouxUrl}/$ajaxmPath';
    DebugService.log('📡 发送POST请求到: $apiUrl');

    final response = await _dio.post(
      apiUrl,
      data: postData,
      options: Options(
        headers: {
          ...LanzouConfig.directLinkHeaders,
          'Referer': url,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    );

    DebugService.log('📡 POST响应: ${response.data}');
    return jsonEncode(response.data);
  }

  /// 获取下载链接
  static Future<String?> _getDownloadUrl(String apiResponse) async {
    try {
      final response = jsonDecode(apiResponse);

      if (response['url'] == '0') {
        throw Exception(response['inf'] ?? '未知错误');
      }

      if ((response['zt'] ?? 0) != 1) {
        return null;
      }

      final downloadLink = '${response['dom']}/file/${response['url']}';
      DebugService.log('🔗 构建下载链接: $downloadLink');

      // 获取最终直链
      final finalLink = await _getRedirectUrl(downloadLink);

      if (finalLink.isEmpty || !finalLink.startsWith('http')) {
        return downloadLink;
      }

      // 清理链接参数
      return finalLink.replaceAll(RegExp(r'pid=.*?&'), '');
    } catch (e) {
      DebugService.error('❌ 获取下载链接失败: $e', null);
      return null;
    }
  }

  /// 获取重定向URL
  static Future<String> _getRedirectUrl(String url) async {
    try {
      DebugService.log('🔗 获取重定向URL: $url');

      final response = await _dio.head(
        url,
        options: Options(
          headers: LanzouConfig.directLinkHeaders,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final redirectUrl = response.headers.value('location');
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        DebugService.log('🔗 重定向到: $redirectUrl');
        return redirectUrl;
      }

      return '';
    } catch (e) {
      DebugService.error('❌ 获取重定向URL失败: $e', null);
      return '';
    }
  }
}
