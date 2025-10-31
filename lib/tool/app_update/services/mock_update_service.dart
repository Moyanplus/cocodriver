/// Mock 更新数据服务
///
/// 提供模拟的更新数据用于测试和开发

import '../models/update_models.dart';

/// Mock 更新数据服务
class MockUpdateService {
  /// 模拟网络延迟（毫秒）
  final int networkDelay;

  MockUpdateService({this.networkDelay = 1500});

  /// 获取当前版本信息
  Future<VersionInfo> getCurrentVersion() async {
    await Future.delayed(Duration(milliseconds: networkDelay ~/ 2));

    return const VersionInfo(
      version: '1.0.0',
      versionCode: 1,
      versionName: 'v1.0.0',
      buildNumber: '100',
    );
  }

  /// 检查更新
  ///
  /// [forceUpdate] 是否模拟强制更新
  /// [hasUpdate] 是否有更新
  Future<UpdateInfo?> checkUpdate({
    bool forceUpdate = false,
    bool hasUpdate = true,
  }) async {
    await Future.delayed(Duration(milliseconds: networkDelay));

    if (!hasUpdate) {
      return null;
    }

    return UpdateInfo(
      version: VersionInfo(
        version: '1.2.0',
        versionCode: forceUpdate ? 10 : 3,
        versionName: 'v1.2.0',
        buildNumber: forceUpdate ? '120' : '105',
      ),
      updateType: forceUpdate ? UpdateType.force : UpdateType.recommend,
      title: forceUpdate ? '发现重要更新' : '发现新版本',
      description: forceUpdate ? '本次更新修复了重要安全问题，请立即更新' : '本次更新带来了全新的功能和体验优化',
      features: _getMockFeatures(forceUpdate),
      downloadUrl: _getMockDownloadUrl(),
      fileSize: _getMockFileSize(),
      md5: '5d41402abc4b2a76b9719d911017c592',
      releaseTime: DateTime.now().subtract(const Duration(hours: 2)),
      minSupportedVersion: forceUpdate ? '1.0.0' : null,
      silentDownload: !forceUpdate,
    );
  }

  /// 获取模拟的更新特性列表
  List<String> _getMockFeatures(bool forceUpdate) {
    if (forceUpdate) {
      return ['修复了严重的安全漏洞', '优化了应用稳定性', '提升了数据安全性', '修复了若干已知问题'];
    }

    return [
      '全新的界面设计，更加美观易用',
      '新增多账号切换功能',
      '优化文件上传下载速度，提升30%',
      '支持更多云盘平台接入',
      '修复已知问题，提升稳定性',
      '优化内存占用，应用更流畅',
    ];
  }

  /// 获取模拟的下载地址
  String _getMockDownloadUrl() {
    // 这里使用一个测试APK文件URL
    return 'https://example.com/app-release-v1.2.0.apk';
  }

  /// 获取模拟的文件大小（字节）
  int _getMockFileSize() {
    // 模拟一个 25MB 的APK文件
    return 25 * 1024 * 1024;
  }

  /// 模拟下载文件
  Stream<DownloadProgress> downloadUpdate(String url) async* {
    final totalBytes = _getMockFileSize();
    var downloadedBytes = 0;
    final chunkSize = 512 * 1024; // 每次下载 512KB
    final chunks = (totalBytes / chunkSize).ceil();

    for (var i = 0; i < chunks; i++) {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 200));

      downloadedBytes = ((i + 1) * chunkSize).clamp(0, totalBytes);
      final speed = chunkSize / 0.2; // 速度：字节/秒

      yield DownloadProgress(
        downloadedBytes: downloadedBytes,
        totalBytes: totalBytes,
        speed: speed,
        status:
            downloadedBytes >= totalBytes
                ? DownloadStatus.completed
                : DownloadStatus.downloading,
      );
    }
  }

  /// 模拟验证更新包
  Future<bool> verifyUpdatePackage(String filePath, String? md5) async {
    await Future.delayed(Duration(milliseconds: networkDelay));
    // 模拟验证成功
    return true;
  }

  /// 获取多个测试场景
  static List<UpdateScenario> getTestScenarios() {
    return [
      UpdateScenario(name: '有新版本（推荐更新）', hasUpdate: true, forceUpdate: false),
      UpdateScenario(name: '有新版本（强制更新）', hasUpdate: true, forceUpdate: true),
      UpdateScenario(name: '已是最新版本', hasUpdate: false, forceUpdate: false),
    ];
  }
}

/// 更新场景（用于测试）
class UpdateScenario {
  final String name;
  final bool hasUpdate;
  final bool forceUpdate;

  const UpdateScenario({
    required this.name,
    required this.hasUpdate,
    required this.forceUpdate,
  });
}

