import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import '../../services/base/qr_login_service.dart';
import '../../services/cloud_drive_preferences_service.dart';
import 'add_account/qr_code_auth_widget.dart';
import 'add_account/webview_auth_widget.dart';
import 'add_account/cookie_auth_form_widget.dart';
import 'add_account/auth_method_selector_widget.dart';
import 'add_account/cloud_drive_type_selector_widget.dart';
import 'add_account/add_account_form_constants.dart';

// 已经重构完毕
/// 云盘账号添加表单组件
///
/// 提供云盘账号的创建功能，支持多种认证方式：
/// - Cookie 认证：手动输入 Cookie
/// - 二维码认证：扫码登录
/// - WebView 认证：在应用内浏览器登录
class AddAccountFormWidget extends ConsumerStatefulWidget {
  final Function(CloudDriveAccount) onAccountCreated;
  final VoidCallback? onCancel;

  const AddAccountFormWidget({
    super.key,
    required this.onAccountCreated,
    this.onCancel,
  });

  @override
  ConsumerState<AddAccountFormWidget> createState() =>
      _AddAccountFormWidgetState();
}

class _AddAccountFormWidgetState extends ConsumerState<AddAccountFormWidget> {
  // 表单状态
  CloudDriveType _selectedType = CloudDriveType.baidu;
  AuthType _selectedAuthType = AuthType.cookie;
  bool _isInitialized = false;

  // 文本控制器
  final _nameController = TextEditingController();
  final _cookiesController = TextEditingController();

  // 二维码登录相关
  StreamSubscription<QRLoginInfo>? _qrLoginSubscription;
  QRLoginInfo? _currentQRLoginInfo;

  // 服务
  final _preferencesService = CloudDrivePreferencesService();

  @override
  void initState() {
    super.initState();
    _initializePreferences();

    // 监听输入框变化，实时更新按钮状态
    _nameController.addListener(_updateButtonState);
    _cookiesController.addListener(_updateButtonState);
  }

  /// 更新按钮状态
  void _updateButtonState() {
    setState(() {
      // 触发UI重建，更新按钮启用状态
    });
  }

  @override
  void dispose() {
    // 移除监听器
    _nameController.removeListener(_updateButtonState);
    _cookiesController.removeListener(_updateButtonState);

    _nameController.dispose();
    _cookiesController.dispose();
    _qrLoginSubscription?.cancel();
    if (_currentQRLoginInfo != null) {
      QRLoginManager.cancelQRLogin(_currentQRLoginInfo!.qrId);
    }
    super.dispose();
  }

  /// 初始化用户偏好设置
  Future<void> _initializePreferences() async {
    try {
      final defaultType = await _preferencesService.getDefaultCloudDriveType();
      final defaultAuthType = await _preferencesService.getDefaultAuthType(
        defaultType,
      );

      if (mounted) {
        setState(() {
          _selectedType = defaultType;
          _selectedAuthType = defaultAuthType;
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedType = CloudDriveType.baidu;
          _selectedAuthType = AuthType.web;
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildLoadingState();
    }

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
                children: [
                  // 云盘类型选择
                  CloudDriveTypeSelectorWidget(
                    selectedType: _selectedType,
                    onTypeChanged: _handleCloudDriveTypeChanged,
                  ),
                  SizedBox(height: AddAccountFormConstants.itemSpacing.h),

                  // 账号名称输入
                  _buildAccountNameInput(),
                  SizedBox(height: AddAccountFormConstants.itemSpacing.h),

                  // 认证方式选择
                  AuthMethodSelectorWidget(
                    cloudDriveType: _selectedType,
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

  /// 构建加载状态
  Widget _buildLoadingState() {
    return SizedBox(
      height: AddAccountFormConstants.loadingMinHeight.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: AddAccountFormConstants.itemSpacing.h),
            Text(AddAccountFormConstants.msgLoadingPreferences),
          ],
        ),
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
      case AuthType.qrCode:
        return _buildQRCodeAuth();
      case AuthType.web:
        return _buildWebViewAuth();
      case AuthType.cookie:
        return _buildCookieAuth();
    }
  }

  /// 构建二维码认证
  Widget _buildQRCodeAuth() {
    return QRCodeAuthWidget(
      cloudDriveType: _selectedType,
      onLoginSuccess: (qrLoginInfo) => _handleQRLoginSuccess(qrLoginInfo),
      onError: (error) {
        _showErrorSnackBar(
          '${AddAccountFormConstants.msgQRLoginFailed}: $error',
        );
      },
    );
  }

  /// 构建 WebView 认证
  Widget _buildWebViewAuth() {
    return Column(
      children: [
        _buildWebViewInstructions(),
        SizedBox(height: AddAccountFormConstants.itemSpacing.h),
        WebViewAuthWidget(
          cloudDriveType: _selectedType,
          onLoginSuccess: widget.onAccountCreated,
        ),
      ],
    );
  }

  /// 构建 WebView 使用说明
  Widget _buildWebViewInstructions() {
    return Container(
      padding: EdgeInsets.all(AddAccountFormConstants.contentPaddingVertical.w),
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
                AddAccountFormConstants.instructionTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AddAccountFormConstants.smallSpacing.h),
          Text(
            AddAccountFormConstants.webViewInstructions,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// 构建 Cookie 认证
  Widget _buildCookieAuth() {
    return CookieAuthFormWidget(
      cloudDriveType: _selectedType,
      cookiesController: _cookiesController,
      nameController: _nameController,
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
          _buildPrimaryButton(),
        ],
      ),
    );
  }

  /// 构建主要操作按钮
  Widget _buildPrimaryButton() {
    if (_selectedAuthType == AuthType.web) {
      return ElevatedButton.icon(
        onPressed: _validateForm() ? _createAccount : null,
        style: _getButtonStyle(),
        icon: Icon(Icons.login, size: AddAccountFormConstants.iconSizeNormal.w),
        label: Text(
          AddAccountFormConstants.btnStartLogin,
          style: TextStyle(fontSize: AddAccountFormConstants.fontSizeNormal.sp),
        ),
      );
    }

    return ElevatedButton(
      onPressed: _validateForm() ? _createAccount : null,
      style: _getButtonStyle(),
      child: Text(
        AddAccountFormConstants.btnAddAccount,
        style: TextStyle(fontSize: AddAccountFormConstants.fontSizeNormal.sp),
      ),
    );
  }

  /// 获取按钮样式
  ButtonStyle _getButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(
        horizontal: AddAccountFormConstants.buttonPaddingHorizontal.w,
        vertical: AddAccountFormConstants.buttonPaddingVertical.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AddAccountFormConstants.borderRadius.r,
        ),
      ),
    );
  }

