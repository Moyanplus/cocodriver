/// 应用侧边栏组件
///
/// 提供应用程序的侧边导航栏功能，包含用户信息、导航菜单、主题切换等
/// 使用Riverpod进行状态管理，支持响应式布局和多平台适配
///
/// 主要功能：
/// - 用户头像和信息显示
/// - 导航菜单项
/// - 主题切换功能
/// - 云盘类型选择
/// - 设置页面入口
/// - 响应式布局适配
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// 核心模块导入
import '../../../core/navigation/navigation_providers.dart';
import '../../../core/providers/cloud_drive_type_provider.dart';
import '../../../core/theme/theme_models.dart';
import '../../../core/utils/adaptive_utils.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/common/bottom_sheet_widget.dart';

// 云盘功能导入
import '../../../tool/cloud_drive/data/models/cloud_drive_entities.dart';
import '../../../tool/cloud_drive/base/cloud_drive_operation_service.dart';
import '../../../tool/cloud_drive/presentation/providers/cloud_drive_provider.dart';
import '../../../tool/cloud_drive/presentation/state/cloud_drive_state_manager.dart';
import '../../../tool/cloud_drive/presentation/widgets/account/account_detail_bottom_sheet.dart';
import '../../../tool/cloud_drive/presentation/widgets/add_account/add_account_form_widget.dart';

/// 当前账号详情 Provider：根据选中账号动态拉取云盘账号信息
final currentAccountDetailsProvider =
    FutureProvider.autoDispose<CloudDriveAccountDetails?>((ref) async {
      final account = ref.watch(currentAccountProvider);
      if (account == null) return null;
      final strategy = CloudDriveOperationService.getStrategy(account.type);
      if (strategy == null) return null;
      return strategy.getAccountDetails(account: account);
    });

/// 应用侧边栏Widget
///
/// 使用Riverpod进行状态管理，提供侧边导航功能
/// 包含用户信息、导航菜单、主题切换等核心功能
class AppDrawerWidget extends ConsumerStatefulWidget {
  const AppDrawerWidget({super.key});

  @override
  ConsumerState<AppDrawerWidget> createState() => _AppDrawerWidgetState();
}

/// AppDrawerWidget的状态管理类
///
/// 负责监听主题和云盘类型变化，构建侧边栏的UI结构
/// 包括用户信息区域、导航菜单、主题切换等组件
class _AppDrawerWidgetState extends ConsumerState<AppDrawerWidget> {
  bool _hasRequestedAccounts = false;

