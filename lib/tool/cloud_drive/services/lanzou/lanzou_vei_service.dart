import 'package:dio/dio.dart';

import '../../../core/services/base/debug_service.dart';
import 'lanzou_config.dart';

/// 蓝奏云vei参数管理服务
/// 专门负责vei参数的获取、存储和管理
class LanzouVeiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: LanzouConfig.baseUrl,
      connectTimeout: LanzouConfig.connectTimeout,
      receiveTimeout: LanzouConfig.receiveTimeout,
      sendTimeout: LanzouConfig.sendTimeout,
      headers: LanzouConfig.defaultHeaders,
    ),
  );

  /// 从HTML页面中提取vei参数
  static String? extractVeiFromHtml(String html) {
    try {
      DebugService.log(
        '🔍 蓝奏云 - 开始从HTML中提取vei参数',
        category: DebugCategory.tools,
        subCategory: LanzouConfig.logSubCategory,
      );

      // 使用正则表达式匹配vei参数
      final regex = RegExp(r"'vei':'([^']+)'");
      final match = regex.firstMatch(html);

      if (match != null && match.groupCount >= 1) {
        final vei = match.group(1);
        DebugService.log(
          '✅ 蓝奏云 - 成功提取vei参数: $vei',
          category: DebugCategory.tools,
          subCategory: LanzouConfig.logSubCategory,
        );
        return vei;
      }

      // 备用正则表达式，匹配不同的格式
      final regex2 = RegExp(r'"vei":"([^"]+)"');
      final match2 = regex2.firstMatch(html);

      if (match2 != null && match2.groupCount >= 1) {
        final vei = match2.group(1);
        DebugService.log(
          '✅ 蓝奏云 - 成功提取vei参数(备用): $vei',
          category: DebugCategory.tools,
          subCategory: LanzouConfig.logSubCategory,
        );
        return vei;
      }

      DebugService.error('❌ 蓝奏云 - 无法从HTML中提取vei参数', null);
      return null;
    } catch (e) {
      DebugService.error('❌ 蓝奏云 - 提取vei参数时发生错误: $e', e);
      return null;
    }
  }

  /// 创建包含Cookie的请求头
  static Map<String, String> _createHeaders(String cookies, String uid) {
    DebugService.log(
      '🔧 蓝奏云 - 创建vei请求头',
      category: DebugCategory.tools,
      subCategory: LanzouConfig.logSubCategory,
    );

    final headers = Map<String, String>.from(LanzouConfig.pageHeaders);
    headers['Cookie'] = cookies;
    headers['Referer'] = '${LanzouConfig.baseUrl}/';
    headers['Origin'] = LanzouConfig.baseUrl;
    headers['X-Requested-With'] = 'XMLHttpRequest';

    DebugService.log(
      '🔧 蓝奏云 - vei请求头创建完成',
      category: DebugCategory.tools,
      subCategory: LanzouConfig.logSubCategory,
    );

    return headers;
  }

  /// 获取vei参数
  static Future<String?> getVeiParameter(
    String userId, {
    String? cookies,
  }) async {
    try {
      DebugService.log(
        '🔍 蓝奏云 - 开始获取vei参数',
        category: DebugCategory.tools,
        subCategory: LanzouConfig.logSubCategory,
      );
      DebugService.log(
        '👤 蓝奏云 - 用户ID: $userId',
        category: DebugCategory.tools,
        subCategory: LanzouConfig.logSubCategory,
      );

      // 创建包含Cookie的请求头
      final headers =
          cookies != null
              ? _createHeaders(cookies, userId)
              : LanzouConfig.pageHeaders;

      final response = await _dio.get(
        LanzouConfig.mydiskUrl,
        queryParameters: {'item': 'files', 'action': 'index', 'u': userId},
        options: Options(
          headers: headers,
          followRedirects: LanzouConfig.followRedirects,
          maxRedirects: LanzouConfig.maxRedirects,
          validateStatus: LanzouConfig.validateStatus,
        ),
      );

      if (response.statusCode == 200) {
        final html = response.data.toString();
        final vei = extractVeiFromHtml(html);

        if (vei != null) {
          // 将vei参数存储到配置中
          LanzouConfig.setVeiParameter(vei);
          DebugService.log(
            '✅ 蓝奏云 - 成功获取并存储vei参数: $vei',
            category: DebugCategory.tools,
            subCategory: LanzouConfig.logSubCategory,
          );
          return vei;
        } else {
          DebugService.error('❌ 蓝奏云 - 无法从响应中提取vei参数', null);
          return null;
        }
      } else {
        DebugService.error(
          '❌ 蓝奏云 - 获取vei参数失败，状态码: ${response.statusCode}',
          null,
        );
        return null;
      }
    } catch (e) {
      DebugService.error('❌ 蓝奏云 - 获取vei参数时发生错误: $e', e);
      return null;
    }
  }

  /// 初始化vei参数
  /// 如果配置中没有vei参数，则自动获取
  static Future<String?> initializeVeiParameter(
    String userId, {
    String? cookies,
  }) async {
    try {
      DebugService.log(
        '🔍 蓝奏云 - 检查vei参数状态',
        category: DebugCategory.tools,
        subCategory: LanzouConfig.logSubCategory,
      );

      // 如果已经有vei参数，直接返回
      if (LanzouConfig.hasVeiParameter()) {
        final vei = LanzouConfig.getVeiParameter();
        DebugService.log(
          '✅ 蓝奏云 - 使用已缓存的vei参数: $vei',
          category: DebugCategory.tools,
          subCategory: LanzouConfig.logSubCategory,
        );
        return vei;
      }

      // 如果没有vei参数，则获取
      DebugService.log(
        '🔄 蓝奏云 - 未找到vei参数，开始获取',
        category: DebugCategory.tools,
        subCategory: LanzouConfig.logSubCategory,
      );

      return await getVeiParameter(userId, cookies: cookies);
    } catch (e) {
      DebugService.error('❌ 蓝奏云 - 初始化vei参数失败: $e', e);
      return null;
    }
  }
}
