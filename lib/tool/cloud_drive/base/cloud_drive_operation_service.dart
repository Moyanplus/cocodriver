import '../../../../../core/logging/log_manager.dart';
import '../data/models/cloud_drive_entities.dart';
import '../data/models/cloud_drive_dtos.dart';
import '../services/strategy_registry.dart';
import 'cloud_drive_file_service.dart';

/// 云盘操作服务
///
/// 实现策略模式，统一管理不同云盘平台的操作实现。
/// 通过策略注册机制实现动态策略选择和解耦。
abstract class CloudDriveOperationStrategy {
  // ===========================================
  // 一、查询类方法
  // ===========================================

  /// 获取文件列表
  Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    String? path,
    String? folderId,
    int page = 1,
    int pageSize = 50,
  });

  /// 获取账号详情（包含用户信息和容量信息）
  Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  });

  /// 搜索文件
  ///
  /// [account] 云盘账号信息
  /// [keyword] 搜索关键词
  /// [folderId] 可选，在指定文件夹内搜索，为null时在整个云盘搜索
  /// [page] 页码，默认第1页
  /// [pageSize] 每页数量，默认50
  /// [fileType] 可选，文件类型筛选（如：'file'、'folder'）
  /// 返回符合条件的文件列表
  Future<List<CloudDriveFile>> searchFiles({
    required CloudDriveAccount account,
    required String keyword,
    String? folderId,
    int page = 1,
    int pageSize = 50,
    String? fileType,
  });

  // ===========================================
  // 二、文件操作类方法（基础操作）
  // ===========================================

  /// 上传文件
  Future<Map<String, dynamic>> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String? folderId,
  });

  /// 获取下载链接
  Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  });

  /// 创建文件夹
  Future<Map<String, dynamic>?> createFolder({
    required CloudDriveAccount account,
    required String folderName,
    String? parentFolderId,
  });

  /// 移动文件
  Future<bool> moveFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    String? targetFolderId,
  });

  /// 复制文件
  Future<bool> copyFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String destPath,
    String? newName,
  });

  /// 重命名文件
  Future<bool> renameFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String newName,
  });

  /// 删除文件
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required CloudDriveFile file,
  });

  // ===========================================
  // 三、分享相关类方法
  // ===========================================

  /// 生成分享链接
  Future<String?> createShareLink({
    required CloudDriveAccount account,
    required List<CloudDriveFile> files,
    String? password,
    int? expireDays,
  });

  /// 高速下载 - 使用第三方解析服务获取直接下载链接
  Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  });

  // ===========================================
  // 四、配置和信息类方法
  // ===========================================

  /// 获取支持的操作
  Map<String, bool> getSupportedOperations();

  /// 获取UI配置
  Map<String, dynamic> getOperationUIConfig();

  // ===========================================
  // 五、路径处理类方法
  // ===========================================

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

  // ===========================================
  // 六、账号管理类方法
  // ===========================================

  /// 刷新鉴权信息
  ///
  /// [account] 云盘账号信息
  /// 返回刷新后的账号信息（包含更新后的token、cookies等）
  /// 如果刷新失败返回null
  Future<CloudDriveAccount?> refreshAuth({required CloudDriveAccount account});
}

/// 云盘操作服务工厂
///
/// 通过策略模式调用不同云盘平台的操作策略，实现操作的统一管理。
class CloudDriveOperationService {
  // ===========================================
  // 策略获取方法（基础方法）
  // ===========================================

  /// 获取操作策略
  ///
  /// [type] 云盘类型
  static CloudDriveOperationStrategy? getStrategy(CloudDriveType type) {
    LogManager().cloudDrive(
      '获取策略: ${type.displayName}',
      className: 'CloudDriveOperationService',
      methodName: 'getStrategy',
      data: {'type': type.displayName},
    );
    final strategy = StrategyRegistry.getStrategy(type);
    if (strategy != null) {
      LogManager().cloudDrive(
        '策略获取成功: ${strategy.runtimeType}',
        className: 'CloudDriveOperationService',
        methodName: 'getStrategy',
        data: {'strategyType': strategy.runtimeType.toString()},
      );
    } else {
      LogManager().warning(
        '策略未找到: ${type.displayName}',
        className: 'CloudDriveOperationService',
        methodName: 'getStrategy',
        data: {'type': type.displayName},
      );
    }
    return strategy;
  }

  // ===========================================
  // 一、查询类方法
  // ===========================================

