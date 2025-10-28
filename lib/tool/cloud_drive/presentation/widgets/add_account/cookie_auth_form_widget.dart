import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/cloud_drive_entities.dart';
import '../../../services/cookie_validation_service.dart';
import 'add_account_form_constants.dart';

/// Cookie 认证表单组件
///
/// 提供完整的 Cookie 输入、验证和状态显示功能
class CookieAuthFormWidget extends StatefulWidget {
  final CloudDriveType cloudDriveType;
  final TextEditingController cookiesController;
  final TextEditingController? nameController;

  const CookieAuthFormWidget({
    super.key,
    required this.cloudDriveType,
    required this.cookiesController,
    this.nameController,
  });

  @override
  State<CookieAuthFormWidget> createState() => _CookieAuthFormWidgetState();
}

class _CookieAuthFormWidgetState extends State<CookieAuthFormWidget> {
  bool _isValidating = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cookie 输入框
        _buildCookieInput(),
        SizedBox(height: AddAccountFormConstants.smallSpacing.h),

        // 检查按钮
        _buildCheckButton(),
        SizedBox(height: AddAccountFormConstants.smallSpacing.h),

        // 状态提示
        _buildStatusIndicator(),
        if (_errorMessage != null || _successMessage != null)
          SizedBox(height: AddAccountFormConstants.smallSpacing.h),

        // 帮助信息
        _buildHelpInfo(),
      ],
    );
  }

  /// 构建 Cookie 输入框
  Widget _buildCookieInput() {
    return TextField(
      controller: widget.cookiesController,
      maxLines: AddAccountFormConstants.cookieTextFieldMaxLines,
      decoration: InputDecoration(
        labelText: AddAccountFormConstants.labelCookie,
        hintText: AddAccountFormConstants.hintCookie,
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
        onPressed: _isValidating ? null : _checkCookie,
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
                AddAccountFormConstants.instructionCookieTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AddAccountFormConstants.smallSpacing.h),
          Text(
            CookieValidationService.getCookieInstructions(
              widget.cloudDriveType,
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// 检查 Cookie
  Future<void> _checkCookie() async {
    if (widget.cookiesController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '请先输入 Cookie';
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
      final result = await CookieValidationService.validateCookie(
        cookies: widget.cookiesController.text.trim(),
        type: widget.cloudDriveType,
        accountName: widget.nameController?.text.trim(),
      );

      if (!mounted) return;

      if (result.isValid) {
        // 验证成功，更新 Cookie 输入框为格式化后的值
        widget.cookiesController.text = result.formattedCookie!;

        // 如果提供了名称控制器且名称为空，自动填充用户名
        if (widget.nameController != null &&
            widget.nameController!.text.trim().isEmpty &&
            result.username != null) {
          widget.nameController!.text = result.username!;
        }

        setState(() {
          _isValidating = false;
          _successMessage = result.successMessage;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isValidating = false;
          _errorMessage = result.errorMessage;
          _successMessage = null;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isValidating = false;
        _errorMessage = 'Cookie 验证异常: $e';
        _successMessage = null;
      });
    }
  }
}
