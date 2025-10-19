/// 日志分类枚举
/// 定义应用中不同类型的日志分类
enum LogCategory {
  /// 网络相关日志（请求、响应、连接等）
  network('NETWORK', '网络'),

  /// 文件操作日志（上传、下载、删除、重命名等）
  fileOperation('FILE_OPERATION', '文件操作'),

  /// 用户行为日志（登录、浏览、点击等）
  userAction('USER_ACTION', '用户行为'),

  /// 错误和异常日志
  error('ERROR', '错误'),

  /// 性能监控日志（响应时间、内存使用等）
  performance('PERFORMANCE', '性能'),

  /// 云盘服务特定日志
  cloudDrive('CLOUD_DRIVE', '云盘服务'),

  /// 数据库操作日志
  database('DATABASE', '数据库'),

  /// 缓存操作日志
  cache('CACHE', '缓存'),

  /// 认证相关日志
  auth('AUTH', '认证'),

  /// 系统日志（启动、关闭、配置等）
  system('SYSTEM', '系统'),

  /// 调试日志
  debug('DEBUG', '调试'),

  /// 信息日志
  info('INFO', '信息'),

  /// 警告日志
  warning('WARNING', '警告');

  const LogCategory(this.code, this.displayName);

  /// 分类代码
  final String code;

  /// 显示名称
  final String displayName;

  /// 根据代码获取分类
  static LogCategory fromCode(String code) {
    return LogCategory.values.firstWhere(
      (category) => category.code == code,
      orElse: () => LogCategory.info,
    );
  }

  /// 获取所有分类的代码列表
  static List<String> getAllCodes() {
    return LogCategory.values.map((category) => category.code).toList();
  }

  /// 获取所有分类的显示名称列表
  static List<String> getAllDisplayNames() {
    return LogCategory.values.map((category) => category.displayName).toList();
  }

  @override
  String toString() => displayName;
}
