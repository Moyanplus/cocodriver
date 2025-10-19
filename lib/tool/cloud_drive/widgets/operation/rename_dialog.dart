import 'package:flutter/material.dart';
import '../../config/cloud_drive_ui_config.dart';
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
        style: CloudDriveUIConfig.titleTextStyle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前文件名
          Text(
            '当前名称: ${widget.currentName}',
            style: CloudDriveUIConfig.smallTextStyle,
          ),
          
          SizedBox(height: CloudDriveUIConfig.spacingM),
          
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
            SizedBox(height: CloudDriveUIConfig.spacingS),
            Text(
              _errorMessage!,
              style: CloudDriveUIConfig.smallTextStyle.copyWith(
                color: CloudDriveUIConfig.errorColor,
              ),
            ),
          ],
          
          SizedBox(height: CloudDriveUIConfig.spacingM),
          
          // 提示信息
          Container(
            padding: CloudDriveUIConfig.cardPadding,
            decoration: BoxDecoration(
              color: CloudDriveUIConfig.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: CloudDriveUIConfig.infoColor,
                  size: CloudDriveUIConfig.iconSizeS,
                ),
                SizedBox(width: CloudDriveUIConfig.spacingS),
                Expanded(
                  child: Text(
                    '文件名不能包含特殊字符: / \\ : * ? " < > |',
                    style: CloudDriveUIConfig.smallTextStyle.copyWith(
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
          onPressed: _isLoading ? null : () {
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
