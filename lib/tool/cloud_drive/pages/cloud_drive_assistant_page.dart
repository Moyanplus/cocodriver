import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/base/debug_service.dart';
import 'cloud_drive_account_detail_page.dart';
import 'cloud_drive_login_webview.dart';
import 'cloud_drive_widgets.dart';
import '../base/cloud_drive_operation_service.dart';
import '../models/cloud_drive_models.dart';
import '../providers/cloud_drive_provider.dart';

/// 云盘助手页面
class CloudDriveAssistantPage extends ConsumerStatefulWidget {
  const CloudDriveAssistantPage({super.key});

  @override
  ConsumerState<CloudDriveAssistantPage> createState() =>
      _CloudDriveAssistantPageState();
}

class _CloudDriveAssistantPageState
    extends ConsumerState<CloudDriveAssistantPage> {
  @override
  void initState() {
    super.initState();
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cloudDriveProvider.notifier).loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cloudDriveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('云盘助手'),
        actions: [
          // 添加账号按钮
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _handleAddAccount,
            tooltip: '添加账号',
          ),
          // 切换账号选择器显示/隐藏按钮
          Consumer(
            builder: (context, ref, child) {
              final showSelector =
                  ref.watch(cloudDriveProvider).showAccountSelector;
              return IconButton(
                icon: Icon(
                  showSelector
                      ? Icons.account_circle
                      : Icons.account_circle_outlined,
                ),
                onPressed:
                    () =>
                        ref
                            .read(cloudDriveProvider.notifier)
                            .toggleAccountSelector(),
                tooltip: showSelector ? '隐藏账号选择器' : '显示账号选择器',
              );
            },
          ),
          // 取消待操作按钮
          Consumer(
            builder: (context, ref, child) {
              final showFloatingButton =
                  ref.watch(cloudDriveProvider).showFloatingActionButton;
              return showFloatingButton
                  ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed:
                        () =>
                            ref
                                .read(cloudDriveProvider.notifier)
                                .clearPendingOperation(),
                    tooltip: '取消操作',
                  )
                  : const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () => ref
                    .read(cloudDriveProvider.notifier)
                    .loadCurrentFolder(forceRefresh: true),
            tooltip: '刷新',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 打开设置页面
            },
            tooltip: '设置',
          ),
        ],
      ),
      body:
          state.accounts.isEmpty && !state.isLoading
              ? Center(
                child: EmptyStateWidget(
                  title: '暂无云盘账号',
                  subtitle: '点击右上角按钮添加第一个账号',
                  icon: Icons.cloud_off,
                  onAction: _handleAddAccount,
                  actionText: '添加账号',
                ),
              )
              : CloudDriveWidget(
                onAddAccount: _handleAddAccount,
                onAccountTap: _handleAccountTap,
              ),
      // 添加悬浮按钮
      floatingActionButton: _buildFloatingActionButton(state),
    );
  }

  /// 处理添加账号
  void _handleAddAccount() {
    _showAddAccountDialog();
  }

  /// 显示添加账号对话框
  void _showAddAccountDialog() {
    CloudDriveType selectedType = CloudDriveType.baidu;
    final nameController = TextEditingController();
    final cookiesController = TextEditingController();
    bool useWebViewLogin = true; // 默认使用WebView登录

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('添加云盘账号'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 云盘类型选择
                        DropdownButtonFormField<CloudDriveType>(
                          value: selectedType,
                          decoration: const InputDecoration(
                            labelText: '云盘类型',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              CloudDriveType.values
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Row(
                                        children: [
                                          Icon(
                                            type.iconData,
                                            color: type.color,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(type.displayName),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedType = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // 账号名称
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: '账号名称',
                            hintText: '请输入账号名称',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 登录方式选择
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '登录方式',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                FilterChip(
                                  label: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.web, size: 16),
                                      SizedBox(width: 4),
                                      Text('WebView'),
                                    ],
                                  ),
                                  selected: useWebViewLogin,
                                  onSelected: (selected) {
                                    setState(() {
                                      useWebViewLogin = selected;
                                    });
                                  },
                                  selectedColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  checkmarkColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                FilterChip(
                                  label: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.cookie, size: 16),
                                      SizedBox(width: 4),
                                      Text('Cookie'),
                                    ],
                                  ),
                                  selected: !useWebViewLogin,
                                  onSelected: (selected) {
                                    setState(() {
                                      useWebViewLogin = !selected;
                                    });
                                  },
                                  selectedColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  checkmarkColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 根据选择显示不同的内容
                        if (useWebViewLogin) ...[
                          // WebView登录说明
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '使用说明',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '1. 点击"开始登录"按钮\n'
                                  '2. 在打开的页面中完成登录\n'
                                  '3. 登录成功后点击悬浮按钮自动获取Cookie\n'
                                  '4. 确认添加账号',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // 手动输入Cookie
                          TextField(
                            controller: cookiesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Cookie',
                              hintText: '请输入登录后的Cookie',
                              border: OutlineInputBorder(),
                              helperText: '请先在浏览器中登录对应云盘，然后复制Cookie',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 帮助信息
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '获取Cookie步骤',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '1. 在浏览器中打开 ${selectedType.webViewConfig.initialUrl ?? 'https://www.123pan.com/'}\n'
                                  '2. 登录您的账号\n'
                                  '3. 按F12打开开发者工具\n'
                                  '4. 在Network标签页中找到任意请求\n'
                                  '5. 复制请求头中的Cookie值',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    if (useWebViewLogin) ...[
                      ElevatedButton.icon(
                        onPressed: () async {
                          final name = nameController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请输入账号名称')),
                            );
                            return;
                          }

                          Navigator.pop(context);

                          // 打开WebView登录页面
                          final cookies = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CloudDriveLoginWebView(
                                    cloudDriveType: selectedType,
                                    accountName: name,
                                    onLoginSuccess: (
                                      String capturedAuthData,
                                    ) async {
                                      try {
                                        // 根据认证方式创建账号对象
                                        final account = CloudDriveAccount(
                                          id:
                                              DateTime.now()
                                                  .millisecondsSinceEpoch
                                                  .toString(),
                                          type: selectedType,
                                          name: name,
                                          cookies:
                                              selectedType.authType ==
                                                      AuthType.cookie
                                                  ? capturedAuthData
                                                  : null,
                                          authorizationToken:
                                              selectedType.authType ==
                                                      AuthType.authorization
                                                  ? capturedAuthData
                                                  : null,
                                          createdAt: DateTime.now(),
                                          lastLoginAt: DateTime.now(),
                                        );

                                        // 添加到Provider
                                        await ref
                                            .read(cloudDriveProvider.notifier)
                                            .addAccount(account);

                                        _showAccountAddSuccess(name);
                                      } catch (e) {
                                        _showAccountAddError(e);
                                      }
                                    },
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('开始登录'),
                      ),
                    ] else ...[
                      ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final cookies = cookiesController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请输入账号名称')),
                            );
                            return;
                          }

                          if (cookies.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请输入Cookie')),
                            );
                            return;
                          }

                          Navigator.pop(context);

                          // 创建账号对象
                          final account = CloudDriveAccount(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            type: selectedType,
                            name: name,
                            cookies: cookies,
                            createdAt: DateTime.now(),
                            lastLoginAt: DateTime.now(),
                          );

                          try {
                            // 添加到Provider
                            await ref
                                .read(cloudDriveProvider.notifier)
                                .addAccount(account);

                            _showAccountAddSuccess(name);
                          } catch (e) {
                            _showAccountAddError(e);
                          }
                        },
                        child: const Text('添加'),
                      ),
                    ],
                  ],
                ),
          ),
    );
  }

  /// 处理账号点击
  void _handleAccountTap(CloudDriveAccount account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CloudDriveAccountDetailPage(account: account),
      ),
    );
  }

  Widget _buildFloatingActionButton(CloudDriveState state) {
    // 如果有待操作的文件，显示复制/移动按钮
    if (state.showFloatingActionButton && state.pendingOperationFile != null) {
      final file = state.pendingOperationFile!;
      final operationType = state.pendingOperationType;

      return FloatingActionButton.extended(
        onPressed: () async {
          final notifier = ref.read(cloudDriveProvider.notifier);

          DebugService.log('🎯 悬浮按钮点击事件开始');
          DebugService.log('📄 待操作文件: ${file.name}');
          DebugService.log('🔧 操作类型: ${operationType}');
          DebugService.log('👤 当前账号: ${state.currentAccount?.name ?? 'null'}');

          DebugService.log('✅ 参数验证通过，开始执行操作');

          try {
            // 执行操作
            DebugService.log('🚀 调用 executePendingOperation');
            final success = await notifier.executePendingOperation();
            DebugService.log('✅ executePendingOperation 执行完成，结果: $success');

            // 根据操作结果显示不同的提示
            if (mounted) {
              if (success) {
                DebugService.log('📱 显示成功提示 SnackBar');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '文件${operationType == 'copy' ? '复制' : '移动'}成功: ${file.name}',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
                DebugService.log('✅ 成功 SnackBar 显示完成');
              } else {
                DebugService.log('📱 显示失败提示 SnackBar');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '文件${operationType == 'copy' ? '复制' : '移动'}失败: ${file.name}',
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
                DebugService.log('✅ 失败 SnackBar 显示完成');
              }
            } else {
              DebugService.log('⚠️ Widget 已卸载，无法显示 SnackBar');
            }
          } catch (e) {
            DebugService.error('❌ 执行操作时发生异常', e);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('操作异常: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }

          DebugService.log('🎯 悬浮按钮点击事件结束');
        },
        icon: Icon(
          state.pendingOperationType == 'copy'
              ? Icons.copy
              : Icons.drive_file_move,
          color: Colors.white,
        ),
        label: Text(
          state.pendingOperationType == 'copy' ? '复制到这里' : '移动到这里',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor:
            state.pendingOperationType == 'copy' ? Colors.blue : Colors.orange,
      );
    }

    // 默认显示创建文件夹和上传按钮
    return FloatingActionButton(
      onPressed: () => _showActionMenu(context),
      tooltip: '更多操作',
      child: const Icon(Icons.add),
    );
  }

  void _showActionMenu(BuildContext context) {
    final state = ref.read(cloudDriveProvider);
    final currentAccount = state.currentAccount;

    // 如果没有当前账号，显示提示
    if (currentAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先选择云盘账号'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 检查支持的操作
    final supportsCreateFolder =
        CloudDriveOperationService.isOperationSupported(
          currentAccount,
          'createFolder',
        );

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (BuildContext context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 拖拽指示器
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 创建文件夹选项
                if (supportsCreateFolder) ...[
                  ListTile(
                    leading: Icon(
                      Icons.create_new_folder,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      '创建文件夹',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showCreateFolderDialog(context);
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: Icon(
                      Icons.create_new_folder,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    title: Text(
                      '创建文件夹（暂不支持）',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ),
                    enabled: false,
                  ),
                ],
                // 上传文件选项（暂时都不支持）
                ListTile(
                  leading: Icon(
                    Icons.upload_file,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  title: Text(
                    '上传文件（开发中）',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
                  enabled: false,
                ),
              ],
            ),
          ),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              '创建文件夹',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            content: TextField(
              controller: controller,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: '文件夹名称',
                hintText: '请输入文件夹名称',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final folderName = controller.text.trim();
                  if (folderName.isNotEmpty) {
                    Navigator.pop(context);
                    _createFolder(folderName);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('创建'),
              ),
            ],
          ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              '上传文件',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            content: Text(
              '上传功能正在开发中，敬请期待！',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '确定',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _createFolder(String folderName) async {
    final state = ref.read(cloudDriveProvider);
    final currentAccount = state.currentAccount;

    if (currentAccount == null) {
      _showErrorMessage('请先选择云盘账号');
      return;
    }

    // 检查是否支持创建文件夹
    if (!CloudDriveOperationService.isOperationSupported(
      currentAccount,
      'createFolder',
    )) {
      _showErrorMessage('当前云盘不支持创建文件夹功能');
      return;
    }

    // 获取当前文件夹ID
    String? parentFolderId;
    if (state.folderPath.isNotEmpty) {
      parentFolderId = state.folderPath.last.id;
    }

    _logFolderCreation(folderName, parentFolderId, currentAccount);

    try {
      // 使用统一的操作服务创建文件夹
      final result = await CloudDriveOperationService.createFolder(
        account: currentAccount,
        folderName: folderName,
        parentFolderId: parentFolderId,
      );

      await _handleCreateFolderResult(result, folderName);
    } catch (e, stackTrace) {
      _handleCreateFolderError(e, stackTrace, folderName);
    }
  }

  /// 显示错误消息
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 显示成功消息
  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 记录文件夹创建日志
  void _logFolderCreation(
    String folderName,
    String? parentFolderId,
    CloudDriveAccount account,
  ) {
    DebugService.log(
      '📁 开始创建文件夹',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.createFolder',
    );
    DebugService.log(
      '📝 文件夹名称: $folderName',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.createFolder',
    );
    DebugService.log(
      '📂 父文件夹ID: ${parentFolderId ?? '根目录'}',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.createFolder',
    );
    DebugService.log(
      '👤 账号信息: ${account.name} (${account.type.displayName})',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.createFolder',
    );
  }

  /// 处理创建文件夹结果
  Future<void> _handleCreateFolderResult(
    Map<String, dynamic>? result,
    String folderName,
  ) async {
    if (result != null && result['success'] == true) {
      DebugService.log(
        '✅ 文件夹创建成功',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.createFolder',
      );

      // 如果返回结果中包含文件夹对象，直接添加到状态
      if (result['folder'] != null) {
        final folder = result['folder'] as CloudDriveFile;
        DebugService.log(
          '📁 添加新文件夹到状态: ${folder.name}',
          category: DebugCategory.tools,
          subCategory: 'cloudDrive.createFolder',
        );

        // 直接添加文件夹到当前状态
        ref
            .read(cloudDriveProvider.notifier)
            .addFileToState(folder, operationType: 'create');
      } else {
        // 兜底方案：重新加载目录
        DebugService.log(
          '🔄 未返回文件夹对象，重新加载目录',
          category: DebugCategory.tools,
          subCategory: 'cloudDrive.createFolder',
        );
        await ref
            .read(cloudDriveProvider.notifier)
            .loadCurrentFolder(forceRefresh: true);
      }

      _showSuccessMessage('文件夹创建成功: $folderName');
    } else {
      DebugService.log(
        '❌ 文件夹创建失败',
        category: DebugCategory.tools,
        subCategory: 'cloudDrive.createFolder',
      );
      _showErrorMessage('文件夹创建失败，请重试');
    }
  }

  /// 处理创建文件夹错误
  void _handleCreateFolderError(
    dynamic e,
    StackTrace stackTrace,
    String folderName,
  ) {
    DebugService.log(
      '❌ 创建文件夹异常: $e',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.createFolder',
    );
    DebugService.log(
      '📄 错误堆栈: $stackTrace',
      category: DebugCategory.tools,
      subCategory: 'cloudDrive.createFolder',
    );

    _showErrorMessage('创建文件夹失败: $e');
  }

  void _showAccountAddSuccess(String accountName) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('账号添加成功: $accountName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showAccountAddError(dynamic e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('账号添加失败: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
