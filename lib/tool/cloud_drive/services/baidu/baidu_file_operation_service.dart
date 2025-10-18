import 'package:dio/dio.dart';
import '../../../core/services/base/debug_service.dart';
import '../../models/cloud_drive_models.dart';
import 'baidu_base_service.dart';
import 'baidu_config.dart';
import 'baidu_param_service.dart';

/// 百度网盘文件操作服务
/// 专门处理文件重命名、移动、复制、删除等操作
class BaiduFileOperationService {
  /// 重命名文件
  static Future<bool> renameFile({
    required CloudDriveAccount account,
    required String filePath,
    required String newFileName,
  }) async {
    try {
      DebugService.log(
        '✏️ 百度网盘 - 开始重命名文件',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📋 百度网盘 - 请求参数: filePath=$filePath, newFileName=$newFileName',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      // 验证账号登录状态
      if (!account.isLoggedIn) {
        DebugService.log(
          '❌ 百度网盘 - 账号未登录，请先登录',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return false;
      }

      // 获取百度网盘参数（包括bdstoken）
      final baiduParams = await BaiduParamService.getBaiduParams(account);
      final bdstoken = baiduParams['bdstoken']?.toString();

      if (bdstoken == null) {
        DebugService.log(
          '❌ 百度网盘 - 无法获取bdstoken',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return false;
      }

      // 构建URL查询参数
      final urlParams = BaiduConfig.buildFileManagerUrlParams(
        operation: 'rename',
        bdstoken: bdstoken,
      );

      // 构建请求体（表单数据格式）
      final requestBodyMap = BaiduConfig.buildFileManagerBody(
        operation: 'rename',
        fileList: [filePath],
        newName: newFileName,
      );

      // 将Map转换为FormData以确保正确的表单编码
      final formData = FormData.fromMap(requestBodyMap);

      final baseUrl = BaiduConfig.getApiUrl(
        BaiduConfig.endpoints['fileManager']!,
      );
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: urlParams.map((k, v) => MapEntry(k, v.toString())),
      );

      DebugService.log(
        '🌐 百度网盘 - 请求URL: $uri',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📤 百度网盘 - 请求体: ${requestBodyMap.entries.map((e) => '${e.key}=${e.value}').join('&')}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      // 发送请求
      final dio = BaiduBaseService.createDio(account);
      final response = await dio.postUri(uri, data: formData);

      DebugService.log(
        '📡 百度网盘 - 响应状态: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      final responseData = response.data as Map<String, dynamic>;

      // 处理API响应
      final processedResponse = BaiduBaseService.handleApiResponse(
        responseData,
      );

      if (processedResponse['errno'] == 0) {
        DebugService.log(
          '✅ 百度网盘 - 文件重命名成功: $filePath -> $newFileName',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return true;
      } else {
        DebugService.log(
          '❌ 百度网盘 - 文件重命名失败: errno=${processedResponse['errno']}, errmsg=${processedResponse['errmsg']}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return false;
      }
    } catch (e) {
      DebugService.log(
        '❌ 百度网盘 - 重命名文件失败: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return false;
    }
  }

  /// 移动文件
  static Future<bool> moveFile({
    required CloudDriveAccount account,
    required String filePath,
    required String targetPath,
  }) async {
    try {
      DebugService.log(
        '🚚 百度网盘 - 开始移动文件',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📋 百度网盘 - 请求参数: filePath=$filePath, targetPath=$targetPath',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      // 验证账号登录状态
      if (!account.isLoggedIn) {
        DebugService.log(
          '❌ 百度网盘 - 账号未登录，请先登录',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return false;
      }

      // 获取百度网盘参数（包括bdstoken）
      final baiduParams = await BaiduParamService.getBaiduParams(account);
      final bdstoken = baiduParams['bdstoken']?.toString();

      if (bdstoken == null) {
        DebugService.log(
          '❌ 百度网盘 - 无法获取bdstoken',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return false;
      }

      // 构建URL查询参数
      final urlParams = BaiduConfig.buildFileManagerUrlParams(
        operation: 'move',
        bdstoken: bdstoken,
      );

      // 构建请求体（表单数据格式）
      final requestBodyMap = BaiduConfig.buildFileManagerBody(
        operation: 'move',
        fileList: [filePath],
        targetPath: targetPath,
      );

      // 将Map转换为FormData以确保正确的表单编码
      final formData = FormData.fromMap(requestBodyMap);

      final baseUrl = BaiduConfig.getApiUrl(
        BaiduConfig.endpoints['fileManager']!,
      );
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: urlParams.map((k, v) => MapEntry(k, v.toString())),
      );

      DebugService.log(
        '🌐 百度网盘 - 请求URL: $uri',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📤 百度网盘 - 请求体: ${requestBodyMap.entries.map((e) => '${e.key}=${e.value}').join('&')}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      // 发送请求
      final dio = BaiduBaseService.createDio(account);
      final response = await dio.postUri(uri, data: formData);

      DebugService.log(
        '📡 百度网盘 - 响应状态: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      final responseData = response.data as Map<String, dynamic>;

      // 处理API响应
      final processedResponse = BaiduBaseService.handleApiResponse(
        responseData,
      );

      if (processedResponse['errno'] == 0) {
        DebugService.log(
          '✅ 百度网盘 - 文件移动成功: $filePath -> $targetPath',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return true;
      } else {
        DebugService.log(
          '❌ 百度网盘 - 文件移动失败: errno=${processedResponse['errno']}, errmsg=${processedResponse['errmsg']}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return false;
      }
    } catch (e) {
      DebugService.log(
        '❌ 百度网盘 - 移动文件失败: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return false;
    }
  }

  /// 复制文件
  static Future<bool> copyFile({
    required CloudDriveAccount account,
    required String filePath,
    required String targetPath,
  }) async {
    try {
      DebugService.log(
        '📋 百度网盘 - 开始复制文件',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📋 百度网盘 - 请求参数: filePath=$filePath, targetPath=$targetPath',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      // 验证账号登录状态
      if (!account.isLoggedIn) {
        DebugService.log(
          '❌ 百度网盘 - 账号未登录，请先登录',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return false;
      }

      // 获取百度网盘参数（包括bdstoken）
      final baiduParams = await BaiduParamService.getBaiduParams(account);
      final bdstoken = baiduParams['bdstoken']?.toString();

      if (bdstoken == null) {
        DebugService.log(
          '❌ 百度网盘 - 无法获取bdstoken',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return false;
      }

      // 构建URL查询参数
      final urlParams = BaiduConfig.buildFileManagerUrlParams(
        operation: 'copy',
        bdstoken: bdstoken,
      );

      // 构建请求体（表单数据格式）
      final requestBodyMap = BaiduConfig.buildFileManagerBody(
        operation: 'copy',
        fileList: [filePath],
        targetPath: targetPath,
      );

      // 将Map转换为FormData以确保正确的表单编码
      final formData = FormData.fromMap(requestBodyMap);

      final baseUrl = BaiduConfig.getApiUrl(
        BaiduConfig.endpoints['fileManager']!,
      );
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: urlParams.map((k, v) => MapEntry(k, v.toString())),
      );

      DebugService.log(
        '🌐 百度网盘 - 请求URL: $uri',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📤 百度网盘 - 请求体: ${requestBodyMap.entries.map((e) => '${e.key}=${e.value}').join('&')}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      // 发送请求
      final dio = BaiduBaseService.createDio(account);
      final response = await dio.postUri(uri, data: formData);

      DebugService.log(
        '📡 百度网盘 - 响应状态: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      final responseData = response.data as Map<String, dynamic>;

      // 处理API响应
      final processedResponse = BaiduBaseService.handleApiResponse(
        responseData,
      );

      if (processedResponse['errno'] == 0) {
        DebugService.log(
          '✅ 百度网盘 - 文件复制成功: $filePath -> $targetPath',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return true;
      } else {
        DebugService.log(
          '❌ 百度网盘 - 文件复制失败: errno=${processedResponse['errno']}, errmsg=${processedResponse['errmsg']}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return false;
      }
    } catch (e) {
      DebugService.log(
        '❌ 百度网盘 - 复制文件失败: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return false;
    }
  }

  /// 删除文件
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required String filePath,
  }) async {
    try {
      DebugService.log(
        '🗑️ 百度网盘 - 开始删除文件',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📋 百度网盘 - 请求参数: filePath=$filePath',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      // 验证账号登录状态
      if (!account.isLoggedIn) {
        DebugService.log(
          '❌ 百度网盘 - 账号未登录，请先登录',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return false;
      }

      // 获取百度网盘参数（包括bdstoken）
      final baiduParams = await BaiduParamService.getBaiduParams(account);
      final bdstoken = baiduParams['bdstoken']?.toString();

      if (bdstoken == null) {
        DebugService.log(
          '❌ 百度网盘 - 无法获取bdstoken',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return false;
      }

      // 构建URL查询参数
      final urlParams = BaiduConfig.buildFileManagerUrlParams(
        operation: 'delete',
        bdstoken: bdstoken,
      );

      // 构建请求体（表单数据格式）
      final requestBodyMap = BaiduConfig.buildFileManagerBody(
        operation: 'delete',
        fileList: [filePath],
      );

      // 将Map转换为FormData以确保正确的表单编码
      final formData = FormData.fromMap(requestBodyMap);

      final baseUrl = BaiduConfig.getApiUrl(
        BaiduConfig.endpoints['fileManager']!,
      );
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: urlParams.map((k, v) => MapEntry(k, v.toString())),
      );

      DebugService.log(
        '🌐 百度网盘 - 请求URL: $uri',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      DebugService.log(
        '📤 百度网盘 - 请求体: ${requestBodyMap.entries.map((e) => '${e.key}=${e.value}').join('&')}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      // 发送请求
      final dio = BaiduBaseService.createDio(account);
      final response = await dio.postUri(uri, data: formData);

      DebugService.log(
        '📡 百度网盘 - 响应状态: ${response.statusCode}',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );

      final responseData = response.data as Map<String, dynamic>;

      // 处理API响应
      final processedResponse = BaiduBaseService.handleApiResponse(
        responseData,
      );

      if (processedResponse['errno'] == 0) {
        DebugService.log(
          '✅ 百度网盘 - 文件删除成功: $filePath',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return true;
      } else {
        DebugService.log(
          '❌ 百度网盘 - 文件删除失败: errno=${processedResponse['errno']}, errmsg=${processedResponse['errmsg']}',
          category: DebugCategory.tools,
          subCategory: BaiduConfig.logSubCategory,
        );
        return false;
      }
    } catch (e) {
      DebugService.log(
        '❌ 百度网盘 - 删除文件失败: $e',
        category: DebugCategory.tools,
        subCategory: BaiduConfig.logSubCategory,
      );
      return false;
    }
  }
}
