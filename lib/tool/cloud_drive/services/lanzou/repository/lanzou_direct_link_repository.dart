import '../../../../../core/logging/log_manager.dart';
import '../lanzou_config.dart';
import '../models/lanzou_direct_link_models.dart';
import '../models/lanzou_result.dart';
import '../exceptions/lanzou_exceptions.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

/// 仓库：负责蓝奏云直链解析的网络请求与 HTML 解析。
class LanzouDirectLinkRepository {
  LanzouDirectLinkRepository({Dio? dio}) : _dio = dio ?? Dio(_baseOptions);

  static final BaseOptions _baseOptions = BaseOptions(
    connectTimeout: LanzouConfig.connectTimeout,
    receiveTimeout: LanzouConfig.receiveTimeout,
    sendTimeout: LanzouConfig.sendTimeout,
    headers: LanzouConfig.directLinkHeaders,
  );

  final Dio _dio;

  Future<LanzouResult<LanzouDirectLinkResult>> parseDirectLink(
    LanzouDirectLinkRequest request,
  ) async {
    try {
      final context = await _buildShareContext(request);
      final apiResponse = await _resolveApiResponse(
        context: context,
        password: request.password,
      );
      final downloadUrl = await _getDownloadUrl(apiResponse);
      if (downloadUrl == null) {
        return LanzouResult.failure(
          const LanzouFailure(message: '获取下载链接失败'),
        );
      }
      return LanzouResult.success(
        LanzouDirectLinkResult(
          name: context.fileInfo.name,
          size: context.fileInfo.size,
          time: context.fileInfo.time,
          directLink: downloadUrl,
          originalUrl: request.shareUrl,
        ),
      );
    } catch (e) {
      LogManager().error('解析直链失败', exception: e);
      if (e is LanzouApiException) {
        return LanzouResult.failure(
          LanzouFailure(message: e.message),
        );
      }
      return LanzouResult.failure(
        LanzouFailure(message: e.toString()),
      );
    }
  }

  Future<LanzouDirectLinkContext> _buildShareContext(
    LanzouDirectLinkRequest request,
  ) async {
    final formattedUrl = _formatUrl(request.shareUrl);
    final content = await _getPageContent(formattedUrl);
    if (content == null) {
      throw const LanzouApiException('无法获取页面内容');
    }
    if (_isFileDeleted(content)) {
      throw const LanzouApiException('文件取消分享了');
    }
    final fileInfo = _extractFileInfo(content);
    if (fileInfo == null) {
      throw const LanzouApiException('文件解析失败');
    }
    return LanzouDirectLinkContext(
      originalUrl: request.shareUrl,
      formattedUrl: formattedUrl,
      rawContent: content,
      fileInfo: fileInfo,
      needsPassword: content.contains('function down_p(){'),
    );
  }

  Future<String> _resolveApiResponse({
    required LanzouDirectLinkContext context,
    String? password,
  }) async {
    if (context.needsPassword) {
      if (password == null || password.isEmpty) {
        throw const LanzouApiException('请输入分享密码');
      }
      return await _handlePasswordProtected(
        context.rawContent,
        context.formattedUrl,
        password,
      );
    }
    return await _handlePublicFile(context.rawContent, context.formattedUrl);
  }

