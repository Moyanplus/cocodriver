import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../data/models/cloud_drive_dtos.dart';
import '../../services/base/qr_login_service.dart';
import '../../config/cloud_drive_ui_config.dart';
import '../pages/cloud_drive_login_webview.dart';

/// 云盘账号添加表单组件
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
  CloudDriveType selectedType = CloudDriveType.baidu;
  final nameController = TextEditingController();
  final cookiesController = TextEditingController();
  bool useWebViewLogin = true; // 默认使用WebView登录
  AuthType selectedAuthType = AuthType.cookie;

  // 二维码登录相关状态
  StreamSubscription<QRLoginInfo>? _qrLoginSubscription;
  QRLoginInfo? _currentQRLoginInfo;
  bool _isGeneratingQR = false;
  String? _qrError;

  @override
  void dispose() {
    nameController.dispose();
    cookiesController.dispose();
    _qrLoginSubscription?.cancel();
    if (_currentQRLoginInfo != null) {
      QRLoginManager.cancelQRLogin(_currentQRLoginInfo!.qrId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 内容区域
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 云盘类型选择
                _buildCloudDriveTypeSelector(),
                SizedBox(height: ResponsiveUtils.getSpacing()),

                // 账号名称输入
                _buildAccountNameInput(),
                SizedBox(height: ResponsiveUtils.getSpacing()),

                // 登录方式选择
                _buildAuthTypeSelector(),
                SizedBox(height: ResponsiveUtils.getSpacing()),

                // 根据选择显示不同的内容
                _buildAuthContent(),
              ],
            ),
          ),
        ),

        // 操作按钮区域
        Container(
          width: double.infinity,
          padding: ResponsiveUtils.getResponsivePadding(all: 16.w),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _getActionButtons(),
          ),
        ),
      ],
    );
  }

  /// 构建云盘类型选择器
  Widget _buildCloudDriveTypeSelector() {
    return DropdownButtonFormField<CloudDriveType>(
      value: selectedType,
      decoration: InputDecoration(
        labelText: '云盘类型',
        labelStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.getCardRadius()),
        ),
        contentPadding: ResponsiveUtils.getResponsivePadding(
          horizontal: 16.w,
          vertical: 12.h,
        ),
      ),
      items:
          CloudDriveType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        type.iconData,
                        color: type.color,
                        size: ResponsiveUtils.getIconSize(20.sp),
                      ),
                      SizedBox(width: ResponsiveUtils.getSpacing() * 0.67),
                      Text(
                        type.displayName,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedType = value;
          });
        }
      },
    );
  }

  /// 构建账号名称输入框
  Widget _buildAccountNameInput() {
    return TextField(
      controller: nameController,
      style: TextStyle(fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp)),
      decoration: InputDecoration(
        labelText: '账号名称',
        hintText: '请输入账号名称',
        labelStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
        ),
        hintStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.getCardRadius()),
        ),
        contentPadding: ResponsiveUtils.getResponsivePadding(
          horizontal: 16.w,
          vertical: 12.h,
        ),
      ),
    );
  }

  /// 构建认证方式选择器
  Widget _buildAuthTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '登录方式',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing() * 0.75),
        Wrap(
          spacing: ResponsiveUtils.getSpacing() * 0.67,
          children: [
            // WebView登录
            FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.web, size: ResponsiveUtils.getIconSize(16.sp)),
                  SizedBox(width: ResponsiveUtils.getSpacing() * 0.33),
                  Text(
                    'WebView',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
                    ),
                  ),
                ],
              ),
              selected: selectedAuthType == AuthType.cookie && useWebViewLogin,
              onSelected: (selected) {
                setState(() {
                  selectedAuthType = AuthType.cookie;
                  useWebViewLogin = selected;
                });
              },
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.primary,
            ),
            // Cookie登录
            FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cookie, size: ResponsiveUtils.getIconSize(16.sp)),
                  SizedBox(width: ResponsiveUtils.getSpacing() * 0.33),
                  Text(
                    'Cookie',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
                    ),
                  ),
                ],
              ),
              selected: selectedAuthType == AuthType.cookie && !useWebViewLogin,
              onSelected: (selected) {
                setState(() {
                  selectedAuthType = AuthType.cookie;
                  useWebViewLogin = !selected;
                });
              },
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.primary,
            ),
            // 二维码登录
            if (QRLoginManager.isSupported(selectedType)) ...[
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: ResponsiveUtils.getIconSize(16.sp),
                    ),
                    SizedBox(width: ResponsiveUtils.getSpacing() * 0.33),
                    Text(
                      '二维码',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
                      ),
                    ),
                  ],
                ),
                selected: selectedAuthType == AuthType.qrCode,
                onSelected: (selected) {
                  setState(() {
                    selectedAuthType = AuthType.qrCode;
                  });
                  // 自动开始生成二维码
                  if (selected) {
                    _startQRLogin();
                  }
                },
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                checkmarkColor: Theme.of(context).colorScheme.primary,
              ),
            ] else ...[
              // 调试信息：显示为什么不支持二维码登录
              Container(
                padding: ResponsiveUtils.getResponsivePadding(all: 8.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getCardRadius() * 0.5,
                  ),
                ),
                child: Text(
                  '调试: ${selectedType.displayName} 不支持二维码登录\n'
                  '支持的类型: ${QRLoginManager.getSupportedTypes().map((e) => (e as CloudDriveType).displayName).join(", ")}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(10.sp),
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// 构建认证内容区域
  Widget _buildAuthContent() {
    if (selectedAuthType == AuthType.qrCode) {
      return _buildQRCodeAuthContent();
    } else if (useWebViewLogin) {
      return _buildWebViewAuthContent();
    } else {
      return _buildCookieAuthContent();
    }
  }

  /// 构建二维码登录内容
  Widget _buildQRCodeAuthContent() {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(all: 12.w),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getCardRadius()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.qr_code,
                color: Theme.of(context).colorScheme.primary,
                size: ResponsiveUtils.getIconSize(20.sp),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing() * 0.67),
              Text(
                '二维码登录',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing()),

          // 二维码显示区域
          _buildQRCodeDisplay(),

          SizedBox(height: ResponsiveUtils.getSpacing() * 0.75),

          // 使用说明
          Text(
            '使用${selectedType.displayName}手机APP扫描二维码完成登录',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建二维码显示组件
  Widget _buildQRCodeDisplay() {
    if (_isGeneratingQR) {
      return Container(
        height: ResponsiveUtils.getResponsiveHeight(180.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUtils.getCardRadius()),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: ResponsiveUtils.isMobile ? 2.0 : 3.0,
              ),
              SizedBox(height: ResponsiveUtils.getSpacing() * 0.75),
              Text(
                '正在生成二维码...',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_qrError != null) {
      return Container(
        height: ResponsiveUtils.getResponsiveHeight(180.h),
        padding: ResponsiveUtils.getResponsivePadding(all: 16.w),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(ResponsiveUtils.getCardRadius()),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade600,
                size: ResponsiveUtils.getIconSize(24.sp),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing() * 0.67),
              Text(
                '二维码生成失败',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing() * 0.75),
              ElevatedButton.icon(
                onPressed: _startQRLogin,
                icon: Icon(
                  Icons.refresh,
                  size: ResponsiveUtils.getIconSize(16.sp),
                ),
                label: Text(
                  '重试',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  minimumSize: Size(
                    0,
                    ResponsiveUtils.getButtonHeight() * 0.67,
                  ),
                  padding: ResponsiveUtils.getResponsivePadding(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getCardRadius() * 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentQRLoginInfo == null) {
      return Container(
        height: ResponsiveUtils.getResponsiveHeight(180.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(ResponsiveUtils.getCardRadius()),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code,
                color: Colors.grey,
                size: ResponsiveUtils.getIconSize(32.sp),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing() * 0.67),
              Text(
                '准备生成二维码...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(14.sp),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(all: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getCardRadius()),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 状态指示器和刷新按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildQRStatusIndicator()),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _startQRLogin,
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: '刷新二维码',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  minimumSize: const Size(32, 32),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 二维码
          QrImageView(
            data: _currentQRLoginInfo!.qrContent,
            version: QrVersions.auto,
            size: 120.0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            errorStateBuilder: (context, error) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('生成失败', style: TextStyle(fontSize: 10)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建二维码状态指示器
  Widget _buildQRStatusIndicator() {
    if (_currentQRLoginInfo == null) return const SizedBox.shrink();

    final status = _currentQRLoginInfo!.status;
    final message = _currentQRLoginInfo!.message ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, color: status.color, size: 16),
          const SizedBox(width: 6),
          Text(
            message.isNotEmpty ? message : status.displayName,
            style: TextStyle(
              color: status.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建WebView登录内容
  Widget _buildWebViewAuthContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '使用说明',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. 点击"开始登录"按钮\n'
            '2. 在打开的页面中完成登录\n'
            '3. 登录成功后点击悬浮按钮自动获取Cookie\n'
            '4. 确认添加账号',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// 构建Cookie登录内容
  Widget _buildCookieAuthContent() {
    return Column(
      children: [
        // 手动输入Cookie
        TextField(
          controller: cookiesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Cookie',
            hintText: '请输入登录后的Cookie',
            border: OutlineInputBorder(),
            helperText: '请先在浏览器中登录对应云盘，然后复制Cookie',
          ),
        ),
        const SizedBox(height: 16),

        // 帮助信息
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '获取Cookie步骤',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '1. 在浏览器中打开 ${selectedType.webViewConfig.initialUrl ?? 'https://www.123pan.com/'}\n'
                '2. 登录您的账号\n'
                '3. 按F12打开开发者工具\n'
                '4. 在Network标签页中找到任意请求\n'
                '5. 复制请求头中的Cookie值',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 开始二维码登录
  void _startQRLogin() {
    setState(() {
      _isGeneratingQR = true;
      _qrError = null;
      _currentQRLoginInfo = null;
    });

    _qrLoginSubscription?.cancel();
    _qrLoginSubscription = QRLoginManager.startQRLogin(selectedType).listen(
      (loginInfo) {
        final qrLoginInfo = loginInfo as QRLoginInfo;
        setState(() {
          _currentQRLoginInfo = qrLoginInfo;
          _isGeneratingQR = false;
        });

        // 处理登录成功
        if (qrLoginInfo.status == QRLoginStatus.success) {
          _handleQRLoginSuccess(qrLoginInfo);
        }
        // 处理登录失败
        else if (qrLoginInfo.status == QRLoginStatus.failed) {
          setState(() {
            _qrError = qrLoginInfo.message ?? '登录失败';
          });
        }
        // 处理二维码过期
        else if (qrLoginInfo.status == QRLoginStatus.expired) {
          setState(() {
            _qrError = '二维码已过期，请重新生成';
          });
        }
      },
      onError: (error) {
        setState(() {
          _isGeneratingQR = false;
          _qrError = error.toString();
        });
      },
    );
  }

  /// 处理二维码登录成功
  Future<void> _handleQRLoginSuccess(QRLoginInfo loginInfo) async {
    try {
      final service = QRLoginManager.getService(selectedType);
      if (service == null) {
        throw Exception('找不到${selectedType.displayName}的二维码登录服务');
      }

      // 解析认证数据
      final authData = await service.parseAuthData(loginInfo);

      // 创建账号对象
      final account = CloudDriveAccount(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: selectedType,
        name: nameController.text.trim(),
        cookies: authData, // 二维码登录返回的是Cookie
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // 调用成功回调
      widget.onAccountCreated(account);

      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedType.displayName}登录成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _qrError = '解析登录数据失败: $e';
      });
    }
  }

  /// 验证表单
  bool _validateForm() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入账号名称')));
      return false;
    }

    if (selectedAuthType == AuthType.cookie && !useWebViewLogin) {
      final cookies = cookiesController.text.trim();
      if (cookies.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请输入Cookie')));
        return false;
      }
    }

    return true;
  }

  /// 处理二维码登录确认
  Future<void> _handleQRCodeConfirm() async {
    if (!_validateForm()) return;

    // 检查是否已经登录成功
    if (_currentQRLoginInfo?.status == QRLoginStatus.success) {
      // 如果已经登录成功，直接处理
      await _handleQRLoginSuccess(_currentQRLoginInfo!);
    } else {
      // 如果还没有登录成功，显示提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请先使用${selectedType.displayName}APP扫描二维码完成登录'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 处理WebView登录
  Future<void> _handleWebViewLogin() async {
    if (!_validateForm()) return;

    final name = nameController.text.trim();
    Navigator.pop(context);

    // 打开WebView登录页面
    await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder:
            (context) => CloudDriveLoginWebView(
              cloudDriveType: selectedType,
              accountName: name,
              onLoginSuccess: (String capturedAuthData) async {
                try {
                  // 根据认证方式创建账号对象
                  final account = CloudDriveAccount(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: selectedType,
                    name: name,
                    cookies:
                        selectedType.authType == AuthType.cookie
                            ? capturedAuthData
                            : null,
                    authorizationToken:
                        selectedType.authType == AuthType.authorization
                            ? capturedAuthData
                            : null,
                    createdAt: DateTime.now(),
                    lastLoginAt: DateTime.now(),
                  );

                  widget.onAccountCreated(account);
                } catch (e) {
                  _showError('账号添加失败: $e');
                }
              },
            ),
      ),
    );
  }

  /// 处理Cookie登录
  Future<void> _handleCookieLogin() async {
    if (!_validateForm()) return;

    final name = nameController.text.trim();
    final cookies = cookiesController.text.trim();

    // 创建账号对象
    final account = CloudDriveAccount(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: selectedType,
      name: name,
      cookies: cookies,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    try {
      widget.onAccountCreated(account);
    } catch (e) {
      _showError('账号添加失败: $e');
    }
  }

  /// 显示错误信息
  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 获取操作按钮
  List<Widget> _getActionButtons() {
    if (selectedAuthType == AuthType.qrCode) {
      return [
        TextButton(
          onPressed: widget.onCancel,
          style: TextButton.styleFrom(
            padding: ResponsiveUtils.getResponsivePadding(
              horizontal: 16.w,
              vertical: 8.h,
            ),
          ),
          child: Text(
            '取消',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _handleQRCodeConfirm,
          icon: Icon(Icons.check, size: ResponsiveUtils.getIconSize(20.sp)),
          label: Text(
            '确认',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: ResponsiveUtils.getResponsivePadding(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getCardRadius() * 0.5,
              ),
            ),
          ),
        ),
      ];
    } else if (useWebViewLogin) {
      return [
        TextButton(
          onPressed: widget.onCancel,
          style: TextButton.styleFrom(
            padding: ResponsiveUtils.getResponsivePadding(
              horizontal: 16.w,
              vertical: 8.h,
            ),
          ),
          child: Text(
            '取消',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _handleWebViewLogin,
          icon: Icon(Icons.login, size: ResponsiveUtils.getIconSize(20.sp)),
          label: Text(
            '开始登录',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: ResponsiveUtils.getResponsivePadding(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getCardRadius() * 0.5,
              ),
            ),
          ),
        ),
      ];
    } else {
      return [
        TextButton(
          onPressed: widget.onCancel,
          style: TextButton.styleFrom(
            padding: ResponsiveUtils.getResponsivePadding(
              horizontal: 16.w,
              vertical: 8.h,
            ),
          ),
          child: Text(
            '取消',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _handleCookieLogin,
          style: ElevatedButton.styleFrom(
            padding: ResponsiveUtils.getResponsivePadding(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getCardRadius() * 0.5,
              ),
            ),
          ),
          child: Text(
            '添加',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(16.sp),
            ),
          ),
        ),
      ];
    }
  }
}
