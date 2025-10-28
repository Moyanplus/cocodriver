/// 云盘基础服务抽象类 (Cloud Drive Base Service Abstract Class)
///
/// 这是整个云盘服务的基础抽象类，为所有云盘平台提供统一的基础设施和功能接口。
/// 通过抽象方法定义标准接口，确保所有云盘实现的一致性和可维护性。
///
/// 核心功能：
/// 1. 网络请求管理
///    - 统一的HTTP请求处理（GET, POST, PUT, DELETE）
///    - 请求头和认证信息管理
///    - 响应解析和错误处理
///
/// 2. 性能监控
///    - 请求性能跟踪
///    - 操作耗时统计
///    - 资源使用监控
///
/// 3. 错误处理
///    - 统一的错误捕获机制
///    - 错误日志记录
///    - 重试策略实现
///
/// 4. 文件操作
///    - 文件列表获取
///    - 文件上传下载
///    - 文件管理操作
///
/// 5. 账号管理
///    - 账号验证
///    - 登录状态维护
///    - 会话管理
///
/// 技术特点：
/// - 使用Dio进行网络请求
/// - 支持异步操作
/// - 实现依赖注入模式
/// - 遵循SOLID原则
///
/// 使用方式：
/// 1. 继承此类实现具体云盘服务
/// 2. 实现所有抽象方法
/// 3. 根据需要重写部分方法
///
/// 扩展性：
/// - 易于添加新的云盘支持
/// - 可自定义请求处理
/// - 灵活的错误处理机制
///
/// @author Flutter开发团队
/// @version 1.0.0
/// @since 2024年
/// @see CloudDriveAccountService
/// @see CloudDriveFileService
/// @see CloudDriveOperationService

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// 云盘数据模型导入
import '../data/models/cloud_drive_entities.dart';

// 工具类导入
import '../utils/common_utils.dart';

// 性能监控导入
import '../infrastructure/performance/performance_metrics.dart';

/// 云盘基础服务抽象类
///
/// 提供云盘服务的通用功能，减少各云盘平台服务类的代码重复
/// 包含网络请求、性能监控、错误处理等基础功能
abstract class CloudDriveBaseService {
  // 性能监控实例
  final PerformanceMetrics _metrics = PerformanceMetrics();

  /// 创建Dio实例
  ///
  /// 为指定的云盘账号创建配置好的Dio实例
  /// 包含默认请求头和Cookie信息
  ///
  /// [account] 云盘账号信息
  /// 返回配置好的Dio实例
  Dio createDio(CloudDriveAccount account) {
    return CommonUtils.createDio(
      account: account,
      defaultHeaders: getDefaultHeaders(account),
    );
  }

  /// 获取默认请求头
  ///
  /// 为指定账号生成默认的HTTP请求头
  /// 包含Referer、Origin和Cookie信息
  ///
  /// [account] 云盘账号信息
  /// 返回请求头映射
  Map<String, String> getDefaultHeaders(CloudDriveAccount account) {
    final headers = <String, String>{
      'Referer': getRefererUrl(account),
      'Origin': getOriginUrl(account),
    };

    if (account.cookies != null) {
      headers['Cookie'] = account.cookies!;
    }

    return headers;
  }

  /// 获取Referer URL
  ///
  /// 获取指定账号对应的Referer URL
  ///
  /// [account] 云盘账号信息
  /// 返回Referer URL字符串
  String getRefererUrl(CloudDriveAccount account);

  /// 获取Origin URL
  ///
  /// 获取指定账号对应的Origin URL
  ///
  /// [account] 云盘账号信息
  /// 返回Origin URL字符串
  String getOriginUrl(CloudDriveAccount account);

  /// 统一的API请求方法
  ///
  /// 执行HTTP请求的统一入口，包含错误处理和性能监控
  ///
  /// [dio] Dio实例
  /// [method] HTTP方法
  /// [url] 请求URL
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [headers] 请求头
  /// [operationId] 操作ID，用于性能监控
  /// 返回响应结果
  Future<Response<T>> request<T>({
    required Dio dio,
    required String method,
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? operationId,
  }) async {
    return await CommonUtils.apiRequest<T>(
      dio: dio,
      method: method,
      url: url,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      operationId: operationId,
    );
  }

  /// 统一的GET请求
  ///
  /// 执行GET请求的便捷方法
  ///
  /// [dio] Dio实例
  /// [url] 请求URL
  /// [queryParameters] 查询参数
  /// [headers] 请求头
  /// [operationId] 操作ID
  /// 返回响应结果
  Future<Response<T>> get<T>({
    required Dio dio,
    required String url,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? operationId,
  }) async {
    return await request<T>(
      dio: dio,
      method: 'GET',
      url: url,
      queryParameters: queryParameters,
      headers: headers,
      operationId: operationId,
    );
  }

