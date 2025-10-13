import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/mixins/smart_keep_alive_mixin.dart';
import '../../../core/utils/responsive_utils.dart';
import '../models/category_data.dart';

/// 分类页面
class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage>
    with SmartKeepAliveClientMixin {
  // 分类展开状态
  final Map<String, bool> _categoryExpanded = {};

  @override
  void initState() {
    super.initState();
    // 初始化所有分类为展开状态
    for (final category in CategoryData.categoryNames) {
      _categoryExpanded[category] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          // 模拟刷新
          await Future.delayed(const Duration(seconds: 1));
        },
        child: _buildPageContent(),
      ),
    );
  }

  Widget _buildPageContent() {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      cacheExtent: 200, // 增加缓存范围
      slivers: [
        // 功能分类列表 - 使用SliverList.builder优化性能
        SliverList.builder(
          itemCount: CategoryData.categoryNames.length,
          itemBuilder: (context, index) {
            final category = CategoryData.categoryNames[index];
            final tools = CategoryData.getToolsForCategory(category);
            return _buildCategorySection(category, tools);
          },
        ),

        // 底部间距
        SliverToBoxAdapter(child: SizedBox(height: 80.h)),
      ],
    );
  }

  /// 构建分类区域
  Widget _buildCategorySection(String category, List<CategoryTool> tools) {
    final isExpanded = _categoryExpanded[category] ?? true;
    final int appCount = tools.length;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.only(bottom: 4.h),
      margin: EdgeInsets.only(bottom: 2.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类标题行
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: InkWell(
              onTap: () {
                setState(() {
                  _categoryExpanded[category] = !isExpanded;
                });
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 14.h),
                child: Row(
                  children: [
                    Container(
                      width: 5.w,
                      height: 28.h,
                      margin: EdgeInsets.only(left: 16.w, right: 12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(18),
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '$appCount 个应用',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(10),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: ResponsiveUtils.getIconSize(18),
                    ),
                    SizedBox(width: 20.w),
                  ],
                ),
              ),
            ),
          ),

          // 功能列表（展开时显示）
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child:
                isExpanded
                    ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            spacing: ResponsiveUtils.getSpacing(),
                            runSpacing: ResponsiveUtils.getSpacing(),
                            children: [
                              for (final tool in tools)
                                _buildFunctionButton(tool),
                            ],
                          ),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// 构建功能按钮
  Widget _buildFunctionButton(CategoryTool tool) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('点击了${tool.name}')));
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 1.w),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          constraints: BoxConstraints(maxWidth: 200.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tool.icon,
                size: ResponsiveUtils.getIconSize(16),
                color: tool.color,
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  tool.name,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(13),
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
