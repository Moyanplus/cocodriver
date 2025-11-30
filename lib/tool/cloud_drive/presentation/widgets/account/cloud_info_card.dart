// import 'package:flutter/material.dart';
// import '../../../config/cloud_drive_ui_config.dart';
// import '../../../data/models/cloud_drive_entities.dart';
// import '../common/cloud_drive_common_widgets.dart';

// /// 云盘信息卡片组件
// ///
// /// 该组件用于显示云盘账号的详细信息，以底部弹出卡片的形式展示。主要功能包括：
// /// 1. 显示云盘存储空间使用情况（已用空间、总容量、使用率进度条）
// /// 2. 展示账号基本信息（用户名、手机号等）
// /// 3. 显示会员状态（VIP、SVIP）
// /// 4. 支持加载状态、错误状态和空状态的展示
// ///
// /// 组件特点：
// /// - 使用 DraggableScrollableSheet 实现可拖动的底部弹出效果
// /// - 响应式布局，适应不同屏幕尺寸
// /// - 优雅的状态切换（加载中、错误、空状态）
// /// - 存储空间使用率的智能颜色提示（>90% 红色、>70% 黄色、其他绿色）
// ///
// /// 调用关系：
// /// - 被 CloudDriveAccountSelector 在点击账号信息图标时调用
// /// - 使用 CloudDriveCommonWidgets 展示通用UI组件
// /// - 依赖 CloudDriveUIConfig 统一管理UI配置
// ///
// /// 参数说明：
// /// - [account]: 必需，云盘账号基本信息
// /// - [accountDetails]: 可选，云盘账号详细信息，包含存储空间、会员状态等
// /// - [isLoading]: 可选，是否处于加载状态，默认false
// /// - [error]: 可选，错误信息，如果有则显示错误状态
// ///
// /// 示例：
// /// ```dart
// /// showModalBottomSheet(
// ///   context: context,
// ///   isScrollControlled: true,
// ///   backgroundColor: Colors.transparent,
// ///   builder: (context) => CloudInfoCard(
// ///     account: cloudAccount,
// ///     accountDetails: accountDetails,
// ///   ),
// /// );
// /// ```
// class CloudInfoCard extends StatelessWidget {
//   final CloudDriveAccount account;
//   final CloudDriveAccountDetails? accountDetails;
//   final bool isLoading;
//   final String? error;
//   final bool useSimpleLayout;

//   const CloudInfoCard({
//     super.key,
//     required this.account,
//     this.accountDetails,
//     this.isLoading = false,
//     this.error,
//     this.useSimpleLayout = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // 如果是简单布局模式（用于 BottomSheetWidget），直接返回内容
//     if (useSimpleLayout) {
//       return _buildContent(context);
//     }

