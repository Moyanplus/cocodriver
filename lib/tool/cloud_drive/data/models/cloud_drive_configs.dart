/// Cookie捕获规则
class CookieCaptureRule {
  final String urlPattern;
  final List<String> cookieNames;
  final List<String> cookieDomains;

  const CookieCaptureRule({
    required this.urlPattern,
    required this.cookieNames,
    this.cookieDomains = const [],
  });
}

/// UserAgent类型枚举
enum UserAgentType {
  /// PC Chrome
  pcChrome,

  /// PC Firefox
  pcFirefox,

  /// PC Edge
  pcEdge,

  /// Mobile Chrome
  mobileChrome,

  /// Mobile Safari
  mobileSafari,

  /// 自定义
  custom,
}

/// UserAgent类型扩展
extension UserAgentTypeExtension on UserAgentType {
  String get userAgent {
    switch (this) {
      case UserAgentType.pcChrome:
        return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
      case UserAgentType.pcFirefox:
        return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0';
      case UserAgentType.pcEdge:
        return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0';
      case UserAgentType.mobileChrome:
        return 'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
      case UserAgentType.mobileSafari:
        return 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
      case UserAgentType.custom:
        return '';
    }
  }
}

/// Token配置
class TokenConfig {
  final List<String> localStorageKeys;
  final List<String> sessionStorageKeys;
  final List<String> cookieNames;
  final String? tokenKey;
  final String? tokenPrefix;
  final Map<String, String>? headers;
  final bool isJsonFormat;
  final String? jsonFieldPath;
  final bool enableDebugLog;
  final bool removeQuotes;
  final Map<String, String>? fieldMapping;

  const TokenConfig({
    this.localStorageKeys = const [],
    this.sessionStorageKeys = const [],
    this.cookieNames = const [],
    this.tokenKey,
    this.tokenPrefix,
    this.headers,
    this.isJsonFormat = false,
    this.jsonFieldPath,
    this.enableDebugLog = false,
    this.removeQuotes = false,
    this.fieldMapping,
  });

  /// 阿里云盘Token配置
  static const TokenConfig aliDriveConfig = TokenConfig(
    localStorageKeys: ['authorization'],
    tokenKey: 'authorization',
    tokenPrefix: 'Bearer ',
    headers: {'Content-Type': 'application/json'},
    isJsonFormat: false,
    removeQuotes: true,
  );

  /// 百度网盘Token配置
  static const TokenConfig baiduDriveConfig = TokenConfig(
    cookieNames: ['BDUSS'],
    tokenKey: 'BDUSS',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    isJsonFormat: false,
  );
}

/// 登录检测配置
class LoginDetectionConfig {
  final bool enableAutoDetection;
  final String detectionMethod;
  final Duration checkInterval;
  final int maxRetries;
  final List<String> successIndicators;
  final String? successUrl;
  final String? successTitle;
  final String? successSelector;
  final Duration timeout;

  const LoginDetectionConfig({
    this.enableAutoDetection = true,
    this.detectionMethod = 'cookie',
    this.checkInterval = const Duration(seconds: 2),
    this.maxRetries = 30,
    this.successIndicators = const [],
    this.successUrl,
    this.successTitle,
    this.successSelector,
    this.timeout = const Duration(seconds: 30),
  });

  /// 阿里云盘登录检测配置
  static const LoginDetectionConfig aliConfig = LoginDetectionConfig(
    enableAutoDetection: true,
    detectionMethod: 'token',
    checkInterval: Duration(seconds: 2),
    maxRetries: 30,
    successIndicators: ['authorization'],
    successUrl: 'https://www.aliyundrive.com/drive',
    successTitle: '阿里云盘',
    timeout: Duration(seconds: 30),
  );

  /// 百度网盘登录检测配置
  static const LoginDetectionConfig baiduConfig = LoginDetectionConfig(
    enableAutoDetection: true,
    detectionMethod: 'cookie',
    checkInterval: Duration(seconds: 2),
    maxRetries: 30,
    successIndicators: ['BDUSS', 'STOKEN', 'PCS_TOKEN'], // 与Cookie处理配置保持一致
    successUrl: 'https://pan.baidu.com/disk/home',
    successTitle: '百度网盘',
    timeout: Duration(seconds: 30),
  );

  /// 123云盘登录检测配置
  static const LoginDetectionConfig pan123Config = LoginDetectionConfig(
    enableAutoDetection: true,
    detectionMethod: 'cookie',
    checkInterval: Duration(seconds: 2),
    maxRetries: 30,
    successIndicators: ['ctoken', 'b-user-id', '__uid'], // 与Cookie处理配置保持一致
    successUrl: 'https://www.123pan.com/',
    successTitle: '123云盘',
    timeout: Duration(seconds: 30),
  );

  /// 蓝奏云登录检测配置
  static const LoginDetectionConfig lanzouConfig = LoginDetectionConfig(
    enableAutoDetection: true,
    detectionMethod: 'cookie',
    checkInterval: Duration(seconds: 2),
    maxRetries: 30,
    successIndicators: ['ylogin', 'phpdisk_info'], // 与Cookie处理配置保持一致
    successUrl: 'https://pc.woozooo.com/mydisk.php',
    successTitle: '蓝奏云',
    timeout: Duration(seconds: 30),
  );

