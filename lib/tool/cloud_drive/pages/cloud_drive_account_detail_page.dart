import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/base/debug_service.dart';
import '../models/cloud_drive_models.dart';
import '../providers/cloud_drive_provider.dart';
import '../base/cloud_drive_operation_service.dart';
import '../base/cloud_drive_account_service.dart';

/// 云盘账号详情页面
class CloudDriveAccountDetailPage extends ConsumerWidget {
  final CloudDriveAccount account;

  const CloudDriveAccountDetailPage({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 从provider中获取最新的账号信息
    final currentAccount = ref
        .watch(cloudDriveProvider)
        .accounts
        .firstWhere((acc) => acc.id == account.id, orElse: () => account);

    return Scaffold(
      appBar: AppBar(
        title: const Text('账号详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshAccountDetails(context),
            tooltip: '刷新详情',
          ),
          PopupMenuButton<String>(
            onSelected:
                (value) =>
                    _handleMenuAction(context, ref, value, currentAccount),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('编辑账号'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'test',
                    child: Row(
                      children: [
                        Icon(Icons.wifi_tethering),
                        SizedBox(width: 8),
                        Text('测试连接'),
                      ],
                    ),
                  ),
                  if (currentAccount.isLoggedIn)
                    const PopupMenuItem(
                      value: 'copy_cookie',
                      child: Row(
                        children: [
                          Icon(Icons.copy),
                          SizedBox(width: 8),
                          Text('复制Cookie'),
                        ],
                      ),
                    ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('删除账号', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一部分：账号概览 - 包含基本信息
            _buildAccountOverviewCard(context, ref, currentAccount),
            const SizedBox(height: 20),

            // 第二部分：云盘详情
            _buildCloudInfoCard(context, currentAccount),
            const SizedBox(height: 20),

            // 第三部分：操作区域
            _buildActionsSection(context, ref, currentAccount),
          ],
        ),
      ),
    );
  }

  /// 构建账号概览卡片 - 包含基本信息
  Widget _buildAccountOverviewCard(
    BuildContext context,
    WidgetRef ref,
    CloudDriveAccount currentAccount,
  ) => GestureDetector(
    onTap: () => _syncAccountDetails(context, ref, currentAccount),
    child: Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 账号头部信息
            Row(
              children: [
                // 云盘图标或用户头像
                _buildAccountAvatar(context, currentAccount),
                const SizedBox(width: 16),

                // 账号名称和类型
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentAccount.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            currentAccount.type.displayName,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (currentAccount.isLoggedIn)
                            Icon(
                              Icons.touch_app,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.6),
                            ),
                          if (currentAccount.isLoggedIn)
                            Text(
                              '点击同步',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 登录状态徽章
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        currentAccount.isLoggedIn
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          currentAccount.isLoggedIn
                              ? Colors.green
                              : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        currentAccount.isLoggedIn
                            ? Icons.check_circle
                            : Icons.warning,
                        color:
                            currentAccount.isLoggedIn
                                ? Colors.green
                                : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        currentAccount.isLoggedIn ? '已登录' : '未登录',
                        style: TextStyle(
                          color:
                              currentAccount.isLoggedIn
                                  ? Colors.green
                                  : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 基本信息部分
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '基本信息',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('账号ID', currentAccount.id),
                  _buildInfoRow(
                    '创建时间',
                    _formatDateTime(currentAccount.createdAt),
                  ),
                  if (currentAccount.lastLoginAt != null)
                    _buildInfoRow(
                      '最后登录',
                      _formatDateTime(currentAccount.lastLoginAt),
                    ),
                  _buildInfoRow(
                    '认证方式',
                    _getAuthTypeDisplayName(currentAccount.type.authType),
                  ),
                  _buildAuthInfoRow(context, currentAccount),
                ],
              ),
            ),

            // 如果已登录，显示快速操作
            if (currentAccount.isLoggedIn) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '认证有效，可以正常使用云盘功能',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed:
                          () => _openCloudDrive(context, ref, currentAccount),
                      icon: const Icon(Icons.folder_open, size: 16),
                      label: const Text('打开云盘'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  /// 构建账号头像或图标
  Widget _buildAccountAvatar(BuildContext context, CloudDriveAccount account) {
    // 如果有头像URL，显示网络图片
    if (account.avatarUrl != null && account.avatarUrl!.isNotEmpty) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: account.type.color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            account.avatarUrl!,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // 头像加载失败时显示默认图标
              return _buildDefaultAvatar(account);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  strokeWidth: 2,
                ),
              );
            },
          ),
        ),
      );
    } else {
      // 没有头像时显示默认图标
      return _buildDefaultAvatar(account);
    }
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar(CloudDriveAccount account) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: account.type.color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: account.type.color.withOpacity(0.3), width: 1),
    ),
    child: Icon(account.type.iconData, color: account.type.color, size: 32),
  );

  /// 同步账号详情（包括用户名和头像）
  void _syncAccountDetails(
    BuildContext context,
    WidgetRef ref,
    CloudDriveAccount currentAccount,
  ) async {
    if (!currentAccount.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('账号未登录，无法同步详情'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 显示同步对话框
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            title: Row(
              children: [
                Icon(Icons.cloud_sync, color: Colors.blue),
                SizedBox(width: 8),
                Text('同步账号详情'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在从云盘获取最新的账号信息...'),
              ],
            ),
          ),
    );

    try {
      DebugService.log(
        '🔄 开始同步账号详情: ${currentAccount.name}',
        category: DebugCategory.tools,
        subCategory: 'account.sync',
      );

      final accountDetails = await CloudDriveOperationService.getAccountDetails(
        account: currentAccount,
      );

      Navigator.pop(context); // 关闭加载对话框

      if (accountDetails != null &&
          accountDetails.accountInfo.username.isNotEmpty) {
        final cloudUserName = accountDetails.accountInfo.username;
        final cloudUserPhoto = accountDetails.accountInfo.photo;

        // 显示同步确认对话框
        final bool? shouldSync = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.cloud_done, color: Colors.green),
                    SizedBox(width: 8),
                    Text('发现云盘信息'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('从云盘获取到以下信息：'),
                    const SizedBox(height: 16),

                    // 显示获取到的信息
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text('用户名: $cloudUserName'),
                            ],
                          ),
                          if (cloudUserPhoto != null &&
                              cloudUserPhoto.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Icon(Icons.photo, size: 16, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('头像: 已获取'),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.workspace_premium,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '会员状态: ${accountDetails.accountInfo.vipStatusDescription}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      '是否使用云盘信息更新账号名称？',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('取消'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.sync),
                    label: const Text('同步'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
        );

        if (shouldSync == true) {
          _updateAccountWithCloudInfo(
            context,
            ref,
            accountDetails,
            currentAccount,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('无法获取云盘用户信息'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // 关闭加载对话框
      DebugService.error('❌ 同步账号详情失败', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('同步失败: $e')),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 使用云盘信息更新账号
  void _updateAccountWithCloudInfo(
    BuildContext context,
    WidgetRef ref,
    CloudDriveAccountDetails details,
    CloudDriveAccount currentAccount,
  ) async {
    try {
      final newName = details.accountInfo.username;
      final photoUrl = details.accountInfo.photo;

      DebugService.log(
        '🔄 开始更新账号信息: 名称=${newName}, 头像=${photoUrl != null ? '有' : '无'}',
        category: DebugCategory.tools,
        subCategory: 'account.update',
      );

      // 创建更新后的账号对象
      final updatedAccount = currentAccount.copyWith(
        name: newName,
        avatarUrl: photoUrl,
        lastLoginAt: DateTime.now(), // 更新最后登录时间
      );

      // 更新到本地存储
      await CloudDriveAccountService.updateAccount(updatedAccount);

      // 更新Provider状态
      await ref.read(cloudDriveProvider.notifier).updateAccount(updatedAccount);

      DebugService.log(
        '✅ 账号信息更新成功: ${updatedAccount.name}',
        category: DebugCategory.tools,
        subCategory: 'account.update',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('账号信息同步成功！'),
                    Text(
                      '名称: $newName${photoUrl != null ? '，头像已更新' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '查看',
            textColor: Colors.white,
            onPressed: () {
              // 刷新页面以显示更新后的信息
              (context as Element).markNeedsBuild();
            },
          ),
        ),
      );

      // 如果有头像，记录额外的日志
      if (photoUrl != null && photoUrl.isNotEmpty) {
        DebugService.log(
          '📸 头像URL已保存: $photoUrl',
          category: DebugCategory.tools,
          subCategory: 'account.avatar',
        );
      }

      // 自动刷新页面以显示更新后的信息
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          (context as Element).markNeedsBuild();
        }
      });
    } catch (e) {
      DebugService.error('❌ 更新账号信息失败', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('同步失败'),
                    Text(
                      '$e',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// 构建云盘信息卡片
  Widget _buildCloudInfoCard(
    BuildContext context,
    CloudDriveAccount currentAccount,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '云盘详情',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _refreshAccountDetails(context),
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: '刷新详情',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<CloudDriveAccountDetails?>(
            future: _fetchAccountDetails(currentAccount),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _buildErrorState(context, snapshot.error.toString());
              }

              final accountDetails = snapshot.data;
              if (accountDetails == null) {
                return _buildEmptyState(context);
              }

              return _buildCloudDetailsContent(context, accountDetails);
            },
          ),
        ],
      ),
    ),
  );

  /// 构建云盘详情内容
  Widget _buildCloudDetailsContent(
    BuildContext context,
    CloudDriveAccountDetails details,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 用户信息
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用户信息',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            _buildCompactInfoRow('用户名', details.accountInfo.username),
            if (details.accountInfo.phone != null)
              _buildCompactInfoRow('手机号', details.accountInfo.phone!),
            _buildCompactInfoRow(
              '会员状态',
              details.accountInfo.vipStatusDescription,
            ),
          ],
        ),
      ),

      const SizedBox(height: 12),

      // 存储信息
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.secondaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '存储信息',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),

            // 使用率进度条
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '使用情况',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${details.quotaInfo.usagePercentage.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: details.quotaInfo.usagePercentage / 100,
                        backgroundColor:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          details.quotaInfo.usagePercentage > 90
                              ? Colors.red
                              : details.quotaInfo.usagePercentage > 70
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            _buildCompactInfoRow('总容量', details.quotaInfo.formattedTotal),
            _buildCompactInfoRow('已使用', details.quotaInfo.formattedUsed),
            _buildCompactInfoRow('可用空间', details.quotaInfo.formattedAvailable),
          ],
        ),
      ),

      const SizedBox(height: 8),
      Text(
        '更新时间: ${_formatDateTime(DateTime.now())}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );

  /// 构建错误状态
  Widget _buildErrorState(BuildContext context, String error) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          '获取详情失败',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          error,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Icon(
          Icons.info_outline,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          '暂不支持获取该云盘的详情',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  /// 构建操作区域
  Widget _buildActionsSection(
    BuildContext context,
    WidgetRef ref,
    CloudDriveAccount currentAccount,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '操作',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),

      // 主要操作按钮
      Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed:
                  currentAccount.isLoggedIn
                      ? () => _openCloudDrive(context, ref, currentAccount)
                      : null,
              icon: const Icon(Icons.folder_open),
              label: const Text('打开云盘'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _testConnection(context, ref, currentAccount),
              icon: const Icon(Icons.wifi_tethering),
              label: const Text('测试连接'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      // 次要操作按钮
      Row(
        children: [
          if (currentAccount.isLoggedIn) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copyCookie(context, currentAccount),
                icon: const Icon(Icons.copy),
                label: const Text('复制Cookie'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _deleteAccount(context, ref, currentAccount),
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('删除账号'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  /// 构建紧凑信息行
  Widget _buildCompactInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );

  /// 格式化日期时间
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '未知';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 处理菜单操作
  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    CloudDriveAccount currentAccount,
  ) {
    switch (action) {
      case 'edit':
        _editAccount(context, ref, currentAccount);
        break;
      case 'test':
        _testConnection(context, ref, currentAccount);
        break;
      case 'logout':
        _logoutAccount(context, ref, currentAccount);
        break;
      case 'copy_cookie':
        _copyCookie(context, currentAccount);
        break;
      case 'delete':
        _deleteAccount(context, ref, currentAccount);
        break;
    }
  }

  /// 编辑账号
  void _editAccount(
    BuildContext context,
    WidgetRef ref,
    CloudDriveAccount currentAccount,
  ) {
    // TODO: 实现编辑账号功能
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('编辑功能开发中...')));
  }

  /// 测试连接
  void _testConnection(
    BuildContext context,
    WidgetRef ref,
    CloudDriveAccount currentAccount,
  ) {
    // TODO: 实现测试连接功能
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('测试连接功能开发中...')));
  }

  /// 退出登录
  void _logoutAccount(
    BuildContext context,
    WidgetRef ref,
    CloudDriveAccount currentAccount,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('退出登录'),
            content: const Text('确定要退出登录吗？退出后需要重新登录才能使用云盘功能。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: 实现退出登录功能
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('退出登录功能开发中...')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('退出'),
              ),
            ],
          ),
    );
  }

  /// 删除账号
  void _deleteAccount(
    BuildContext context,
    WidgetRef ref,
    CloudDriveAccount currentAccount,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('删除账号'),
            content: Text('确定要删除账号 "${currentAccount.name}" 吗？此操作不可恢复。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await ref
                        .read(cloudDriveProvider.notifier)
                        .deleteAccount(currentAccount.id);
                    if (context.mounted) {
                      Navigator.pop(context); // 返回上一页
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('账号删除成功: ${currentAccount.name}'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('账号删除失败: $e')));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('删除'),
              ),
            ],
          ),
    );
  }

  /// 打开云盘
  void _openCloudDrive(
    BuildContext context,
    WidgetRef ref,
    CloudDriveAccount currentAccount,
  ) {
    // 切换到当前账号
    final state = ref.read(cloudDriveProvider);
    final accountIndex = state.accounts.indexWhere(
      (a) => a.id == currentAccount.id,
    );
    if (accountIndex != -1) {
      ref.read(cloudDriveProvider.notifier).switchAccount(accountIndex);
    }

    // 返回上一页（云盘助手页面）
    Navigator.pop(context);
  }

  /// 复制Cookie
  void _copyCookie(BuildContext context, CloudDriveAccount currentAccount) {
    final cookies = currentAccount.cookies;
    if (cookies != null && cookies.isNotEmpty) {
      try {
        Clipboard.setData(ClipboardData(text: cookies));
        DebugService.log(
          '🍪 Cookie已复制到剪贴板，长度: ${cookies.length}',
          category: DebugCategory.tools,
          subCategory: 'account.cookie',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Cookie已复制到剪贴板'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        DebugService.error('❌ 复制Cookie失败', e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('复制失败: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      DebugService.log('⚠️ Cookie为空，无法复制');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Cookie为空，无法复制'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// 复制认证信息
  void _copyAuthInfo(BuildContext context, CloudDriveAccount currentAccount) {
    String paramInfo = '';
    String fullParamValue = ''; // 完整的认证信息用于复制
    String displayParamValue = ''; // 略缩版用于显示

    switch (currentAccount.type.authType) {
      case AuthType.cookie:
        if (currentAccount.cookies != null) {
          paramInfo = 'Cookie';
          fullParamValue = currentAccount.cookies!; // 完整的Cookie
          // 显示前50个字符，避免过长
          displayParamValue =
              fullParamValue.length > 50
                  ? '${fullParamValue.substring(0, 50)}...'
                  : fullParamValue;
        }
        break;
      case AuthType.authorization:
        if (currentAccount.authorizationToken != null) {
          paramInfo = 'Token';
          fullParamValue = currentAccount.authorizationToken!; // 完整的Token
          // 显示前30个字符，避免过长
          displayParamValue =
              fullParamValue.length > 30
                  ? '${fullParamValue.substring(0, 30)}...'
                  : fullParamValue;
        }
        break;
    }

    if (paramInfo.isEmpty || fullParamValue.isEmpty) {
      return;
    }

    try {
      // 复制完整的认证信息到剪贴板
      Clipboard.setData(ClipboardData(text: fullParamValue));
      DebugService.log(
        '📋 完整$paramInfo已复制到剪贴板 (长度: ${fullParamValue.length})',
        category: DebugCategory.tools,
        subCategory: 'account.auth',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('完整$paramInfo已复制到剪贴板'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      DebugService.error('❌ 复制认证信息失败', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('复制失败: $e'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<CloudDriveAccountDetails?> _fetchAccountDetails(
    CloudDriveAccount currentAccount,
  ) async {
    try {
      DebugService.log(
        '🔍 开始获取账号详情: ${currentAccount.name} (${currentAccount.type.displayName})',
        category: DebugCategory.tools,
        subCategory: 'account.details',
      );

      final details = await CloudDriveOperationService.getAccountDetails(
        account: currentAccount,
      );

      if (details != null) {
        DebugService.log(
          '✅ 账号详情获取成功: ${details.accountInfo.username}',
          category: DebugCategory.tools,
          subCategory: 'account.details',
        );
      } else {
        DebugService.log(
          '⚠️ 账号详情获取失败: 返回null',
          category: DebugCategory.tools,
          subCategory: 'account.details',
        );
      }

      return details;
    } catch (e, stackTrace) {
      DebugService.log(
        '❌ 获取账号详情异常: $e',
        category: DebugCategory.tools,
        subCategory: 'account.details',
      );
      DebugService.log(
        '📄 错误堆栈: $stackTrace',
        category: DebugCategory.tools,
        subCategory: 'account.details',
      );
      rethrow;
    }
  }

  void _refreshAccountDetails(BuildContext context) {
    // 触发页面重建以重新获取数据
    (context as Element).markNeedsBuild();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在刷新账号详情...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getAuthTypeDisplayName(AuthType authType) {
    switch (authType) {
      case AuthType.cookie:
        return 'Cookie认证';
      case AuthType.authorization:
        return 'Token认证';
    }
  }

  Widget _buildAuthInfoRow(
    BuildContext context,
    CloudDriveAccount currentAccount,
  ) {
    if (!currentAccount.isLoggedIn) {
      return const SizedBox.shrink();
    }

    String paramInfo = '';
    String paramValue = '';

    switch (currentAccount.type.authType) {
      case AuthType.cookie:
        if (currentAccount.cookies != null) {
          paramInfo = 'Cookie';
          final cookieStr = currentAccount.cookies!;
          // 显示前50个字符，避免过长
          paramValue =
              cookieStr.length > 50
                  ? '${cookieStr.substring(0, 50)}...'
                  : cookieStr;
        }
        break;
      case AuthType.authorization:
        if (currentAccount.authorizationToken != null) {
          paramInfo = 'Token';
          final tokenStr = currentAccount.authorizationToken!;
          // 显示前30个字符，避免过长
          paramValue =
              tokenStr.length > 30
                  ? '${tokenStr.substring(0, 30)}...'
                  : tokenStr;
        }
        break;
    }

    if (paramInfo.isEmpty || paramValue.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 4),
        _buildClickableInfoRow(
          paramInfo,
          paramValue,
          onTap: () => _copyAuthInfo(context, currentAccount),
        ),
      ],
    );
  }

  Widget _buildClickableInfoRow(
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: onTap != null ? '点击复制完整认证信息' : '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.blue.withOpacity(0.05),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  '$label:',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              Icon(Icons.copy, size: 16, color: Colors.blue.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
