import 'package:dio/dio.dart';
import '../../../../core/logging/log_manager.dart';
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
      LogManager().cloudDrive('✏️ 百度网盘 - 开始重命名文件');
      LogManager().cloudDrive(
        '📋 百度网盘 - 请求参数: filePath=$filePath, newFileName=$newFileName',
      );

      // 验证账号登录状态
      if (!account.isLoggedIn) {
        LogManager().cloudDrive('❌ 百度网盘 - 账号未登录，请先登录');
        return false;
      }

      // 获取百度网盘参数（包括bdstoken）
      final baiduParams = await BaiduParamService.getBaiduParams(account);
      final bdstoken = baiduParams['bdstoken']?.toString();

      if (bdstoken == null) {
        LogManager().cloudDrive('❌ 百度网盘 - 无法获取bdstoken');
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

      LogManager().cloudDrive('🌐 百度网盘 - 请求URL: $uri');
      LogManager().cloudDrive(
        '📤 百度网盘 - 请求体: ${requestBodyMap.entries.map((e) => '${e.key}=${e.value}').join('&')}',
      );

      // 发送请求
      final dio = BaiduBaseService.createDio(account);
      final response = await dio.postUri(uri, data: formData);

      LogManager().cloudDrive('📡 百度网盘 - 响应状态: ${response.statusCode}');

      final responseData = response.data as Map<String, dynamic>;

      // 处理API响应
      final processedResponse = BaiduBaseService.handleApiResponse(
        responseData,
      );

      if (processedResponse['errno'] == 0) {
        LogManager().cloudDrive('✅ 百度网盘 - 文件重命名成功: $filePath -> $newFileName');
        return true;
      } else {
        LogManager().cloudDrive(
          '❌ 百度网盘 - 文件重命名失败: errno=${processedResponse['errno']}, errmsg=${processedResponse['errmsg']}',
        );
        return false;
      }
    } catch (e) {
      LogManager().cloudDrive('❌ 百度网盘 - 重命名文件失败: $e');
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
      LogManager().cloudDrive('🚚 百度网盘 - 开始移动文件');
      LogManager().cloudDrive(
        '📋 百度网盘 - 请求参数: filePath=$filePath, targetPath=$targetPath',
      );

      // 验证账号登录状态
      if (!account.isLoggedIn) {
        LogManager().cloudDrive('❌ 百度网盘 - 账号未登录，请先登录');
        return false;
      }

      // 获取百度网盘参数（包括bdstoken）
      final baiduParams = await BaiduParamService.getBaiduParams(account);
      final bdstoken = baiduParams['bdstoken']?.toString();

      if (bdstoken == null) {
        LogManager().cloudDrive('❌ 百度网盘 - 无法获取bdstoken');
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

      LogManager().cloudDrive('🌐 百度网盘 - 请求URL: $uri');
      LogManager().cloudDrive(
        '📤 百度网盘 - 请求体: ${requestBodyMap.entries.map((e) => '${e.key}=${e.value}').join('&')}',
      );

      // 发送请求
      final dio = BaiduBaseService.createDio(account);
      final response = await dio.postUri(uri, data: formData);

      LogManager().cloudDrive('📡 百度网盘 - 响应状态: ${response.statusCode}');

      final responseData = response.data as Map<String, dynamic>;

      // 处理API响应
      final processedResponse = BaiduBaseService.handleApiResponse(
        responseData,
      );

      if (processedResponse['errno'] == 0) {
        LogManager().cloudDrive('✅ 百度网盘 - 文件移动成功: $filePath -> $targetPath');
        return true;
      } else {
        LogManager().cloudDrive(
          '❌ 百度网盘 - 文件移动失败: errno=${processedResponse['errno']}, errmsg=${processedResponse['errmsg']}',
        );
        return false;
      }
    } catch (e) {
      LogManager().cloudDrive('❌ 百度网盘 - 移动文件失败: $e');
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
      LogManager().cloudDrive('📋 百度网盘 - 开始复制文件');
      LogManager().cloudDrive(
        '📋 百度网盘 - 请求参数: filePath=$filePath, targetPath=$targetPath',
      );

      // 验证账号登录状态
      if (!account.isLoggedIn) {
        LogManager().cloudDrive('❌ 百度网盘 - 账号未登录，请先登录');
        return false;
      }

      // 获取百度网盘参数（包括bdstoken）
      final baiduParams = await BaiduParamService.getBaiduParams(account);
      final bdstoken = baiduParams['bdstoken']?.toString();

      if (bdstoken == null) {
        LogManager().cloudDrive('❌ 百度网盘 - 无法获取bdstoken');
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

      LogManager().cloudDrive('🌐 百度网盘 - 请求URL: $uri');
      LogManager().cloudDrive(
        '📤 百度网盘 - 请求体: ${requestBodyMap.entries.map((e) => '${e.key}=${e.value}').join('&')}',
      );

      // 发送请求
      final dio = BaiduBaseService.createDio(account);
      final response = await dio.postUri(uri, data: formData);

      LogManager().cloudDrive('📡 百度网盘 - 响应状态: ${response.statusCode}');

      final responseData = response.data as Map<String, dynamic>;

      // 处理API响应
      final processedResponse = BaiduBaseService.handleApiResponse(
        responseData,
      );

      if (processedResponse['errno'] == 0) {
        LogManager().cloudDrive('✅ 百度网盘 - 文件复制成功: $filePath -> $targetPath');
        return true;
      } else {
        LogManager().cloudDrive(
          '❌ 百度网盘 - 文件复制失败: errno=${processedResponse['errno']}, errmsg=${processedResponse['errmsg']}',
        );
        return false;
      }
    } catch (e) {
      LogManager().cloudDrive('❌ 百度网盘 - 复制文件失败: $e');
      return false;
    }
  }

  /// 删除文件
  static Future<bool> deleteFile({
    required CloudDriveAccount account,
    required String filePath,
  }) async {
    try {
      LogManager().cloudDrive('🗑️ 百度网盘 - 开始删除文件');
      LogManager().cloudDrive('📋 百度网盘 - 请求参数: filePath=$filePath');

      // 验证账号登录状态
      if (!account.isLoggedIn) {
        LogManager().cloudDrive('❌ 百度网盘 - 账号未登录，请先登录');
        return false;
      }

      // 获取百度网盘参数（包括bdstoken）
      final baiduParams = await BaiduParamService.getBaiduParams(account);
      final bdstoken = baiduParams['bdstoken']?.toString();

      if (bdstoken == null) {
        LogManager().cloudDrive('❌ 百度网盘 - 无法获取bdstoken');
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

      LogManager().cloudDrive('🌐 百度网盘 - 请求URL: $uri');
      LogManager().cloudDrive(
        '📤 百度网盘 - 请求体: ${requestBodyMap.entries.map((e) => '${e.key}=${e.value}').join('&')}',
      );

      // 发送请求
      final dio = BaiduBaseService.createDio(account);
      final response = await dio.postUri(uri, data: formData);

      LogManager().cloudDrive('📡 百度网盘 - 响应状态: ${response.statusCode}');

      final responseData = response.data as Map<String, dynamic>;

      // 处理API响应
      final processedResponse = BaiduBaseService.handleApiResponse(
        responseData,
      );

      if (processedResponse['errno'] == 0) {
        LogManager().cloudDrive('✅ 百度网盘 - 文件删除成功: $filePath');
        return true;
      } else {
        LogManager().cloudDrive(
          '❌ 百度网盘 - 文件删除失败: errno=${processedResponse['errno']}, errmsg=${processedResponse['errmsg']}',
        );
        return false;
      }
    } catch (e) {
      LogManager().cloudDrive('❌ 百度网盘 - 删除文件失败: $e');
      return false;
    }
  }
}
