import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 分类页面
class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 模拟分类数据
  final Map<String, List<Map<String, dynamic>>> _categories = {
    '工具': [
      {'name': '计算器', 'icon': Icons.calculate, 'color': Colors.blue},
      {'name': '二维码', 'icon': Icons.qr_code, 'color': Colors.green},
      {'name': '颜色选择', 'icon': Icons.color_lens, 'color': Colors.orange},
      {'name': '单位转换', 'icon': Icons.swap_horiz, 'color': Colors.purple},
    ],
    '媒体': [
      {'name': '图片压缩', 'icon': Icons.image, 'color': Colors.pink},
      {'name': '音频转换', 'icon': Icons.audiotrack, 'color': Colors.teal},
      {'name': '视频处理', 'icon': Icons.video_library, 'color': Colors.red},
      {'name': '格式转换', 'icon': Icons.transform, 'color': Colors.indigo},
    ],
    '网络': [
      {'name': '网络测速', 'icon': Icons.speed, 'color': Colors.cyan},
      {'name': 'IP查询', 'icon': Icons.network_check, 'color': Colors.amber},
      {'name': '端口扫描', 'icon': Icons.router, 'color': Colors.deepOrange},
      {'name': 'Ping测试', 'icon': Icons.network_ping, 'color': Colors.lime},
    ],
    '生活': [
      {'name': '天气查询', 'icon': Icons.wb_sunny, 'color': Colors.yellow},
      {'name': '汇率转换', 'icon': Icons.attach_money, 'color': Colors.green},
      {'name': '邮编查询', 'icon': Icons.location_on, 'color': Colors.blue},
      {'name': '身份证查询', 'icon': Icons.badge, 'color': Colors.brown},
    ],
  };

  final Map<String, bool> _categoryExpanded = {};

  @override
  void initState() {
    super.initState();
    // 初始化所有分类为展开状态
    for (final category in _categories.keys) {
      _categoryExpanded[category] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
      slivers: [
        // 功能分类列表
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final category = _categories.keys.elementAt(index);
            final tools = _categories[category]!;
            return _buildCategorySection(category, tools);
          }, childCount: _categories.length),
        ),

        // 底部间距
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  /// 构建分类区域
  Widget _buildCategorySection(
    String category,
    List<Map<String, dynamic>> tools,
  ) {
    final isExpanded = _categoryExpanded[category] ?? true;
    final int appCount = tools.length;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.only(bottom: 4),
      margin: const EdgeInsets.only(bottom: 2),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 28,
                      margin: const EdgeInsets.only(left: 16, right: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$appCount 个应用',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 10,
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
                      size: 18,
                    ),
                    const SizedBox(width: 20),
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
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
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
  Widget _buildFunctionButton(Map<String, dynamic> tool) {
    final IconData functionIcon = tool['icon'] as IconData;
    final Color color = tool['color'] as Color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('点击了${tool['name']}')));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          constraints: const BoxConstraints(maxWidth: 200),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(functionIcon, size: 16, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  tool['name'] as String,
                  style: TextStyle(
                    fontSize: 13,
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