  Future<String?> _getPageContent(String url) async {
    final response = await _dio.get(
      url,
      options: Options(
        headers: LanzouConfig.directLinkHeaders,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    if (response.statusCode == 200) {
      return response.data as String;
    }
    return null;
  }

  Future<String> _handlePasswordProtected(
    String content,
    String url,
    String password,
  ) async {
    final reSign = RegExp(r'data : \{(.*?)\}').firstMatch(content);
    if (reSign == null) {
      throw const LanzouApiException('解析密码接口失败');
    }
    final signInfo = reSign.group(1)?.replaceAll("'", '"');
    if (signInfo == null) {
      throw const LanzouApiException('解析密码接口失败');
    }
    final signJson = jsonDecode('{$signInfo}') as Map<String, dynamic>;
    signJson['p'] = password;

    final ajaxPath = RegExp(r"var ajaxm = '(.*?)';").firstMatch(content);
    if (ajaxPath == null) {
      throw const LanzouApiException('解析 ajaxm 失败');
    }
    final apiUrl = '${LanzouConfig.lanzouxUrl}/${ajaxPath.group(1)}';
    final response = await _dio.post(
      apiUrl,
      data: FormData.fromMap(signJson),
      options: Options(
        headers: {
          ...LanzouConfig.directLinkHeaders,
          'Referer': url,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    );
    return jsonEncode(response.data);
  }

  Future<String> _handlePublicFile(String content, String url) async {
    final ajaxPath = RegExp(r"var ajaxm = '(.*?)';").firstMatch(content);
    if (ajaxPath == null) {
      throw const LanzouApiException('解析 ajaxm 失败');
    }
    final apiUrl = '${LanzouConfig.lanzouxUrl}/${ajaxPath.group(1)}';
    final sign = RegExp(r"data : \{(.*?)\}").firstMatch(content);
    if (sign == null) {
      throw const LanzouApiException('解析 data 失败');
    }
    final postData = jsonDecode('{${sign.group(1)!.replaceAll("'", '"')}}');
    final response = await _dio.post(
      apiUrl,
      data: FormData.fromMap(postData as Map<String, dynamic>),
      options: Options(
        headers: {
          ...LanzouConfig.directLinkHeaders,
          'Referer': url,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    );
    return jsonEncode(response.data);
  }

  Future<String?> _getDownloadUrl(String apiResponse) async {
    final response = jsonDecode(apiResponse);
    if (response['url'] == '0') {
      throw LanzouApiException(response['inf']?.toString() ?? '未知错误');
    }
    if ((response['zt'] ?? 0) != 1) {
      return null;
    }
    final downloadLink = '${response['dom']}/file/${response['url']}';
    final finalLink = await _getRedirectUrl(downloadLink);
    if (finalLink.isEmpty || !finalLink.startsWith('http')) {
      return downloadLink;
    }
    return finalLink.replaceAll(RegExp(r'pid=.*?&'), '');
  }

  Future<String> _getRedirectUrl(String url) async {
    final response = await _dio.head(
      url,
      options: Options(
        headers: LanzouConfig.directLinkHeaders,
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return response.headers.value('location') ?? '';
  }

  bool _isFileDeleted(String content) => content.contains('文件取消分享了');

  LanzouDirectLinkFileInfo? _extractFileInfo(String content) {
    try {
      final sizeMatch = RegExp(r'文件大小：(.*?)"').firstMatch(content);
      final size = sizeMatch?.group(1)?.trim() ?? '';
      final timeMatch = RegExp(r'n_file_infos">(.*?)<').firstMatch(content);
      final time = timeMatch?.group(1)?.trim() ?? '';
      final nameMatch = RegExp(r'<div class="n_box_3fn".*?>(.*?)</div>').firstMatch(content);
      final name = nameMatch?.group(1)?.trim() ?? '';
      if (name.isEmpty) {
        return null;
      }
      return LanzouDirectLinkFileInfo(name: name, size: size, time: time);
    } catch (_) {
      return null;
    }
  }

  String _formatUrl(String url) {
    if (url.contains('.com/')) {
      final parts = url.split('.com/');
      if (parts.length > 1) {
        return '${LanzouConfig.lanzoupUrl}/${parts[1]}';
      }
    }
    if (url.contains('lanzou') && url.contains('/')) {
      final uri = Uri.parse(url);
      if (uri.path.isNotEmpty && uri.path != '/') {
        final fileId = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
        return '${LanzouConfig.lanzoupUrl}/$fileId';
      }
    }
    return url;
  }
}
