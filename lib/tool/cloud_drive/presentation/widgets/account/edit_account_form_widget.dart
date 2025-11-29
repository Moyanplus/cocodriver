import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/cloud_drive_entities.dart';
import '../../../services/registry/cloud_drive_provider_registry.dart';
import '../add_account/cookie_auth_form_widget.dart';
import '../add_account/authorization_auth_form_widget.dart';
import '../add_account/auth_method_selector_widget.dart';
import '../add_account/add_account_form_constants.dart';

/// 编辑账号表单组件
///
/// 提供编辑现有云盘账号的功能：
/// - 修改账号名称
/// - 更换认证方式（Cookie/WebView/QRCode）
/// - 更新认证凭证
class EditAccountFormWidget extends StatefulWidget {
  final CloudDriveAccount account;
  final Function(CloudDriveAccount) onAccountUpdated;
  final VoidCallback? onCancel;

  const EditAccountFormWidget({
    super.key,
    required this.account,
    required this.onAccountUpdated,
    this.onCancel,
  });

  @override
  State<EditAccountFormWidget> createState() => _EditAccountFormWidgetState();
}

class _EditAccountFormWidgetState extends State<EditAccountFormWidget> {
  // 表单状态
  late AuthType _selectedAuthType;

  // 文本控制器
  late TextEditingController _nameController;
  late TextEditingController _cookiesController;
  late TextEditingController _authorizationController;

