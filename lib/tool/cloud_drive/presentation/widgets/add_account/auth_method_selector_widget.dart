import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/cloud_drive_entities.dart';
import 'add_account_form_constants.dart';

/// 认证方式选择器组件
///
/// 使用 FilterChip 样式，简洁明了
/// 根据云盘类型自动过滤显示支持的认证方式
class AuthMethodSelectorWidget extends StatelessWidget {
  final CloudDriveType cloudDriveType;
  final AuthType selectedAuthType;
  final ValueChanged<AuthType> onAuthTypeChanged;

  const AuthMethodSelectorWidget({
    super.key,
    required this.cloudDriveType,
    required this.selectedAuthType,
    required this.onAuthTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 获取支持的认证方式
    final supportedAuthTypes = cloudDriveType.supportedAuthTypes;

    return FormField<AuthType>(
      initialValue: selectedAuthType,
      builder:
          (state) => InputDecorator(
            decoration: InputDecoration(
              labelText: AddAccountFormConstants.labelLoginMethod,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 网页登录
                _buildFilterChip(
                  context: context,
                  authType: AuthType.web,
                  icon: Icons.web,
                  label: AddAccountFormConstants.authMethodWeb,
                  isEnabled: supportedAuthTypes.contains(AuthType.web),
                ),
                // Cookie 登录（与Authorization互斥）
                if (supportedAuthTypes.contains(AuthType.cookie))
                  _buildFilterChip(
                    context: context,
                    authType: AuthType.cookie,
                    icon: Icons.cookie,
                    label: AddAccountFormConstants.authMethodCookie,
                    isEnabled: true,
                  ),
                // Authorization Token登录（与Cookie互斥）
                if (supportedAuthTypes.contains(AuthType.authorization))
                  _buildFilterChip(
                    context: context,
                    authType: AuthType.authorization,
                    icon: Icons.lock,
                    label: AddAccountFormConstants.authMethodAuthorization,
                    isEnabled: true,
                  ),
                // 二维码登录
                _buildFilterChip(
                  context: context,
                  authType: AuthType.qrCode,
                  icon: Icons.qr_code,
                  label: AddAccountFormConstants.authMethodQRCode,
                  isEnabled: supportedAuthTypes.contains(AuthType.qrCode),
                ),
              ],
            ),
          ),
    );
  }

  /// 构建单个 FilterChip
  Widget _buildFilterChip({
    required BuildContext context,
    required AuthType authType,
    required IconData icon,
    required String label,
    required bool isEnabled,
  }) {
    final isSelected = selectedAuthType == authType;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AddAccountFormConstants.iconSizeSmall.w),
            SizedBox(width: AddAccountFormConstants.tinySpacing.w),
            Text(label),
          ],
        ),
        selected: isSelected && isEnabled,
        onSelected:
            isEnabled ? (selected) => onAuthTypeChanged(authType) : null,
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        checkmarkColor: Theme.of(context).colorScheme.primary,
        disabledColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
    );
  }
}
