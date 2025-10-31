import '../../data/models/cloud_drive_entities.dart';

/// 云盘业务规则
///
/// 定义云盘操作的业务规则，包括文件大小限制、操作权限验证等。
class CloudDriveBusinessRules {
  /// 验证文件上传权限
  static bool validateUploadPermission({
    required CloudDriveAccount account,
    required String folderId,
    required int fileSize,
  }) {
    // 检查账号是否已登录
    if (!account.isLoggedIn) {
      return false;
    }

    // 检查文件大小限制
    if (fileSize > _getMaxFileSize(account.type)) {
      return false;
    }

    // 检查存储空间
    // TODO: 实现存储空间检查逻辑

    return true;
  }

  /// 获取最大文件大小限制
  static int _getMaxFileSize(CloudDriveType type) {
    switch (type) {
      case CloudDriveType.baidu:
        return 2 * 1024 * 1024 * 1024; // 2GB
      case CloudDriveType.lanzou:
        return 100 * 1024 * 1024; // 100MB
      case CloudDriveType.pan123:
        return 5 * 1024 * 1024 * 1024; // 5GB
      case CloudDriveType.ali:
        return 20 * 1024 * 1024 * 1024; // 20GB
      case CloudDriveType.quark:
        return 5 * 1024 * 1024 * 1024; // 5GB
      case CloudDriveType.chinaMobile:
        return 5 * 1024 * 1024 * 1024; // 5GB
    }
  }

  /// 验证文件操作权限
  static bool validateFileOperation({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String operation,
  }) {
    // 检查账号是否已登录
    if (!account.isLoggedIn) {
      return false;
    }

    // 检查操作是否被支持
    if (!_isOperationSupported(account.type, operation)) {
      return false;
    }

    // 检查文件状态
    if (file.metadata?['status'] == 'locked') {
      return false;
    }

    return true;
  }

  /// 检查操作是否被支持
  static bool _isOperationSupported(CloudDriveType type, String operation) {
    final supportedOperations = _getSupportedOperations(type);
    return supportedOperations.containsKey(operation) &&
        supportedOperations[operation] == true;
  }

  /// 获取支持的操作列表
  static Map<String, bool> _getSupportedOperations(CloudDriveType type) {
    switch (type) {
      case CloudDriveType.baidu:
        return {
          'upload': true,
          'download': true,
          'delete': true,
          'rename': true,
          'move': true,
          'copy': true,
          'share': true,
        };
      case CloudDriveType.lanzou:
        return {
          'upload': true,
          'download': true,
          'delete': true,
          'rename': false,
          'move': false,
          'copy': false,
          'share': true,
        };
      case CloudDriveType.pan123:
        return {
          'upload': true,
          'download': true,
          'delete': true,
          'rename': true,
          'move': true,
          'copy': true,
          'share': true,
        };
      case CloudDriveType.ali:
        return {
          'upload': true,
          'download': true,
          'delete': true,
          'rename': true,
          'move': true,
          'copy': true,
          'share': true,
        };
      case CloudDriveType.quark:
        return {
          'upload': true,
          'download': true,
          'delete': true,
          'rename': true,
          'move': true,
          'copy': true,
          'share': true,
        };
      case CloudDriveType.chinaMobile:
        return {
          'upload': true,
          'download': true,
          'delete': true,
          'rename': true,
          'move': true,
          'copy': true,
          'share': true,
        };
    }
  }

  /// 验证批量操作
  static bool validateBatchOperation({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    required String operation,
    int? maxBatchSize,
  }) {
    // 检查账号权限
    if (!account.isLoggedIn) {
      return false;
    }

    // 检查批量大小限制
    final limit = maxBatchSize ?? _getMaxBatchSize(account.type, operation);
    if (files.length > limit) {
      return false;
    }

    // 检查每个文件的操作权限
    for (final file in files) {
      if (!validateFileOperation(
        account: account,
        file: file,
        operation: operation,
      )) {
        return false;
      }
    }

    return true;
  }

