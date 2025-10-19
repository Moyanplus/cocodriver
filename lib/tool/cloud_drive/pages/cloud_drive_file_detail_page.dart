import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/logging/log_manager.dart';
import '../base/cloud_drive_file_service.dart';
import '../models/cloud_drive_models.dart';
import '../business/cloud_drive_business_service.dart';

/// 文件详情页面
class CloudDriveFileDetailPage extends StatefulWidget {
  final CloudDriveFile file;
  final CloudDriveAccount account;

  const CloudDriveFileDetailPage({
    super.key,
    required this.file,
    required this.account,
  });

  @override
  State<CloudDriveFileDetailPage> createState() =>
      _CloudDriveFileDetailPageState();
}

class _CloudDriveFileDetailPageState extends State<CloudDriveFileDetailPage> {
  Map<String, dynamic>? _fileDetail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFileDetail();
  }

  Future<void> _loadFileDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      LogManager().cloudDrive('📄 开始加载文件详情: ${widget.file.name}');

      final detail = await CloudDriveFileService.getFileDetail(
        account: widget.account,
        fileId: widget.file.id,
      );

      if (mounted) {
        setState(() {
          _fileDetail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      LogManager().error('❌ 加载文件详情失败: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('文件详情'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      actions: [
        IconButton(
          onPressed: _loadFileDetail,
          icon: const Icon(Icons.refresh),
          tooltip: '刷新',
        ),
      ],
    ),
    body:
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildErrorState()
            : _buildFileDetail(),
  );

  Widget _buildErrorState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64.h,
          color: Theme.of(context).colorScheme.error,
        ),
        SizedBox(height: 16.h),
        Text(
          '加载文件详情失败',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          _error!,
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
        ElevatedButton.icon(
          onPressed: _loadFileDetail,
          icon: const Icon(Icons.refresh),
          label: const Text('重试'),
        ),
      ],
    ),
  );

  Widget _buildFileDetail() => SingleChildScrollView(
    padding: EdgeInsets.all(16.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 显示文件基本信息
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '基本信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildInfoRow('文件名', widget.file.name),
                _buildInfoRow('文件大小', widget.file.size?.toString() ?? '未知'),
                _buildInfoRow(
                  '修改时间',
                  widget.file.modifiedTime?.toString() ?? '未知',
                ),
                _buildInfoRow('文件类型', widget.file.isFolder ? '文件夹' : '文件'),
              ],
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // 文件详情信息
        if (_fileDetail != null) ...[
          _buildDetailInfo(),
          SizedBox(height: 24.h),
        ],

        // 操作按钮
        _buildActionButtons(),
      ],
    ),
  );

  Widget _buildDetailInfo() => Card(
    child: Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '详细信息',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          ..._fileDetail!.entries.map(
            (entry) => _buildInfoRow(entry.key, entry.value.toString()),
          ),
        ],
      ),
    ),
  );

  Widget _buildInfoRow(String label, String value) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildActionButtons() => Column(
    children: [
      // 主要操作按钮
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _downloadFile,
          icon:
              _isLoading
                  ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.download),
          label: Text(
            _isLoading ? '正在下载...' : '下载文件',
            style: TextStyle(fontSize: 16.sp),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            textStyle: TextStyle(fontSize: 16.sp),
          ),
        ),
      ),
      SizedBox(height: 16.h),

      // 次要操作按钮
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _copyPassword,
              icon: const Icon(Icons.share),
              label: Text('复制提取码', style: TextStyle(fontSize: 14.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _copyDownloadLink,
              icon: const Icon(Icons.copy),
              label: Text('复制下载链接', style: TextStyle(fontSize: 14.sp)),
            ),
          ),
        ],
      ),
      SizedBox(height: 12.h),
    ],
  );

  void _copyPassword() {
    final password = _fileDetail!['pwd'];
    if (password != null) {
      Clipboard.setData(ClipboardData(text: password));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('提取码已复制: $password'),
          backgroundColor: Colors.green,
        ),
      );
      LogManager().cloudDrive('📋 提取码已复制: $password');
    }
  }

  void _copyDownloadLink() {
    final downloadLink = _fileDetail!['is_newd'];
    if (downloadLink != null) {
      Clipboard.setData(ClipboardData(text: downloadLink));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('下载链接已复制'), backgroundColor: Colors.green),
      );
      LogManager().cloudDrive('📋 下载链接已复制: $downloadLink');
    }
  }

  /// 下载文件
  void _downloadFile() async {
    if (_fileDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('文件详情未加载完成'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                SizedBox(width: 16.w),
                const Text('正在解析直链并下载...'),
              ],
            ),
          ),
    );

    try {
      // 使用业务服务处理下载
      final result = await CloudDriveBusinessService.getFileDetailAndDownload(
        account: widget.account,
        fileId: widget.file.id,
      );

      // 关闭加载对话框
      Navigator.of(context).pop();

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('下载任务已创建: ${result.fileName}'),
            backgroundColor: Colors.green,
          ),
        );
        LogManager().cloudDrive('✅ 下载任务创建成功: ${result.taskId}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('下载失败: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 关闭加载对话框
      Navigator.of(context).pop();

      LogManager().error('❌ 下载失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('下载失败: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _parseDirectLink() async {
    if (_fileDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('文件详情未加载完成'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                SizedBox(width: 16.w),
                const Text('正在解析直链...'),
              ],
            ),
          ),
    );

    try {
      // 构建分享链接
      final downloadLink = _fileDetail!['is_newd'];
      final password = _fileDetail!['pwd'];
      final fileId = _fileDetail!['f_id'];

      String fullShareUrl = downloadLink;
      if (fileId != null && fileId.isNotEmpty) {
        if (!downloadLink.contains(fileId)) {
          fullShareUrl = '$downloadLink/$fileId';
        }
      }

      // 使用业务服务解析直链
      final result = await CloudDriveBusinessService.parseAndDownloadFile(
        shareUrl: fullShareUrl,
        password: password,
      );

      // 关闭加载对话框
      Navigator.of(context).pop();

      if (result.success && result.fileInfo != null) {
        _showDirectLinkResult(result.fileInfo!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('解析直链失败: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 关闭加载对话框
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('解析直链失败: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showDirectLinkResult(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('直链解析成功'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('文件名: ${result['name']}'),
                Text('文件大小: ${result['size']}'),
                SizedBox(height: 8.h),
                const Text(
                  '直链地址:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  child: SelectableText(
                    result['directLink'],
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: result['directLink']));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('直链已复制到剪贴板'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('复制直链'),
              ),
            ],
          ),
    );
  }
}
