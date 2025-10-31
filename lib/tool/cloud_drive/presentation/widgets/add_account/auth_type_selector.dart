import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/cloud_drive_entities.dart';

/// 认证类型选择器组件
class AuthTypeSelector extends StatelessWidget {
  final AuthType selectedAuthType;
  final ValueChanged<AuthType> onAuthTypeChanged;

  const AuthTypeSelector({
    super.key,
    required this.selectedAuthType,
    required this.onAuthTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择登录方式',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children:
                AuthType.values.map((authType) {
                  final isSelected = selectedAuthType == authType;
                  return InkWell(
                    onTap: () => onAuthTypeChanged(authType),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).dividerColor,
                                width: 2,
                              ),
                            ),
                            child:
                                isSelected
                                    ? Icon(
                                      Icons.check,
                                      size: 16.sp,
                                      color: Theme.of(context).primaryColor,
                                    )
                                    : null,
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            _getAuthTypeIcon(authType),
                            size: 20.sp,
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).iconTheme.color,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getAuthTypeName(authType),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isSelected
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  _getAuthTypeDescription(authType),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getAuthTypeIcon(AuthType authType) {
    switch (authType) {
      case AuthType.cookie:
        return Icons.cookie;
      case AuthType.authorization:
        return Icons.lock;
      case AuthType.qrCode:
        return Icons.qr_code;
      case AuthType.web:
        return Icons.web;
    }
  }

  String _getAuthTypeName(AuthType authType) {
    switch (authType) {
      case AuthType.cookie:
        return 'Cookie登录';
      case AuthType.authorization:
        return 'Authorization登录';
      case AuthType.qrCode:
        return '二维码登录';
      case AuthType.web:
        return 'WebView登录';
    }
  }

  String _getAuthTypeDescription(AuthType authType) {
    switch (authType) {
      case AuthType.cookie:
        return '手动输入Cookie信息';
      case AuthType.authorization:
        return '手动输入Authorization Token';
      case AuthType.qrCode:
        return '扫描二维码快速登录';
      case AuthType.web:
        return '在应用内浏览器登录';
    }
  }
}