//     // 完整的 DraggableScrollableSheet 布局
//     return Container(
//       margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(CloudDriveUIConfig.cardRadius),
//         ),
//       ),
//       child: SafeArea(
//         child: DraggableScrollableSheet(
//           initialChildSize: 0.6,
//           minChildSize: 0.3,
//           maxChildSize: 0.95,
//           builder:
//               (context, scrollController) => Container(
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.surface,
//                   borderRadius: BorderRadius.vertical(
//                     top: Radius.circular(CloudDriveUIConfig.cardRadius),
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // 顶部拖动条
//                     Container(
//                       width: 40,
//                       height: 4,
//                       margin: EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.onSurfaceVariant.withOpacity(0.4),
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                     Padding(
//                       padding: CloudDriveUIConfig.cardPadding,
//                       child: Row(
//                         children: [
//                           Text(
//                             '云盘信息',
//                             style: CloudDriveUIConfig.titleTextStyle,
//                           ),
//                           Spacer(),
//                           IconButton(
//                             icon: Icon(Icons.close),
//                             onPressed: () => Navigator.of(context).pop(),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: SingleChildScrollView(
//                         controller: scrollController,
//                         padding: CloudDriveUIConfig.cardPadding,
//                         child: _buildContent(context),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//         ),
//       ),
//     );
//   }

//   /// 构建内容部分
//   Widget _buildContent(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (isLoading)
//           _buildLoadingState()
//         else if (error != null)
//           _buildErrorState(context, error!)
//         else if (accountDetails == null)
//           _buildEmptyState(context)
//         else
//           _buildCloudDetailsContent(context, accountDetails!),
//         SizedBox(height: CloudDriveUIConfig.spacingM),
//       ],
//     );
//   }

//   /// 构建加载状态视图
//   ///
//   /// 当 [isLoading] 为 true 时显示加载中的状态视图。
//   /// 使用 [CloudDriveCommonWidgets.buildLoadingState] 构建统一的加载状态UI，
//   /// 确保整个应用的加载状态展示风格一致。
//   ///
//   /// 返回：
//   /// - 一个居中显示的加载动画和"正在加载云盘信息..."文本的组件
//   Widget _buildLoadingState() {
//     return CloudDriveCommonWidgets.buildLoadingState(message: '正在加载云盘信息...');
//   }

//   /// 构建错误状态视图
//   ///
//   /// 当加载云盘信息失败时显示的错误状态视图。包含以下元素：
//   /// - 错误图标
//   /// - "加载失败"标题文本
//   /// - 具体的错误信息
//   ///
//   /// 参数：
//   /// - [context]: 构建上下文，用于获取主题数据
//   /// - [error]: 具体的错误信息文本
//   ///
//   /// 样式特点：
//   /// - 使用红色系错误主题色
//   /// - 带有半透明背景和边框的容器
//   /// - 居中布局的错误信息展示
//   Widget _buildErrorState(BuildContext context, String error) {
//     final colorScheme = Theme.of(context).colorScheme;
//     return Container(
//       padding: CloudDriveUIConfig.cardPadding,
//       decoration: BoxDecoration(
//         color: colorScheme.error.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
//         border: Border.all(color: colorScheme.error.withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           Icon(
//             Icons.error_outline,
//             color: colorScheme.error,
//             size: CloudDriveUIConfig.iconSizeL,
//           ),
//           SizedBox(height: CloudDriveUIConfig.spacingS),
//           Text(
//             '加载失败',
//             style: CloudDriveUIConfig.bodyTextStyle.copyWith(
//               color: colorScheme.error,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: CloudDriveUIConfig.spacingXS),
//           Text(
//             error,
//             style: CloudDriveUIConfig.smallTextStyle,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   /// 构建空状态视图
//   ///
//   /// 当 [accountDetails] 为 null 时显示的空状态视图。
//   /// 用于提示用户当前没有可用的云盘详细信息。
//   ///
//   /// 参数：
//   /// - [context]: 构建上下文，用于获取主题数据
//   ///
//   /// 视图元素：
//   /// - 云盘离线图标（cloud_off）
//   /// - "暂无云盘信息"提示文本
//   ///
//   /// 样式特点：
//   /// - 使用次要文本颜色
//   /// - 居中布局
//   /// - 简洁的空状态提示
//   Widget _buildEmptyState(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     return Container(
//       padding: CloudDriveUIConfig.cardPadding,
//       child: Column(
//         children: [
//           Icon(
//             Icons.cloud_off,
//             color: colorScheme.onSurfaceVariant,
//             size: CloudDriveUIConfig.iconSizeL,
//           ),
//           SizedBox(height: CloudDriveUIConfig.spacingS),
//           Text(
//             '暂无云盘信息',
//             style: CloudDriveUIConfig.bodyTextStyle.copyWith(
//               color: colorScheme.onSurfaceVariant,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 构建云盘详细信息内容视图
//   ///
//   /// 当有可用的账号详细信息时，构建完整的信息展示视图。
//   /// 该方法整合了所有详细信息的展示模块，包括：
//   /// 1. 存储空间信息（如果有效的配额信息）
//   /// 2. 文件统计信息
//   /// 3. 其他账号相关信息
//   ///
//   /// 参数：
//   /// - [details]: 云盘账号的详细信息，包含配额、统计数据等
//   ///
//   /// 布局特点：
//   /// - 垂直方向的列表布局
//   /// - 各个信息模块之间有统一的间距
//   /// - 根据数据有效性选择性显示某些模块
//   ///
//   /// 调用关系：
//   /// - 调用 [_buildStorageInfo] 构建存储空间信息
//   /// - 调用 [_buildFileStats] 构建文件统计信息
//   /// - 调用 [_buildOtherInfo] 构建其他信息
//   Widget _buildCloudDetailsContent(
//     BuildContext context,
//     CloudDriveAccountDetails details,
//   ) {
//     return Column(
//       children: [
//         // 存储空间信息
//         if (details.quotaInfo?.total != null &&
//             details.quotaInfo?.used != null &&
//             (details.quotaInfo!.total > 0 || details.quotaInfo!.used > 0))
//           _buildStorageInfo(context, details),

//         SizedBox(height: CloudDriveUIConfig.spacingM),

//         // 文件统计信息
//         _buildFileStats(context, details),

//         SizedBox(height: CloudDriveUIConfig.spacingM),

//         // 其他信息
//         _buildOtherInfo(context, details),
//       ],
//     );
//   }

//   /// 构建存储空间信息视图
//   ///
//   /// 展示云盘存储空间的使用情况，包括：
//   /// - 存储空间标题
//   /// - 存储空间使用进度条（当有效数据时显示）
//   /// - 已使用空间和总容量的详细信息
//   ///
//   /// 参数：
//   /// - [details]: 云盘账号详细信息，包含存储空间配额信息
//   ///
//   /// 布局特点：
//   /// - 垂直布局的信息展示
//   /// - 使用网格布局展示已用空间和总容量
//   /// - 根据数据有效性动态显示进度条
//   ///
//   /// 调用关系：
//   /// - 调用 [_buildStorageProgressBar] 构建存储空间进度条
//   /// - 使用 [CloudDriveCommonWidgets.buildInfoRow] 构建信息行
//   /// - 使用 [_formatFileSize] 格式化存储空间数值
//   Widget _buildStorageInfo(
//     BuildContext context,
//     CloudDriveAccountDetails details,
//   ) {
//     final textTheme = Theme.of(context).textTheme;
//     final colorScheme = Theme.of(context).colorScheme;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '存储空间',
//           style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
//         ),
//         SizedBox(height: CloudDriveUIConfig.spacingS),

//         if (details.quotaInfo?.total != null &&
//             details.quotaInfo?.used != null &&
//             details.quotaInfo!.total > 0 &&
//             details.quotaInfo!.used > 0) ...[
//           // 存储空间进度条
//           _buildStorageProgressBar(context, details),
//           SizedBox(height: CloudDriveUIConfig.spacingS),
//         ],

//         // 存储空间详情
//         Row(
//           children: [
//             Expanded(
//               child: CloudDriveCommonWidgets.buildInfoRow(
//                 label: '已使用',
//                 value: _formatFileSize(details.quotaInfo?.used ?? 0),
//                 labelColor: colorScheme.onSurfaceVariant,
//                 valueColor: colorScheme.onSurface,
//               ),
//             ),
//             Expanded(
//               child: CloudDriveCommonWidgets.buildInfoRow(
//                 label: '总容量',
//                 value: _formatFileSize(details.quotaInfo?.total ?? 0),
//                 labelColor: colorScheme.onSurfaceVariant,
//                 valueColor: colorScheme.onSurface,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   /// 构建存储空间使用率进度条视图
//   ///
//   /// 展示云盘存储空间使用率的可视化进度条，包括：
//   /// - 使用率百分比文本
//   /// - 带颜色提示的进度条
//   ///
//   /// 参数：
//   /// - [details]: 云盘账号详细信息，包含存储空间配额信息
//   ///
//   /// 进度条颜色逻辑：
//   /// - 使用率 > 90%: 红色警告
//   /// - 使用率 > 70%: 黄色提醒
//   /// - 使用率 ≤ 70%: 绿色正常
//   ///
//   /// 特点：
//   /// - 智能的颜色反馈机制
//   /// - 精确的百分比显示（保留一位小数）
//   /// - 当存储空间数据无效时返回空组件
//   ///
//   /// 注意：
//   /// - 仅在有效的存储空间数据（total > 0 且 used > 0）时显示
//   /// - 使用 [CloudDriveUIConfig] 中定义的颜色主题
//   Widget _buildStorageProgressBar(
//     BuildContext context,
//     CloudDriveAccountDetails details,
//   ) {
//     if (details.quotaInfo?.total == null ||
//         details.quotaInfo?.used == null ||
//         details.quotaInfo!.total == 0 ||
//         details.quotaInfo!.used == 0) {
//       return const SizedBox.shrink();
//     }

//     final usedPercentage = details.quotaInfo!.used / details.quotaInfo!.total;
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//     Color progressColor;

//     if (usedPercentage > 0.9) {
//       progressColor = colorScheme.error;
//     } else if (usedPercentage > 0.7) {
//       progressColor = colorScheme.tertiary;
//     } else {
//       progressColor = colorScheme.primary;
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               '使用率',
//               style: textTheme.bodySmall?.copyWith(
//                 color: colorScheme.onSurfaceVariant,
//               ),
//             ),
//             Text(
//               '${(usedPercentage * 100).toStringAsFixed(1)}%',
//               style: textTheme.bodySmall?.copyWith(
//                 color: colorScheme.onSurface,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: CloudDriveUIConfig.spacingXS),
//         LinearProgressIndicator(
//           value: usedPercentage,
//           backgroundColor: colorScheme.surfaceVariant,
//           valueColor: AlwaysStoppedAnimation<Color>(progressColor),
//         ),
//       ],
//     );
//   }

//   /// 构建账号基本信息统计视图
//   ///
//   /// 展示云盘账号的基本信息统计，包括：
//   /// - 用户名信息
//   /// - 手机号信息（如果有）
//   ///
//   /// 参数：
//   /// - [details]: 云盘账号详细信息，包含账号基本信息
//   ///
//   /// 布局特点：
//   /// - 使用网格布局展示统计项
//   /// - 每个统计项使用卡片式设计
//   /// - 统计项包含图标、数值和标签
//   ///
//   /// 调用关系：
//   /// - 调用 [_buildStatItem] 构建单个统计项卡片
//   /// - 使用 [CloudDriveUIConfig] 定义的样式和间距
//   ///
//   /// 注意：
//   /// - 手机号信息仅在 [details.accountInfo?.phone] 存在时显示
//   /// - 使用不同的主题色区分不同类型的信息
//   Widget _buildFileStats(
//     BuildContext context,
//     CloudDriveAccountDetails details,
//   ) {
//     final textTheme = Theme.of(context).textTheme;
//     final colorScheme = Theme.of(context).colorScheme;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '文件统计',
//           style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
//         ),
//         SizedBox(height: CloudDriveUIConfig.spacingS),

//         Row(
//           children: [
//             Expanded(
//               child: _buildStatItem(
//                 context: context,
//                 icon: Icons.person,
//                 label: '用户名',
//                 value: details.accountInfo?.username ?? '未知用户',
//                 color: colorScheme.primary,
//               ),
//             ),
//             if (details.accountInfo?.phone != null)
//               Expanded(
//                 child: _buildStatItem(
//                   context: context,
//                   icon: Icons.phone,
//                   label: '手机',
//                   value: details.accountInfo?.phone ?? '',
//                   color: colorScheme.secondary,
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }

