/// API端点配置
class ApiEndpoints {
  // 基础URL配置
  static const String baseUrl = 'https://api.example.com';
  static const String baseUrlDev = 'https://dev-api.example.com';
  static const String baseUrlStaging = 'https://staging-api.example.com';

  // API版本
  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api/$apiVersion';

  // 认证相关
  static const String login = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String refreshToken = '$apiPrefix/auth/refresh';
  static const String logout = '$apiPrefix/auth/logout';
  static const String forgotPassword = '$apiPrefix/auth/forgot-password';
  static const String resetPassword = '$apiPrefix/auth/reset-password';

  // 用户相关
  static const String userProfile = '$apiPrefix/user/profile';
  static const String updateProfile = '$apiPrefix/user/profile';
  static const String changePassword = '$apiPrefix/user/change-password';
  static const String uploadAvatar = '$apiPrefix/user/avatar';

  // 设置相关
  static const String userSettings = '$apiPrefix/user/settings';
  static const String updateSettings = '$apiPrefix/user/settings';
  static const String notificationSettings = '$apiPrefix/user/notifications';

  // 内容相关
  static const String content = '$apiPrefix/content';
  static const String contentById = '$apiPrefix/content/{id}';
  static const String contentByCategory =
      '$apiPrefix/content/category/{category}';

  // 分类相关
  static const String categories = '$apiPrefix/categories';
  static const String categoryById = '$apiPrefix/categories/{id}';

  // 搜索相关
  static const String search = '$apiPrefix/search';
  static const String searchSuggestions = '$apiPrefix/search/suggestions';

  // 文件上传
  static const String uploadFile = '$apiPrefix/upload';
  static const String uploadImage = '$apiPrefix/upload/image';
  static const String uploadDocument = '$apiPrefix/upload/document';

  // 统计相关
  static const String statistics = '$apiPrefix/statistics';
  static const String userStatistics = '$apiPrefix/user/statistics';

  // 反馈相关
  static const String feedback = '$apiPrefix/feedback';
  static const String reportBug = '$apiPrefix/feedback/bug';
  static const String featureRequest = '$apiPrefix/feedback/feature';

  // 系统相关
  static const String systemInfo = '$apiPrefix/system/info';
  static const String systemHealth = '$apiPrefix/system/health';
  static const String appVersion = '$apiPrefix/system/version';

  /// 获取完整的URL
  static String getFullUrl(String endpoint, {String? baseUrl}) {
    final base = baseUrl ?? ApiEndpoints.baseUrl;
    return '$base$endpoint';
  }

  /// 替换URL中的参数
  static String replacePathParams(
    String endpoint,
    Map<String, dynamic> params,
  ) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }

  /// 构建查询参数URL
  static String buildQueryUrl(
    String endpoint,
    Map<String, dynamic>? queryParams,
  ) {
    if (queryParams == null || queryParams.isEmpty) {
      return endpoint;
    }

    final uri = Uri.parse(endpoint);
    final queryString = uri.queryParametersAll;

    // 添加新的查询参数
    queryParams.forEach((key, value) {
      if (value != null) {
        queryString[key] = [value.toString()];
      }
    });

    return uri.replace(queryParameters: queryString).toString();
  }
}
