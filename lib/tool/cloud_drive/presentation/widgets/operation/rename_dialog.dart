import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../common/cloud_drive_common_widgets.dart';

/// 重命名对话框组件
class RenameDialog extends StatefulWidget {
  final String currentName;
  final VoidCallback? onCancel;
  final Function(String newName)? onConfirm;

  const RenameDialog({
    super.key,
    required this.currentName,
    this.onCancel,
    this.onConfirm,
  });

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  late TextEditingController _nameController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '重命名文件',
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(18.sp),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前文件名
          Text(
            '当前名称: ${widget.currentName}',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(12.sp),
            ),
          ),

          SizedBox(height: ResponsiveUtils.getSpacing()),

          // 新文件名输入框
          CloudDriveCommonWidgets.buildInputField(
            label: '新文件名',
            hint: '请输入新的文件名',
            controller: _nameController,
            validator: _validateFileName,
            onChanged: (value) {
              setState(() {
                _errorMessage = null;
              });
            },
          ),

          // 错误信息
          if (_errorMessage != null) ...[
            SizedBox(height: ResponsiveUtils.getSpacing() * 0.5),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(12.sp),
                color: CloudDriveUIConfig.errorColor,
              ),
            ),
          ],

          SizedBox(height: ResponsiveUtils.getSpacing()),

          // 提示信息
          Container(
            padding: ResponsiveUtils.getResponsivePadding(all: 12.w),
            decoration: BoxDecoration(
              color: CloudDriveUIConfig.infoColor.withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getCardRadius(),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: CloudDriveUIConfig.infoColor,
                  size: ResponsiveUtils.getIconSize(18.sp),
                ),
                SizedBox(width: ResponsiveUtils.getSpacing() * 0.5),
                Expanded(
                  child: Text(
                    '文件名不能包含特殊字符: / \\ : * ? " < > |',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(12.sp),
                      color: CloudDriveUIConfig.infoColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          text: '确认重命名',
          onPressed: _isLoading ? () {} : _handleConfirm,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  /// 验证文件名
  String? _validateFileName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '文件名不能为空';
    }

    final trimmedValue = value.trim();

    // 检查特殊字符
    final invalidChars = RegExp(r'[/\\:*?"<>|]');
    if (invalidChars.hasMatch(trimmedValue)) {
      return '文件名包含非法字符';
    }

    // 检查长度
    if (trimmedValue.length > 255) {
      return '文件名过长（最大255个字符）';
    }

    // 检查是否与当前名称相同
    if (trimmedValue == widget.currentName) {
      return '新名称与当前名称相同';
    }

    return null;
  }

  /// 处理确认操作
  void _handleConfirm() {
    final newName = _nameController.text.trim();
    final validationError = _validateFileName(newName);

    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    widget.onConfirm?.call(newName);

    // 延迟关闭对话框，让调用者处理结果
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
