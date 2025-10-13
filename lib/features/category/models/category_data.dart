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
      CategoryTool(name: '文本对比', icon: Icons.compare, color: Colors.blue),
      CategoryTool(name: '密码生成', icon: Icons.lock, color: Colors.green),
      CategoryTool(
        name: '时间戳转换',
        icon: Icons.access_time,
        color: Colors.orange,
      ),
      CategoryTool(name: '进制转换', icon: Icons.numbers, color: Colors.purple),
      CategoryTool(name: '正则测试', icon: Icons.code, color: Colors.blue),
      CategoryTool(
        name: 'JSON格式化',
        icon: Icons.data_object,
        color: Colors.green,
      ),
      CategoryTool(
        name: 'Base64编码',
        icon: Icons.transform,
        color: Colors.orange,
      ),
      CategoryTool(name: 'URL编码', icon: Icons.link, color: Colors.purple),
      CategoryTool(name: '哈希计算', icon: Icons.fingerprint, color: Colors.blue),
      CategoryTool(name: '随机数生成', icon: Icons.casino, color: Colors.green),
      CategoryTool(
        name: '条形码生成',
        icon: Icons.qr_code_scanner,
        color: Colors.orange,
      ),
      CategoryTool(name: '文本统计', icon: Icons.analytics, color: Colors.purple),
      CategoryTool(name: '文件大小转换', icon: Icons.storage, color: Colors.blue),
      CategoryTool(name: '温度转换', icon: Icons.thermostat, color: Colors.green),
      CategoryTool(
        name: '角度转换',
        icon: Icons.rotate_right,
        color: Colors.orange,
      ),
      CategoryTool(
        name: '货币转换',
        icon: Icons.monetization_on,
        color: Colors.purple,
      ),
      CategoryTool(name: '长度转换', icon: Icons.straighten, color: Colors.blue),
      CategoryTool(name: '重量转换', icon: Icons.scale, color: Colors.green),
      CategoryTool(name: '面积转换', icon: Icons.crop_square, color: Colors.orange),
      CategoryTool(name: '体积转换', icon: Icons.crop_free, color: Colors.purple),
      CategoryTool(name: '速度转换', icon: Icons.speed, color: Colors.blue),
      CategoryTool(name: '压力转换', icon: Icons.compress, color: Colors.green),
      CategoryTool(name: '功率转换', icon: Icons.flash_on, color: Colors.orange),
      CategoryTool(
        name: '能量转换',
        icon: Icons.battery_charging_full,
        color: Colors.purple,
      ),
      CategoryTool(name: '频率转换', icon: Icons.waves, color: Colors.blue),
      CategoryTool(
        name: '电阻转换',
        icon: Icons.electrical_services,
        color: Colors.green,
      ),
      CategoryTool(name: '电容转换', icon: Icons.battery_std, color: Colors.orange),
      CategoryTool(
        name: '电感转换',
        icon: Icons.electric_bolt,
        color: Colors.purple,
      ),
      CategoryTool(name: '磁通量转换', icon: Icons.abc, color: Colors.blue),
      CategoryTool(name: '光强转换', icon: Icons.lightbulb, color: Colors.green),
      CategoryTool(name: '声强转换', icon: Icons.volume_up, color: Colors.orange),
      CategoryTool(
        name: '辐射转换',
        icon: Icons.radio_button_checked,
        color: Colors.purple,
      ),
      CategoryTool(
        name: '剂量转换',
        icon: Icons.medical_services,
        color: Colors.blue,
      ),
      CategoryTool(name: '浓度转换', icon: Icons.science, color: Colors.green),
      CategoryTool(name: '粘度转换', icon: Icons.water_drop, color: Colors.orange),
      CategoryTool(
        name: '密度转换',
        icon: Icons.density_medium,
        color: Colors.purple,
      ),
      CategoryTool(name: '硬度转换', icon: Icons.hardware, color: Colors.blue),
      CategoryTool(name: '弹性转换', icon: Icons.extension, color: Colors.green),
      CategoryTool(name: '塑性转换', icon: Icons.shape_line, color: Colors.orange),
      CategoryTool(
        name: '韧性转换',
        icon: Icons.fitness_center,
        color: Colors.purple,
      ),
      CategoryTool(name: '脆性转换', icon: Icons.crisis_alert, color: Colors.blue),
      CategoryTool(name: '疲劳转换', icon: Icons.bedtime, color: Colors.green),
      CategoryTool(name: '蠕变转换', icon: Icons.timeline, color: Colors.orange),
      CategoryTool(
        name: '松弛转换',
        icon: Icons.self_improvement,
        color: Colors.purple,
      ),
      CategoryTool(name: '老化转换', icon: Icons.elderly, color: Colors.blue),
      CategoryTool(name: '腐蚀转换', icon: Icons.construction, color: Colors.green),
    ],
    '媒体': [
      CategoryTool(name: '图片压缩', icon: Icons.image, color: Colors.pink),
      CategoryTool(name: '音频转换', icon: Icons.audiotrack, color: Colors.teal),
      CategoryTool(name: '视频处理', icon: Icons.video_library, color: Colors.red),
      CategoryTool(name: '格式转换', icon: Icons.transform, color: Colors.indigo),
      CategoryTool(name: '图片裁剪', icon: Icons.crop, color: Colors.pink),
      CategoryTool(
        name: '图片旋转',
        icon: Icons.rotate_90_degrees_cw,
        color: Colors.teal,
      ),
      CategoryTool(name: '图片滤镜', icon: Icons.filter, color: Colors.red),
      CategoryTool(name: '图片水印', icon: Icons.water_drop, color: Colors.indigo),
      CategoryTool(name: '图片拼接', icon: Icons.grid_view, color: Colors.pink),
      CategoryTool(name: '图片分割', icon: Icons.crop_free, color: Colors.teal),
      CategoryTool(name: '图片识别', icon: Icons.visibility, color: Colors.red),
      CategoryTool(name: '图片修复', icon: Icons.healing, color: Colors.indigo),
      CategoryTool(name: '图片增强', icon: Icons.auto_fix_high, color: Colors.pink),
      CategoryTool(
        name: '图片去噪',
        icon: Icons.noise_control_off,
        color: Colors.teal,
      ),
      CategoryTool(
        name: '图片锐化',
        icon: Icons.auto_fix_normal,
        color: Colors.red,
      ),
      CategoryTool(name: '图片模糊', icon: Icons.blur_on, color: Colors.indigo),
      CategoryTool(name: '图片调色', icon: Icons.palette, color: Colors.pink),
      CategoryTool(name: '图片对比度', icon: Icons.contrast, color: Colors.teal),
      CategoryTool(name: '图片亮度', icon: Icons.brightness_6, color: Colors.red),
      CategoryTool(name: '图片饱和度', icon: Icons.tune, color: Colors.indigo),
      CategoryTool(name: '图片色温', icon: Icons.thermostat, color: Colors.pink),
      CategoryTool(name: '图片色调', icon: Icons.tune, color: Colors.teal),
      CategoryTool(name: '图片曝光', icon: Icons.exposure, color: Colors.red),
      CategoryTool(name: '图片高光', icon: Icons.highlight, color: Colors.indigo),
      CategoryTool(name: '图片阴影', icon: Icons.dark_mode, color: Colors.pink),
      CategoryTool(name: '图片中间调', icon: Icons.balance, color: Colors.teal),
      CategoryTool(name: '图片白平衡', icon: Icons.wb_sunny, color: Colors.red),
      CategoryTool(name: '图片黑点', icon: Icons.circle, color: Colors.indigo),
      CategoryTool(
        name: '图片白点',
        icon: Icons.circle_outlined,
        color: Colors.pink,
      ),
      CategoryTool(name: '图片灰点', icon: Icons.circle, color: Colors.teal),
      CategoryTool(name: '图片红点', icon: Icons.circle, color: Colors.red),
      CategoryTool(name: '图片绿点', icon: Icons.circle, color: Colors.indigo),
      CategoryTool(name: '图片蓝点', icon: Icons.circle, color: Colors.pink),
      CategoryTool(name: '图片黄点', icon: Icons.circle, color: Colors.teal),
      CategoryTool(name: '图片青点', icon: Icons.circle, color: Colors.red),
      CategoryTool(name: '图片洋红点', icon: Icons.circle, color: Colors.indigo),
      CategoryTool(name: '图片透明度', icon: Icons.opacity, color: Colors.pink),
      CategoryTool(name: '图片不透明度', icon: Icons.opacity, color: Colors.teal),
      CategoryTool(
        name: '图片混合模式',
        icon: Icons.blur_circular,
        color: Colors.red,
      ),
      CategoryTool(name: '图片图层', icon: Icons.layers, color: Colors.indigo),
      CategoryTool(name: '图片蒙版', icon: Icons.masks, color: Colors.pink),
      CategoryTool(name: '图片选区', icon: Icons.select_all, color: Colors.teal),
      CategoryTool(name: '图片路径', icon: Icons.route, color: Colors.red),
      CategoryTool(name: '图片形状', icon: Icons.shape_line, color: Colors.indigo),
      CategoryTool(name: '图片文字', icon: Icons.text_fields, color: Colors.pink),
      CategoryTool(name: '图片画笔', icon: Icons.brush, color: Colors.teal),
      CategoryTool(name: '图片橡皮擦', icon: Icons.auto_fix_off, color: Colors.red),
      CategoryTool(
        name: '图片克隆',
        icon: Icons.content_copy,
        color: Colors.indigo,
      ),
      CategoryTool(name: '图片修复', icon: Icons.healing, color: Colors.pink),
      CategoryTool(name: '图片仿制', icon: Icons.content_copy, color: Colors.teal),
      CategoryTool(name: '图片渐变', icon: Icons.gradient, color: Colors.red),
      CategoryTool(name: '图片图案', icon: Icons.pattern, color: Colors.indigo),
      CategoryTool(name: '图片纹理', icon: Icons.texture, color: Colors.pink),
      CategoryTool(name: '图片材质', icon: Icons.texture, color: Colors.teal),
      CategoryTool(name: '图片光照', icon: Icons.light_mode, color: Colors.red),
      CategoryTool(name: '图片阴影', icon: Icons.dark_mode, color: Colors.indigo),
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
      CategoryTool(name: 'DNS查询', icon: Icons.dns, color: Colors.cyan),
      CategoryTool(name: 'WHOIS查询', icon: Icons.search, color: Colors.amber),
      CategoryTool(
        name: 'SSL检查',
        icon: Icons.security,
        color: Colors.deepOrange,
      ),
      CategoryTool(name: 'HTTP头检查', icon: Icons.http, color: Colors.lime),
      CategoryTool(name: '网站状态', icon: Icons.web, color: Colors.cyan),
      CategoryTool(name: '域名解析', icon: Icons.domain, color: Colors.amber),
      CategoryTool(name: '反向DNS', icon: Icons.dns, color: Colors.deepOrange),
      CategoryTool(name: 'MX记录', icon: Icons.mail, color: Colors.lime),
      CategoryTool(name: 'TXT记录', icon: Icons.text_fields, color: Colors.cyan),
      CategoryTool(name: 'CNAME记录', icon: Icons.link, color: Colors.amber),
      CategoryTool(name: 'A记录', icon: Icons.dns, color: Colors.deepOrange),
      CategoryTool(name: 'AAAA记录', icon: Icons.dns, color: Colors.lime),
      CategoryTool(name: 'PTR记录', icon: Icons.dns, color: Colors.cyan),
      CategoryTool(name: 'SRV记录', icon: Icons.dns, color: Colors.amber),
      CategoryTool(name: 'NS记录', icon: Icons.dns, color: Colors.deepOrange),
      CategoryTool(name: 'SOA记录', icon: Icons.dns, color: Colors.lime),
      CategoryTool(name: 'CAA记录', icon: Icons.dns, color: Colors.cyan),
      CategoryTool(name: 'TLSA记录', icon: Icons.dns, color: Colors.amber),
      CategoryTool(name: 'SSHFP记录', icon: Icons.dns, color: Colors.deepOrange),
      CategoryTool(name: 'DANE记录', icon: Icons.dns, color: Colors.lime),
      CategoryTool(name: '网络延迟', icon: Icons.timer, color: Colors.cyan),
      CategoryTool(name: '带宽测试', icon: Icons.speed, color: Colors.amber),
      CategoryTool(name: '丢包率', icon: Icons.warning, color: Colors.deepOrange),
      CategoryTool(name: '抖动测试', icon: Icons.vibration, color: Colors.lime),
      CategoryTool(name: '路由追踪', icon: Icons.route, color: Colors.cyan),
      CategoryTool(name: '网络拓扑', icon: Icons.account_tree, color: Colors.amber),
      CategoryTool(
        name: '子网计算',
        icon: Icons.calculate,
        color: Colors.deepOrange,
      ),
      CategoryTool(name: 'IP范围', icon: Icons.linear_scale, color: Colors.lime),
      CategoryTool(name: '网络掩码', icon: Icons.masks, color: Colors.cyan),
      CategoryTool(name: '网关检测', icon: Icons.router, color: Colors.amber),
      CategoryTool(
        name: 'MAC地址',
        icon: Icons.device_hub,
        color: Colors.deepOrange,
      ),
      CategoryTool(name: 'ARP表', icon: Icons.table_chart, color: Colors.lime),
      CategoryTool(name: '网络接口', icon: Icons.network_wifi, color: Colors.cyan),
      CategoryTool(name: '网络统计', icon: Icons.analytics, color: Colors.amber),
      CategoryTool(name: '连接监控', icon: Icons.monitor, color: Colors.deepOrange),
      CategoryTool(name: '流量分析', icon: Icons.traffic, color: Colors.lime),
      CategoryTool(name: '协议分析', icon: Icons.analytics, color: Colors.cyan),
      CategoryTool(name: '端口监控', icon: Icons.monitor, color: Colors.amber),
      CategoryTool(name: '服务检测', icon: Icons.build, color: Colors.deepOrange),
      CategoryTool(name: '漏洞扫描', icon: Icons.security, color: Colors.lime),
      CategoryTool(name: '防火墙测试', icon: Icons.security, color: Colors.cyan),
      CategoryTool(name: '代理检测', icon: Icons.vpn_key, color: Colors.amber),
      CategoryTool(
        name: 'VPN检测',
        icon: Icons.vpn_key,
        color: Colors.deepOrange,
      ),
      CategoryTool(name: 'CDN检测', icon: Icons.cloud, color: Colors.lime),
      CategoryTool(name: '负载均衡', icon: Icons.balance, color: Colors.cyan),
      CategoryTool(name: '缓存检测', icon: Icons.cached, color: Colors.amber),
      CategoryTool(
        name: '压缩检测',
        icon: Icons.compress,
        color: Colors.deepOrange,
      ),
      CategoryTool(name: '加密检测', icon: Icons.lock, color: Colors.lime),
      CategoryTool(name: '证书检查', icon: Icons.verified_user, color: Colors.cyan),
      CategoryTool(name: '密钥检查', icon: Icons.key, color: Colors.amber),
      CategoryTool(
        name: '签名验证',
        icon: Icons.verified,
        color: Colors.deepOrange,
      ),
      CategoryTool(name: '哈希验证', icon: Icons.fingerprint, color: Colors.lime),
    ],
    '生活': [
      CategoryTool(name: '天气查询', icon: Icons.wb_sunny, color: Colors.yellow),
      CategoryTool(name: '汇率转换', icon: Icons.attach_money, color: Colors.green),
      CategoryTool(name: '邮编查询', icon: Icons.location_on, color: Colors.blue),
      CategoryTool(name: '身份证查询', icon: Icons.badge, color: Colors.brown),
      CategoryTool(name: '星座查询', icon: Icons.star, color: Colors.yellow),
      CategoryTool(
        name: '黄历查询',
        icon: Icons.calendar_today,
        color: Colors.green,
      ),
      CategoryTool(name: '节日查询', icon: Icons.celebration, color: Colors.blue),
      CategoryTool(name: '节气查询', icon: Icons.nature, color: Colors.brown),
      CategoryTool(
        name: '农历转换',
        icon: Icons.calendar_month,
        color: Colors.yellow,
      ),
      CategoryTool(
        name: '公历转换',
        icon: Icons.calendar_view_day,
        color: Colors.green,
      ),
      CategoryTool(name: '时区转换', icon: Icons.access_time, color: Colors.blue),
      CategoryTool(name: '年龄计算', icon: Icons.cake, color: Colors.brown),
      CategoryTool(name: '工作日计算', icon: Icons.work, color: Colors.yellow),
      CategoryTool(name: '倒计时', icon: Icons.timer, color: Colors.green),
      CategoryTool(name: '纪念日', icon: Icons.favorite, color: Colors.blue),
      CategoryTool(
        name: '生日提醒',
        icon: Icons.notifications,
        color: Colors.brown,
      ),
      CategoryTool(name: '日程安排', icon: Icons.schedule, color: Colors.yellow),
      CategoryTool(name: '任务管理', icon: Icons.task, color: Colors.green),
      CategoryTool(name: '习惯追踪', icon: Icons.track_changes, color: Colors.blue),
      CategoryTool(name: '目标设定', icon: Icons.flag, color: Colors.brown),
      CategoryTool(name: '进度跟踪', icon: Icons.trending_up, color: Colors.yellow),
      CategoryTool(name: '成就记录', icon: Icons.emoji_events, color: Colors.green),
      CategoryTool(name: '日记记录', icon: Icons.book, color: Colors.blue),
      CategoryTool(name: '笔记管理', icon: Icons.note, color: Colors.brown),
      CategoryTool(name: '标签管理', icon: Icons.label, color: Colors.yellow),
      CategoryTool(name: '分类管理', icon: Icons.category, color: Colors.green),
      CategoryTool(name: '收藏夹', icon: Icons.bookmark, color: Colors.blue),
      CategoryTool(
        name: '书签管理',
        icon: Icons.bookmark_border,
        color: Colors.brown,
      ),
      CategoryTool(name: '链接管理', icon: Icons.link, color: Colors.yellow),
      CategoryTool(name: '文件管理', icon: Icons.folder, color: Colors.green),
      CategoryTool(name: '图片管理', icon: Icons.image, color: Colors.blue),
      CategoryTool(
        name: '视频管理',
        icon: Icons.video_library,
        color: Colors.brown,
      ),
      CategoryTool(name: '音频管理', icon: Icons.audiotrack, color: Colors.yellow),
      CategoryTool(name: '文档管理', icon: Icons.description, color: Colors.green),
      CategoryTool(name: '表格管理', icon: Icons.table_chart, color: Colors.blue),
      CategoryTool(name: '演示管理', icon: Icons.slideshow, color: Colors.brown),
      CategoryTool(
        name: 'PDF管理',
        icon: Icons.picture_as_pdf,
        color: Colors.yellow,
      ),
      CategoryTool(name: '压缩管理', icon: Icons.compress, color: Colors.green),
      CategoryTool(name: '备份管理', icon: Icons.backup, color: Colors.blue),
      CategoryTool(name: '同步管理', icon: Icons.sync, color: Colors.brown),
      CategoryTool(name: '云存储', icon: Icons.cloud, color: Colors.yellow),
      CategoryTool(name: '本地存储', icon: Icons.storage, color: Colors.green),
      CategoryTool(name: '网络存储', icon: Icons.cloud_upload, color: Colors.blue),
      CategoryTool(name: '移动存储', icon: Icons.usb, color: Colors.brown),
      CategoryTool(name: '光盘存储', icon: Icons.disc_full, color: Colors.yellow),
      CategoryTool(name: '磁带存储', icon: Icons.music_note, color: Colors.green),
      CategoryTool(name: '固态存储', icon: Icons.memory, color: Colors.blue),
      CategoryTool(name: '机械存储', icon: Icons.hardware, color: Colors.brown),
      CategoryTool(name: '混合存储', icon: Icons.storage, color: Colors.yellow),
      CategoryTool(
        name: '分布式存储',
        icon: Icons.account_tree,
        color: Colors.green,
      ),
      CategoryTool(name: '对象存储', icon: Icons.circle, color: Colors.blue),
      CategoryTool(name: '块存储', icon: Icons.crop_square, color: Colors.brown),
      CategoryTool(
        name: '文件存储',
        icon: Icons.insert_drive_file,
        color: Colors.yellow,
      ),
      CategoryTool(name: '数据库存储', icon: Icons.storage, color: Colors.green),
      CategoryTool(name: '缓存存储', icon: Icons.cached, color: Colors.blue),
      CategoryTool(
        name: '临时存储',
        icon: Icons.temple_buddhist,
        color: Colors.brown,
      ),
      CategoryTool(name: '持久存储', icon: Icons.save, color: Colors.yellow),
      CategoryTool(name: '只读存储', icon: Icons.visibility, color: Colors.green),
      CategoryTool(name: '读写存储', icon: Icons.edit, color: Colors.blue),
      CategoryTool(name: '追加存储', icon: Icons.add, color: Colors.brown),
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
