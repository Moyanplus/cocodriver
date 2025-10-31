/// 更新服务
///
/// 负责检查更新、下载更新、安装更新等功能

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/update_models.dart';
import 'mock_update_service.dart';

/// 更新服务
class UpdateService {
  final MockUpdateService _mockService;
  final Dio _dio;
  CancelToken? _cancelToken;

  UpdateService({MockUpdateService? mockService, Dio? dio})
    : _mockService = mockService ?? MockUpdateService(),
      _dio = dio ?? Dio();

  /// 获取当前应用版本
  Future<VersionInfo> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return VersionInfo(
        version: packageInfo.version,
        versionCode: int.tryParse(packageInfo.buildNumber) ?? 1,
        versionName: 'v${packageInfo.version}',
        buildNumber: packageInfo.buildNumber,
      );
    } catch (e) {
      debugPrint('获取当前版本失败: $e');
      // 如果获取失败，返回 mock 数据
      return _mockService.getCurrentVersion();
    }
  }

  /// 检查更新
  Future<UpdateCheckResult> checkForUpdate({
    bool forceUpdate = false,
    bool hasUpdate = true,
  }) async {
    try {
      final currentVersion = await getCurrentVersion();

      // 这里使用 Mock 数据
      // 实际项目中应该调用真实的API
      final updateInfo = await _mockService.checkUpdate(
        forceUpdate: forceUpdate,
        hasUpdate: hasUpdate,
      );

      if (updateInfo == null) {
        return UpdateCheckResult.success(
          hasUpdate: false,
          currentVersion: currentVersion,
        );
      }

      // 比较版本号
      final hasNewVersion = updateInfo.version.compareTo(currentVersion) > 0;

      return UpdateCheckResult.success(
        hasUpdate: hasNewVersion,
        updateInfo: hasNewVersion ? updateInfo : null,
        currentVersion: currentVersion,
      );
    } catch (e) {
      debugPrint('检查更新失败: $e');
      final currentVersion = await getCurrentVersion();
      return UpdateCheckResult.failure(
        error: '检查更新失败: $e',
        currentVersion: currentVersion,
      );
    }
  }

  /// 下载更新包
  Stream<DownloadProgress> downloadUpdate(UpdateInfo updateInfo) async* {
    try {
      // 获取下载目录
      final downloadDir = await _getDownloadDirectory();
      final fileName = _getFileNameFromUrl(updateInfo.downloadUrl);
      final filePath = '${downloadDir.path}/$fileName';

      // 删除旧文件
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      _cancelToken = CancelToken();
      // 使用真实下载（如果需要）或Mock下载
      if (kDebugMode && updateInfo.downloadUrl.contains('example.com')) {
        // 使用 Mock 下载
        yield* _mockService
            .downloadUpdate(updateInfo.downloadUrl)
            .map((progress) => progress.copyWith(filePath: filePath));
      } else {
        // 真实下载
        await _dio.download(
          updateInfo.downloadUrl,
          filePath,
          cancelToken: _cancelToken,
          onReceiveProgress: (received, total) {
            // 真实下载的进度回调
            // 注意：这里不能直接yield，需要通过Stream控制器
          },
        );

        // 下载完成
        yield DownloadProgress(
          downloadedBytes: updateInfo.fileSize,
          totalBytes: updateInfo.fileSize,
          speed: 0,
          status: DownloadStatus.completed,
          filePath: filePath,
        );
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        yield DownloadProgress.empty.copyWith(
          status: DownloadStatus.cancelled,
          error: '下载已取消',
        );
      } else {
        debugPrint('下载失败: $e');
        yield DownloadProgress.empty.copyWith(
          status: DownloadStatus.failed,
          error: '下载失败: $e',
        );
      }
    }
  }

  /// 取消下载
  void cancelDownload() {
    _cancelToken?.cancel('用户取消下载');
  }

  /// 暂停下载
  Future<void> pauseDownload() async {
    // TODO: 实现断点续传
    cancelDownload();
  }

  /// 继续下载
  Stream<DownloadProgress> resumeDownload(UpdateInfo updateInfo) async* {
    // TODO: 实现断点续传
    yield* downloadUpdate(updateInfo);
  }

  /// 验证更新包
  Future<bool> verifyUpdatePackage(String filePath, String? md5) async {
    try {
      // 检查文件是否存在
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('文件不存在: $filePath');
        return false;
      }

      // 如果提供了 MD5，验证文件完整性
      if (md5 != null && md5.isNotEmpty) {
        // 使用 Mock 验证
        return _mockService.verifyUpdatePackage(filePath, md5);
      }

      return true;
    } catch (e) {
      debugPrint('验证更新包失败: $e');
      return false;
    }
  }

  /// 安装更新包
  Future<bool> installUpdate(String filePath) async {
    try {
      // 验证文件
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('安装文件不存在: $filePath');
        return false;
      }

      // Android 平台安装 APK
      if (Platform.isAndroid) {
        // TODO: 使用 install_plugin 或其他插件安装 APK
        debugPrint('开始安装 APK: $filePath');
        // 这里需要集成安装插件
        return true;
      }

      // iOS 平台不支持直接安装
      if (Platform.isIOS) {
        debugPrint('iOS 不支持应用内安装，请前往 App Store 更新');
        return false;
      }

      return false;
    } catch (e) {
      debugPrint('安装更新失败: $e');
      return false;
    }
  }

  /// 获取下载目录
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Android 使用外部存储
      final dir = await getExternalStorageDirectory();
      return dir ?? await getApplicationDocumentsDirectory();
    } else {
      // iOS 使用应用文档目录
      return getApplicationDocumentsDirectory();
    }
  }

  /// 从URL获取文件名
  String _getFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    var fileName = uri.pathSegments.last;
    if (!fileName.contains('.')) {
      fileName = 'app-update.apk';
    }
    return fileName;
  }

  /// 清理下载文件
  Future<void> cleanupDownloadFiles() async {
    try {
      final downloadDir = await _getDownloadDirectory();
      final dir = Directory(downloadDir.path);

      if (await dir.exists()) {
        await for (final file in dir.list()) {
          if (file is File && file.path.endsWith('.apk')) {
            await file.delete();
            debugPrint('已删除: ${file.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('清理下载文件失败: $e');
    }
  }
}
