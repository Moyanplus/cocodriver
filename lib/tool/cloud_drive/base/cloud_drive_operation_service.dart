import '../../../core/services/base/debug_service.dart';
import '../models/cloud_drive_models.dart';
import '../services/ali/ali_operation_strategy.dart';
import '../services/baidu/baidu_operation_strategy.dart';
import '../services/lanzou/lanzou_operation_strategy.dart';
import '../services/pan123/pan123_operation_strategy.dart';
import '../services/quark/quark_operation_strategy.dart';

/// 云盘操作策略接口
abstract class CloudDriveOperationStrategy {
  /// 获取文件列表
  Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? path,
    String? folderId,
  });

  /// 获取下载链接
  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  });

  /// 高速下载 - 使用第三方解析服务获取直接下载链接
  Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  });

  /// 生成分享链接
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  });

  /// 移动文件
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  });

  /// 删除文件
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  });

  /// 重命名文件
  Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  });

  /// 复制文件
  Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String destPath,
    String? newName,
  });

  /// 创建文件夹
  Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  });

  /// 获取支持的操作
  Map<String, bool> getSupportedOperations();

  /// 获取UI配置
  Map<String, dynamic> getOperationUIConfig();

  /// 获取账号详情（包含用户信息和容量信息）
  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  });

  /// 将路径信息转换为目标文件夹ID
  /// [folderPath] 当前的文件夹路径信息
  /// 返回适合该云盘类型的目标文件夹ID
  String convertPathToTargetFolderId(List<PathInfo> folderPath);

  /// 更新文件的路径信息为目标目录
  /// [file] 要更新的文件
  /// [targetPath] 目标路径
  /// 返回更新后的文件对象
  CloudDriveFile updateFilePathForTargetDirectory(
    CloudDriveFile file,
    String targetPath,
  );
}

/// 云盘操作服务工厂
class CloudDriveOperationService {
  static final Map<CloudDriveType, CloudDriveOperationStrategy> _strategies = {
    CloudDriveType.baidu: BaiduCloudDriveOperationStrategy(),
    CloudDriveType.lanzou: LanzouCloudDriveOperationStrategy(),
    CloudDriveType.pan123: Pan123CloudDriveOperationStrategy(),
    CloudDriveType.ali: AliCloudDriveOperationStrategy(), // 使用阿里云盘专用策略
    CloudDriveType.quark: QuarkCloudDriveOperationStrategy(),
  };

  /// 获取操作策略
  static CloudDriveOperationStrategy getStrategy(CloudDriveType type) {
    DebugService.log('🔧 云盘操作服务 - 获取策略: ${type.displayName}');
    final strategy = _strategies[type] ?? LanzouCloudDriveOperationStrategy();
    DebugService.log('✅ 云盘操作服务 - 策略获取成功: ${strategy.runtimeType}');
    return strategy;
  }

  /// 获取下载链接
  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    DebugService.log('🔗 云盘操作服务 - 获取下载链接');
    DebugService.log('📄 文件: ${file.name} (${file.isFolder ? '文件夹' : '文件'})');
    DebugService.log('👤 账号: ${account.name} (${account.type.displayName})');

    final strategy = getStrategy(account.type);
    final result = await strategy.getDownloadUrl(account: account, file: file);

