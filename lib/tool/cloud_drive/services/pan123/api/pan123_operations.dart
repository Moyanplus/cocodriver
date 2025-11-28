import '../../../../../core/logging/log_manager.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../models/requests/pan123_operation_requests.dart';
import 'pan123_base_service.dart';
import 'pan123_config.dart';

/// 123 云盘文件/下载操作合集
class Pan123Operations {
  static void _log(String message) => LogManager().cloudDrive(message);
  static bool get _detailed => Pan123Config.enableDetailedLog;

  static Future<bool> rename({
    required CloudDriveAccount account,
    required Pan123RenameRequest request,
  }) async {
    try {
      _log('123云盘 - 开始重命名文件: ${request.file.id} -> ${request.newName}');
      if (!account.isLoggedIn) {
        _log('123云盘 - 账号未登录');
        return false;
      }

      final url = Uri.parse(
        Pan123Config.getApiUrl(Pan123Config.endpoints['rename']!),
      );
      final params = request.toApiParams();

      final dio = Pan123BaseService.createDio(account);
      final response = await dio.post(url.toString(), data: params);
      if (_detailed) _log('请求体: $params');
      final processed = Pan123BaseService.handleApiResponse(
        response.data as Map<String, dynamic>,
      );
      if (_detailed) _log('响应体: ${response.data}');
      final ok = processed['code'] == 0;
      _log(ok ? '123云盘 - 文件重命名成功' : '123云盘 - 文件重命名失败');
      return ok;
    } catch (e, s) {
      _log('123云盘 - 重命名文件异常: $e');
      _log('堆栈: $s');
      return false;
    }
  }

  static Future<bool> move({
    required CloudDriveAccount account,
    required Pan123MoveRequest request,
  }) async {
    try {
      _log('123云盘 - 开始移动文件: ${request.file.id} -> ${request.targetParentId}');
      if (!account.isLoggedIn) {
        _log('123云盘 - 账号未登录');
        return false;
      }

      final url = Uri.parse(
        Pan123Config.getApiUrl(Pan123Config.endpoints['move']!),
      );
      final params = request.toApiParams();

      final dio = Pan123BaseService.createDio(account);
      final response = await dio.post(url.toString(), data: params);
      final processed = Pan123BaseService.handleApiResponse(
        response.data as Map<String, dynamic>,
      );
      if (_detailed) _log('响应体: ${response.data}');
      final ok = processed['code'] == 0;
      _log(ok ? '123云盘 - 文件移动成功' : '123云盘 - 文件移动失败');
      return ok;
    } catch (e) {
      _log('123云盘 - 移动文件失败: $e');
      return false;
    }
  }

  static Future<bool> copy({
    required CloudDriveAccount account,
    required Pan123CopyRequest request,
  }) async {
    try {
      _log('123云盘 - 开始复制文件: ${request.file.id} -> ${request.targetParentId}');
      if (!account.isLoggedIn) {
        _log('123云盘 - 账号未登录');
        return false;
      }

      final url = Uri.parse(
        Pan123Config.getApiUrl(Pan123Config.endpoints['copy']!),
      );
      final params = request.toApiParams();

      final dio = Pan123BaseService.createDio(account);
      final response = await dio.post(url.toString(), data: params);
      final processed = Pan123BaseService.handleApiResponse(
        response.data as Map<String, dynamic>,
      );
      if (_detailed) _log('响应体: ${response.data}');
      final ok = processed['code'] == 0;
      _log(ok ? '123云盘 - 文件复制成功' : '123云盘 - 文件复制失败');
      return ok;
    } catch (e) {
      _log('123云盘 - 复制文件失败: $e');
      return false;
    }
  }

  static Future<bool> delete({
    required CloudDriveAccount account,
    required Pan123DeleteRequest request,
  }) async {
    try {
      _log('123云盘 - 删除文件: ${request.file.id} (${request.file.name})');
      if (!account.isLoggedIn) {
        _log('123云盘 - 账号未登录');
        return false;
      }

      final url = Uri.parse(
        Pan123Config.getApiUrl(Pan123Config.endpoints['delete']!),
      );
      final params = request.toApiParams();

      final dio = Pan123BaseService.createDio(account);
      final response = await dio.post(url.toString(), data: params);
      final processed = Pan123BaseService.handleApiResponse(
        response.data as Map<String, dynamic>,
      );
      if (_detailed) _log('响应体: ${response.data}');
      final ok = processed['code'] == 0;
      _log(ok ? '123云盘 - 文件删除成功' : '123云盘 - 文件删除失败');
      return ok;
    } catch (e) {
      _log('123云盘 - 删除文件失败: $e');
      return false;
    }
  }

  static Future<CloudDriveFile?> createFolder({
    required CloudDriveAccount account,
    required Pan123CreateFolderRequest request,
  }) async {
    try {
      _log('123云盘 - 创建文件夹: ${request.name} @ ${request.parentId ?? '0'}');
      if (!account.isLoggedIn) {
        _log('123云盘 - 账号未登录');
        return null;
      }

      final url = Uri.parse(
        Pan123Config.getApiUrl(Pan123Config.endpoints['createFolder']!),
      );
      final params = request.toApiParams();

      final dio = Pan123BaseService.createDio(account);
      final response = await dio.post(url.toString(), data: params);
      final processed = Pan123BaseService.handleApiResponse(
        response.data as Map<String, dynamic>,
      );
      if (_detailed) _log('响应体: ${response.data}');
      if (processed['code'] == 0) {
        final id = processed['data']?['fileId']?.toString();
        return CloudDriveFile(
          id: id ?? '',
          name: request.name,
          isFolder: true,
          folderId: request.parentId ?? '0',
        );
      }
      return null;
    } catch (e) {
      _log('123云盘 - 创建文件夹失败: $e');
      return null;
    }
  }

  static Future<String?> getDownloadUrl({
    required CloudDriveAccount account,
    required Pan123DownloadRequest request,
  }) async {
    try {
      _log('123云盘 - 获取下载链接: ${request.file.name} (${request.file.id})');
      final dio = Pan123BaseService.createDio(account);
      final params = request.toApiParams();

      final url = Uri.parse(
        Pan123Config.getApiUrl(Pan123Config.endpoints['downloadInfo']!),
      );
      final response = await dio.post(url.toString(), data: params);
      final processed = Pan123BaseService.handleApiResponse(
        response.data as Map<String, dynamic>,
      );
      final downloadUrl = processed['data']?['downloadUrl']?.toString();
      if (downloadUrl != null && downloadUrl.isNotEmpty) {
        final preview =
            downloadUrl.length > 100 ? '${downloadUrl.substring(0, 100)}...' : downloadUrl;
        _log('123云盘 - 下载链接获取成功: $preview');
        return downloadUrl;
      }
      _log('123云盘 - 响应中无下载链接');
      return null;
    } catch (e) {
      _log('123云盘 - 获取下载链接失败: $e');
      return null;
    }
  }

  static Future<List<String>?> getHighSpeedDownloadUrls({
    required CloudDriveAccount account,
    required CloudDriveFile file,
    required String shareUrl,
    required String password,
  }) async {
    _log('123云盘 - 暂不支持高速下载');
    return null;
  }
}