  /// 夸克云盘登录检测配置
  static const LoginDetectionConfig quarkConfig = LoginDetectionConfig(
    enableAutoDetection: true,
    detectionMethod: 'cookie',
    checkInterval: Duration(seconds: 2),
    maxRetries: 30,
    successIndicators: ['__puus', 'QKUID', 'QK_UID'], // 与Cookie处理配置保持一致
    successUrl: 'https://pan.quark.cn/',
    successTitle: '夸克网盘',
    timeout: Duration(seconds: 30),
  );
}

/// Cookie处理配置
class CookieProcessingConfig {
  final bool enableProcessing;
  final bool useInterceptedCookies;
  final bool extractSpecificCookies;
  final List<String> priorityCookieNames;
  final List<String> requiredCookies;
  final List<String> excludedDomains;

  const CookieProcessingConfig({
    this.enableProcessing = true,
    this.useInterceptedCookies = true,
    this.extractSpecificCookies = true,
    this.priorityCookieNames = const [],
    this.requiredCookies = const [],
    this.excludedDomains = const [],
  });

  /// 默认Cookie处理配置
  static const CookieProcessingConfig defaultConfig = CookieProcessingConfig(
    enableProcessing: true,
    useInterceptedCookies: true,
    extractSpecificCookies: true,
    priorityCookieNames: ['BDUSS', 'STOKEN', 'PCS_TOKEN'],
    requiredCookies: ['BDUSS', 'STOKEN', 'PCS_TOKEN'],
    excludedDomains: ['google.com', 'facebook.com'],
  );

  /// 123云盘Cookie处理配置
  static const CookieProcessingConfig pan123Config = CookieProcessingConfig(
    enableProcessing: true,
    useInterceptedCookies: true,
    extractSpecificCookies: true,
    priorityCookieNames: ['ctoken', 'b-user-id', '__uid'],
    requiredCookies: ['ctoken', 'b-user-id'],
    excludedDomains: ['google.com', 'facebook.com'],
  );

  /// 蓝奏云Cookie处理配置
  static const CookieProcessingConfig lanzouConfig = CookieProcessingConfig(
    enableProcessing: true,
    useInterceptedCookies: true,
    extractSpecificCookies: true,
    priorityCookieNames: ['ylogin', 'phpdisk_info'],
    requiredCookies: ['ylogin'],
    excludedDomains: ['google.com', 'facebook.com'],
  );

  /// 夸克云盘Cookie处理配置
  static const CookieProcessingConfig quarkConfig = CookieProcessingConfig(
    enableProcessing: true,
    useInterceptedCookies: true,
    extractSpecificCookies: true,
    priorityCookieNames: ['__puus'],
    requiredCookies: ['__puus'],
    excludedDomains: ['google.com', 'facebook.com'],
  );
}

/// 登录后处理配置
class PostLoginConfig {
  final bool hasPostLoginProcessing;
  final String? postLoginMessage;
  final List<String> postLoginActions;
  final bool enableAutoRedirect;
  final String? redirectUrl;
  final Duration waitTime;

  const PostLoginConfig({
    this.hasPostLoginProcessing = false,
    this.postLoginMessage,
    this.postLoginActions = const [],
    this.enableAutoRedirect = true,
    this.redirectUrl,
    this.waitTime = const Duration(seconds: 2),
  });

  /// 默认登录后处理配置
  static const PostLoginConfig defaultConfig = PostLoginConfig(
    hasPostLoginProcessing: false,
    enableAutoRedirect: true,
    waitTime: const Duration(seconds: 2),
  );
}

/// 请求拦截配置
class RequestInterceptConfig {
  final bool enableRequestIntercept;
  final List<String> skipInterceptForAuthTypes;
  final List<String> interceptPatterns;
  final Map<String, String>? customHeaders;

  const RequestInterceptConfig({
    this.enableRequestIntercept = false,
    this.skipInterceptForAuthTypes = const ['authorization'],
    this.interceptPatterns = const [],
    this.customHeaders,
  });

  /// Token认证配置（不需要拦截）
  static const RequestInterceptConfig tokenBasedConfig = RequestInterceptConfig(
    enableRequestIntercept: false,
    skipInterceptForAuthTypes: ['authorization'],
  );

  /// Cookie认证配置（需要拦截）
  static const RequestInterceptConfig cookieBasedConfig =
      RequestInterceptConfig(
        enableRequestIntercept: true,
        skipInterceptForAuthTypes: ['authorization'],
        interceptPatterns: ['*://*.baidu.com/*', '*://*.aliyundrive.com/*'],
      );
}

/// 云盘WebView配置
class CloudDriveWebViewConfig {
  final String? initialUrl;
  final String? userAgent;
  final UserAgentType? userAgentType;
  final List<CookieCaptureRule> cookieCaptureRules;
  final String rootDir;
  final TokenConfig? tokenConfig;
  final LoginDetectionConfig? loginDetectionConfig;
  final CookieProcessingConfig? cookieProcessingConfig;
  final PostLoginConfig? postLoginConfig;
  final RequestInterceptConfig? requestInterceptConfig;

  const CloudDriveWebViewConfig({
    this.initialUrl,
    this.userAgent,
    this.userAgentType,
    this.cookieCaptureRules = const [],
    this.rootDir = '/',
    this.tokenConfig,
    this.loginDetectionConfig,
    this.cookieProcessingConfig,
    this.postLoginConfig,
    this.requestInterceptConfig,
  });

  /// 获取实际使用的UserAgent字符串
  String get effectiveUserAgent {
    if (userAgentType != null) {
      return userAgentType!.userAgent;
    }
    if (userAgent != null && userAgent!.isNotEmpty) {
      return userAgent!;
    }
    return UserAgentType.pcChrome.userAgent;
  }
}
