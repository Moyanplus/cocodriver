import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/services/base/debug_service.dart';
import '../../../features/download/services/download_service.dart';
import '../../../features/download/services/download_config_service.dart';
import '../models/cloud_drive_models.dart';
import '../base/cloud_drive_operation_service.dart';
import '../services/quark/quark_auth_service.dart';
import '../services/quark/quark_operation_strategy.dart';
import 'cloud_drive_file_detail_page.dart';
import '../providers/cloud_drive_provider.dart';

/// 云盘操作选项组件
class CloudDriveOperationOptions extends ConsumerStatefulWidget {
  final CloudDriveFile file;
  final CloudDriveAccount account;
  final VoidCallback? onClose;
  final Function(String message, bool isSuccess)?
  onOperationResult; // 新增：操作结果回调

  const CloudDriveOperationOptions({
    super.key,
    required this.file,
    required this.account,
    this.onClose,
    this.onOperationResult, // 新增
  });

  @override
  ConsumerState<CloudDriveOperationOptions> createState() =>
      _CloudDriveOperationOptionsState();
}

class _CloudDriveOperationOptionsState
    extends ConsumerState<CloudDriveOperationOptions> {
  String? _sharePassword;
  int _expireDays = 1;
  bool _isLoading = false;
  String _loadingMessage = '';
  BuildContext? _savedContext; // 新增：保存有效的context引用

  @override
  void initState() {
    super.initState();
    // 保存初始context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _savedContext = context;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DebugService.log('🎨 操作选项组件 - 构建开始');
    DebugService.log(
      '📄 文件: ${widget.file.name} (${widget.file.isFolder ? '文件夹' : '文件'})',
    );
    DebugService.log(
      '👤 账号: ${widget.account.name} (${widget.account.type.displayName})',
    );

    final uiConfig = CloudDriveOperationService.getUIConfig(widget.account);
    final supportedOps =
        CloudDriveOperationService.getStrategy(
          widget.account.type,
        ).getSupportedOperations();

    DebugService.log('🔧 支持的操作: $supportedOps');
    DebugService.log('🎨 UI配置: ${uiConfig.keys}');

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 文件信息
          _buildFileInfo(),
          Divider(),

          // 操作选项 - 使用Flexible包装以支持滚动
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildOperationOptions(supportedOps, uiConfig),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileInfo() {
    final supportedOps =
        CloudDriveOperationService.getStrategy(
          widget.account.type,
        ).getSupportedOperations();

    return ListTile(
      leading: Icon(
        widget.file.isFolder ? Icons.folder : Icons.insert_drive_file,
        color: widget.file.isFolder ? Colors.orange : Colors.blue,
      ),
      title: Text(
        widget.file.name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        widget.file.isFolder ? '文件夹' : _buildFileInfoText(widget.file),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      onTap: supportedOps['rename'] == true ? _renameFile : null,
    );
  }

  String _buildFileInfoText(CloudDriveFile file) {
    final parts = <String>[];

    // 添加大小信息（如果有）
    if (file.size != null && file.size! > 0) {
      parts.add(file.size!.toString());
    }

    // 添加时间信息（如果有）
    if (file.modifiedTime != null) {
      parts.add(file.modifiedTime!.toString());
    }

    // 如果没有任何信息，返回默认文本
    if (parts.isEmpty) {
      return '未知信息';
    }

    // 用 • 连接多个信息
    return parts.join(' • ');
  }

  List<Widget> _buildOperationOptions(
    Map<String, bool> supportedOps,
    Map<String, dynamic> uiConfig,
  ) {
    final options = <Widget>[];

    // 添加调试日志
    DebugService.log(
      '🔧 构建操作选项 - 支持的操作: $supportedOps',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.operationOptions',
    );

    // 文件详情
    options.add(
      _buildOperationTile(
        icon: Icons.info_outline,
        title: '文件详情',
        onTap: _showFileDetail,
      ),
    );

    // 下载文件（如果支持且是文件）
    if (supportedOps['download'] == true && !widget.file.isFolder) {
      options.add(
        _buildOperationTile(
          icon: Icons.download_rounded,
          title: '下载文件',
          onTap: _downloadFile,
        ),
      );

      // 添加高速下载选项（仅百度网盘支持）
      if (widget.account.type == CloudDriveType.baidu) {
        options.add(
          _buildOperationTile(
            icon: Icons.speed_rounded,
            title: '高速下载',
            onTap: _highSpeedDownload,
          ),
        );
      }
    }

    // 分享文件（如果支持）
    if (supportedOps['share'] == true) {
      options.add(
        _buildOperationTile(
          icon: Icons.share_rounded,
          title: '分享文件',
          onTap: _shareFile,
        ),
      );
    }

    // 复制文件
    if (supportedOps['copy'] == true) {
      options.add(
        _buildOperationTile(
          icon: Icons.copy_rounded,
          title: '复制文件',
          onTap: _copyFile,
        ),
      );
    }

    // 移动文件
    if (supportedOps['move'] == true) {
      options.add(
        _buildOperationTile(
          icon: Icons.drive_file_move_rounded,
          title: '移动文件',
          onTap: _moveFile,
        ),
      );
    }

    // 删除文件
    if (supportedOps['delete'] == true) {
      DebugService.log(
        '✅ 删除选项已启用，添加删除操作',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.operationOptions',
      );
      options.add(
        _buildOperationTile(
          icon: Icons.delete_rounded,
          title: '删除文件',
          onTap: _deleteFile,
          isDestructive: true,
        ),
      );
    } else {
      DebugService.log(
        '❌ 删除选项未启用: supportedOps[delete] = ${supportedOps['delete']}',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.operationOptions',
      );
    }

    return options;
  }

  Widget _buildOperationTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) => ListTile(
    leading: Icon(
      icon,
      color:
          isDestructive
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface,
      size: 24.sp,
    ),
    title: Text(
      title,
      style: TextStyle(
        color:
            isDestructive
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurface,
        fontSize: 14.sp,
      ),
    ),
    onTap: onTap,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
    minLeadingWidth: 40.w,
  );

  void _showFileDetail() {
    Navigator.pop(context); // 关闭操作选项对话框

    // 跳转到文件详情页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CloudDriveFileDetailPage(
              file: widget.file,
              account: widget.account,
            ),
      ),
    );
  }

  Future<void> _downloadFile() async {
    DebugService.log('🔗 操作选项 - 开始下载文件');
    DebugService.log('📄 文件: ${widget.file.name}');
    DebugService.log('👤 账号: ${widget.account.name}');

    setState(() => _isLoading = true);

    try {
      final downloadUrl = await CloudDriveOperationService.getDownloadUrl(
        account: widget.account,
        file: widget.file,
      );

      if (downloadUrl != null) {
        DebugService.log('✅ 操作选项 - 下载链接获取成功: $downloadUrl');

        // 获取下载配置
        final downloadConfig = await DownloadConfigService().loadConfig();
        final downloadService = DownloadService();

        // 构建认证头 - 特别处理不同云盘类型
        final Map<String, String> authHeaders = {};
        if (widget.account.type == CloudDriveType.quark) {
          // 使用夸克认证服务获取最新的完整cookie
          try {
            final headers = await QuarkAuthService.buildAuthHeaders(
              widget.account,
            );
            if (headers['Cookie'] != null) {
              authHeaders['Cookie'] = headers['Cookie']!;
              DebugService.log(
                '🍪 夸克云盘 - 下载任务使用刷新后的完整cookie: ${headers['Cookie']!.length}字符',
              );
            }
          } catch (e) {
            DebugService.log('⚠️ 夸克认证服务调用失败，使用原始cookie: $e');
            authHeaders['Cookie'] = widget.account.cookies ?? '';
          }
        } else if (widget.account.type == CloudDriveType.ali) {
          // 阿里云盘使用Authorization Bearer Token认证
          if (widget.account.authorizationToken != null &&
              widget.account.authorizationToken!.isNotEmpty) {
            authHeaders['Authorization'] =
                'Bearer ${widget.account.authorizationToken}';
            DebugService.log(
              '🔑 阿里云盘 - 下载任务使用Authorization认证: ${widget.account.authorizationToken!.length}字符',
            );
          } else {
            DebugService.log('⚠️ 阿里云盘 - 账号缺少Authorization Token');
          }
        } else {
          // 其他云盘使用Cookie认证
          authHeaders['Cookie'] = widget.account.cookies ?? '';
        }

        // 创建下载任务
        final taskId = await downloadService.createDownloadTask(
          url: downloadUrl,
          fileName: widget.file.name,
          downloadDir: downloadConfig.downloadDirectory,
          showNotification: downloadConfig.showNotification,
          openFileFromNotification: downloadConfig.openFileFromNotification,
          isExternalStorage: downloadConfig.downloadDirectory.startsWith(
            '/storage/emulated/0/',
          ),
          customHeaders: {
            'User-Agent': 'netdisk;PC',
            ...authHeaders,
            ...downloadConfig.customHeaders,
          },
        );

        if (taskId != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('下载任务已创建: ${widget.file.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
          DebugService.log('✅ 下载任务创建成功: $taskId');
        } else {
          throw Exception('创建下载任务失败');
        }
      } else {
        DebugService.log('❌ 操作选项 - 下载链接获取失败');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('获取下载链接失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      DebugService.error('❌ 操作选项 - 下载文件异常', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('下载失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  /// 高速下载 - 使用第三方解析服务
  Future<void> _highSpeedDownload() async {
    DebugService.log('🚀 操作选项 - 开始高速下载');
    DebugService.log('📄 文件: ${widget.file.name}');
    DebugService.log('👤 账号: ${widget.account.name}');

    setState(() => _isLoading = true);

    try {
      // 第一步：自动生成分享链接
      DebugService.log('🔗 自动生成分享链接');
      final shareLink = await CloudDriveOperationService.createShareLink(
        account: widget.account,
        files: [widget.file],
        password: '0000', // 使用默认提取码
        expireDays: 1, // 1天有效期
      );

      if (shareLink == null) {
        throw Exception('生成分享链接失败');
      }

      DebugService.log('✅ 分享链接生成成功: $shareLink');

      // 第二步：使用分享链接进行高速下载
      final downloadUrls =
          await CloudDriveOperationService.getHighSpeedDownloadUrls(
            account: widget.account,
            file: widget.file,
            shareUrl: shareLink,
            password: '0000', // 使用默认提取码
          );

      if (downloadUrls != null && downloadUrls.isNotEmpty) {
        DebugService.log('✅ 操作选项 - 高速下载链接获取成功，共 ${downloadUrls.length} 个链接');

        // 显示下载链接选择对话框
        if (mounted) {
          _showDownloadUrlSelectionDialog(downloadUrls);
        }
      } else {
        DebugService.log('❌ 操作选项 - 高速下载链接获取失败');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('获取高速下载链接失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      DebugService.error('❌ 操作选项 - 高速下载异常', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('高速下载失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 显示下载链接选择对话框
  void _showDownloadUrlSelectionDialog(List<String> downloadUrls) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              '选择下载链接',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18.sp,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: downloadUrls.length,
                itemBuilder: (context, index) {
                  final url = downloadUrls[index];
                  return ListTile(
                    title: Text(
                      '链接 ${index + 1}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      url.length > 50 ? '${url.substring(0, 50)}...' : url,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.copy,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: url));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('链接已复制'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.download,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () => _downloadWithUrl(url),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text('关闭', style: TextStyle(fontSize: 14.sp)),
              ),
            ],
          ),
    );
  }

  /// 使用指定链接下载文件
  Future<void> _downloadWithUrl(String downloadUrl) async {
    try {
      // 获取下载配置
      final downloadConfig = await DownloadConfigService().loadConfig();
      final downloadService = DownloadService();

      // 构建认证头 - 特别处理不同云盘类型
      final Map<String, String> authHeaders = {};
      if (widget.account.type == CloudDriveType.quark) {
        // 使用夸克认证服务获取最新的完整cookie
        try {
          final headers = await QuarkAuthService.buildAuthHeaders(
            widget.account,
          );
          if (headers['Cookie'] != null) {
            authHeaders['Cookie'] = headers['Cookie']!;
            DebugService.log(
              '🍪 夸克云盘 - 高速下载任务使用刷新后的完整cookie: ${headers['Cookie']!.length}字符',
            );
          }
        } catch (e) {
          DebugService.log('⚠️ 夸克认证服务调用失败，使用原始cookie: $e');
          authHeaders['Cookie'] = widget.account.cookies ?? '';
        }
      } else if (widget.account.type == CloudDriveType.ali) {
        // 阿里云盘使用Authorization Bearer Token认证
        if (widget.account.authorizationToken != null &&
            widget.account.authorizationToken!.isNotEmpty) {
          authHeaders['Authorization'] =
              'Bearer ${widget.account.authorizationToken}';
          DebugService.log(
            '🔑 阿里云盘 - 高速下载任务使用Authorization认证: ${widget.account.authorizationToken!.length}字符',
          );
        } else {
          DebugService.log('⚠️ 阿里云盘 - 账号缺少Authorization Token');
        }
      } else {
        // 其他云盘使用Cookie认证
        authHeaders['Cookie'] = widget.account.cookies ?? '';
      }

      // 创建下载任务
      final taskId = await downloadService.createDownloadTask(
        url: downloadUrl,
        fileName: widget.file.name,
        downloadDir: downloadConfig.downloadDirectory,
        showNotification: downloadConfig.showNotification,
        openFileFromNotification: downloadConfig.openFileFromNotification,
        isExternalStorage: downloadConfig.downloadDirectory.startsWith(
          '/storage/emulated/0/',
        ),
        customHeaders: {
          'User-Agent': 'netdisk;PC',
          ...authHeaders,
          ...downloadConfig.customHeaders,
        },
      );

      if (taskId != null) {
        Navigator.pop(context); // 关闭选择对话框
        Navigator.pop(context); // 关闭操作选项对话框

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('高速下载任务已创建: ${widget.file.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
        DebugService.log('✅ 高速下载任务创建成功: $taskId');
      } else {
        throw Exception('创建高速下载任务失败');
      }
    } catch (e) {
      DebugService.error('❌ 高速下载任务创建失败', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('高速下载失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 分享文件
  Future<void> _shareFile() async {
    DebugService.log('🔗 开始分享文件: ${widget.file.name}');

    // 显示分享对话框
    final result = await _showShareDialog();
    if (result == null) return;

    final title = result['title'] as String?;
    final passcode = result['passcode'] as String?;
    final expiredType = result['expiredType'] as int;

    try {
      setState(() {
        _isLoading = true;
        _loadingMessage = '正在创建分享链接...';
      });

      // 根据云盘类型调用相应的分享方法
      Map<String, dynamic>? shareResult;

      switch (widget.account.type) {
        case CloudDriveType.quark:
          final strategy = QuarkCloudDriveOperationStrategy();
          final shareUrl = await strategy.createShareLink(
            account: widget.account,
            files: [widget.file],
            password: passcode,
            expireDays: expiredType,
          );
          if (shareUrl != null) {
            shareResult = {
              'success': true,
              'share_url': shareUrl,
              'passcode': passcode,
            };
          } else {
            shareResult = {'success': false};
          }
          break;
        case CloudDriveType.baidu:
          // TODO: 实现百度网盘分享
          break;
        case CloudDriveType.pan123:
          // TODO: 实现123云盘分享
          break;
        case CloudDriveType.ali:
          // TODO: 实现阿里云盘分享
          break;
        case CloudDriveType.lanzou:
          // TODO: 实现蓝奏云分享
          break;
      }

      if (shareResult != null && shareResult['success'] == true) {
        final shareUrl = shareResult['share_url'] as String;
        final sharePasscode = shareResult['passcode'] as String?;

        // 显示分享结果
        await _showShareResult(shareUrl, sharePasscode);

        widget.onOperationResult?.call('分享链接创建成功', true);
      } else {
        widget.onOperationResult?.call('分享链接创建失败', false);
      }
    } catch (e) {
      DebugService.error('❌ 分享文件失败: $e', null);
      widget.onOperationResult?.call('分享文件失败: $e', false);
    } finally {
      setState(() {
        _isLoading = false;
        _loadingMessage = '';
      });
    }
  }

  /// 显示分享对话框
  Future<Map<String, dynamic>?> _showShareDialog() async {
    String? title;
    String? passcode;
    int expiredType = 1; // 默认永久

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('创建分享链接'),
            content: StatefulBuilder(
              builder:
                  (context, setState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 分享标题
                      TextField(
                        decoration: const InputDecoration(
                          labelText: '分享标题',
                          hintText: '请输入分享标题（可选）',
                        ),
                        onChanged:
                            (value) => title = value.isEmpty ? null : value,
                      ),
                      const SizedBox(height: 16),

                      // 提取码
                      TextField(
                        decoration: const InputDecoration(
                          labelText: '提取码',
                          hintText: '请输入提取码（可选，不填则无密码）',
                        ),
                        onChanged:
                            (value) => passcode = value.isEmpty ? null : value,
                      ),
                      const SizedBox(height: 16),

                      // 过期时间
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: '过期时间'),
                        value: expiredType,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('永久有效')),
                          DropdownMenuItem(value: 2, child: Text('1天')),
                          DropdownMenuItem(value: 3, child: Text('7天')),
                          DropdownMenuItem(value: 4, child: Text('30天')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => expiredType = value);
                          }
                        },
                      ),
                    ],
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).pop({
                      'title': title,
                      'passcode': passcode,
                      'expiredType': expiredType,
                    }),
                child: const Text('创建'),
              ),
            ],
          ),
    );
  }

  /// 显示分享结果
  Future<void> _showShareResult(String shareUrl, String? passcode) async =>
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('分享链接创建成功'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('分享链接：'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SelectableText(shareUrl),
                  ),
                  if (passcode != null) ...[
                    const SizedBox(height: 16),
                    const Text('提取码：'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SelectableText(passcode),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('关闭'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: shareUrl));
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('链接已复制到剪贴板')));
                    Navigator.of(context).pop();
                  },
                  child: const Text('复制链接'),
                ),
              ],
            ),
      );

  Future<void> _copyFile() async {
    DebugService.log('🔗 操作选项 - 开始复制文件');
    DebugService.log('📄 文件: ${widget.file.name}');
    DebugService.log('👤 账号: ${widget.account.name}');

    // 设置待操作文件，显示悬浮按钮
    ref
        .read(cloudDriveProvider.notifier)
        .setPendingOperation(widget.file, 'copy');

    // 关闭操作选项对话框
    Navigator.pop(context);

    // 显示提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已选择复制: ${widget.file.name}，请进入目标目录点击悬浮按钮'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _renameFile() {
    final controller = TextEditingController(text: widget.file.name);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              '重命名文件',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18.sp,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: '新名称',
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14.sp,
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14.sp,
                  ),
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final newName = controller.text.trim();
                  if (newName.isNotEmpty && newName != widget.file.name) {
                    Navigator.pop(context);
                    _executeRenameOperation(newName);
                  }
                },
                child: Text('确定', style: TextStyle(fontSize: 14.sp)),
              ),
            ],
          ),
    );
  }

  /// 异步执行重命名操作
  Future<void> _executeRenameOperation(String newName) async {
    // 在操作开始前保存文件信息和ref引用，避免后续访问已销毁的widget
    final fileId = widget.file.id;
    final oldName = widget.file.name;
    final notifier = ref.read(cloudDriveProvider.notifier);

    try {
      final success = await CloudDriveOperationService.renameFile(
        account: widget.account,
        file: widget.file,
        newName: newName,
      );

      if (success) {
        DebugService.log('✅ 操作选项 - 文件重命名成功');

        // 使用保存的notifier引用更新状态
        try {
          notifier.updateFileInState(fileId, newName);
          DebugService.log('✅ 状态更新成功');
        } catch (e) {
          DebugService.error('❌ 状态更新失败', e);
        }

        // 重命名成功后关闭底部弹窗
        Navigator.pop(context);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('文件重命名成功: $oldName → $newName'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        DebugService.log('❌ 操作选项 - 文件重命名失败');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('文件重命名失败: $oldName'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      DebugService.error('❌ 操作选项 - 重命名文件异常', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('重命名失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _moveFile() async {
    DebugService.log('🔗 操作选项 - 开始移动文件');
    DebugService.log('📄 文件: ${widget.file.name}');
    DebugService.log('👤 账号: ${widget.account.name}');

    // 设置待操作文件，显示悬浮按钮
    ref
        .read(cloudDriveProvider.notifier)
        .setPendingOperation(widget.file, 'move');

    // 关闭操作选项对话框
    Navigator.pop(context);

    // 显示提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已选择移动: ${widget.file.name}，请进入目标目录点击悬浮按钮'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 异步执行移动操作
  Future<void> _executeMoveOperation() async {
    // 在操作开始前保存文件信息和ref引用，避免后续访问已销毁的widget
    final fileId = widget.file.id;
    final fileName = widget.file.name;
    final isFolder = widget.file.isFolder;
    final notifier = ref.read(cloudDriveProvider.notifier);

    try {
      final success = await CloudDriveOperationService.moveFile(
        account: widget.account,
        file: widget.file,
      );

      if (success) {
        DebugService.log('✅ 操作选项 - 文件移动成功');

        // 使用保存的notifier引用更新状态
        try {
          if (isFolder) {
            notifier.removeFolderFromState(fileId);
          } else {
            notifier.removeFileFromState(fileId);
          }
          DebugService.log('✅ 状态更新成功');
        } catch (e) {
          DebugService.error('❌ 状态更新失败', e);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('文件移动成功: $fileName'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        DebugService.log('❌ 操作选项 - 文件移动失败');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('文件移动失败: $fileName'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      DebugService.error('❌ 操作选项 - 移动文件异常', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('移动失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteFile() async {
    DebugService.log('🔗 操作选项 - 开始删除文件');
    DebugService.log('📄 文件: ${widget.file.name}');
    DebugService.log('👤 账号: ${widget.account.name}');

    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              '确认删除',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              '确定要删除 "${widget.file.name}" 吗？\n\n此操作不可撤销！',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('删除'),
              ),
            ],
          ),
    );

    if (confirmed != true) {
      DebugService.log('❌ 用户取消删除操作');
      return;
    }

    // 先关闭操作选项对话框
    Navigator.pop(context);

    // 异步执行删除操作
    _executeDeleteOperation();
  }

  /// 异步执行删除操作
  Future<void> _executeDeleteOperation() async {
    // 在操作开始前保存文件信息和ref引用，避免后续访问已销毁的widget
    final fileId = widget.file.id;
    final fileName = widget.file.name;
    final notifier = ref.read(cloudDriveProvider.notifier);

    try {
      final success = await CloudDriveOperationService.deleteFile(
        account: widget.account,
        file: widget.file,
      );

      DebugService.log('🔍 删除操作完成，结果: $success');
      DebugService.log('🔍 mounted状态: $mounted');

      if (success) {
        DebugService.log('✅ 操作选项 - 文件删除成功');
        final message = '文件删除成功: $fileName';

        // 使用保存的notifier引用更新状态
        try {
          notifier.removeFileFromState(fileId);
          DebugService.log('✅ 状态更新成功');
        } catch (e) {
          DebugService.error('❌ 状态更新失败', e);
        }

        // 使用回调函数显示结果
        if (widget.onOperationResult != null) {
          widget.onOperationResult!(message, true);
        } else if (_savedContext != null) {
          // 使用保存的context显示SnackBar
          DebugService.log('🔍 使用保存的context显示成功SnackBar');
          try {
            final scaffoldMessenger = ScaffoldMessenger.of(_savedContext!);
            if (scaffoldMessenger.mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
              DebugService.log('🔍 成功SnackBar已显示');
            } else {
              DebugService.log('❌ ScaffoldMessenger未挂载');
            }
          } catch (e) {
            DebugService.error('❌ 显示SnackBar失败', e);
          }
        } else {
          DebugService.log('❌ 没有可用的context');
        }
      } else {
        DebugService.log('❌ 操作选项 - 文件删除失败');
        final message = '文件删除失败: $fileName';

        // 使用回调函数显示结果
        if (widget.onOperationResult != null) {
          widget.onOperationResult!(message, false);
        } else if (_savedContext != null) {
          // 使用保存的context显示SnackBar
          DebugService.log('🔍 使用保存的context显示失败SnackBar');
          try {
            final scaffoldMessenger = ScaffoldMessenger.of(_savedContext!);
            if (scaffoldMessenger.mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
              DebugService.log('🔍 失败SnackBar已显示');
            } else {
              DebugService.log('❌ ScaffoldMessenger未挂载');
            }
          } catch (e) {
            DebugService.error('❌ 显示SnackBar失败', e);
          }
        } else {
          DebugService.log('❌ 没有可用的context');
        }
      }
    } catch (e) {
      DebugService.error('❌ 操作选项 - 删除文件异常', e);
      final message = '删除失败: $e';

      // 使用回调函数显示结果
      if (widget.onOperationResult != null) {
        widget.onOperationResult!(message, false);
      } else if (_savedContext != null) {
        // 使用保存的context显示SnackBar
        DebugService.log('🔍 使用保存的context显示异常SnackBar');
        try {
          final scaffoldMessenger = ScaffoldMessenger.of(_savedContext!);
          if (scaffoldMessenger.mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
            DebugService.log('🔍 异常SnackBar已显示');
          } else {
            DebugService.log('❌ ScaffoldMessenger未挂载');
          }
        } catch (e2) {
          DebugService.error('❌ 显示SnackBar失败', e2);
        }
      } else {
        DebugService.log('❌ 没有可用的context');
      }
    }
  }
}
