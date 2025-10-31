import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/cloud_drive_entities.dart';
import 'add_account_form_constants.dart';

/// Authorization Token 认证表单组件
///
/// 提供 Authorization Token 输入和验证功能
class AuthorizationAuthFormWidget extends StatefulWidget {
  final CloudDriveType cloudDriveType;
  final TextEditingController authorizationController;
  final TextEditingController? nameController;

  const AuthorizationAuthFormWidget({
    super.key,
    required this.cloudDriveType,
    required this.authorizationController,
    this.nameController,
  });

  @override
  State<AuthorizationAuthFormWidget> createState() =>
      _AuthorizationAuthFormWidgetState();
}

class _AuthorizationAuthFormWidgetState
    extends State<AuthorizationAuthFormWidget> {
  bool _isValidating = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Authorization Token 输入框
        _buildAuthorizationInput(),
        SizedBox(height: AddAccountFormConstants.smallSpacing.h),

        // 检查按钮
        _buildCheckButton(),
        SizedBox(height: AddAccountFormConstants.smallSpacing.h),

        // 状态提示
        _buildStatusIndicator(),

        // 帮助信息
        if (_errorMessage == null && _successMessage == null)
          SizedBox(height: AddAccountFormConstants.smallSpacing.h),
        _buildHelpInfo(),
      ],
    );
  }

  /// 构建 Authorization Token 输入框
  Widget _buildAuthorizationInput() {
    return TextField(
      controller: widget.authorizationController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Authorization Token',
        hintText: '请输入 Authorization Token',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AddAccountFormConstants.borderRadius.r,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AddAccountFormConstants.contentPaddingHorizontal.w,
          vertical: AddAccountFormConstants.contentPaddingVertical.h,
        ),
      ),
    );
  }

  /// 构建检查按钮
  Widget _buildCheckButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: _isValidating ? null : _checkAuthorization,
        icon:
            _isValidating
                ? SizedBox(
                  width: AddAccountFormConstants.loadingIndicatorSize.w,
                  height: AddAccountFormConstants.loadingIndicatorSize.h,
                  child: CircularProgressIndicator(
                    strokeWidth: AddAccountFormConstants.loadingIndicatorStroke,
                  ),
                )
                : Icon(
                  Icons.verified_user,
                  size: AddAccountFormConstants.iconSizeNormal.w,
                ),
        label: Text(
          _isValidating
              ? AddAccountFormConstants.btnChecking
              : AddAccountFormConstants.btnCheck,
          style: TextStyle(fontSize: AddAccountFormConstants.fontSizeNormal.sp),
        ),
      ),
    );
  }

  /// 构建状态提示
  Widget _buildStatusIndicator() {
    if (_errorMessage != null) {
      return _buildStatusContainer(
        color: Theme.of(context).colorScheme.error,
        icon: Icons.error_outline,
        message: _errorMessage!,
      );
    }

    if (_successMessage != null) {
      return _buildStatusContainer(
        color: Colors.green,
        icon: Icons.check_circle_outline,
        message: _successMessage!,
      );
    }

    return const SizedBox.shrink();
  }

  /// 构建状态容器
  Widget _buildStatusContainer({
    required Color color,
    required IconData icon,
    required String message,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AddAccountFormConstants.contentPaddingHorizontal.w,
        vertical: AddAccountFormConstants.smallSpacing.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          AddAccountFormConstants.smallBorderRadius.r,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: AddAccountFormConstants.iconSizeMedium.sp,
            color: color,
          ),
          SizedBox(width: AddAccountFormConstants.smallSpacing.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: AddAccountFormConstants.fontSizeSmall.sp,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建帮助信息
  Widget _buildHelpInfo() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AddAccountFormConstants.contentPaddingHorizontal.w,
        vertical: AddAccountFormConstants.contentPaddingVertical.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(
          alpha: AddAccountFormConstants.containerOpacity,
        ),
        borderRadius: BorderRadius.circular(
          AddAccountFormConstants.borderRadius.r,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: AddAccountFormConstants.iconSizeLarge.w,
              ),
              SizedBox(width: AddAccountFormConstants.smallSpacing.w),
              Text(
                '获取 Authorization Token 步骤',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AddAccountFormConstants.smallSpacing.h),
          Text(
            '1. 打开浏览器开发者工具（F12）\n'
            '2. 访问中国移动云盘网站并登录\n'
            '3. 在 Network 标签页中找到任意 API 请求\n'
            '4. 查看请求头中的 Authorization 字段\n'
            '5. 复制完整的 Authorization 值',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// 检查 Authorization Token
  Future<void> _checkAuthorization() async {
    final token = widget.authorizationController.text.trim();
    if (token.isEmpty) {
      setState(() {
        _errorMessage = '请先输入 Authorization Token';
        _successMessage = null;
      });
      return;
    }

    // 基本格式验证
    if (!token.startsWith('Bearer ') && !token.contains(' ')) {
      setState(() {
        _errorMessage = 'Token 格式不正确，通常以 "Bearer " 开头';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _errorMessage = null;
      _successMessage = null;
    });

    // TODO: 这里可以添加实际的验证逻辑
    // 暂时只做格式验证
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isValidating = false;
      _successMessage = 'Token 格式验证通过';
      _errorMessage = null;
    });
  }
}
