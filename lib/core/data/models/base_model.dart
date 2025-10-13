import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_model.freezed.dart';
part 'base_model.g.dart';

/// 基础数据模型
@freezed
class BaseModel with _$BaseModel {
  const factory BaseModel({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
    String? createdBy,
    String? updatedBy,
  }) = _BaseModel;

  factory BaseModel.fromJson(Map<String, dynamic> json) =>
      _$BaseModelFromJson(json);
}

/// 分页响应模型
@Freezed(genericArgumentFactories: true)
class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    required List<T> data,
    required int page,
    required int limit,
    required int total,
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
