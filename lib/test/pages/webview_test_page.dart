import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/logging/log_manager.dart';

/// WebView测试页面
/// 用于测试flutter_inappwebview插件的各种功能
class WebViewTestPage extends StatefulWidget {
  const WebViewTestPage({super.key});

  @override
  State<WebViewTestPage> createState() => _WebViewTestPageState();
}

class _WebViewTestPageState extends State<WebViewTestPage> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  String _currentUrl = 'https://www.baidu.com';
  String _statusMessage = '准备就绪';
  double _progress = 0.0;
  bool _canGoBack = false;
  bool _canGoForward = false;
  String _userAgent = '';
  String _title = '';
  String _cookies = '';
  String _localStorage = '';
  String _sessionStorage = '';
  String _errorMessage = '';

  // 测试URL列表
  final List<Map<String, String>> _testUrls = [
    {'name': '百度', 'url': 'https://www.baidu.com'},
    {'name': 'Google', 'url': 'https://www.google.com'},
    {'name': 'GitHub', 'url': 'https://github.com'},
    {'name': 'Flutter官网', 'url': 'https://flutter.dev'},
    {'name': '123云盘', 'url': 'https://www.123pan.com'},
    {
      'name': '本地HTML',
      'url': 'data:text/html,<h1>Hello WebView!</h1><p>这是一个本地HTML测试页面</p>',
    },
  ];

  @override
  void initState() {
    super.initState();
    LogManager().debug('WebView测试页面初始化');
  }

  @override
  void dispose() {
    LogManager().debug('WebView测试页面销毁');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView测试'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: '刷新页面',
          ),
          // 更多选项
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'clear_cache',
                    child: ListTile(
                      leading: Icon(Icons.clear_all),
                      title: Text('清除缓存'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_cookies',
                    child: ListTile(
                      leading: Icon(Icons.cookie_outlined),
                      title: Text('清除Cookie'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'get_info',
                    child: ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('获取页面信息'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'inject_js',
                    child: ListTile(
                      leading: Icon(Icons.code),
                      title: Text('注入JavaScript'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 状态栏
          _buildStatusBar(),

          // URL选择器
          _buildUrlSelector(),

          // 进度条
          if (_isLoading) _buildProgressBar(),

          // WebView
          Expanded(child: _buildWebView()),

          // 控制面板
          _buildControlPanel(),

          // 信息面板
          _buildInfoPanel(),
        ],
      ),
    );
  }

  /// 构建状态栏
  Widget _buildStatusBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(8.w),
      color: colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(
            _isLoading ? PhosphorIcons.spinner() : PhosphorIcons.checkCircle(),
            size: 16,
            color: _isLoading ? colorScheme.tertiary : colorScheme.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_errorMessage.isNotEmpty)
            Icon(PhosphorIcons.warning(), size: 16, color: colorScheme.error),
        ],
      ),
    );
  }

  /// 构建URL选择器
  Widget _buildUrlSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(8.w),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 4.h,
        children:
            _testUrls.map((urlInfo) {
              final isSelected = _currentUrl == urlInfo['url'];
              return GestureDetector(
                onTap: () => _loadUrl(urlInfo['url']!),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color:
                          isSelected
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    urlInfo['name']!,
                    style: TextStyle(
                      color:
                          isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  /// 构建进度条
  Widget _buildProgressBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return LinearProgressIndicator(
      value: _progress / 100.0,
      backgroundColor: colorScheme.surfaceContainerHighest,
      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
    );
  }

  /// 构建WebView
  Widget _buildWebView() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(_currentUrl)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
          databaseEnabled: true,
          allowsInlineMediaPlayback: true,
          mediaPlaybackRequiresUserGesture: false,
          supportZoom: true,
          builtInZoomControls: true,
          displayZoomControls: false,
          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          allowsBackForwardNavigationGestures: true,
          // 错误处理相关设置
          allowsLinkPreview: false,
          isFraudulentWebsiteWarningEnabled: false,
          // 性能优化
          cacheEnabled: true,
          clearCache: false,
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
          LogManager().debug('WebView创建成功');
          _updateStatus('WebView已创建');
        },
        onLoadStart: (controller, url) {
          setState(() {
            _isLoading = true;
            _errorMessage = '';
          });
          LogManager().debug('开始加载: $url');
          _updateStatus('正在加载: ${url?.host}');
        },
        onLoadStop: (controller, url) async {
          setState(() {
            _isLoading = false;
          });
          LogManager().debug('加载完成: $url');
          _updateStatus('加载完成: ${url?.host}');

          // 获取页面信息
          await _getPageInfo();
        },
        onProgressChanged: (controller, progress) {
          setState(() {
            _progress = progress.toDouble();
          });
        },
        onReceivedError: (controller, request, error) {
          setState(() {
            _isLoading = false;
            _errorMessage = '错误: ${error.description}';
          });
          LogManager().error('WebView错误: ${error.description}');
          _updateStatus('加载错误: ${error.description}');
        },
        onReceivedHttpError: (controller, request, errorResponse) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'HTTP错误: ${errorResponse.statusCode}';
          });
          LogManager().error('HTTP错误: ${errorResponse.statusCode}');
          _updateStatus('HTTP错误: ${errorResponse.statusCode}');
        },
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          // 接受所有SSL证书（仅用于测试）
          return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED,
          );
        },
        onUpdateVisitedHistory: (controller, url, androidIsReload) {
          setState(() {
            _currentUrl = url?.toString() ?? '';
          });
          _updateNavigationState();
        },
      ),
    );
  }

  /// 构建控制面板
  Widget _buildControlPanel() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _canGoBack ? _goBack : null,
            tooltip: '后退',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _canGoForward ? _goForward : null,
            tooltip: '前进',
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _goHome,
            tooltip: '首页',
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _isLoading ? _stopLoading : null,
            tooltip: '停止',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: '刷新',
          ),
        ],
      ),
    );
  }

  /// 构建信息面板
  Widget _buildInfoPanel() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 200.h,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
      ),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: '基本信息'),
                Tab(text: 'Cookie'),
                Tab(text: 'LocalStorage'),
                Tab(text: 'SessionStorage'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildBasicInfoTab(),
                  _buildCookieTab(),
                  _buildLocalStorageTab(),
                  _buildSessionStorageTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 基本信息标签页
  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('URL', _currentUrl),
          _buildInfoRow('标题', _title),
          _buildInfoRow('User Agent', _userAgent),
          _buildInfoRow('状态', _statusMessage),
          if (_errorMessage.isNotEmpty)
            _buildInfoRow('错误', _errorMessage, isError: true),
        ],
      ),
    );
  }

  /// Cookie标签页
  Widget _buildCookieTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: _getCookies,
                child: const Text('获取Cookie'),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: _clearCookies,
                child: const Text('清除Cookie'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            _cookies.isEmpty ? '暂无Cookie数据' : _cookies,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  /// LocalStorage标签页
  Widget _buildLocalStorageTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: _getLocalStorage,
                child: const Text('获取LocalStorage'),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: _clearLocalStorage,
                child: const Text('清除LocalStorage'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            _localStorage.isEmpty ? '暂无LocalStorage数据' : _localStorage,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  /// SessionStorage标签页
  Widget _buildSessionStorageTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: _getSessionStorage,
                child: const Text('获取SessionStorage'),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: _clearSessionStorage,
                child: const Text('清除SessionStorage'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            _sessionStorage.isEmpty ? '暂无SessionStorage数据' : _sessionStorage,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isError ? colorScheme.error : colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color:
                    isError ? colorScheme.error : colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 更新状态消息
  void _updateStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
  }

  /// 加载URL
  void _loadUrl(String url) {
    _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    setState(() {
      _currentUrl = url;
    });
  }

  /// 刷新页面
  void _refresh() {
    _webViewController?.reload();
  }

  /// 停止加载
  void _stopLoading() {
    _webViewController?.stopLoading();
  }

  /// 后退
  void _goBack() {
    _webViewController?.goBack();
  }

  /// 前进
  void _goForward() {
    _webViewController?.goForward();
  }

  /// 首页
  void _goHome() {
    _loadUrl('https://www.baidu.com');
  }

  /// 更新导航状态
  void _updateNavigationState() async {
    if (_webViewController != null) {
      final canGoBack = await _webViewController!.canGoBack();
      final canGoForward = await _webViewController!.canGoForward();
      setState(() {
        _canGoBack = canGoBack;
        _canGoForward = canGoForward;
      });
    }
  }

  /// 获取页面信息
  Future<void> _getPageInfo() async {
    if (_webViewController == null) return;

    try {
      final title = await _webViewController!.getTitle();
      final userAgent = await _webViewController!.evaluateJavascript(
        source: 'navigator.userAgent',
      );

      setState(() {
        _title = title ?? '';
        _userAgent = userAgent?.toString() ?? '';
      });
    } catch (e) {
      LogManager().error('获取页面信息失败: $e');
    }
  }

  /// 获取Cookie
  Future<void> _getCookies() async {
    if (_webViewController == null) return;

    try {
      final result = await _webViewController!.evaluateJavascript(
        source: 'document.cookie',
      );
      setState(() {
        _cookies = result?.toString() ?? '';
      });
      LogManager().debug('获取Cookie成功');
    } catch (e) {
      LogManager().error('获取Cookie失败: $e');
    }
  }

  /// 清除Cookie
  Future<void> _clearCookies() async {
    try {
      await CookieManager.instance().deleteAllCookies();
      setState(() {
        _cookies = '';
      });
      LogManager().debug('清除Cookie成功');
      _updateStatus('Cookie已清除');
    } catch (e) {
      LogManager().error('清除Cookie失败: $e');
    }
  }

  /// 获取LocalStorage
  Future<void> _getLocalStorage() async {
    if (_webViewController == null) return;

    try {
      final result = await _webViewController!.evaluateJavascript(
        source: 'JSON.stringify(localStorage)',
      );
      setState(() {
        _localStorage = result?.toString() ?? '';
      });
      LogManager().debug('获取LocalStorage成功');
    } catch (e) {
      LogManager().error('获取LocalStorage失败: $e');
    }
  }

  /// 清除LocalStorage
  Future<void> _clearLocalStorage() async {
    if (_webViewController == null) return;

    try {
      await _webViewController!.evaluateJavascript(
        source: 'localStorage.clear()',
      );
      setState(() {
        _localStorage = '';
      });
      LogManager().debug('清除LocalStorage成功');
      _updateStatus('LocalStorage已清除');
    } catch (e) {
      LogManager().error('清除LocalStorage失败: $e');
    }
  }

  /// 获取SessionStorage
  Future<void> _getSessionStorage() async {
    if (_webViewController == null) return;

    try {
      final result = await _webViewController!.evaluateJavascript(
        source: 'JSON.stringify(sessionStorage)',
      );
      setState(() {
        _sessionStorage = result?.toString() ?? '';
      });
      LogManager().debug('获取SessionStorage成功');
    } catch (e) {
      LogManager().error('获取SessionStorage失败: $e');
    }
  }

  /// 清除SessionStorage
  Future<void> _clearSessionStorage() async {
    if (_webViewController == null) return;

    try {
      await _webViewController!.evaluateJavascript(
        source: 'sessionStorage.clear()',
      );
      setState(() {
        _sessionStorage = '';
      });
      LogManager().debug('清除SessionStorage成功');
      _updateStatus('SessionStorage已清除');
    } catch (e) {
      LogManager().error('清除SessionStorage失败: $e');
    }
  }

  /// 处理菜单操作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_cache':
        _clearCache();
        break;
      case 'clear_cookies':
        _clearCookies();
        break;
      case 'get_info':
        _getPageInfo();
        break;
      case 'inject_js':
        _injectJavaScript();
        break;
    }
  }

  /// 清除缓存
  Future<void> _clearCache() async {
    try {
      await _webViewController?.clearCache();
      LogManager().debug('清除缓存成功');
      _updateStatus('缓存已清除');
    } catch (e) {
      LogManager().error('清除缓存失败: $e');
    }
  }

  /// 注入JavaScript
  Future<void> _injectJavaScript() async {
    if (_webViewController == null) return;

    try {
      final result = await _webViewController!.evaluateJavascript(
        source: '''
          // 注入测试JavaScript
          document.body.style.border = '5px solid red';
          alert('JavaScript注入成功！');
          'JavaScript执行完成';
        ''',
      );
      LogManager().debug('JavaScript注入结果: $result');
      _updateStatus('JavaScript注入成功');
    } catch (e) {
      LogManager().error('JavaScript注入失败: $e');
    }
  }
}
