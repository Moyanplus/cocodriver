/// 基础数据模型定义
///
/// 定义应用程序中使用的通用数据模型
/// 使用Freezed和JSON序列化，提供不可变的数据结构
///
/// 主要功能：
/// - 基础实体模型
/// - 分页响应模型
/// - 错误响应模型
/// - 通用响应模型
/// - JSON序列化支持
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年

import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_model.freezed.dart';
part 'base_model.g.dart';

/// 基础数据模型
///
/// 提供所有实体的基础字段，包括ID、创建时间、更新时间等
/// 使用Freezed注解生成不可变的数据类
@freezed
class BaseModel with _$BaseModel {
  const factory BaseModel({
    /// 唯一标识符
    required String id,

    /// 创建时间
    required DateTime createdAt,

    /// 更新时间
    required DateTime updatedAt,

    /// 是否已删除
    @Default(false) bool isDeleted,

    /// 创建者（可选）
    String? createdBy,

    /// 更新者（可选）
    String? updatedBy,
  }) = _BaseModel;

  factory BaseModel.fromJson(Map<String, dynamic> json) =>
      _$BaseModelFromJson(json);
}

/// 分页响应模型
///
/// 提供分页数据的通用响应结构
/// 支持泛型，可以包装任何类型的数据列表
@Freezed(genericArgumentFactories: true)
class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    /// 数据列表
    required List<T> data,

    /// 当前页码
    required int page,

    /// 每页数量
    required int limit,

    /// 总数量
    required int total,

    /// 总页数
    required int totalPages,
    @Default(false) bool hasNext,
    @Default(false) bool hasPrevious,
  }) = _PaginatedResponse<T>;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);
}

/// API响应模型
@Freezed(genericArgumentFactories: true)
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    required String message,
    T? data,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) = _ApiResponse<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);
}

/// 用户模型
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String username,
    required String email,
    String? avatar,
    String? displayName,
    String? phone,
    DateTime? lastLoginAt,
    @Default(false) bool isActive,
    @Default(false) bool isVerified,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// 设置模型
@freezed
class SettingsModel with _$SettingsModel {
  const factory SettingsModel({
    required String id,
    required String userId,
    @Default('zh') String language,
    @Default('system') String theme,
    @Default(false) bool notifications,
    @Default(false) bool darkMode,
    @Default(false) bool autoUpdate,
    Map<String, dynamic>? customSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);
}

/// 统计模型
@freezed
class StatisticsModel with _$StatisticsModel {
  const factory StatisticsModel({
    required String id,
    required String userId,
    @Default(0) int totalSessions,
    @Default(0) int totalTime,
    @Default(0) int totalActions,
    Map<String, dynamic>? customStats,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) = _StatisticsModel;

  factory StatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$StatisticsModelFromJson(json);
}

/// 反馈模型
@freezed
class FeedbackModel with _$FeedbackModel {
  const factory FeedbackModel({
    required String id,
    required String userId,
    required String type,
    required String title,
    required String content,
    String? category,
    String? priority,
    @Default('pending') String status,
    String? response,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FeedbackModel;

  factory FeedbackModel.fromJson(Map<String, dynamic> json) =>
      _$FeedbackModelFromJson(json);
}