  @override
  void initState() {
    super.initState();
    // 首次构建时若账号列表为空，则主动触发一次加载，避免侧边栏初次打开空白
    Future.microtask(() async {
      if (!mounted) return;
      final state = ref.read(cloudDriveProvider);
      if (!_hasRequestedAccounts && state.accounts.isEmpty) {
        _hasRequestedAccounts = true;
        await ref.read(cloudDriveEventHandlerProvider).loadAccounts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // 顶部用户信息区域
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20.h,
              bottom: 20.h,
              left: 20.w,
              right: 20.w,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                // 头像
                _buildAvatar(context, ref),
                SizedBox(height: 16.h),
                // 用户信息
                _buildUserInfo(context, ref),
              ],
            ),
          ),
          // 云盘类型选择器
          _buildCloudDriveTypeSelector(context, ref),

          // 测试页面区域（仅在debug模式显示）
          if (kDebugMode) _buildTestPagesSection(context, ref),

          // 菜单项
          Expanded(child: _buildMenuItems(context, ref)),
          // 底部区域
          _buildFooter(context, ref),
        ],
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    final initial =
        (account?.name.isNotEmpty ?? false)
            ? account!.name[0].toUpperCase()
            : 'F';
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 3.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: ResponsiveUtils.getIconSize(50),
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Text(
          initial,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(30),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  /// 构建用户信息
  Widget _buildUserInfo(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    final detailsAsync = ref.watch(currentAccountDetailsProvider);

    final name = account?.name ?? '未登录';
    final typeLabel = account?.type.displayName ?? '请选择云盘';

    return Column(
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: ResponsiveUtils.getResponsiveFontSize(16),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          typeLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: ResponsiveUtils.getResponsiveFontSize(12),
          ),
        ),
        SizedBox(height: 4.h),
        detailsAsync.when(
          data: (details) {
            if (details == null) return const SizedBox.shrink();
            final info = details.accountInfo;
            final vip = info?.isVip == true || info?.isSvip == true;
            final subtitle = info?.username ?? details.name;
            final badge = vip ? 'VIP' : (details.isValid ? '已登录' : '未登录');

            return Column(
              children: [
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: ResponsiveUtils.getResponsiveFontSize(12),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  badge,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        vip
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(12),
                  ),
                ),
                if (details.quotaInfo != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    '存储: ${(details.quotaInfo!.used / (1024 * 1024 * 1024)).toStringAsFixed(1)} / ${(details.quotaInfo!.total / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: ResponsiveUtils.getResponsiveFontSize(12),
                    ),
                  ),
                ],
              ],
            );
          },
          loading:
              () => Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: SizedBox(
                  height: 12,
                  width: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
          error:
              (_, __) => Text(
                '账号信息获取失败',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.8),
                  fontSize: ResponsiveUtils.getResponsiveFontSize(12),
                ),
              ),
        ),
      ],
    );
  }

  /// 构建云盘类型选择器
  Widget _buildCloudDriveTypeSelector(BuildContext context, WidgetRef ref) {
    final cloudDriveTypeState = ref.watch(cloudDriveTypeProvider);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.cloud(),
                size: ResponsiveUtils.getIconSize(20),
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                '云盘类型',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                cloudDriveTypeState.availableTypes.map((type) {
                  final isSelected = cloudDriveTypeState.selectedType == type;
                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        ref
                            .read(cloudDriveTypeProvider.notifier)
                            .clearSelection();
                      } else {
                        ref
                            .read(cloudDriveTypeProvider.notifier)
                            .selectType(type);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? type.color.withValues(alpha: 0.2)
                                : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color:
                              isSelected
                                  ? type.color
                                  : Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type.iconData,
                            size: ResponsiveUtils.getIconSize(16),
                            color:
                                isSelected
                                    ? type.color
                                    : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            type.displayName,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  isSelected
                                      ? type.color
                                      : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  /// 构建菜单项
  Widget _buildMenuItems(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // 账号管理
        _buildMenuItem(
          context,
          icon: PhosphorIcons.userList(),
          title: '账号管理',
          onTap: () {
            Navigator.pop(context);
            _showAccountManager(context, ref);
          },
        ),

        // 下载管理
        _buildMenuItem(
          context,
          icon: PhosphorIcons.downloadSimple(),
          title: '下载管理',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/download/manager');
          },
        ),

        // 主题管理
        _buildMenuItem(
          context,
          icon: PhosphorIcons.palette(),
          title: '主题管理',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/settings/theme');
          },
        ),

        // 设置
        _buildMenuItem(
          context,
          icon: PhosphorIcons.gear(),
          title: '设置',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/settings');
          },
        ),

        // 关于
        _buildMenuItem(
          context,
          icon: PhosphorIcons.info(),
          title: '关于',
          onTap: () {
            Navigator.pop(context);
            showAboutDialog(
              context: context,
              applicationName: 'Flutter UI模板',
              applicationVersion: '1.0.0',
              applicationIcon: Icon(PhosphorIcons.squaresFour(), size: 48),
              children: const [
                Text('这是一个基于可可世界设计的Flutter UI模板项目。'),
                SizedBox(height: 16),
                Text('© 2024 Flutter UI模板'),
              ],
            );
          },
        ),

        // 帮助
        _buildMenuItem(
          context,
          icon: PhosphorIcons.question(),
          title: '帮助',
          onTap: () {
            Navigator.pop(context);
            _showHelpDialog(context);
          },
        ),

        // 反馈
        _buildMenuItem(
          context,
          icon: PhosphorIcons.chatCircle(),
          title: '反馈',
          onTap: () {
            Navigator.pop(context);
            _showFeedbackDialog(context);
          },
        ),
      ],
    );
  }

  /// 构建菜单项
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Widget? trailing,
  }) => AdaptiveUtils.adaptiveListTile(
    leading: Icon(
      icon,
      color:
          isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
      size: ResponsiveUtils.getIconSize(24),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
        fontSize: ResponsiveUtils.getResponsiveFontSize(14),
      ),
    ),
    trailing: trailing,
    onTap: onTap,
  );

  /// 构建底部
  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(all: 16),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.info(),
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            size: ResponsiveUtils.getIconSize(16),
          ),
          SizedBox(width: 8.w),
          Text(
            '版本 1.0.0',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: ResponsiveUtils.getResponsiveFontSize(12),
            ),
          ),
          const Spacer(),
          Consumer(
            builder: (context, ref, child) {
              final currentTheme = ref.watch(currentThemeProvider);
              return IconButton(
                icon: Icon(
                  currentTheme == ThemeType.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                  size: ResponsiveUtils.getIconSize(20),
                ),
                onPressed: () async {
                  // 切换主题：浅色 <-> 深色
                  final ThemeType newTheme =
                      currentTheme == ThemeType.dark
                          ? ThemeType.light
                          : ThemeType.dark;

                  await ref.read(themeProvider.notifier).setTheme(newTheme);

                  // 显示切换提示
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '已切换到${newTheme == ThemeType.light ? '浅色' : '深色'}主题',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                tooltip: '切换主题模式',
              );
            },
          ),
        ],
      ),
    );
  }

  /// 账号管理入口：列表 + 添加
  Future<void> _showAccountManager(BuildContext context, WidgetRef ref) async {
    // 预先获取账户与事件处理器，避免在 BottomSheet 生命周期外使用 ref
    final typeState = ref.read(cloudDriveTypeProvider);
    final handler = ref.read(cloudDriveStateManagerProvider.notifier);
    final cloudProvider = ref.read(cloudDriveProvider);
    final isLoading = cloudProvider.isLoading;
    final allAccounts = cloudProvider.accounts;
    final idToIndex = <String, int>{
      for (var i = 0; i < allAccounts.length; i++) allAccounts[i].id: i,
    };

    final accounts =
        allAccounts.where((a) {
          if (typeState.isFilterEnabled && typeState.selectedType != null) {
            return a.type == typeState.selectedType;
          }
          return true;
        }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('云盘账号管理'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      debugPrint('[AccountAdd] add button pressed');
                      // 预先获取根级 context，避免当前 BottomSheet 关闭后 context 失效
                      final rootCtx =
                          Navigator.of(
                            ctx,
                            rootNavigator: true,
                          ).overlay?.context;
                      Navigator.pop(ctx);
                      Future.microtask(() {
                        if (rootCtx != null && rootCtx.mounted) {
                          debugPrint(
                            '[AccountAdd] using root context to show add sheet',
                          );
                          _handleAddAccount(rootCtx, handler);
                        } else {
                          debugPrint(
                            '[AccountAdd] root context unavailable, fallback to ctx',
                          );
                          _handleAddAccount(ctx, handler);
                        }
                      });
                    },
                  ),
                ),
                if (accounts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child:
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : const Text('尚未添加云盘账号'),
                  )
                else
                  ...accounts.map(
                    (a) => ListTile(
                      title: Text('${a.name} (${a.type.displayName})'),
                      subtitle: Text('ID: ${a.id}'),
                      onTap: () {
                        // 点按：切换账号
                        final idx = idToIndex[a.id];
                        Navigator.pop(ctx);
                        if (idx != null) {
                          handler.switchAccount(idx);
                        } else {
                          debugPrint('[AccountTap] idx not found for ${a.id}');
                        }
                      },
                      onLongPress: () {
                        // 长按：查看账号详情
                        final nav = Navigator.of(ctx, rootNavigator: true);
                        final rootCtx = nav.overlay?.context ?? ctx;
                        Navigator.pop(ctx);
                        Future.microtask(() {
                          if (rootCtx.mounted) {
                            _showAccountDetail(rootCtx, a);
                          }
                        });
                      },
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleAddAccount(BuildContext context, CloudDriveStateManager handler) {
    debugPrint('[AccountAdd] _handleAddAccount invoked, context=$context');
    final navigator = Navigator.of(context, rootNavigator: true);
    debugPrint(
      '[AccountAdd] navigator=$navigator, overlay=${navigator.overlay}, overlay.ctx=${navigator.overlay?.context}',
    );
    final rootContext = navigator.overlay?.context ?? navigator.context;
    debugPrint('[AccountAdd] resolved rootContext=$rootContext');
    BottomSheetWidget.showWithTitle(
      context: rootContext,
      title: '添加云盘账号',
      content: AddAccountFormWidget(
        onAccountCreated: (account) async {
          try {
            await handler.addAccount(account);
            if (rootContext.mounted) {
              Navigator.pop(rootContext);
              _showAccountAddSuccess(rootContext, account.name);
            }
          } catch (e) {
            if (rootContext.mounted) {
              _showAccountAddError(rootContext, e);
            }
          }
        },
        onCancel: () => Navigator.pop(rootContext),
      ),
    );
  }

  void _showAccountDetail(BuildContext context, CloudDriveAccount account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AccountDetailBottomSheet(account: account),
    );
  }

  void _showAccountAddSuccess(BuildContext context, String accountName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('账号添加成功: $accountName'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAccountAddError(BuildContext context, dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('账号添加失败: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 显示帮助对话框
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('帮助'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('这是一个Flutter UI模板项目，包含以下功能：'),
                SizedBox(height: 8),
                Text('• 多种主题选择'),
                Text('• 响应式设计'),
                Text('• 流畅的导航'),
                Text('• 丰富的组件库'),
                SizedBox(height: 8),
                Text('您可以根据需要自定义和扩展功能。'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }

  /// 显示反馈对话框
  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('反馈'),
            content: const Text(
              '感谢您的使用！如有问题或建议，请通过以下方式联系我们：\n\n• 提交Issue到项目仓库\n• 发送邮件反馈\n• 参与社区讨论',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }

  /// 构建测试页面区域
  Widget _buildTestPagesSection(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                PhosphorIcons.bug(),
                size: ResponsiveUtils.getIconSize(20),
                color: Colors.orange,
              ),
              SizedBox(width: 8.w),
              Text(
                '测试页面',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 测试页面按钮
          _buildTestChip(
            context,
            icon: PhosphorIcons.globe(),
            label: 'WebView测试',
            color: Colors.blue,
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/test/webview');
            },
          ),
        ],
      ),
    );
  }

  /// 构建测试chip
  Widget _buildTestChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: ResponsiveUtils.getIconSize(16), color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
