import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/cloud_drive_ui_config.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import '../providers/cloud_drive_provider.dart';
import '../widgets/account/account.dart';
import '../../../../../core/logging/log_manager.dart';

/// 云盘账号详情页面 - 重构版本
class CloudDriveAccountDetailPage extends ConsumerStatefulWidget {
  final CloudDriveAccount account;

  const CloudDriveAccountDetailPage({super.key, required this.account});

  @override
  ConsumerState<CloudDriveAccountDetailPage> createState() =>
      _CloudDriveAccountDetailPageState();
}

class _CloudDriveAccountDetailPageState
    extends ConsumerState<CloudDriveAccountDetailPage> {
  CloudDriveAccountDetails? _accountDetails;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAccountDetails();
  }

  @override
  Widget build(BuildContext context) {
    final currentAccount = ref
        .watch(cloudDriveProvider)
        .accounts
        .firstWhere(
          (acc) => acc.id == widget.account.id,
          orElse: () => widget.account,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text('账号详情'),
        backgroundColor: CloudDriveUIConfig.primaryActionColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAccountDetails,
            tooltip: '刷新详情',
          ),
        ],
      ),
      body:
          _isLoading && _accountDetails == null
              ? _buildLoadingState()
              : SingleChildScrollView(
                padding: CloudDriveUIConfig.pagePadding,
                child: Column(
                  children: [
                    // 账号概览卡片
                    AccountOverviewCard(
                      account: currentAccount,
                      onTap: _showAccountInfo,
                    ),

                    SizedBox(height: CloudDriveUIConfig.spacingM),

                    // 云盘信息卡片
                    CloudInfoCard(
                      account: currentAccount,
                      accountDetails: _accountDetails,
                      isLoading: _isLoading,
                      error: _error,
                    ),

                    SizedBox(height: CloudDriveUIConfig.spacingM),

                    // 账号操作按钮
                    AccountActionsSection(
                      account: currentAccount,
                      onEdit: _editAccount,
                      onDelete: _deleteAccount,
                      onRefresh: _refreshAccountDetails,
                      onLogin: _loginAccount,
                      onLogout: _logoutAccount,
                      onTest: _testConnection,
                    ),

                    SizedBox(height: CloudDriveUIConfig.spacingM),

                    // 认证信息
                    AuthInfoSection(
                      account: currentAccount,
                      onCopy: _copyAuthInfo,
                      onView: _viewAuthInfo,
                    ),
                  ],
                ),
              ),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: CloudDriveUIConfig.spacingM),
          Text('正在加载账号详情...', style: CloudDriveUIConfig.bodyTextStyle),
        ],
      ),
    );
  }

  /// 加载账号详情
  Future<void> _loadAccountDetails() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: 实现获取账号详情的逻辑
      await Future.delayed(Duration(seconds: 2));

      // 模拟账号详情数据
      _accountDetails = CloudDriveAccountDetails(
        accountInfo: CloudDriveAccountInfo(
          username: widget.account.name,
          uk: 123456789,
          isVip: false,
          isSvip: false,
        ),
        quotaInfo: CloudDriveQuotaInfo(
          total: 2 * 1024 * 1024 * 1024, // 2GB
          used: 500 * 1024 * 1024, // 500MB
          serverTime: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      _error = e.toString();
      LogManager().error('加载账号详情失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 刷新账号详情
  void _refreshAccountDetails() {
    _loadAccountDetails();
  }

  /// 显示账号信息
  void _showAccountInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('账号信息'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('账号ID: ${widget.account.id}'),
                Text('账号名称: ${widget.account.name}'),
                Text('云盘类型: ${widget.account.type.displayName}'),
                Text('创建时间: ${widget.account.createdAt}'),
                Text('最后登录: ${widget.account.lastLoginAt ?? '从未登录'}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('关闭'),
              ),
            ],
          ),
    );
  }

  /// 编辑账号
  void _editAccount() {
    // TODO: 实现编辑账号逻辑
    LogManager().cloudDrive('编辑账号: ${widget.account.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('编辑账号功能待实现'),
        backgroundColor: CloudDriveUIConfig.warningColor,
      ),
    );
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
                onPressed: () => Navigator.of(context).pop(),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _executeDeleteAccount();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CloudDriveUIConfig.errorColor,
                ),
                child: Text('删除', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  /// 执行删除账号
  void _executeDeleteAccount() {
    // TODO: 实现删除账号逻辑
    LogManager().cloudDrive('删除账号: ${widget.account.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('账号删除成功'),
        backgroundColor: CloudDriveUIConfig.successColor,
      ),
    );
    Navigator.of(context).pop();
  }

  /// 登录账号
  void _loginAccount() {
    // TODO: 实现登录逻辑
    LogManager().cloudDrive('登录账号: ${widget.account.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('登录功能待实现'),
        backgroundColor: CloudDriveUIConfig.warningColor,
      ),
    );
  }

  /// 登出账号
  void _logoutAccount() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('确认登出'),
            content: Text('确定要登出账号 "${widget.account.name}" 吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _executeLogoutAccount();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CloudDriveUIConfig.warningColor,
                ),
                child: Text('登出', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  /// 执行登出账号
  void _executeLogoutAccount() {
    // TODO: 实现登出逻辑
    LogManager().cloudDrive('登出账号: ${widget.account.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('账号登出成功'),
        backgroundColor: CloudDriveUIConfig.successColor,
      ),
    );
  }

  /// 测试连接
  void _testConnection() {
    setState(() {
      _isLoading = true;
    });

    // TODO: 实现测试连接逻辑
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('连接测试成功'),
          backgroundColor: CloudDriveUIConfig.successColor,
        ),
      );
    });
  }

  /// 复制认证信息
  void _copyAuthInfo() {
    // TODO: 实现复制认证信息逻辑
    LogManager().cloudDrive('复制认证信息');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('认证信息已复制到剪贴板'),
        backgroundColor: CloudDriveUIConfig.successColor,
      ),
    );
  }

  /// 查看认证信息
  void _viewAuthInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('认证信息'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.account.cookies != null) ...[
                    Text(
                      'Cookie:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.account.cookies!),
                    SizedBox(height: CloudDriveUIConfig.spacingM),
                  ],
                  if (widget.account.authorizationToken != null) ...[
                    Text(
                      'Token:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.account.authorizationToken!),
                    SizedBox(height: CloudDriveUIConfig.spacingM),
                  ],
                  if (widget.account.qrCodeToken != null) ...[
                    Text(
                      'QR Token:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.account.qrCodeToken!),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('关闭'),
              ),
            ],
          ),
    );
  }
}