//   /// 构建单个统计信息卡片
//   ///
//   /// 创建一个包含图标、数值和标签的统计信息卡片。
//   /// 用于在文件统计区域展示单个指标项。
//   ///
//   /// 参数：
//   /// - [icon]: 统计项的图标
//   /// - [label]: 统计项的标签文本
//   /// - [value]: 统计项的具体数值
//   /// - [color]: 统计项的主题色
//   ///
//   /// 布局特点：
//   /// - 卡片式设计，带有半透明背景
//   /// - 垂直排列的图标、数值和标签
//   /// - 统一的内边距和圆角
//   ///
//   /// 样式：
//   /// - 使用传入的主题色及其透明度变体
//   /// - 图标和数值使用主题色
//   /// - 标签使用小号文本样式
//   ///
//   /// 使用场景：
//   /// - 用于展示用户名、手机号等账号信息
//   /// - 可用于展示其他类型的统计数据
//   Widget _buildStatItem({
//     required BuildContext context,
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     final textTheme = Theme.of(context).textTheme;
//     return Container(
//       padding: CloudDriveUIConfig.cardPadding,
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: CloudDriveUIConfig.iconSize),
//           SizedBox(height: CloudDriveUIConfig.spacingXS),
//           Text(
//             value,
//             style: textTheme.titleMedium?.copyWith(
//               color: color,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           Text(
//             label,
//             style: textTheme.bodySmall?.copyWith(
//               color: Theme.of(context).colorScheme.onSurfaceVariant,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 构建其他账号信息视图
//   ///
//   /// 展示账号的额外信息，主要包括会员状态相关信息：
//   /// - VIP状态（VIP用户/普通用户）
//   /// - SVIP状态（仅当是SVIP用户时显示）
//   ///
//   /// 参数：
//   /// - [details]: 云盘账号详细信息，包含会员状态信息
//   ///
//   /// 布局特点：
//   /// - 使用列表布局垂直展示信息
//   /// - 每个信息项使用统一的信息行样式
//   ///
//   /// 调用关系：
//   /// - 使用 [CloudDriveCommonWidgets.buildInfoRow] 构建信息行
//   ///
//   /// 条件渲染：
//   /// - VIP状态始终显示
//   /// - SVIP状态仅在 [details.accountInfo?.isSvip] 为 true 时显示
//   Widget _buildOtherInfo(
//     BuildContext context,
//     CloudDriveAccountDetails details,
//   ) {
//     final colorScheme = Theme.of(context).colorScheme;
//     return Column(
//       children: [
//         CloudDriveCommonWidgets.buildInfoRow(
//           label: 'VIP状态',
//           value: details.accountInfo?.isVip == true ? 'VIP用户' : '普通用户',
//           labelColor: colorScheme.onSurfaceVariant,
//           valueColor: colorScheme.onSurface,
//         ),
//         if (details.accountInfo?.isSvip == true)
//           CloudDriveCommonWidgets.buildInfoRow(
//             label: 'SVIP状态',
//             value: 'SVIP用户',
//             labelColor: colorScheme.onSurfaceVariant,
//             valueColor: colorScheme.onSurface,
//           ),
//       ],
//     );
//   }

