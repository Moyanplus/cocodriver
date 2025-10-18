import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/base/debug_service.dart';
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

  /// 根据云盘类型获取日志分类
  String get _logSubCategory {
    switch (widget.cloudDriveType) {
      case CloudDriveType.quark:
        return 'cloudDrive.quark';
      case CloudDriveType.baidu:
        return 'cloudDrive.baidu';
      case CloudDriveType.lanzou:
        return 'cloudDrive.lanzou';
      case CloudDriveType.pan123:
        return 'cloudDrive.pan123';
      case CloudDriveType.ali:
        return 'cloudDrive.ali';
    }
  }

  // 提取 set-cookie 字段中的 name=value
  String extractCookies(String setCookieHeader, List<String> targetNames) {
    DebugService.log(
      '🔍 开始提取cookie: $setCookieHeader',
      category: DebugCategory.tools,
      subCategory: _logSubCategory,
    );
    DebugService.log(
      '🎯 目标cookie: $targetNames',
      category: DebugCategory.tools,
      subCategory: _logSubCategory,
    );

    final cookies = <String, String>{};

    // 首先尝试按逗号分割（标准的多个set-cookie格式）
    final cookieParts = setCookieHeader.split(RegExp(r',(?=[^ ;]+=)'));
    DebugService.log(
      '🍪 按逗号分割的cookie部分数量: ${cookieParts.length}',
      category: DebugCategory.tools,
      subCategory: _logSubCategory,
    );

    for (final part in cookieParts) {
      // 对于每个part，按分号分割获取所有的name=value对
      final segments = part.split(';');
      DebugService.log(
        '🔍 处理cookie部分: $part',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );
      DebugService.log(
        '🍪 分号分割的段数: ${segments.length}',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );

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
            DebugService.log(
              '🍪 解析cookie: $name = $value',
              category: DebugCategory.tools,
              subCategory: _logSubCategory,
            );

            if (targetNames.contains(name)) {
              cookies[name] = value;
              DebugService.log(
                '✅ 匹配目标cookie: $name = $value',
                category: DebugCategory.tools,
                subCategory: _logSubCategory,
              );
            }
          } else {
            DebugService.log(
              '⏭️ 跳过cookie属性: $name = $value',
              category: DebugCategory.tools,
              subCategory: _logSubCategory,
            );
          }
        }
      }
    }

    final result = cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    DebugService.log(
      '🎯 提取结果: $result',
      category: DebugCategory.tools,
      subCategory: _logSubCategory,
    );
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
        DebugService.log(
          '🔍 缩放比例调整为: ${(_currentZoom * 100).toStringAsFixed(0)}%',
        );
      } catch (e) {
        DebugService.error('❌ 调整缩放失败: $e', null);
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

  /// 通用登录监听器
  void _setupGenericLoginListener(LoginDetectionConfig detectionConfig) {
    DebugService.log(
      '🔧 开始设置${widget.cloudDriveType.displayName}登录监听',
      category: DebugCategory.tools,
      subCategory: _logSubCategory,
    );
    DebugService.log(
      '⚙️ 检测方法: ${detectionConfig.detectionMethod}, 间隔: ${detectionConfig.checkInterval.inSeconds}秒',
      category: DebugCategory.tools,
      subCategory: _logSubCategory,
    );

    int retryCount = 0;

    // 定期检查登录状态
    Timer.periodic(detectionConfig.checkInterval, (timer) async {
      if (!mounted) {
        DebugService.log(
          '⚠️ WebView已销毁，停止监听',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );
        timer.cancel();
        return;
      }

      retryCount++;
      if (retryCount > detectionConfig.maxRetries) {
        DebugService.log(
          '⏰ ${widget.cloudDriveType.displayName}登录检测超时，停止监听',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );
        timer.cancel();
        return;
      }

      DebugService.log(
        '🔍 检查${widget.cloudDriveType.displayName}登录状态... (${retryCount}/${detectionConfig.maxRetries})',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );

      bool isLoggedIn = false;

      // 根据检测方法进行不同的检测
      switch (detectionConfig.detectionMethod) {
        case 'token':
          final token = await _getAuthorizationToken();
          isLoggedIn = token.isNotEmpty;
          if (isLoggedIn) {
            DebugService.log(
              '🔑 检测到token: ${token.substring(0, token.length > 50 ? 50 : token.length)}...',
              category: DebugCategory.tools,
              subCategory: _logSubCategory,
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
                DebugService.log(
                  '🌐 检测到登录成功URL: $url',
                  category: DebugCategory.tools,
                  subCategory: _logSubCategory,
                );
              }
            }
          }
          break;

        case 'cookie':
          final cookies = await _getCookies();
          isLoggedIn =
              cookies.isNotEmpty &&
              detectionConfig.successIndicators.any(
                (indicator) => cookies.contains(indicator),
              );
          if (isLoggedIn) {
            DebugService.log(
              '🍪 检测到登录成功Cookie',
              category: DebugCategory.tools,
              subCategory: _logSubCategory,
            );
          }
          break;
      }

      if (isLoggedIn && !_isLoggedIn) {
        DebugService.log(
          '🎉 检测到${widget.cloudDriveType.displayName}登录成功！',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );

        setState(() {
          _isLoggedIn = true;
        });
        timer.cancel();
        DebugService.log(
          '✅ ${widget.cloudDriveType.displayName}登录监听完成，停止定时器',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );
      } else if (isLoggedIn) {
        DebugService.log(
          '✅ 已登录状态，停止监听',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );
        timer.cancel();
      } else {
        DebugService.log(
          '⏳ 未检测到登录成功，继续监听...',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.cloudDriveType.webViewConfig;
    final rules = config.cookieCaptureRules;
    return Scaffold(
      appBar: AppBar(
        title: Text('登录${widget.cloudDriveType.displayName}'),
        actions: [
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
              useShouldInterceptRequest: true,
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
              databaseEnabled: false,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            shouldInterceptRequest: (controller, request) async {
              // 检查是否启用请求拦截
              final interceptConfig =
                  config.requestInterceptConfig ??
                  RequestInterceptConfig.cookieBasedConfig;
              if (!interceptConfig.enableRequestIntercept) {
                DebugService.log(
                  '⏭️ 请求拦截已禁用，跳过拦截: ${request.url}',
                  category: DebugCategory.tools,
                  subCategory: _logSubCategory,
                );
                return null;
              }

              // 检查是否为跳过拦截的认证类型
              final authTypeString = widget.cloudDriveType.authType.name;
              if (interceptConfig.skipInterceptForAuthTypes.contains(
                authTypeString,
              )) {
                DebugService.log(
                  '⏭️ 认证类型 $authTypeString 跳过拦截: ${request.url}',
                  category: DebugCategory.tools,
                  subCategory: _logSubCategory,
                );
                return null;
              }

              // 多步多 cookie 捕获
              for (final rule in rules) {
                if (request.url.toString().contains(rule.urlPattern)) {
                  DebugService.log('🔍 拦截: ${rule.urlPattern}');
                  try {
                    // 获取多个域名的 cookie
                    String? webviewCookies;
                    if (rule.cookieDomains.isNotEmpty) {
                      final allCookies = <String>[];
                      for (final domain in rule.cookieDomains) {
                        try {
                          final cookies = await CookieManager.instance()
                              .getCookies(url: WebUri(domain));
                          if (cookies.isNotEmpty) {
                            final domainCookies = cookies
                                .map((c) => '${c.name}=${c.value}')
                                .join('; ');
                            allCookies.add(domainCookies);
                          }
                        } catch (e) {
                          DebugService.log('⚠️ 获取Cookie失败: $domain');
                        }
                      }
                      webviewCookies = allCookies.join('; ');
                    }

                    final headers = <String, String>{};
                    if (request.headers != null) {
                      headers.addAll(request.headers!);
                    }
                    headers['User-Agent'] =
                        config.effectiveUserAgent; // 使用配置化UserAgent
                    if (webviewCookies != null && webviewCookies.isNotEmpty) {
                      headers['Cookie'] = webviewCookies;
                    }

                    final response = await Dio().get(
                      request.url.toString(),
                      options: Options(headers: headers),
                    );

                    // 提取 cookie
                    final setCookies = <String>[];
                    response.headers.forEach((name, values) {
                      if (name.toLowerCase() == 'set-cookie') {
                        setCookies.addAll(values);
                      }
                    });
                    final setCookiesString = setCookies.join('; ');

                    DebugService.log(
                      '🍪 原始set-cookie: $setCookiesString',
                      category: DebugCategory.tools,
                      subCategory: _logSubCategory,
                    );

                    final extracted = extractCookies(
                      setCookiesString,
                      rule.cookieNames,
                    );

                    DebugService.log(
                      '🍪 提取的cookie: $extracted',
                      category: DebugCategory.tools,
                      subCategory: _logSubCategory,
                    );

                    if (extracted.isNotEmpty) {
                      for (final kv in extracted.split(';')) {
                        final parts = kv.trim().split('=');
                        if (parts.length == 2) {
                          _cookieMap[parts[0]] = parts[1];
                          DebugService.log(
                            '🍪 保存cookie: ${parts[0]} = ${parts[1]}',
                            category: DebugCategory.tools,
                            subCategory: _logSubCategory,
                          );
                        }
                      }
                      DebugService.log('✅ 捕获: $extracted');
                    } else {
                      DebugService.log(
                        '⚠️ 未提取到任何cookie',
                        category: DebugCategory.tools,
                        subCategory: _logSubCategory,
                      );
                    }

                    // 检查是否所有 cookie 都已捕获
                    final allNames = rules.expand((r) => r.cookieNames).toSet();
                    final allGot = allNames.every(_cookieMap.containsKey);
                    if (allGot && !_isLoggedIn) {
                      final merged = allNames
                          .map((k) => '$k=${_cookieMap[k]}')
                          .join('; ');
                      setState(() {
                        _isLoggedIn = true;
                      });
                      DebugService.log('🎉 登录成功: $merged');
                    }

                    // 转换响应头格式
                    final responseHeaders = <String, String>{};
                    response.headers.forEach((name, values) {
                      if (values.isNotEmpty) {
                        responseHeaders[name] = values.first;
                      }
                    });

                    return WebResourceResponse(
                      contentType:
                          responseHeaders['content-type'] ?? 'application/json',
                      contentEncoding: 'utf-8',
                      data: Uint8List.fromList(
                        utf8.encode(response.data.toString()),
                      ),
                      statusCode: response.statusCode ?? 200,
                      reasonPhrase: response.statusMessage ?? 'OK',
                      headers: responseHeaders,
                    );
                  } catch (e) {
                    DebugService.error('❌ 请求失败: $e', null);
                    return null;
                  }
                }
              }
              return null;
            },
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
                DebugService.error('❌ 获取缩放比例失败: $e', null);
              }
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
          if (_isLoggedIn)
            Positioned(
              bottom: 32.h,
              right: 32.w,
              child: FloatingActionButton.extended(
                heroTag: 'confirmLogin',
                onPressed: _confirmLogin,
                backgroundColor: Colors.green,
                icon: const Icon(Icons.check),
                label: const Text('完成并返回'),
              ),
            ),
        ],
      ),
    );
  }

  /// 确认登录
  Future<void> _confirmLogin() async {
    if (_webViewController == null) {
      DebugService.log(
        '❌ WebView控制器为空，无法确认登录',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );
      return;
    }

    try {
      DebugService.log(
        '🔐 开始确认登录流程',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );
      DebugService.log(
        '👤 云盘类型: ${widget.cloudDriveType.displayName}',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );
      DebugService.log(
        '🔑 认证方式: ${widget.cloudDriveType.authType}',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );

      String authData = '';

      // 根据认证方式获取不同的认证数据
      switch (widget.cloudDriveType.authType) {
        case AuthType.cookie:
          DebugService.log(
            '🍪 使用Cookie认证方式',
            category: DebugCategory.tools,
            subCategory: _logSubCategory,
          );
          // 获取Cookie
          authData = await _getCookies();
          if (authData.isEmpty) {
            DebugService.log(
              '❌ 未获取到Cookie',
              category: DebugCategory.tools,
              subCategory: _logSubCategory,
            );
            return;
          }
          DebugService.log(
            '✅ 获取到Cookie: ${authData.length} 个字符',
            category: DebugCategory.tools,
            subCategory: _logSubCategory,
          );
          DebugService.log(
            '🍪 Cookie内容预览: ${authData.substring(0, authData.length > 200 ? 200 : authData.length)}...',
            category: DebugCategory.tools,
            subCategory: _logSubCategory,
          );
          break;

        case AuthType.authorization:
          DebugService.log(
            '🔑 使用Authorization Token认证方式',
            category: DebugCategory.tools,
            subCategory: _logSubCategory,
          );
          // 获取Authorization Token
          authData = await _getAuthorizationToken();
          if (authData.isEmpty) {
            DebugService.log(
              '❌ 未获取到Authorization Token',
              category: DebugCategory.tools,
              subCategory: _logSubCategory,
            );
            return;
          }
          DebugService.log(
            '✅ 获取到Authorization Token: ${authData.length} 个字符',
            category: DebugCategory.tools,
            subCategory: _logSubCategory,
          );
          DebugService.log(
            '🔑 Token内容预览: ${authData.substring(0, authData.length > 100 ? 100 : authData.length)}...',
            category: DebugCategory.tools,
            subCategory: _logSubCategory,
          );
          break;
      }

      DebugService.log(
        '📤 准备调用登录成功回调',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );

      // 调用登录成功回调
      await widget.onLoginSuccess(authData);

      DebugService.log(
        '✅ 登录成功回调执行完成',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );

      // 执行登录后处理（如果配置要求）
      final config = widget.cloudDriveType.webViewConfig;
      final postLoginConfig = config.postLoginConfig;
      if (postLoginConfig?.hasPostLoginProcessing == true) {
        DebugService.log(
          '🔄 执行登录后处理: ${postLoginConfig!.postLoginMessage ?? '处理云盘特定逻辑'}',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );

        // 执行配置的登录后动作
        for (final action in postLoginConfig.postLoginActions) {
          DebugService.log(
            '⚡ 执行登录后动作: $action',
            category: DebugCategory.tools,
            subCategory: _logSubCategory,
          );
        }
      }

      // 关闭WebView
      if (mounted) {
        DebugService.log(
          '🚪 关闭WebView页面',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );
        Navigator.of(context).pop();
      }
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 确认登录失败: $e',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );
    }
  }

  // Helper to get cookies from the webview
  Future<String> _getCookies() async {
    if (_webViewController == null) {
      DebugService.log(
        '❌ WebView控制器为空，无法获取Cookie',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );
      return '';
    }

    try {
      DebugService.log(
        '🍪 开始获取WebView Cookie',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );

      final config = widget.cloudDriveType.webViewConfig;
      final cookieConfig =
          config.cookieProcessingConfig ?? CookieProcessingConfig.defaultConfig;

      // 优先使用拦截器捕获的Cookie（如果配置启用）
      if (cookieConfig.useInterceptedCookies &&
          cookieConfig.priorityCookieNames.isNotEmpty) {
        DebugService.log(
          '🔍 检查已捕获的优先Cookie: ${cookieConfig.priorityCookieNames}',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );

        for (final cookieName in cookieConfig.priorityCookieNames) {
          if (_cookieMap.containsKey(cookieName)) {
            final priorityCookie = '$cookieName=${_cookieMap[cookieName]}';
            DebugService.log(
              '✅ 使用已捕获的优先Cookie: $priorityCookie',
              category: DebugCategory.tools,
              subCategory: _logSubCategory,
            );
            return priorityCookie;
          }
        }

        DebugService.log(
          '⚠️ 未找到已捕获的优先Cookie，尝试从document.cookie获取',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );
      }

      final result = await _webViewController!.evaluateJavascript(
        source: 'document.cookie',
      );

      final cookies = result?.toString() ?? '';

      DebugService.log(
        '🍪 Cookie获取结果: ${cookies.isNotEmpty ? '成功' : '失败'}',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );

      if (cookies.isNotEmpty) {
        DebugService.log(
          '🍪 获取到Cookie: ${cookies.length} 个字符',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );
        DebugService.log(
          '🍪 Cookie内容预览: ${cookies.substring(0, cookies.length > 200 ? 200 : cookies.length)}...',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );

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
        DebugService.log(
          '❌ 未获取到Cookie',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );
      }

      return cookies;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 获取WebView Cookie失败: $e',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );
      return '';
    }
  }

  /// 从Cookie字符串中提取特定Cookie
  String _extractSpecificCookiesFromString(
    String cookies,
    CookieProcessingConfig cookieConfig,
  ) {
    DebugService.log(
      '🔍 从document.cookie中提取特定Cookie: ${cookieConfig.priorityCookieNames}',
      category: DebugCategory.tools,
      subCategory: _logSubCategory,
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
        DebugService.log(
          '✅ 从document.cookie中提取到优先Cookie: $extractedCookie',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );
        return extractedCookie;
      }
    }

    DebugService.log(
      '❌ document.cookie中未找到优先Cookie',
      category: DebugCategory.tools,
      subCategory: _logSubCategory,
    );
    DebugService.log(
      '🍪 可用的cookie: ${cookieMap.keys.toList()}',
      category: DebugCategory.tools,
      subCategory: _logSubCategory,
    );

    return '';
  }

  // Helper to get authorization token from the webview
  Future<String> _getAuthorizationToken() async {
    if (_webViewController == null) {
      DebugService.log(
        '❌ WebView控制器为空，无法获取token',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );
      return '';
    }

    try {
      DebugService.log(
        '🔍 开始获取Authorization Token',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );

      final config = widget.cloudDriveType.webViewConfig;
      final tokenConfig = config.tokenConfig;

      if (tokenConfig == null) {
        DebugService.log(
          '⚠️ 未配置TokenConfig，无法获取token',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );
        return '';
      }

      DebugService.log(
        '📋 TokenConfig配置: localStorageKeys=${tokenConfig.localStorageKeys}, sessionStorageKeys=${tokenConfig.sessionStorageKeys}, cookieNames=${tokenConfig.cookieNames}',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
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
              DebugService.log(
                '✅ 从localStorage.$key获取到原始数据: ${data.length}字符',
                category: DebugCategory.tools,
                subCategory: _logSubCategory,
              );
              rawData = data;
              break;
            }
          } catch (e) {
            DebugService.log(
              '⚠️ 从localStorage.$key获取数据失败: $e',
              category: DebugCategory.tools,
              subCategory: _logSubCategory,
            );
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
              DebugService.log(
                '✅ 从sessionStorage.$key获取到原始数据: ${data.length}字符',
                category: DebugCategory.tools,
                subCategory: _logSubCategory,
              );
              rawData = data;
              break;
            }
          } catch (e) {
            DebugService.log(
              '⚠️ 从sessionStorage.$key获取数据失败: $e',
              category: DebugCategory.tools,
              subCategory: _logSubCategory,
            );
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
            DebugService.log(
              '✅ 获取到cookie原始数据: ${cookies.length}字符',
              category: DebugCategory.tools,
              subCategory: _logSubCategory,
            );
          }
        } catch (e) {
          DebugService.log(
            '⚠️ 获取cookie数据失败: $e',
            category: DebugCategory.tools,
            subCategory: _logSubCategory,
          );
        }
      }

      DebugService.log(
        '📜 原始数据获取完成: ${rawData.isNotEmpty ? '成功' : '失败'}',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );

      if (rawData.isNotEmpty) {
        DebugService.log(
          '🔑 获取到原始数据: ${rawData.substring(0, rawData.length > 100 ? 100 : rawData.length)}...',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );
        DebugService.log(
          '🔑 原始数据长度: ${rawData.length} 字符',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );

        DebugService.log(
          '🔧 准备调用TokenParser.parseToken',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );

        // 使用TokenParser解析原始数据
        final parsedToken = TokenParser.parseToken(
          rawData,
          tokenConfig,
          widget.cloudDriveType,
        );

        DebugService.log(
          '🔑 TokenParser调用完成',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );
        DebugService.log(
          '🔑 解析后Token长度: ${parsedToken.length} 字符',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );

        return parsedToken;
      } else {
        DebugService.log(
          '❌ 未获取到原始数据',
          category: DebugCategory.tools,
          subCategory: _logSubCategory,
        );
      }

      return '';
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 获取WebView Authorization Token失败: $e',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: _logSubCategory,
      );
      return '';
    }
  }
}