  /// 统一的POST请求
  ///
  /// 执行POST请求的便捷方法
  ///
  /// [dio] Dio实例
  /// [url] 请求URL
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [headers] 请求头
  /// [operationId] 操作ID
  /// 返回响应结果
  Future<Response<T>> post<T>({
    required Dio dio,
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? operationId,
  }) async {
    return await request<T>(
      dio: dio,
      method: 'POST',
      url: url,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      operationId: operationId,
    );
  }

  /// 统一的PUT请求
  ///
  /// 执行PUT请求的便捷方法
  ///
  /// [dio] Dio实例
  /// [url] 请求URL
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [headers] 请求头
  /// [operationId] 操作ID
  /// 返回响应结果
  Future<Response<T>> put<T>({
    required Dio dio,
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? operationId,
  }) async {
    return await request<T>(
      dio: dio,
      method: 'PUT',
      url: url,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      operationId: operationId,
    );
  }

  /// 统一的DELETE请求
  ///
  /// 执行DELETE请求的便捷方法
  ///
  /// [dio] Dio实例
  /// [url] 请求URL
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [headers] 请求头
  /// [operationId] 操作ID
  /// 返回响应结果
  Future<Response<T>> delete<T>({
    required Dio dio,
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? operationId,
  }) async {
    return await request<T>(
      dio: dio,
      method: 'DELETE',
      url: url,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      operationId: operationId,
    );
  }

  /// 统一的响应处理
  ///
  /// 处理HTTP响应的统一方法，包含错误检查和数据解析
  ///
  /// [response] HTTP响应
  /// [parser] 数据解析函数
  /// [errorMessage] 自定义错误消息
  /// 返回解析后的数据
  T handleResponse<T>({
    required Response response,
    required T Function(Map<String, dynamic>) parser,
    String? errorMessage,
  }) {
    return CommonUtils.parseResponse<T>(
      response: response,
      parser: parser,
      errorMessage: errorMessage,
    );
  }

  /// 统一的错误处理
  ///
  /// 处理各种类型错误的统一方法
  ///
  /// [error] 错误对象
  /// [operation] 操作名称
  /// 返回格式化的错误消息
  String handleError(dynamic error, {String? operation}) {
    return CommonUtils.handleError(error, operation: operation);
  }

  /// 统一的日志记录
  ///
  /// 记录信息级别日志
  ///
  /// [message] 日志消息
  /// [context] 上下文信息
  void logInfo(String message, {Map<String, dynamic>? context}) {
    CommonUtils.logInfo(message, context: context);
  }

  /// 记录成功日志
  ///
  /// 记录成功操作的日志
  ///
  /// [message] 日志消息
  /// [context] 上下文信息
  void logSuccess(String message, {Map<String, dynamic>? context}) {
    CommonUtils.logSuccess(message, context: context);
  }

  void logError(
    String message, {
    dynamic error,
    Map<String, dynamic>? context,
  }) {
    CommonUtils.logError(message, error: error, context: context);
  }

  void logWarning(String message, {Map<String, dynamic>? context}) {
    CommonUtils.logWarning(message, context: context);
  }

  /// 统一的文件操作包装
  Future<T> fileOperation<T>({
    required String operation,
    required Future<T> Function() operationFunction,
    String? fileName,
    int? fileSize,
    Map<String, dynamic>? context,
  }) async {
    return await CommonUtils.fileOperation<T>(
      operation: operation,
      operationFunction: operationFunction,
      fileName: fileName,
      fileSize: fileSize,
      context: context,
    );
  }

  /// 统一的账号验证
  Future<bool> validateAccount(CloudDriveAccount account) async {
    try {
      final dio = createDio(account);
      final response = await get(
        dio: dio,
        url: getValidationUrl(account),
        operationId: 'validate_account_${account.type.name}',
      );

      return isAccountValid(response);
    } catch (error) {
      logError(
        '账号验证失败',
        error: error,
        context: {'account_id': account.id, 'account_type': account.type.name},
      );
      return false;
    }
  }

  /// 获取验证URL
  String getValidationUrl(CloudDriveAccount account);

  /// 判断账号是否有效
  bool isAccountValid(Response response);

  /// 统一的文件列表获取
  Future<List<CloudDriveFile>> getFileList({
    required CloudDriveAccount account,
    required String folderId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final dio = createDio(account);
      final response = await post(
        dio: dio,
        url: getFileListUrl(account),
        data: getFileListData(account, folderId, page, pageSize),
        operationId: 'get_file_list_${account.type.name}',
      );

      return parseFileListResponse(response);
    } catch (error) {
      logError(
        '获取文件列表失败',
        error: error,
        context: {
          'account_id': account.id,
          'folder_id': folderId,
          'page': page,
        },
      );
      rethrow;
    }
  }

  /// 获取文件列表URL
  String getFileListUrl(CloudDriveAccount account);

  /// 获取文件列表请求数据
  Map<String, dynamic> getFileListData(
    CloudDriveAccount account,
    String folderId,
    int page,
    int pageSize,
  );

  /// 解析文件列表响应
  List<CloudDriveFile> parseFileListResponse(Response response);