  /// 获取账号详情
  static Future<CloudDriveAccountDetails?> getAccountDetails({
    required CloudDriveAccount account,
  }) async {
    final strategy = getStrategy(account.type);
    if (strategy == null) {
      LogManager().error('策略未找到: ${account.type.displayName}');
      return Future.value(null);
    }
    return strategy.getAccountDetails(account: account);
  }

  /// 搜索文件
  ///
  /// [account] 云盘账号信息
  /// [keyword] 搜索关键词
  /// [folderId] 可选，在指定文件夹内搜索，为null时在整个云盘搜索
  /// [page] 页码，默认第1页
  /// [pageSize] 每页数量，默认50
  /// [fileType] 可选，文件类型筛选（如：'file'、'folder'）
  /// 返回符合条件的文件列表
  static Future<List<CloudDriveFile>> searchFiles({
    required CloudDriveAccount account,
    required String keyword,
    String? folderId,
    int page = 1,
    int pageSize = 50,
    String? fileType,
  }) async {
    LogManager().cloudDrive(
      '云盘操作服务 - 搜索文件',
      className: 'CloudDriveOperationService',
      methodName: 'searchFiles',
      data: {
        'keyword': keyword,
        'folderId': folderId ?? '整个云盘',
        'page': page,
        'pageSize': pageSize,
        'fileType': fileType ?? '全部',
        'accountName': account.name,
        'accountType': account.type.displayName,
      },
    );

    final strategy = getStrategy(account.type);
    if (strategy == null) {
      LogManager().error('策略未找到: ${account.type.displayName}');
      return [];
    }

    try {
      final result = await strategy.searchFiles(
        account: account,
        keyword: keyword,
        folderId: folderId,
        page: page,
        pageSize: pageSize,
        fileType: fileType,
      );

      LogManager().cloudDrive(
        '云盘操作服务 - 搜索完成: 找到 ${result.length} 个文件',
        className: 'CloudDriveOperationService',
        methodName: 'searchFiles',
        data: {'resultCount': result.length, 'keyword': keyword},
      );

      return result;
    } catch (e, stackTrace) {
      LogManager().error(
        '云盘操作服务 - 搜索文件失败: $e',
        className: 'CloudDriveOperationService',
        methodName: 'searchFiles',
      );
      LogManager().error('错误堆栈: $stackTrace');
      return [];
    }
  }

  // ===========================================
  // 二、文件操作类方法（基础操作）
  // ===========================================

  /// 上传文件
  static Future<Map<String, dynamic>> uploadFile({
    required CloudDriveAccount account,
    required String filePath,
    required String fileName,
    String? folderId,
  }) async {
    LogManager().cloudDrive('云盘操作服务 - 上传文件');
    LogManager().cloudDrive('文件路径: $filePath');
    LogManager().cloudDrive('文件名: $fileName');
    LogManager().cloudDrive('文件夹ID: $folderId');
    LogManager().cloudDrive(
      '账号: ${account.name} (${account.type.displayName})',
    );

    final strategy = getStrategy(account.type);
    if (strategy == null) {
      LogManager().error('策略未找到: ${account.type.displayName}');
      return {
        'success': false,
        'message': '${account.type.displayName}上传功能暂未实现',
      };
    }

    final result = await strategy.uploadFile(
      account: account,
      filePath: filePath,
      fileName: fileName,
      folderId: folderId,
    );

    LogManager().cloudDrive('云盘操作服务 - 文件上传完成: ${result['success'] ?? false}');
    return result;
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
    if (strategy == null) {
      LogManager().error('策略未找到: ${account.type.displayName}');
      return null;
    }
    final result = await strategy.getDownloadUrl(account: account, file: file);

    LogManager().cloudDrive(
      '下载链接获取完成: ${result != null ? '成功' : '失败'}',
      className: 'CloudDriveOperationService',
      methodName: 'getDownloadUrl',
      data: {'success': result != null, 'fileName': file.name},
    );
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
    if (strategy == null) {
      LogManager().error('策略未找到: ${account.type.displayName}');
      return null;
    }
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
    if (strategy == null) {
      LogManager().error('策略未找到: ${account.type.displayName}');
      return false;
    }
    final result = await strategy.moveFile(
      account: account,
      file: file,
      targetFolderId: targetFolderId,
    );

    LogManager().cloudDrive('云盘操作服务 - 文件移动完成: $result');
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
    if (strategy == null) {
      LogManager().error('策略未找到: ${account.type.displayName}');
      return false;
    }
    final result = await strategy.copyFile(
      account: account,
      file: file,
      destPath: destPath,
      newName: newName,
    );

    LogManager().cloudDrive('云盘操作服务 - 文件复制完成: $result');
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
    if (strategy == null) {
      LogManager().error('策略未找到: ${account.type.displayName}');
      return false;
    }
    final result = await strategy.renameFile(
      account: account,
      file: file,
      newName: newName,
    );

    LogManager().cloudDrive('云盘操作服务 - 文件重命名完成: $result');
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
    if (strategy == null) {
      LogManager().error('策略未找到: ${account.type.displayName}');
      return false;
    }
    final result = await strategy.deleteFile(account: account, file: file);

    LogManager().cloudDrive('云盘操作服务 - 文件删除完成: $result');
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

  // ===========================================
  // 三、分享相关类方法
  // ===========================================

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
    if (strategy == null) {
      LogManager().error('策略未找到: ${account.type.displayName}');
      return null;
    }
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
    if (strategy == null) {
      LogManager().error('策略未找到: ${account.type.displayName}');
      return null;
    }
    final result = await strategy.getHighSpeedDownloadUrls(
      account: account,
      file: file,
      shareUrl: shareUrl,
      password: password,
    );

    LogManager().cloudDrive('云盘操作服务 - 高速下载完成: ${result != null ? '成功' : '失败'}');
    return result;
  }

