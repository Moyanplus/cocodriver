/// 更新详情页面
///
/// 显示详细的更新信息和管理更新
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/update_models.dart';
import '../providers/update_provider.dart';

/// 更新详情页面
class UpdateDetailPage extends ConsumerStatefulWidget {
  const UpdateDetailPage({super.key});

  @override
  ConsumerState<UpdateDetailPage> createState() => _UpdateDetailPageState();
}

class _UpdateDetailPageState extends ConsumerState<UpdateDetailPage> {
  @override
  void initState() {
    super.initState();
    // 自动检查更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(updateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('软件更新'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkForUpdate,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'test_force':
                  _testUpdate(forceUpdate: true);
                  break;
                case 'test_recommend':
                  _testUpdate(forceUpdate: false);
                  break;
                case 'test_no_update':
                  _testUpdate(hasUpdate: false);
                  break;
                case 'cleanup':
                  _cleanupDownloads();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'test_force',
                    child: Text('测试强制更新'),
                  ),
                  const PopupMenuItem(
                    value: 'test_recommend',
                    child: Text('测试推荐更新'),
                  ),
                  const PopupMenuItem(
                    value: 'test_no_update',
                    child: Text('测试无更新'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'cleanup', child: Text('清理下载文件')),
                ],
          ),
        ],
      ),
      body: _buildBody(updateState),
    );
  }

  Widget _buildBody(UpdateState state) {
    return switch (state) {
      UpdateStateInitial() => _buildInitialView(),
      UpdateStateChecking() => _buildCheckingView(),
      UpdateStateAvailable(:final updateInfo) => _buildUpdateAvailableView(
        updateInfo,
      ),
      UpdateStateNoUpdate(:final currentVersion) => _buildNoUpdateView(
        currentVersion,
      ),
      UpdateStateDownloading(:final updateInfo, :final progress) =>
        _buildDownloadingView(updateInfo, progress),
      UpdateStateReadyToInstall(:final updateInfo, :final filePath) =>
        _buildReadyToInstallView(updateInfo, filePath),
      UpdateStateInstalling(:final updateInfo) => _buildInstallingView(
        updateInfo,
      ),
      UpdateStateInstalled(:final updateInfo) => _buildInstalledView(
        updateInfo,
      ),
      UpdateStateError(:final message) => _buildErrorView(message),
      UpdateStateDownloadError(:final updateInfo, :final error) =>
        _buildDownloadErrorView(updateInfo, error),
      UpdateStateInstallError(:final updateInfo, :final error) =>
        _buildInstallErrorView(updateInfo, error),
    };
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.system_update, size: 80.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            '点击检查按钮查看是否有新版本',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
          SizedBox(height: 24.h),
          FilledButton.icon(
            onPressed: _checkForUpdate,
            icon: const Icon(Icons.search),
            label: const Text('检查更新'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 16.h),
          Text('正在检查更新...', style: TextStyle(fontSize: 16.sp)),
        ],
      ),
    );
  }

  Widget _buildUpdateAvailableView(UpdateInfo updateInfo) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 更新类型标签
          if (updateInfo.isForceUpdate)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8.w),
                  const Text(
                    '强制更新',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 16.h),

          // 版本信息卡片
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    updateInfo.title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Chip(
                        label: Text(updateInfo.version.versionName),
                        avatar: const Icon(Icons.new_releases, size: 16),
                      ),
                      SizedBox(width: 8.w),
                      Chip(
                        label: Text(updateInfo.fileSizeFormatted),
                        avatar: const Icon(Icons.storage, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // 更新内容
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '更新内容',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...updateInfo.features.map(
                    (feature) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20.sp,
                            color: Colors.green,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // 更新说明
          if (updateInfo.description.isNotEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '更新说明',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      updateInfo.description,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 24.h),

          // 操作按钮
          FilledButton.icon(
            onPressed: () {
              ref.read(updateProvider.notifier).startDownload(updateInfo);
            },
            icon: const Icon(Icons.download),
            label: const Text('立即更新'),
          ),

          if (!updateInfo.isForceUpdate) ...[
            SizedBox(height: 12.h),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('稍后更新'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoUpdateView(VersionInfo currentVersion) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 80.sp, color: Colors.green),
          SizedBox(height: 16.h),
          Text(
            '当前已是最新版本',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            currentVersion.versionName,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadingView(
    UpdateInfo updateInfo,
    DownloadProgress progress,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 120.w,
              height: 120.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120.w,
                    height: 120.w,
                    child: CircularProgressIndicator(
                      value: progress.percentage / 100,
                      strokeWidth: 8,
                    ),
                  ),
                  Text(
                    '${progress.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              '正在下载更新...',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.speed, size: 16.sp, color: Colors.grey),
                SizedBox(width: 8.w),
                Text(
                  progress.speedFormatted,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                SizedBox(width: 24.w),
                Icon(Icons.timer, size: 16.sp, color: Colors.grey),
                SizedBox(width: 8.w),
                Text(
                  '剩余 ${progress.remainingTimeFormatted}',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            if (!updateInfo.isForceUpdate)
              OutlinedButton(
                onPressed: () {
                  ref.read(updateProvider.notifier).cancelDownload();
                },
                child: const Text('取消下载'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyToInstallView(UpdateInfo updateInfo, String filePath) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.install_mobile, size: 80.sp, color: Colors.green),
            SizedBox(height: 16.h),
            Text(
              '下载完成',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              '新版本已准备就绪',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
            SizedBox(height: 32.h),
            FilledButton.icon(
              onPressed: () {
                ref
                    .read(updateProvider.notifier)
                    .installUpdate(filePath, updateInfo);
              },
              icon: const Icon(Icons.upgrade),
              label: const Text('立即安装'),
            ),
            if (!updateInfo.isForceUpdate) ...[
              SizedBox(height: 12.h),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('稍后安装'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstallingView(UpdateInfo updateInfo) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 16.h),
          Text('正在安装...', style: TextStyle(fontSize: 16.sp)),
        ],
      ),
    );
  }

  Widget _buildInstalledView(UpdateInfo updateInfo) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 80.sp, color: Colors.green),
          SizedBox(height: 16.h),
          Text(
            '安装完成',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 80.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              '检查更新失败',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            FilledButton.icon(
              onPressed: _checkForUpdate,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadErrorView(UpdateInfo updateInfo, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 80.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              '下载失败',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            FilledButton.icon(
              onPressed: () {
                ref.read(updateProvider.notifier).startDownload(updateInfo);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重新下载'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallErrorView(UpdateInfo updateInfo, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 80.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              '安装失败',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _checkForUpdate() {
    ref.read(updateProvider.notifier).checkForUpdate(showNoUpdateMessage: true);
  }

  void _testUpdate({bool forceUpdate = false, bool hasUpdate = true}) {
    ref
        .read(updateProvider.notifier)
        .checkForUpdate(
          forceUpdate: forceUpdate,
          hasUpdate: hasUpdate,
          showNoUpdateMessage: true,
        );
  }

  void _cleanupDownloads() {
    ref.read(updateProvider.notifier).cleanupDownloads();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已清理下载文件'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
