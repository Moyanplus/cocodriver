import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/cloud_drive_entities.dart';
import '../../../services/common/authorization_validation_service.dart';
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
    // 检查是否支持 Authorization Token
    final supportsAuth =
        AuthorizationValidationService.supportsAuthorizationToken(
          widget.cloudDriveType,
        );

    if (!supportsAuth) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AddAccountFormConstants.contentPaddingHorizontal.w,
          vertical: AddAccountFormConstants.contentPaddingVertical.h,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withValues(
            alpha: AddAccountFormConstants.containerOpacity,
          ),
          borderRadius: BorderRadius.circular(
            AddAccountFormConstants.borderRadius.r,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
              size: AddAccountFormConstants.iconSizeLarge.w,
            ),
            SizedBox(width: AddAccountFormConstants.smallSpacing.w),
            Expanded(
              child: Text(
                '该云盘不支持 Authorization Token 认证方式，请使用 Cookie 认证方式添加账号',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

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
            AuthorizationValidationService.getTokenInstructions(
              widget.cloudDriveType,
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// 检查 Authorization Token
  Future<void> _checkAuthorization() async {
    final token = widget.authorizationController.text.trim();

    // 基本检查
    if (token.isEmpty) {
      setState(() {
        _errorMessage = '请先输入 Authorization Token';
        _successMessage = null;
      });
      return;
    }

    // 检查是否支持
    if (!AuthorizationValidationService.supportsAuthorizationToken(
      widget.cloudDriveType,
    )) {
      setState(() {
        _errorMessage = '该云盘不支持 Authorization Token 认证方式，请使用 Cookie 认证方式';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // 调用验证服务
      final result = await AuthorizationValidationService.validateToken(
        token: token,
        type: widget.cloudDriveType,
        accountName: widget.nameController?.text.trim(),
      );

      if (!mounted) return;

      if (result.isValid) {
        // 验证成功，更新输入框
        if (result.formattedToken != null) {
          widget.authorizationController.text = result.formattedToken!;
        }

        // 如果提供了名称控制器且名称为空，自动填充用户名
        if (widget.nameController != null &&
            widget.nameController!.text.trim().isEmpty &&
            result.username != null) {
          widget.nameController!.text = result.username!;
        }

        setState(() {
          _isValidating = false;
          _successMessage = result.successMessage ?? 'Token 验证成功！';
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isValidating = false;
          _errorMessage = result.errorMessage ?? 'Token 验证失败';
          _successMessage = null;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isValidating = false;
        _errorMessage = '验证过程中发生错误: $e';
        _successMessage = null;
      });
    }
  }
}