    DebugService.log('✅ 云盘操作服务 - 下载链接获取完成: ${result != null ? '成功' : '失败'}');
    return result;
  }

  /// 高速下载 - 使用第三方解析服务获取直接下载链接
  static Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    DebugService.log('🚀 云盘操作服务 - 开始高速下载');
    DebugService.log('📄 文件: ${file.name} (ID: ${file.id})');
    DebugService.log('🔗 分享链接: $shareUrl');
    DebugService.log('🔑 提取密码: $password');
    DebugService.log('👤 账号: ${account.name} (${account.type.displayName})');

    final strategy = getStrategy(account.type);
    final result = await strategy.getHighSpeedDownloadUrls(
      account: account,
      file: file,
      shareUrl: shareUrl,
      password: password,
    );

    DebugService.log('✅ 云盘操作服务 - 高速下载完成: ${result != null ? '成功' : '失败'}');
    return result;
  }

  /// 生成分享链接
  static Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    DebugService.log('🔗 云盘操作服务 - 生成分享链接');
    DebugService.log('📄 文件数量: ${files.length}');
    DebugService.log('🔑 提取码: ${password ?? '无'}');
    DebugService.log('⏰ 有效期: ${expireDays ?? 1}天');
    DebugService.log('👤 账号: ${account.name} (${account.type.displayName})');

    final strategy = getStrategy(account.type);
    final result = await strategy.createShareLink(
      account: account,
      files: files,
      password: password,
      expireDays: expireDays,
    );

    DebugService.log('✅ 云盘操作服务 - 分享链接生成完成: ${result != null ? '成功' : '失败'}');
    return result;
  }

  /// 移动文件
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    DebugService.log('🔗 云盘操作服务 - 移动文件');
    DebugService.log('📄 文件: ${file.name} (ID: ${file.id})');
    DebugService.log('📁 目标文件夹ID: $targetFolderId');
    DebugService.log('👤 账号: ${account.name} (${account.type.displayName})');

    final strategy = getStrategy(account.type);
    final result = await strategy.moveFile(
      account: account,
      file: file,
      targetFolderId: targetFolderId,
    );

    DebugService.log('✅ 云盘操作服务 - 文件移动完成: $result');
    return result;
  }

  /// 删除文件
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    DebugService.log('🔗 云盘操作服务 - 删除文件');
    DebugService.log('📄 文件: ${file.name} (ID: ${file.id})');
    DebugService.log('👤 账号: ${account.name} (${account.type.displayName})');

    final strategy = getStrategy(account.type);
    final result = await strategy.deleteFile(account: account, file: file);

    DebugService.log('✅ 云盘操作服务 - 文件删除完成: $result');
    return result;
  }

  /// 重命名文件
  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    DebugService.log('🔗 云盘操作服务 - 重命名文件');
    DebugService.log('📄 文件: ${file.name} (ID: ${file.id})');
    DebugService.log('🔄 新文件名: $newName');
    DebugService.log('👤 账号: ${account.name} (${account.type.displayName})');

    final strategy = getStrategy(account.type);
    final result = await strategy.renameFile(
      account: account,
      file: file,
      newName: newName,
    );

    DebugService.log('✅ 云盘操作服务 - 文件重命名完成: $result');
    return result;
  }

  /// 复制文件
  static Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String destPath,
    String? newName,
  }) async {
    DebugService.log('🔗 云盘操作服务 - 复制文件');
    DebugService.log('📄 文件: ${file.name} (ID: ${file.id})');
    DebugService.log('📁 目标路径: $destPath');
    DebugService.log('👤 账号: ${account.name} (${account.type.displayName})');

    final strategy = getStrategy(account.type);
    final result = await strategy.copyFile(
      account: account,
      file: file,
      destPath: destPath,
      newName: newName,
    );

    DebugService.log('✅ 云盘操作服务 - 文件复制完成: $result');
    return result;
  }

  /// 创建文件夹
  static Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    DebugService.log('🔗 云盘操作服务 - 创建文件夹');
    DebugService.log('📁 文件夹名称: $folderName');
    DebugService.log('📁 父文件夹ID: $parentFolderId');
    DebugService.log('👤 账号: ${account.name} (${account.type.displayName})');

    final strategy = getStrategy(account.type);
    final result = await strategy.createFolder(
      account: account,
      folderName: folderName,
      parentFolderId: parentFolderId,
    );

    DebugService.log('✅ 云盘操作服务 - 文件夹创建完成: ${result != null ? '成功' : '失败'}');
    return result;
  }

  /// 检查操作是否支持
  static bool isOperationSupported(
    CloudDriveAccount account,
    String operation,
  ) {
    DebugService.log('🔧 云盘操作服务 - 检查操作支持: $operation');
    DebugService.log('👤 账号: ${account.name} (${account.type.displayName})');

    final strategy = getStrategy(account.type);
    final supported = strategy.getSupportedOperations()[operation] ?? false;

    DebugService.log('✅ 云盘操作服务 - 操作支持检查: $operation = $supported');
    return supported;
  }

  /// 获取UI配置
  static Map<String, dynamic> getUIConfig(CloudDriveAccount account) {
    DebugService.log('🎨 云盘操作服务 - 获取UI配置');
    DebugService.log('👤 账号: ${account.name} (${account.type.displayName})');

    final strategy = getStrategy(account.type);
    final config = strategy.getOperationUIConfig();

    DebugService.log('✅ 云盘操作服务 - UI配置获取完成: ${config.keys}');
    return config;
  }

  /// 获取账号详情
  static Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) {
    final strategy = getStrategy(account.type);
    return strategy.getAccountDetails(account: account);
  }

  /// 将路径信息转换为目标文件夹ID
  /// [cloudDriveType] 云盘类型
  /// [folderPath] 当前的文件夹路径信息
  /// 返回适合该云盘类型的目标文件夹ID
  static String convertPathToTargetFolderId({
    required CloudDriveType cloudDriveType,
    required List<PathInfo> folderPath,
  }) {
    DebugService.log('🔧 云盘操作服务 - 转换路径为目标文件夹ID');
    DebugService.log('📁 云盘类型: ${cloudDriveType.displayName}');
    DebugService.log(
      '📂 路径信息: ${folderPath.map((p) => '${p.name}(${p.id})').join(' -> ')}',
    );

    final strategy = getStrategy(cloudDriveType);
    final result = strategy.convertPathToTargetFolderId(folderPath);

    DebugService.log('✅ 云盘操作服务 - 路径转换完成: $result');
    return result;
  }

  /// 更新文件的路径信息为目标目录
  /// [cloudDriveType] 云盘类型
  /// [file] 要更新的文件
  /// [targetPath] 目标路径
  /// 返回更新后的文件对象
  static CloudDriveFile updateFilePathForTargetDirectory({
    required CloudDriveType cloudDriveType,
    required CloudDriveFile file,
    required String targetPath,
  }) {
    DebugService.log('🔧 云盘操作服务 - 更新文件路径为目标目录');
    DebugService.log('📄 文件: ${file.name} (${file.isFolder ? '文件夹' : '文件'})');
    DebugService.log('📁 目标路径: $targetPath');
    DebugService.log('👤 云盘类型: ${cloudDriveType.displayName}');

    final strategy = getStrategy(cloudDriveType);
    final result = strategy.updateFilePathForTargetDirectory(file, targetPath);

    DebugService.log('✅ 云盘操作服务 - 文件路径更新完成');
    DebugService.log('🔄 原路径: ${file.id} -> 新路径: ${result.id}');
    DebugService.log(
      '📁 原文件夹ID: ${file.folderId} -> 新文件夹ID: ${result.folderId}',
    );

    return result;
  }
}
