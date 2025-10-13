import 'package:flutter/material.dart';

/// 分类数据模型
class CategoryData {
  /// 分类工具数据
  static const Map<String, List<CategoryTool>> categories = {
    '工具': [
      CategoryTool(name: '计算器', icon: Icons.calculate, color: Colors.blue),
      CategoryTool(name: '二维码', icon: Icons.qr_code, color: Colors.green),
      CategoryTool(name: '颜色选择', icon: Icons.color_lens, color: Colors.orange),
      CategoryTool(name: '单位转换', icon: Icons.swap_horiz, color: Colors.purple),
    ],
    '媒体': [
      CategoryTool(name: '图片压缩', icon: Icons.image, color: Colors.pink),
      CategoryTool(name: '音频转换', icon: Icons.audiotrack, color: Colors.teal),
      CategoryTool(name: '视频处理', icon: Icons.video_library, color: Colors.red),
      CategoryTool(name: '格式转换', icon: Icons.transform, color: Colors.indigo),
    ],
    '网络': [
      CategoryTool(name: '网络测速', icon: Icons.speed, color: Colors.cyan),
      CategoryTool(
        name: 'IP查询',
        icon: Icons.network_check,
        color: Colors.amber,
      ),
      CategoryTool(name: '端口扫描', icon: Icons.router, color: Colors.deepOrange),
      CategoryTool(
        name: 'Ping测试',
        icon: Icons.network_ping,
        color: Colors.lime,
      ),
    ],
    '生活': [
      CategoryTool(name: '天气查询', icon: Icons.wb_sunny, color: Colors.yellow),
      CategoryTool(name: '汇率转换', icon: Icons.attach_money, color: Colors.green),
      CategoryTool(name: '邮编查询', icon: Icons.location_on, color: Colors.blue),
      CategoryTool(name: '身份证查询', icon: Icons.badge, color: Colors.brown),
    ],
  };

  /// 获取所有分类名称
  static List<String> get categoryNames => categories.keys.toList();

  /// 获取指定分类的工具列表
  static List<CategoryTool> getToolsForCategory(String category) {
    return categories[category] ?? [];
  }

  /// 获取所有工具
  static List<CategoryTool> getAllTools() {
    return categories.values.expand((tools) => tools).toList();
  }
}

/// 分类工具数据类
class CategoryTool {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryTool({
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryTool &&
        other.name == name &&
        other.icon == icon &&
        other.color == color;
  }

  @override
  int get hashCode => name.hashCode ^ icon.hashCode ^ color.hashCode;

  @override
  String toString() => 'CategoryTool(name: $name, icon: $icon, color: $color)';
}