  /// 统一的文件下载
  Future<String> getDownloadUrl({
    required CloudDriveAccount account,
    required String fileId,
  }) async {
    try {
      final dio = createDio(account);
      final response = await post(
        dio: dio,
        url: getDownloadUrlEndpoint(account),
        data: getDownloadUrlData(account, fileId),
        operationId: 'get_download_url_${account.type.name}',
      );

      return parseDownloadUrlResponse(response);
    } catch (error) {
      logError(
        '获取下载链接失败',
        error: error,
        context: {'account_id': account.id, 'file_id': fileId},
      );
      rethrow;
    }
  }

  /// 获取下载链接端点
  String getDownloadUrlEndpoint(CloudDriveAccount account);

  /// 获取下载链接请求数据
  Map<String, dynamic> getDownloadUrlData(
    CloudDriveAccount account,
    String fileId,
  );

  /// 解析下载链接响应
  String parseDownloadUrlResponse(Response response);

  /// 统一的文件重命名
  Future<bool> renameFile({
    required CloudDriveAccount account,
    required String fileId,
    required String newName,
  }) async {
    try {
      final dio = createDio(account);
      final response = await post(
        dio: dio,
        url: getRenameFileUrl(account),
        data: getRenameFileData(account, fileId, newName),
        operationId: 'rename_file_${account.type.name}',
      );

      return isRenameSuccess(response);
    } catch (error) {
      logError(
        '重命名文件失败',
        error: error,
        context: {
          'account_id': account.id,
          'file_id': fileId,
          'new_name': newName,
        },
      );
      return false;
    }
  }

  /// 获取重命名文件URL
  String getRenameFileUrl(CloudDriveAccount account);

  /// 获取重命名文件请求数据
  Map<String, dynamic> getRenameFileData(
    CloudDriveAccount account,
    String fileId,
    String newName,
  );

  /// 判断重命名是否成功
  bool isRenameSuccess(Response response);

  /// 统一的文件删除
  Future<bool> deleteFile({
    required CloudDriveAccount account,
    required String fileId,
  }) async {
    try {
      final dio = createDio(account);
      final response = await post(
        dio: dio,
        url: getDeleteFileUrl(account),
        data: getDeleteFileData(account, fileId),
        operationId: 'delete_file_${account.type.name}',
      );

      return isDeleteSuccess(response);
    } catch (error) {
      logError(
        '删除文件失败',
        error: error,
        context: {'account_id': account.id, 'file_id': fileId},
      );
      return false;
    }
  }

  /// 获取删除文件URL
  String getDeleteFileUrl(CloudDriveAccount account);

  /// 获取删除文件请求数据
  Map<String, dynamic> getDeleteFileData(
    CloudDriveAccount account,
    String fileId,
  );

  /// 判断删除是否成功
  bool isDeleteSuccess(Response response);

  /// 统一的文件夹创建
  Future<bool> createFolder({
    required CloudDriveAccount account,
    required String parentId,
    required String folderName,
  }) async {
    try {
      final dio = createDio(account);
      final response = await post(
        dio: dio,
        url: getCreateFolderUrl(account),
        data: getCreateFolderData(account, parentId, folderName),
        operationId: 'create_folder_${account.type.name}',
      );

      return isCreateFolderSuccess(response);
    } catch (error) {
      logError(
        '创建文件夹失败',
        error: error,
        context: {
          'account_id': account.id,
          'parent_id': parentId,
          'folder_name': folderName,
        },
      );
      return false;
    }
  }

  /// 获取创建文件夹URL
  String getCreateFolderUrl(CloudDriveAccount account);

  /// 获取创建文件夹请求数据
  Map<String, dynamic> getCreateFolderData(
    CloudDriveAccount account,
    String parentId,
    String folderName,
  );

  /// 判断创建文件夹是否成功
  bool isCreateFolderSuccess(Response response);

  /// 统一的账号信息获取
  Future<CloudDriveAccountDetails> getAccountDetails(
    CloudDriveAccount account,
  ) async {
    try {
      final dio = createDio(account);
      final response = await get(
        dio: dio,
        url: getAccountDetailsUrl(account),
        operationId: 'get_account_details_${account.type.name}',
      );

      return parseAccountDetailsResponse(response);
    } catch (error) {
      logError('获取账号详情失败', error: error, context: {'account_id': account.id});
      rethrow;
    }
  }

  /// 获取账号详情URL
  String getAccountDetailsUrl(CloudDriveAccount account);

  /// 解析账号详情响应
  CloudDriveAccountDetails parseAccountDetailsResponse(Response response);

  /// 统一的网络状态检查
  Future<bool> checkNetworkConnectivity() async {
    return await CommonUtils.checkNetworkConnectivity();
  }

  /// 统一的延迟执行
  Future<void> delay(Duration duration) async {
    await CommonUtils.delay(duration);
  }

  /// 统一的防抖执行
  void debounce(Duration delay, VoidCallback callback) {
    CommonUtils.debounce(delay, callback);
  }

  /// 统一的节流执行
  bool throttle(Duration interval, VoidCallback callback) {
    return CommonUtils.throttle(interval, callback);
  }
}
