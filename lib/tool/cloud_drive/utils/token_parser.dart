import 'dart:convert';

import '../../../../core/logging/log_manager.dart';
import '../models/cloud_drive_models.dart';

/// 通用Token解析器
/// 根据TokenConfig配置，解析不同格式的token数据
class TokenParser {
  /// 解析token数据
  ///
  /// [rawToken] - 从localStorage/sessionStorage/cookie获取的原始token
  /// [config] - token配置信息
  /// [cloudDriveType] - 云盘类型（用于日志）
  ///
  /// 返回解析后的token字符串，如果是JSON格式会提取指定字段
  static String parseToken(
    String rawToken,
    TokenConfig config,
    CloudDriveType cloudDriveType,
  ) {
    // 首先输出调用确认日志
    LogManager().cloudDrive(
      '🚀 TokenParser.parseToken被调用 - ${cloudDriveType.displayName}',
    );

    if (rawToken.isEmpty) {
      LogManager().cloudDrive('❌ rawToken为空，直接返回');
      return '';
    }

    final logSubCategory = 'tokenParser.${cloudDriveType.name}';

    try {
      LogManager().cloudDrive('🔍 开始解析token: ${cloudDriveType.displayName}');
      LogManager().cloudDrive('📝 原始token长度: ${rawToken.length}');
      LogManager().cloudDrive(
        '⚙️ 配置: isJsonFormat=${config.isJsonFormat}, jsonFieldPath=${config.jsonFieldPath}, enableDebugLog=${config.enableDebugLog}',
      );

      String processedToken = rawToken;

      // 步骤0: 检查是否为Cookie字符串且需要提取特定Cookie值
      if (config.cookieNames.isNotEmpty &&
          rawToken.contains('=') &&
          rawToken.contains(';')) {
        LogManager().cloudDrive(
          '🍪 检测到Cookie字符串，尝试提取指定Cookie: ${config.cookieNames}',
        );

        final extractedCookie = _extractCookieValue(
          rawToken,
          config.cookieNames,
        );
        if (extractedCookie.isNotEmpty) {
          processedToken = extractedCookie;
          LogManager().cloudDrive('✅ 从Cookie中提取到值: ${processedToken.length}字符');
        } else {
          LogManager().cloudDrive('⚠️ 未从Cookie中找到指定值: ${config.cookieNames}');
        }
      }

      // 步骤1: 移除引号（如果配置要求）
      if (config.removeQuotes) {
        processedToken = _removeQuotes(processedToken);
        LogManager().cloudDrive('✂️ 移除引号后长度: ${processedToken.length}');
      }

      // 步骤2: JSON格式解析
      if (config.isJsonFormat) {
        processedToken = _parseJsonToken(
          processedToken,
          config,
          logSubCategory,
        );
      }

      // 步骤3: 添加token前缀（如果配置要求）
      if (config.tokenPrefix != null && config.tokenPrefix!.isNotEmpty) {
        processedToken = '${config.tokenPrefix}$processedToken';
        LogManager().cloudDrive('🏷️ 添加前缀后: ${config.tokenPrefix}[token]');
      }

      LogManager().cloudDrive('✅ token解析完成: ${processedToken.length}字符');
      if (processedToken.length > 50) {
        LogManager().cloudDrive(
          '📋 token预览: ${processedToken.substring(0, 50)}...',
        );
      }

      return processedToken;
    } catch (e) {
      LogManager().cloudDrive('❌ token解析失败: $e');
      return rawToken; // 解析失败时返回原始token
    }
  }

  /// 移除token字符串中的引号
  static String _removeQuotes(String token) {
    String result = token.trim();

    // 移除开头和结尾的双引号
    if (result.startsWith('"') && result.endsWith('"') && result.length >= 2) {
      result = result.substring(1, result.length - 1);
    }

    // 移除开头和结尾的单引号
    if (result.startsWith("'") && result.endsWith("'") && result.length >= 2) {
      result = result.substring(1, result.length - 1);
    }

    return result;
  }

  /// 解析JSON格式的token
  static String _parseJsonToken(
    String jsonString,
    TokenConfig config,
    String logSubCategory,
  ) {
    try {
      LogManager().cloudDrive('📊 开始JSON解析...');

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      LogManager().cloudDrive('📊 JSON解析成功，字段数: ${jsonData.keys.length}');
      LogManager().cloudDrive('🔑 可用字段: ${jsonData.keys.join(', ')}');

      // 提取指定字段
      if (config.jsonFieldPath != null) {
        final fieldValue = _extractJsonField(jsonData, config.jsonFieldPath!);
        if (fieldValue != null) {
          LogManager().cloudDrive(
            '✅ 成功提取字段 ${config.jsonFieldPath}: ${fieldValue.toString().length}字符',
          );
          return fieldValue.toString();
        } else {
          LogManager().cloudDrive('⚠️ 字段 ${config.jsonFieldPath} 不存在或为空');
        }
      }

      // 如果没有指定字段路径，或者字段不存在，返回整个JSON字符串
      LogManager().cloudDrive('📄 返回完整JSON数据');
      return jsonString;
    } catch (e) {
      LogManager().cloudDrive('❌ JSON解析失败: $e');
      return jsonString; // JSON解析失败时返回原始字符串
    }
  }

  /// 从JSON对象中提取指定路径的字段值
  /// 支持嵌套路径，如 "user.profile.name"
  static dynamic _extractJsonField(
    Map<String, dynamic> json,
    String fieldPath,
  ) {
    final pathParts = fieldPath.split('.');
    dynamic current = json;

    for (final part in pathParts) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else {
        return null; // 路径不存在
      }
    }

    return current;
  }

  /// 解析字段映射（如果需要提取多个字段）
  /// 返回Map<String, String>，key为目标用途，value为提取的值
  static Map<String, String> parseFieldMapping(
    String jsonString,
    TokenConfig config,
    CloudDriveType cloudDriveType,
  ) {
    final result = <String, String>{};

    if (!config.isJsonFormat || config.fieldMapping == null) {
      return result;
    }

    try {
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      config.fieldMapping!.forEach((sourceField, targetKey) {
        final value = _extractJsonField(jsonData, sourceField);
        if (value != null) {
          result[targetKey] = value.toString();
        }
      });

      LogManager().cloudDrive('📊 字段映射解析完成: ${result.keys.join(', ')}');
    } catch (e) {
      LogManager().cloudDrive('❌ 字段映射解析失败: $e');
    }

    return result;
  }

  /// 从Cookie字符串中提取指定Cookie值
  static String _extractCookieValue(
    String cookieString,
    List<String> cookieNames,
  ) {
    final cookies = <String, String>{};

    // 解析Cookie字符串
    for (final cookie in cookieString.split(';')) {
      final trimmedCookie = cookie.trim();
      if (trimmedCookie.isEmpty) continue;

      final eqIdx = trimmedCookie.indexOf('=');
      if (eqIdx > 0) {
        final name = trimmedCookie.substring(0, eqIdx).trim();
        final value = trimmedCookie.substring(eqIdx + 1).trim();
        cookies[name] = value;
      }
    }

    // 按优先级查找Cookie值
    for (final cookieName in cookieNames) {
      if (cookies.containsKey(cookieName)) {
        return cookies[cookieName]!;
      }
    }

    return '';
  }
}
