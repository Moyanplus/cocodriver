/// 云盘配置数据模型
///
/// 定义云盘相关的配置类，包括 Cookie 处理、登录检测、Token 配置等。

/// Cookie 捕获规则类
///
/// 定义 Cookie 捕获的规则，包括 URL 模式、Cookie 名称和域名。
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

/// UserAgent 类型扩展
///
/// 为 UserAgentType 枚举提供用户代理字符串获取功能。
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

/// Token 配置类
///
/// 配置 Token 的存储位置、格式和提取方式。
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

/// 登录检测配置类
///
/// 配置登录状态的检测方式、检测间隔和成功指示器。
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

  /// 中国移动云盘登录检测配置
  static const LoginDetectionConfig chinaMobileConfig = LoginDetectionConfig(
    enableAutoDetection: true,
    detectionMethod: 'cookie',
    checkInterval: Duration(seconds: 2),
    maxRetries: 30,
    successIndicators: ['token', 'userId'], // 与Cookie处理配置保持一致
    successUrl: 'https://yun.139.com/',
    successTitle: '中国移动云盘',
    timeout: Duration(seconds: 30),
  );
}

/// Cookie 处理配置类
///
/// 配置 Cookie 的处理方式、必需字段和排除域名。
class CookieProcessingConfig {
  final bool enableProcessing;
  final bool useInterceptedCookies;
  final List<String> requiredCookies;
  final List<String> excludedDomains;

  const CookieProcessingConfig({
    this.enableProcessing = true,
    this.useInterceptedCookies = true,
    required this.requiredCookies,
    this.excludedDomains = const ['google.com', 'facebook.com'],
  });

  /// 默认Cookie处理配置（百度网盘）
  static const CookieProcessingConfig defaultConfig = CookieProcessingConfig(
    enableProcessing: true,
    useInterceptedCookies: true,
    requiredCookies: ['BDUSS', 'STOKEN', 'PCS_TOKEN'],
  );

  /// 123云盘Cookie处理配置
  static const CookieProcessingConfig pan123Config = CookieProcessingConfig(
    enableProcessing: true,
    useInterceptedCookies: true,
    requiredCookies: ['ctoken', 'b-user-id', '__uid'],
  );

  /// 蓝奏云Cookie处理配置
  static const CookieProcessingConfig lanzouConfig = CookieProcessingConfig(
    enableProcessing: true,
    useInterceptedCookies: true,
    requiredCookies: ['ylogin', 'phpdisk_info'],
  );

  /// 夸克云盘Cookie处理配置
  static const CookieProcessingConfig quarkConfig = CookieProcessingConfig(
    enableProcessing: true,
    useInterceptedCookies: true,
    requiredCookies: ['__puus', 'QKUID', 'QK_UID'],
  );

  /// 中国移动云盘Cookie处理配置
  static const CookieProcessingConfig chinaMobileConfig =
      CookieProcessingConfig(
        enableProcessing: true,
        useInterceptedCookies: true,
        requiredCookies: ['token', 'userId'],
      );
}

/// 登录后处理配置类
///
/// 配置登录成功后的处理逻辑，包括 Cookie 提取、Token 保存等。
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

/// 请求拦截配置类
///
/// 配置请求拦截规则，包括拦截模式、跳过规则和自定义请求头。
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

/// 云盘统一配置类
///
/// 整合云盘的各种配置，包括 Token、登录检测、Cookie 处理等。
class CloudDriveConfig {
  final String name;
  final String baseUrl;
  final TokenConfig? tokenConfig;
  final LoginDetectionConfig loginDetectionConfig;
  final CookieProcessingConfig cookieProcessingConfig;
  final PostLoginConfig postLoginConfig;
  final RequestInterceptConfig requestInterceptConfig;
  final bool isAvailable;

  const CloudDriveConfig({
    required this.name,
    required this.baseUrl,
    this.tokenConfig,
    required this.loginDetectionConfig,
    required this.cookieProcessingConfig,
    required this.postLoginConfig,
    required this.requestInterceptConfig,
    this.isAvailable = true,
  });

  /// 百度网盘配置
  static const CloudDriveConfig baidu = CloudDriveConfig(
    name: '百度网盘',
    baseUrl: 'https://pan.baidu.com',
    tokenConfig: TokenConfig.baiduDriveConfig,
    loginDetectionConfig: LoginDetectionConfig.baiduConfig,
    cookieProcessingConfig: CookieProcessingConfig.defaultConfig,
    postLoginConfig: PostLoginConfig.defaultConfig,
    requestInterceptConfig: RequestInterceptConfig.cookieBasedConfig,
    isAvailable: false,
  );

  /// 阿里云盘配置
  static const CloudDriveConfig aliyun = CloudDriveConfig(
    name: '阿里云盘',
    baseUrl: 'https://www.aliyundrive.com',
    tokenConfig: TokenConfig.aliDriveConfig,
    loginDetectionConfig: LoginDetectionConfig.aliConfig,
    cookieProcessingConfig: CookieProcessingConfig(
      enableProcessing: true,
      useInterceptedCookies: true,
      requiredCookies: ['access_token', 'refresh_token'],
    ),
    postLoginConfig: PostLoginConfig.defaultConfig,
    requestInterceptConfig: RequestInterceptConfig.tokenBasedConfig,
    isAvailable: false,
  );

  /// 蓝奏云配置
  static const CloudDriveConfig lanzou = CloudDriveConfig(
    name: '蓝奏云',
    baseUrl: 'https://pc.woozooo.com',
    loginDetectionConfig: LoginDetectionConfig.lanzouConfig,
    cookieProcessingConfig: CookieProcessingConfig.lanzouConfig,
    postLoginConfig: PostLoginConfig.defaultConfig,
    requestInterceptConfig: RequestInterceptConfig.cookieBasedConfig,
    isAvailable: true,
  );

  /// 夸克云盘配置
  static const CloudDriveConfig quark = CloudDriveConfig(
    name: '夸克云盘',
    baseUrl: 'https://pan.quark.cn',
    loginDetectionConfig: LoginDetectionConfig.quarkConfig,
    cookieProcessingConfig: CookieProcessingConfig.quarkConfig,
    postLoginConfig: PostLoginConfig.defaultConfig,
    requestInterceptConfig: RequestInterceptConfig.cookieBasedConfig,
    isAvailable: true,
  );

  /// 123云盘配置
  static const CloudDriveConfig pan123 = CloudDriveConfig(
    name: '123云盘',
    baseUrl: 'https://www.123pan.com',
    loginDetectionConfig: LoginDetectionConfig.pan123Config,
    cookieProcessingConfig: CookieProcessingConfig.pan123Config,
    postLoginConfig: PostLoginConfig.defaultConfig,
    requestInterceptConfig: RequestInterceptConfig.cookieBasedConfig,
    isAvailable: false,
  );

  /// 中国移动云盘配置
  static const CloudDriveConfig chinaMobile = CloudDriveConfig(
    name: '中国移动云盘',
    baseUrl: 'https://yun.139.com',
    loginDetectionConfig: LoginDetectionConfig.chinaMobileConfig,
    cookieProcessingConfig: CookieProcessingConfig.chinaMobileConfig,
    postLoginConfig: PostLoginConfig.defaultConfig,
    requestInterceptConfig: RequestInterceptConfig.cookieBasedConfig,
    isAvailable: true,
  );
}

/// 云盘 WebView 配置类
///
/// 配置 WebView 登录相关的参数，包括初始 URL、UserAgent、Cookie 捕获规则等。
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
