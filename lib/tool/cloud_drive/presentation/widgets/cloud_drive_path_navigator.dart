import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../providers/cloud_drive_provider.dart';

/// ========================================
/// 云盘路径导航器组件
/// ========================================
/// 【功能】显示在文件列表顶部的面包屑导航栏
///
/// 【位置】CloudDriveAssistantPage -> _buildMainContent -> Column 的第一个子组件
///
/// 【显示内容】
///   1. 根目录状态：显示 "📁 根目录"
///   2. 子文件夹状态：显示 "返回上级" 按钮 + 完整路径链
///
/// 【工作原理】
///   - 从 cloudDriveProvider 的 state.folderPath 获取当前路径链
///   - folderPath 是一个 List<PathInfo>，记录了从根目录到当前位置的完整路径
///   - 例如：[{id: 1, name: '文档'}, {id: 2, name: '工作'}, {id: 3, name: '2024'}]
///   - 显示为：返回上级 > 文档 > 工作 > 2024
///
/// 【交互】
///   - 点击"返回上级"：调用 goBack()，返回上一级目录
///   - 点击路径中的文件夹：调用 enterFolder()（注意：当前实现可能有问题）
///
/// 【状态判断】
///   - isInSubFolder = folderPath.isNotEmpty
///   - true：在子文件夹中，显示"返回上级"按钮
///   - false：在根目录，显示"📁 根目录"文本
/// ========================================
class CloudDrivePathNavigator extends ConsumerWidget {
  const CloudDrivePathNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取云盘状态
    final state = ref.watch(cloudDriveProvider);

    // 判断是否在子文件夹中（根据路径链是否为空）
    // folderPath.isEmpty → 在根目录
    // folderPath.isNotEmpty → 在子文件夹中
    final isInSubFolder = state.folderPath.isNotEmpty;

    // ========== 主容器：带底部边框的浅色背景条 ==========
    return Container(
      // 【优化】减小垂直 padding，从 8.h 改为 6.h，让路径导航器更紧凑
      padding: ResponsiveUtils.getResponsivePadding(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      // ========== 横向布局：图标 + 路径内容（紧凑型） ==========
      child: Row(
        children: [
          // 左侧文件夹图标
          Icon(
            Icons.folder,
            size: ResponsiveUtils.getIconSize(18.sp),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: ResponsiveUtils.getSpacing() * 0.5),

          // ========== 可滚动的路径内容区域 ==========
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // 路径过长时横向滚动
              child: Row(
                children: [
                  // ========== 起点：根目录或返回按钮 ==========
                  // 如果在子文件夹中，显示"返回上级"按钮
                  // 【功能说明】点击后调用 goBack() 方法返回上一级目录
                  // 【工作原理】
                  // - goBack() 会从 folderPath 中移除最后一个元素
                  // - 然后加载父文件夹的内容
                  // - UI 会自动更新，面包屑导航会变短一级
                  if (isInSubFolder)
                    GestureDetector(
                      onTap:
                          () => ref.read(cloudDriveProvider.notifier).goBack(),
                      child: Container(
                        padding: ResponsiveUtils.getResponsivePadding(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getCardRadius(),
                          ),
                        ),
                        child: Text(
                          '返回上级',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              12.sp,
                            ),
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    )
                  // 如果在根目录，显示"📁 根目录"文本
                  else
                    Container(
                      padding: ResponsiveUtils.getResponsivePadding(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      child: Text(
                        '📁 根目录',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            12.sp,
                          ),
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),

                  // ========== 路径链：每个文件夹都显示为可点击的按钮 ==========
                  // 【显示格式】返回上级 > 文件夹1 > 文件夹2 > 文件夹3
                  // 【示例】返回上级 > 文档 > 工作文件 > 2024年度
                  // 【数据来源】state.folderPath（由 FolderStateHandler 维护的路径链）
                  //
                  // 【注意】点击路径中的文件夹会调用 enterFolder()
                  // 这可能会导致路径不一致的问题，因为：
                  // - enterFolder() 会将文件夹添加到 folderPath 末尾
                  // - 但点击中间的路径节点应该直接跳转到该层级，而不是添加到末尾
                  // 【TODO】未来可能需要实现 navigateToPath() 方法来正确处理面包屑导航点击
                  ...state.folderPath.asMap().entries.map((entry) {
                    final pathInfo = entry.value; // 路径中的每个文件夹信息

                    return Row(
                      children: [
                        // 分隔符间距
                        SizedBox(width: ResponsiveUtils.getSpacing() * 0.67),

                        // 右箭头分隔符 ">"
                        Icon(
                          Icons.chevron_right,
                          size: ResponsiveUtils.getIconSize(16.sp),
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),

                        // 分隔符间距
                        SizedBox(width: ResponsiveUtils.getSpacing() * 0.67),

                        // 可点击的文件夹按钮
                        // 【当前行为】点击后会调用 enterFolder()，将该文件夹添加到路径末尾
                        // 【期望行为】应该直接跳转到该层级（截断后面的路径）
                        GestureDetector(
                          onTap:
                              () => ref
                                  .read(cloudDriveProvider.notifier)
                                  .enterFolder(
                                    CloudDriveFile(
                                      id: pathInfo.id,
                                      name: pathInfo.name,
                                      isFolder: true,
                                    ),
                                  ),
                          child: Container(
                            padding: ResponsiveUtils.getResponsivePadding(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.getCardRadius(),
                              ),
                            ),
                            child: Text(
                              pathInfo.name, // 显示文件夹名称
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  12.sp,
                                ),
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// 使用位置说明：
// CloudDriveFileBrowserPage (主页面)
//   └── _buildBody() 方法
//       └── Column
//           ├── CloudDrivePathNavigator <-- 就是这里！（列表顶部）
//           └── Expanded(CloudDriveFileList) <-- 文件列表（占据剩余空间）
// ========================================