  /// 获取最大批量操作大小
  static int _getMaxBatchSize(CloudDriveType type, String operation) {
    switch (type) {
      case CloudDriveType.baidu:
        return operation == 'delete' ? 100 : 50;
      case CloudDriveType.lanzou:
        return 10; // 蓝奏云批量操作限制较严格
      case CloudDriveType.pan123:
        return 50;
      case CloudDriveType.ali:
        return 100;
      case CloudDriveType.quark:
        return 50;
      case CloudDriveType.chinaMobile:
        return 50;
    }
  }

  /// 验证分享链接
  static bool validateShareLink({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? password,
    int? expireDays,
  }) {
    // 检查账号权限
    if (!account.isLoggedIn) {
      return false;
    }

    // 检查文件是否支持分享
    if (!_isFileShareable(account.type, file)) {
      return false;
    }

    // 检查密码长度
    if (password != null && password.length > 8) {
      return false;
    }

    // 检查过期时间
    if (expireDays != null && expireDays > _getMaxExpireDays(account.type)) {
      return false;
    }

    return true;
  }

  /// 检查文件是否可分享
  static bool _isFileShareable(CloudDriveType type, CloudDriveFile file) {
    // 文件夹通常不能直接分享
    if (file.isFolder) {
      return false;
    }

    // 检查文件大小限制
    if (file.size != null && file.size! > _getMaxShareFileSize(type)) {
      return false;
    }

    return true;
  }

  /// 获取最大分享文件大小
  static int _getMaxShareFileSize(CloudDriveType type) {
    switch (type) {
      case CloudDriveType.baidu:
        return 2 * 1024 * 1024 * 1024; // 2GB
      case CloudDriveType.lanzou:
        return 100 * 1024 * 1024; // 100MB
      case CloudDriveType.pan123:
        return 5 * 1024 * 1024 * 1024; // 5GB
      case CloudDriveType.ali:
        return 20 * 1024 * 1024 * 1024; // 20GB
      case CloudDriveType.quark:
        return 5 * 1024 * 1024 * 1024; // 5GB
      case CloudDriveType.chinaMobile:
        return 5 * 1024 * 1024 * 1024; // 5GB
    }
  }

  /// 获取最大过期天数
  static int _getMaxExpireDays(CloudDriveType type) {
    switch (type) {
      case CloudDriveType.baidu:
        return 7; // 7天
      case CloudDriveType.lanzou:
        return 30; // 30天
      case CloudDriveType.pan123:
        return 7; // 7天
      case CloudDriveType.ali:
        return 7; // 7天
      case CloudDriveType.quark:
        return 7; // 7天
      case CloudDriveType.chinaMobile:
        return 7; // 7天
    }
  }

  /// 验证下载权限
  static bool validateDownloadPermission({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) {
    // 检查账号权限
    if (!account.isLoggedIn) {
      return false;
    }

    // 检查文件状态
    if (file.metadata?['status'] == 'deleted') {
      return false;
    }

    // 检查下载限制
    if (file.size != null && file.size! > _getMaxDownloadSize(account.type)) {
      return false;
    }

    return true;
  }

  /// 获取最大下载文件大小
  static int _getMaxDownloadSize(CloudDriveType type) {
    switch (type) {
      case CloudDriveType.baidu:
        return 2 * 1024 * 1024 * 1024; // 2GB
      case CloudDriveType.lanzou:
        return 100 * 1024 * 1024; // 100MB
      case CloudDriveType.pan123:
        return 5 * 1024 * 1024 * 1024; // 5GB
      case CloudDriveType.ali:
        return 20 * 1024 * 1024 * 1024; // 20GB
      case CloudDriveType.quark:
        return 5 * 1024 * 1024 * 1024; // 5GB
      case CloudDriveType.chinaMobile:
        return 5 * 1024 * 1024 * 1024; // 5GB
    }
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// 获取云盘类型显示信息
  static Map<String, dynamic> getCloudDriveTypeInfo(CloudDriveType type) {
    return {
      'displayName': type.displayName,
      'iconData': type.iconData,
      'color': type.color,
      'icon': type.icon,
      'authType': type.authType.name,
      'supportedAuthTypes': type.supportedAuthTypes.map((e) => e.name).toList(),
    };
  }
}
