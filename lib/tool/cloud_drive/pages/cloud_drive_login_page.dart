import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/services/base/debug_service.dart';

/// 云盘登录专用的 WebView 页面
/// 包含获取 Cookie 的悬浮按钮
class CloudDriveLoginWebView extends StatefulWidget {
  final String title;
  final String url;
  final Function(String cookies)? onCookiesObtained;

  const CloudDriveLoginWebView({
    super.key,
    required this.title,
    required this.url,
    this.onCookiesObtained,
  });

  @override
  State<CloudDriveLoginWebView> createState() => _CloudDriveLoginWebViewState();
}

class _CloudDriveLoginWebViewState extends State<CloudDriveLoginWebView> {
  WebViewController? _webViewController;
  bool _isLoading = true;
  String? _error;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    DebugService.log('🌐 云盘登录 WebView 初始化: ${widget.url}');
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.transparent)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                setState(() {
                  _progress = progress;
                });
              },
              onPageStarted: (String url) {
                DebugService.log('🚀 开始加载页面: $url');
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
              },
              onPageFinished: (String url) {
                DebugService.log('✅ 页面加载完成: $url');
                setState(() {
                  _isLoading = false;
                });
              },
              onWebResourceError: (WebResourceError error) {
                DebugService.error('❌ WebView 资源加载错误: ${error.description}', null);
                setState(() {
                  _isLoading = false;
                });
              },
              onNavigationRequest: (NavigationRequest request) {
                DebugService.log('🔗 导航请求: ${request.url}');
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  /// 获取 Cookie
  Future<void> _getCookies() async {
    try {
      DebugService.log('🍪 开始获取 Cookie...');

      // 使用 JavaScript 获取 Cookie
      const cookieScript = 'document.cookie';
      final cookieResult = await _webViewController
          ?.runJavaScriptReturningResult(cookieScript);

      if (cookieResult != null && cookieResult.toString().isNotEmpty) {
        String cookieString = cookieResult.toString();

        // 清理 Cookie 字符串，移除多余的引号和空格
        cookieString = cookieString.replaceAll('"', '').trim();

        DebugService.log('✅ 成功获取真实 Cookie');
        DebugService.log('🍪 原始 Cookie: $cookieString');
        DebugService.log('🍪 Cookie 长度: ${cookieString.length}');

        // 详细分析 Cookie
        _analyzeCookies(cookieString);

        // 检查是否包含必要的 Cookie
        if (!cookieString.contains('ylogin=')) {
          DebugService.log('⚠️ Cookie 中缺少 ylogin，可能未完成登录');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cookie 中缺少登录信息，请确保已完成登录'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        // 回调获取到的 Cookie
        widget.onCookiesObtained?.call(cookieString);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('成功获取 Cookie (${cookieString.length} 字符)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        DebugService.log('⚠️ 未获取到任何 Cookie');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('未获取到 Cookie，请确保已登录'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      DebugService.error('❌ 获取 Cookie 失败: $e', null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('获取 Cookie 失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 分析 Cookie 内容
  void _analyzeCookies(String cookies) {
    try {
      DebugService.log('🔍 开始分析 Cookie 内容...');

      final cookieMap = <String, String>{};
      final cookieList = cookies.split(';');

      DebugService.log('🍪 Cookie 总数: ${cookieList.length}');

      for (int i = 0; i < cookieList.length; i++) {
        final cookie = cookieList[i].trim();
        if (cookie.isEmpty) continue;

        final parts = cookie.split('=');
        if (parts.length >= 2) {
          final name = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();
          cookieMap[name] = value;

          DebugService.log(
            '🍪 Cookie $i: $name = ${value.length > 50 ? value.substring(0, 50) + '...' : value}',
          );
        }
      }

      // 检查关键 Cookie
      final criticalCookies = ['ylogin', 'phpdisk_info', 'PHPSESSID', 'uag'];
      for (final cookieName in criticalCookies) {
        if (cookieMap.containsKey(cookieName)) {
          DebugService.log('✅ 找到关键 Cookie: $cookieName');
        } else {
          DebugService.log('❌ 缺少关键 Cookie: $cookieName');
        }
      }

      DebugService.log('🍪 所有 Cookie 键: ${cookieMap.keys.toList()}');
    } catch (e) {
      DebugService.error('❌ 分析 Cookie 失败: $e', null);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      actions: [
        if (!_isLoading)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _webViewController?.reload(),
          ),
        if (!_isLoading)
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              // 在外部浏览器中打开
              final uri = Uri.parse(widget.url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
      ],
    ),
    body: Stack(
      children: [
        WebViewWidget(controller: _webViewController!),
        // 进度条
        if (_isLoading && _progress < 100)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _progress / 100,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        // 错误显示
        if (_error != null)
          Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '页面加载失败',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _webViewController?.reload(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _getCookies,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      icon: const Icon(Icons.cookie),
      label: const Text('获取 Cookie'),
    ),
  );
}