  /// 处理云盘类型变更
  void _handleCloudDriveTypeChanged(CloudDriveType type) {
    setState(() {
      _selectedType = type;
      _selectedAuthType = type.authType;
    });

    _preferencesService.setDefaultCloudDriveType(type);
    _preferencesService.setDefaultAuthType(type.authType);
  }

  /// 处理认证方式变更
  void _handleAuthTypeChanged(AuthType authType) {
    setState(() {
      _selectedAuthType = authType;
    });

    _preferencesService.setDefaultAuthType(authType);
  }

  /// 验证表单
  bool _validateForm() {
    switch (_selectedAuthType) {
      case AuthType.cookie:
        return _nameController.text.trim().isNotEmpty &&
            _cookiesController.text.trim().isNotEmpty;
      case AuthType.qrCode:
        // 二维码登录不需要填名称，成功后即可添加
        return _currentQRLoginInfo != null;
      case AuthType.web:
        return _nameController.text.trim().isNotEmpty;
    }
  }

  /// 创建账号
  Future<void> _createAccount() async {
    if (!_validateForm()) {
      _showErrorSnackBar(AddAccountFormConstants.msgFormIncomplete);
      return;
    }

    try {
      CloudDriveAccount account;

      switch (_selectedAuthType) {
        case AuthType.cookie:
          account = _createCookieAccount();
          break;
        case AuthType.qrCode:
          // 显示加载提示
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('正在获取认证信息...')));
          account = await _createQRCodeAccount();
          break;
        case AuthType.web:
          // Authorization 登录在 WebViewAuthWidget 中处理
          return;
      }

      widget.onAccountCreated(account);
    } catch (e) {
      _showErrorSnackBar(
        '${AddAccountFormConstants.msgAccountCreateFailed}: $e',
      );
    }
  }

  /// 创建 Cookie 账号
  CloudDriveAccount _createCookieAccount() {
    final cookiesValue = _cookiesController.text.trim();
    debugPrint('🍪 创建Cookie账号 - cookies长度: ${cookiesValue.length}');
    debugPrint(
      '🍪 创建Cookie账号 - cookies前100字符: ${cookiesValue.length > 100 ? cookiesValue.substring(0, 100) : cookiesValue}',
    );

    final account = CloudDriveAccount(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      type: _selectedType,
      cookies: cookiesValue,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    debugPrint('🍪 账号创建完成 - isLoggedIn: ${account.isLoggedIn}');
    debugPrint(
      '🍪 账号创建完成 - cookies字段: ${account.cookies?.substring(0, account.cookies!.length > 100 ? 100 : account.cookies!.length)}',
    );

    return account;
  }

  /// 创建二维码账号
  Future<CloudDriveAccount> _createQRCodeAccount() async {
    if (_currentQRLoginInfo == null) {
      throw Exception(AddAccountFormConstants.msgQRCodeNotGenerated);
    }

    // 使用二维码登录服务将 loginToken 换取 cookie
    final qrLoginService = QRLoginManager.getService(_selectedType);
    if (qrLoginService == null) {
      throw Exception('${_selectedType.displayName}不支持二维码登录');
    }

    LogManager().cloudDrive('开始解析二维码登录认证数据...');
    final cookies = await qrLoginService.parseAuthData(_currentQRLoginInfo!);
    LogManager().cloudDrive('二维码登录认证数据解析成功');

    final account = CloudDriveAccount(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name:
          _nameController.text.isNotEmpty
              ? _nameController.text.trim()
              : '${_selectedType.displayName}账号',
      type: _selectedType,
      cookies: cookies, // 保存解析得到的 cookie
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    LogManager().cloudDrive(
      '🍪 二维码账号创建完成 - cookies字段: ${account.cookies?.substring(0, account.cookies!.length > 100 ? 100 : account.cookies!.length)}',
    );

    return account;
  }

  /// 处理二维码登录成功
  /// 保存登录信息，启用"添加账号"按钮
  void _handleQRLoginSuccess(QRLoginInfo loginInfo) {
    setState(() {
      _currentQRLoginInfo = loginInfo;
    });
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
}