  // ===========================================
  // 四、配置和信息类方法
  // ===========================================

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
    if (strategy == null) {
      LogManager().error('策略未找到: ${account.type.displayName}');
      return false;
    }
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
    if (strategy == null) {
      LogManager().error('策略未找到: ${account.type.displayName}');
      return {};
    }
    final config = strategy.getOperationUIConfig();

    LogManager().cloudDrive('云盘操作服务 - UI配置获取完成: ${config.keys}');
    return config;
  }

  // ===========================================
  // 五、路径处理类方法
  // ===========================================

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
    if (strategy == null) {
      LogManager().error('策略未找到: ${cloudDriveType.displayName}');
      return '';
    }
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
    if (strategy == null) {
      LogManager().error('策略未找到: ${cloudDriveType.displayName}');
      return file;
    }
    final result = strategy.updateFilePathForTargetDirectory(file, targetPath);

    LogManager().cloudDrive('云盘操作服务 - 文件路径更新完成');
    LogManager().cloudDrive('原路径: ${file.id} -> 新路径: ${result.id}');
    LogManager().cloudDrive(
      '原文件夹ID: ${file.folderId} -> 新文件夹ID: ${result.folderId}',
    );

    return result;
  }

  // ===========================================
  // 六、账号管理类方法
  // ===========================================

  /// 刷新鉴权信息
  ///
  /// [account] 云盘账号信息
  /// 返回刷新后的账号信息（包含更新后的token、cookies等）
  /// 如果刷新失败返回null
  static Future<CloudDriveAccount?> refreshAuth({
    required CloudDriveAccount account,
  }) async {
    LogManager().cloudDrive(
      '云盘操作服务 - 刷新鉴权信息',
      className: 'CloudDriveOperationService',
      methodName: 'refreshAuth',
      data: {
        'accountName': account.name,
        'accountType': account.type.displayName,
      },
    );

    final strategy = getStrategy(account.type);
    if (strategy == null) {
      LogManager().error('策略未找到: ${account.type.displayName}');
      return null;
    }

    try {
      final result = await strategy.refreshAuth(account: account);

      if (result != null) {
        LogManager().cloudDrive(
          '云盘操作服务 - 鉴权刷新成功',
          className: 'CloudDriveOperationService',
          methodName: 'refreshAuth',
          data: {
            'accountName': result.name,
            'accountType': result.type.displayName,
          },
        );
      } else {
        LogManager().warning(
          '云盘操作服务 - 鉴权刷新失败: 返回null',
          className: 'CloudDriveOperationService',
          methodName: 'refreshAuth',
        );
      }

      return result;
    } catch (e, stackTrace) {
      LogManager().error(
        '云盘操作服务 - 刷新鉴权失败: $e',
        className: 'CloudDriveOperationService',
        methodName: 'refreshAuth',
      );
      LogManager().error('错误堆栈: $stackTrace');
      return null;
    }
  }
}
