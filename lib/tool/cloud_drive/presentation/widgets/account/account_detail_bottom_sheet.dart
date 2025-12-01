import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/scheduler.dart';

import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../providers/cloud_drive_provider.dart';
import '../../../../../core/logging/log_manager.dart';
import '../../../../../shared/widgets/common/bottom_sheet_widget.dart';
import 'edit_account_form_widget.dart';
import '../../../services/registry/cloud_drive_provider_registry.dart';

/// 账号详情底部弹窗组件
///
/// 完整的账号详情展示，包括：
/// - 账号基本信息（名称、类型、登录状态、创建时间）
/// - 云盘容量信息（已用/总容量、使用率进度条）
/// - 文件统计（用户名、手机号）
/// - 会员状态（VIP/SVIP）
/// - 认证信息（Cookie/Token/QR Code）
/// - 操作按钮（编辑、删除、刷新、复制等）
class AccountDetailBottomSheet extends ConsumerStatefulWidget {
  final CloudDriveAccount account;

  const AccountDetailBottomSheet({super.key, required this.account});

  @override
  ConsumerState<AccountDetailBottomSheet> createState() =>
      _AccountDetailBottomSheetState();
}

class _AccountDetailBottomSheetState
    extends ConsumerState<AccountDetailBottomSheet> {
  CloudDriveAccountDetails? _accountDetails;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 先用全局状态中的详情作为初始值，避免每次打开都为空
    _accountDetails = ref
        .read(cloudDriveProvider)
        .accountDetails[widget.account.id];
    // 延后刷新，避免在构建阶段修改 provider
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadAccountDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(CloudDriveUIConfig.cardRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖动条和标题
          _buildHeader(),

          // 内容区域
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: [
                  // 账号基本信息卡片
                  _buildAccountInfoCard(),
                  SizedBox(height: 12.h),

                  // 云盘容量信息
                  if (_accountDetails != null) ...[
                    _buildStorageCard(),
                    SizedBox(height: 12.h),
                  ],

                  // 认证信息
                  if (widget.account.isLoggedIn) ...[
                    _buildAuthInfoCard(),
                    SizedBox(height: 12.h),
                  ],

                  // 操作按钮
                  _buildActionButtons(),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建顶部标题栏
  Widget _buildHeader() {
    return Column(
      children: [
        // 拖动条
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // 标题和关闭按钮
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 32.w,
            right: 16.w,
            top: 0.h,
            bottom: 8.h,
          ),
          child: Row(
            children: [
              _buildTypeIcon(),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '账号详情',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (_isLoading)
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: Icon(Icons.refresh, size: 20.w),
                  onPressed: _loadAccountDetails,
                  tooltip: '刷新',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              IconButton(
                icon: Icon(Icons.close, size: 20.w),
                onPressed: () => Navigator.pop(context),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeIcon() {
    final descriptor = CloudDriveProviderRegistry.get(widget.account.type);
    if (descriptor == null) {
      throw StateError('未注册云盘描述: ${widget.account.type}');
    }
    return Icon(
      descriptor.iconData ?? Icons.cloud_outlined,
      color: descriptor.color ?? Theme.of(context).colorScheme.primary,
      size: 24.sp,
    );
  }

  /// 构建账号基本信息卡片
  Widget _buildAccountInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 账号名称和登录状态
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.account.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.account.type.displayName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (context) {
                  final isValid = _accountDetails?.isValid;
                  final isInvalid = isValid == false;
                  final isLoggedIn = !isInvalid && widget.account.isLoggedIn;
                  final statusText =
                      isInvalid ? '失效' : (isLoggedIn ? '正常' : '未登录');
                  final bgColor =
                      isInvalid
                          ? Theme.of(context).colorScheme.errorContainer
                          : isLoggedIn
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.tertiaryContainer;
                  final fgColor =
                      isInvalid
                          ? Theme.of(context).colorScheme.onErrorContainer
                          : isLoggedIn
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onTertiaryContainer;
                  final icon =
                      isInvalid
                          ? Icons.error_outline
                          : (isLoggedIn ? Icons.check_circle : Icons.warning_amber_rounded);
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 14.sp, color: fgColor),
                        SizedBox(width: 4.w),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: fgColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),
          Divider(height: 1),
          SizedBox(height: 12.h),

          // 详细信息
          _buildInfoRow('账号ID', widget.account.id),
          SizedBox(height: 8.h),
          _buildInfoRow(
            '认证方式',
            _getAuthTypeName(
              widget.account.actualAuthType ?? widget.account.type.authType,
            ),
          ),
          SizedBox(height: 8.h),
          _buildInfoRow('创建时间', _formatDateTime(widget.account.createdAt)),
          if (widget.account.lastLoginAt != null) ...[
            SizedBox(height: 8.h),
            _buildInfoRow('最后登录', _formatDateTime(widget.account.lastLoginAt)),
          ],
        ],
      ),
    );
  }

  /// 构建存储容量卡片
  Widget _buildStorageCard() {
    if (_accountDetails?.quotaInfo == null) {
      return const SizedBox.shrink();
    }

    final quota = _accountDetails!.quotaInfo!;
    final usedPercentage = quota.total > 0 ? quota.used / quota.total : 0.0;
    Color progressColor;

    if (usedPercentage > 0.9) {
      progressColor = Theme.of(context).colorScheme.error;
    } else if (usedPercentage > 0.7) {
      progressColor = Theme.of(context).colorScheme.tertiary;
    } else {
      progressColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storage,
                size: 20.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                '存储空间',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // 使用率进度条
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('使用率', style: TextStyle(fontSize: 12.sp)),
              Text(
                '${(usedPercentage * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: usedPercentage,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
          SizedBox(height: 16.h),

          // 容量详情
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '已使用',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatFileSize(quota.used),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '总容量',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatFileSize(quota.total),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 会员状态
          if (_accountDetails?.accountInfo != null) ...[
            SizedBox(height: 16.h),
            Divider(height: 1),
            SizedBox(height: 12.h),
            _buildInfoRow('用户名', _accountDetails!.accountInfo!.username),
            if (_accountDetails!.accountInfo!.phone != null) ...[
              SizedBox(height: 8.h),
              _buildInfoRow('手机', _accountDetails!.accountInfo!.phone!),
            ],
            SizedBox(height: 8.h),
            _buildInfoRow(
              'VIP状态',
              _accountDetails!.accountInfo!.isVip == true ? 'VIP用户' : '普通用户',
            ),
          ],
        ],
      ),
    );
  }

  /// 构建认证信息卡片
  Widget _buildAuthInfoCard() {
    String authType = '';
    String authValue = '';

    // 使用实际的认证方式
    final actualAuth = widget.account.actualAuthType;

    switch (actualAuth) {
      case AuthType.cookie:
        authType = 'Cookie';
        authValue = widget.account.cookies ?? '';
        break;
      case AuthType.authorization:
        authType = 'Authorization Token';
        authValue = widget.account.authorizationToken ?? '';
        break;
      case AuthType.web:
        authType = 'Authorization Token';
        authValue = widget.account.authorizationToken ?? '';
        break;
      case AuthType.qrCode:
        authType = 'QR Code Token';
        authValue = widget.account.qrCodeToken ?? '';
        break;
      case null:
        // 没有任何认证信息
        return const SizedBox.shrink();
    }

    if (authValue.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                size: 20.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                '认证信息',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildInfoRow('认证方式', authType),
          SizedBox(height: 12.h),

          // 认证凭证（完整显示）
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Text(
              authValue,
              style: TextStyle(
                fontSize: 11.sp,
                fontFamily: 'monospace',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    // 暂不提供操作按钮
    return const SizedBox.shrink();
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Text(value, style: TextStyle(fontSize: 12.sp))),
      ],
    );
  }

  /// 加载账号详情
  Future<void> _loadAccountDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 调试：打印当前账号存储字段（美化 JSON）
      final prettyAccount = const JsonEncoder.withIndent('  ').convert(
        widget.account.toJson(),
      );
      LogManager().cloudDrive(
        'AccountDetailBottomSheet: 当前账号信息\n$prettyAccount',
      );

      CloudDriveAccountDetails? details;
      if (widget.account.isLoggedIn) {
        details = await ref
            .read(cloudDriveProvider.notifier)
            .refreshAccountDetails(widget.account);
      } else {
        details =
            ref
                .read(cloudDriveProvider)
                .accountDetails[widget.account.id];
      }

      if (mounted) {
        setState(() {
          _accountDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      LogManager().error('加载账号详情失败: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载账号详情失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// 编辑账号
  void _editAccount() {
    // 关闭当前底部弹窗
    Navigator.pop(context);

    // 延迟一下再打开编辑弹窗，避免动画冲突
    Future.delayed(Duration(milliseconds: 300), () {
      if (!mounted) return;

      BottomSheetWidget.showWithTitle(
        context: context,
        title: '编辑账号',
        content: EditAccountFormWidget(
          account: widget.account,
          onAccountUpdated: (updatedAccount) async {
            try {
              // 更新账号
              await ref
                  .read(cloudDriveProvider.notifier)
                  .updateAccount(updatedAccount);

              if (context.mounted) {
                Navigator.pop(context); // 关闭编辑弹窗

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('账号更新成功'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('更新失败: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }
          },
          onCancel: () => Navigator.pop(context),
        ),
      );
    });
  }

  /// 删除账号
  void _deleteAccount() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('确认删除'),
            content: Text('确定要删除账号 "${widget.account.name}" 吗？此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); // 关闭对话框
                  Navigator.pop(context); // 关闭底部弹窗

                  try {
                    await ref
                        .read(cloudDriveProvider.notifier)
                        .deleteAccount(widget.account.id);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('账号删除成功'),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('删除失败: $e'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(
                  '删除',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// 测试连接
  void _testConnection() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('测试连接功能待实现')));
  }

  /// 复制到剪贴板
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label已复制到剪贴板'), duration: Duration(seconds: 2)),
    );
  }

  /// 显示完整认证信息
  void _showFullAuthInfo(String authType, String authValue) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(authType),
            content: SingleChildScrollView(
              child: SelectableText(
                authValue,
                style: TextStyle(fontSize: 12.sp, fontFamily: 'monospace'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _copyToClipboard(authValue, authType);
                  Navigator.pop(context);
                },
                child: Text('复制'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('关闭'),
              ),
            ],
          ),
    );
  }

  /// 获取认证方式名称
  String _getAuthTypeName(AuthType authType) {
    switch (authType) {
      case AuthType.cookie:
        return 'Cookie 认证';
      case AuthType.authorization:
        return 'Authorization 认证';
      case AuthType.web:
        return 'WebView 认证';
      case AuthType.qrCode:
        return '二维码认证';
    }
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '未知';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
  }
}
