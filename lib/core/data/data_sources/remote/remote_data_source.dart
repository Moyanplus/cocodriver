import 'dart:io';
import 'package:dio/dio.dart';

import '../../../error/exceptions.dart';
import '../../../network/api_client.dart';
import '../../models/base_model.dart';

/// 远程数据源基类
abstract class RemoteDataSource {
  final ApiClient _apiClient;

  RemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClientFactory.getInstance();

  /// 处理API响应
  T _handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw ServerException(
        message: 'Invalid response status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    if (response.data is! Map<String, dynamic>) {
      throw ServerException(
        message: 'Invalid response format',
        statusCode: response.statusCode,
      );
    }

    return fromJson(response.data as Map<String, dynamic>);
  }

  /// 处理分页响应
  PaginatedResponse<T> _handlePaginatedResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw ServerException(
        message: 'Invalid response status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    if (response.data is! Map<String, dynamic>) {
      throw ServerException(
        message: 'Invalid response format',
        statusCode: response.statusCode,
      );
    }

    final data = response.data as Map<String, dynamic>;
    final items =
        (data['data'] as List)
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();

    return PaginatedResponse<T>(
      data: items,
      page: data['page'] ?? 1,
      limit: data['limit'] ?? 20,
      total: data['total'] ?? 0,
      totalPages: data['totalPages'] ?? 0,
      hasNext: data['hasNext'] ?? false,
      hasPrevious: data['hasPrevious'] ?? false,
    );
  }
}

/// 用户远程数据源
class UserRemoteDataSource extends RemoteDataSource {
  UserRemoteDataSource({ApiClient? apiClient}) : super(apiClient: apiClient);

  /// 获取用户设置
  Future<SettingsModel> getUserSettings() async {
    try {
      final response = await _apiClient.getUserSettings();
      return SettingsModel.fromJson(response);
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Failed to get user settings',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// 更新用户设置
  Future<SettingsModel> updateUserSettings(SettingsModel settings) async {
    try {
      final response = await _apiClient.updateUserSettings(settings.toJson());
      return SettingsModel.fromJson(response);
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Failed to update user settings',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// 获取用户统计信息
  Future<StatisticsModel> getUserStatistics() async {
    try {
      final response = await _apiClient.getUserStatistics();
      return StatisticsModel.fromJson(response);
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Failed to get user statistics',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }
}

/// 系统远程数据源
class SystemRemoteDataSource extends RemoteDataSource {
  SystemRemoteDataSource({ApiClient? apiClient}) : super(apiClient: apiClient);

  /// 获取系统信息
  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final response = await _apiClient.getSystemInfo();
      return response;
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Failed to get system info',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// 获取应用版本信息
  Future<Map<String, dynamic>> getAppVersion() async {
    try {
      final response = await _apiClient.getAppVersion();
      return response;
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Failed to get app version',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }
}

/// 反馈远程数据源
class FeedbackRemoteDataSource extends RemoteDataSource {
  FeedbackRemoteDataSource({ApiClient? apiClient})
    : super(apiClient: apiClient);

  /// 提交反馈
  Future<FeedbackModel> submitFeedback(FeedbackModel feedback) async {
    try {
      final response = await _apiClient.submitFeedback(feedback.toJson());
      return FeedbackModel.fromJson(response);
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Failed to submit feedback',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// 报告Bug
  Future<FeedbackModel> reportBug(FeedbackModel bugReport) async {
    try {
      final response = await _apiClient.reportBug(bugReport.toJson());
      return FeedbackModel.fromJson(response);
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Failed to report bug',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// 请求新功能
  Future<FeedbackModel> requestFeature(FeedbackModel featureRequest) async {
    try {
      final response = await _apiClient.requestFeature(featureRequest.toJson());
      return FeedbackModel.fromJson(response);
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Failed to request feature',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }
}

/// 文件远程数据源
class FileRemoteDataSource extends RemoteDataSource {
  FileRemoteDataSource({ApiClient? apiClient}) : super(apiClient: apiClient);

  /// 上传文件
  Future<Map<String, dynamic>> uploadFile(String filePath, String type) async {
    try {
      final file = File(filePath);
      final response = await _apiClient.uploadFile(file, type);
      return response;
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Failed to upload file',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// 上传图片
  Future<Map<String, dynamic>> uploadImage(
    String imagePath, {
    String? category,
  }) async {
    try {
      final file = File(imagePath);
      final response = await _apiClient.uploadImage(file, category);
      return response;
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Failed to upload image',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }
}