  @override
  void initState() {
    super.initState();

    // 初始化控制器
    _nameController = TextEditingController(text: widget.account.name);

    // 确定当前的认证方式和内容
    _selectedAuthType =
        widget.account.actualAuthType ?? widget.account.type.authType;

    // 初始化 Cookie 控制器
    if (_selectedAuthType == AuthType.cookie &&
        widget.account.cookies != null) {
      _cookiesController = TextEditingController(text: widget.account.cookies);
    } else {
      _cookiesController = TextEditingController();
    }

    // 初始化 Authorization 控制器
    if (_selectedAuthType == AuthType.authorization &&
        widget.account.authorizationToken != null) {
      _authorizationController = TextEditingController(
        text: widget.account.authorizationToken,
      );
    } else {
      _authorizationController = TextEditingController();
    }

    // 监听输入框变化
    _nameController.addListener(_updateButtonState);
    _cookiesController.addListener(_updateButtonState);
    _authorizationController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateButtonState);
    _cookiesController.removeListener(_updateButtonState);
    _authorizationController.removeListener(_updateButtonState);
    _nameController.dispose();
    _cookiesController.dispose();
    _authorizationController.dispose();
    super.dispose();
  }

  /// 更新按钮状态
  void _updateButtonState() {
    setState(() {
      // 触发UI重建
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 可滚动的表单内容
        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AddAccountFormConstants.horizontalPadding.w,
                vertical: AddAccountFormConstants.verticalPadding.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 云盘类型信息（不可编辑）
                  _buildAccountTypeInfo(),
                  SizedBox(height: AddAccountFormConstants.itemSpacing.h),

                  // 账号名称输入
                  _buildAccountNameInput(),
                  SizedBox(height: AddAccountFormConstants.itemSpacing.h),

                  // 认证方式选择
                  AuthMethodSelectorWidget(
                    cloudDriveType: widget.account.type,
                    selectedAuthType: _selectedAuthType,
                    onAuthTypeChanged: _handleAuthTypeChanged,
                  ),
                  SizedBox(height: AddAccountFormConstants.itemSpacing.h),

                  // 认证内容
                  _buildAuthContent(),
                ],
              ),
            ),
          ),
        ),

        // 底部操作按钮
        _buildActionButtons(),
      ],
    );
  }

  /// 构建账号类型信息（不可编辑）
  Widget _buildAccountTypeInfo() {
    final descriptor = CloudDriveProviderRegistry.get(widget.account.type);
    if (descriptor == null) {
      throw StateError('未注册云盘描述: ${widget.account.type}');
    }
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          AddAccountFormConstants.borderRadius.r,
        ),
      ),
      child: Row(
        children: [
          Icon(
            descriptor.iconData ?? Icons.cloud_outlined,
            color: descriptor.color ?? Theme.of(context).colorScheme.primary,
            size: 32.sp,
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                descriptor.displayName ?? widget.account.type.name,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                '账号ID: ${widget.account.id}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建账号名称输入框
  Widget _buildAccountNameInput() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: AddAccountFormConstants.labelAccountName,
        hintText: AddAccountFormConstants.hintAccountName,
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

  /// 构建认证内容
  Widget _buildAuthContent() {
    switch (_selectedAuthType) {
      case AuthType.cookie:
        return CookieAuthFormWidget(
          cloudDriveType: widget.account.type,
          cookiesController: _cookiesController,
          nameController: _nameController,
        );
      case AuthType.authorization:
        return AuthorizationAuthFormWidget(
          cloudDriveType: widget.account.type,
          authorizationController: _authorizationController,
          nameController: _nameController,
        );
      case AuthType.web:
        return _buildWebViewAuthNote();
      case AuthType.qrCode:
        return _buildQRCodeAuthNote();
    }
  }

  /// 构建 WebView 认证提示
  Widget _buildWebViewAuthNote() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '提示',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'WebView 认证需要重新登录。保存后将清除当前认证信息，您需要重新进行网页登录。',
            style: TextStyle(fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  /// 构建二维码认证提示
  Widget _buildQRCodeAuthNote() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '提示',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '二维码认证需要重新扫码。保存后将清除当前认证信息，您需要重新扫描二维码登录。',
            style: TextStyle(fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AddAccountFormConstants.horizontalPadding.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(
              alpha: AddAccountFormConstants.outlineOpacity,
            ),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: widget.onCancel,
            child: Text(
              AddAccountFormConstants.btnCancel,
              style: TextStyle(
                fontSize: AddAccountFormConstants.fontSizeNormal.sp,
              ),
            ),
          ),
          SizedBox(width: AddAccountFormConstants.buttonSpacing.w),
          ElevatedButton(
            onPressed: _validateForm() ? _saveAccount : null,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AddAccountFormConstants.buttonPaddingHorizontal.w,
                vertical: AddAccountFormConstants.buttonPaddingVertical.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AddAccountFormConstants.borderRadius.r,
                ),
              ),
            ),
            child: Text(
              '保存',
              style: TextStyle(
                fontSize: AddAccountFormConstants.fontSizeNormal.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理认证方式变更
  void _handleAuthTypeChanged(AuthType authType) {
    setState(() {
      _selectedAuthType = authType;

      // 如果切换认证方式，尝试恢复对应的认证信息
      if (authType == AuthType.cookie && _cookiesController.text.isEmpty) {
        // 如果有旧的 Cookie，尝试恢复
        if (widget.account.cookies != null) {
          _cookiesController.text = widget.account.cookies!;
        }
      } else if (authType == AuthType.authorization &&
          _authorizationController.text.isEmpty) {
        // 如果有旧的 Authorization Token，尝试恢复
        if (widget.account.authorizationToken != null) {
          _authorizationController.text = widget.account.authorizationToken!;
        }
      }
    });
  }

  /// 验证表单
  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      return false;
    }

    // 如果选择 Cookie 认证，需要验证 Cookie 不为空
    if (_selectedAuthType == AuthType.cookie) {
      return _cookiesController.text.trim().isNotEmpty;
    }

    return true;
  }

  /// 保存账号
  void _saveAccount() {
    if (!_validateForm()) {
      _showErrorSnackBar('请填写完整信息');
      return;
    }

    try {
      // 创建更新后的账号对象
      CloudDriveAccount updatedAccount;

      switch (_selectedAuthType) {
        case AuthType.cookie:
          updatedAccount = widget.account.copyWith(
            name: _nameController.text.trim(),
            cookies: _cookiesController.text.trim(),
            // 清除其他认证方式的字段
            clearAuthorizationToken: true,
            clearQrCodeToken: true,
            lastLoginAt: DateTime.now(),
          );
          break;
        case AuthType.authorization:
          updatedAccount = widget.account.copyWith(
            name: _nameController.text.trim(),
            authorizationToken: _authorizationController.text.trim(),
            // 清除其他认证方式的字段
            clearCookies: true,
            clearQrCodeToken: true,
            lastLoginAt: DateTime.now(),
          );
          break;
        case AuthType.web:
          // WebView 认证需要重新登录，清空所有认证信息
          updatedAccount = widget.account.copyWith(
            name: _nameController.text.trim(),
            clearCookies: true,
            clearAuthorizationToken: true,
            clearQrCodeToken: true,
            lastLoginAt: DateTime.now(),
          );
          _showWarningSnackBar('已清除认证信息，请重新进行网页登录');
          break;
        case AuthType.qrCode:
          // 二维码认证需要重新扫码，清空所有认证信息
          updatedAccount = widget.account.copyWith(
            name: _nameController.text.trim(),
            clearCookies: true,
            clearAuthorizationToken: true,
            clearQrCodeToken: true,
            lastLoginAt: DateTime.now(),
          );
          _showWarningSnackBar('已清除认证信息，请重新扫描二维码登录');
          break;
      }

      widget.onAccountUpdated(updatedAccount);
    } catch (e) {
      _showErrorSnackBar('保存失败: $e');
    }
  }

  /// 显示错误提示
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  /// 显示警告提示
  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }
}
