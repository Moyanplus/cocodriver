import 'dart:async';

// import 'dart:convert';
// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/logging/log_manager.dart';
import '../utils/token_parser.dart';
import '../models/cloud_drive_models.dart';

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
  // 新增：累积所有规则需要的 cookie
  final Map<String, String> _cookieMap = {};
  // 新增：WebView 控制器和缩放比例
  InAppWebViewController? _webViewController;
  double _currentZoom = 1.0;
  // 新增：123云盘登录成功后的token

  // 提取 set-cookie 字段中的 name=value
  String extractCookies(String setCookieHeader, List<String> targetNames) {
    LogManager().cloudDrive('🔍 开始提取cookie: $setCookieHeader');
    LogManager().cloudDrive('🎯 目标cookie: $targetNames');

    final cookies = <String, String>{};

    // 首先尝试按逗号分割（标准的多个set-cookie格式）
    final cookieParts = setCookieHeader.split(RegExp(r',(?=[^ ;]+=)'));
    LogManager().cloudDrive('🍪 按逗号分割的cookie部分数量: ${cookieParts.length}');

    for (final part in cookieParts) {
      // 对于每个part，按分号分割获取所有的name=value对
      final segments = part.split(';');
      LogManager().cloudDrive('🔍 处理cookie部分: $part');
      LogManager().cloudDrive('🍪 分号分割的段数: ${segments.length}');

      for (final segment in segments) {
        final kv = segment.trim();
        final eqIdx = kv.indexOf('=');
        if (eqIdx > 0) {
          final name = kv.substring(0, eqIdx).trim();
          final value = kv.substring(eqIdx + 1).trim();

          // 跳过cookie属性（如path, max-age, expires等）
          if (![
            'path',
            'max-age',
            'expires',
            'domain',
            'httponly',
            'secure',
            'samesite',
          ].contains(name.toLowerCase())) {
            LogManager().cloudDrive('🍪 解析cookie: $name = $value');

            if (targetNames.contains(name)) {
              cookies[name] = value;
              LogManager().cloudDrive('✅ 匹配目标cookie: $name = $value');
            }
          } else {
            LogManager().cloudDrive('⏭️ 跳过cookie属性: $name = $value');
          }
        }
      }
    }

    final result = cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    LogManager().cloudDrive('🎯 提取结果: $result');
    return result;
  }

  // 新增：调整缩放比例
  Future<void> _adjustZoom(double delta) async {
    if (_webViewController != null) {
      final newZoom = (_currentZoom + delta).clamp(0.25, 3.0);
      try {
        await _webViewController!.evaluateJavascript(
          source: 'document.body.style.zoom = "$newZoom"',
        );
        setState(() {
          _currentZoom = newZoom;
        });
        LogManager().cloudDrive(
          '🔍 缩放比例调整为: ${(_currentZoom * 100).toStringAsFixed(0)}%',
        );
      } catch (e) {
        LogManager().error('❌ 调整缩放失败: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // 通用登录检测配置
    final config = widget.cloudDriveType.webViewConfig;
    if (config.loginDetectionConfig?.enableAutoDetection == true) {
      _setupGenericLoginListener(config.loginDetectionConfig!);
    }
  }

  @override
  void dispose() {
    // 清理WebView资源
    _webViewController = null;
    LogManager().cloudDrive('🧹 WebView资源已清理');
    super.dispose();
  }

  /// 通用登录监听器
  void _setupGenericLoginListener(LoginDetectionConfig detectionConfig) {
    LogManager().cloudDrive('🔧 开始设置${widget.cloudDriveType.displayName}登录监听');
    LogManager().cloudDrive(
      '⚙️ 检测方法: ${detectionConfig.detectionMethod}, 间隔: ${detectionConfig.checkInterval.inSeconds}秒',
    );

    int retryCount = 0;

    // 定期检查登录状态
    Timer.periodic(detectionConfig.checkInterval, (timer) async {
      if (!mounted) {
        LogManager().cloudDrive('⚠️ WebView已销毁，停止监听');
        timer.cancel();
        return;
      }

      retryCount++;
      if (retryCount > detectionConfig.maxRetries) {
        LogManager().cloudDrive(
          '⏰ ${widget.cloudDriveType.displayName}登录检测超时，停止监听',
        );
        timer.cancel();
        return;
      }

      LogManager().cloudDrive(
        '🔍 检查${widget.cloudDriveType.displayName}登录状态... (${retryCount}/${detectionConfig.maxRetries})',
      );

      bool isLoggedIn = false;

      // 根据检测方法进行不同的检测
      switch (detectionConfig.detectionMethod) {
        case 'token':
          final token = await _getAuthorizationToken();
          isLoggedIn = token.isNotEmpty;
          if (isLoggedIn) {
            LogManager().cloudDrive(
              '🔑 检测到token: ${token.substring(0, token.length > 50 ? 50 : token.length)}...',
            );
          }
          break;

        case 'url':
          if (_webViewController != null) {
            final currentUrl = await _webViewController!.getUrl();
            if (currentUrl != null) {
              final url = currentUrl.toString();
              isLoggedIn = detectionConfig.successIndicators.any(
                (indicator) => url.contains(indicator),
              );
              if (isLoggedIn) {
                LogManager().cloudDrive('🌐 检测到登录成功URL: $url');
              }
            }
          }
          break;

        case 'cookie':
          final cookies = await _getCookies();
          // 使用Cookie处理配置的priorityCookieNames进行检测
          final config = widget.cloudDriveType.webViewConfig;
          final cookieConfig =
              config.cookieProcessingConfig ??
              CookieProcessingConfig.defaultConfig;

          LogManager().cloudDrive(
            '🔍 检查Cookie: ${cookieConfig.priorityCookieNames}',
          );
          LogManager().cloudDrive(
            '🍪 获取到的Cookie: ${cookies.isNotEmpty ? '有' : '无'}',
          );

          // 检查是否包含所有必需的Cookie
          final requiredCookies = cookieConfig.requiredCookies;
          isLoggedIn =
              cookies.isNotEmpty &&
              requiredCookies.every(
                (cookieName) => cookies.contains(cookieName),
              );

          if (isLoggedIn) {
            LogManager().cloudDrive('🍪 检测到登录成功Cookie: 所有必需Cookie都存在');
          } else {
            LogManager().cloudDrive('🍪 登录检测失败: 缺少必需的Cookie');
            // 详细检查每个必需Cookie
            for (final cookieName in requiredCookies) {
              final hasCookie = cookies.contains(cookieName);
              LogManager().cloudDrive(
                '🍪 $cookieName: ${hasCookie ? '存在' : '缺失'}',
              );
            }
          }
          break;
      }

      if (isLoggedIn && !_isLoggedIn) {
        LogManager().cloudDrive(
          '🎉 检测到${widget.cloudDriveType.displayName}登录成功！',
        );

        setState(() {
          _isLoggedIn = true;
        });
        timer.cancel();
        LogManager().cloudDrive(
          '✅ ${widget.cloudDriveType.displayName}登录监听完成，停止定时器',
        );
      } else if (isLoggedIn) {
        LogManager().cloudDrive('✅ 已登录状态，停止监听');
        timer.cancel();
      } else {
        LogManager().cloudDrive('⏳ 未检测到登录成功，继续监听...');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.cloudDriveType.webViewConfig;
    // final rules = config.cookieCaptureRules; // 暂时注释掉
    return Scaffold(
      appBar: AppBar(
        title: Text('登录${widget.cloudDriveType.displayName}'),
        actions: [
          // 取消按钮
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: '取消登录',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: () {
              _webViewController?.reload();
            },
          ),
          // 缩放比例显示和调整
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_out),
                onPressed: () => _adjustZoom(-0.25),
                tooltip: '缩小',
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${(_currentZoom * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in),
                onPressed: () => _adjustZoom(0.25),
                tooltip: '放大',
              ),
            ],
          ),
          // 测试按钮 - 手动获取Cookie
          IconButton(
            icon: const Icon(Icons.cookie, color: Colors.orange),
            onPressed: () async {
              LogManager().cloudDrive('🧪 手动测试获取Cookie');
              final cookies = await _getCookies();
              LogManager().cloudDrive(
                '🍪 测试结果: ${cookies.isNotEmpty ? '成功' : '失败'}',
              );
              if (cookies.isNotEmpty) {
                LogManager().cloudDrive('🍪 Cookie内容: $cookies');
              }
            },
            tooltip: '测试获取Cookie',
          ),
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: _confirmLogin,
              tooltip: '确认登录',
            ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(config.initialUrl ?? 'https://www.123pan.com/'),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              userAgent: config.effectiveUserAgent, // 使用新的UserAgent配置方法
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
              useShouldInterceptRequest: false, // 暂时禁用请求拦截
              // 启用手势缩放
              supportZoom: true,
              displayZoomControls: false, // 不显示缩放控制按钮
              builtInZoomControls: true, // 启用内置缩放控制
              // 减少错误提示
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              // 禁用一些不必要的功能
              allowFileAccess: false,
              allowContentAccess: false,
              // 减少日志输出
              domStorageEnabled: true,
              databaseEnabled: true, // 启用数据库支持
              // 错误处理相关设置
              allowsLinkPreview: false,
              isFraudulentWebsiteWarningEnabled: false,
              allowsBackForwardNavigationGestures: true,
              // 性能优化
              cacheEnabled: true,
              clearCache: false,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            // 暂时注释掉请求拦截功能
            // shouldInterceptRequest: (controller, request) async {
            //   // 检查是否启用请求拦截
            //   final interceptConfig =
            //       config.requestInterceptConfig ??
            //       RequestInterceptConfig.cookieBasedConfig;
            //   if (!interceptConfig.enableRequestIntercept) {
            //     LogManager().cloudDrive('⏭️ 请求拦截已禁用，跳过拦截: ${request.url}');
            //     return null;
            //   }

            //   // 检查是否为跳过拦截的认证类型
            //   final authTypeString = widget.cloudDriveType.authType.name;
            //   if (interceptConfig.skipInterceptForAuthTypes.contains(
            //     authTypeString,
            //   )) {
            //     LogManager().cloudDrive(
            //       '⏭️ 认证类型 $authTypeString 跳过拦截: ${request.url}',
            //     );
            //     return null;
            //   }

            //   // 多步多 cookie 捕获
            //   for (final rule in rules) {
            //     if (request.url.toString().contains(rule.urlPattern)) {
            //       LogManager().cloudDrive('🔍 拦截: ${rule.urlPattern}');
            //       try {
            //         // 获取多个域名的 cookie
            //         String? webviewCookies;
            //         if (rule.cookieDomains.isNotEmpty) {
            //           final allCookies = <String>[];
            //           for (final domain in rule.cookieDomains) {
            //             try {
            //               final cookies = await CookieManager.instance()
            //                   .getCookies(url: WebUri(domain));
            //               if (cookies.isNotEmpty) {
            //                 final domainCookies = cookies
            //                     .map((c) => '${c.name}=${c.value}')
            //                     .join('; ');
            //                 allCookies.add(domainCookies);
            //               }
            //             } catch (e) {
            //               LogManager().cloudDrive('⚠️ 获取Cookie失败: $domain');
            //             }
            //           }
            //           webviewCookies = allCookies.join('; ');
            //         }

            //         final headers = <String, String>{};
            //         if (request.headers != null) {
            //           headers.addAll(request.headers!);
            //         }
            //         headers['User-Agent'] =
            //             config.effectiveUserAgent; // 使用配置化UserAgent
            //         if (webviewCookies != null && webviewCookies.isNotEmpty) {
            //           headers['Cookie'] = webviewCookies;
            //         }

            //         final response = await Dio().get(
            //           request.url.toString(),
            //           options: Options(headers: headers),
            //         );

            //         // 提取 cookie
            //         final setCookies = <String>[];
            //         response.headers.forEach((name, values) {
            //           if (name.toLowerCase() == 'set-cookie') {
            //             setCookies.addAll(values);
            //           }
            //         });
            //         final setCookiesString = setCookies.join('; ');

            //         LogManager().cloudDrive(
            //           '🍪 原始set-cookie: $setCookiesString',
            //         );

            //         final extracted = extractCookies(
            //           setCookiesString,
            //           rule.cookieNames,
            //         );

            //         LogManager().cloudDrive('🍪 提取的cookie: $extracted');

            //         if (extracted.isNotEmpty) {
            //           for (final kv in extracted.split(';')) {
            //             final parts = kv.trim().split('=');
            //             if (parts.length == 2) {
            //               _cookieMap[parts[0]] = parts[1];
            //               LogManager().cloudDrive(
            //                 '🍪 保存cookie: ${parts[0]} = ${parts[1]}',
            //               );
            //             }
            //           }
            //           LogManager().cloudDrive('✅ 捕获: $extracted');
            //         } else {
            //           LogManager().cloudDrive('⚠️ 未提取到任何cookie');
            //         }

            //         // 检查是否所有 cookie 都已捕获
            //         final allNames = rules.expand((r) => r.cookieNames).toSet();
            //         final allGot = allNames.every(_cookieMap.containsKey);
            //         if (allGot && !_isLoggedIn) {
            //           final merged = allNames
            //               .map((k) => '$k=${_cookieMap[k]}')
            //               .join('; ');
            //           setState(() {
            //             _isLoggedIn = true;
            //           });
            //           LogManager().cloudDrive('🎉 登录成功: $merged');
            //         }

            //         // 转换响应头格式
            //         final responseHeaders = <String, String>{};
            //         response.headers.forEach((name, values) {
            //           if (values.isNotEmpty) {
            //             responseHeaders[name] = values.first;
            //           }
            //         });

            //         return WebResourceResponse(
            //           contentType:
            //               responseHeaders['content-type'] ?? 'application/json',
            //           contentEncoding: 'utf-8',
            //           data: Uint8List.fromList(
            //             utf8.encode(response.data.toString()),
            //           ),
            //           statusCode: response.statusCode ?? 200,
            //           reasonPhrase: response.statusMessage ?? 'OK',
            //           headers: responseHeaders,
            //         );
            //       } catch (e) {
            //         LogManager().error('❌ 请求失败: $e');
            //         return null;
            //       }
            //     }
            //   }
            //   return null;
            // },
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) async {
              setState(() => _isLoading = false);
              // 获取当前缩放比例
              try {
                final zoomResult = await controller.evaluateJavascript(
                  source: 'document.body.style.zoom || "1"',
                );
                final zoomLevel =
                    double.tryParse(zoomResult?.toString() ?? '1') ?? 1.0;
                setState(() {
                  _currentZoom = zoomLevel;
                });
              } catch (e) {
                LogManager().error('❌ 获取缩放比例失败: $e');
              }
            },
            // 添加错误处理回调
            onReceivedError: (controller, request, error) {
              setState(() {
                _isLoading = false;
              });
              LogManager().error('❌ WebView错误: ${error.description}');
              LogManager().cloudDrive('❌ 加载失败: ${error.description}');
            },
            onReceivedHttpError: (controller, request, errorResponse) {
              setState(() {
                _isLoading = false;
              });
              LogManager().error('❌ HTTP错误: ${errorResponse.statusCode}');
              LogManager().cloudDrive('❌ HTTP错误: ${errorResponse.statusCode}');
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              // 接受所有SSL证书（用于云盘登录）
              LogManager().cloudDrive(
                '🔒 SSL证书验证: ${challenge.protectionSpace.host}',
              );
              return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED,
              );
            },
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_isLoggedIn)
            Positioned(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8.w),
                    const Expanded(
                      child: Text(
                        '登录成功！点击右上角按钮确认',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 手动检测登录状态的FAB
          Positioned(
            bottom: 32.h,
            right: 32.w,
            child: FloatingActionButton.extended(
              heroTag: 'checkLogin',
              onPressed: _isLoggedIn ? _confirmLogin : _manualCheckLogin,
              backgroundColor: _isLoggedIn ? Colors.green : Colors.blue,
              icon: Icon(_isLoggedIn ? Icons.check : Icons.search),
              label: Text(_isLoggedIn ? '完成并返回' : '检测登录'),
            ),
          ),
        ],
      ),
    );
  }

  /// 手动检测登录状态
  Future<void> _manualCheckLogin() async {
    if (_webViewController == null) {
      LogManager().cloudDrive('❌ WebView控制器为空，无法检测登录状态');
      _showSnackBar('WebView未初始化，无法检测登录状态');
      return;
    }

    LogManager().cloudDrive('🔍 开始手动检测登录状态...');
    _showSnackBar('正在检测登录状态...');

    try {
      final config = widget.cloudDriveType.webViewConfig;
      final detectionConfig = config.loginDetectionConfig;

      if (detectionConfig == null) {
        LogManager().cloudDrive('❌ 未配置登录检测');
        _showSnackBar('未配置登录检测');
        return;
      }

      bool isLoggedIn = false;
      String detectionResult = '';

      // 根据检测方法进行检测
      switch (detectionConfig.detectionMethod) {
        case 'token':
          final token = await _getAuthorizationToken();
          isLoggedIn = token.isNotEmpty;
          detectionResult = isLoggedIn ? '检测到Token' : '未检测到Token';
          break;

        case 'url':
          final currentUrl = await _webViewController!.getUrl();
          if (currentUrl != null) {
            final url = currentUrl.toString();
            isLoggedIn = detectionConfig.successIndicators.any(
              (indicator) => url.contains(indicator),
            );
            detectionResult = isLoggedIn ? 'URL匹配成功' : 'URL不匹配';
          } else {
            detectionResult = '无法获取当前URL';
          }
          break;

        case 'cookie':
          final cookies = await _getCookies();
          final cookieConfig =
              config.cookieProcessingConfig ??
              CookieProcessingConfig.defaultConfig;

          // 检查必需Cookie
          final requiredCookies = cookieConfig.requiredCookies;
          isLoggedIn =
              cookies.isNotEmpty &&
              requiredCookies.every(
                (cookieName) => cookies.contains(cookieName),
              );

          if (isLoggedIn) {
            detectionResult = '检测到所有必需Cookie';
          } else {
            final missingCookies =
                requiredCookies
                    .where((cookieName) => !cookies.contains(cookieName))
                    .toList();
            detectionResult = '缺少必需Cookie: ${missingCookies.join(', ')}';
          }
          break;
      }

      LogManager().cloudDrive('🔍 检测结果: $detectionResult');

      if (isLoggedIn && !_isLoggedIn) {
        setState(() {
          _isLoggedIn = true;
        });
        _showSnackBar('✅ 登录检测成功！');
        LogManager().cloudDrive(
          '🎉 手动检测到${widget.cloudDriveType.displayName}登录成功！',
        );
      } else if (isLoggedIn) {
        _showSnackBar('✅ 已登录状态');
      } else {
        _showSnackBar('❌ $detectionResult');
      }
    } catch (e) {
      LogManager().error('❌ 手动检测登录状态失败: $e');
      _showSnackBar('检测失败: $e');
    }
  }

  /// 显示提示消息
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  /// 确认登录
  Future<void> _confirmLogin() async {
    if (_webViewController == null) {
      LogManager().cloudDrive('❌ WebView控制器为空，无法确认登录');
      return;
    }

    try {
      LogManager().cloudDrive('🔐 开始确认登录流程');
      LogManager().cloudDrive('👤 云盘类型: ${widget.cloudDriveType.displayName}');
      LogManager().cloudDrive('🔑 认证方式: ${widget.cloudDriveType.authType}');

      String authData = '';

      // 根据认证方式获取不同的认证数据
      switch (widget.cloudDriveType.authType) {
        case AuthType.cookie:
          LogManager().cloudDrive('🍪 使用Cookie认证方式');
          // 获取Cookie
          authData = await _getCookies();
          if (authData.isEmpty) {
            LogManager().cloudDrive('❌ 未获取到Cookie');
            return;
          }
          LogManager().cloudDrive('✅ 获取到Cookie: ${authData.length} 个字符');
          LogManager().cloudDrive('🍪 Cookie内容预览: $authData');
          break;

        case AuthType.authorization:
          LogManager().cloudDrive('🔑 使用Authorization Token认证方式');
          // 获取Authorization Token
          authData = await _getAuthorizationToken();
          if (authData.isEmpty) {
            LogManager().cloudDrive('❌ 未获取到Authorization Token');
            return;
          }
          LogManager().cloudDrive(
            '✅ 获取到Authorization Token: ${authData.length} 个字符',
          );
          LogManager().cloudDrive(
            '🔑 Token内容预览: ${authData.substring(0, authData.length > 100 ? 100 : authData.length)}...',
          );
          break;
        case AuthType.qrCode:
          // TODO: Handle this case.
          throw UnimplementedError();
      }

      LogManager().cloudDrive('📤 准备调用登录成功回调');

      // 调用登录成功回调
      await widget.onLoginSuccess(authData);

      LogManager().cloudDrive('✅ 登录成功回调执行完成');

      // 执行登录后处理（如果配置要求）
      final config = widget.cloudDriveType.webViewConfig;
      final postLoginConfig = config.postLoginConfig;
      if (postLoginConfig?.hasPostLoginProcessing == true) {
        LogManager().cloudDrive(
          '🔄 执行登录后处理: ${postLoginConfig!.postLoginMessage ?? '处理云盘特定逻辑'}',
        );

        // 执行配置的登录后动作
        for (final action in postLoginConfig.postLoginActions) {
          LogManager().cloudDrive('⚡ 执行登录后动作: $action');
        }
      }

      // 关闭WebView
      if (mounted) {
        LogManager().cloudDrive('🚪 关闭WebView页面');
        Navigator.of(context).pop();
      }
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 确认登录失败: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
    }
  }

  // Helper to get cookies from the webview
  Future<String> _getCookies() async {
    if (_webViewController == null) {
      LogManager().cloudDrive('❌ WebView控制器为空，无法获取Cookie');
      return '';
    }

    try {
      LogManager().cloudDrive('🍪 开始获取WebView Cookie');

      final config = widget.cloudDriveType.webViewConfig;
      final cookieConfig =
          config.cookieProcessingConfig ?? CookieProcessingConfig.defaultConfig;

      // 优先使用拦截器捕获的Cookie（如果配置启用）
      if (cookieConfig.useInterceptedCookies &&
          cookieConfig.priorityCookieNames.isNotEmpty) {
        LogManager().cloudDrive(
          '🔍 检查已捕获的优先Cookie: ${cookieConfig.priorityCookieNames}',
        );

        for (final cookieName in cookieConfig.priorityCookieNames) {
          if (_cookieMap.containsKey(cookieName)) {
            final priorityCookie = '$cookieName=${_cookieMap[cookieName]}';
            LogManager().cloudDrive('✅ 使用已捕获的优先Cookie: $priorityCookie');
            return priorityCookie;
          }
        }

        LogManager().cloudDrive('⚠️ 未找到已捕获的优先Cookie，尝试从document.cookie获取');
      }

      final result = await _webViewController!.evaluateJavascript(
        source: 'document.cookie',
      );

      final cookies = result?.toString() ?? '';

      LogManager().cloudDrive(
        '🍪 Cookie获取结果: ${cookies.isNotEmpty ? '成功' : '失败'}',
      );

      if (cookies.isNotEmpty) {
        LogManager().cloudDrive('🍪 获取到Cookie: ${cookies.length} 个字符');
        LogManager().cloudDrive('🍪 Cookie内容预览: $cookies');

        // 如果配置要求提取特定Cookie
        if (cookieConfig.extractSpecificCookies &&
            cookieConfig.priorityCookieNames.isNotEmpty) {
          final extractedCookie = _extractSpecificCookiesFromString(
            cookies,
            cookieConfig,
          );
          if (extractedCookie.isNotEmpty) {
            return extractedCookie;
          }
        }
      } else {
        LogManager().cloudDrive('❌ 未获取到Cookie');
      }

      return cookies;
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 获取WebView Cookie失败: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
      return '';
    }
  }

  /// 从Cookie字符串中提取特定Cookie
  String _extractSpecificCookiesFromString(
    String cookies,
    CookieProcessingConfig cookieConfig,
  ) {
    LogManager().cloudDrive(
      '🔍 从document.cookie中提取特定Cookie: ${cookieConfig.priorityCookieNames}',
    );

    final cookieMap = <String, String>{};
    for (final cookie in cookies.split(';')) {
      final trimmedCookie = cookie.trim();
      if (trimmedCookie.isEmpty) continue;

      final parts = trimmedCookie.split('=');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        final value = parts.sublist(1).join('=').trim();
        cookieMap[name] = value;
      }
    }

    // 查找优先Cookie
    for (final cookieName in cookieConfig.priorityCookieNames) {
      if (cookieMap.containsKey(cookieName)) {
        final extractedCookie = '$cookieName=${cookieMap[cookieName]}';
        LogManager().cloudDrive(
          '✅ 从document.cookie中提取到优先Cookie: $extractedCookie',
        );
        return extractedCookie;
      }
    }

    LogManager().cloudDrive('❌ document.cookie中未找到优先Cookie');
    LogManager().cloudDrive('🍪 可用的cookie: ${cookieMap.keys.toList()}');

    return '';
  }

  // Helper to get authorization token from the webview
  Future<String> _getAuthorizationToken() async {
    if (_webViewController == null) {
      LogManager().cloudDrive('❌ WebView控制器为空，无法获取token');
      return '';
    }

    try {
      LogManager().cloudDrive('🔍 开始获取Authorization Token');

      final config = widget.cloudDriveType.webViewConfig;
      final tokenConfig = config.tokenConfig;

      if (tokenConfig == null) {
        LogManager().cloudDrive('⚠️ 未配置TokenConfig，无法获取token');
        return '';
      }

      LogManager().cloudDrive(
        '📋 TokenConfig配置: localStorageKeys=${tokenConfig.localStorageKeys}, sessionStorageKeys=${tokenConfig.sessionStorageKeys}, cookieNames=${tokenConfig.cookieNames}',
      );

      // 使用配置化的token获取方式 - 简化JavaScript，只获取原始数据
      String rawData = '';

      // 按优先级获取原始数据
      for (final key in tokenConfig.localStorageKeys) {
        if (rawData.isEmpty) {
          try {
            final result = await _webViewController!.evaluateJavascript(
              source: 'localStorage.getItem("$key") || ""',
            );
            final data = result?.toString() ?? '';
            if (data.isNotEmpty) {
              LogManager().cloudDrive(
                '✅ 从localStorage.$key获取到原始数据: ${data.length}字符',
              );
              rawData = data;
              break;
            }
          } catch (e) {
            LogManager().cloudDrive('⚠️ 从localStorage.$key获取数据失败: $e');
          }
        }
      }

      // 如果localStorage中没有，尝试sessionStorage
      if (rawData.isEmpty) {
        for (final key in tokenConfig.sessionStorageKeys) {
          try {
            final result = await _webViewController!.evaluateJavascript(
              source: 'sessionStorage.getItem("$key") || ""',
            );
            final data = result?.toString() ?? '';
            if (data.isNotEmpty) {
              LogManager().cloudDrive(
                '✅ 从sessionStorage.$key获取到原始数据: ${data.length}字符',
              );
              rawData = data;
              break;
            }
          } catch (e) {
            LogManager().cloudDrive('⚠️ 从sessionStorage.$key获取数据失败: $e');
          }
        }
      }

      // 如果还是没有，尝试从cookie获取
      if (rawData.isEmpty && tokenConfig.cookieNames.isNotEmpty) {
        try {
          final result = await _webViewController!.evaluateJavascript(
            source: 'document.cookie || ""',
          );
          final cookies = result?.toString() ?? '';
          if (cookies.isNotEmpty) {
            // 简单获取cookie字符串，让TokenParser处理提取逻辑
            rawData = cookies;
            LogManager().cloudDrive('✅ 获取到cookie原始数据: ${cookies.length}字符');
          }
        } catch (e) {
          LogManager().cloudDrive('⚠️ 获取cookie数据失败: $e');
        }
      }

      LogManager().cloudDrive(
        '📜 原始数据获取完成: ${rawData.isNotEmpty ? '成功' : '失败'}',
      );

      if (rawData.isNotEmpty) {
        LogManager().cloudDrive(
          '🔑 获取到原始数据: ${rawData.substring(0, rawData.length > 100 ? 100 : rawData.length)}...',
        );
        LogManager().cloudDrive('🔑 原始数据长度: ${rawData.length} 字符');

        LogManager().cloudDrive('🔧 准备调用TokenParser.parseToken');

        // 使用TokenParser解析原始数据
        final parsedToken = TokenParser.parseToken(
          rawData,
          tokenConfig,
          widget.cloudDriveType,
        );

        LogManager().cloudDrive('🔑 TokenParser调用完成');
        LogManager().cloudDrive('🔑 解析后Token长度: ${parsedToken.length} 字符');

        return parsedToken;
      } else {
        LogManager().cloudDrive('❌ 未获取到原始数据');
      }

      return '';
    } catch (e, stackTrace) {
      LogManager().cloudDrive('❌ 获取WebView Authorization Token失败: $e');
      LogManager().cloudDrive('📄 错误堆栈: $stackTrace');
      return '';
    }
  }
}
