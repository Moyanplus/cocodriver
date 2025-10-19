import 'package:flutter/material.dart';
import '../../../config/cloud_drive_ui_config.dart';

/// 链接输入区域组件
class LinkInputSection extends StatelessWidget {
  final TextEditingController urlController;
  final TextEditingController passwordController;
  final VoidCallback onParse;
  final bool isLoading;

  const LinkInputSection({
    super.key,
    required this.urlController,
    required this.passwordController,
    required this.onParse,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: CloudDriveUIConfig.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('分享链接解析', style: CloudDriveUIConfig.titleTextStyle),
          SizedBox(height: CloudDriveUIConfig.spacingM),

          Card(
            child: Padding(
              padding: CloudDriveUIConfig.cardPadding,
              child: Column(
                children: [
                  // URL输入框
                  TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      labelText: '分享链接',
                      hintText: '请输入云盘分享链接',
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          CloudDriveUIConfig.inputRadius,
                        ),
                      ),
                    ),
                    maxLines: 2,
                  ),

                  SizedBox(height: CloudDriveUIConfig.spacingM),

                  // 密码输入框
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: '提取码（可选）',
                      hintText: '如果链接有密码请输入',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          CloudDriveUIConfig.inputRadius,
                        ),
                      ),
                    ),
                    obscureText: true,
                  ),

                  SizedBox(height: CloudDriveUIConfig.spacingL),

                  // 解析按钮
                  SizedBox(
                    width: double.infinity,
                    height: CloudDriveUIConfig.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onParse,
                      icon:
                          isLoading
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Icon(Icons.search),
                      label: Text(isLoading ? '解析中...' : '开始解析'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CloudDriveUIConfig.primaryActionColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
