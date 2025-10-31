import '../../../../../core/logging/log_manager.dart';
import '../data/models/cloud_drive_entities.dart';
import '../data/models/cloud_drive_dtos.dart';
import '../services/ali/ali_operation_strategy.dart';
import '../services/baidu/baidu_operation_strategy.dart';
import '../services/lanzou/lanzou_operation_strategy.dart';
import '../services/pan123/pan123_operation_strategy.dart';
import '../services/quark/strategy/quark_operation_strategy.dart';
import 'cloud_drive_file_service.dart';

/// 云盘操作服务 (Cloud Drive Operation Service)
///
/// 该服务实现了策略模式，用于管理和协调不同云盘平台的具体操作实现。
/// 通过统一的接口定义和动态策略选择，实现了对多个云盘平台的统一管理。
///
/// 核心功能：
/// 1. 策略管理
///    - 动态策略选择
///    - 策略注册机制
///    - 策略切换控制
///    - 默认策略支持
///
/// 2. 操作统一
///    - 标准化接口
///    - 统一的错误处理
///    - 一致的返回格式
///    - 操作权限控制
///
/// 3. 平台适配
///    - 多平台支持
///    - 平台特性处理
///    - 接口兼容性
///    - 版本适配
///
/// 4. 性能优化
///    - 策略缓存
///    - 操作队列
///    - 并发控制
///    - 资源管理
///
/// 5. 扩展能力
///    - 新平台集成
///    - 功能扩展
///    - 自定义策略
///    - 插件机制
///
/// 支持的云盘平台：
/// - 百度网盘 (BaiduCloudDriveOperationStrategy)
/// - 阿里云盘 (AliCloudDriveOperationStrategy)
/// - 夸克网盘 (QuarkCloudDriveOperationStrategy)
/// - 蓝奏云 (LanzouCloudDriveOperationStrategy)
/// - 123云盘 (Pan123CloudDriveOperationStrategy)
///
/// 使用方式：
/// ```dart
/// // 获取特定云盘的操作策略
/// final strategy = CloudDriveOperationService.getStrategy(CloudDriveType.baidu);
///
/// // 执行文件操作
/// final result = await strategy.getFileList(
///   account: account,
///   folderId: "root"
/// );
/// ```
///
/// 策略接口：
/// - 文件操作接口
/// - 下载管理接口
/// - 分享功能接口
/// - 账号管理接口
///
/// 扩展方式：
/// 1. 实现CloudDriveOperationStrategy接口
/// 2. 注册新的策略实现
/// 3. 添加平台特定功能
/// 4. 更新策略映射
///
/// 错误处理：
/// - 策略不存在处理
/// - 操作失败恢复
/// - 异常状态处理
/// - 降级策略支持
///
/// @author Flutter开发团队
/// @version 1.0.0
/// @since 2024年
/// @see CloudDriveBaseService
/// @see CloudDriveFileService
/// @see CloudDriveAccountService
///
/// 云盘操作策略接口
abstract class CloudDriveOperationStrategy {
  /// 获取文件列表
  Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? path,
    String? folderId,
    int page = 1,
    int pageSize = 50,
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
    LogManager().cloudDrive(
      '获取策略: ${type.displayName}',
      className: 'CloudDriveOperationService',
      methodName: 'getStrategy',
      data: {'type': type.displayName},
    );
    final strategy = _strategies[type] ?? LanzouCloudDriveOperationStrategy();
    LogManager().cloudDrive(
      '策略获取成功: ${strategy.runtimeType}',
      className: 'CloudDriveOperationService',
      methodName: 'getStrategy',
      data: {'strategyType': strategy.runtimeType.toString()},
    );
    return strategy;
  }

  /// 获取下载链接
  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    LogManager().cloudDrive(
      '获取下载链接',
      className: 'CloudDriveOperationService',
      methodName: 'getDownloadUrl',
      data: {
        'fileName': file.name,
        'fileId': file.id,
        'isFolder': file.isFolder,
        'accountName': account.name,
        'accountType': account.type.displayName,
      },
    );

    final strategy = getStrategy(account.type);
    final result = await strategy.getDownloadUrl(account: account, file: file);

    LogManager().cloudDrive(
      '下载链接获取完成: ${result != null ? '成功' : '失败'}',
      className: 'CloudDriveOperationService',
      methodName: 'getDownloadUrl',
      data: {'success': result != null, 'fileName': file.name},
    );
    return result;
  }

  /// 高速下载 - 使用第三方解析服务获取直接下载链接
  static Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    LogManager().cloudDrive(
      '开始高速下载',
      className: 'CloudDriveOperationService',
      methodName: 'getHighSpeedDownloadUrls',
      data: {
        'fileName': file.name,
        'fileId': file.id,
        'shareUrl': shareUrl,
        'accountName': account.name,
        'accountType': account.type.displayName,
      },
    );

    final strategy = getStrategy(account.type);
    final result = await strategy.getHighSpeedDownloadUrls(
      account: account,
      file: file,
      shareUrl: shareUrl,
      password: password,
    );

    LogManager().cloudDrive('云盘操作服务 - 高速下载完成: ${result != null ? '成功' : '失败'}');
    return result;
  }

  /// 生成分享链接
  static Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  }) async {
    LogManager().cloudDrive('云盘操作服务 - 生成分享链接');
    LogManager().cloudDrive('文件数量: ${files.length}');
    LogManager().cloudDrive('🔑 提取码: ${password ?? '无'}');
    LogManager().cloudDrive('有效期: ${expireDays ?? 1}天');
    LogManager().cloudDrive(
      '账号: ${account.name} (${account.type.displayName})',
    );

    final strategy = getStrategy(account.type);
    final result = await strategy.createShareLink(
      account: account,
      files: files,
      password: password,
      expireDays: expireDays,
    );

    LogManager().cloudDrive(
      '云盘操作服务 - 分享链接生成完成: ${result != null ? '成功' : '失败'}',
    );
    return result;
  }

  /// 移动文件
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  }) async {
    LogManager().cloudDrive('云盘操作服务 - 移动文件');
    LogManager().cloudDrive('文件: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive('目标文件夹ID: $targetFolderId');
    LogManager().cloudDrive(
      '账号: ${account.name} (${account.type.displayName})',
    );

    final strategy = getStrategy(account.type);
    final result = await strategy.moveFile(
      account: account,
      file: file,
      targetFolderId: targetFolderId,
    );

    LogManager().cloudDrive('云盘操作服务 - 文件移动完成: $result');
    return result;
  }

  /// 删除文件
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  }) async {
    LogManager().cloudDrive('云盘操作服务 - 删除文件');
    LogManager().cloudDrive('文件: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive(
      '账号: ${account.name} (${account.type.displayName})',
    );

    final strategy = getStrategy(account.type);
    final result = await strategy.deleteFile(account: account, file: file);

    LogManager().cloudDrive('云盘操作服务 - 文件删除完成: $result');
    return result;
  }

  /// 重命名文件
  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  }) async {
    LogManager().cloudDrive('云盘操作服务 - 重命名文件');
    LogManager().cloudDrive('文件: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive('新文件名: $newName');
    LogManager().cloudDrive(
      '账号: ${account.name} (${account.type.displayName})',
    );

    final strategy = getStrategy(account.type);
    final result = await strategy.renameFile(
      account: account,
      file: file,
      newName: newName,
    );

    LogManager().cloudDrive('云盘操作服务 - 文件重命名完成: $result');
    return result;
  }

  /// 复制文件
  static Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String destPath,
    String? newName,
  }) async {
    LogManager().cloudDrive('云盘操作服务 - 复制文件');
    LogManager().cloudDrive('文件: ${file.name} (ID: ${file.id})');
    LogManager().cloudDrive('目标路径: $destPath');
    LogManager().cloudDrive(
      '账号: ${account.name} (${account.type.displayName})',
    );

    final strategy = getStrategy(account.type);
    final result = await strategy.copyFile(
      account: account,
      file: file,
      destPath: destPath,
      newName: newName,
    );

    LogManager().cloudDrive('云盘操作服务 - 文件复制完成: $result');
    return result;
  }

  /// 创建文件夹
  static Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  }) async {
    LogManager().cloudDrive('云盘操作服务 - 创建文件夹');
    LogManager().cloudDrive('文件夹名称: $folderName');
    LogManager().cloudDrive('父文件夹ID: $parentFolderId');
    LogManager().cloudDrive(
      '账号: ${account.name} (${account.type.displayName})',
    );

    final strategy = getStrategy(account.type);
    final result = await strategy.createFolder(
      account: account,
      folderName: folderName,
      parentFolderId: parentFolderId,
    );

    LogManager().cloudDrive(
      '云盘操作服务 - 文件夹创建完成: ${result != null ? '成功' : '失败'}',
    );
    return result;
  }

  /// 检查操作是否支持
  static bool isOperationSupported(
    CloudDriveAccount account,
    String operation,
  ) {
    LogManager().cloudDrive('云盘操作服务 - 检查操作支持: $operation');
    LogManager().cloudDrive(
      '账号: ${account.name} (${account.type.displayName})',
    );

    final strategy = getStrategy(account.type);
    final supported = strategy.getSupportedOperations()[operation] ?? false;

    LogManager().cloudDrive('云盘操作服务 - 操作支持检查: $operation = $supported');
    return supported;
  }

  /// 获取UI配置
  static Map<String, dynamic> getUIConfig(CloudDriveAccount account) {
    LogManager().cloudDrive('云盘操作服务 - 获取UI配置');
    LogManager().cloudDrive(
      '账号: ${account.name} (${account.type.displayName})',
    );

    final strategy = getStrategy(account.type);
    final config = strategy.getOperationUIConfig();

    LogManager().cloudDrive('云盘操作服务 - UI配置获取完成: ${config.keys}');
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
    LogManager().cloudDrive('云盘操作服务 - 转换路径为目标文件夹ID');
    LogManager().cloudDrive('云盘类型: ${cloudDriveType.displayName}');
    LogManager().cloudDrive(
      '路径信息: ${folderPath.map((p) => '${p.name}(${p.id})').join(' -> ')}',
    );

    final strategy = getStrategy(cloudDriveType);
    final result = strategy.convertPathToTargetFolderId(folderPath);

    LogManager().cloudDrive('云盘操作服务 - 路径转换完成: $result');
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
    LogManager().cloudDrive('云盘操作服务 - 更新文件路径为目标目录');
    LogManager().cloudDrive(
      '文件: ${file.name} (${file.isFolder ? '文件夹' : '文件'})',
    );
    LogManager().cloudDrive('目标路径: $targetPath');
    LogManager().cloudDrive('云盘类型: ${cloudDriveType.displayName}');

    final strategy = getStrategy(cloudDriveType);
    final result = strategy.updateFilePathForTargetDirectory(file, targetPath);

    LogManager().cloudDrive('云盘操作服务 - 文件路径更新完成');
    LogManager().cloudDrive('原路径: ${file.id} -> 新路径: ${result.id}');
    LogManager().cloudDrive(
      '原文件夹ID: ${file.folderId} -> 新文件夹ID: ${result.folderId}',
    );

    return result;
  }

  /// 下载文件
  ///
  /// 委托给 [CloudDriveFileService.batchDownloadFiles] 处理
  /// 保持接口一致性，避免代码重复
  static Future<bool> downloadFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? savePath,
  }) async {
    try {
      LogManager().cloudDrive('云盘操作服务 - 开始下载文件: ${file.name}');

      // 委托给 CloudDriveFileService 处理批量下载
      // 这样可以复用统一的下载逻辑，避免代码重复
      await CloudDriveFileService.batchDownloadFiles(
        account: account,
        files: [file],
        folders: [],
      );

      LogManager().cloudDrive('云盘操作服务 - 下载任务创建成功: ${file.name}');
      return true;
    } catch (e, stackTrace) {
      LogManager().error('云盘操作服务 - 文件下载失败: $e');
      LogManager().error('错误堆栈: $stackTrace');
      return false;
    }
  }
}
