import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/cloud_drive_entities.dart';
import '../../pages/auth/cloud_drive_login_page.dart';

/// WebView登录组件
class WebViewAuthWidget extends StatelessWidget {
  final CloudDriveType cloudDriveType;
  final Function(CloudDriveAccount)? onLoginSuccess;

  const WebViewAuthWidget({
    super.key,
    required this.cloudDriveType,
    this.onLoginSuccess,
  });

  /// 构建WebView登录组件的UI界面
  ///
  /// 返回一个包含WebView登录说明和打开登录页面按钮的Column组件
  /// 使用主题色彩和响应式尺寸进行样式设计
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.web,
                size: 24.sp,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WebView登录',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '在应用内浏览器中完成登录',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openWebViewLogin(context),
            icon: Icon(Icons.open_in_browser, size: 18.sp),
            label: Text('打开登录页面', style: TextStyle(fontSize: 14.sp)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 打开WebView登录页面
  ///
  /// 使用Navigator导航到CloudDriveLoginPage页面进行登录
  /// 登录成功后会创建CloudDriveAccount对象并回调onLoginSuccess
  ///
  /// [context] 当前构建上下文，用于导航
  void _openWebViewLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => CloudDriveLoginPage(
              cloudDriveType: cloudDriveType,
              accountName: 'WebView账号',
              onLoginSuccess: (cookies) async {
                Navigator.of(context).pop();
                // 创建账号对象
                final account = CloudDriveAccount(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: 'WebView账号',
                  type: cloudDriveType,
                  authType: AuthType.cookie,
                  authValue: cookies,
                  createdAt: DateTime.now(),
                  lastLoginAt: DateTime.now(),
                );
                onLoginSuccess?.call(account);
              },
            ),
      ),
    );
  }
}
