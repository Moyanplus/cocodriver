import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../common/cloud_drive_common_widgets.dart';

/// 分享对话框组件
class ShareDialog extends StatefulWidget {
  final String fileName;
  final VoidCallback? onCancel;
  final Function(String? password, int expireDays)? onConfirm;

  const ShareDialog({
    super.key,
    required this.fileName,
    this.onCancel,
    this.onConfirm,
  });

  @override
  State<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<ShareDialog> {
  final TextEditingController _passwordController = TextEditingController();
  int _expireDays = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '分享文件',
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(18.sp),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文件名
          Text(
            '文件: ${widget.fileName}',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
            ),
          ),

          SizedBox(height: ResponsiveUtils.getSpacing()),

          // 密码设置
          CloudDriveCommonWidgets.buildInputField(
            label: '分享密码（可选）',
            hint: '留空表示无密码',
            controller: _passwordController,
            obscureText: false,
          ),

          SizedBox(height: ResponsiveUtils.getSpacing()),

          // 有效期设置
          Text(
            '有效期',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing() * 0.5),

          _buildExpireDaysSelector(),
        ],
      ),
      actions: [
        // 取消按钮
        TextButton(
          onPressed:
              _isLoading
                  ? null
                  : () {
                    widget.onCancel?.call();
                    Navigator.of(context).pop();
                  },
          child: Text(
            '取消',
            style: TextStyle(color: CloudDriveUIConfig.secondaryTextColor),
          ),
        ),

        // 确认按钮
        CloudDriveCommonWidgets.buildButton(
          text: '创建分享',
          onPressed: _isLoading ? () {} : _handleConfirm,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  /// 构建有效期选择器
  Widget _buildExpireDaysSelector() {
    final options = [
      {'label': '1天', 'value': 1},
      {'label': '7天', 'value': 7},
      {'label': '30天', 'value': 30},
      {'label': '永久', 'value': 0},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CloudDriveUIConfig.dividerColor),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getCardRadius() * 0.5,
        ),
      ),
      child: Column(
        children:
            options.map((option) {
              final isSelected = _expireDays == option['value'];
              return InkWell(
                onTap: () {
                  setState(() {
                    _expireDays = option['value'] as int;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: ResponsiveUtils.getResponsivePadding(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? CloudDriveUIConfig.primaryActionColor.withValues(
                              alpha: 0.1,
                            )
                            : null,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getCardRadius() * 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color:
                            isSelected
                                ? CloudDriveUIConfig.primaryActionColor
                                : CloudDriveUIConfig.secondaryTextColor,
                        size: ResponsiveUtils.getIconSize(18.sp),
                      ),
                      SizedBox(width: ResponsiveUtils.getSpacing() * 0.5),
                      Text(
                        option['label'] as String,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            14.sp,
                          ),
                          color:
                              isSelected
                                  ? CloudDriveUIConfig.primaryActionColor
                                  : CloudDriveUIConfig.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  /// 处理确认操作
  void _handleConfirm() {
    setState(() {
      _isLoading = true;
    });

    final password =
        _passwordController.text.trim().isEmpty
            ? null
            : _passwordController.text.trim();

    widget.onConfirm?.call(password, _expireDays);

    // 延迟关闭对话框，让调用者处理结果
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}

/// 分享结果对话框
class ShareResultDialog extends StatelessWidget {
  final String shareUrl;
  final String? password;
  final VoidCallback? onClose;

  const ShareResultDialog({
    super.key,
    required this.shareUrl,
    this.password,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('分享创建成功', style: CloudDriveUIConfig.titleTextStyle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分享链接
          CloudDriveCommonWidgets.buildInfoRow(label: '分享链接', value: shareUrl),

          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 密码
          if (password != null)
            CloudDriveCommonWidgets.buildInfoRow(
              label: '分享密码',
              value: password!,
            ),

          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: CloudDriveCommonWidgets.buildSecondaryButton(
                  text: '复制链接',
                  onPressed: () => _copyToClipboard(context, shareUrl),
                  icon: const Icon(Icons.copy),
                ),
              ),

              SizedBox(width: CloudDriveUIConfig.spacingS),

              if (password != null)
                Expanded(
                  child: CloudDriveCommonWidgets.buildSecondaryButton(
                    text: '复制密码',
                    onPressed: () => _copyToClipboard(context, password!),
                    icon: const Icon(Icons.copy),
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        CloudDriveCommonWidgets.buildButton(
          text: '关闭',
          onPressed: () {
            onClose?.call();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  /// 复制到剪贴板
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制到剪贴板'),
        backgroundColor: CloudDriveUIConfig.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
