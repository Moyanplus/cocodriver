import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_configs.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../services/registry/cloud_drive_provider_descriptor.dart';
import '../../../../../../core/logging/log_manager.dart';
import '../../../services/registry/cloud_drive_provider_registry.dart';
import '../../widgets/login/webview_toolbar.dart';

/// 云盘登录页面
///
/// 使用 WebView 实现各云盘平台的登录功能

class CloudDriveLoginPage extends StatefulWidget {
  final CloudDriveType cloudDriveType;
  final String accountName;
  final Future<void> Function(String cookies) onLoginSuccess;

  const CloudDriveLoginPage({
    super.key,
    required this.cloudDriveType,
    required this.accountName,
    required this.onLoginSuccess,
  });

  @override
  State<CloudDriveLoginPage> createState() => _CloudDriveLoginPageState();
}

class CloudDriveLoginController {
  CloudDriveLoginController(this.type)
    : descriptor =
          CloudDriveProviderRegistry.get(type) ??
          (throw StateError('未注册云盘描述: $type')) {
    loginUri = _resolveLoginUrl();
    userAgent = _resolveUserAgent();
  }

  final CloudDriveType type;
  final CloudDriveProviderDescriptor descriptor;
  late final Uri loginUri;
  late final String userAgent;

  LoginDetectionConfig? get detection =>
      type.webViewConfig.loginDetectionConfig;

  Uri _resolveLoginUrl() {
    final initial = type.webViewConfig.initialUrl;
    if (initial != null && initial.isNotEmpty) {
      return Uri.parse(initial);
    }
    throw StateError('未提供登录地址: $type');
  }

  String _resolveUserAgent() {
    final uaType = type.webViewConfig.userAgentType;
    if (uaType != null) return uaType.userAgent;
    final custom = type.webViewConfig.userAgent;
    if (custom != null && custom.isNotEmpty) return custom;
    return 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1';
  }

  bool isLoginSuccess(Uri url) {
    final detection = this.detection;
    final urlString = url.toString();
    if (detection == null) return false;

    if (detection.successUrl != null &&
        detection.successUrl!.isNotEmpty &&
        urlString.contains(detection.successUrl!)) {
      return true;
    }

    if (detection.successIndicators.isNotEmpty) {
      return detection.successIndicators.any(urlString.contains);
    }
    return false;
  }

  Future<String> collectCookies(InAppWebViewController controller) async {
    final cookies = await CookieManager.instance().getCookies(
      url: WebUri(loginUri.toString()),
    );
    if (cookies.isEmpty) return '';
    final cookieString = cookies.map((c) => '${c.name}=${c.value}').join('; ');
    LogManager().cloudDrive('获取到Cookies: ${cookieString.length} 字符');
    return cookieString;
  }
}

class _CloudDriveLoginPageState extends State<CloudDriveLoginPage> {
  late final CloudDriveLoginController _controller = CloudDriveLoginController(
    widget.cloudDriveType,
  );

  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _canGoBack = false;
  bool _canGoForward = false;
  String? _errorMessage;
  InAppWebViewController? _webViewController;
  double _currentZoom = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_controller.descriptor.displayName ?? widget.cloudDriveType.name} 登录',
        ),
        backgroundColor: CloudDriveUIConfig.primaryActionColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // WebView工具栏
          WebViewToolbar(
            canGoBack: _canGoBack,
            canGoForward: _canGoForward,
            isLoading: _isLoading,
            currentZoom: _currentZoom,
            onBack: _goBack,
            onForward: _goForward,
            onRefresh: _refreshWebView,
            onStop: _stopLoading,
            onZoomChanged: _changeZoom,
            onManualCheck: _manualCheckLogin,
          ),
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () => setState(() => _errorMessage = null),
                  ),
                ],
              ),
            ),

          // WebView with loading overlay
          Expanded(
            child: Stack(
              children: [
                _buildWebView(),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.05),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建WebView
  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(_controller.loginUri.toString()),
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        clearCache: true,
        cacheEnabled: false,
        userAgent: _controller.userAgent,
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        LogManager().cloudDrive('WebView已创建');
      },
      onLoadStart: (controller, url) {
        _setLoading(true);
        _setError(null);
        LogManager().cloudDrive('开始加载: $url');
      },
      onLoadStop: (controller, url) {
        _setLoading(false);
        LogManager().cloudDrive('页面加载完成: $url');
        _updateNavigationState();
        _checkLoginStatus(url);
      },
      onReceivedError: (controller, request, error) {
        _setLoading(false);
        _setError(error.description);
        LogManager().error('WebView加载错误: ${error.description}');
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) {
        _checkLoginStatus(url);
        _updateNavigationState();
      },
      onProgressChanged: (controller, progress) {
        if (progress == 100) {
          _setLoading(false);
        }
      },
      shouldOverrideUrlLoading: (controller, action) async {
        // 保持导航状态及时更新
        _updateNavigationState();
        return NavigationActionPolicy.ALLOW;
      },
    );
  }

  /// 检查登录状态
  void _checkLoginStatus(Uri? url) {
    if (url == null) return;

    if (_controller.isLoginSuccess(url) && !_isLoggedIn) {
      _handleLoginSuccess();
    }
  }

  /// 处理登录成功
  void _handleLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });

    _getCookies()
        .then((cookies) {
          if (cookies.isNotEmpty) {
            widget.onLoginSuccess(cookies);
          }
        })
        .catchError((error) {
          LogManager().error('获取登录信息失败: $error');
        });
  }

  /// 获取Cookies
  Future<String> _getCookies() async {
    if (_webViewController == null) return '';

    try {
      return await _controller.collectCookies(_webViewController!);
    } catch (e) {
      LogManager().error('获取Cookies失败: $e');
      return '';
    }
  }

  /// 手动检查登录
  void _manualCheckLogin() {
    if (_webViewController == null) return;

    _setLoading(true);

    _webViewController!.getUrl().then((url) {
      _checkLoginStatus(url);
      _setLoading(false);
    });
  }

  /// 后退
  void _goBack() {
    _webViewController?.goBack();
    _updateNavigationState();
  }

  /// 前进
  void _goForward() {
    _webViewController?.goForward();
    _updateNavigationState();
  }

  /// 刷新WebView
  void _refreshWebView() {
    _webViewController?.reload();
  }

  /// 停止加载
  void _stopLoading() {
    _webViewController?.stopLoading();
    setState(() {
      _isLoading = false;
    });
  }

  /// 改变缩放
  void _changeZoom(double newZoom) {
    // TODO: 实现缩放功能
    // _webViewController?.setZoomScale(zoomScale: newZoom, animated: true);
    setState(() {
      _currentZoom = newZoom;
    });
  }

  Future<void> _updateNavigationState() async {
    if (_webViewController == null) return;
    try {
      final canBack = await _webViewController!.canGoBack();
      final canForward = await _webViewController!.canGoForward();
      if (!mounted) return;
      setState(() {
        _canGoBack = canBack;
        _canGoForward = canForward;
      });
    } catch (e) {
      LogManager().error('更新导航状态失败: $e');
    }
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() => _isLoading = value);
  }

  void _setError(String? message) {
    if (!mounted) return;
    setState(() => _errorMessage = message);
  }
}
