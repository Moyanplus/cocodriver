/// 更新对话框组件
///
/// 显示更新信息、下载进度、安装等UI
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/update_models.dart';
import '../providers/update_provider.dart';

/// 显示更新对话框
Future<void> showUpdateDialog(
  BuildContext context, {
  required UpdateInfo updateInfo,
  bool barrierDismissible = true,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible && !updateInfo.isForceUpdate,
    builder: (context) => UpdateDialog(updateInfo: updateInfo),
  );
}

/// 更新对话框
class UpdateDialog extends ConsumerWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateProvider);

    return PopScope(
      canPop: !updateInfo.isForceUpdate,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: 400.w, maxHeight: 600.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头部
              _buildHeader(context),

              // 内容
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _buildVersionInfo(),
                      SizedBox(height: 16.h),
                      _buildFeatureList(),
                      SizedBox(height: 16.h),
                      _buildFileInfo(),
                    ],
                  ),
                ),
              ),

              // 底部按钮或进度
              _buildBottom(context, ref, updateState),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Row(
        children: [
          Icon(
            updateInfo.isForceUpdate
                ? Icons.warning_rounded
                : Icons.system_update_rounded,
            size: 32.sp,
            color:
                updateInfo.isForceUpdate
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 16.w),
          Expanded(
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
                if (updateInfo.isForceUpdate)
                  Text(
                    '必须更新',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建版本信息
  Widget _buildVersionInfo() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.new_releases_outlined, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            '版本：${updateInfo.version.versionName}',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              updateInfo.fileSizeFormatted,
              style: TextStyle(fontSize: 12.sp, color: Colors.green[700]),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建特性列表
  Widget _buildFeatureList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '更新内容',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        ...updateInfo.features.map(
          (feature) => Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16.sp,
                  color: Colors.green,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(fontSize: 14.sp, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建文件信息
  Widget _buildFileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (updateInfo.description.isNotEmpty) ...[
          Text(
            '更新说明',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            updateInfo.description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  /// 构建底部
  Widget _buildBottom(BuildContext context, WidgetRef ref, UpdateState state) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: switch (state) {
        UpdateStateDownloading(:final progress) => _buildDownloadingProgress(
          context,
          ref,
          progress,
        ),
        UpdateStateDownloadError(:final error) => _buildErrorButtons(
          context,
          ref,
          error,
        ),
        _ => _buildActionButtons(context, ref),
      },
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        if (!updateInfo.isForceUpdate)
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('稍后更新'),
            ),
          ),
        if (!updateInfo.isForceUpdate) SizedBox(width: 12.w),
        Expanded(
          flex: updateInfo.isForceUpdate ? 1 : 0,
          child: FilledButton(
            onPressed: () {
              ref.read(updateProvider.notifier).startDownload(updateInfo);
            },
            child: const Text('立即更新'),
          ),
        ),
      ],
    );
  }

  /// 构建下载进度
  Widget _buildDownloadingProgress(
    BuildContext context,
    WidgetRef ref,
    DownloadProgress progress,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '下载中...',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            Text(
              '${progress.percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        LinearProgressIndicator(
          value: progress.percentage / 100,
          minHeight: 8.h,
          borderRadius: BorderRadius.circular(4.r),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              progress.speedFormatted,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            Text(
              '剩余 ${progress.remainingTimeFormatted}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ],
        ),
        if (!updateInfo.isForceUpdate) ...[
          SizedBox(height: 16.h),
          OutlinedButton(
            onPressed: () {
              ref.read(updateProvider.notifier).cancelDownload();
              Navigator.of(context).pop();
            },
            child: const Text('取消下载'),
          ),
        ],
      ],
    );
  }

  /// 构建错误按钮
  Widget _buildErrorButtons(BuildContext context, WidgetRef ref, String error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          error,
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            if (!updateInfo.isForceUpdate)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
              ),
            if (!updateInfo.isForceUpdate) SizedBox(width: 12.w),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  ref.read(updateProvider.notifier).startDownload(updateInfo);
                },
                child: const Text('重试'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
