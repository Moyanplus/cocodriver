import '../../data/models/cloud_drive_entities.dart';
import '../../base/cloud_drive_service_gateway.dart';
import '../../config/cloud_drive_capabilities.dart';
import '../../services/registry/cloud_drive_provider_registry.dart';

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
    return getCapabilities(type).maxUploadSize;
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
    if (!_isOperationSupported(account, operation)) {
      return false;
    }

    // 检查文件状态
    if (file.metadata?['status'] == 'locked') {
      return false;
    }

    return true;
  }

  /// 检查操作是否被支持
  static bool _isOperationSupported(
    CloudDriveAccount account,
    String operation,
  ) {
    final support = defaultCloudDriveGateway.getSupportedOperations(account);
    return support[operation] ?? false;
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
    return getCapabilities(type).getBatchLimit(operation);
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
    return getCapabilities(type).maxShareFileSize;
  }

  /// 获取最大过期天数
  static int _getMaxExpireDays(CloudDriveType type) {
    return getCapabilities(type).maxExpireDays;
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
    return getCapabilities(type).maxDownloadSize;
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
    final descriptor = CloudDriveProviderRegistry.get(type);
    if (descriptor == null) {
      throw StateError('未在 CloudDriveProviderRegistry 注册 $type');
    }
    final supportedAuth = descriptor.supportedAuthTypes ?? <AuthType>[];
    final authTypeName = supportedAuth.isNotEmpty
        ? supportedAuth.first.name
        : type.authType.name;
    return {
      'displayName': descriptor.displayName ?? type.name,
      'iconData': descriptor.iconData ?? type.iconData,
      'color': descriptor.color ?? type.color,
      'icon': type.icon,
      'authType': authTypeName,
      'supportedAuthTypes':
          supportedAuth.map((e) => e.name).toList(),
    };
  }
}
