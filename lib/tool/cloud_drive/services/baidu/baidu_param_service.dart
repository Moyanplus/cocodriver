import '../../../core/services/base/debug_service.dart';
import '../../models/cloud_drive_models.dart';
import 'baidu_base_service.dart';
import 'baidu_config.dart';

/// 百度网盘参数管理服务
/// 专门负责获取和缓存百度网盘的API参数（bdstoken、sign等）
class BaiduParamService {
  // 缓存参数，避免重复请求
  static final Map<String, Map<String, dynamic>> _paramCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 30); // 缓存30分钟

  /// 获取百度网盘参数（bdstoken等）
  static Future<Map<String, dynamic>> getBaiduParams(
    CloudDriveAccount account,
  ) async {
    final cacheKey = account.id;
    final now = DateTime.now();

    // 检查缓存是否有效
    if (_paramCache.containsKey(cacheKey)) {
      final cacheTime = _cacheTimestamps[cacheKey];
      if (cacheTime != null && now.difference(cacheTime) < _cacheExpiry) {
        DebugService.log(
          '✅ 百度网盘 - 使用缓存的参数: ${_paramCache[cacheKey]}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return _paramCache[cacheKey]!;
      }
    }

    DebugService.log(
      '🔄 百度网盘 - 获取参数',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );

    try {
      // 使用配置中的API端点
      final url = BaiduConfig.getApiUrl(
        BaiduConfig.endpoints['templateVariable']!,
      );
      final queryParams = {
        'fields':
            '["sign1","sign2","sign3","bdstoken","token","uk","isdocuser","servertime","timestamp"]',
        'channel': 'chunlei',
        'clienttype': '0',
        'web': '1',
      };

      DebugService.log(
        '🌐 百度网盘 - 请求参数: $url',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📋 百度网盘 - 查询参数: $queryParams',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      final dio = BaiduBaseService.createDio(account);
      final response = await dio.get(url, queryParameters: queryParams);

      DebugService.log(
        '📡 百度网盘 - 参数请求响应状态码: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📄 百度网盘 - 参数请求响应体: ${response.data}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (response.statusCode != 200) {
        throw Exception('参数请求失败: ${response.statusCode}');
      }

      final data = response.data;
      DebugService.log(
        '📋 百度网盘 - 参数响应数据: $data',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      if (data['errno'] != 0) {
        final errorMsg = BaiduConfig.getErrorMessage(data['errno']);
        throw Exception('参数获取失败: $errorMsg');
      }

      final result = data['result'] as Map<String, dynamic>?;
      if (result == null) {
        throw Exception('参数响应格式错误');
      }

      // 缓存参数
      _paramCache[cacheKey] = result;
      _cacheTimestamps[cacheKey] = now;

      DebugService.log(
        '✅ 百度网盘 - 参数获取成功: $result',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      return result;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 百度网盘 - 获取参数失败: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📄 百度网盘 - 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      rethrow;
    }
  }

  /// 获取bdstoken
  static Future<String> getBdstoken(CloudDriveAccount account) async {
    final params = await getBaiduParams(account);
    return params['bdstoken']?.toString() ?? '';
  }

  /// 获取sign参数
  static Future<String> getSign(CloudDriveAccount account) async {
    final params = await getBaiduParams(account);
    return params['sign1']?.toString() ?? '';
  }

  /// 获取uk参数
  static Future<String> getUk(CloudDriveAccount account) async {
    final params = await getBaiduParams(account);
    return params['uk']?.toString() ?? '';
  }

  /// 清除缓存
  static void clearCache() {
    _paramCache.clear();
    _cacheTimestamps.clear();
    DebugService.log(
      '🧹 百度网盘 - 参数缓存已清除',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
  }

  /// 清除指定账号的缓存
  static void clearCacheForAccount(String accountId) {
    _paramCache.remove(accountId);
    _cacheTimestamps.remove(accountId);
    DebugService.log(
      '🧹 百度网盘 - 已清除账号 $accountId 的参数缓存',
      category: DebugCategory.tools,
      subCategory: BaiduConfig.logSubCategory,
    );
  }
}
