// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionInfo _$VersionInfoFromJson(Map<String, dynamic> json) => VersionInfo(
      version: json['version'] as String,
      versionCode: (json['versionCode'] as num).toInt(),
      versionName: json['versionName'] as String,
      buildNumber: json['buildNumber'] as String,
    );

Map<String, dynamic> _$VersionInfoToJson(VersionInfo instance) =>
    <String, dynamic>{
      'version': instance.version,
      'versionCode': instance.versionCode,
      'versionName': instance.versionName,
      'buildNumber': instance.buildNumber,
    };

UpdateInfo _$UpdateInfoFromJson(Map<String, dynamic> json) => UpdateInfo(
      version: VersionInfo.fromJson(json['version'] as Map<String, dynamic>),
      updateType: $enumDecode(_$UpdateTypeEnumMap, json['updateType'],
          unknownValue: UpdateType.optional),
      title: json['title'] as String,
      description: json['description'] as String,
      features:
          (json['features'] as List<dynamic>).map((e) => e as String).toList(),
      downloadUrl: json['downloadUrl'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      md5: json['md5'] as String?,
      releaseTime: DateTime.parse(json['releaseTime'] as String),
      minSupportedVersion: json['minSupportedVersion'] as String?,
      silentDownload: json['silentDownload'] as bool? ?? false,
    );

Map<String, dynamic> _$UpdateInfoToJson(UpdateInfo instance) =>
    <String, dynamic>{
      'version': instance.version,
      'updateType': _$UpdateTypeEnumMap[instance.updateType]!,
      'title': instance.title,
      'description': instance.description,
      'features': instance.features,
      'downloadUrl': instance.downloadUrl,
      'fileSize': instance.fileSize,
      'md5': instance.md5,
      'releaseTime': instance.releaseTime.toIso8601String(),
      'minSupportedVersion': instance.minSupportedVersion,
      'silentDownload': instance.silentDownload,
    };

const _$UpdateTypeEnumMap = {
  UpdateType.force: 'force',
  UpdateType.recommend: 'recommend',
  UpdateType.optional: 'optional',
};
