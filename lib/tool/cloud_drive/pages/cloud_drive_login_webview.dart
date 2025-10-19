import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../config/cloud_drive_ui_config.dart';
import '../data/models/cloud_drive_entities.dart';
import '../presentation/widgets/login/login.dart';
import '../../../../core/logging/log_manager.dart';

/// 云盘登录WebView页面 - 重构版本
class CloudDriveLoginWebView extends StatefulWidget {
  final CloudDriveType cloudDriveType;
  final String accountName;
  final Future<void> Function(String cookies) onLoginSuccess;

  const CloudDriveLoginWebView({
    super.key,
    required this.cloudDriveType,
    required this.accountName,
    required this.onLoginSuccess,
  });

  @override
  State<CloudDriveLoginWebView> createState() => _CloudDriveLoginWebViewState();
}

class _CloudDriveLoginWebViewState extends State<CloudDriveLoginWebView> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _statusMessage;
  InAppWebViewController? _webViewController;
  double _currentZoom = 1.0;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_getCloudDriveName()} 登录'),
        backgroundColor: CloudDriveUIConfig.primaryActionColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 登录状态显示
          LoginStatusDisplay(
            cloudDriveType: widget.cloudDriveType,
            accountName: widget.accountName,
            isLoading: _isLoading,
            isLoggedIn: _isLoggedIn,
            statusMessage: _statusMessage,
            onRetry: _manualCheckLogin,
          ),

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

          // WebView
          Expanded(child: _buildWebView()),

          // 登录说明
          LoginInstructions(
            cloudDriveType: widget.cloudDriveType,
            onClose: _hideInstructions,
          ),
        ],
      ),
    );
  }

  /// 构建WebView
  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(_getLoginUrl().toString())),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        clearCache: true,
        cacheEnabled: false,
        userAgent: _getUserAgent(),
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        LogManager().cloudDrive('WebView已创建');
      },
      onLoadStart: (controller, url) {
        setState(() {
          _isLoading = true;
          _statusMessage = '正在加载页面...';
        });
        LogManager().cloudDrive('开始加载: $url');
      },
      onLoadStop: (controller, url) {
        setState(() {
          _isLoading = false;
          _statusMessage = '页面加载完成，请完成登录';
        });
        LogManager().cloudDrive('页面加载完成: $url');
      },
      onReceivedError: (controller, request, error) {
        setState(() {
          _isLoading = false;
          _statusMessage = '加载失败: ${error.description}';
        });
        LogManager().error('WebView加载错误: ${error.description}');
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) {
        _checkLoginStatus(url);
      },
      onProgressChanged: (controller, progress) {
        if (progress == 100) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  /// 获取登录URL
  Uri _getLoginUrl() {
    switch (widget.cloudDriveType) {
      case CloudDriveType.ali:
        return Uri.parse('https://passport.alipan.com/login');
      case CloudDriveType.baidu:
        return Uri.parse('https://passport.baidu.com/v2/?login');
      case CloudDriveType.quark:
        return Uri.parse('https://pan.quark.cn/login');
      case CloudDriveType.lanzou:
        return Uri.parse('https://up.woozooo.com/account.php');
      case CloudDriveType.pan123:
        return Uri.parse('https://www.123pan.com/login');
      default:
        return Uri.parse('https://www.baidu.com');
    }
  }

  /// 获取UserAgent
  String _getUserAgent() {
    return 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1';
  }

  /// 检查登录状态
  void _checkLoginStatus(Uri? url) {
    if (url == null) return;

    // 根据URL判断是否登录成功
    final urlString = url.toString();
    bool isLoginSuccess = false;

    switch (widget.cloudDriveType) {
      case CloudDriveType.ali:
        isLoginSuccess =
            urlString.contains('alipan.com') && !urlString.contains('login');
        break;
      case CloudDriveType.baidu:
        isLoginSuccess = urlString.contains('pan.baidu.com');
        break;
      case CloudDriveType.quark:
        isLoginSuccess =
            urlString.contains('pan.quark.cn') && !urlString.contains('login');
        break;
      case CloudDriveType.lanzou:
        isLoginSuccess =
            urlString.contains('up.woozooo.com') &&
            !urlString.contains('login');
        break;
      case CloudDriveType.pan123:
        isLoginSuccess =
            urlString.contains('123pan.com') && !urlString.contains('login');
        break;
      default:
        break;
    }

    if (isLoginSuccess && !_isLoggedIn) {
      _handleLoginSuccess();
    }
  }

  /// 处理登录成功
  void _handleLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
      _statusMessage = '登录成功！正在获取登录信息...';
    });

    _getCookies()
        .then((cookies) {
          if (cookies.isNotEmpty) {
            widget.onLoginSuccess(cookies);
            setState(() {
              _statusMessage = '登录信息获取成功';
            });
          } else {
            setState(() {
              _statusMessage = '登录成功，但无法获取登录信息';
            });
          }
        })
        .catchError((error) {
          setState(() {
            _statusMessage = '登录成功，但获取信息失败: $error';
          });
          LogManager().error('获取登录信息失败: $error');
        });
  }

  /// 获取Cookies
  Future<String> _getCookies() async {
    if (_webViewController == null) return '';

    try {
      // TODO: 修复getCookies API调用
      // final cookies = await _webViewController!.getCookies(
      //   url: WebUri(_getLoginUrl().toString()),
      // );
      // final cookieString = cookies.entries
      //     .map((e) => '${e.key}=${e.value}')
      //     .join('; ');

      // LogManager().cloudDrive('获取到Cookies: ${cookieString.length} 字符');
      // return cookieString;

      // 临时返回空字符串
      LogManager().cloudDrive('获取到Cookies: 临时返回空字符串');
      return '';
    } catch (e) {
      LogManager().error('获取Cookies失败: $e');
      return '';
    }
  }

  /// 手动检查登录
  void _manualCheckLogin() {
    if (_webViewController == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = '正在检查登录状态...';
    });

    _webViewController!.getUrl().then((url) {
      _checkLoginStatus(url);
      setState(() {
        _isLoading = false;
      });
    });
  }

  /// 后退
  void _goBack() {
    _webViewController?.goBack();
  }

  /// 前进
  void _goForward() {
    _webViewController?.goForward();
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

  /// 隐藏说明
  void _hideInstructions() {
    // TODO: 实现隐藏说明的逻辑
  }

  /// 获取云盘名称
  String _getCloudDriveName() {
    switch (widget.cloudDriveType) {
      case CloudDriveType.ali:
        return '阿里云盘';
      case CloudDriveType.baidu:
        return '百度网盘';
      case CloudDriveType.quark:
        return '夸克云盘';
      case CloudDriveType.lanzou:
        return '蓝奏云';
      case CloudDriveType.pan123:
        return '123云盘';
      default:
        return '云盘';
    }
  }
}
