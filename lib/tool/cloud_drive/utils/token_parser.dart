import 'dart:convert';

import '../../../core/services/base/debug_service.dart';
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
    DebugService.log(
      '🚀 TokenParser.parseToken被调用 - ${cloudDriveType.displayName}',
      category: DebugCategory.tools,
      subCategory: 'tokenParser.${cloudDriveType.name}',
    );

    if (rawToken.isEmpty) {
      DebugService.log(
        '❌ rawToken为空，直接返回',
        category: DebugCategory.tools,
        subCategory: 'tokenParser.${cloudDriveType.name}',
      );
      return '';
    }

    final logSubCategory = 'tokenParser.${cloudDriveType.name}';

    try {
      DebugService.log(
        '🔍 开始解析token: ${cloudDriveType.displayName}',
        category: DebugCategory.tools,
        subCategory: logSubCategory,
      );
      DebugService.log(
        '📝 原始token长度: ${rawToken.length}',
        category: DebugCategory.tools,
        subCategory: logSubCategory,
      );
      DebugService.log(
        '⚙️ 配置: isJsonFormat=${config.isJsonFormat}, jsonFieldPath=${config.jsonFieldPath}, enableDebugLog=${config.enableDebugLog}',
        category: DebugCategory.tools,
        subCategory: logSubCategory,
      );

      String processedToken = rawToken;

      // 步骤0: 检查是否为Cookie字符串且需要提取特定Cookie值
      if (config.cookieNames.isNotEmpty &&
          rawToken.contains('=') &&
          rawToken.contains(';')) {
        DebugService.log(
          '🍪 检测到Cookie字符串，尝试提取指定Cookie: ${config.cookieNames}',
          category: DebugCategory.tools,
          subCategory: logSubCategory,
        );

        final extractedCookie = _extractCookieValue(
          rawToken,
          config.cookieNames,
        );
        if (extractedCookie.isNotEmpty) {
          processedToken = extractedCookie;
          DebugService.log(
            '✅ 从Cookie中提取到值: ${processedToken.length}字符',
            category: DebugCategory.tools,
            subCategory: logSubCategory,
          );
        } else {
          DebugService.log(
            '⚠️ 未从Cookie中找到指定值: ${config.cookieNames}',
            category: DebugCategory.tools,
            subCategory: logSubCategory,
          );
        }
      }

      // 步骤1: 移除引号（如果配置要求）
      if (config.removeQuotes) {
        processedToken = _removeQuotes(processedToken);
        DebugService.log(
          '✂️ 移除引号后长度: ${processedToken.length}',
          category: DebugCategory.tools,
          subCategory: logSubCategory,
        );
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
        DebugService.log(
          '🏷️ 添加前缀后: ${config.tokenPrefix}[token]',
          category: DebugCategory.tools,
          subCategory: logSubCategory,
        );
      }

      DebugService.log(
        '✅ token解析完成: ${processedToken.length}字符',
        category: DebugCategory.tools,
        subCategory: logSubCategory,
      );
      if (processedToken.length > 50) {
        DebugService.log(
          '📋 token预览: ${processedToken.substring(0, 50)}...',
          category: DebugCategory.tools,
          subCategory: logSubCategory,
        );
      }

      return processedToken;
    } catch (e) {
      DebugService.log(
        '❌ token解析失败: $e',
        category: DebugCategory.tools,
        subCategory: logSubCategory,
      );
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
      DebugService.log(
        '📊 开始JSON解析...',
        category: DebugCategory.tools,
        subCategory: logSubCategory,
      );

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      DebugService.log(
        '📊 JSON解析成功，字段数: ${jsonData.keys.length}',
        category: DebugCategory.tools,
        subCategory: logSubCategory,
      );
      DebugService.log(
        '🔑 可用字段: ${jsonData.keys.join(', ')}',
        category: DebugCategory.tools,
        subCategory: logSubCategory,
      );

      // 提取指定字段
      if (config.jsonFieldPath != null) {
        final fieldValue = _extractJsonField(jsonData, config.jsonFieldPath!);
        if (fieldValue != null) {
          DebugService.log(
            '✅ 成功提取字段 ${config.jsonFieldPath}: ${fieldValue.toString().length}字符',
            category: DebugCategory.tools,
            subCategory: logSubCategory,
          );
          return fieldValue.toString();
        } else {
          DebugService.log(
            '⚠️ 字段 ${config.jsonFieldPath} 不存在或为空',
            category: DebugCategory.tools,
            subCategory: logSubCategory,
          );
        }
      }

      // 如果没有指定字段路径，或者字段不存在，返回整个JSON字符串
      DebugService.log(
        '📄 返回完整JSON数据',
        category: DebugCategory.tools,
        subCategory: logSubCategory,
      );
      return jsonString;
    } catch (e) {
      DebugService.log(
        '❌ JSON解析失败: $e',
        category: DebugCategory.tools,
        subCategory: logSubCategory,
      );
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

      DebugService.log(
        '📊 字段映射解析完成: ${result.keys.join(', ')}',
        category: DebugCategory.tools,
        subCategory: 'tokenParser.${cloudDriveType.name}',
      );
    } catch (e) {
      DebugService.log(
        '❌ 字段映射解析失败: $e',
        category: DebugCategory.tools,
        subCategory: 'tokenParser.${cloudDriveType.name}',
      );
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
