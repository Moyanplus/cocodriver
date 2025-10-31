# 网盘图标资源

本目录包含各大网盘平台的 favicon 图标，用于项目中的云盘功能展示。

## 图标列表

| 网盘名称 | 文件名 | 大小 | 官网 URL |
|---------|--------|------|---------|
| 百度网盘 | `baidu.ico` | 4.2KB | https://pan.baidu.com/ |
| 阿里云盘 | `aliyun.ico` | 17KB | https://www.aliyundrive.com/ |
| 夸克网盘 | `quark.ico` | 66KB | https://pan.quark.cn/ |
| 蓝奏云盘 | `lanzou.ico` | 1.1KB | https://up.woozooo.com/ |

## 获取方式

这些图标使用 `scripts/get_website_icon.py` 脚本自动获取：

```bash
# 批量获取示例
python3 scripts/get_website_icon.py https://pan.baidu.com/ assets/icons/cloud_drive/baidu.ico
python3 scripts/get_website_icon.py https://www.aliyundrive.com/ assets/icons/cloud_drive/aliyun.ico
python3 scripts/get_website_icon.py https://pan.quark.cn/ assets/icons/cloud_drive/quark.ico
python3 scripts/get_website_icon.py https://up.woozooo.com/ assets/icons/cloud_drive/lanzou.ico
```

## 使用方法

在 Flutter 项目中使用这些图标：

```dart
// 在 pubspec.yaml 中添加资源声明
flutter:
  assets:
    - assets/icons/cloud_drive/

// 在代码中使用
Image.asset('assets/icons/cloud_drive/baidu.ico')
Image.asset('assets/icons/cloud_drive/aliyun.ico')
Image.asset('assets/icons/cloud_drive/quark.ico')
Image.asset('assets/icons/cloud_drive/lanzou.ico')
```

## 更新说明

- 获取时间：2025-10-30
- 获取工具：`scripts/get_website_icon.py`
- 图标来源：各平台官网自动提取

## 版权说明

这些图标属于各自网盘平台的商标资产，仅用于标识对应的云盘服务。请遵守各平台的商标使用规范。