//   /// 格式化文件大小为人类可读的格式
//   ///
//   /// 将字节大小转换为适当的单位表示，支持从B到TB的自动单位转换。
//   ///
//   /// 参数：
//   /// - [bytes]: 文件大小（字节数），可以为null
//   ///
//   /// 返回值：
//   /// - 如果 [bytes] 为 null，返回"未知"
//   /// - 否则返回格式化后的字符串，例如：
//   ///   - "1.5 GB"
//   ///   - "720 KB"
//   ///   - "2 TB"
//   ///
//   /// 格式化规则：
//   /// - 使用1024作为换算基数
//   /// - B单位显示整数
//   /// - 其他单位保留一位小数
//   /// - 自动选择最合适的单位（B、KB、MB、GB、TB）
//   ///
//   /// 示例：
//   /// ```dart
//   /// _formatFileSize(1024) // 返回 "1.0 KB"
//   /// _formatFileSize(1048576) // 返回 "1.0 MB"
//   /// _formatFileSize(null) // 返回 "未知"
//   /// ```
//   String _formatFileSize(int? bytes) {
//     if (bytes == null) return '未知';

//     const units = ['B', 'KB', 'MB', 'GB', 'TB'];
//     int unitIndex = 0;
//     double size = bytes.toDouble();

//     while (size >= 1024 && unitIndex < units.length - 1) {
//       size /= 1024;
//       unitIndex++;
//     }

//     return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
//   }
// }
